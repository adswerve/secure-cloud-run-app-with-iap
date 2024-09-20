#!/bin/bash
# Purpose: To deploy the App to Cloud Run.

# Google Cloud Project ID
PROJECT=adswerve-bigquery-training

# Google Cloud Region
LOCATION=us-central1

# Deploy app from source code
gcloud run deploy cloud-run-service --source . --region=$LOCATION --project=$PROJECT --allow-unauthenticated