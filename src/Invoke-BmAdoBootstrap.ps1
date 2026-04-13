<#
.SYNOPSIS
    ST-2026-002: BM↔ADO Epic bootstrap and linking verification.

.DESCRIPTION
    Scoped to one BM board and one ADO work area. On each run:
      1. Fetches all cards from the BM board and all Epics from the ADO area path.
      2. Computes the delta: paired / ADO-only (missing in BM) / BM-only (no CustomId).
      3. Creates BM cards for ADO-only Epics (initial bootstrap). Idempotent — will not
         duplicate cards that already have a matching CustomId.
      4. Verifies paired cards by confirming the ADO work item is reachable. BM card
         content is never overwritten — BM is source of truth for Epic data.
      5. Prints a summary report.

.PARAMETER BmBaseUrl
    BusinessMap API base URL. Defaults to $env:BM_BASE_URL.

.PARAMETER BmApiToken
    BusinessMap API token. Defaults to $env:BM_API_TOKEN.

.PARAMETER BmBoardId
    BusinessMap board ID to scope the sync. Defaults to $env:BM_BOARD_ID.

.PARAMETER AdoOrganization
    ADO organization name. Defaults to $env:ADO_ORG.

.PARAMETER AdoProject
    ADO project name. Defaults to $env:ADO_PROJECT.

.PARAMETER AdoAreaPath
    ADO area path to query Epics from. Defaults to $env:ADO_AREA_PATH.

.PARAMETER AdoPat
    ADO Personal Access Token. Defaults to $env:ADO_PAT.

.PARAMETER RequestedColumnName
    Name of the BM column where new cards are placed. Default: 'Requested'.

.EXAMPLE
    $env:BM_BASE_URL  = 'https://auth.businessmap.io/api/v2'
    $env:BM_API_TOKEN = '<token>'
    $env:BM_BOARD_ID  = '42'
    $env:ADO_ORG      = 'myorg'
    $env:ADO_PROJECT  = 'MyProject'
    $env:ADO_AREA_PATH= 'MyProject\ValueStream'
    $env:ADO_PAT      = '<pat>'
    .\Invoke-BmAdoBootstrap.ps1
