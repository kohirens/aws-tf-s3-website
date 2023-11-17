package web

import (
	"reflect"
	"testing"
)

func TestGetHeader(t *testing.T) {
	tests := []struct {
		name    string
		headers map[string]string
		header  string
		want    string
	}{
		{"get-lowercase-host-header", map[string]string{"Host": "example.com"}, "host", "example.com"},
		{"get-uppercase-host-header", map[string]string{"HOST": "example.com"}, "host", "example.com"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := GetHeader(tt.headers, tt.header)

			if got != tt.want {
				t.Errorf("GetHeader() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestGetPageType(t *testing.T) {
	tests := []struct {
		name    string
		headers map[string]string
		want    string
	}{
		{"html-type", map[string]string{"content-type": "text/html"}, "text/html"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := GetPageType(tt.headers); got != tt.want {
				t.Errorf("GetPageType() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestGetPageTypeByExt(t *testing.T) {
	tests := []struct {
		name     string
		pagePath string
		want     string
	}{
		{"html", "page.html", "text/html;charset=utf-8"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := GetPageTypeByExt(tt.pagePath)

			if got != tt.want {
				t.Errorf("GetPageTypeByExt() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestRespond301Or308(t *testing.T) {
	fixedResponse := &Response{
		StatusCode: 301,
		Headers: map[string]string{
			"Content-Type": "text/html;charset=utf-8",
			"Location":     "https://www.example.com",
		},
	}
	fixed308Response := &Response{
		StatusCode: 308,
		Headers: map[string]string{
			"Content-Type": "text/html;charset=utf-8",
			"Location":     "https://www.example.com",
		},
	}
	tests := []struct {
		name     string
		method   string
		location string
		want     *Response
	}{
		{"301", "GET", "www.example.com", fixedResponse},
		{"308", "POST", "www.example.com", fixed308Response},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := Respond301Or308(tt.method, tt.location)

			if got.StatusCode != tt.want.StatusCode {
				t.Errorf("Respond301Or308() = %v, want %v", got.StatusCode, tt.want.StatusCode)
			}

			if !reflect.DeepEqual(got.Headers, tt.want.Headers) {
				t.Errorf("Respond301Or308() = %v, want %v", got.Headers, tt.want.Headers)
			}
		})
	}
}

// This suite of test ensure any refactoring of these methods leave the
// required HTTP status code and recommended status message are left intact.
// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/401
// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/404
// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/500
func TestRespond401(t *testing.T) {
	tests := []struct {
		name       string
		call       func() *Response
		wantCode   int
		wantStatus string
	}{
		{"401", Respond401, 401, "Unauthorized"},
		{"404", Respond404, 404, "Not found"},
		{"500", Respond500, 500, "Internal Server Error"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := tt.call()

			if got.StatusCode != tt.wantCode {
				t.Errorf("Respond%v() = %v, want %v", tt.name, got.StatusCode, tt.wantCode)
			}

			if got.StatusCode != tt.wantCode {
				t.Errorf("Respond%v() = %v, want %v", tt.name, got.Status, tt.wantStatus)
			}
		})
	}
}

func TestRespondJSONOG(t *testing.T) {
	type jsonMsg struct {
		Msg string `json:"msg"`
	}

	fixedBody := &jsonMsg{"Salam"}

	tests := []struct {
		name     string
		content  *jsonMsg
		wantBody string
		wantErr  bool
	}{
		{"can-encode", fixedBody, `{"msg":"Salam"}`, false},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, e := RespondJSON(tt.content)

			if (e != nil) != tt.wantErr {
				t.Errorf("RespondJSON() = %v, want %v", e, tt.wantErr)
			}

			if got.Body != tt.wantBody {
				t.Errorf("RespondJSON() = %v, want %v", got.Body, tt.wantBody)
			}
		})
	}
}
