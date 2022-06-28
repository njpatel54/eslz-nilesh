Param(
    [Parameter(Mandatory=$true)]
    [string] $tenantid,    
    [Parameter(Mandatory=$true)]
    [string] $mgmtsubid,
    [Parameter(Mandatory=$true)]
    [string] $location,    
    [Parameter(Mandatory=$true)]
    [string] $appid,
    [Parameter(Mandatory=$true)]
    [string] $cloudmetadataurl,
    [Parameter(Mandatory=$true)]
    [string] $environment,
    [Parameter(Mandatory=$true)]
    [string] $appsecret,
    #[Parameter(Mandatory=$true)]
    #[string] $bicepparameterfilepath,
    [Parameter(Mandatory=$true)]
    [string] $aaddiagparameterfilepath
)

write-host -ForegroundColor Blue "Starting Script Execution"

# Read Values from Bicep Parameter File
#$bicepparameters = Get-Content -Path $bicepParameterfilepath | ConvertFrom-Json 
#$workspaceName  = $bicepparameters.parameters.loganalytics_workspace_name.value

# Read Values from AAD Diag Settings Parameter File
$aaddiagparameters = Get-Content -Path $aaddiagparameterfilepath | ConvertFrom-Json 
$logs  = $aaddiagparameters.parameters.logs.value
$metrics  = $aaddiagparameters.parameters.metrics.value
$workspaceId  = $aaddiagparameters.parameters.workspaceId.value
$storageAccountId  = $aaddiagparameters.parameters.storageAccountId.value
$eventHubAuthorizationRuleId  = $aaddiagparameters.parameters.eventHubAuthorizationRuleId.value
$eventHubName  = $aaddiagparameters.parameters.eventHubName.value


# Login to Azure
$env:ARM_CLOUD_METADATA_URL = $cloudmetadataurl
$appsecret_securestring=($appsecret | ConvertTo-SecureString -AsPlainText -Force)
$pscredential = new-object System.Management.Automation.PSCredential($appid,$appsecret_securestring)
Disable-AzContextAutosave -Scope Process
Login-AzAccount -Environment $environment -ServicePrincipal -Credential $pscredential -Tenant $tenantId

# Select Management Subscription
Select-AzSubscription $mgmtsubid

# Register Microsoft Insights Provider with Subscription
Register-AzResourceProvider -ProviderNamespace Microsoft.Insights

# Find the ResourceId for the Log Analytics workspace
#$workspaceResource = Get-AzResource -ResourceType "Microsoft.OperationalInsights/workspaces" -Name $workspaceName
#$workspaceId = $workspaceResource.ResourceId

# Define Diagnostic Setting Rule Name
$ruleName = 'centralized-logging-diagSetting'

# Get Resource Manager URL
$resourceManagerUrl = (Get-AzContext).Environment.ResourceManagerUrl

function Get-AzCachedAccessToken()
{
    $ErrorActionPreference = 'Stop'

    $azureRmProfileModuleVersion = (Get-Module Az.Profile).Version
    $azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
    if(-not $azureRmProfile.Accounts.Count) {
        Write-Error "Ensure you have logged in before calling this function."    
    }
  
    $currentAzureContext = Get-AzContext
    $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
    Write-Debug ("Getting access token for tenant" + $currentAzureContext.Tenant.TenantId)
    $token = $profileClient.AcquireAccessToken($currentAzureContext.Tenant.TenantId)
    $token.AccessToken
}
$token = Get-AzCachedAccessToken

#setup diag settings
$uri = "$resourceManagerUrl/providers/microsoft.aadiam/diagnosticSettings/{0}?api-version=2017-04-01-preview" -f $ruleName
$body = @"
{
    "id": "providers/microsoft.aadiam/diagnosticSettings/$ruleName",
    "type": null,
    "name": "Log Analytics",
    "location": null,
    "kind": null,
    "tags": null,
    "properties": {
      "storageAccountId": "$storageAccountId",
      "serviceBusRuleId": null,
      "workspaceId": "$workspaceId",
      "eventHubAuthorizationRuleId": "$eventHubAuthorizationRuleId",
      "eventHubName": "$eventHubName",
      "metrics": $($metrics | ConvertTo-Json),
      "logs": $($logs | ConvertTo-Json)
    },
    "identity": null
  }
"@

$headers = @{
  "Authorization" = "Bearer $token"
  "Content-Type"  = "application/json"
}
$response = Invoke-WebRequest -Method Put -Uri $uri -Body $body -Headers $headers

if ($response.StatusCode -ne 200) {
  throw "an error occured: $($response | out-string)"
}
