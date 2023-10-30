package lambda

import (
    "context"
    "github.com/kohirens/stdlib/cli"
    "time"
)

// Request See https://docs.aws.amazon.com/lambda/latest/dg/urls-invocation.html#urls-request-payload
type Request struct {
	Body    string        `json:"body"`
	Headers cli.StringMap `json:"headers"`
	Http    Http          `json:"http"`
	RawPath string        `json:"rawPath"`
}

// Http See https://docs.aws.amazon.com/lambda/latest/dg/urls-invocation.html#urls-request-payload
type Http struct {
	Method    string `json:"method"`
	Path      string `json:"path"`
	Protocol  string `json:"protocol"`
	SourceIp  string `json:"sourceIp"`
	UserAgent string `json:"userAgent"`
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
