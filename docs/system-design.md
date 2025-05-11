## System Design

Setup infrastructure that serves a website where cost are relative to the
client traffic. If low to no traffic, then cost should be low to none. While
high volume traffic, then scale to meet demand but still be cost-efficient.

The solution should be repeatable and simple for any number of domains and not
care if the site is a traditional static, SPA, or other kind of website. If an
Apex domain is given for the site, then it should redirect to the "www"
subdomain. Any given site should perform to the best of its developers ability
and the system should help where it can.

## Features

* Cost-efficient
* Support HTTPS protocol
* Provide dynamic and static content
* Redirect apex to www
* Low network latency relative to content being served

### Functional Requirements

* Scale up to meet high demand, expenses should be reasonable.
* Works with at least static and SPA websites.
* Domain registration.
* Redirect apex domain to "www" subdomain.
* Register SSL certificate for domains.
* Help reduce page load-time where possible.

## Non Functional Requirements

* When there is no traffic, then cost should be low.
* Keep cost relative to the amount of traffic.
* Repeatable and simple deployment process.

## High Level Design

* Storage for the website files.
* Server static content from cache whenever possible.

## Setup Lambda Apex Redirect

We want to redirect the apex domain to is "www" subdomain.

We can achieve this without using a CloudFront edge function by change the
infrastructure configuration of the CloudFront distribution and the Lambda 
function setup as its origin.

1. Set up a second origin for the apex domain on the CloudFront Distribution.
   1. Add an HTTP header "Redirect-Apex-To" and set that to the subdomain you
      want it to redirect to. 
2. Update the Lambda function code to look for this header, and when it is set,
   perform a 301 (or 308 for POST method) to the value in the environment
   variable "REDIRECT_TO."

With this method you no longer need a CloudFront function at the edge to store
the original HTTP "Host" header value in another header for safe keep. Though
it should be recommended to do that as you never know when you Lambda code will
need that value.