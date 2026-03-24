param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$ContainerAppName,

    [Parameter(Mandatory = $true)]
    [int]$TargetDiv,
)

$ErrorActionPreference = 'Stop'

Write-Output "Logging in to Azure using Managed Identity..."
Connect-AzAccount -Identity | Out-Null

$day = (Get-Date).Day
$div = [math]::Floor($day / 8)

Write-Output "Today day-of-month: $day"
Write-Output "floor(day / 8) = $div"
Write-Output "TargetDiv parameter = $TargetDiv"

$app = Get-AzResource `
    -ResourceGroupName $ResourceGroupName `
    -ResourceType 'Microsoft.App/containerApps' `
    -Name $ContainerAppName

if (-not $app) {
    throw "Container App not found"
}

if ($div -eq $TargetDiv) {
    Write-Output "Condition met → START container app"

    Invoke-AzRestMethod `
        -Method POST `
        -Path "$($app.ResourceId)/start?api-version=2024-03-01"

    Write-Output "Container App START triggered"
}
else {
    Write-Output "Condition NOT met → STOP container app"

    Invoke-AzRestMethod `
        -Method POST `
        -Path "$($app.ResourceId)/stop?api-version=2024-03-01"

    Write-Output "Container App STOP triggered"
}
