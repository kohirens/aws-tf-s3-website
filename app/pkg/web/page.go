package web

import (
	"encoding/json"
	"fmt"
	"github.com/aws/aws-lambda-go/events"
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
	case ".jpg":
		ct = contentTypeJpg
	case ".gif":
		ct = contentTypeGif
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
		if lch == lcn {
			ov := v
			if lch == "authorization" {
				ov = "*************"
			}
			log.Infof("found header %v = %v", name, ov)
			value = v
			break
		}
	}

	return value
}

// GetMapItem Retrieve an item from a string map.
func GetMapItem(mapData cli.StringMap, name string) string {
	value := ""
	ln := strings.ToLower(name)

	for k, v := range mapData {
		lk := strings.ToLower(k)
		if lk == ln {
			log.Infof("found item %q in string map", name)
			value = v
			break
		}
	}

	return value
}

// Respond200 Send a 301 or 308 HTTP response redirect to another location.
func Respond200(content, contentType string) *events.LambdaFunctionURLResponse {
	return &events.LambdaFunctionURLResponse{
		Body: content,
		Headers: cli.StringMap{
			"Content-Type": contentType,
		},
		StatusCode: 200,
		Cookies:    []string{},
	}
}

// Respond301Or308 Send a 301 or 308 HTTP response redirect to another location.
func Respond301Or308(method, location string) *events.LambdaFunctionURLResponse {
	code := 301
	content := http301RedirectContent

	if method == "POST" {
		code = 308
		content = http308RedirectContent
	}

	if !strings.Contains(location, "https://") {
		location = "https://" + location
	}

	return &events.LambdaFunctionURLResponse{
		Body: content,
		Headers: cli.StringMap{
			"Content-Type": contentTypeHtml,
			"Location":     location,
		},
		StatusCode: code,
	}
}

// Respond401 Send a 401 Unauthorized HTTP response.
func Respond401() *events.LambdaFunctionURLResponse {
	return &events.LambdaFunctionURLResponse{
		Body: http401UnauthorizedContent,
		Headers: cli.StringMap{
			"Content-Type": contentTypeHtml,
		},
		StatusCode: 401,
	}
}

// Respond404 Send a 404 Not Found HTTP response.
func Respond404() *events.LambdaFunctionURLResponse {
	return &events.LambdaFunctionURLResponse{
		Body: http404NotFoundContent,
		Headers: cli.StringMap{
			"Content-Type": contentTypeHtml,
		},
		StatusCode: 404,
	}
}

// Respond500 Send a 500 Internal Server Error HTTP response.
func Respond500() *events.LambdaFunctionURLResponse {
	return &events.LambdaFunctionURLResponse{
		Body: http500InternalErrorContent,
		Headers: cli.StringMap{
			"Content-Type": contentTypeHtml,
		},
		StatusCode: 500,
	}
}

// Response501 Send a 501 Not Implemented HTTP response.
//
//	501 is the appropriate response when the server does not recognize the
//	request method and is incapable of supporting it for any resource. The only
//	methods that servers are required to support (and therefore that must not
//	return 501) are GET and HEAD.
func Response501() *events.LambdaFunctionURLResponse {
	return &events.LambdaFunctionURLResponse{
		Body: http501NotImplemented,
		Headers: cli.StringMap{
			"Content-Type": contentTypeHtml,
		},
		StatusCode: 501,
	}
}

// RespondJSON Send a JSON HTTP response.
func RespondJSON(content interface{}) (*events.LambdaFunctionURLResponse, error) {
	jsonEncodedContent, e1 := json.Marshal(content)
	if e1 != nil {
		return nil, fmt.Errorf(Stderr.CannotEncodeToJson, e1.Error())
	}

	return Respond200(string(jsonEncodedContent), contentTypeJson), nil
}
