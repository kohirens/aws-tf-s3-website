package main

import (
	"context"
	"errors"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/service/s3"
	ilambda "github.com/kohirens/aws-tf-s3-wesbite/app/pkg/lambda"
	is3 "github.com/kohirens/aws-tf-s3-wesbite/app/pkg/s3"
	"github.com/kohirens/aws-tf-s3-wesbite/app/pkg/web"
	"github.com/kohirens/stdlib/log"
	"os"
	"strconv"
	"time"
)

func main() {
	var mainErr error

	defer func() {
		if mainErr != nil {
			log.Fatf(web.Stderr.FatalHeader, mainErr)
			os.Exit(1)
		}
		os.Exit(0)
	}()

	vl, vOk := os.LookupEnv("VERBOSITY_LEVEL")
	if vOk {
		log.VerbosityLevel, mainErr = strconv.Atoi(vl)
		if mainErr != nil {
			return
		}
	}

	log.Logf(web.Stdout.RunLambda)

	lambda.Start(Handler)
}

// Handler Lambda handler function.
func Handler(ctx context.Context, event ilambda.Request) (*web.Response, error) {
	//if e := web.Authenticate(event.Headers); e != nil { // require auth for everything below this block
	//	res.StatusCode = 401
	//	res.Status = "Unauthorized!"
	//	res.Body = fmt.Sprintf("{%q: %q}", "message", e.Error())
	//	return res, nil
	//}

	host := web.GetHeader(event.Headers, "host")

	redirect, e1 := web.DoRedirect(host, event.Http.Method)
	if e1 != nil {
		log.Errf(e1.Error())
	}

	if redirect != nil {
		return redirect, nil
	}

	ct := web.GetPageType(event.Headers)
	pagePath := event.RawPath

	res, e2 := loadPageFromS3(pagePath, ct)
	if e1 != nil { // keep going on error
		log.Errf(e2.Error())
	}

	return res, nil
}

// loadPageFromS3 Download the page content from an S3 Bucket.
func loadPageFromS3(pagePath, contentType string) (*web.Response, error) {
	bucketName, ok1 := os.LookupEnv("S3_BUCKET_NAME")
	if !ok1 {
		return nil, fmt.Errorf(web.Stderr.EnvVarUnset, "S3_BUCKET_NAME")
	}

	s3svc := is3.NewClient(bucketName)
	if s3svc == nil {
		log.Errf(web.Stderr.NoS3ClientOrContext)
	}

	content, e1 := s3svc.Download(pagePath, ilambda.GetContextWithTimeout(time.Second*5))

	var res *web.Response

	if e1 != nil {
		var aErr awserr.Error
		ok := errors.As(e1, &aErr)

		if ok {
			switch aErr.Code() {
			case s3.ErrCodeNoSuchKey:
				res = web.Respond404()
				return res, fmt.Errorf(ilambda.Stderr.S3NoSuchKey, aErr.Error())
			case s3.ErrCodeInvalidObjectState:
				log.Errf(ilambda.Stderr.InvalidObjectState, aErr.Error())
			default:
				res = web.Respond500()
			}
		} else {
			res = web.Respond500()
			log.Errf(ilambda.Stderr.CannotLoadPage, pagePath, e1.Error())
		}

		return nil, fmt.Errorf(ilambda.Stderr.CannotLoadPage, pagePath, e1.Error())
	}

	res = web.Respond200(content, contentType)

	return res, nil
}
