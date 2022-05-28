
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
    [string] $templatepath,
    [Parameter(Mandatory = $true)]
    [string] $templateparameterfile
)

write-host -ForegroundColor Blue "Starting Script Execution"

# Login to Azure
$env:ARM_CLOUD_METADATA_URL = $cloudmetadataurl
$appsecret_securestring=($appsecret | ConvertTo-SecureString -AsPlainText -Force)
$pscredential = new-object System.Management.Automation.PSCredential($appid,$appsecret_securestring)
Disable-AzContextAutosave -Scope Process
Login-AzAccount -Environment $environment -ServicePrincipal -Credential $pscredential -Tenant $tenantId

Select-AzSubscription $mgmtsubid

# Deploy ARM
$random = ( get-random -Minimum 0 -Maximum 999999 ).tostring('000000') 
New-AzTenantDeployment `
    -Name "deploy-mgs-$random" `
    -Location $location `
    -TemplateFile $templatepath `
    -TemplateParameterFile $templateparameterfile