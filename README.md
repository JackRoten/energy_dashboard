# USA Energy Usage Dashboard
WIP: Simple webapp that pulls data from EIA and displays data in a dashboard.

### First look at initial dashboard containing color differentiation based on number of energy units


## Setup Instructions:
Request EIA api key from: weblink. Will be sent via email.

### Clone repo
```
git clone ssh command
cd  energy_dashboard
```

### Install python package manager
```
pip install uv
uv init 
# To test a file without pip installing 
uv run path/to/file.py
```

### Terraform 
```
terraform init # init terraform
terraform plan # This shows what will change
terraform apply -var "eia_api_key=EIA_API_KEY" -auto-approve
terraform apply -auto-approve # This applies configed terraform
```

### Infra Diagram
![alt text](https://github.com/JackRoten/energy_dashboard/blob/main/images/energy_dashboard.jpg "Infra Diagram")
