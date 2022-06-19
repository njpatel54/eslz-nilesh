
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
    [string] $parameterfilepath
)

# The Microsoft Graph module uses a different naming convention for Azure Government, so based 
# on the environment parameter we set the correct Graph environment parameter

if ($environment -eq 'AzureUSGovernment')
{
    $graphenvironment = 'USGov'
}

Write-Host "Parameter file path: $parameterfilepath"
Write-Host "Environment: $environment"
Write-Host "Microsoft Graph Environment: $graphenvironment"

# Imports .JSON parameter file and extracts CA policies

Write-Host "Importing CA policies from JSON parameters file..."
$importedFile = get-content -Raw -Path $parameterfilepath | ConvertFrom-Json
$importedPolicies = $importedfile.parameters.conditionalaccesspolicies.value

Write-Host "Installing and importing Microsoft Graph modules..."
Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
Install-Module Microsoft.Graph.Authentication -Force -Scope CurrentUser
Install-Module Microsoft.Graph.Identity.SignIns -Force -Scope CurrentUser
Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.Identity.SignIns

Write-Host "Connecting to Azure..."
$env:ARM_CLOUD_METADATA_URL = $cloudmetadataurl
$appsecret_securestring=($appsecret | ConvertTo-SecureString -AsPlainText -Force)
$pscredential = new-object System.Management.Automation.PSCredential($appid,$appsecret_securestring)
Disable-AzContextAutosave -Scope Process
Login-AzAccount -Environment $environment -ServicePrincipal -Credential $pscredential -Tenant $tenantId
$aadToken = Get-AzAccessToken -ResourceTypeName MSGraph

Write-Host "Connecting to Microsoft Graph..."
Connect-Graph -environment $graphenvironment -AccessToken $aadToken.Token

