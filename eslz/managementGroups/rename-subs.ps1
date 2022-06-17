Param(
    [Parameter(Mandatory=$true)]
    [string] $tenantid,    
    [Parameter(Mandatory=$true)]
    [string] $mgmtsubid,
    [Parameter(Mandatory=$true)]
    [string] $connsubid,
    [Parameter(Mandatory=$true)]
    [string] $entlzmg,    
    [Parameter(Mandatory=$true)]
    [string] $appid,
    [Parameter(Mandatory=$true)]
    [string] $cloudmetadataurl,
    [Parameter(Mandatory=$true)]
    [string] $environment,
    [Parameter(Mandatory=$true)]
    [string] $appsecret
)

write-host -ForegroundColor Blue "Starting Script Execution"

# Login to Azure
$env:ARM_CLOUD_METADATA_URL = $cloudmetadataurl
$appsecret_securestring=($appsecret | ConvertTo-SecureString -AsPlainText -Force)
$pscredential = new-object System.Management.Automation.PSCredential($appid,$appsecret_securestring)
Disable-AzContextAutosave -Scope Process
Connect-AzAccount -Environment $environment -ServicePrincipal -Credential $pscredential -Tenant $tenantId
Select-AzSubscription $mgmtsubid

# Update Management Subscription Name
update-AzSubscription -SubscriptionId $mgmtsubid -Action "Rename" -Name "$entlzmg-platform-management-01"

# Update Connectivity Subscription Name
update-AzSubscription -SubscriptionId $connsubid -Action "Rename" -Name "$entlzmg-platform-connectivity-01"
