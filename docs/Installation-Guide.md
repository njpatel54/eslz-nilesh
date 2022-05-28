## Deployment Steps
### 1. Install Azure Active Directory (AAD) Prerequisites
Prerequisite Azure Active Directory items including Groups, Service Principal and Role Assignments are required to perform subsequent deployment steps.  This step is intended to be executed one time on first deployment.  It is packaged as a single PowerShell script and intended to be executed interactively from a PowerShell instance with access to the management plane of target Azure environment.  The script, [deploy.aadprereqs.ps1](deploy-aadprereqs.ps1), does the following:
* Creates Azure AD Group **azure-platform-owners**
* Creates Azure AD Group **azure-platform-readers**
* Assigns **azure-platform-owners** the Owner role at scope **/providers/Microsoft.Management/managementGroups/root_management_group_id**
* Assigns **azure-platform-readers** the Reader role at scope **/providers/Microsoft.Management/managementGroups/root_management_group_id**
* Creates AzureAD App **azure-entlz-deployer**
* Creates AzureAD Service Principal for App **azure-entlz-deployer**
* Adds AzureAD App Service Principal **azure-entlz-deployer** to group **azure-platform-owners**
* Adds Currently Logged in Deployment User to group **azure-platform-readers**

The user running the script must be elevated to **User Rights Administrator** temporarily in Azure Active Directory (Properties tab, see below).  After the script runs successfully the account should be removed from this role.

![](images\aad_useraccesscontributor.png)

Generate a client Secret for the **azure-entlz-deployer** account in the App Registrations blade.  

![](images\aad_clientsecret.png)

Make a note of the secret value, Application ID and Tenant ID.

![](images\aad_info.png)

### 2. Setup Azure Devops Pipelines Variable Group
Create new Variable Groups in ADO for the target Azure Dev and Prod Tenants Pipelines with the following variables:
* appid - Application ID from Step 1
* appsecret - Secret value from Step 1 (Set as Secured Variable!!)
* cloudmetadataurl - URL for environment (ex. Secret- https://management.azure.microsoft.scloud/metadata/endpoints?api-version=2020-06-01)
* connsubid - Connectivity Subscription ID
* entlzmg - Enterprise Landing Zone Root MG Name
* environment - Cloud Environment (ex. ussec, usnat)
* location - Azure Region (ex. usseceast, ussecwest)
* mgmtsubid - Management Subscription ID
* tenantid - Tenant ID from Step 1

Accept all other default values.

![](images\ado_variablegroup.png)

The variable group can be referenced in build and release pipelines.  The YAML is shown below:
```
variables:
- group: <Variable Group>
```

### 3. Run Build and Release Pipelines
The pipelines should be executed in the following order:
1. Management Groups
2. Management Services
3. VDSS
4. VDMS-Core
5. VDMS-Collab
6. Policies
7. Roles
8. Workbooks
9. Mission Workloads
    a. Generic Workload 
    b. Workspaces (VDI)
    c. Workshops (DevSecOps-DSOP Software Factory)
