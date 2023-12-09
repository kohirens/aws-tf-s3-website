package lambda

import (
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/kohirens/stdlib/cli"
	"github.com/kohirens/stdlib/path"
	"os"
	"reflect"
	"testing"
)

const (
	FixtureDir = "testdata"
	pS         = string(os.PathSeparator)
)

type MockHandler struct{}

func (MockHandler) Load(pagePath string) ([]byte, error) {
	//TODO implement me
	if !path.Exist(pagePath) {
		return nil, fmt.Errorf(s3.ErrCodeNoSuchKey)
	}
	return os.ReadFile(pagePath)
}

func TestGetCookie(t *testing.T) {
	tests := []struct {
		name    string
		cookies []string
		cname   string
		want    string
	}{
		{"cookie1", []string{"Cookie_1=Value1; Expires=21 Oct 2021 07:48 GMT"}, "Cookie_1", "Value1"},
		{"cookie2", []string{"Cookie_2=Value2; Max-Age=78000"}, "Cookie_2", "Value2"},
		{"cookie2", []string{"Cc3=Value3"}, "Cc3", "Value3"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := GetCookie(tt.cookies, tt.cname); got != tt.want {
				t.Errorf("GetCookie() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestBootstrap(t *testing.T) {
	_ = os.Setenv("Authorization", "1234")
	_ = os.Setenv("REDIRECT_TO", "www.example.com")
	_ = os.Setenv("REDIRECT_HOSTS", "example.com")
	defer func() {
		_ = os.Unsetenv("Authorization")
		_ = os.Unsetenv("REDIRECT_TO")
	}()

	tests := []struct {
		name    string
		src     PageSource
		event   *events.LambdaFunctionURLRequest
		want    *events.LambdaFunctionURLResponse
		wantErr bool
	}{
		{
			"not-implemented",
			&MockHandler{},
			&events.LambdaFunctionURLRequest{
				RequestContext: events.LambdaFunctionURLRequestContext{
					HTTP: events.LambdaFunctionURLRequestContextHTTPDescription{
						Method: "HEAD",
					},
				},
			},
			&events.LambdaFunctionURLResponse{
				StatusCode: 501,
			},
			false,
		},
		{
			"not-authorized",
			&MockHandler{},
			&events.LambdaFunctionURLRequest{
				Headers: cli.StringMap{"Authorization": ""},
				RequestContext: events.LambdaFunctionURLRequestContext{
					HTTP: events.LambdaFunctionURLRequestContextHTTPDescription{
						Method: "GET",
					},
				},
			},
			&events.LambdaFunctionURLResponse{
				StatusCode: 401,
			},
			false,
		},
		{
			"redirect-301",
			&MockHandler{},
			&events.LambdaFunctionURLRequest{
				Headers: cli.StringMap{"Authorization": "1234", headerAltHost: "example.com"},
				RequestContext: events.LambdaFunctionURLRequestContext{
					HTTP: events.LambdaFunctionURLRequestContextHTTPDescription{
						Method: "GET",
					},
				},
			},
			&events.LambdaFunctionURLResponse{
				StatusCode: 301,
			},
			false,
		},
		{
			"redirect-308",
			&MockHandler{},
			&events.LambdaFunctionURLRequest{
				Headers: cli.StringMap{"Authorization": "1234", headerAltHost: "example.com"},
				RequestContext: events.LambdaFunctionURLRequestContext{
					HTTP: events.LambdaFunctionURLRequestContextHTTPDescription{
						Method: "POST",
					},
				},
			},
			&events.LambdaFunctionURLResponse{
				StatusCode: 308,
			},
			false,
		},
		{
			"cloudfront-domain-not-authorized",
			&MockHandler{},
			&events.LambdaFunctionURLRequest{
				Headers: cli.StringMap{
					"Authorization": "1234",
					headerAltHost:   "cfd.cloudfront.aws",
					headerCfDomain:  "cfd.cloudfront.aws",
				},
				RequestContext: events.LambdaFunctionURLRequestContext{
					HTTP: events.LambdaFunctionURLRequestContextHTTPDescription{
						Method: "GET",
					},
				},
			},
			&events.LambdaFunctionURLResponse{
				StatusCode: 401,
			},
			false,
		},
		{
			"cloudfront-domain-not-authorized",
			&MockHandler{},
			&events.LambdaFunctionURLRequest{
				Headers: cli.StringMap{
					"Authorization": "1234",
					headerAltHost:   "www.example.com",
					headerCfDomain:  "cfd.cloudfront.aws",
				},
				RequestContext: events.LambdaFunctionURLRequestContext{
					HTTP: events.LambdaFunctionURLRequestContextHTTPDescription{
						Method: "GET",
					},
				},
				RawPath: FixtureDir + pS + "404.html",
			},
			&events.LambdaFunctionURLResponse{
				StatusCode: 404,
			},
			false,
		},
		{
			"ok",
			&MockHandler{},
			&events.LambdaFunctionURLRequest{
				Headers: cli.StringMap{
					"Authorization": "1234",
					headerAltHost:   "www.example.com",
					headerCfDomain:  "cfd.cloudfront.aws",
				},
				RequestContext: events.LambdaFunctionURLRequestContext{
					HTTP: events.LambdaFunctionURLRequestContextHTTPDescription{
						Method: "GET",
					},
				},
				RawPath: FixtureDir + pS + "index.html",
			},
			&events.LambdaFunctionURLResponse{
				StatusCode: 200,
			},
			false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {

			fxtr := NewHandler(tt.src)
			got, e := fxtr.Bootstrap(tt.event)
			if (e != nil) != tt.wantErr {
				t.Errorf("Bootstrap() error, want %v", tt.wantErr)
			}

			if reflect.DeepEqual(got, tt.want) {
				t.Errorf("Bootstrap() got %v, want %v", got.StatusCode, tt.want.StatusCode)
			}

			if got.StatusCode != tt.want.StatusCode {
				t.Errorf("Bootstrap() got %v, want %v", got.StatusCode, tt.want.StatusCode)
			}
		})
	}
}
