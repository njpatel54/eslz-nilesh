
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
    [string] $templateparameterfile,
    [Parameter(Mandatory=$true)]
    [string] $outfile
)

write-host -ForegroundColor Blue "Starting Script Execution"

# Login to Azure
$env:ARM_CLOUD_METADATA_URL = $cloudmetadataurl
$appsecret_securestring=($appsecret | ConvertTo-SecureString -AsPlainText -Force)
$pscredential = new-object System.Management.Automation.PSCredential($appid,$appsecret_securestring)
Disable-AzContextAutosave -Scope Process
Connect-AzAccount -Environment $environment -ServicePrincipal -Credential $pscredential -Tenant $tenantId
Select-AzSubscription $mgmtsubid

# Get What-If Results
$testobj = Get-AzTenantDeploymentWhatIfResult `
    -Location $location `
    -TemplateFile $templatepath `
    -TemplateParameterFile $templateparameterfile `
    -ResultFormat FullResourcePayloads
    
$output = ( $testobj | out-string ) -replace '\x1b\[[0-9;]*m', '' 

write-host $output

$output | out-file $outfile
