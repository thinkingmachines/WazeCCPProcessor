### GCP setup

log into your GCP console.

**Create GCP project**
1. Create a new project
    Open up the project selection dialog and click New Project. Select a name and organization for your project.

1. Create service account
    navigate to the IAM and admin panel for your newly created project. Select service accounts from the menu on the left. Enter a name and ID for your service account.

2. Grant the following permissions to your service account

    Storage Admin
    BigQuery Admin
    Cloud Functions Developer
    Project Owner (we will remove this role later)

3. Create a key and note its location for later account.json

click done to finish the service account creation dialog

**Enable Cloud Functions API**
1. [Enable the cloud functions api](https://console.cloud.google.com/apis/library/cloudfunctions.googleapis.com) for your project


### Download Git Repo Code and Configure
1. Download this repo to a folder on your computer.
2. copy your key json file to the GCP directory and rename it to account.json
3. go to GCP/providers.tf and add your project name and a default region to the config
4. edit variables.tf and make the following changes

    set `waze_data_url` to the url of your waze feed
    set `user_email` to your email
    set `service_account_email` to the email of the service account you created
    set `waze_raw_bucket_name` note: this value must be globally unique
    set `gcp-wazeccpprocessor-processed` note: this value must be globally unique
    optional: change the bucket_location or dataset name


### Setup Terraform for the First Time (one-time)

1. Download the [latest version](https://www.terraform.io/downloads.html) v0.11, unzip, move to /bin if needed, and [set the path](https://www.terraform.io/intro/getting-started/install.html) (eg, sudo ln -s terraform terraform).
2. Verify your version is correct by running `terraform --version`.

### Running Terraform
1. In your terminal go to your `/GCP` directory
2. Run the following commands
    - `terraform init`
    - `terraform plan`
    - `terraform apply`

###GCloud setup
1. install the [gcloud SDK](https://cloud.google.com/sdk/install)
2. set your default gcloud sdk credentials by executing `gcloud auth login application-default` at the command line
    
### Create App Engine service and configure cron
1. Go to `GCP/app_engine` and execute `gcloud app deploy`
2. Choose a region for your app engine application to be deployed in
3. Once the app finishes deploying execute `gcloud app browse` to check that it's running properly
4. Run `gcloud app deploy cron.yaml` to set the cron job to run your cloud function every 2 minutes

###Cleanup
1. navigate back to the iam page and remove the project owner permission from the service account