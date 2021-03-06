## Deployment Steps
### 1. Install Azure Active Directory (AAD) Prerequisites
Prerequisite Azure Active Directory items including Groups, Service Principal and Role Assignments are required to perform subsequent deployment steps.  This step is intended to be executed one time on first deployment.  It is packaged as a single PowerShell script and intended to be executed interactively from a PowerShell instance with access to the management plane of target Azure environment.  The script, **deploy-aadprereqs.ps1**, does the following:

|  Type                                    |  Role  | Role Assignment Scope                                                     | Group Members|
|:-----------------------------------------|:-------|:--------------------------------------------------------------------------|:-------------|
| AzureAD App<br>Name: **`azure-eslz-deployer`**| N/A    | N/A                                                                       | N/A          |
| AzureAD Service Principal for App<br>Name: **`azure-eslz-deployer`**| N/A   | N/A                                                  | N/A          |
| AzureAD Group<br>Name:  **`azure-platform-owners`** | Owner | /providers/Microsoft.Management<br>/managementGroups/root_management_group_id | AzureAD SPN (azure-entlz-deployer)|
| AzureAD Group<br>Name: **`azure-platform-readers`** | Reader| /providers/Microsoft.Management<br>/managementGroups/root_management_group_id | Currently LoggedIn User |



The user running the script must be elevated to **User Rights Administrator** temporarily in Azure Active Directory (Properties tab, see below).  After the script runs successfully the account should be removed from this role.

![](User-Rights-Administrator.jpg)

Generate a client Secret for the **azure-entlz-deployer** account in the App Registrations blade.  

![](Client-Secret.jpg)

### Make a note of the following ... 
- **`Client Secret value`**
- **`Application ID`**
- **`Tenant ID`**

### 2. Create GitHub Repository Secrets
Create new GitHub Repository Secrets for the target Azure Tenant workflow with the following variables:

|  Secret Name              |  Value Format                                                 | Notes                                         |
|:--------------------------|:--------------------------------------------------------------| :---------------------------------------------|
| `AZURE_CREDENTIALS`         | { <br>   "clientId": "xxxxx-xxxx-xxxx-xxx-xxxxxx", <br>  "clientSecret": "xxxxx-xxxx-xxxx-xxx-xxxxxx", <br>       "subscriptionId": "xxxxx-xxxx-xxxx-xxx-xxxxxx", <br>     "tenantId": "xxxxx-xxxx-xxxx-xxx-xxxxxx" <br>         } | Provide appropriate values for <br> - **clientId**<br> - **clientSecret**<br> - **tenantId**<br><br> For **subscriptionId**, provide Subscription ID <br>of Management Subscription.|
| `AZURE_ENVIRONMENT`         | AzureUSGovernment                                             | Azure Cloud Environment         |
| `AZURE_LOCATION`            | USGovVirginia                                                 | Azure Region                    |
| `AZURE_MG_TOP`              | mg-A2g                                                        | Top Level Management Group      |
| `AZURE_RG`                  | Resource Group Name                                       | To test notScope policy setting |                 
| `AZURE_MGMTSUBSCRIPTIONID`  | xxxxx-xxxx-xxxx-xxx-xxxxxx                                    | Management Subscription ID      |
| `AZURE_CONNSUBSCRIPTIONID`  | xxxxx-xxxx-xxxx-xxx-xxxxxx                                    | Connectivity Subscription ID    |
| `AZURE_IDENSUBSCRIPTIONID`  | xxxxx-xxxx-xxxx-xxx-xxxxxx                                    | Identity Subscription ID        |
| `AZURE_SANDSUBSCRIPTIONID`  | xxxxx-xxxx-xxxx-xxx-xxxxxx                                    | Sandbox Subscription ID         |
| `AZURE_SSVCSUBSCRIPTIONID`  | xxxxx-xxxx-xxxx-xxx-xxxxxx                                    | Shared Services Subscription ID |
| `AZURE_LZ01SUBSCRIPTIONID`  | xxxxx-xxxx-xxxx-xxx-xxxxxx                                    | Landing Zone Subscription ID    |

### 3. Run GitHub Workflows
The GitHub workflows should be executed in the following order:
1. Management Groups
2. Management Services
3. Policies
4. Roles
5. Workloads
    - Virtual Networks
    - Virtual Machines
    - Key Vault

