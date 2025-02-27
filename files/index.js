/**
 * Preserver the server Host header as it is passed along to an origin.
 *
 * Cloudfront Function (ES5.1+)
 * viewer_request
 * Resources for your review:
 *   - Example Function code: https://github.com/aws-samples/amazon-cloudfront-functions
 *   - Supported ES 5,6,7 features: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/functions-javascript-runtime-20.html
 *   - Use async & await: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/async-await-syntax.html
 *   - Standard logs: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
 *   - Configure Standard logs: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/standard-logging.html
 * @param event
 * @returns {Promise<Request|IDBRequest<any>|((name: string, callback: LockGrantedCallback) => Promise<any>)|((type?: WakeLockType) => Promise<WakeLockSentinel>)|((name: string, options: LockOptions, callback: LockGrantedCallback) => Promise<any>)>}
 */
async function handler(event) {
    let request = event.request;

    request.headers["viewer-host"] = request.headers.host;
    request.headers["distribution-domain"] = {
        value: event.context.distributionDomainName,
    };

    return request;
}
