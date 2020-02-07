# Terraform boilerplate for GCP VM.

Terraform config that creates a basic GCP VM that host a nginx server. This project is meant to be used as a boilerplate only.

### Requirement 

- Install [terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)

### Steps

#### Step 1: Create Service Account

Visit [Google Console](https://console.cloud.google.com/iam-admin/serviceaccounts) to create a service account.
Download the created key (json) `gcloud-service.json` and place it in root folder.

#### Step 2: Customize your VM

Create `terraform.tfvars` on root folder. For example.

```
gcp_project       = "gcp-project-1234"
gcp_website_image = "nginx:latest"
```

#### Step 3: Push to Google could

Run these commands
```
terraform init
terraform plan
terraform apply
```

#### Step 4: Update DNS

Update DNS config of the domain by added a new `A` record with the `ip` printed while running `terraform apply` on `step 3`.
