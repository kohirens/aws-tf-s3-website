/**
 * Preserver the server Host header as it is passed along to an origin.
 *
 * Cloudfront Function (ES5)
 * viewer_request
 *
 * @param event
 * @returns {Promise<Request|IDBRequest<any>|((name: string, callback: LockGrantedCallback) => Promise<any>)|((type?: WakeLockType) => Promise<WakeLockSentinel>)|((name: string, options: LockOptions, callback: LockGrantedCallback) => Promise<any>)>}
 */
function handler(event) {
    var request = event.request;

    request.headers["viewer-host"] = request.headers.host;

    return request;
}
