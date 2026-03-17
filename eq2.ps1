param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$ContainerAppName
)

$ErrorActionPreference = 'Stop'

Write-Output "Logging in to Azure using Managed Identity..."
Connect-AzAccount -Identity | Out-Null

$day = (Get-Date).Day
$mod = $day % 8

Write-Output "Today day-of-month: $day"
Write-Output "day % 8 = $mod"
Write-Output "ResourceGroupName = $ResourceGroupName"
Write-Output "ContainerAppName = $ContainerAppName"

if ($mod -eq 2) {
    $minReplicas = 1
    $maxReplicas = 1
    Write-Output "Condition met. START Container App."
}
else {
    $minReplicas = 0
    $maxReplicas = 0
    Write-Output "Condition not met. STOP Container App."
}

$app = Get-AzResource `
    -ResourceGroupName $ResourceGroupName `
    -ResourceType 'Microsoft.App/containerApps' `
    -Name $ContainerAppName

if (-not $app) {
    throw "Container App '$ContainerAppName' not found in resource group '$ResourceGroupName'."
}

$payload = @{
    properties = @{
        template = @{
            scale = @{
                minReplicas = $minReplicas
                maxReplicas = $maxReplicas
            }
        }
    }
} | ConvertTo-Json -Depth 20

Write-Output "Updating Container App scale settings..."
Write-Output $payload

$response = Invoke-AzRestMethod `
    -Method PATCH `
    -Path "$($app.ResourceId)?api-version=2024-03-01" `
    -Payload $payload

Write-Output "Update completed."
Write-Output $response.Content
