#!/bin/bash
echo "*********** Cloud Monitoring Automation Build************"
echo -e ""
echo -e "********************************************"

echo -e "Useful information before you proceed."

echo -e "\n\n1. deploy.sh will deploy Resource Group, Monitoring Alert Rules, Log Analytics Workspace, Managed User Identities, Policy Definitions and Assignments. However some of the resources optional for existing PCR customers. Example: ResourceGroup, Loganalyticsworkspace etc"

echo -e "\n\n2. Is this customer existing PCR customer or new customer?"

echo -e "\n\n3. Log Analytics Workspace Data Retention Period 90 days - by default. This period could be extended up to 2 years (730 days)  if customer wanted. "
currentTimestamp=$(date +%s)
echo -e ""
echo -e ""
echo -e "Parameters\n\n"
echo -e "-----------------------------------------------"
echo -e ""
echo -e "Customer / Local OpCo Information...\n\n"
echo -e ""
read -p "   Is this deployment for existing PCR customer subscription (Yes / No): " pcrcustomer
echo -e ""
echo -e ""
declare -i retentionindays

while true; do
  # Prompt the user for input
  echo "   Deployment local OpCo or location :"
  echo "      1. GB"
  echo "      2. DE"
  echo "      3. PT"

  read -p $'\n    Local OpCo Location :' opcoLocation

  # Check the user's local opCo choice 
  if [ "$opcoLocation" -eq 1 ]; then
    pcrRG="vf-core-GB-resources-rg"
    location=$(az group show --resource-group $pcrRG --query "location" --output tsv)
    break
  elif [ "$opcoLocation" -eq 2 ]; then
    pcrRG="vf-core-DE-resources-rg"
    location=$(az group show --resource-group $pcrRG --query "location" --output tsv)
    break
  elif [ "$opcoLocation" -eq 3 ]; then
    pcrRG="vf-core-PT-resources-rg"
    location=$(az group show --resource-group $pcrRG --query "location" --output tsv)
    break
  else
    echo $'\n   Invalid local OpCo choice. Please enter 1, 2, or 3.\n'
  fi
done 

echo $pcrRG
echo $location


echo -e ""
echo -e "-----------------------------------------------"
echo -e ""
echo -e "   Log Analytics Workspace Configuration...\n\n"
echo -e ""
read -p "   Would you like to change the data retention period for Log Analytics workspace? (Yes / No): " changeretentionlaw



if [ "$changeretentionlaw" == "Yes" ]; then
  read -p "   How many days would you like to change? : " retentiondays
  retentionindays=$retentiondays
else 
  retentionindays=90
fi

echo -e ""
echo -e "-----------------------------------------------"
echo -e ""
echo -e "Notifications Action Group Configuration...\n\n"

echo -e ""

read -p "   Enter email address for alert notifications: " -a emailNotification

emailNotification="['${emailNotification//,/\',\'}']"

echo -e ""
echo -e "-----------------------------------------------"

echo -e ""
echo -e "Monitoring Resource Group Information.. \n\n"
echo -e ""

read -p "   Enter Monitoring Resource group (if multiple Resource Groups, separate them with comma):" -a  customerRG
polScope=$customerRG
customerRG="['${customerRG//,/\',\'}']"
echo -e ""
echo -e "-----------------------------------------------"

echo -e ""
echo -e "Virtual Machines Alerts Information"
echo -e ""

read -p "   Enter virtual machines location (if multiple locations, separate them with comma): " -a mLocation

echo -e ""
echo -e ""

mLocation="['${mLocation//,/\',\'}']"

echo -e ""
echo -e "-----------------------------------------------"
echo -e ""
echo -e "Website Monitoring Standard Availability Test Configuration..."

echo -e ""
echo -e ""
read -p "   Would you like to monitor website? (Yes / No): " websiteMonitor
echo -e ""
echo -e ""

if [ "$websiteMonitor" == "Yes" ]; then
  read -p "   Enter Wesite URL : " url
  echo -e ""
  echo -e ""
  read -p "   Enter Application Insight Resource Group : " appInsightRG
  appInsightLocation=$(az group show --resource-group $appInsightRG --query "location" --output tsv)

  echo -e ""
  echo -e "-----------------------------------------------"

  echo -e ""
  echo -e ""

  echo -e "\n\n Deployment in progress .....\n\n"

  echo -e ""
  echo -e ""

  az deployment sub create -f bicep/main.bicep -l $location --parameters pcrCustomer=$pcrcustomer pcrRG=$pcrRG mLocation=$mLocation  customerRG=$customerRG emailNotification=$emailNotification retentionInDays=$retentionindays appInsightRG=$appInsightRG appInsightLocation=$appInsightLocation
else
  echo -e "\n\n Deployment in progress .....\n\n"

  echo -e ""
  echo -e ""

  az deployment sub create -f bicep/main.bicep -l $location --parameters pcrCustomer=$pcrcustomer pcrRG=$pcrRG mLocation=$mLocation  customerRG=$customerRG emailNotification=$emailNotification retentionInDays=$retentionindays 

fi

echo -e "\n\n Azure Policy Assignment in progress .....\n\n"

sh bicep/scripts/policyAssignment.sh $polScope $pcrRG



echo -e "\n\n Custom Log Search Policy in progress .....\n\n"

sh bicep/scripts/customLogSearchPolDeployment.sh $polScope $pcrRG

echo -e "\n\n Contributor role Assignment in progress .....\n\n"

sleep 100


az deployment sub create -f bicep/contributorRoleAssignment.bicep -l $location --parameters pcrRG=$pcrRG currentTimestamp=currentTimeStamp

echo -e "\n\n Custom Log Search Policy Assignment and remediation in progress .....\n\n"

sh bicep/scripts/customLogSearchPolAssignment.sh $polScope $pcrRG