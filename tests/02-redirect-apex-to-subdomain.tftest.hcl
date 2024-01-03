provider "aws" {
  region = "us-east-1"
}

variables {
  iac_source = "terratest.fakehub.com"
}

run "execute" {
  variables {
    alt_domain_names   = ["terraform-02.test.kohirens.com"]
    aws_region         = "us-east-1"
    domain_name        = "www.terraform-02.test.kohirens.com"
    force_destroy      = true
    iac_source         = "github.com/kohirens/aws-tf-s3-website"
    lf_source_zip      = "./app/bootstrap.zip"
    cf_allowed_methods = ["GET", "HEAD", "OPTIONS"]
  }
}

run "verify_domain_redirect" {
  module {
    source = "./tests/02-redirect-apex"
  }

  variables {
    domain_name = run.execute.fqdn
  }

  assert {
    condition     = terraform_data.redirect_apex_to_www.output.status_code == "301"
    error_message = "the request resulted in a response code other than 301"
  }

  assert {
    condition     = terraform_data.www_no_redirect_loop.output.status_code == "200"
    error_message = "the request resulted in a response code other than 200"
  }

  assert {
    condition     = "hi world!" == terraform_data.www_no_redirect_loop.output.response_body
    error_message = "incorrect response body for the index.html page"
  }

  assert {
    condition     = strcontains(data.local_file.get_options.content, "allow: GET,HEAD,OPTIONS")
    error_message = "failed to get expected options status code"
  }
}