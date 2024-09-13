#!/bin/bash

# Set environment variables
export PROJECT_ID=adswerve-bigquery-training
export REGION=us-central1
export CLOUD_RUN_SERVICE=cloud-run-service

# Delete IAP OAuth client
CLIENT_NAME=$(gcloud alpha iap oauth-clients list projects/$PROJECT_ID/brands/$PROJECT_NUMBER --format='value(name)' --filter="displayName:iap-demo")
# ERROR: (gcloud.alpha.iap.oauth-clients.list) INVALID_ARGUMENT: Unable to parse project number and brand. Use following format: projects/{ProjectNumber|ProjectId}/brands/{brand}

echo $CLIENT_NAME

gcloud alpha iap oauth-clients delete $CLIENT_NAME

# Delete IAP OAuth brand
gcloud alpha iap oauth-brands delete projects/$PROJECT_ID/brands/$PROJECT_NUMBER

# Delete forwarding rule
gcloud compute forwarding-rules delete demo-iap-forwarding-rule --global --quiet

# Delete target HTTPS proxy
gcloud compute target-https-proxies delete demo-iap-http-proxy --quiet

# Delete SSL certificate
gcloud compute ssl-certificates delete demo-iap-cert --global --quiet

# Delete static IP address
gcloud compute addresses delete demo-iap-ip --global --quiet

# Delete URL map
gcloud compute url-maps delete demo-iap-url-map --quiet

# Delete backend service
gcloud compute backend-services delete demo-iap-backend --global --quiet

# Delete network endpoint group
gcloud compute network-endpoint-groups delete demo-iap-neg --region=$REGION --quiet

# Delete Cloud Run service
gcloud run services delete $CLOUD_RUN_SERVICE --region=$REGION --quiet

# Disable services
gcloud services disable \
  iap.googleapis.com \
  cloudresourcemanager.googleapis.com \
  cloudidentity.googleapis.com \
  compute.googleapis.com

echo "Cleanup completed."
