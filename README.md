
# CI/CD with Terraform, Docker, and AWS

This project demonstrates a Continuous Integration/Continuous Deployment (CI/CD) pipeline using **Terraform**, **Docker**, and **AWS**. The pipeline automates the deployment of a Node.js application to an EC2 instance, leveraging AWS Elastic Container Registry (ECR) for Docker image storage. The application is built using Express.js, Dockerized, and deployed via GitHub Actions.

## Project Overview

This project includes the following components:

1. **Node.js Application (`app.js`)**: A simple Express.js application that serves a "Service is up and running" message.
2. **Dockerfile**: A Dockerfile to containerize the Node.js application.
3. **Terraform Configuration (`main.tf`)**: Terraform configuration to provision an EC2 instance on AWS and set up the necessary IAM roles, security groups, and key pairs.
4. **GitHub Actions Workflow (`deploy.yml`)**: A CI/CD pipeline using GitHub Actions to automate the deployment process.

## Prerequisites

- **AWS Account**: Ensure you have an AWS account with the necessary permissions to create EC2 instances, ECR repositories, and other resources.
- **GitHub Account**: A GitHub repository to store the project files and configure GitHub Actions.
- **Terraform**: Terraform must be installed locally for initial setup and execution.
- **Docker**: Docker must be installed on the local machine for building the Docker image.
- **AWS CLI**: AWS CLI must be installed and configured for interacting with AWS services.

## Project Structure

```plaintext
.
├── nodeapp/
│   ├── app.js          # Node.js application
│   └── Dockerfile      # Dockerfile to containerize the app
├── terraform/
│   ├── main.tf         # Terraform configuration for provisioning AWS resources
    └── variables.tf    # Terraform configuration for the variables
├── .github/
│   └── workflows/
│       └── deploy.yml  # GitHub Actions workflow for CI/CD
├── README.md           # Project documentation
└── package.json        # Node.js dependencies
```

## Setup

### 1. **Terraform Configuration**

The `main.tf` file contains the Terraform configuration to provision AWS resources:

- **EC2 Instance**: A `t3.micro` instance is created to run the Docker container.
- **IAM Role and Instance Profile**: An IAM role (`ec2-ecr-auth`) is created to allow the EC2 instance to authenticate with AWS ECR.
- **Security Group**: A security group is created with the following rules:
  - Port 22 (SSH) open for remote access.
  - Port 80 (HTTP) and 443 (HTTPS) open for application traffic.
- **Key Pair**: An AWS EC2 key pair is created to enable SSH access to the EC2 instance.

### 2. **Dockerfile**

The `Dockerfile` builds a Docker image for the Node.js application:

```dockerfile
FROM node:14
WORKDIR /usr/app
COPY package.json .
RUN npm install
COPY . .
EXPOSE 8080
CMD [ "node", "app.js" ]
```

- **Node.js**: The application is based on Node.js version 14.
- **Working Directory**: The working directory is set to `/usr/app` inside the container.
- **Dependencies**: The `package.json` file is copied, and `npm install` is run to install dependencies.
- **Expose Port**: Port 8080 is exposed for the application to listen on.
- **Run Command**: The application is started using `node app.js`.

### 3. **Node.js Application (`app.js`)**

The `app.js` file contains a simple Express.js server:

```javascript
const express = require("express");
const app = express();

app.get("/", (req, res) => {
    res.send("Service is up and running");
});

app.listen(8080, () => {
    console.log("Server is up");
});
```

- **Express.js**: A basic Express.js application that listens on port 8080 and serves a "Service is up and running" message.

### 4. **GitHub Actions Workflow (`deploy.yml`)**

The `deploy.yml` file defines a GitHub Actions workflow for the CI/CD pipeline:

#### Workflow Breakdown:

- **`deploy-infrastructure` Job**:
  - **Terraform Init**: Initializes Terraform with an S3 backend for storing the state file.
  - **Terraform Plan**: Creates an execution plan for provisioning AWS resources.
  - **Terraform Apply**: Applies the Terraform plan to provision the infrastructure.
  - **Outputs EC2 Public IP**: Retrieves and outputs the public IP of the EC2 instance.

- **`deploy-app` Job**:
  - **Ensure ECR Repository Exists**: Checks if the ECR repository exists, and creates it if necessary.
  - **Docker Image Build and Push**: Builds the Docker image and pushes it to AWS ECR.
  - **Deploy to EC2**: Connects to the EC2 instance via SSH, installs Docker, AWS CLI, and other dependencies, then pulls and runs the Docker container.

```yaml
name: CI/CD with terraform

on: [push, workflow_dispatch]

jobs:
  deploy-infrastructure:
    runs-on: ubuntu-latest
    steps:
      # Terraform steps to provision EC2 instance and related resources

  deploy-app:
    runs-on: ubuntu-latest
    needs: deploy-infrastructure
    steps:
      # Docker build, push, and EC2 deployment steps
```

## How to Use

### 1. **Set Up AWS Credentials**

Store your AWS credentials as GitHub Secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SSH_KEY_PRIVATE` (Private SSH key for EC2 access)
- `AWS_SSH_KEY_PUBLIC` (Public SSH key for EC2 access)
- `AWS_TF_STATE_BUCKET_NAME` (S3 bucket for Terraform state)

### 2. **Configure Terraform Variables**

Ensure the following variables are configured in the `terraform/main.tf` file or passed as input variables:

- `AWS_REGION`: The AWS region to deploy resources in.
- `AWS_SSH_KEY_PUBLIC`: Your public SSH key.
- `AWS_SSH_KEY_PRIVATE`: Your private SSH key.
- `AWS_TF_STATE_BUCKET_NAME`: The S3 bucket name for storing Terraform state.

### 3. **Push to GitHub**

Push the code to your GitHub repository. The workflow will trigger on every push to the repository and execute the CI/CD pipeline.

### 4. **Monitor Deployment**

- The GitHub Actions workflow will provision the infrastructure, build the Docker image, and deploy the application to the EC2 instance.
- You can monitor the progress in the **Actions** tab of your GitHub repository.

### 5. **Access the Application**

Once the deployment is complete, access the application by visiting the public IP of the EC2 instance in your browser.

```plaintext
http://<EC2_PUBLIC_IP>
```

You should see the message: "Service is up and running".

## Conclusion

This project demonstrates a fully automated CI/CD pipeline that provisions infrastructure with Terraform, builds and pushes Docker images to AWS ECR, and deploys the application to an EC2 instance. It integrates multiple AWS services and GitHub Actions to streamline the deployment process.
