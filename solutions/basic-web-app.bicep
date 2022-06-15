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

// @secure()
// @description('Mandatory. The administrator login username for the SQL server.')
// param sqlServerAdministratorLogin string

// @secure()
// @description('Mandatory. The administrator login password for the SQL server.')
// param sqlServerAdministratorPassword string

// ========= //
// Variables //
// ========= //

var resourceGroupName = '${solutionName}-${environmentName}-rg'
var keyVaultName = '${solutionName}-${environmentName}-kv'
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
module kv '../arm/Microsoft.KeyVault/vaults/deploy.bicep' = {
  name: keyVaultName
  scope: resourceGroup(resourceGroupName)
  params: {
    name: keyVaultName
    location: location
    enableVaultForDeployment: true
    enableVaultForTemplateDeployment: true
  }
  dependsOn: [
    rg
  ]
}

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

// // SQL Server
// module sqlserver '../arm/Microsoft.Sql/servers/deploy.bicep' = {
//   name: sqlServerName
//   scope: resourceGroup(resourceGroupName)
//   params: {
//     name: sqlServerName
//     administratorLogin: sqlServerAdministratorLogin
//     administratorLoginPassword: sqlServerAdministratorPassword
//   }
//   dependsOn: [
//     rg
//   ]
// }

// // SQL DB
// module sqldb '../arm/Microsoft.Sql/servers/databases/deploy.bicep' = {
//   name: sqlDatabaseName
//   scope: resourceGroup(resourceGroupName)
//   params: {
//     name: sqlDatabaseName
//     serverName: sqlserver.name
//   }
//   dependsOn: [
//     rg
//     sqlserver
//   ]
// }
