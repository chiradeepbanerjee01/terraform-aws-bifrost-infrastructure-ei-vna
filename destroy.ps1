$account = (aws sts get-caller-identity | ConvertFrom-Json).account
Write-Output "Note: This script will destroy the Bifröst infrastructure stack previously created. Continue at your own risk."
$userInput = Read-Host "Are you sure you want to continue? (y/n)"

# Check the user's input and proceed accordingly
switch ($userInput.ToLower()) {
    'y' {
        Write-Information "Continuing with the termination of the Bifröst infrastructure..."
        $key = "bifrost-infrastructure"
        terraform init -upgrade -backend-config="key=${key}" -backend-config="bucket=terraform-remote-state-${account}-us-east-2" -backend-config="dynamodb_table=terraform-remote-state-${account}-us-east-2" -reconfigure
        terraform destroy --auto-approve
    }
    'n' {
        Write-Information "User has chosen to not destroy the infrastructure. Aborting the script."
        exit
    }
    default {
        Write-Information "Invalid input. Please respond with Y for Yes or N for No."
    }
}
