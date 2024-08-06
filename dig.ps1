$PCRalertResourceGroup =  "vf-core-IT-resources-rg"

$PCRalertResourceGroupv2 = $PCRalertResourceGroup
$subscriptionID = "24b4b7e2-6a4a-4418-8868-9f51dfeca509"
$newResourceGroupName = "VF-03"
$newResourceGroup = Get-AzResourceGroup -Name $newResourceGroupName
$newResourceGroupId = $newResourceGroup.ResourceId
$newResourceGrouplocation = $newResourceGroup.Location

$userAssignedIdentity = Get-AzUserAssignedIdentity -ResourceGroupName  $PCRalertResourceGroup -Name 'vf-core-cm-managed-identity-ap'




# Define the policy parameters
$DS_policyParameters = @{
    "logAnalytics" = "$logAnalyticsWorkspaceId"
}

$DS_policyDefinitions = @(
    "vf-core-cm-diag-setg-for-storage-acc-to-log-anl",
    "vf-core-cm-diag-setg-for-blob-ser-to-log-anl",
    "vf-core-cm-diag-setg-for-file-ser-to-log-anl",
    "vf-core-cm-diag-setg-for-SQL-db-to-log-anl",
    "vf-core-cm-diag-setg-for-postgreSQL-to-log-anl",
    "vf-core-cm-diag-setg-for-mySQL-db-to-log-anl",
    "vf-core-cm-diag-setg-for-app-gw-to-log-anl"
   
)

foreach ($DS_policyDefinition in $DS_policyDefinitions) {
    $DS_PolicynameASS ="$DS_policyDefinition-$newResourceGroupName"
    $DS_GETpolicyDefinition = Get-AzPolicyDefinition -Name $DS_policyDefinition

    $DS_existingpolicyAssignment = Get-AzPolicyAssignment -Name $TS_PolicynameASS -Scope $newResourceGroupId -ErrorAction SilentlyContinue

    if ($null -ne $DS_existingpolicyAssignment) {
        Write-Output "The policy $DS_policyDefinition is already assigned to the resource group $newResourceGroupName."
    } else {
        New-AzPolicyAssignment -Name $DS_PolicynameASS -PolicyDefinition $DS_GETpolicyDefinition -Scope $newResourceGroupId -Location $newResourceGrouplocation  -IdentityType 'UserAssigned' -IdentityId $userAssignedIdentity.Id  -PolicyParameterObject $DS_policyParameters
        Write-Output "Assigned policy $DS_policyDefinition to resource group $newResourceGroupName."
    }


    New-AzPolicyAssignment -Name $DS_PolicynameASS -PolicyDefinition $DS_GETpolicyDefinition -Scope $newResourceGroupId -Location $newResourceGrouplocation  -IdentityType 'UserAssigned' -IdentityId $userAssignedIdentity.Id  -PolicyParameterObject $DS_policyParameters
     # Output the assignment status
     Write-Output "Assigned policy $DS_policyDefinition to resource group $newResourceGroupName."
}

##############
# Define the policy parameters
$TS_policyParameters = @{
        "tagName" = "vf-core-cloud-monitoring"
        "tagValue" = "true"
    }
    $TS_PolicynameASS ="vf-core-cm-tag-resources-$newResourceGroupName"
    $TS_GETpolicyDefinition = Get-AzPolicyDefinition -Name "vf-core-cm-tag-resources"
    
    $TS_existingpolicyAssignment = Get-AzPolicyAssignment -Name $TS_PolicynameASS -Scope $newResourceGroupId -ErrorAction SilentlyContinue

if ($null -ne $TS_existingpolicyAssignment) {
    Write-Output "The policy$TS_policyDefinition is already assigned to the resource group $newResourceGroupName."
} else {
    New-AzPolicyAssignment -Name $TS_PolicynameASS -PolicyDefinition $TS_GETpolicyDefinition -Scope $newResourceGroupId -Location $newResourceGrouplocation  -IdentityType 'UserAssigned' -IdentityId $userAssignedIdentity.Id  -PolicyParameterObject $TS_policyParameters
    Write-Output "Assigned policy $TS_policyDefinition to resource group $newResourceGroupName."
}
#############
$SDS_policyParameters = @{
    "logAnalytics" = $logAnalyticsWorkspaceId
}

$SDS_policyDefinitions = @(
"vf-core-cm-diag-setg-for-blob-ser-to-log-anl",
"vf-core-cm-diag-setg-for-file-ser-to-log-anl"
)
foreach ($SDS_policyDefinition in $SDS_policyDefinitions) {
$SDS_PolicynameASS ="$SDS_policyDefinition-$newResourceGroupName"
$SDS_GETpolicyDefinition = Get-AzPolicyDefinition -Name $SDS_policyDefinition
New-AzPolicyAssignment -Name $SDS_PolicynameASS -PolicyDefinition $SDS_GETpolicyDefinition -Scope $newResourceGroupId -Location $newResourceGrouplocation  -IdentityType 'UserAssigned' -IdentityId $userAssignedIdentity.Id  -PolicyParameterObject $SDS_policyParameters
}