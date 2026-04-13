#Requires -Modules Pester

BeforeAll {
    . "$PSScriptRoot/../src/BmAdoSync.ps1"
}

Describe 'Get-BmEpicState' {

    Context 'All children Proposed' {
        It 'returns Requested' {
            Get-BmEpicState -StateCategories @('Proposed', 'Proposed') | Should -Be 'Requested'
        }
        It 'returns Requested for a single Proposed child' {
            Get-BmEpicState -StateCategories @('Proposed') | Should -Be 'Requested'
        }
    }

    Context 'Any child InProgress' {
        It 'returns In Progress when one child is InProgress' {
            Get-BmEpicState -StateCategories @('InProgress') | Should -Be 'In Progress'
        }
        It 'returns In Progress when mixed with Proposed and Complete' {
            Get-BmEpicState -StateCategories @('InProgress', 'Proposed', 'Complete') | Should -Be 'In Progress'
        }
        It 'returns In Progress and ignores Removed alongside InProgress' {
            Get-BmEpicState -StateCategories @('InProgress', 'Removed') | Should -Be 'In Progress'
        }
    }

    Context 'All active children Complete (Removed excluded)' {
        It 'returns Done when all children are Complete' {
            Get-BmEpicState -StateCategories @('Complete', 'Complete') | Should -Be 'Done'
        }
        It 'returns Done when Complete and Removed — Removed excluded from calculation' {
            Get-BmEpicState -StateCategories @('Complete', 'Removed') | Should -Be 'Done'
        }
    }

    Context 'Mix of Complete and Proposed — no InProgress' {
        It 'returns In Progress' {
            Get-BmEpicState -StateCategories @('Complete', 'Proposed') | Should -Be 'In Progress'
        }
        It 'returns In Progress with multiple of each' {
            Get-BmEpicState -StateCategories @('Complete', 'Complete', 'Proposed') | Should -Be 'In Progress'
        }
    }

    Context 'All children Removed' {
        It 'returns null — caller must skip and log for manual review' {
            Get-BmEpicState -StateCategories @('Removed') | Should -BeNullOrEmpty
        }
        It 'returns null for multiple Removed children' {
            Get-BmEpicState -StateCategories @('Removed', 'Removed') | Should -BeNullOrEmpty
        }
    }
}

Describe 'Get-SyncDelta' {

    Context 'All ADO epics already paired in BM' {
        It 'returns empty AdoOnly and BmOnly' {
            $result = Get-SyncDelta `
                -AdoEpicIds @(1, 2) `
                -BmCards @(
                    [pscustomobject]@{ Id = 10; CustomId = '1' },
                    [pscustomobject]@{ Id = 11; CustomId = '2' }
                )
            $result.AdoOnly  | Should -BeNullOrEmpty
            $result.BmOnly   | Should -BeNullOrEmpty
            $result.Paired   | Should -HaveCount 2
        }
    }

    Context 'ADO epics missing from BM' {
        It 'returns unpaired ADO IDs in AdoOnly' {
            $result = Get-SyncDelta `
                -AdoEpicIds @(1, 2, 3) `
                -BmCards @(
                    [pscustomobject]@{ Id = 10; CustomId = '1' }
                )
            $result.AdoOnly | Should -Be @(2, 3)
            $result.Paired  | Should -Be @(1)
        }
    }

    Context 'BM cards with no CustomId' {
        It 'returns unlinked BM cards in BmOnly' {
            $result = Get-SyncDelta `
                -AdoEpicIds @(1) `
                -BmCards @(
                    [pscustomobject]@{ Id = 10; CustomId = '1' },
                    [pscustomobject]@{ Id = 99; CustomId = $null }
                )
            $result.BmOnly  | Should -HaveCount 1
            $result.BmOnly[0].Id | Should -Be 99
            $result.Paired  | Should -Be @(1)
        }
    }

    Context 'All BM cards unlinked, no ADO epics' {
        It 'returns all BM cards in BmOnly, empty AdoOnly' {
            $result = Get-SyncDelta `
                -AdoEpicIds @() `
                -BmCards @(
                    [pscustomobject]@{ Id = 5; CustomId = $null }
                )
            $result.BmOnly  | Should -HaveCount 1
            $result.AdoOnly | Should -BeNullOrEmpty
            $result.Paired  | Should -BeNullOrEmpty
        }
    }

    Context 'Empty board and empty ADO' {
        It 'returns all empty sets' {
            $result = Get-SyncDelta -AdoEpicIds @() -BmCards @()
            $result.AdoOnly | Should -BeNullOrEmpty
            $result.BmOnly  | Should -BeNullOrEmpty
            $result.Paired  | Should -BeNullOrEmpty
        }
    }
}

Describe 'Get-AdoChildStateCategories' -Tag 'Integration' {
    It 'returns valid state categories for a real ADO Epic' -Skip:(-not $env:ADO_PAT) {
        # Set environment variables before running:
        #   $env:ADO_PAT      = '<personal-access-token>'
        #   $env:ADO_ORG      = '<organization>'
        #   $env:ADO_PROJECT  = '<project>'
        #   $env:ADO_EPIC_ID  = '<epic-work-item-id>'
        $categories = Get-AdoChildStateCategories `
            -Organization    $env:ADO_ORG `
            -Project         $env:ADO_PROJECT `
            -EpicId          ([int]$env:ADO_EPIC_ID) `
            -PersonalAccessToken $env:ADO_PAT

        $categories | Should -Not -BeNullOrEmpty
        $validCategories = @('Proposed', 'InProgress', 'Complete', 'Removed')
        foreach ($cat in $categories) {
            $cat | Should -BeIn $validCategories
        }
    }
}
