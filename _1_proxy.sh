

# https://cloud.google.com/run/docs/authenticating/public#gcloud
# https://cloud.google.com/sdk/gcloud/reference/run/services/update


export CLOUD_RUN_SERVICE=cloud-run-service
export REGION=us-central1

# --no-allow-unauthenticated

gcloud run services remove-iam-policy-binding $CLOUD_RUN_SERVICE \
    --member="allUsers" \
    --role="roles/run.invoker" \
    --region=$REGION

gcloud run services add-iam-policy-binding $CLOUD_RUN_SERVICE \
    --member="allAuthenticatedUsers" \
    --role="roles/run.invoker" \
    --region=$REGION


# --allow-unauthenticated
gcloud run services add-iam-policy-binding $CLOUD_RUN_SERVICE  \
    --member="allUsers" \
    --role="roles/run.invoker" \
    --region=$REGION

gcloud run services proxy $CLOUD_RUN_SERVICE --port=8080  --region=$REGION