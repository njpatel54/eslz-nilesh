
Param(    
    [Parameter(Mandatory=$true)]
    [string] $mgmtsubid,
    [Parameter(Mandatory=$false)]
    [string] $location="usgovvirginia",
    [Parameter(Mandatory=$false)]
    [string] $environment = "AzureUSGovernment",
    [Parameter(Mandatory=$false)]
    [string] $ResourceManagerURL = "https://management.usgovcloudapi.net/"
)

# Script Requires Az PowerShell Modules

write-host -ForegroundColor Blue "Starting Script Execution"

# Login to Azure
$env:ARM_CLOUD_METADATA_URL = "$ResourceManagerURL/metadata/endpoints?api-version=2020-06-01"
Connect-AzAccount -Environment $environment 
Select-AzSubscription $mgmtsubid

$platform_owners_group_displayname = "azure-platform-owners"
$platform_readers_group_displayname = "azure-platform-readers"
$azure_ad_app_name = "azure-entlz-deployer"

# Create Platform Owners Group
if ( ! ( $platform_owners_group = Get-AzADGroup -DisplayName $platform_owners_group_displayname ) ) {
    write-host -ForegroundColor Green "Creating Azure AD Group $platform_owners_group"
    $platform_owners_group = New-AzADGroup -DisplayName $platform_owners_group_displayname -MailNickname $($platform_owners_group_displayname) -Description "Members have Owner rights at Tenant Root Group scope."
    write-host -ForegroundColor Green "Created Azure AD Group $($platform_owners_group.DisplayName) with objectid $($platform_owners_group.Id)"
}
else {
    write-host -ForegroundColor Yellow "$($platform_owners_group.DisplayName) already exists with objectid $($platform_owners_group.Id)"
}

# Create Platform Readers Group
if ( ! ( $platform_readers_group = Get-AzADGroup -DisplayName $platform_readers_group_displayname ) ) {
    write-host -ForegroundColor Green "Creating Azure AD Group $platform_readers_group"
    $platform_readers_group = New-AzADGroup -DisplayName $platform_readers_group_displayname -MailNickname $($platform_readers_group_displayname) -Description "Members have Reader rights at Tenant Root Group scope."
    write-host -ForegroundColor Green "Created Azure AD Group $($platform_readers_group.DisplayName) with objectid $($platform_readers_group.Id)"
}
else {
    write-host -ForegroundColor Yellow "$($platform_readers_group.DisplayName) already exists with objectid $($platform_readers_group.Id)"
}

# Get Group Objects Again to Ensure Creation Has Completed
start-sleep 10
$platform_owners_group = Get-AzADGroup -DisplayName $platform_owners_group_displayname
$platform_readers_group = Get-AzADGroup -DisplayName $platform_readers_group_displayname

# Create Platform Owners Assignment at Management Group Scope
if ( ! (  $platform_owners_assignment = Get-AzRoleAssignment -Scope / -ObjectId $platform_owners_group.Id -RoleDefinitionName Owner ) ) {

    write-host -ForegroundColor Green "Assigning $($platform_owners_group.DisplayName) with objectid $($platform_owners_group.Id) the Owner role at scope / (Tenant Root)"
    $platform_owners_assignment = New-AzRoleAssignment -Scope / -ObjectId $platform_owners_group.Id -RoleDefinitionName Owner 
    write-host -ForegroundColor Green "Role Assignment Created"
}
else {
    write-host -ForegroundColor Yellow "$($platform_owners_group.DisplayName) with objectid $($platform_owners_group.Id) already has $($platform_owners_assignment.RoleDefinitionName) role at scope / (Tenant Root)"
}

# Create Platform Readers Assignment at Management Group Scope
if ( ! (  $platform_readers_assignment = Get-AzRoleAssignment -Scope / -ObjectId $platform_readers_group.Id -RoleDefinitionName Reader ) ) {
    start-sleep 3
    write-host -ForegroundColor Green "Assigning $($platform_readers_group.DisplayName) with objectid $($platform_readers_group.Id) the Reader role at scope / (Tenant Root)"
    $platform_readers_assignment = New-AzRoleAssignment -Scope / -ObjectId $platform_readers_group.Id -RoleDefinitionName Reader 
    write-host -ForegroundColor Green "Role Assignment Created"
}
else {
    write-host -ForegroundColor Yellow "$($platform_readers_group.DisplayName) with objectid $($platform_readers_group.Id) already has Reader role at scope / (Tenant Root)"
}