foreach ($importedPolicy in $importedPolicies) 
{
    # CA policy settings are only defined if property is not empty or null via an if/then statement
    # as passing an empty CA policy setting results in an error in Microsoft Graph API

    $policyName = $importedPolicy.Displayname
    $state = $importedPolicy.state
    $includeApplications = $importedPolicy.Conditions.Applications.IncludeApplications
    $excludeApplications = $importedPolicy.Conditions.Applications.ExcludeApplications
    $includeUserActions = $importedPolicy.Conditions.Applications.IncludeUserActions
    $IncludeAuthenticationContextClassReferences = $importedPolicy.Conditions.Applications.IncludeAuthenticationContextClassReferences
    $includeUsers = $importedPolicy.Conditions.Users.IncludeUsers
    $excludeUsers = $importedPolicy.Conditions.Users.ExcludeUsers
    $includeGroups = $importedPolicy.Conditions.Users.IncludeGroups
    $excludeGroups = $importedPolicy.Conditions.Users.ExcludeGroups
    $includeRoles = $importedPolicy.Conditions.Users.IncludeRoles
    $excludeRoles = $importedPolicy.Conditions.Users.ExcludeRoles
    $includePlatforms = $importedPolicy.Conditions.Platforms.includePlatforms
    $excludePlatforms = $importedPolicy.Conditions.Platforms.excludePlatforms
    $includeLocations = $importedPolicy.Conditions.Locations.includeLocations
    $excludeLocations = $importedPolicy.Conditions.Locations.excludeLocations
    $userRiskLevels = $importedPolicy.Conditions.UserRiskLevels
    $signInRiskLevels = $importedPolicy.Conditions.signInRiskLevels
    $ClientAppTypes = $importedPolicy.Conditions.ClientAppTypes
    $devices = $importedPolicy.Conditions.devices
    $operator = $importedPolicy.GrantControls.Operator
    $builtInControls = $importedPolicy.GrantControls.BuiltInControls
    $customAuthenticationFactors = $importedPolicy.GrantControls.CustomAuthenticationFactors
    $termsOfUse = $importedPolicy.GrantControls.TermsOfUse
    $ApplicationEnforcedRestrictions = $importedPolicy.SessionControls.ApplicationEnforcedRestrictions
    $CloudAppSecurity = $importedPolicy.SessionControls.CloudAppSecurity
    $SignInFrequency = $importedPolicy.SessionControls.SignInFrequency
    $PersistentBrowser = $importedPolicy.SessionControls.PersistentBrowser

    Write-Host "Working on on imported policy '$policyName'..."

    #Creates CA conditions policy object in PowerShell

    $policy = @{}
    $policy.State = $state
    $policy.DisplayName = $policyName
    $policy.Conditions = @{}

    #Defines application conditions
    if ($includeApplications -or $excludeApplications -or $includeUserActions -or $IncludeAuthenticationContextClassReferences)
    {
        $policy.conditions.Applications = @{}

        if ($includeApplications)
        {
            $policy.conditions.Applications.IncludeApplications = $includeApplications
        }
        
        if ($excludeApplications)
        {
            $policy.conditions.Applications.excludeApplications = $excludeApplications
        }

        if ($includeUserActions)
        {
            $policy.conditions.Applications.IncludeUserActions = $includeUserActions
        }
        
        if ($IncludeAuthenticationContextClassReferences)
        {
            $policy.conditions.Applications.IncludeAuthenticationContextClassReferences = $IncludeAuthenticationContextClassReferences
        }
    }

    #Defines user conditions, does not set if null or no value as this causes an error in the Graph API request
    if ($includeUsers -or $excludeUsers -or $includeGroups -or $excludeGroups -or $includeRoles -or $excludeRoles)
    {
        $policy.conditions.Users = @{}

        if ($includeUsers)
        {
            $policy.conditions.Users.IncludeUsers = $includeUsers
        }

        if ($excludeUsers)
        {
            $policy.conditions.Users.ExcludeUsers = $excludeUsers
        }

        if ($includeGroups)
        {
            $policy.conditions.Users.IncludeGroups = $includeGroups
        }

        if ($excludeGroups)
        {
            $policy.conditions.Users.ExcludeGroups = $excludeGroups
        }

        if ($includeRoles)
        {
            $policy.conditions.Users.IncludeRoles = $includeRoles
        }

        if ($excludeRoles)
        {
            $policy.conditions.Users.ExcludeRoles = $excludeRoles
        }
    }

    #Defines platform conditions
    if ($includePlatforms -or $excludePlatforms)
    {
        $policy.conditions.Platforms = @{}
    
        if ($includePlatforms)
        {
            $policy.conditions.Platforms.IncludePlatforms = $includePlatforms
        }

        if ($excludePlatforms)
        {
            $policy.conditions.Platforms.ExcludePlatforms = $excludePlatforms
        }
    }

    #Defines location conditions
    if ($includeLocations -or $excludeLocations)
    {
        $policy.conditions.Locations = @{}
    
        if ($includeLocations)
        {
            $policy.conditions.Locations.IncludeLocations = $includeLocations 
        }

        if ($excludeLocations)
        {
            $policy.conditions.Locations.ExcludeLocations = $excludeLocations
        }
    }

    #Defines user risk level conditions
    if ($UserRiskLevels)
    {
        $policy.conditions.UserRiskLevels = @{}
        $policy.conditions.UserRiskLevels = $UserRiskLevels
    }

    #Defines sign in risk level conditions
    if ($signInRiskLevels)
    {
        $policy.conditions.SignInRiskLevels = @{}
        $policy.conditions.SignInRiskLevels = $signInRiskLevels
    }

    #Defines client app type conditions
    if ($ClientAppTypes)
    {
        $policy.conditions.ClientAppTypes = @{}
        $policy.conditions.ClientAppTypes = $ClientAppTypes
    }

    #Defines client device conditions
    if ($devices)
    {
        $policy.conditions.Devices = @{}
        $policy.conditions.Devices = $devices
    }

    #Defines controls object
    if ($operator -or $builtInControls -or $customAuthenticationFactors -or $termsOfUse)
    {
        $policy.grantcontrols = @{}

        if ($operator)
        {
            $policy.grantcontrols.Operator = $operator
        }

        if ($builtInControls)
        {
            $policy.grantcontrols.builtInControls = $builtInControls
        }

        if ($customAuthenticationFactors)
        {
            $policy.grantcontrols.customAuthenticationFactors = $customAuthenticationFactors
        }
        
        if ($termsOfUse)
        {
            $policy.grantcontrols.termsOfUse = $termsOfUse
        }
    }

        #Defines Session controls object
        if ($ApplicationEnforcedRestrictions -or $CloudAppSecurity -or $SignInFrequency -or $PersistentBrowser)
        {
            $policy.sessionControls = @{}
    
            if ($ApplicationEnforcedRestrictions)
            {
                $policy.sessionControls.ApplicationEnforcedRestrictions = $ApplicationEnforcedRestrictions
            }
    
            if ($CloudAppSecurity)
            {
                $policy.sessionControls.CloudAppSecurity = @{}
                $policy.sessionControls.CloudAppSecurity.CloudAppSecurityType = $CloudAppSecurity.CloudAppSecurityType
                $policy.sessionControls.CloudAppSecurity.IsEnabled = $CloudAppSecurity.IsEnabled  
            }
    
            if ($SignInFrequency)
            {
                $policy.sessionControls.SignInFrequency = $SignInFrequency
            }
            
            if ($PersistentBrowser)
            {
                $policy.sessionControls.PersistentBrowser = @{}
                $policy.sessionControls.PersistentBrowser.Mode = $PersistentBrowser.Mode
                $policy.sessionControls.PersistentBrowser.isEnabled = $PersistentBrowser.IsEnabled
            }
        }

    # Searches for CA policy by display name. If more than one is found the script exits. 
    # If one is already found it modifies. If none found then it creates the policy.
    
    $existingPolicy = $(Get-MgIdentityConditionalAccessPolicy | Where-Object {$_.DisplayName -like "$policyName"})

    if ($existingPolicy.count -gt 1) 
    {
        Write-Host "Multiple matches found for '$policyName', exiting..."
        Exit
    } 
    elseif ($existingPolicy.count -eq 1) 
    {
        Write-Host "Found '$policyName', editing..."
        Update-MgIdentityConditionalAccessPolicy -bodyParameter $policy -ConditionalAccessPolicyId $($existingPolicy.id)
        Write-Host "Done..."
    }
    else
    {
        Write-Host "Did not find '$policyName', creating..."
        New-MgIdentityConditionalAccessPolicy -bodyParameter $policy
        Write-Host "Done..."
    }
}

Write-Host "Disconnecting from Azure and Microsoft Graph..."
Disconnect-AzAccount
Disconnect-Graph