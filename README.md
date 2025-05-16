# TF-AWS-Webapp

Terraform module composition to deploy infrastructure for hosing a web
application in AWS.

## Status

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/kohirens/aws-tf-s3-website/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/kohirens/aws-tf-s3-website/tree/main)

## Table of Contents

1. [Terraform](/docs/terraform.md)
   1. [Inputs](/docs/terraform.md#inputs)
2. Examples
   1. [01-website](/examples/01-website/main.tf)
   2. [02-webapp](/examples/02-webapp/main.tf)
   3. [03-ordered-cache-behavior](/examples/03-ordered-cache-behavior/main.tf)
3. [System Flow Diagram](/docs/tf-aws-webapp-flow.drawio.svg)

## Resource Details

The following resources will be made.

* ACM Certificate - A certificate to allow CloudFront to serve the website
  over HTTPS.
* CloudFront distribution - To allow caching content to reduce latency,
  multiple origins, and encryption in transit via HTTPS.
* S3 bucket - Serve as cloud storage for static content and assets for
  generating dynamic content.
* Lambda function - [Using a Lambda function URL] feature will allow it to be
  used as a CloudFront origin (backend) to serve dynamic content, with access
  to the S3 bucket to use as long-term storage.
* IAM inline S3 policy - Granting CloudFront direct access.
* IAM Role and Policy - Attached to the Lambda execution role, giving access to
  write to a CloudWatch log group and put/get objects from the S3 bucket.
* Route 53 hosted zone - Optionally deploy the zone for the website.
* Route 53 alias record - Directs traffic to the CloudFront distribution.

## Resource Dependency Order

1. S3 bucket inline policy depends on the Lambda function.
2. Cloudfront Distribution depends on the Lambda function as an origin.
3. Lambda function policy depends on CloudFront distribution ID.

### IAM Policy Details

This statement allows access from CloudFront only. You can block all public
access with this since the policy is a non-public policy.

There a several IAM policies in play. We'll try to clarify what each does.

#### Bucket Inline Policy

The [policy-bucket.json] is a non-public policy, so that all public access is
blocked. Furthermore, it is locked down to the Lambda service principal and only
Lambda functions listed as resources can get objects.

#### Lambda Inline Policy

The [policy-lambda.json] only allows the CloudFront service principal access to
the function. The distribution sit in front of this function and expects an
HTTP response to serve over HTTPS.

#### Lambda Role Managed Policy

This role has a policy on it to allow the lambda function to write CloudWatch
logs.

---

[Using a Lambda function URL]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DownloadDistS3AndCustomOrigins.html#concept_lambda_function_url
[policy-bucket.json]: files/policy-bucket.json
[policy-lambda.json]: files/policy-lambda.json
