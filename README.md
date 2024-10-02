# Cloud Run and IAP (Identity-Aware Proxy)

## Purpose
Secure a Cloud Run application with IAP.

## Value
This solution provides Identity management for a Cloud Run app, whhich is:
- Safe
- Secure
- Simple to use
- Centralized
- Cost-efficient

## Audience:
A developer who wants to secure their Cloud Run app. 

## IAP

Tutorial (source for the IAP code in this repo): 
https://codelabs.developers.google.com/secure-serverless-application-with-identity-aware-proxy?hl=en#0. 

Video on IAP: 
https://www.youtube.com/watch?v=ayTGOuCaxuc

## About deploying a Cloud Run service

(source for the code in this repo)
https://medium.com/google-cloud/how-to-deploy-your-streamlit-web-app-to-google-cloud-run-with-ease-c9f044aabc12

(source for the code in this repo)
https://github.com/GoogleCloudPlatform/devrel-demos/tree/main/ai-ml/gemini-chatbot-app/lesson01

https://cloud.google.com/run/docs/quickstarts/build-and-deploy/deploy-python-service

https://cloud.google.com/sdk/gcloud/reference/run/deploy



## If you do not have a Cloud Run app and want one for testing:

Please use the files in the `cloud_run_app` directory.

In the `deploy.sh` file, set up your `PROJECT_ID` and `LOCATION` variables.

In the `cloud_run.sh` file, set up your `PROJECT_ID` and `GCLOUD_CONFIGURATION` variables.

After that, run all the commands one at a time in the `cloud_run.sh` file.

This will deploy a test Cloud Run app. 

Source for the test app: 
https://medium.com/google-cloud/how-to-deploy-your-streamlit-web-app-to-google-cloud-run-with-ease-c9f044aabc12

## Securing your Cloud Run app with IAP.

The files you need are in the `iap` dir.

In the `main.tf` file, set up your `project_id` var.

in the `iap.sh` file, set up the following vars:

```
export GCLOUD_CONFIGURATION=adswerve-bigquery-training
export PROJECT_ID=adswerve-bigquery-training
export REGION=us-central1
export CLOUD_RUN_SERVICE=cloud-run-service
```
After that, run all the commands one at a time in the `iap.sh` file.

This will secure your Cloud Run app.

Please read the comments in the file, as there are some manual steps.

Feel free to refer to this tutorial (source for the IAP code in this repo): 
https://codelabs.developers.google.com/secure-serverless-application-with-identity-aware-proxy?hl=en#0. 

## Permissions 

You need to be an Owner in the GCP project, because there are a lot of resources we would need to create in the project.

If Owner is not possible, then we can put together a list of Predefined roles needed. 