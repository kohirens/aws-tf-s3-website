<a name="unreleased"></a>
## [Unreleased]


<a name="1.2.2"></a>
## [1.2.2] - 2023-12-09

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

[Unreleased]: https://github.com/kohirens/aws-tf-s3-wesbite.git/compare/1.2.2...HEAD
[1.2.2]: https://github.com/kohirens/aws-tf-s3-wesbite.git/compare/1.2.1...1.2.2
[1.2.1]: https://github.com/kohirens/aws-tf-s3-wesbite.git/compare/1.2.0...1.2.1
[1.2.0]: https://github.com/kohirens/aws-tf-s3-wesbite.git/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/kohirens/aws-tf-s3-wesbite.git/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/kohirens/aws-tf-s3-wesbite.git/compare/0.0.1...1.0.0
