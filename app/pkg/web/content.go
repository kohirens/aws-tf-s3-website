package web

const (
	http301RedirectContent      = `<!DOCTYPE html><html><head><title>301 Moved Permanently</title></head><body><center><h1>301 Moved Permanently</h1></center><hr><center>CloudFront</center></body></html>`
	http308RedirectContent      = `<!DOCTYPE html><html><head><title>308 Permanent Redirect</title></head><body><center><h1>308 Permanent Redirect</h1></center><hr><center>CloudFront</center></body></html>`
	http404NotFoundContent      = `<!DOCTYPE html><html><head><title>301 Moved Permanently</title></head><body><center><h1>301 Moved Permanently</h1></center><hr><center>CloudFront</center></body></html>`
	http500InternalErrorContent = `<!DOCTYPE html><html><head><title>500 Internal Server Error</title></head><body><center><h1>301 Internal Server Error</h1></center><hr><center>CloudFront</center></body></html>`

	// [Media Types](https://www.iana.org/assignments/media-types/media-types.xhtml)

	contentTypeHtml = "text/html; charset=utf-8"
	contentTypePng  = "application/json; charset=utf-8"
	contentTypeJson = "application/json; charset=utf-8"
	contentTypeJS   = "text/javascript; charset=utf-8"
	contentTypeCSS  = "text/css; charset=utf-8"
)
