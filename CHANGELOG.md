# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.0.4]

### Changed

- Add Variable Conditions

### Regular Maintenance

- Removed SSH Fingerprint From CI

## [3.0.3]

### Fixed

- Terraform Resource Path Changed

### Regular Maintenance

- Add Note for GH_TOKEN Environment Variable

### Removed

- Unused Variables

## [3.0.2]

### Fixed

- Post Tag Artifact Upload

## [3.0.1]

### Removed

- Providers

## [3.0.0]

### Added

- Sh Provider for Lambda Environment Variables
- Sh Provider for Lambda Environment Variables
- Example For Ordered Cache Behavior
- Condition To Variable
- Added Lambda Resource Policy
- Missing Build Dependency for AWS Lambda

### Changed

- Project Name
- CloudFront Resource Dependencies
- Updated Terraform Documentation
- Optimize S3 Origin Cache Policy
- Allow Lambda S3 Put
- Set S3 Origin Behavior Cahce Policy
- Upgrade CloudFront Function Runtime
- Handle POST & PUT To Lambda Backend
- Upgrade Lambda Module Version
- Handling of Origin and Ordered Policies
- Replaced Allowed HTTP Method Variable
- Origin and Ordered Cache Bahavior Handling
- Add OAC From Cloudfront To lambda
- List S3 Bucket Origin

### Fixed

- Add Required Providers
- No Logs in CloudWatch for Lambda Function
- Lamda Module Download Permissions.
- CloudFront Default Befavior and Others

### Regular Maintenance

- Add missing resource
- Fix Test
- Upgraded Auto Version Release
- Cleanup
- Fixed Broken Test
- Clean Up Broken Unit Test
- Fixed Unit Test 03
- Change the Cache Behaviors for Test
- Clean-up
- Renamed Dependency Handle
- Upgraded CI Version Release
- Update Unit tests
- Upgrade Development Container
- Add jq To Terraform Container
- Added Execution Bit To Script
- Use OICD for CircleCI
- Upgrade Go Build Image
- Renamed wait-for-dna-resolve.sh

### Removed

- Deploy Hosted Zone
- Authorization Code
- Unused Local Variable
- Provisioner Script
- Reference To Unused Variable
- Go Package stdlib.cli Dependency

<a name="unreleased"></a>
## [Unreleased]


<a name="2.1.0"></a>
## [2.1.0] - 2024-01-20
### Added
- Origin Path
- Set Additional Origins

### Changed
- To Origin For Alt Host Header
- Upgraded Kohirens Lambda Module
- Add Caching Policy To S3 Origin
- Updated Terraform Variable Documentation


<a name="2.0.0"></a>
## [2.0.0] - 2024-01-12
### Changed
- Upgraded Kohirens Lambda Module
- Variable Names
- Consolidate HTTP Allow Methods Variable


<a name="1.4.2"></a>
## [1.4.2] - 2024-01-12
### Changed
- Updated Documentation


<a name="1.4.1"></a>
## [1.4.1] - 2024-01-06
### Removed
- Body In OPTION Response


<a name="1.4.0"></a>
## [1.4.0] - 2024-01-05
### Added
- HTTP Method OPTIONS Response
- HTTP OPTIONS Method

### Changed
- Pass Allowed HTTP Methods To Lambda
- Simple HTTP Responder Allowed HTTP Methods
- Pass Allowed HTTP Methods To Lambda


<a name="1.3.0"></a>
## [1.3.0] - 2023-12-31
### Added
- Asset Origin
- Bucket Policy


<a name="1.2.1"></a>
## [1.2.1] - 2023-12-06
### Fixed
- Loading Images


<a name="1.2.0"></a>
## [1.2.0] - 2023-12-05
### Added
- Move Policy Configuration
- Invoke Mode Variable
- Add Cache Policy Variables
- 501 Response
- Passing In Cache Behavior
- Wait For DNS Propagation
- Block Public Use Of Distribution Domain Name
- Unauthorize Distribution Domain Request
- CloudFront Function Viewer-Host Header
- Lambda Module Outputs
- Lambda Bucket Access
- Alternative Domain Names
- Required Code Variable
- Custom Header For CloudFront Origin
- Lambda Origin

