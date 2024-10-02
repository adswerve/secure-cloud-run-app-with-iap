#!/bin/bash
# Purpose: To deploy the App to Cloud Run.

# Google Cloud Project ID
PROJECT_ID=adswerve-bigquery-training

# Google Cloud Region
LOCATION=us-central1

# Deploy app from source code
gcloud run deploy cloud-run-service --source . --region=$LOCATION --project=$PROJECT_ID --allow-unauthenticated