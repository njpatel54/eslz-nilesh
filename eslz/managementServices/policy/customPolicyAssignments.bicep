targetScope = 'managementGroup'

@description('Prefix for the management group hierarchy.')
@minLength(2)
@maxLength(10)
param targetMgId string

param location string

@description('The region where the Log Analytics Workspace & Automation Account are deployed.')
param logaAALocation string = 'USGovVirginia'

@description('Log Analytics Workspace Resource ID. - DEFAULT VALUE: Empty String.')
param diagnosticWorkspaceId string = ''

@description('Number of days of log retention for Log Analytics Workspace.')
param diagnosticLogsRetentionInDays string = '365'

@description('Automation account name.')
param aaName string = 'aa-ccs-prod-usva-siem'

@description('An e-mail address that you want Microsoft Defender for Cloud alerts to be sent to.')
param SecurityContactEmail string = 'ccsao-1669@azgperatonpartners.onmicrosoft.us'

@description('ID of the DdosProtectionPlan which will be applied to the Virtual Networks. If left empty, the policy Enable-DDoS-VNET will not be assigned at connectivity or landing zone Management Groups to avoid VNET deployment issues. Default: Empty String')
param ddosProtectionPlanId string = ''

var logaName = split(diagnosticWorkspaceId, '/')[8]

var logaRgName = split(diagnosticWorkspaceId, '/')[4]

// **Variables**
// Orchestration Module Variables
var varDeploymentNameWrappers = {
  basePrefix: 'ALZBicep'
  #disable-next-line no-loc-expr-outside-params //Policies resources are not deployed to a region, like other resources, but the metadata is stored in a region hence requiring this to keep input parameters reduced. See https://github.com/Azure/ALZ-Bicep/wiki/FAQ#why-are-some-linter-rules-disabled-via-the-disable-next-line-bicep-function for more information
  baseSuffixTenantAndManagementGroup: '${deployment().location}-${uniqueString(deployment().location, targetMgId)}'
}

var varModuleDeploymentNames = {
  modPolicyAssignmentIntRootdeployMdfcConfig: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployMdfcConfig-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIntRootDeployAzActivityLog: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployAzActivityLog-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIntRootDeployAscMonitoring: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployASCMonitoring-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIntRootDeployResourceDiag: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployResoruceDiag-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIntRootDeployVmMonitoring: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployVMMonitoring-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIntRootDeployVmssMonitoring: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployVMSSMonitoring-intRoot-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentConnEnableDdosVnet: take('${varDeploymentNameWrappers.basePrefix}-polAssi-enableDDoSVNET-conn-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIdentDenyPublicIp: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyPublicIP-ident-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIdentDenyRdpFromInternet: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyRDPFromInet-ident-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIdentDenySubnetWithoutNsg: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denySubnetNoNSG-ident-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentIdentDeployVmBackup: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployVMBackup-ident-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentMgmtDeployLogAnalytics: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployLAW-mgmt-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsDenyIpForwarding: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyIPForward-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsDenyPublicIp: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyPublicIP-corp-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsDenyRdpFromInternet: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyRDPFromInet-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsDenySubnetWithoutNsg: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denySubnetNoNSG-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsDeployVmBackup: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployVMBackup-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsEnableDdosVnet: take('${varDeploymentNameWrappers.basePrefix}-polAssi-enableDDoSVNET-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsDenyStorageHttp: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyStorageHttp-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsDeployAksPolicy: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployAKSPolicy-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsDenyPrivEscalationAks: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyPrivEscAKS-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsDenyPrivContainersAks: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyPrivConAKS-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsEnforceAksHttps: take('${varDeploymentNameWrappers.basePrefix}-polAssi-enforceAKSHTTPS-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsEnforceTlsSsl: take('${varDeploymentNameWrappers.basePrefix}-polAssi-enforceTLSSSL-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsDeploySqlDbAuditing: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deploySQLDBAudit-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsDeploySqlThreat: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deploySQLThreat-lz-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsDenyPublicEndpoints: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyPublicEndpoints-corp-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsDeployPrivateDnsZones: take('${varDeploymentNameWrappers.basePrefix}-polAssi-deployPrivateDNS-corp-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsdenyDataBPip: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyDataBPip-corp-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsDenyDataBSku: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyDataBSku-corp-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
  modPolicyAssignmentLzsDenyDataBVnet: take('${varDeploymentNameWrappers.basePrefix}-polAssi-denyDataBVnet-corp-${varDeploymentNameWrappers.baseSuffixTenantAndManagementGroup}', 64)
}

// Policy Assignments Modules Variables

var denyDataBPip = {
	definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-Databricks-NoPublicIp'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deny_databricks_public_ip.tmpl.json'))
}

var DenyDataBSku = {
	definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-Databricks-Sku'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deny_databricks_sku.tmpl.json'))
}

