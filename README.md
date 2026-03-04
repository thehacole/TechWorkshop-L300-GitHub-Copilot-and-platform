# Project

This lab guides you through a series of practical exercises focused on modernising Zava's business applications and databases by migrating everything to Azure, leveraging GitHub Enterprise, Copilot, and Azure services. Each exercise is designed to deliver hands-on experience in governance, automation, security, AI integration, and observability, ensuring Zava’s transition to Azure is robust, secure, and future-ready.

## ZavaStorefront – Azure Infrastructure Deployment (AZD)

This project uses [Azure Developer CLI (AZD)](https://learn.microsoft.com/azure/developer/azure-developer-cli/) and [Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/overview) to provision all Azure resources for the ZavaStorefront web application in a single command.

### Resources Provisioned

| Resource | Name | Purpose |
|---|---|---|
| App Service Plan | `asp-zavastorefront-dev` | Hosting plan for the web app |
| Linux App Service | `app-zavastorefront-dev` | Web application host |
| Azure Container Registry | `acrzavastorefrontdev` | Docker image storage |
| Application Insights | `appi-zavastorefront-dev` | Application monitoring |
| Log Analytics Workspace | `law-zavastorefront-dev` | Log aggregation for App Insights |
| Azure AI Foundry | `foundry-zavastorefront-dev` | GPT-4 and Phi model access |

All resources are deployed to resource group `rg-zavastorefront-dev` in the `westus3` region.

### Project Structure

```
infra/
├── main.bicep                 # Main infrastructure template (orchestrates all modules)
├── app-service.bicep          # App Service Plan and Linux Web App with managed identity
├── acr.bicep                  # Azure Container Registry with AcrPull RBAC assignment
├── app-insights.bicep         # Application Insights and Log Analytics Workspace
├── foundry.bicep              # Azure AI Foundry with GPT-4 and Phi model deployments
├── main.parameters.json       # Default parameter values
└── parameters.dev.json        # Dev environment parameters

azure.yaml                     # AZD project configuration
```

### Prerequisites

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (v2.50+)
- [Azure Developer CLI (AZD)](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- An active Azure subscription with Contributor access

> **Note:** No local Docker installation is required. The App Service pulls container images directly from Azure Container Registry using managed identity.

### Installation

Install AZD if you haven't already:

```bash
# macOS / Linux
curl -fsSL https://aka.ms/install-azd.sh | bash

# Windows (PowerShell)
winget install microsoft.azd
```

### Deployment Guide

#### 1. Authenticate with Azure

```bash
az login
azd auth login
```

#### 2. Initialize the AZD environment

```bash
azd env new dev
azd env set AZURE_LOCATION westus3
```

#### 3. Deploy all resources

```bash
azd up
```

This single command will:
- Create resource group `rg-zavastorefront-dev`
- Provision all Bicep-defined resources
- Wire Application Insights to the App Service

#### 4. View deployment outputs

After deployment completes, AZD will display:
- `appServiceUrl` – Public URL of the deployed web app
- `acrLoginServer` – ACR login server for pushing images
- `appInsightsName` – Application Insights resource name
- `foundryEndpoint` – Azure AI Foundry endpoint

### Environment Configuration

Parameters can be customised in `infra/parameters.dev.json`:

| Parameter | Default | Description |
|---|---|---|
| `environmentName` | `dev` | Environment suffix for resource names |
| `location` | `westus3` | Azure region |
| `appName` | `zavastorefront` | Base name for all resources |
| `containerImage` | `mcr.microsoft.com/appsvc/staticsite:latest` | Initial container image |

### Azure RBAC for ACR Image Pulls

The App Service uses a **system-assigned managed identity** to pull images from ACR without any passwords or secrets. The `acr.bicep` module assigns the built-in `AcrPull` role to the App Service identity automatically at deployment time.

To push a new image to ACR after deployment:

```bash
# Build and push without local Docker – use ACR Tasks
az acr build \
  --registry acrzavastorefrontdev \
  --image zavastorefront:latest \
  ./src
```

Then update the App Service container image:

```bash
az webapp config container set \
  --name app-zavastorefront-dev \
  --resource-group rg-zavastorefront-dev \
  --docker-custom-image-name acrzavastorefrontdev.azurecr.io/zavastorefront:latest
```

### Verification Steps

1. Open the `appServiceUrl` in a browser to verify the app is running
2. Navigate to Application Insights in the Azure portal to confirm telemetry is flowing
3. Verify the AcrPull role assignment in the ACR → Access Control (IAM) blade

### Teardown

To remove all provisioned resources:

```bash
azd down
```

### Troubleshooting

| Issue | Resolution |
|---|---|
| `az login` fails | Ensure Azure CLI is installed and run `az account set --subscription <id>` |
| Role assignment error | Confirm your account has `Owner` or `User Access Administrator` on the subscription |
| Container image pull fails | Verify the managed identity has the `AcrPull` role in ACR IAM |
| Model deployment quota error | Request quota increase for the selected region in the Azure portal |

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
