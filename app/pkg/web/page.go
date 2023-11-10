package web

import (
	"github.com/kohirens/stdlib/cli"
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

func GetHeader(headers map[string]string, header string) string {
	value := ""
	for h, v := range headers {
		lch := strings.ToLower(h)
		if lch == header {
			value = v
			break
		}
	}

	return value
}

func Respond200(content, contentType string) *Response {
	return &Response{
		Body:       content,
		StatusCode: 200,
		Status:     "OK!",
		Headers: cli.StringMap{
			"Content-Type": contentType,
		},
	}
}

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
		Body:       content,
		StatusCode: code,
		Status:     "Moved Permanently",
		Headers: cli.StringMap{
			"Content-Type": contentTypeHtml,
			"Location":     location,
		},
	}
}

func Respond401() *Response {
	return &Response{
		Body:       http401NotFoundContent,
		Status:     "Unauthorized",
		StatusCode: 401,
		Headers: cli.StringMap{
			"Content-Type": contentTypeHtml,
		},
	}
}

func Respond404() *Response {
	return &Response{
		Body:       http404NotFoundContent,
		StatusCode: 404,
		Status:     "Not Found",
		Headers: cli.StringMap{
			"Content-Type": contentTypeHtml,
		},
	}
}

func Respond500() *Response {
	return &Response{
		Body:       http500InternalErrorContent,
		StatusCode: 500,
		Status:     "Internal Server Error",
		Headers: cli.StringMap{
			"Content-Type": contentTypeHtml,
		},
	}
}

func RespondJSON(content string) *Response {
	res := Respond200(content, contentTypeJson)
	res.Body = content
	return res
}
