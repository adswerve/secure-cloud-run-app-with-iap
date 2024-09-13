# https://codelabs.developers.google.com/secure-serverless-application-with-identity-aware-proxy?hl=en#0
# https://codelabs.developers.google.com/secure-serverless-application-with-identity-aware-proxy?hl=en#1

############################################################################################
# PART 1: SET UP
############################################################################################
export PROJECT_ID=adswerve-bigquery-training
export GCLOUD_CONFIGURATION=adswerve-bigquery-training
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
export REGION=us-central1
export CLOUD_RUN_SERVICE=cloud-run-service


# Log the values of the environment variables
echo "PROJECT_ID: $PROJECT_ID"
echo "GCLOUD_CONFIGURATION: $GCLOUD_CONFIGURATION"
echo "PROJECT_NUMBER: $PROJECT_NUMBER"
echo "REGION: $REGION"
echo "CLOUD_RUN_SERVICE: $CLOUD_RUN_SERVICE"


gcloud auth application-default login
gcloud config configurations activate $GCLOUD_CONFIGURATION
gcloud auth application-default set-quota-project $PROJECT_ID
gcloud config configurations list

gcloud services enable \
    iap.googleapis.com \
    cloudresourcemanager.googleapis.com \
    cloudidentity.googleapis.com \
    compute.googleapis.com


############################################################################################
# PART 2: CONFIGURING A SERVERLESS NETWORK ENDPOINT GROUP (NEG)
############################################################################################
# https://codelabs.developers.google.com/secure-serverless-application-with-identity-aware-proxy?hl=en#2
# https://cloud.google.com/load-balancing/docs/negs/serverless-neg-concepts?authuser=0

# 1. Create a network endpoint group for the employee UI service.
gcloud compute network-endpoint-groups create demo-iap-neg \
    --project $PROJECT_ID \
    --region=$REGION \
    --network-endpoint-type=serverless  \
    --cloud-run-service=$CLOUD_RUN_SERVICE
    
# https://console.cloud.google.com/compute/networkendpointgroups/list?referrer=search&project=adswerve-bigquery-training


# Create a backend service
gcloud compute backend-services create demo-iap-backend \
    --global 
# https://console.cloud.google.com/net-services/loadbalancing/list/backends?project=adswerve-bigquery-training

 # Add the serverless NEG as a backend to the backend service
gcloud compute backend-services add-backend demo-iap-backend \
    --global \
    --network-endpoint-group=demo-iap-neg \
    --network-endpoint-group-region=$REGION    

# Create a URL map to route incoming requests to the backend service
gcloud compute url-maps create demo-iap-url-map \
    --default-service demo-iap-backend   
# https://console.cloud.google.com/net-services/loadbalancing/details/http/demo-iap-url-map?project=adswerve-bigquery-training


############################################################################################
# PART 3: CONFIGURING THE LOAD BALANCER COMPONENTS
############################################################################################
# https://codelabs.developers.google.com/secure-serverless-application-with-identity-aware-proxy?hl=en#3

# Reserve an static IPv4 address and store the domain
gcloud compute addresses create demo-iap-ip \
    --network-tier=PREMIUM \
    --ip-version=IPV4 \
    --global
# https://console.cloud.google.com/networking/addresses/list?referrer=search&project=adswerve-bigquery-training    

# Store the nip.io domain
export DOMAIN=$(gcloud compute addresses list --filter demo-iap-ip --format='value(ADDRESS)').nip.io    

echo $DOMAIN
# 34.95.125.93.nip.io
# https://nip.io/


# Create a Google-managed SSL certificate resource
gcloud compute ssl-certificates create demo-iap-cert \
    --description=demo-iap-cert \
    --domains=$DOMAIN \
    --global

gcloud compute ssl-certificates list --format='value(MANAGED_STATUS)'
#  Provisioning a Google-managed certificate might take up to 60 minutes.

# Create the target HTTPS proxy to route requests to your URL map
gcloud compute target-https-proxies create demo-iap-http-proxy \
    --ssl-certificates demo-iap-cert \
    --url-map demo-iap-url-map

# Create a forwarding rule to route incoming requests to the proxy
gcloud compute forwarding-rules create demo-iap-forwarding-rule \
--load-balancing-scheme=EXTERNAL \
--network-tier=PREMIUM \
--address=demo-iap-ip \
--global \
--ports=443 \
--target-https-proxy demo-iap-http-proxy

# Restricting ingress to the Cloud Run service
gcloud run services update $CLOUD_RUN_SERVICE \
    --ingress internal-and-cloud-load-balancing \
    --region $REGION


# Click on the Service URL link
# codelab it should be forbidden. I'm getting a page not found
# Error: Page not found
# The requested URL was not found on this server.

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

# Verify the SSL certificate is ACTIVE
gcloud compute ssl-certificates list --format='value(MANAGED_STATUS)'    
# Note: Wait for the status to show as ACTIVE before moving forward. This process can take up to 60 minutes.
# In my testing, it took about 7-30 mins

# Get service URL
echo https://$DOMAIN
# https://34.95.125.93.nip.io


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

# https://console.cloud.google.com/security/iap?referrer=search&project=adswerve-bigquery-training

