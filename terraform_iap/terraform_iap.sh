
############################################################################################
# PART 1: SET UP
############################################################################################
gcloud auth application-default login

export GCLOUD_CONFIGURATION=as-dev-ga4-flattener
export PROJECT_ID=as-dev-ga4-flattener-320623

gcloud config configurations activate $GCLOUD_CONFIGURATION
gcloud auth application-default set-quota-project $PROJECT_ID


export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
export REGION=us-central1
export CLOUD_RUN_SERVICE=cloud-run-service


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

cd terraform_iap

ls -a

terraform init

# terraform import google_cloud_run_service.default projects/as-dev-ga4-flattener-320623/locations/us-central1/services/cloud-run-service
#  Error: Cannot import non-existent remote object

terraform plan

terraform apply

terraform destroy


############################################################################################
# PART 4: ENABLING CLOUD IDENTITY-AWARE PROXY (IAP) ON THE LOAD BALANCER
############################################################################################
# https://codelabs.developers.google.com/secure-serverless-application-with-identity-aware-proxy?hl=en#4

export USER_EMAIL=$(gcloud config list account --format "value(core.account)")

echo $USER_EMAIL

# create an OAuth consent screen 
# gcloud alpha iap oauth-brands create \
#     --application_title="demo" \
#     --support_email=$USER_EMAIL
# ERROR: (gcloud.alpha.iap.oauth-brands.create) Resource in projects [adswerve-ts-team-sandbox] is the subject of a conflict: Requested entity already exists

gcloud alpha iap oauth-brands list    

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
# https://console.cloud.google.com/security/iap?tab=applications&project=as-dev-ga4-flattener-320623
# Navigate to the OAuth consent screen in the Cloud Console
# Click MAKE EXTERNAL under User Type
# Select Testing as the Publishing status
# https://console.cloud.google.com/apis/credentials/consent?authuser=0&project=as-dev-ga4-flattener-320623

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
echo https://$ip.nip.io

# Verify the SSL certificate is ACTIVE
gcloud compute ssl-certificates list --format='value(MANAGED_STATUS)'    
# Note: Wait for the status to show as ACTIVE before moving forward. This process can take up to 60 minutes.
# In my testing, it took about 7-30 mins

# Add an IAM policy binding for the role of 'roles/iap.httpsResourceAccessor' for the user created in the previous step

gcloud iap web add-iam-policy-binding \
    --resource-type=backend-services \
    --service=demo-iap-backend \
    --member=user:$USER_EMAIL \
    --role='roles/iap.httpsResourceAccessor'

# Note: It takes 5-7 minutes for the changes to take effect. If you are presented with the sign in prompt wait and retry.

# The IAP service account is not provisioned. Please follow the instructions to create service account and rectify IAP and Cloud Run setup: https://cloud.google.com/iap/docs/enabling-cloud-run

gcloud beta services identity create --service=iap.googleapis.com --project=$PROJECT_ID

export USER_EMAIL=teamap@adswerve.com

echo $USER_EMAIL

gcloud iap web add-iam-policy-binding \
    --resource-type=backend-services \
    --service=demo-iap-backend \
    --member=user:$USER_EMAIL \
    --role='roles/iap.httpsResourceAccessor'

# https://console.cloud.google.com/security/iap?referrer=search&project=as-dev-ga4-flattener-320623