var DenyDataBVnet = {
	definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-Databricks-VirtualNetwork'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deny_databricks_vnet.tmpl.json'))
}

var EnforceAksHttps = {
	definitionId: '/providers/Microsoft.Authorization/policyDefinitions/1a5b4dca-0b6f-4cf5-907c-56316bc1bf3d'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deny_http_ingress_aks.tmpl.json'))
}

var DenyIpForwarding = {
	definitionId: '/providers/Microsoft.Authorization/policyDefinitions/88c0b9da-ce96-4b03-9635-f29a937e2900'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deny_ip_forwarding.tmpl.json'))
}

var DenyPrivContainersAks = {
	definitionId: '/providers/Microsoft.Authorization/policyDefinitions/95edb821-ddaf-4404-9732-666045e056b4'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deny_priv_containers_aks.tmpl.json'))
}

var DenyPrivEscalationAks = {
	definitionId: '/providers/Microsoft.Authorization/policyDefinitions/1c6e92c9-99f0-4e55-9cf2-0c234dc48f99'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deny_priv_escalation_aks.tmpl.json'))
}

var DenyPublicEndpoints = {
	definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policySetDefinitions/Deny-PublicPaaSEndpoints'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deny_public_endpoints.tmpl.json'))
}

var DenyPublicIp = {
	definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-PublicIP'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deny_public_ip.tmpl.json'))
}

var DenyRdpFromInternet = {
	definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-RDP-From-Internet'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deny_rdp_from_internet.tmpl.json'))
}

var DenyStorageHttp = {
	definitionId: '/providers/Microsoft.Authorization/policyDefinitions/404c3081-a854-4457-ae30-26a93ef643f9'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deny_storage_http.tmpl.json'))
}

var DenySubnetWithoutNsg = {
	definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policyDefinitions/Deny-Subnet-Without-Nsg'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deny_subnet_without_nsg.tmpl.json'))
}

var DeployAksPolicy = {
	definitionId: '/providers/Microsoft.Authorization/policyDefinitions/a8eff44f-8c92-45c3-a3fb-9880802d67a7'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deploy_aks_policy.tmpl.json'))
}

var DeployAscMonitoring = {
	definitionId: '/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deploy_asc_monitoring.tmpl.json'))
}

var DeployAzActivityLog = {
	definitionId: '/providers/Microsoft.Authorization/policyDefinitions/2465583e-4e78-4c15-b6be-a36cbc7c8b0f'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deploy_azactivity_log.tmpl.json'))
}

var DeployLogAnalytics = {
	definitionId: '/providers/Microsoft.Authorization/policyDefinitions/8e3e61b3-0b32-22d5-4edf-55f87fdb5955'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deploy_log_analytics.tmpl.json'))
}

var deployMdfcConfig = {
	definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policySetDefinitions/Deploy-MDFC-Config'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deploy_mdfc_config.tmpl.json'))
}

var DeployResourceDiag = {
	definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policySetDefinitions/Deploy-Diagnostics-LogAnalytics'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deploy_resource_diag.tmpl.json'))
}

var DeploySqlDbAuditing = {
	definitionId: '/providers/Microsoft.Authorization/policyDefinitions/a6fb4358-5bf4-4ad7-ba82-2cd2f41ce5e9'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deploy_sql_db_auditing.tmpl.json'))
}

var DeploySqlThreat = {
	definitionId: '/providers/Microsoft.Authorization/policyDefinitions/36d49e87-48c4-4f2e-beed-ba4ed02b71f5'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deploy_sql_threat.tmpl.json'))
}

