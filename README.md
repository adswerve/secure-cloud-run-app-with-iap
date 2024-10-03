Here's an improved and enhanced version of the README in markdown format:

# Securing Cloud Run Applications with Identity-Aware Proxy (IAP)

## Purpose

This project demonstrates how to secure a Google Cloud Run application using Identity-Aware Proxy (IAP). It provides a comprehensive solution for implementing robust identity management for Cloud Run apps.

## Key Benefits

- **Enhanced Security**: Implements strong authentication and authorization controls.
- **Simplified Access Management**: Centralizes user access control.
- **Cost-Efficient**: Leverages Google Cloud's IAP service with some additional infrastructure at low cost.
- **User-Friendly**: Provides a seamless authentication experience for end-users.
- **Scalable**: Easily adaptable to growing application needs.

## Target Audience

Developers and cloud architects looking to implement secure access controls for their Cloud Run applications.

## Prerequisites

- Google Cloud Platform (GCP) account with billing enabled
- `gcloud` CLI installed and configured
- Terraform installed. Please see the commmands in the `iap.sh` file which install Terraform. 
- Owner role or necessary permissions in the GCP project

## Project Structure

```
.
├── cloud_run_app/        # Sample Cloud Run application (optional)
│   ├── deploy.sh
│   └── cloud_run.sh
├── iap/
│   ├── main.tf           # Terraform configuration for IAP setup
│   └── iap.sh            # Shell script for IAP configuration and cleanup
├── proxy_demo/
│   └── proxy.sh          # Shell script setting up a proxy instead of IAP (optional)
├── tools/
│   └── cleanup.sh        # Shell script full gcloud cli cleanup (optional). It's recommended to cleanup using the terraform iap.sh script instead.
└── README.md
```

## Setup Instructions

### 0. Clone the repo

```
git clone https://github.com/adswerve/secure-cloud-run-app-with-iap

cd secure-cloud-run-app-with-iap
```


### 1. Deploying a Test Cloud Run Application (Optional)

If you don't have an existing Cloud Run app:

1. Navigate to the `cloud_run_app` directory.
2. Update `PROJECT_ID` and `LOCATION` in `deploy.sh`.
3. Update `PROJECT_ID` and `GCLOUD_CONFIGURATION` in `cloud_run.sh`.
4. Execute the commands in `cloud_run.sh` sequentially.

### 2. Securing Cloud Run with IAP

1. Navigate to the `iap` directory.
2. In `main.tf`, set your `project_id` variable.
3. In `iap.sh`, configure the following variables:
   ```sh
   export GCLOUD_CONFIGURATION=your-gcloud-config
   export PROJECT_ID=your-project-id
   export REGION=your-preferred-region
   export CLOUD_RUN_SERVICE=your-cloud-run-service-name
   ```
4. Execute the commands in `iap.sh` sequentially, following any manual steps as indicated in the comments.

## Important Notes

- Some steps in the IAP setup process require manual intervention. Pay close attention to the comments in `iap.sh`. Specifically, some steps requiring OAuth Consent Screen are manual. We need to set it to INTERNAL and then to EXTERNAL - Testing.
- Most of infrastructure deployment has been Terraformed. However, there are some steps which would require you to run some gcloud shell commmands. 
- The SSL certificate provisioning can take up to 60 minutes. Be patient during this step.
- After making changes to IAP permissions, it may take 5-7 minutes for them to take effect.

## Troubleshooting

- If you get this error: `The IAP service account is not provisioned. Please follow the instructions to create service account and rectify IAP and Cloud Run setup: https://cloud.google.com/iap/docs/enabling-cloud-run`. 
Try this:
`gcloud beta services identity create --service=iap.googleapis.com --project=$PROJECT_ID`

- For SSL-related issues, ensure that the certificate is in an ACTIVE state before proceeding.

## Cleanup

There are two options to remove the IAP configuration and infrastructure and revert changes:

Option A (recommended)

1. Run `terraform destroy` in the `iap` directory.
2. Execute the cleanup commands provided in the "CLEANUP" section of `iap.sh`.

Option B:

Run the commands in the `tools/cleanup.sh` file

## Quick Proxy Solution for Cloud Run

While not as secure or centralized as IAP, a quick alternative is to set up a proxy for your Cloud Run service.

### Setup Instructions

1. Navigate to the `proxy_demo` directory.
2. Open the `proxy.sh` file.
3. Execute the commands in `proxy.sh` sequentially.

### Considerations

- **Pros**: 
  - Faster to implement
  - Simpler configuration
- **Cons**:
  - Less secure than IAP
  - Lacks centralized management
  - May not be suitable for production environments

### When to Use

- For rapid prototyping
- In development environments
- When full IAP setup is not immediately feasible

**Note**: For production deployments, it's strongly recommended to use the full IAP solution described in the main setup instructions.
## Sources / credits for the code in this repo

### IAP

- [IAP for Cloud Run Tutorial](https://codelabs.developers.google.com/secure-serverless-application-with-identity-aware-proxy)

### Cloud Run
- [Deploying Streamlit Web App to Google Cloud Run](https://medium.com/google-cloud/how-to-deploy-your-streamlit-web-app-to-google-cloud-run-with-ease-c9f044aabc12)
- [Google Cloud Platform DevRel Demos](https://github.com/GoogleCloudPlatform/devrel-demos/tree/main/ai-ml/gemini-chatbot-app/lesson01)

## Additional Resources

### IAP
- [IAP Overview Video](https://www.youtube.com/watch?v=ayTGOuCaxuc)
### Cloud Run
- [Cloud Run Deployment Guide](https://cloud.google.com/run/docs/quickstarts/build-and-deploy/deploy-python-service)
- [Google Cloud Run Quickstart](https://cloud.google.com/run/docs/quickstarts/build-and-deploy/deploy-python-service)
- [gcloud run deploy Reference](https://cloud.google.com/sdk/gcloud/reference/run/deploy)

### Terraform
- [Install Terraform](https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli?in=terraform%2Fgcp-get-started)
- [Terraform GCP Quickstart](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started)


## Permissions

This project requires Owner role in the GCP project due to the numerous resources created. If Owner access is not possible, a list of required predefined roles can be compiled upon request.
