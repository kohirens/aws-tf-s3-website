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

## High Level Overview

1. A web a browser is directed to your sites' domain in the form of a request.
2. Route53 returns some info and directs the request to a CloudFront
   distribution that is fronting your site.
3. CloudFront forwards the request to the origin:
    1. If its `static content` (the URL contains /assets/*), direct traffic to
       an S3 bucket.
    2. If it is dynamic (the URL contains /api/*), direct traffic to a Lambda
       function.

       NOTE: Only CloudFront has access to the S3 bucket and Lambda function;
       based on the default IAM policies provided.
4. A response is provided from the origin and sent back to the clients' browser.

   NOTE: If the response is for `static content`, it is cached by default at the
   edge. Which you can adjust by configuring CloudFront cache policies per
   origin behaviors.
5. The web browser displays the response.

While S3 is used for storage for `static content` files, it can also double as
storage for the Lambda, by default the Lambda function should have access. So
you can access content in S3 from the Lambda with an AWS SDK by default.

CloudFront can serve `static content` from cache whenever possible. But you'll
need to have a good understanding of how cache polices in CloudFront work.
If you're new, then it's best to disable any caching until you do.

## Setup Redirect Apex Domain with Lambda

If you'd like for your domain, for example `example.com` to redirect to
`www.example.com` or vice versa; then you can.

This can be achieved when using the deployed CloudFront distribution
and a Lambda origin running some code and also configuring the Terraform

NOTE: You are not limited to just Lambda, any backend which allows coding will
work.

1. Set up an alternative name for the apex domain, which will in turn set up a
   second origin on the CloudFront Distribution:
   ```terraform
    alt_domain_names = ["example.com"]
    domain_name      = "www.example.com"
    ```
   NOTE: Any values in the `alt_domain_names` list will be added to the
   "REDIRECT_HOSTS" environment variable as a comma separated list.
   You can also add an HTTP header "Redirect-Apex-To" and set that to the
   subdomain you want it to redirect to.
2. Update the Lambda function code to look for "viewer-host" header, this will
   contain the original domain the client came from. Check it against the
   "REDIRECT_HOSTS" environment value; if it is in that list, then perform a 301
   (or 308 for POST method) to the value in the environment variable
   "REDIRECT_TO."

   If you choose to use the code we provide for Lambda, then it already has
   this feature.

This method uses a combination of a CloudFront function to preserve the clients
original HTTP "Host" header value and a Lambda function take action based on
that value. Though you can achieve this with just a CloudFront Function, it
extends this visibility to your origin.

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
