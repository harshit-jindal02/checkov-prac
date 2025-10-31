# Terraform EC2 & S3 Module with Checkov Pipeline

This project contains a simple Terraform module to create an EC2 instance and an S3 bucket. It also includes a GitHub Actions workflow that demonstrates a best-practice CI/CD pipeline.

The pipeline will:
1.  Initialize and validate the Terraform code.
2.  Run **Checkov** to scan the code for security misconfigurations.
3.  Configure AWS credentials using OIDC (recommended).
4.  Generate a `terraform plan`.
5.  On a push to `main`, it will automatically `terraform apply` the changes.

## What is Checkov?

Checkov is a static analysis tool for Infrastructure as Code (IaC). Think of it as a spell-checker, but for security and best practices.

It scans your configuration files (like Terraform, CloudFormation, Kubernetes, etc.) and checks them against a huge library of pre-built policies. These policies cover best practices from cloud providers (like AWS, GCP, Azure), industry standards (like CIS Benchmarks), and compliance regulations (like HIPAA, GDPR).

## How Does it Work?

Checkov reads your `.tf` files and parses the resources you've defined (e.g., `aws_instance`, `aws_s3_bucket`). It then compares the settings of those resources against its policy list.

For example, a Checkov policy might be: "Ensure S3 bucket versioning is enabled." It will scan your `aws_s3_bucket` resource, see if `versioning { enabled = true }` is set, and pass or fail that check.

## What Will Checkov Do in Your Pipeline?

In the provided `terraform-pipeline.yml`, Checkov is a specific step that runs after `terraform validate` but before `terraform plan`.

Here's exactly what it will do:

1.  **Scan:** It will scan all the Terraform files in your repository.
2.  **Find Issues:** It will *definitely* find issues with the simple module in this repo, because we haven't added logging, versioning, or encryption to the S3 bucket. This is intentional, so you can see it work!
    * **For the S3 Bucket:** It will likely fail checks like:
        * `CKV_AWS_18: "Ensure S3 bucket logging is enabled"`
        * `CKV_AWS_19: "Ensure S3 bucket has server-side encryption enabled"`
        * `CKV_AWS_21: "Ensure S3 bucket has versioning enabled"`
        * `CKV_AWS_145: "Ensure S3 bucket does not have public read access"`
    * **For the EC2 Instance:** It might fail checks like:
        * `CKV_AWS_8: "Ensure EBS volumes are encrypted"`
        * `CKV_AWS_88: "Ensure EC2 instance is not using default security group"`
3.  **Report (Soft Fail):** You asked for a "soft fail scanner," and we've configured exactly that with `soft_fail: true`.
    * This means Checkov **will report all its findings** in the GitHub Actions log.
    * It will **NOT** stop the pipeline. The pipeline will continue to the `terraform plan` step.
    * This is perfect for *auditing* and *learning*. You can see the potential issues without blocking your deployment. If you wanted to be strict, you would set `soft_fail: false`, which would stop the pipeline if any issues are found.

## Setup Instructions

1.  **Push to GitHub:** Create a new GitHub repository and push all these files to it.
2.  **Set up AWS OIDC:** The pipeline uses OIDC to securely authenticate with AWS without needing long-lived access keys. This is the modern best practice.
    * Follow this guide to set up the OIDC provider in your AWS account and create an IAM Role for GitHub Actions: [AWS Docs: Configuring OIDC](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)
    * The IAM Role you create will need permissions to create EC2 instances, S3 buckets, and any other resources in your Terraform files.
3.  **Update Workflow File:** Open `.github/workflows/terraform-pipeline.yml` and replace `YOUR_AWS_ACCOUNT_ID` and `YOUR_GITHUB_ACTIONS_ROLE_NAME` with your actual AWS Account ID and the name of the IAM role you just created.
4.  **(Optional but Recommended) Set up Terraform Backend:** For a real project, you should use a remote backend (like an S3 bucket) to store your Terraform state file. I've left a commented-out example in the root `main.tf`.

That's it! When you push your code or open a Pull Request, the pipeline will automatically run, scan your code with Checkov, and show you the plan.