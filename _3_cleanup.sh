#!/bin/bash

# limitation: we are not deleting OAuth consent screen app. Change it back to INTERNAL manually (optional)

# Set environment variables
export PROJECT_ID=adswerve-bigquery-training
export REGION=us-central1
export CLOUD_RUN_SERVICE=cloud-run-service


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

# Delete IAP OAuth brand
# gcloud alpha iap oauth-brands delete projects/$PROJECT_ID/brands/$PROJECT_NUMBER
# ERROR: (gcloud.alpha.iap.oauth-brands) Invalid choice: 'delete'.
# Maybe you meant:
#   gcloud projects delete
#   gcloud iap oauth-brands create
#   gcloud iap oauth-brands describe
#   gcloud iap oauth-brands list
#   gcloud projects remove-iam-policy-binding
#   gcloud alpha projects search
#   gcloud iap oauth-clients delete
#   gcloud iap web remove-iam-policy-binding


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
# gcloud run services delete $CLOUD_RUN_SERVICE --region=$REGION --quiet

# open the Cloud Run service URL
gcloud run services update $CLOUD_RUN_SERVICE \
    --ingress all \
    --region $REGION

# Disable services
gcloud services disable \
  iap.googleapis.com \
  cloudresourcemanager.googleapis.com \
  cloudidentity.googleapis.com \
  compute.googleapis.com

echo "Cleanup completed."
