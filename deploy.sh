#!/bin/bash
# Purpose: To deploy the App to Cloud Run.

# Google Cloud Project ID
PROJECT=as-dev-ga4-flattener-320623

# Google Cloud Region
LOCATION=us-central1

# Deploy app from source code
gcloud run deploy cloud-run-service --source . --region=$LOCATION --project=$PROJECT --allow-unauthenticated