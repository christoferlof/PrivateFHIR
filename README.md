# Azure API for FHIR on Private Link example

This example shows how to provision [Azure API for FHIR](https://docs.microsoft.com/en-us/azure/healthcare-apis/azure-api-for-fhir/) for [Private Link](https://docs.microsoft.com/en-us/azure/healthcare-apis/azure-api-for-fhir/configure-private-link).

By deploying the Main.bicep template you'll get:

* Resource group, named `private-fhir-{6-char-unique}`
* Azure API for FHIR on private network.
* Storage account on private network.
* Azure API for FHIR [configured to use the provisioned storage account](https://docs.microsoft.com/en-us/azure/healthcare-apis/data-transformation/configure-export-data) for `$export` operations.
* FHIR server managed identity added to Blob Contributors role, to be able to save exports.
* Virtual network with one subnet.
* Private endpoints for storage and FHIR server.
* Ubuntu LTS-18.04 jumpbox, to be able to access storage and FHIR server.

To deploy this example run the following command:

> **Note**: The below command will create a subscption scoped deployment.

```bash
 az deployment sub create --location <Azure region> --template-file Main.bicep --subscription <subscriptionId to deploy to> --parameters adminUsername=<jumpbox username> adminPassword=<jumpbox password>
```

Once the deployment is completed there is one post-deployment step to complete:

* Assign RBAC permissions on the FHIR API, like adding yourself.

The jumpbox is deployed with a network security rule denying inbout Internet connections. Use [just-in-time access](https://docs.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-usage?tabs=jit-config-asc%2Cjit-request-asc) to update the NSG rule to allow inbound connections from your location.
