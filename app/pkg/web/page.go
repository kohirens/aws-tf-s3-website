package web

import (
	"encoding/json"
	"fmt"
	"github.com/kohirens/stdlib/cli"
	"github.com/kohirens/stdlib/log"
	"path/filepath"
	"strings"
)

// GetPageType Get the content type via header.
func GetPageType(headers map[string]string) string {
	ct := GetHeader(headers, "content-type")

	fct := strings.Split(ct, ",")
	if fct != nil {
		ct = fct[0]
	}

	return ct
}

// GetPageTypeByExt Get the content type by the extension of the file being
// requested.
func GetPageTypeByExt(pagePath string) string {
	var ct string

	ext := filepath.Ext(pagePath)

	switch ext {
	case ".css":
		ct = contentTypeCSS
	case ".html":
		ct = contentTypeHtml
	case ".js":
		ct = contentTypeJS
	case ".json":
		ct = contentTypeJson
	case ".jpg", ".git":
		ct = ""
	case ".png":
		ct = contentTypePng
	case ".svg", ".svgz":
		ct = contentTypeSvg
	default:
		ct = ""
	}

	return ct
}

// GetHeader Retrieve a header from a request.
func GetHeader(headers map[string]string, name string) string {
	value := ""
	lcn := strings.ToLower(name)

	for h, v := range headers {
		lch := strings.ToLower(h)
		log.Infof("looking for header %v: so far found %v", lcn, lch)
		if lch == lcn {
			value = v
			break
		}
	}

	return value
}

// Respond200 Send a 301 or 308 HTTP response redirect to another location.
func Respond200(content, contentType string) *Response {
	return &Response{
		Body: content,
		Headers: cli.StringMap{
			"Content-Type": contentType,
		},
		Status:     "OK",
		StatusCode: 200,
	}
}

// Respond301Or308 Send a 301 or 308 HTTP response redirect to another location.
func Respond301Or308(method, location string) *Response {
	code := 301
	content := http301RedirectContent

	if method == "POST" {
		code = 308
		content = http308RedirectContent
	}

	if !strings.Contains(location, "https://") {
		location = "https://" + location
	}

	return &Response{
		Body: content,
		Headers: cli.StringMap{
			"Content-Type": contentTypeHtml,
			"Location":     location,
		},
		Status:     "Moved Permanently",
		StatusCode: code,
	}
}

// Respond401 Send a 401 Unauthorized HTTP response.
func Respond401() *Response {
	return &Response{
		Body: http401UnauthorizedContent,
		Headers: cli.StringMap{
			"Content-Type": contentTypeHtml,
		},
		Status:     "Unauthorized",
		StatusCode: 401,
	}
}

// Respond404 Send a 404 HTTP response.
func Respond404() *Response {
	return &Response{
		Body: http404NotFoundContent,
		Headers: cli.StringMap{
			"Content-Type": contentTypeHtml,
		},
		Status:     "Not Found",
		StatusCode: 404,
	}
}

// Respond500 Send a 500 HTTP response.
func Respond500() *Response {
	return &Response{
		Body: http500InternalErrorContent,
		Headers: cli.StringMap{
			"Content-Type": contentTypeHtml,
		},
		Status:     "Internal Server Error",
		StatusCode: 500,
	}
}

// RespondJSON Send a JSON HTTP response.
func RespondJSON(content interface{}) (*Response, error) {
	jsonEncodedContent, e1 := json.Marshal(content)
	if e1 != nil {
		return nil, fmt.Errorf(Stderr.CannotEncodeToJson, e1.Error())
	}

	return Respond200(string(jsonEncodedContent), contentTypeJson), nil
}
