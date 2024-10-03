I apologize for the oversight. You're right, I should have included all the links you provided. Here's an updated version of the README that includes all the links you originally provided:

# Securing Cloud Run Applications with Identity-Aware Proxy (IAP)

## Purpose

This project demonstrates how to secure a Google Cloud Run application using Identity-Aware Proxy (IAP). It provides a comprehensive solution for implementing robust identity management for Cloud Run apps.

## Key Benefits

- **Enhanced Security**: Implements strong authentication and authorization controls.
- **Simplified Access Management**: Centralizes user access control.
- **Cost-Efficient**: Leverages Google Cloud's IAP service without additional infrastructure.
- **User-Friendly**: Provides a seamless authentication experience for end-users.
- **Scalable**: Easily adaptable to growing application needs.

## Target Audience

Developers and cloud architects looking to implement secure access controls for their Cloud Run applications.

## Prerequisites

- Google Cloud Platform (GCP) account with billing enabled
- `gcloud` CLI installed and configured
- Terraform installed
- Owner role or necessary permissions in the GCP project

## Project Structure

```
.
├── cloud_run_app/        # Sample Cloud Run application (optional)
│   ├── deploy.sh
│   └── cloud_run.sh
├── iap/
│   ├── main.tf           # Terraform configuration for IAP setup
│   └── iap.sh            # Shell script for IAP configuration
└── README.md
```

## Setup Instructions

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

- Some steps in the IAP setup process require manual intervention. Pay close attention to the comments in `iap.sh`.
- The SSL certificate provisioning can take up to 60 minutes. Be patient during this step.
- After making changes, it may take 5-7 minutes for them to take effect.

## Troubleshooting

- If you encounter issues with the IAP service account, follow the instructions provided in the error message to create the necessary service account.
- For SSL-related errors, ensure that the certificate is in an ACTIVE state before proceeding.

## Cleanup

To remove the IAP configuration and revert changes:

1. Run `terraform destroy` in the `iap` directory.
2. Execute the cleanup commands provided in the "CLEANUP" section of `iap.sh`.

## Additional Resources

- [IAP for Cloud Run Tutorial](https://codelabs.developers.google.com/secure-serverless-application-with-identity-aware-proxy)
- [IAP Overview Video](https://www.youtube.com/watch?v=ayTGOuCaxuc)
- [Cloud Run Deployment Guide](https://cloud.google.com/run/docs/quickstarts/build-and-deploy/deploy-python-service)
- [Deploying Streamlit Web App to Google Cloud Run](https://medium.com/google-cloud/how-to-deploy-your-streamlit-web-app-to-google-cloud-run-with-ease-c9f044aabc12)
- [Google Cloud Platform DevRel Demos](https://github.com/GoogleCloudPlatform/devrel-demos/tree/main/ai-ml/gemini-chatbot-app/lesson01)
- [Google Cloud Run Quickstart](https://cloud.google.com/run/docs/quickstarts/build-and-deploy/deploy-python-service)
- [gcloud run deploy Reference](https://cloud.google.com/sdk/gcloud/reference/run/deploy)

## Permissions

This project requires Owner role in the GCP project due to the numerous resources created. If Owner access is not possible, a list of required predefined roles can be compiled upon request.

## Contributing

Contributions to improve this project are welcome. Please submit pull requests or open issues for any enhancements or bug fixes.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

Citations:
[1] https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/28411965/7cdc8598-4511-4ca0-ae55-42ca6359df55/iap.sh
[2] https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/28411965/f0d46360-d496-4734-9299-ba8c510733c1/main.tf
[3] https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/28411965/410fc601-9aa2-41b9-b610-163510d07b0b/README.md