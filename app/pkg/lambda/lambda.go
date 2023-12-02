package lambda

import (
	"context"
	"regexp"
	"strings"
	"time"
)

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
