[![Bifröst Infrastructure Template][repo_logo_img]][repo_url]

# Purpose

The Bifröst infrastructure template is intended to provide functioning examples and guidance of how to provision the necessary components into your Amazon Web Services (AWS) account that fall into the following categories:

- Infrastructure components that have little to no cost associated with them and can be safely shared across pipeline runs
  - Virtual Private Cloud, Subnets, and Route 53 DNS are examples of this category
- Infrastructure components that have excessive build times to provision as part of a pipeline run AND have acceptable costs
  - FSx for Windows and AWS Directory Service for Microsoft Active Directory are examples of this category
  - Both have >30 minute deploy times, and FSx depends on AD requiring them to be run serially
- Any other items that a team may require to persist and share across pipeline executions
  - Example: An S3 bucket containing test data or team specific artifacts

This is for infrastructure above and beyond the account generic items deployed by the [AFT process](https://hyland.atlassian.net/l/cp/f1dWAG4n)

# Required Pre-Reqs

[Full Documentation here]https://hyland.atlassian.net/wiki/spaces/CE/pages/847218780/Tooling+Required

1. Terraform executable
2. AWS CLI installed
3. Access to the account via hyland.okta.com
4. An SSH key for accessing Hyland's github organization
   - This key will need to be passwordless or managed by your SSH provider
   - Terraform does not allow for user input of the password at run time

# Components

The Bifröst infrastructure template shares many criteria with the [Root module](https://github.com/HylandSoftware/terraform-aws-bifrost-root-module-template) as it is by definition a Root Module as well, but has some special handling that a standard root module does not require. If you are unfamiliar with the Root Module template, you should review it first, as this document assumes much of the information held there.

## Providers

`providers.tf` will require an alias if you are deploying the [R53 service catalog](https://github.com/HylandSoftware/terraform-aws-bifrost-infrastructure-template/blob/main/templates/onbase/standard/main.tf#L22). This is due to the fact that the R53 service catalog requires a different provider which assuming a different role (delivery_org_r53_delegation) which exists in a different central account dedicated to networking and DNS (962530257108).

## Versions

Unlike a standard root module, `versions.tf` can contain static S3 backend information, as this repo is not intended to be run multiple times or concurrently. Please see the example [versions.tf](versions.tf) in the root of this repo for further information

# Execution Instructions

These infrastructure components are expected to be known to the team and not needing to be traced, thus the expectation is that these will be run in with the IAC creds provided in Secrets Manager in your AWS account rather than your SSO account creds. A version of these instructions with screen shots can be found [here](https://hyland.atlassian.net/l/cp/pncj8DUe)

1. Install and configure AWS CLI
   <details>
   <summary>How to install and configure?</summary>

   - **Install AWS CLI:** Follow the instructions provided in the [AWS CLI documentation](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) to install AWS CLI on your local machine(Windows/Linux/MacOS).

   - **Verify AWS CLI Installation:**

     - Run `aws --version` to ensure that AWS CLI is installed correctly.

   - **Configure AWS CLI:**
     1. Log into [okta](https://hyland.okta.com/)
     1. Select one of the accounts you have access to
     1. Choose your OS from tabs in the dialogue box
     1. Find the first method: `AWS IAM Identity Center credentials (Recommended)`
     1. Copy `SSO start URL` and `SSO Region`
     1. Run the `aws configure sso` command in your preferred terminal
     1. Provide the following details to terminal prompts:
        ```bash
           sso session name = default
           sso_start_url = https://d-9a671dcf76.awsapps.com/start
           sso_region = us-east-2
           sso_registration_scopes = sso:account:access
        ```
        - AWS CLI attempts to open your default browser
        - In your browser window, click `Confirm and continue` if the code on browser matches the one given to you in terminal.
        - Then click `Allow access` to approve the request
        - AWS CLI displays the AWS accounts available for you to use (If you are authorized to use only one account, the AWS CLI selects that account for you automatically and skips the prompt)
        - Use the arrow keys to select the account you want to use then hit `ENTER`
        - The AWS CLI displays the IAM roles that are available to you in the selected account. (If the selected account lists only one role, the AWS CLI selects that role for you automatically and skips the prompt.
        - Use the arrow keys to select the role you want to use then hit `ENTER`. (If you are intending to deploy resources, you will need to select `AWSPowerUserAccess` or `AWSAdministratorAccess` for sufficient permissions.)
        - Specify `CLI default client Region`, `CLI default output format`, `CLI profile name` (i.e: us-east-2, json, default)
     1. Verify the configuration by running `aws sts get-caller-identity`.

   </details>

1. Create a new GitHub repo for your infrastructure repo utilizing this repo as a template
   - This repo is available as a template repo inside the Hyland Org
   - Repository name recommendation: `terraform-aws-DEPARTMENT-PROGRAMKEY-ENVIRONMENT-infrastructure`
   - Example group: https://hyland.atlassian.net/jira/software/c/projects/ENBL/pages
   - Example replaced: `terraform-aws-cpedevelopment-enbl-sandbox-infrastructure`
1. Clone down your new repo
1. Move the template folder for the Hyland product infrastructure you desire from the `templates` folder to the root of the repo, and remove the `templates` folder and all subfolders
   - This should leave no folder structure and only loose files
1. Log into [okta](https://hyland.okta.com/)
1. Select the account you wish to deploy into
1. Open notepad\text editor of choice
   1. Make a note of both the account name and account number in your text editor
1. Log in with the AWSPowerUserAccess role to the AWS Console
1. Search for Secrets Manager in the AWS dashboard
1. Click on `iac_deploy_user_api_keys`
1. Click Retrieve Secret Value
1. Paste the following into your editor
   ```
   $Env:AWS_ACCESS_KEY_ID="<<ACCESS_KEY>>"
   $Env:AWS_SECRET_ACCESS_KEY="<<SECRET_ACCESS_KEY>>"
   $Env:AWS_DEFAULT_REGION="us-east-2"
   ```
1. Replace the access and secret key with the values from Secrets Manager
1. If you need a different region than us-east-2, you can replace it here
1. Set aside the editor for now
1. Rename the `terraform.tfvars.template` to `terraform.tfvars`
1. Ensure that the newly renamed file is not being tracked and is being picked up by the .gitignore
1. Edit the `terraform.tfvars` file
1. Replace the `<<ACCESS_KEY>>` on line 3 with your access key from Secrets Manager
1. Replace the `<<SECRET_KEY>>` on line 4 with your secret key from Secrets Manager
1. Replace the `<<ACCOUNT_NUMBER>>` on line 5 with your account number
1. Replace the following items in the `zone_name` on line 6
   - `<<ENVTYPE>>` with your environment type - refer to the account name if unsure
   - `<<PROGRAM_KEY>>` with your Jira Program Key
   - `<<BDU>>` with your Business Delivery Unit Key
   1. Example: `sandbox.bifrost.ecm.bdu.hyland.dev`
      1. Where:
         - `<<ENVTYPE>>` = `sandbox`
         - `<<PROGRAM_KEY>>` = `bifrost`
         - `<<BDU>>` = `ecm`
1. If necessary, replace the region with the region you are deploying to
1. Save, commit, and push your changes to the repo
1. Open a Powershell session to the root of your repo
1. Retrieve the three commands from your text editor, paste them in to Powershell and press enter
1. Paste the following commands into Powershell and press enter (no replacements are needed):
   ```
   $account = (aws sts get-caller-identity | ConvertFrom-Json).account
   $cred = (aws sts assume-role --duration-seconds 3600 --role-arn "arn:aws:iam::${account}:role/@iac_deploy_role" --role-session-name iacrole | ConvertFrom-Json).Credentials
   $Env:AWS_ACCESS_KEY_ID=$cred.AccessKeyId
   $Env:AWS_SECRET_ACCESS_KEY=$cred.SecretAccessKey
   $Env:AWS_SESSION_TOKEN=$cred.SessionToken
   ```
1. Run `deploy.ps1` via PowerShell. (This script will run terraform init, plan, and apply)
   ```powershell
   .\deploy.ps1
   ```
1. Terraform will now build out the infrastructure
   - For the OnBase Standard Template, expect ~50 minutes for the deploy to complete
   - In the event of an interruption or timeout, simply run the apply again, Terraform is very good at picking up where it left off

# Subsequent Execution Instructions

In the event that you have made changes to your infrastructure repository and need to apply them

1. Ensure you have cloned down the latest version you wish to apply
1. Generate the `terraform.tfvars` that contains the needed 5 variables
   - See [terraform.tfvars.template](templates/onbase/standard/terraform.tfvars.template) for formatting
1. Create the environmental variables with the access keys from Secrets Manager
   ```
   $Env:AWS_ACCESS_KEY_ID="<<ACCESS_KEY>>"
   $Env:AWS_SECRET_ACCESS_KEY="<<SECRET_ACCESS_KEY>>"
   $Env:AWS_DEFAULT_REGION="us-east-2"
   ```
1. Paste the following commands into Powershell and press enter (no replacements are needed):
   ```
   $account = (aws sts get-caller-identity | ConvertFrom-Json).account
   $cred = (aws sts assume-role --duration-seconds 3600 --role-arn "arn:aws:iam::${account}:role/@iac_deploy_role" --role-session-name iacrole | ConvertFrom-Json).Credentials
   $Env:AWS_ACCESS_KEY_ID=$cred.AccessKeyId
   $Env:AWS_SECRET_ACCESS_KEY=$cred.SecretAccessKey
   $Env:AWS_SESSION_TOKEN=$cred.SessionToken
   ```
1. Run `deploy.ps1` via PowerShell. (This script will run terraform init, plan, and apply)
   ```powershell
   .\deploy.ps1
   ```

# Destroy the Bifröst infrastructure

1. Generate the `terraform.tfvars` that contains the needed 5 variables
   - See [terraform.tfvars.template](templates/onbase/standard/terraform.tfvars.template) for formatting
1. Create the environmental variables with the access keys from Secrets Manager
   ```
   $Env:AWS_ACCESS_KEY_ID="<<ACCESS_KEY>>"
   $Env:AWS_SECRET_ACCESS_KEY="<<SECRET_ACCESS_KEY>>"
   $Env:AWS_DEFAULT_REGION="us-east-2"
   ```
1. Paste the following commands into Powershell and press enter (no replacements are needed):
   ```
   $account = (aws sts get-caller-identity | ConvertFrom-Json).account
   $cred = (aws sts assume-role --duration-seconds 3600 --role-arn "arn:aws:iam::${account}:role/@iac_deploy_role" --role-session-name iacrole | ConvertFrom-Json).Credentials
   $Env:AWS_ACCESS_KEY_ID=$cred.AccessKeyId
   $Env:AWS_SECRET_ACCESS_KEY=$cred.SecretAccessKey
   $Env:AWS_SESSION_TOKEN=$cred.SessionToken
   ```
1. Run `destroy.ps1` via PowerShell and you'll be prompted to ensure you want to continue performing a destruction of the infrastructure.

   ```powershell
   .\destroy.ps1

   Note: This script will destroy the Bifröst infrastructure stack previously created. Continue at your own risk.
   Are you sure you want to continue? (y/n):
   ```

   Only a `y` or `Y` will perform a destruction of the infrastructure. All other inputs will abort the execution of the script.

<!-- Repository -->

[repo_url]: https://github.com/HylandSoftware/terraform-aws-bifrost-infrastructure-template
[repo_logo_img]: https://github.com/HylandSoftware/terraform-aws-bifrost-infrastructure-template/assets/88686011/579c8c48-ef28-4580-9abf-03af942fe5b8
