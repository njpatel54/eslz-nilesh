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
    [Parameter(Mandatory=$true)]
    [string] $bicepparameterfilepath,
    [Parameter(Mandatory=$true)]
    [string] $mgdiagparameterfilepath
)

write-host -ForegroundColor Blue "Starting Script Execution"

# Read Values from Bicep Parameter File
$bicepparameters = Get-Content -Path $bicepParameterfilepath | ConvertFrom-Json 
$workspaceName  = $bicepparameters.parameters.loganalytics_workspace_name.value

# Read Values from AAD Diag Settings Parameter File
$mgdiagparameters = Get-Content -Path $mgdiagparameterfilepath | ConvertFrom-Json 
$logs  = $mgdiagparameters.parameters.logs.value

# Login to Azure
$env:ARM_CLOUD_METADATA_URL = $cloudmetadataurl
$appsecret_securestring=($appsecret | ConvertTo-SecureString -AsPlainText -Force)
$pscredential = new-object System.Management.Automation.PSCredential($appid,$appsecret_securestring)
Disable-AzContextAutosave -Scope Process
Login-AzAccount -Environment $environment -ServicePrincipal -Credential $pscredential -Tenant $tenantId

# Select Management Subscription
Select-AzSubscription $mgmtsubid

# Find the ResourceId for the Log Analytics workspace
$workspaceResource = Get-AzResource -ResourceType "Microsoft.OperationalInsights/workspaces" -Name $workspaceName
$workspaceId = $workspaceResource.ResourceId

# Define Diagnostic Setting Rule Name
$ruleName = 'MG-Logs-to-LogA'

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

$mgs = Get-AzManagementGroup
foreach($mg in $mgs)
{
  #setup diag settings
  $uri = "$resourceManagerUrl/providers/microsoft.management/managementGroups/$($mg.name)/providers/microsoft.insights/diagnosticSettings/$rulename?api-version=2021-05-01-preview"

  $body = @"
{
  "properties": {
    "storageAccountId": null,
    "serviceBusRuleId": null,
    "workspaceId": "$workspaceId",
    "eventHubAuthorizationRuleId": null,
    "eventHubName": null,
    "logs": $($logs | ConvertTo-Json)
  },
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
}