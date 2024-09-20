# (Optional) Create and use virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install the application requirements
pip install -r requirements.txt

# Run the application
streamlit run streamlit_app.py --server.port 8080

# deploy to GCP
chmod +x deploy.sh

gcloud auth application-default login

gcloud config configurations list 

export PROJECT_ID=adswerve-bigquery-training
export GCLOUD_CONFIGURATION=adswerve-bigquery-training

echo "PROJECT_ID: $PROJECT_ID"
echo "GCLOUD_CONFIGURATION: $GCLOUD_CONFIGURATION"

gcloud auth application-default login
gcloud config configurations activate $GCLOUD_CONFIGURATION
gcloud auth application-default set-quota-project $PROJECT_ID
gcloud config configurations list

gcloud init

./deploy.sh



