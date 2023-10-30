package web

import (
	"fmt"
	"github.com/kohirens/stdlib/log"
	"github.com/kohirens/stdlib/path"
	"os"
	"strings"
)

// Response See https://docs.aws.amazon.com/lambda/latest/dg/urls-invocation.html#urls-response-payload
type Response struct {
	Body       string            `json:"body"`
	Headers    map[string]string `json:"headers"`
	Status     string            `json:"status"`
	StatusCode int               `json:"statusCode"`
}

func LoadFile(pagePath, contentType string) (*Response, error) {
	log.Infof(Stdout.LoadPage, pagePath)

	cwd, e1 := os.Getwd()
	if e1 == nil {
		panic("could not get current working directory:" + e1.Error())
	}

	log.Dbugf("current working directory: %v", cwd)

	if !path.Exist(pagePath) {
		return Respond404(), nil
	}

	html, e1 := os.ReadFile(pagePath)
	if e1 != nil {
		return nil, fmt.Errorf(Stderr.CannotReadFile, pagePath, e1.Error())
	}

	log.Dbugf(Stdout.BytesRead, pagePath, len(html))

	res := Respond200(string(html), contentType)

	return res, nil
}

// DoRedirect Perform a redirect if the host matches any of the domains in the
// REDIRECT environment variable.
func DoRedirect(host, method string) (*Response, error) {
	var res *Response

	redirectTo, ok1 := os.LookupEnv("REDIRECT_TO")
	if !ok1 {
		return nil, fmt.Errorf(Stderr.EnvVarUnset, "REDIRECT_TO")
	}

	rdHosts, ok2 := os.LookupEnv("REDIRECT_HOSTS")

	if ok2 && rdHosts != "" && strings.Contains(rdHosts, host) {
		res = Respond301Or308(method, redirectTo)
	}

	return res, nil
}
