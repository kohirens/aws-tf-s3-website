package lambda

import (
	"context"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/kohirens/aws-tf-s3-wesbite/app/pkg/web"
	"github.com/kohirens/stdlib/log"
	"os"
	"regexp"
	"strings"
	"time"
)

type StringMap map[string]string

const (
	headerAltHost  = "viewer-host"
	headerCfDomain = "distribution-domain"
)

type PageSource interface {
	Load(pagePath string) ([]byte, error)
}

func GetContextWithTimeout(timeout time.Duration) context.Context {
	// Create a context with a timeout that will abort the upload if it takes
	// more than the passed in timeout.
	ctx := context.Background()
	var cancelFn func()

	if timeout > 0 {
		ctx, cancelFn = context.WithTimeout(ctx, timeout)
	}
	// Ensure the context is canceled to prevent leaking.
	// See context package for more information, https://golang.org/pkg/context/
	if cancelFn != nil {
		defer cancelFn()
	}

	return ctx
}

func GetCookie(cookies []string, name string) string {
	value := ""

	re := regexp.MustCompile(`[^=]+=([^;]+);?.*$`)
	for _, cookie := range cookies {
		if strings.Contains(cookie, name+"=") { // we got a hit
			//
			d := re.FindAllStringSubmatch(cookie, 1)
			if d != nil {
				value = d[0][1]
				break
			}
		}
	}

	return value
}

type Handler struct {
	PageSource PageSource
}

func NewHandler(ps PageSource) *Handler {
	return &Handler{
		PageSource: ps,
	}
}

// Bootstrap Lambda execution runtime handler.
func (handler Handler) Bootstrap(event *events.LambdaFunctionURLRequest) (*events.LambdaFunctionURLResponse, error) {
	var res *events.LambdaFunctionURLResponse

	log.Infof("handler started")

	method := event.RequestContext.HTTP.Method
	httpAllowedMethods, ok := os.LookupEnv("HTTP_METHODS_ALLOWED")
	if ok {
		web.SupportedMethods = strings.Split(httpAllowedMethods, ",")
	}

	if strings.ToUpper(method) == "OPTIONS" {
		return web.ResponseOptions(httpAllowedMethods), nil
	}

	if web.NotImplemented(method) {
		return web.Response501(), nil
	}

	host := web.GetHeader(event.Headers, headerAltHost)
	doIt, e1 := web.ShouldRedirect(host)

	if e1 != nil {
		log.Errf(e1.Error())
		return web.Respond500(), nil
	}

	if doIt {
		serverHost, _ := os.LookupEnv("REDIRECT_TO")
		return web.Respond301Or308(event.RequestContext.HTTP.Method, serverHost), nil
	}

	distributionDomain := web.GetHeader(event.Headers, headerCfDomain)
	log.Infof("distributionDomain = %v", distributionDomain)
	if host == distributionDomain {
		log.Infof("a request was made using the CloudFront distribution domain name, which is not authorized: %v", distributionDomain)
		return web.Respond401(), nil
	}

	pagePath := event.RawPath

	content, e2 := handler.PageSource.Load(pagePath)

	if e2 != nil {
		res = web.Respond500()

		if strings.Contains(e2.Error(), s3.ErrCodeNoSuchKey) {
			res = web.Respond404()
		}

		log.Logf(e2.Error())
		return res, nil
	}

	ct := web.GetPageTypeByExt(pagePath)
	res = web.Respond200(content, ct)

	return res, nil
}
