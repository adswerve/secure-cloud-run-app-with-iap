#PURPOSE: secure a Cloud Run app with IAP
# Source: https://codelabs.developers.google.com/secure-serverless-application-with-identity-aware-proxy

############################################################################################
# PART 1: SET UP
############################################################################################

gcloud auth application-default login

export GCLOUD_CONFIGURATION=adswerve-bigquery-training
export PROJECT_ID=adswerve-bigquery-training
export REGION=us-central1
export CLOUD_RUN_SERVICE=cloud-run-service

gcloud config configurations activate $GCLOUD_CONFIGURATION
gcloud auth application-default set-quota-project $PROJECT_ID

export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')

# Log the values of the environment variables
echo "PROJECT_ID: $PROJECT_ID"
echo "GCLOUD_CONFIGURATION: $GCLOUD_CONFIGURATION"
echo "PROJECT_NUMBER: $PROJECT_NUMBER"
echo "REGION: $REGION"
echo "CLOUD_RUN_SERVICE: $CLOUD_RUN_SERVICE"

gcloud config configurations list

############################################################################################
# PART 2: upate the Cloud Run service
############################################################################################
gcloud run services update $CLOUD_RUN_SERVICE \
    --ingress internal-and-cloud-load-balancing \
    --region $REGION


############################################################################################
# PART 3: deploy the solution components
############################################################################################

# make sure you are in the iap directory

cd ..

cd iap

ls -a

# install Terraform if needed

# https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli?in=terraform%2Fgcp-get-started
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew update
brew upgrade hashicorp/tap/terraform
terraform -help

# deploy the solution components

terraform init

# Cloud Run is not managed by Terraform, having a hard time adding it
# terraform import google_cloud_run_service.default projects/adswerve-bigquery-training/locations/us-central1/services/cloud-run-service
#  Error: Cannot import non-existent remote object

terraform plan

terraform apply


############################################################################################
# PART 4: ENABLING CLOUD IDENTITY-AWARE PROXY (IAP) ON THE LOAD BALANCER
############################################################################################
# https://codelabs.developers.google.com/secure-serverless-application-with-identity-aware-proxy?hl=en#4

export USER_EMAIL=$(gcloud config list account --format "value(core.account)")

echo $USER_EMAIL

# create an OAuth consent screen 
gcloud alpha iap oauth-brands create \
    --application_title="demo" \
    --support_email=$USER_EMAIL
# if you get this error, then it's okay, it already exists
# ERROR: (gcloud.alpha.iap.oauth-brands.create) Resource in projects [project] is the subject of a conflict: Requested entity already exists

gcloud alpha iap oauth-brands list    

# ATTENTION: MANUAL STEP
# In GCP console, go to Oath Consent. Change application type Internal

# Create an IAP OAuth Client
# FAILED_PRECONDITION: Brand's Application type must be set to Internal.
gcloud alpha iap oauth-clients create \
    projects/$PROJECT_ID/brands/$PROJECT_NUMBER \
    --display_name=iap-demo

# Store the client name, ID and secret
export CLIENT_NAME=$(gcloud alpha iap oauth-clients list \
projects/$PROJECT_NUMBER/brands/$PROJECT_NUMBER --format='value(name)' \
--filter="displayName:iap-demo")

