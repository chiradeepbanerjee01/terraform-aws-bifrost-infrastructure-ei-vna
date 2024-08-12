$InformationPreference = 'Continue'
function Test-CliToolInstalled {
    param (
        [string]$CliToolName
    )
    try {
        # Attempt to run the command associated with the CLI tool
        & $CliToolName --version
        return $true
    }
    catch [System.Management.Automation.CommandNotFoundException] {
        # If the command is not found, return false
        return $false
    }
    catch {
        # Handle any other exceptions
        Write-Error "An unexpected error occurred while checking if $CliToolName is installed: $_"
        Write-Error $_.Exception.Message
        return $false
    }
}

# List of CLI tools to check
$cliTools = @("terraform", "aws")

Write-Information "Performing pre-deployment checks to ensure all required tools are installed..."
foreach ($tool in $cliTools) {
    if (!(Test-CliToolInstalled -CliToolName $tool)) {
        Write-Error "$tool is not installed. Please install it before proceeding."
        break
    }
}
Write-Information "All required tools are installed. Proceeding with deployment..."

# Terraform init and apply
$account = (aws sts get-caller-identity | ConvertFrom-Json).account
$key = 'bifrost-infrastructure'
$initstopwatch = [system.diagnostics.stopwatch]::StartNew()
Write-Information "Starting Terraform apply."
terraform init -upgrade -backend-config="key=${key}" -backend-config="bucket=terraform-remote-state-${account}-us-east-2" -backend-config="dynamodb_table=terraform-remote-state-${account}-us-east-2" -reconfigure
$initstopwatch.Stop()
Write-Information "Terraform init done."
Write-Information "Starting Terraform apply."
$applystopwatch = [system.diagnostics.stopwatch]::StartNew()
terraform apply --auto-approve
$applystopwatch.Stop()

# print results
Write-Information "Init Clock"
Write-Information $initstopwatch
Write-Information "Apply Clock"
Write-Information $applystopwatch
Write-Information "INFO: Make a note of the following information for future reference"
Write-Information "Terraform State File Key: ${key}"