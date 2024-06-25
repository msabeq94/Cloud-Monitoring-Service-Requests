
# Cloud Monitoring Service Requests

Welcome to the Cloud Monitoring Service Requests repository. This repository contains scripts and templates to automate the setup, management, and removal of Azure monitoring solutions.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Usage](#usage)
  - [Add Azure Cloud Monitoring](#add-azure-cloud-monitoring)
  - [Remove Alerts](#remove-alerts)
  - [Remove Resource Group from Alerts](#remove-resource-group-from-alerts)
  - [Deploy Virtual Machine Alerts](#deploy-virtual-machine-alerts)
- [Contributing](#contributing)
- [License](#license)

## Introduction

This repository provides scripts and templates to help you automate the process of setting up and managing Azure monitoring and alerting. The provided scripts allow you to add monitoring to new resource groups, remove existing alerts, and deploy predefined alert configurations for virtual machines.

## Features

- Automated creation of resource groups and deployment of monitoring solutions.
- Easy removal of specific alerts or all alerts within a resource group.
- Deployment of alert configurations using Bicep templates.

## Prerequisites

Before using the resources in this repository, ensure you have the following:

- An Azure subscription.
- Azure CLI or Azure PowerShell installed and configured.
- Contributor role access to the Azure subscription.
- Basic knowledge of ARM templates, Bicep, and Azure resource management.

## Setup

1. Clone the repository:
    \`\`\`sh
    git clone https://github.com/msabeq94/Cloud-Monitoring-Service-Requests.git
    cd Cloud-Monitoring-Service-Requests
    \`\`\`

2. Navigate to the appropriate directory based on your requirements.

## Usage

### Add Azure Cloud Monitoring

Use the \`Add Azure Cloud Monitoring to a new RG.ps1\` script to create a new resource group and deploy the monitoring solution.

\`\`\`sh
.\Add Azure Cloud Monitoring to a new RG.ps1 -SubscriptionId <your-subscription-id> -ResourceGroupName <your-resource-group-name>
\`\`\`

### Remove Alerts

Use the \`remove alerts.ps1\` script to remove a specific alert from a resource group.

\`\`\`sh
.
emove alerts.ps1 -SubscriptionId <your-subscription-id> -ResourceGroupName <your-resource-group-name> -AlertRuleName <your-alert-rule-name>
\`\`\`

### Remove Resource Group from Alerts

Use the \`remove RG from the alert.ps1\` script to remove all alerts from a resource group.

\`\`\`sh
.
emove RG from the alert.ps1 -SubscriptionId <your-subscription-id> -ResourceGroupName <your-resource-group-name>
\`\`\`

### Deploy Virtual Machine Alerts

Use the \`Virtual Machine Alerts.bicep\` template to deploy alert configurations for virtual machines.

1. Customize the Bicep file with your specific action group ID.
2. Deploy the Bicep template using Azure CLI:

    \`\`\`sh
    az deployment group create --resource-group <your-resource-group-name> --template-file Virtual Machine Alerts.bicep
    \`\`\`

## Contributing

We welcome contributions from the community! If you find any issues or have suggestions for improvements, please feel free to open an issue or submit a pull request.

1. Fork the repository.
2. Create a new branch: \`git checkout -b feature-branch\`
3. Make your changes and commit them: \`git commit -m 'Add some feature'\`
4. Push to the branch: \`git push origin feature-branch\`
5. Submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
