# Default App

Build from CLI

```shell
# Windows
$Env:GOARCH="arm64"; $Env:GOOS="linux" ; go build -tags lambda.norpc .\cmd\bootstrap

# Linux/Mac/Unix/POSIX
GOARCH="arm64" GOOS="linux" go build -tags lambda.norpc ./cmd/bootstrap
```


## Things To Know

There are a lot of nuances and intricate situations that arise when developing
a solution that involves CloudFront. One of the biggest causes for problems is
also the biggest benefit of CloudFront, and that is the caching. And once this
cache is populated is very hard to remove. I suggest always adding a reasonable
small cache TTL (time to live) or turning cache off when dealing with issues
that are intermittent.

If you're having issues, then maybe a review these documents may aid you.

**Topics**

1. [Lambda Function URL Response Payloads]
2. [Hint On Handling Images in Lambda]

[Lambda Function URL Response Payloads]: https://docs.aws.amazon.com/lambda/latest/dg/urls-invocation.html
[Hint On Handling Images in Lambda]: https://docs.aws.amazon.com/apigateway/latest/developerguide/lambda-proxy-binary-media.html

## Issues

### CloudFront

1. If your having problems with inconsistent behavior with your code
    1. Recheck your distribution configuration.
    2. Disabling caching.
    3. If they are not the part your debugging, then disable any edge functions.