export CLIENT_ID=${CLIENT_NAME##*/}

export CLIENT_SECRET=$(gcloud alpha iap oauth-clients describe $CLIENT_NAME --format='value(secret)')


echo $CLIENT_NAME
echo $CLIENT_ID
echo $CLIENT_SECRET


# IAP screen gives this message: Use external identities for authorization
# NOTE: there are GCP URLs in this file. Their purpose is to show you where the resources you created are. Put your GCP project id after "&project=". 
# You can do find and replace across the whole file.
# https://console.cloud.google.com/security/iap?tab=applications&project=adswerve-bigquery-training

# ATTENTION: MANUAL STEP
# Navigate to the OAuth consent screen in the Cloud Console
# Click MAKE EXTERNAL under User Type
# Select Testing as the Publishing status

# https://console.cloud.google.com/apis/credentials/consent?authuser=0&project=adswerve-bigquery-training

############################################################################################
# PART 5: RESTRICTING ACCESS WITH IAP
############################################################################################
# https://codelabs.developers.google.com/secure-serverless-application-with-identity-aware-proxy?hl=en#5

# Enable IAP on the backend service
gcloud iap web enable --resource-type=backend-services \
    --oauth2-client-id=$CLIENT_ID \
    --oauth2-client-secret=$CLIENT_SECRET \
    --service=demo-iap-backend
# WARNING: IAP has been enabled for a backend service that does not use HTTPS. Data sent from the Load Balancer to your VM will not be encrypted.
# WARNING: IAP only protects requests that go through the Cloud Load Balancer. See the IAP documentation for important security best practices: https://cloud.google.com/iap/.


# List all reserved IP addresses and filter for the one named "demo-iap-ip"
ip_info=$(gcloud compute addresses list --filter="name=demo-iap-ip" --format="get(address)")

# Check if the IP address was found
if [ -z "$ip_info" ]; then
    echo "No IP address found with the name 'demo-iap-ip'"
    exit 1
fi

# Save the IP address into a variable
ip=$ip_info

# Print the IP address to verify
echo "The IP address for 'demo-iap-ip' is: $ip"

# Get service URL
# This will be the URL for your Clud Run service
echo https://$ip.nip.io
# Example
# https://34.117.116.251.nip.io
# You can also obtain this URL manually
    # Search "IP Address" in GCP console, in the search field
    # Find the IP address you reserved
    # append .nip.io to your ip address

# Verify the SSL certificate is ACTIVE
gcloud compute ssl-certificates list --format='value(MANAGED_STATUS)'    
# Note: Wait for the status to show as ACTIVE before moving forward. This process can take up to 60 minutes.
# In my testing, it took about 7-30 mins
# You can also verify that it's active in GCP UI:
# https://console.cloud.google.com/net-services/loadbalancing/advanced/sslCertificates/details/demo-iap-cert?q=search&referrer=search&project=adswerve-bigquery-training

# Add an IAM policy binding for the role of 'roles/iap.httpsResourceAccessor' for the user created in the previous step

echo $USER_EMAIL

gcloud iap web add-iam-policy-binding \
    --resource-type=backend-services \
    --service=demo-iap-backend \
    --member=user:$USER_EMAIL \
    --role='roles/iap.httpsResourceAccessor'

# Note: It takes 5-7 minutes for the changes to take effect. If you are presented with the sign in prompt wait and retry.

# if you get this error
# The IAP service account is not provisioned. Please follow the instructions to create service account and rectify IAP and Cloud Run setup: https://cloud.google.com/iap/docs/enabling-cloud-run
# then try this
gcloud beta services identity create --service=iap.googleapis.com --project=$PROJECT_ID

# if you get this error: 
# This site can’t provide a secure connection
# 34.117.32.167.nip.io uses an unsupported protocol.
# then wait a couple of mins


export USER_EMAIL=teamap@adswerve.com

echo $USER_EMAIL

gcloud iap web add-iam-policy-binding \
    --resource-type=backend-services \
    --service=demo-iap-backend \
    --member=user:$USER_EMAIL \
    --role='roles/iap.httpsResourceAccessor'

# You can add user manually here:
# https://console.cloud.google.com/security/iap?referrer=search&project=adswerve-bigquery-training
# Click a checkbox next to "demo-iap-backend". 
# Click "Add prinipal"
# Add them a role "IAP-secured Web App User"

## add another user

export USER_EMAIL=firstname.lastname@domain.com

echo $USER_EMAIL

gcloud iap web add-iam-policy-binding \
    --resource-type=backend-services \
    --service=demo-iap-backend \
    --member=user:$USER_EMAIL \
    --role='roles/iap.httpsResourceAccessor'

############################################################################################
# PART 6: (OPTIONAL) CLEANUP
############################################################################################

terraform destroy

# Function to delete OAuth clients
delete_oauth_clients() {
    # Get the list of OAuth clients
    clients=$(gcloud alpha iap oauth-clients list projects/$PROJECT_NUMBER/brands/$PROJECT_NUMBER --format='value(name)')

    # Check if there are any clients
    if [ -z "$clients" ]; then
        echo "No OAuth clients found."
    else
        # Iterate through the clients and delete them
        while IFS= read -r client; do
            echo "Deleting OAuth client: $client"
            gcloud alpha iap oauth-clients delete "$client" --quiet
        done <<< "$clients"
    fi
}

# Delete OAuth clients
echo "Deleting OAuth clients..."
delete_oauth_clients


gcloud run services update $CLOUD_RUN_SERVICE \
    --ingress all \
    --region $REGION


# OAuth consent screen
# make sure it says "internal"
# https://console.cloud.google.com/apis/credentials/consent?referrer=search&project=adswerve-bigquery-training