var DeployVmBackup = {
	definitionId: '/providers/Microsoft.Authorization/policyDefinitions/98d0b9f8-fd90-49c9-88e2-d3baf3b0dd86'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deploy_vm_backup.tmpl.json'))
}

var DeployVmMonitoring = {
	definitionId: '/providers/Microsoft.Authorization/policySetDefinitions/55f3eceb-5573-4f18-9695-226972c6d74a'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deploy_vm_monitoring.tmpl.json'))
}

var DeployVmssMonitoring = {
	definitionId: '/providers/Microsoft.Authorization/policySetDefinitions/75714362-cae7-409e-9b99-a8e5075b7fad'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_deploy_vmss_monitoring.tmpl.json'))
}

var EnableDdosVnet = {
	definitionId: '/providers/Microsoft.Authorization/policyDefinitions/94de2ad3-e0c1-4caf-ad78-5d47bbc83d3d'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_enable_ddos_vnet.tmpl.json'))
}

var EnforceTlsSsl = {
	definitionId: '${targetMgResourceId}/providers/Microsoft.Authorization/policySetDefinitions/Enforce-EncryptTransit'
	definition: json(loadTextContent('policyAssignments/policy_assignment_es_enforce_tls_ssl.tmpl.json'))
}

// RBAC Role Definitions Variables - Used For Policy Assignments
var rbacRoleDefinitions = {
  owner: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  networkContributor: '4d97b98b-1d4f-4787-a291-c67834d212e7'
  aksContributor: 'ed7f3fbd-7b88-4dd4-9017-9adb7ce333f8'
}

// Managment Groups Varaibles - Used For Policy Assignments
var varManagementGroupIds = {
  intRoot: targetMgId
  platform: '${targetMgId}-platform'
  platformManagement: '${targetMgId}-platform-management'
  platformConnectivity: '${targetMgId}-platform-connectivity'
  platformIdentity: '${targetMgId}-platform-identity'
  landingZones: '${targetMgId}-landingzones'
  landingZonesCorp: '${targetMgId}-landingzones-corp'
  landingZonesOnline: '${targetMgId}-landingzones-online'
  decommissioned: '${targetMgId}-decommissioned'
  sandbox: '${targetMgId}-sandbox'
}

var targetMgResourceId = '/providers/Microsoft.Management/managementGroups/${targetMgId}'

// Modules - Policy Assignments - "mg-A2g"
// Module - Policy Assignment - Deploy-MDFC-Config
module assignDeployMdfcConfig '../../modules/authorization/policyAssignments/managementGroup/deploy.bicep' = {
  scope: managementGroup(targetMgId)
  name: 'assignDeployMdfcConfig'
  params: {
    name: deployMdfcConfig.definition.name
    location: location
    policyDefinitionId: deployMdfcConfig.definitionId    
    displayName: deployMdfcConfig.definition.properties.displayName
    description: deployMdfcConfig.definition.properties.description
    parameters: deployMdfcConfig.definition.properties.parameters
    emailSecurityContact: {
        value: SecurityContactEmail
      }
      ascExportResourceGroupLocation: {
        value: logaAALocation
      }
      logAnalytics: {
        value: diagnosticWorkspaceId
      }
    identity: deployMdfcConfig.definition.identity.type
    roleDefinitionIds: [
      rbacRoleDefinitions.owner
    ]
    enforcementMode: deployMdfcConfig.definition.properties.enforcementMode
  }
}



// Module - Policy Assignment - Deny-DataB-Pip
module assignDenyDataBPip '../../modules/authorization/policyAssignments/managementGroup/deploy.bicep' = {
  scope: managementGroup('mg-A2g-Landing-Zones')
  name: 'DenyDataBPip'
  params: {
    name: denyDataBPip.definition.name 
    location: location
    policyDefinitionId: denyDataBPip.definitionId
    displayName: denyDataBPip.definition.properties.displayName
    description: denyDataBPip.definition.properties.description
    parameters: denyDataBPip.definition.properties.parameters
    identity: denyDataBPip.definition.identity.type
    enforcementMode: denyDataBPip.definition.properties.enforcementMode    
  }
}


