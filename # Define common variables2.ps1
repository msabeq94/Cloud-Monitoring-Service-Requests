# Define common variables
$subscriptionID = "c3323cc6-1939-4b36-8714-86504bbb8e4b"
$AlertRG = "vf-core-UK-resources-rg"
$rgToRemove = "VF-CloudMonitoringv2"
$actionGroupName ="newag"
$VMlocation = "uksouth"

# Get an access token for Azure management
$accessToken = (Get-AzAccessToken -ResourceUrl "https://management.azure.com").Token

# Construct a header for the HTTP requests
$header = @{
    "Authorization" = "Bearer $accessToken"
    "Content-Type" = "application/json"
}

# Rest of the script...