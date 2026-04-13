<#
.SYNOPSIS
    BusinessMap ↔ ADO Epic sync — core functions.

.DESCRIPTION
    ST-2026-001: Compute BusinessMap Epic state from ADO child item state categories.
    ST-2026-002: Delta detection and bootstrap between a BM board and ADO work area.

    ADO state category → BusinessMap column mapping:
        Proposed  → 'Requested'
        InProgress→ 'In Progress'
        Complete  → 'Done'
        Removed   → excluded from calculation; if all children Removed, returns $null

    Sync never moves an Epic backward. Backlog is a pre-planning state outside sync scope.
#>

function Get-BmEpicState {
    <#
    .SYNOPSIS
        Computes the target BusinessMap column for an Epic from ADO child state categories.

    .PARAMETER StateCategories
        Array of ADO state category strings: Proposed, InProgress, Complete, Removed.

    .OUTPUTS
        [string] Target BM column: 'Requested', 'In Progress', or 'Done'.
        [$null]  All children are Removed — caller must skip the Epic and log for manual review.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string[]]$StateCategories
    )

    $active = @($StateCategories | Where-Object { $_ -ne 'Removed' })

    if ($active.Count -eq 0) {
        return $null  # All Removed — skip + log
    }

    if ($active -contains 'InProgress') {
        return 'In Progress'
    }

    if ($active -contains 'Proposed') {
        # Either all Proposed, or a mix of Proposed and Complete — both map to 'In Progress'
        # except all-Proposed which maps to 'Requested'
        if ($active -contains 'Complete') {
            return 'In Progress'  # partial completion
        }
        return 'Requested'  # nothing started yet
    }

    return 'Done'  # all active children are Complete
}

function Get-AdoStateCategoryMap {
    <#
    .SYNOPSIS
        Builds a state-name → state-category lookup for a given ADO work item type.

    .DESCRIPTION
        Queries the ADO process API for a work item type's state definitions.
        Used internally to resolve category from state name, since state category
        is not a directly queryable field on work items.
    #>
    [CmdletBinding()]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)] [string]$Organization,
        [Parameter(Mandatory)] [string]$Project,
        [Parameter(Mandatory)] [string]$WorkItemType,
        [Parameter(Mandatory)] [hashtable]$Headers,
        [string]$ApiVersion = '7.1'
    )

    $encodedType = [Uri]::EscapeDataString($WorkItemType)
    $uri = "https://dev.azure.com/$Organization/$Project/_apis/wit/workitemtypes/$encodedType/states?api-version=$ApiVersion"
    $response = Invoke-RestMethod -Uri $uri -Headers $Headers -ErrorAction Stop

    $map = @{}
    foreach ($state in $response.value) {
        $map[$state.name] = $state.stateCategory
    }
    return $map
}

