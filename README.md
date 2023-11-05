# AWS S3 Website Terraform Module

## Status

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/kohirens/aws-tf-s3-wesbite/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/kohirens/aws-tf-s3-wesbite/tree/main)

## Resource Details

The following resources will be made.

* ACM Certificate - An SSL certificate in the US-East-1 region for CloudFront.
* CloudFront distribution - To allow HTTPS and serve the static content from S3.
* S3 bucket - Playing the part of storage for the Lambda function to pull from.
* Lambda function - [Using a Lambda function URL] feature will allow it to be
  used as a CloudFront origin.
* IAM inline policy - On the S3 bucket to only allows the CloudFront
  Distribution.
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

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.46.0 |
| <a name="provider_aws.cloud_front"></a> [aws.cloud\_front](#provider\_aws.cloud\_front) | 4.46.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_acm_certificate_validation.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation) | resource |
| [aws_cloudfront_distribution.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_control.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_route53_record.acm_validations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.web_s3_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.web_hosted_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_s3_bucket.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_policy.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_versioning.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_website_configuration.web](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_website_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_validation_method"></a> [acm\_validation\_method](#input\_acm\_validation\_method) | ACM validation method | `string` | `"DNS"` | no |
| <a name="input_aws_account"></a> [aws\_account](#input\_aws\_account) | AWS account ID. | `number` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_cert_key_algorithm"></a> [cert\_key\_algorithm](#input\_cert\_key\_algorithm) | Certificate key algorithm and level. | `string` | `"EC_prime256v1"` | no |
| <a name="input_cf_acm_certificate_arn"></a> [cf\_acm\_certificate\_arn](#input\_cf\_acm\_certificate\_arn) | SSL certificate to use when viewing the site. | `string` | `null` | no |
| <a name="input_cf_allowed_methods"></a> [cf\_allowed\_methods](#input\_cf\_allowed\_methods) | HTTP method verbs like GET and POST. | `list(string)` | <pre>[<br>  "GET",<br>  "HEAD"<br>]</pre> | no |
| <a name="input_cf_cache_default_ttl"></a> [cf\_cache\_default\_ttl](#input\_cf\_cache\_default\_ttl) | Default cache life in seconds. | `number` | `3600` | no |
| <a name="input_cf_cache_max_ttl"></a> [cf\_cache\_max\_ttl](#input\_cf\_cache\_max\_ttl) | Max cache life in seconds. | `number` | `86400` | no |
| <a name="input_cf_cache_min_ttl"></a> [cf\_cache\_min\_ttl](#input\_cf\_cache\_min\_ttl) | Minimum cache life. | `string` | `0` | no |
| <a name="input_cf_cached_methods"></a> [cf\_cached\_methods](#input\_cf\_cached\_methods) | HTTP method verbs like GET and POST. | `list(string)` | <pre>[<br>  "GET",<br>  "HEAD"<br>]</pre> | no |
| <a name="input_cf_compress"></a> [cf\_compress](#input\_cf\_compress) | HTTP method verbs like GET and POST. | `bool` | `true` | no |
| <a name="input_cf_enabled"></a> [cf\_enabled](#input\_cf\_enabled) | Enable/Disable the distribution. | `bool` | `true` | no |
| <a name="input_cf_is_ipv6_enabled"></a> [cf\_is\_ipv6\_enabled](#input\_cf\_is\_ipv6\_enabled) | Enable IPv6. | `bool` | `true` | no |
| <a name="input_cf_locations"></a> [cf\_locations](#input\_cf\_locations) | Enable/Disable the distribution. | `list(string)` | <pre>[<br>  "US"<br>]</pre> | no |
| <a name="input_cf_minimum_protocol_version"></a> [cf\_minimum\_protocol\_version](#input\_cf\_minimum\_protocol\_version) | The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections.Can set to be one of [SSLv3 TLSv1 TLSv1\_2016 TLSv1.1\_2016 TLSv1.2\_2018 TLSv1.2\_2019 TLSv1.2\_2021], see options here https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/secure-connections-supported-viewer-protocols-ciphers.html | `string` | `"TLSv1.2_2021"` | no |
| <a name="input_cf_price_class"></a> [cf\_price\_class](#input\_cf\_price\_class) | Options are [PriceClass\_All, PriceClass\_200, PriceClass\_100], see https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html. | `string` | `"PriceClass_100"` | no |
| <a name="input_cf_region"></a> [cf\_region](#input\_cf\_region) | The regions where CloudFront expects your ACM certificate. | `string` | `"us-east-1"` | no |
| <a name="input_cf_restriction_type"></a> [cf\_restriction\_type](#input\_cf\_restriction\_type) | GEO location restrictions. | `string` | `"whitelist"` | no |
| <a name="input_cf_retain_on_delete"></a> [cf\_retain\_on\_delete](#input\_cf\_retain\_on\_delete) | False to delete the distribution on destroy, and true to disable it. | `bool` | `false` | no |
| <a name="input_cf_ssl_support_method"></a> [cf\_ssl\_support\_method](#input\_cf\_ssl\_support\_method) | Specifies how you want CloudFront to serve HTTPS requests. One of `vip` or `sni-only`. Required if you specify acm\_certificate\_arn or iam\_certificate\_id. NOTE: vip causes CloudFront to use a dedicated IP address and may incur extra charges. | `string` | `"sni-only"` | no |
| <a name="input_cf_wait_for_deployment"></a> [cf\_wait\_for\_deployment](#input\_cf\_wait\_for\_deployment) | Wait for the CloudFront Distribution status to change from `Inprogress` to `Deployed`. | `bool` | `true` | no |
| <a name="input_cloudfront_default_certificate"></a> [cloudfront\_default\_certificate](#input\_cloudfront\_default\_certificate) | When you want viewers to use HTTPS to request your objects and you're using the CloudFront domain name for your distribution. | `bool` | `false` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The website domain name, for example: test.example.com. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Designated environment label, for example: prod, beta, test, non-prod, etc. | `string` | n/a | yes |
| <a name="input_error_page"></a> [error\_page](#input\_error\_page) | Error page for 4xx HTTP status errors. | `string` | `"400.html"` | no |
| <a name="input_evaluate_target_health"></a> [evaluate\_target\_health](#input\_evaluate\_target\_health) | Evaluate the health of the alis. Required if record type is "A". | `bool` | `false` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | force bucket destruction | `bool` | `true` | no |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | Use an existing hosted zone to add an A record for the `domain_name`. When this is set, it will skip making a new hosted zone for the domain\_name. | `string` | `null` | no |
| <a name="input_index_page"></a> [index\_page](#input\_index\_page) | Index page. | `string` | `"index.html"` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | Set to true to Enable versioning, false otherwise. | `bool` | `false` | no |
| <a name="input_viewer_protocol_policy"></a> [viewer\_protocol\_policy](#input\_viewer\_protocol\_policy) | to be one of [allow-all https-only redirect-to-https]. | `string` | `"redirect-to-https"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The ARN of the bucket. |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | The bucket domain name. |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | The bucket region-specific domain name. The bucket domain name including the region name, please refer here for format. Note: The AWS CloudFront allows specifying S3 region-specific endpoint when creating S3 origin, it will prevent redirect issues from CloudFront to S3 Origin URL. |
| <a name="output_bucket_website_domain"></a> [bucket\_website\_domain](#output\_bucket\_website\_domain) | The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. Use this when making a Route 53 alias record. |
| <a name="output_bucket_website_endpoint"></a> [bucket\_website\_endpoint](#output\_bucket\_website\_endpoint) | The website endpoint, if the bucket is configured with a website. If not, this will be an empty string. |
| <a name="output_bucket_website_hosted_zone_id"></a> [bucket\_website\_hosted\_zone\_id](#output\_bucket\_website\_hosted\_zone\_id) | The Route 53 Hosted Zone ID for this bucket's region. |
| <a name="output_certificate_arn"></a> [certificate\_arn](#output\_certificate\_arn) | ACM certificate ARN |
| <a name="output_cf_distribution_domain_name"></a> [cf\_distribution\_domain\_name](#output\_cf\_distribution\_domain\_name) | CloudFront distribution domain name |
| <a name="output_cf_distribution_hosted_zone_id"></a> [cf\_distribution\_hosted\_zone\_id](#output\_cf\_distribution\_hosted\_zone\_id) | Hosted zone ID of the CloudFront distribution |
| <a name="output_cf_distribution_id"></a> [cf\_distribution\_id](#output\_cf\_distribution\_id) | ID of the CloudFront distribution |
| <a name="output_cf_distribution_status"></a> [cf\_distribution\_status](#output\_cf\_distribution\_status) | Status of the CloudFront distribution |
| <a name="output_dvo_list"></a> [dvo\_list](#output\_dvo\_list) | Domain validation list |
| <a name="output_fqdn"></a> [fqdn](#output\_fqdn) | The FQDN pointint to the CloudFront distribution |
| <a name="output_hosted_zone"></a> [hosted\_zone](#output\_hosted\_zone) | Name of the Route 53 zone containing the CloudFront Alias record |
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | ID of the Route 53 zone containing the CloudFront Alias record |
| <a name="output_hosted_zone_ns"></a> [hosted\_zone\_ns](#output\_hosted\_zone\_ns) | Route 53 zone |
<!-- END_TF_DOCS -->

---

[Using a Lambda function URL]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/DownloadDistS3AndCustomOrigins.html#concept_lambda_function_url
[policy-bucket.json]: policy-bucket.json
[policy-lambda.json]: policy-lambda.json
