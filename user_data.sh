#!/bin/bash
# Update packages
apt update -y
apt install -y git python3-pip

# Clone GitHub repo
cd /home/ubuntu
git clone https://github.com/ayyanar-vignesh/Updated_fastapi_automation_july21.git app
cd app

# Install required Python packages
pip3 install fastapi uvicorn boto3 python-dotenv jinja2 python-multipart bcrypt

# Run the FastAPI app in the background on port 8000
nohup uvicorn main:app --host 0.0.0.0 --port 8000 > fastapi.log 2>&1 &
