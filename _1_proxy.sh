

# https://cloud.google.com/run/docs/authenticating/public#gcloud
# https://cloud.google.com/sdk/gcloud/reference/run/services/update


export GCLOUD_CONFIGURATION=adswerve-bigquery-training
export PROJECT_ID=adswerve-bigquery-training
export CLOUD_RUN_SERVICE=cloud-run-service
export REGION=us-central1

gcloud config configurations activate $GCLOUD_CONFIGURATION
gcloud auth application-default set-quota-project $PROJECT_ID

gcloud config configurations list

# --no-allow-unauthenticated

gcloud run services remove-iam-policy-binding $CLOUD_RUN_SERVICE \
    --member="allUsers" \
    --role="roles/run.invoker" \
    --region=$REGION

# this is not needed
# gcloud run services add-iam-policy-binding $CLOUD_RUN_SERVICE \
#     --member="allAuthenticatedUsers" \
#     --role="roles/run.invoker" \
#     --region=$REGION
# wait for 1-2 mins for this to kick

# --allow-unauthenticated
gcloud run services add-iam-policy-binding $CLOUD_RUN_SERVICE  \
    --member="allUsers" \
    --role="roles/run.invoker" \
    --region=$REGION

# this is not needed
# gcloud run services remove-iam-policy-binding $CLOUD_RUN_SERVICE \
#     --member="allAuthenticatedUsers" \
#     --role="roles/run.invoker" \
#     --region=$REGION

# https://cloud.google.com/sdk/gcloud/reference/run/services/proxy
gcloud run services proxy $CLOUD_RUN_SERVICE --port=8080  --region=$REGION


# DESCRIPTION
# Runs a server on localhost that proxies requests to the specified Cloud Run Service with credentials attached.
# You can use this to test services protected with IAM authentication.

# if the Cloud Run Service is configured to only allow internal ingress, this command will not work from outside the service's VPC network.
