package web

import (
	"fmt"
	"github.com/aws/aws-lambda-go/events"
	"github.com/kohirens/stdlib/cli"
	"github.com/kohirens/stdlib/log"
	"github.com/kohirens/stdlib/path"
	"os"
	"strings"
)

// Response See https://docs.aws.amazon.com/lambda/latest/dg/urls-invocation.html#urls-response-payload
type Response struct {
	Body       string        `json:"body"`
	Headers    cli.StringMap `json:"headers"`
	Status     string        `json:"status"`
	StatusCode int           `json:"statusCode"`
	Cookies    []string      `json:"cookies"`
}

// This simple server does not implement these methods. You must provide your
// own code to serve these methods.
var SupportedMethods = []string{
	"GET",
	"POST",
}

type FileSource struct {
}

// Load a file from local storage.
func (fileSource *FileSource) Load(pagePath string) ([]byte, error) {
	log.Infof(Stdout.LoadPage, pagePath)

	cwd, e1 := os.Getwd()
	if e1 == nil {
		panic("could not get current working directory:" + e1.Error())
	}

	log.Dbugf("current working directory: %v", cwd)

	if !path.Exist(pagePath) {
		return nil, fmt.Errorf("file %v not found", pagePath)
	}

	contents, e1 := os.ReadFile(pagePath)
	if e1 != nil {
		return nil, fmt.Errorf(Stderr.CannotReadFile, pagePath, e1.Error())
	}

	log.Dbugf(Stdout.BytesRead, pagePath, len(contents))

	return contents, nil
}

func LoadFile(pagePath, contentType string) (*events.LambdaFunctionURLResponse, error) {
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

	res := Respond200(html, contentType)

	return res, nil
}

// NotImplemented Return true if the HTTP method is supported by this server
// and false otherwise.
func NotImplemented(method string) bool {
	missing := true
	for _, sm := range SupportedMethods {
		if strings.EqualFold(sm, method) {
			missing = false
		}
	}
	return missing
}

// ShouldRedirect Perform a redirect if the host matches any of the domains in the
// REDIRECT environment variable.
func ShouldRedirect(host string) (bool, error) {

	if host == "" {
		return false, fmt.Errorf(Stderr.HostNotSet)
	}

	rt, ok1 := os.LookupEnv("REDIRECT_TO")
	if !ok1 {
		return false, fmt.Errorf(Stderr.EnvVarUnset, "REDIRECT_TO")
	}

	if rt == "" {
		return false, fmt.Errorf(Stderr.RedirectToEmpty, "REDIRECT_TO")
	}

	if strings.EqualFold(host, rt) {
		log.Infof(Stderr.DoNoRedirectToSelf, host, rt)
		return false, nil
	}

	rh, ok2 := os.LookupEnv("REDIRECT_HOSTS")
	if !ok2 {
		return false, fmt.Errorf(Stderr.EnvVarUnset, "REDIRECT_HOSTS")
	}

	if rh == "" {
		log.Infof(Stdout.EnvVarEmpty, rt)
		return false, nil
	}

	retVal := false
	rhs := strings.Split(rh, ",")
	for _, h := range rhs {
		if h == host {
			log.Infof("domain %v in in the list of domains to redirect to %v", host, rt)
			retVal = true
		}
	}

	return retVal, nil
}