function Get-AdoChildStateCategories {
    <#
    .SYNOPSIS
        Returns the ADO state categories of all child work items under a given Epic.

    .PARAMETER Organization
        ADO organization name (e.g. 'myorg').

    .PARAMETER Project
        ADO project name.

    .PARAMETER EpicId
        Work item ID of the Epic whose children to query.

    .PARAMETER PersonalAccessToken
        ADO Personal Access Token with work item read scope.

    .OUTPUTS
        [string[]] State category for each child: Proposed, InProgress, Complete, or Removed.
        Empty array if the Epic has no children.
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)] [string]$Organization,
        [Parameter(Mandatory)] [string]$Project,
        [Parameter(Mandatory)] [int]$EpicId,
        [Parameter(Mandatory)] [string]$PersonalAccessToken,
        [string]$ApiVersion = '7.1'
    )

    $base64Auth = [Convert]::ToBase64String(
        [Text.Encoding]::ASCII.GetBytes(":$PersonalAccessToken")
    )
    $headers = @{ Authorization = "Basic $base64Auth" }

    # Step 1 — get Epic with child relations
    $epicUri = "https://dev.azure.com/$Organization/$Project/_apis/wit/workitems/$($EpicId)?`$expand=relations&api-version=$ApiVersion"
    $epic = Invoke-RestMethod -Uri $epicUri -Headers $headers -ErrorAction Stop

    $childIds = @(
        $epic.relations |
        Where-Object { $_.rel -eq 'System.LinkTypes.Hierarchy-Forward' } |
        ForEach-Object { [int]($_.url -split '/')[-1] }
    )

    if ($childIds.Count -eq 0) {
        return @()
    }

    # Step 2 — get child work items with state and type
    $ids = $childIds -join ','
    $childUri = "https://dev.azure.com/$Organization/$Project/_apis/wit/workitems?ids=$ids&fields=System.State,System.WorkItemType&api-version=$ApiVersion"
    $children = (Invoke-RestMethod -Uri $childUri -Headers $headers -ErrorAction Stop).value

    # Step 3 — resolve state → category per work item type (cached per type)
    $categoryCache = @{}
    $categories = foreach ($child in $children) {
        $type  = $child.fields.'System.WorkItemType'
        $state = $child.fields.'System.State'

        if (-not $categoryCache.ContainsKey($type)) {
            $categoryCache[$type] = Get-AdoStateCategoryMap `
                -Organization $Organization `
                -Project      $Project `
                -WorkItemType $type `
                -Headers      $headers `
                -ApiVersion   $ApiVersion
        }

        $categoryCache[$type][$state]
    }

    return $categories
}

# ---------------------------------------------------------------------------
# ST-2026-002: Delta detection and bootstrap
# ---------------------------------------------------------------------------

function Get-SyncDelta {
    <#
    .SYNOPSIS
        Computes the delta between ADO Epics and BM board cards.

    .PARAMETER AdoEpicIds
        Integer array of Epic work item IDs from the ADO work area.

    .PARAMETER BmCards
        Array of objects with at minimum Id (int) and CustomId (string|null) properties,
        representing cards on the target BM board.

    .OUTPUTS
        Hashtable with three keys:
          Paired   — ADO Epic IDs that have a matching BM card (CustomId set)
          AdoOnly  — ADO Epic IDs with no matching BM card → should be created in BM
          BmOnly   — BM card objects with no CustomId → unlinked, log for review
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [AllowEmptyCollection()] [int[]]$AdoEpicIds,
        [Parameter(Mandatory)] [AllowEmptyCollection()] [object[]]$BmCards
    )

    # Split BM cards into linked (CustomId set) and unlinked
    $linked   = @($BmCards | Where-Object { $_.CustomId })
    $bmOnly   = @($BmCards | Where-Object { -not $_.CustomId })

    # Build lookup: ADO ID (as string) → BM card
    $bmByAdoId = @{}
    foreach ($card in $linked) {
        $bmByAdoId[$card.CustomId] = $card
    }

    $paired  = [System.Collections.Generic.List[int]]::new()
    $adoOnly = [System.Collections.Generic.List[int]]::new()

    foreach ($id in $AdoEpicIds) {
        if ($bmByAdoId.ContainsKey([string]$id)) {
            $paired.Add($id)
        } else {
            $adoOnly.Add($id)
        }
    }

    return @{
        Paired  = $paired.ToArray()
        AdoOnly = $adoOnly.ToArray()
        BmOnly  = $bmOnly
    }
}

function Get-BmHeaders {
    param([Parameter(Mandatory)] [string]$ApiToken)
    return @{
        'apikey'       = $ApiToken
        'Content-Type' = 'application/json'
    }
}

function Get-BmBoardCards {
    <#
    .SYNOPSIS
        Returns all cards on a specific BM board.
        Each card object includes Id, Title, and CustomId.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$BaseUrl,
        [Parameter(Mandatory)] [string]$ApiToken,
        [Parameter(Mandatory)] [int]$BoardId
    )

    $headers = Get-BmHeaders $ApiToken
    $uri     = "$BaseUrl/cards?board_ids=$BoardId&limit=1000"
    $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get -ErrorAction Stop

    return $response.data | ForEach-Object {
        [pscustomobject]@{
            Id       = $_.card_id
            Title    = $_.title
            CustomId = $_.custom_id
        }
    }
}

function Get-BmBoardColumns {
    <#
    .SYNOPSIS
        Returns columns on a BM board. Used to resolve column name → column_id.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$BaseUrl,
        [Parameter(Mandatory)] [string]$ApiToken,
        [Parameter(Mandatory)] [int]$BoardId
    )

    $headers  = Get-BmHeaders $ApiToken
    $uri      = "$BaseUrl/boards/$BoardId/columns"
    $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get -ErrorAction Stop
    return $response.data
}

function Get-BmBoardLanes {
    <#
    .SYNOPSIS
        Returns lanes on a BM board. Used to resolve the default lane_id for new cards.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$BaseUrl,
        [Parameter(Mandatory)] [string]$ApiToken,
        [Parameter(Mandatory)] [int]$BoardId
    )

    $headers  = Get-BmHeaders $ApiToken
    $uri      = "$BaseUrl/boards/$BoardId/lanes"
    $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get -ErrorAction Stop
    return $response.data
}

function New-BmCard {
    <#
    .SYNOPSIS
        Creates a new card on a BM board in the specified column and lane.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$BaseUrl,
        [Parameter(Mandatory)] [string]$ApiToken,
        [Parameter(Mandatory)] [string]$Title,
        [Parameter(Mandatory)] [int]$ColumnId,
        [Parameter(Mandatory)] [int]$LaneId,
        [Parameter(Mandatory)] [string]$CustomId
    )

    $headers = Get-BmHeaders $ApiToken
    $body    = @{
        title     = $Title
        column_id = $ColumnId
        lane_id   = $LaneId
        custom_id = $CustomId
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "$BaseUrl/cards" -Headers $headers -Method Post -Body $body -ErrorAction Stop
    return $response.data
}

function Set-BmCardTitle {
    <#
    .SYNOPSIS
        Updates the title of an existing BM card.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$BaseUrl,
        [Parameter(Mandatory)] [string]$ApiToken,
        [Parameter(Mandatory)] [int]$CardId,
        [Parameter(Mandatory)] [string]$Title
    )

    $headers = Get-BmHeaders $ApiToken
    $body    = @{ title = $Title } | ConvertTo-Json

    Invoke-RestMethod -Uri "$BaseUrl/cards/$CardId" -Headers $headers -Method Patch -Body $body -ErrorAction Stop | Out-Null
}

function Get-AdoEpics {
    <#
    .SYNOPSIS
        Returns all non-Removed Epics in an ADO area path.
        Each object includes Id and Title.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$Organization,
        [Parameter(Mandatory)] [string]$Project,
        [Parameter(Mandatory)] [string]$AreaPath,
        [Parameter(Mandatory)] [string]$PersonalAccessToken,
        [string]$ApiVersion = '7.1'
    )

    $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$PersonalAccessToken"))
    $headers    = @{ Authorization = "Basic $base64Auth"; 'Content-Type' = 'application/json' }

    # WIQL query for Epics in area path, excluding Removed
    $wiql = @{
        query = "SELECT [System.Id] FROM WorkItems WHERE [System.WorkItemType] = 'Epic' AND [System.AreaPath] UNDER '$AreaPath' AND [System.StateCategory] <> 'Removed' ORDER BY [System.Id]"
    } | ConvertTo-Json

    $wiqlUri  = "https://dev.azure.com/$Organization/$Project/_apis/wit/wiql?api-version=$ApiVersion"
    $wiqlResp = Invoke-RestMethod -Uri $wiqlUri -Headers $headers -Method Post -Body $wiql -ErrorAction Stop

    if (-not $wiqlResp.workItems -or $wiqlResp.workItems.Count -eq 0) {
        return @()
    }

    # Fetch work item details in batches of 200 (ADO limit)
    $ids    = $wiqlResp.workItems | ForEach-Object { $_.id }
    $result = [System.Collections.Generic.List[pscustomobject]]::new()

    for ($i = 0; $i -lt $ids.Count; $i += 200) {
        $batch   = ($ids[$i..([Math]::Min($i + 199, $ids.Count - 1))]) -join ','
        $itemUri = "https://dev.azure.com/$Organization/$Project/_apis/wit/workitems?ids=$batch&fields=System.Id,System.Title&api-version=$ApiVersion"
        $items   = (Invoke-RestMethod -Uri $itemUri -Headers $headers -ErrorAction Stop).value

        foreach ($item in $items) {
            $result.Add([pscustomobject]@{
                Id    = $item.fields.'System.Id'
                Title = $item.fields.'System.Title'
            })
        }
    }

    return $result.ToArray()
}
