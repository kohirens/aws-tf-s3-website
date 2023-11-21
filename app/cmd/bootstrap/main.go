package main

import (
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/service/s3"
	ilambda "github.com/kohirens/aws-tf-s3-wesbite/app/pkg/lambda"
	is3 "github.com/kohirens/aws-tf-s3-wesbite/app/pkg/s3"
	"github.com/kohirens/aws-tf-s3-wesbite/app/pkg/web"
	"github.com/kohirens/stdlib/log"
	"os"
	"strconv"
	"strings"
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

	lambda.Start(Handler)
}

// Handler Lambda handler function.
func Handler(event ilambda.Request) (*web.Response, error) {
	var res *web.Response

	if e := web.Authenticate(event.Headers); e != nil { // require auth for everything below this block
		res = web.Respond401()
		log.Errf(e.Error())
		return res, nil
	}

	host := web.GetHeader(event.Headers, "viewer-host")

	log.Infof("host = %v", host)

	redirect, e1 := web.DoRedirect(host, event.RequestContext.Http.Method)
	if e1 != nil {
		log.Errf(e1.Error())
	}

	if redirect != nil {
		return redirect, nil
	}

	distributionDomain := event.Context.DistributionDomainName

	if host == distributionDomain {
		return web.Respond401(), nil
	}

	pagePath := event.RawPath

	content, e2 := loadPageFromS3(pagePath)

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

// loadPageFromS3 Download the page content from an S3 Bucket.
func loadPageFromS3(pagePath string) (string, error) {
	bucketName, ok1 := os.LookupEnv("S3_BUCKET_NAME")
	if !ok1 {
		return "", fmt.Errorf(web.Stderr.EnvVarUnset, "S3_BUCKET_NAME")
	}

	s3svc := is3.NewClient(bucketName)
	if s3svc == nil {
		log.Errf(web.Stderr.NoS3ClientOrContext)
	}

	return s3svc.Download(pagePath, ilambda.GetContextWithTimeout(time.Second*5))
}
