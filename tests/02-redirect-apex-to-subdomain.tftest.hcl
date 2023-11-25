provider "aws" {
  region = "us-east-1"
}

variables {
  iac_source = "terratest.fakehub.com"
}

run "execute" {
  variables {
    alt_domain_names = ["terraform-02.test.kohirens.com"]
    aws_region       = "us-east-1"
    domain_name      = "www.terraform-02.test.kohirens.com"
    force_destroy    = true
    iac_source       = "github.com/kohirens/aws-tf-s3-website"
    lf_source_zip    = "./app/bootstrap.zip"
  }
}

run "verify_function_url_with_arm64_al2_go_runtime" {
  module {
    source = "./tests/02-redirect-apex"
  }

  variables {
    cf_distribution_domain_name = run.execute.distribution_domain_name
    domain_name                 = run.execute.fqdn
  }

  assert {
    condition     = data.http.redirect_apex_to_www_01.status_code == 301
    error_message = "a request to the distribution domain url returned a response code other than 301"
  }

  assert {
    condition     = data.http.www_no_redirect_loop.status_code == 200
    error_message = "a request to the distribution domain url returned a response code other than 200"
  }

  assert {
    condition     = "hi world!" == data.http.www_no_redirect_loop.response_body
    error_message = "incorrect response body for the index.html page"
  }
}