#>
[CmdletBinding()]
param(
    [string]$BmBaseUrl          = $env:BM_BASE_URL,
    [string]$BmApiToken         = $env:BM_API_TOKEN,
    [int]   $BmBoardId          = [int]$env:BM_BOARD_ID,
    [string]$AdoOrganization    = $env:ADO_ORG,
    [string]$AdoProject         = $env:ADO_PROJECT,
    [string]$AdoAreaPath        = $env:ADO_AREA_PATH,
    [string]$AdoPat             = $env:ADO_PAT,
    [string]$RequestedColumnName = 'Requested'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/BmAdoSync.ps1"

# --- Validate required inputs ---
foreach ($param in @('BmBaseUrl','BmApiToken','BmBoardId','AdoOrganization','AdoProject','AdoAreaPath','AdoPat')) {
    if (-not (Get-Variable $param -ValueOnly)) {
        throw "Missing required parameter or environment variable: $param"
    }
}

Write-Host "=== BM↔ADO Epic Bootstrap ===" -ForegroundColor Cyan
Write-Host "Board : $BmBoardId"
Write-Host "Area  : $AdoAreaPath"
Write-Host ""

# --- Step 1: Fetch data from both systems ---
Write-Host "Fetching BM cards..." -NoNewline
$bmCards = Get-BmBoardCards -BaseUrl $BmBaseUrl -ApiToken $BmApiToken -BoardId $BmBoardId
Write-Host " $($bmCards.Count) cards"

Write-Host "Fetching ADO Epics..." -NoNewline
$adoEpics = Get-AdoEpics -Organization $AdoOrganization -Project $AdoProject -AreaPath $AdoAreaPath -PersonalAccessToken $AdoPat
Write-Host " $($adoEpics.Count) epics"

# Build ADO lookup by ID
$adoById = @{}
foreach ($epic in $adoEpics) { $adoById[$epic.Id] = $epic }

# --- Step 2: Compute delta ---
$delta = Get-SyncDelta -AdoEpicIds ($adoEpics | ForEach-Object { $_.Id }) -BmCards $bmCards

Write-Host ""
Write-Host "Delta:"
Write-Host "  Paired (in both)   : $($delta.Paired.Count)"
Write-Host "  ADO-only (missing) : $($delta.AdoOnly.Count)"
Write-Host "  BM-only (unlinked) : $($delta.BmOnly.Count)"
Write-Host ""

# --- Step 3: Resolve column and lane IDs for new card creation ---
$created = 0
if ($delta.AdoOnly.Count -gt 0) {
    Write-Host "Resolving BM board columns and lanes..."
    $columns = Get-BmBoardColumns -BaseUrl $BmBaseUrl -ApiToken $BmApiToken -BoardId $BmBoardId
    $lanes   = Get-BmBoardLanes   -BaseUrl $BmBaseUrl -ApiToken $BmApiToken -BoardId $BmBoardId

    $requestedColumn = $columns | Where-Object { $_.name -eq $RequestedColumnName } | Select-Object -First 1
    if (-not $requestedColumn) {
        throw "Column '$RequestedColumnName' not found on board $BmBoardId. Available: $($columns.name -join ', ')"
    }

    $defaultLane = $lanes | Select-Object -First 1
    if (-not $defaultLane) {
        throw "No lanes found on board $BmBoardId."
    }

    Write-Host "  Column : '$RequestedColumnName' (id=$($requestedColumn.column_id))"
    Write-Host "  Lane   : '$($defaultLane.name)' (id=$($defaultLane.lane_id))"
    Write-Host ""

    # --- Step 4a: Create missing BM cards ---
    foreach ($adoId in $delta.AdoOnly) {
        $epic = $adoById[$adoId]
        Write-Host "  Creating BM card for ADO Epic $adoId : '$($epic.Title)'" -NoNewline
        New-BmCard `
            -BaseUrl  $BmBaseUrl `
            -ApiToken $BmApiToken `
            -Title    $epic.Title `
            -ColumnId $requestedColumn.column_id `
            -LaneId   $defaultLane.lane_id `
            -CustomId ([string]$adoId)
        Write-Host " OK" -ForegroundColor Green
        $created++
    }
}

# --- Step 4b: Verify paired cards — confirm ADO work item is reachable ---
$verified = 0
if ($delta.Paired.Count -gt 0) {
    Write-Host "Verifying paired cards (ADO fetch check)..."

    foreach ($adoId in $delta.Paired) {
        $epic = $adoById[$adoId]  # already fetched — presence confirmed
        Write-Host "  ADO Epic $adoId '$($epic.Title)' — paired OK" -ForegroundColor Green
        $verified++
    }
    # BM card data is not modified — BM is source of truth for Epic content
}

# --- Step 5: Report unlinked BM cards ---
if ($delta.BmOnly.Count -gt 0) {
    Write-Host ""
    Write-Host "Unlinked BM cards (no CustomId — not part of sync):" -ForegroundColor Yellow
    foreach ($card in $delta.BmOnly) {
        Write-Host "  BM card $($card.Id) : '$($card.Title)'" -ForegroundColor Yellow
    }
}

# --- Summary ---
Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "  ADO Epics total : $($adoEpics.Count)"
Write-Host "  BM cards total  : $($bmCards.Count)"
Write-Host "  Created in BM   : $created"
Write-Host "  Paired/verified : $verified"
Write-Host "  Unlinked in BM  : $($delta.BmOnly.Count)"
Write-Host ""

if ($delta.BmOnly.Count -gt 0) {
    Write-Warning "$($delta.BmOnly.Count) BM card(s) have no CustomId and are outside the sync. Review manually."
}

Write-Host "Done." -ForegroundColor Green
