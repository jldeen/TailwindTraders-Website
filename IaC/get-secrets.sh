#!/bin/bash

# example command:
# sh scripts/get-secrets.sh

set -e

# GitHub workflow REQUIRED secrets:
# AZURE_CREDENTIALS
# RESOURCE_GROUP
# SUBSCRIPTION_NAME
# LOCATION
# COSMOS_DB_NAME
# SQL_ADMIN
# SQL_PASSWORD
# SQL_DB_NAME
# WEBAPP_NAME
# ACR_NAME
# CONTAINER_REGISTRY
# REGISTRY_USERNAME
# REGISTRY_PASSWORD

# Set the following credentials
spName=tailwindtraders30jd1
resourceGroup=igniteapps30jd
adminUser=twtadmin
adminPassword=twtapps30pD
webappName=igniteapps30
subName="Ignite The Tour"
location=eastus

# DB Info
cosmosDBName=apps30twtnosql
sqlDBName=apps30twtsql

acrName=igniteapps30acr

az account set --subscription "Ignite The Tour" && echo "Your default subscription has been set to: Ignite The Tour"

# Create a service principal
    echo "Creating service principal..."
    spInfo=$(az ad sp create-for-rbac --name "$spName" \
            --role contributor \
            --sdk-auth)

    if [ $? == 0 ]; then
        # get acr name
        echo "Retrieving Container Registry info..."
        acrName=$(az acr list -g $resourceGroup -o tsv --query "[0].name")

        #get mongo connection string

        cosmosConnectionString=$(az cosmosdb list-connection-strings --name $cosmosDBName  --resource-group $resourceGroup --query connectionStrings[0].connectionString -o tsv --subscription "$subName")

        sqlConnectionString=$(az sql db show-connection-string --server $sqlDBName --name tailwind -c ado.net --subscription "$subName" | jq -r .)

        echo '========================================================='
        echo 'GitHub secrets for configuring GitHub workflow'
        echo '========================================================='

        echo "AZURE_CREDENTIALS: $spInfo"
        echo "RESOURCE_GROUP: $resourceGroup"
        echo "SUBSCRIPTION_NAME: $subName"
        echo "LOCATION: $location" 
        echo "COSMOS_DB_NAME: $cosmosDBName"
        echo "SQL_ADMIN: $adminUser"
        echo "SQL_PASSWORD: $adminPassword"
        echo "SQL_DB_NAME: $sqlDBName"
        echo "WEBAPP_NAME: $webappName"
        echo "ACR_NAME: $acrName"
        echo "MONGODB_CONNECTION_STRING: $cosmosConnectionString"
        echo "SQL_CONNECTION_STRING: $sqlConnectionString"
        echo "CONTAINER_REGISTRY: $(az acr list -g $resourceGroup -o tsv --query [0].loginServer)"
        echo "REGISTRY_USERNAME: $(az acr credential show -n $acrName --query username -o tsv)"
        echo "REGISTRY_PASSWORD: $(az acr credential show -n $acrName -o tsv --query passwords[0].value)"
        echo '========================================================='
    else
        "An error occurred. Please try again."
         exit 1
    fi