### Changed
- Go Server Updates
- CF Viewer Request Modified
- Mask Auth Header Value In Logs
- Temporarily Disable Apex Redirects
- Set Compression On Cache Policy
- Cleanup Logging
- Upgraded Lambda Module
- Use Variable For Lambda Name
- Specify Distribution Dependencies.
- Resource Name
- Moved Resource
- Upgraded Kohirens Lambda Module
- CloudFront Distribution Origin ID
- Default Lambda Description
- Clean Up IAM Policies
- Upgraded Kohirens Lambda Module
- Remove Punctuation
- HTTP Response Media Types
- REQUIRED_CODE To Authorization Header
- Require HTTP Header
- Output "fqdn" Back To A String
- Set Lambda Origin Defaults
- Default To TLS version 1.2.
- Permission on Lambda Bootstrap
- Lambda Funcion Handler Signature

### Fixed
- HTTP 503 Codes
- Redirect Loop
- S3 Bucket Policy Delay
- Lambda Environment Vars Unintended Removal
- Provisioning Scripts
- Append Lambda Environment Variables
- Origin Policy
- CloudFront Origin
- Default Lambda Policy Path
- Lookup Managed Origin Request Policy
- Infrastructure Names
- Authorization Code Will Match
- Retrieving Request Headers
- Terraform Module Formatting
- 404 Response
- Content-Type Header in HTML Response
- Extracting Header From Request
- Redirect Loop
- Name Required
- Template Variable
- Lambda Function S3 Access
- 500 Page Typo
- Bucket Policy
- CloudFront Missing A CNAME
- Go Lambda Code Not Loading S3 Objects
- Error From Variable Default Value
- Missing Environment Variable
- Formatting
- CloudFront Distribution Origin Domain
- CloudFront Distribution Origin Domain
- CloudFront Custom Origin

### Removed
- Debugging Name Change
- S3 Bucket Inline Policy


<a name="1.1.0"></a>
## [1.1.0] - 2023-11-08
### Added
- CloudFron Variable cf_http_version

### Changed
- Renamed Resource
- Allow Overwriting Route53 Record

### Removed
- Unused S3 Website Resource


<a name="1.0.0"></a>
## [1.0.0] - 2023-01-04
### Added
- Resource Migration Capability
- Output for CloudFront Status
- Variable To Set CloudFront ACM Region
- CloudFront Distribution To Cover HTTPS
- Hosted Zone Name Servers
- versioning Variable To Toggle Versioning

### Changed
- Group and Label CF Distribution Dependencies
- Default To Force Destroy Bucket
- Line Endings in output.tf
- Updated Terraform Experimental Integration Tests
- Changed Output Names
- Ouput Names And Variable Default
- Renamed Page Variables
- Error Page Defaults
- Lookup Zone Alias
- Required Terraform 1.0.0
- Updated Code for Terraform Version 1.0 Compat

### Fixed
- Integration Tests
- S3 Upload Key for Test Fixture
- Website Alias Record
- Making S3 Alias For A Static Website
- Making S3 Alias For A Static Website
- Zone Name Output
- Deprecated Warnings
- Bucket Reference
- Index and Error Documents

### Removed
- Providers
- 1.0.0 tag
- Faulty Data Lookup


<a name="0.0.1"></a>
## 0.0.1 - 2021-05-16

[Unreleased]: https://github.com/kohirens/aws-tf-s3-wesbite.git/compare/2.1.0...HEAD
[2.1.0]: https://github.com/kohirens/aws-tf-s3-wesbite.git/compare/2.0.0...2.1.0
[2.0.0]: https://github.com/kohirens/aws-tf-s3-wesbite.git/compare/1.4.2...2.0.0
[1.4.2]: https://github.com/kohirens/aws-tf-s3-wesbite.git/compare/1.4.1...1.4.2
[1.4.1]: https://github.com/kohirens/aws-tf-s3-wesbite.git/compare/1.4.0...1.4.1
[1.4.0]: https://github.com/kohirens/aws-tf-s3-wesbite.git/compare/1.3.0...1.4.0
[1.3.0]: https://github.com/kohirens/aws-tf-s3-wesbite.git/compare/1.2.1...1.3.0
[1.2.1]: https://github.com/kohirens/aws-tf-s3-wesbite.git/compare/1.2.0...1.2.1
[1.2.0]: https://github.com/kohirens/aws-tf-s3-wesbite.git/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/kohirens/aws-tf-s3-wesbite.git/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/kohirens/aws-tf-s3-wesbite.git/compare/0.0.1...1.0.0