# Create Azure Application
if ( ! ( $az_ad_application = get-AzADApplication -DisplayName $azure_ad_app_name ) ) {
    write-host -ForegroundColor Green "Creating AzureAD App $azure_ad_app_name"
    $az_ad_application = New-AzADApplication -DisplayName $azure_ad_app_name
    write-host -ForegroundColor Green "Created AzureAD App created with objectid $($az_ad_application.ObjectId) and application id $($az_ad_application.ApplicationId)"
}
else {
    write-host -ForegroundColor Yellow "AzureAD App $($az_ad_application.DisplayName) with objectid $($az_ad_application.ObjectId) and applicationid $($az_ad_application.ApplicationId) already exists."
}

# Create Service Principal for Azure Application
$app_guid = $az_ad_application.AppId
    
if ( ! ( $az_ad_service_principal = Get-AzADServicePrincipal -ApplicationId $app_guid ) ) {
    write-host -ForegroundColor Green "Creating AzureAD Service Principal for App $azure_ad_app_name"
    $az_ad_service_principal = New-AzADServicePrincipal -ApplicationId $app_guid
    } 
    write-host -ForegroundColor Green "Created AzureAD App Service Principal with objectid $($az_ad_service_principal.Id) and applicationid $($az_ad_service_principal.ApplicationId)"
else {
    write-host -ForegroundColor Yellow "AzureAD App Service Principal $($az_ad_service_principal.DisplayName) with objectid $($az_ad_service_principal.Id) and applicationid $($az_ad_service_principal.ApplicationId) already exists."
}

# Add Service Prinicpal to Platform Owners Group
if ( ! ( $az_ad_group_member = get-AzADGroupMember -GroupObjectId $platform_owners_group.Id | where { $_.Id -eq $az_ad_service_principal.Id } )) {
    write-host -ForegroundColor Green "Adding AzureAD App Service Principal $($az_ad_service_principal.DisplayName) with objectid $($az_ad_service_principal.Id) to group $($platform_owners_group.DisplayName) with objectid $($platform_owners_group.Id)"
    $az_ad_group_member = Add-AzADGroupMember -MemberObjectId $az_ad_service_principal.Id -TargetGroupObjectId $platform_owners_group.Id
    write-host -ForegroundColor Green "Group Member Added"
}
else {
    write-host -ForegroundColor Yellow "AzureAD App Service Principal $($az_ad_service_principal.DisplayName) with objectid $($az_ad_service_principal.Id) is already a member of group $($platform_owners_group.DisplayName) with objectid $($platform_owners_group.Id)"
}

# Add Logged In User to Platform Readers Group
$loggedinuser=get-azaduser -UserPrincipalName (get-azcontext).account
if ( ! ( $az_ad_group_member = get-AzADGroupMember -GroupObjectId $platform_readers_group.Id | where { $_.Id -eq $loggedinuser.Id } )) {
    write-host -ForegroundColor Green "Adding Currently Logged in User $($loggedinuser.UserPrincipalName) with objectid $($loggedinuser.Id) to group $($platform_readers_group.DisplayName) with objectid $($platform_readers_group.Id)"
    $az_ad_group_member = Add-AzADGroupMember -MemberObjectId $loggedinuser.Id -TargetGroupObjectId $platform_readers_group.Id
    write-host -ForegroundColor Green "Group Member Added"
} else {
    write-host -ForegroundColor Yellow "AzureAD User $($loggedinuser.UserPrincipalName) with objectid $($loggedinuser.Id) is already a member of group $($platform_readers_group.DisplayName) with objectid $($platform_readers_group.Id)"    
}

# Add Service Prinicpal to Azure AD Global Readers Role
write-host -ForegroundColor Red "The AzureAD App Service Principal $($az_ad_service_principal.DisplayName) with objectid $($az_ad_service_principal.Id) should be manually added to the Azure AD Global Reader Role before continuing with deployment."
Pause

write-host -ForegroundColor Blue "Completing Script Execution"


#Quick Object Removal for Testing Only
#Get-AzADApplication -DisplayName $azure_ad_app_name | remove-AzADApplication -force
#Get-AzRoleAssignment -Scope / -ObjectId $platform_owners_group.Id -RoleDefinitionName Owner | Remove-AzRoleAssignment
#Get-AzRoleAssignment -Scope / -ObjectId $platform_readers_group.Id -RoleDefinitionName Reader | Remove-AzRoleAssignment
#Get-AzADGroup -DisplayName $platform_readers_group_displayname | Remove-AzADGroup -force
#Get-AzADGroup -DisplayName $platform_owners_group_displayname | Remove-AzADGroup -force
