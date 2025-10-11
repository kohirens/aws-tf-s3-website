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
* Redirect apex domain to "www" subdomain or vice-versa.
* Register SSL certificate for domains.

## Non Functional Requirements

* When there is no traffic, then cost should be low.
* Keep cost relative to the amount of traffic.
* Repeatable and simple deployment process.
