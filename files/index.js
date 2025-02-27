const crypto = require('crypto');

/**
 * Preserver the server Host header as it is passed along to an origin.
 *
 * Cloudfront Function (ES5)
 * viewer_request
 *
 * @param event
 * @returns {Promise<Request|IDBRequest<any>|((name: string, callback: LockGrantedCallback) => Promise<any>)|((type?: WakeLockType) => Promise<WakeLockSentinel>)|((name: string, options: LockOptions, callback: LockGrantedCallback) => Promise<any>)>}
 */
async function handler(event) {
    let request = event.request;

    request.headers["viewer-host"] = request.headers.host;
    request.headers["distribution-domain"] = {
        value: event.context.distributionDomainName,
    };

    // https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-lambda.html#create-oac-overview-lambda
    let method = request.method.toLowerCase();
    if (method === "post" || method === "put") {
        hash = await sha256FromBody(request);
        request.headers["x-amz-content-sha256"] = [{            value: hash }];
    }
    return request;
}

/**
 * Compute the SHA256 of the POST|PUT body.
 *
 * If you use PUT or POST methods with your Lambda function URL, your users must
 * compute the SHA256 of the body and include the payload hash value of the
 * request body in the x-amz-content-sha256 header when sending the request to
 * CloudFront. Lambda doesn't support unsigned payloads.
 * @param req
 * @returns {Promise<unknown>}
 */
async function sha256FromBody(req) {
    return new Promise((resolve, reject) => {
        let body = "";
        req.on("data", chunk => {
            body += chunk;
        });
        req.on("end", () => {
            const hash = crypto.createHash("sha256").update(body).digest("hex");
            resolve(hash);
        });
        req.on("error", error => {
            reject(error);
        });
    });
}