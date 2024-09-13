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

gcloud init

./deploy.sh



