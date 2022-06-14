targetScope = 'subscription'

// ================ //
// Input Parameters //
// ================ //

@description('Mandatory. The project short name used for the naming convention')
param solutionName string

@description('Optional. The name of the environment. This must be dev, test, or prod.')
@allowed([
  'dev'
  'tst'
  'acc'
  'prd'
])
param environmentName string = 'dev'

@description('Optional. The location to deploy into')
param location string = deployment().location

@description('Mandatory. The app service plan sku configuration')
param appServicePlanSku object

@description('Mandatory. The app service plan OS')
param appServicePlanOS string

@description('Mandatory. The type of app: Web App or Function App')
param webAppKind string

// ========= //
// Variables //
// ========= //

var resourceGroupName = '${solutionName}-${environmentName}-rg'
// var keyVaultName = '${solutionName}-${environmentName}-kv'
var appServicePlanName = '${solutionName}-${environmentName}-asp'
var appName = '${solutionName}-${environmentName}-webapp'
// var sqlServerName = '${environmentName}-${solutionName}-sqlserver'
// var sqlDatabaseName = '${solutionName}-db'

// =========== //
// Deployments //
// =========== //

// Resource Group
module rg '../arm/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: resourceGroupName
  params: {
    name: resourceGroupName
    location: location
  }
}

// Key Vault
// module kv '../arm/Microsoft.KeyVault/vaults/deploy.bicep' = {
//   name: keyVaultName
//   scope: resourceGroup(resourceGroupName)
//   params: {
//     name: keyVaultName
//     location: location
//     accessPolicies
//     secrets 
//     keys
//     enableVaultForDeployment
//     enableVaultForTemplateDeployment
//     enableVaultForDiskEncryption
//     enableSoftDelete
//     softDeleteRetentionInDays
//     enableRbacAuthorization
//     createMode
//     enablePurgeProtection
//     vaultSku
//     networkAcls
//     publicNetworkAccess
//     diagnosticLogsRetentionInDays
//     diagnosticStorageAccountId
//     diagnosticWorkspaceId
//     diagnosticEventHubAuthorizationRuleId
//     diagnosticEventHubName
//     lock
//     roleAssignments
//     privateEndpoints
//     tags
//     enableDefaultTelemetry
//     baseTime
//     diagnosticLogCategoriesToEnable
//     diagnosticMetricsToEnable
//     diagnosticSettingsName
//   }
//   dependsOn: [
//     rg
//   ]
// }

// App Service Plan
module asp '../arm/Microsoft.Web/serverfarms/deploy.bicep' = {
  name: appServicePlanName
  scope: resourceGroup(resourceGroupName)
  params: {
    name: appServicePlanName
    sku:{
      name: appServicePlanSku.name
      tier: appServicePlanSku.tier
      capacity: appServicePlanSku.capacity
    }
    serverOS: appServicePlanOS
  }
  dependsOn: [
    rg
  ]
}

// Web App
module webapp '../arm/Microsoft.Web/sites/deploy.bicep' = {
  name: appName
  scope: resourceGroup(resourceGroupName)
  params: {
    name: appName
    kind: webAppKind
    serverFarmResourceId: asp.outputs.resourceId
    httpsOnly: true
  }
  dependsOn: [
    rg
    asp
  ]
}

// SQL Database
// module sqldb '../arm/Microsoft.Sql/managedInstances/deploy.bicep' = {
//   name: 'registry-nsg'
//   scope: resourceGroup(resourceGroupName)
//   params: {
//     name: networkSecurityGroupName
//   }
//   dependsOn: [
//     rg
//   ]
// }
