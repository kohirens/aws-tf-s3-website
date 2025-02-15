package main

import (
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	ilambda "github.com/kohirens/aws-tf-s3-wesbite/app/pkg/lambda"
	s3 "github.com/kohirens/aws-tf-s3-wesbite/app/pkg/s3"
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

	vl, ok1 := os.LookupEnv("VERBOSITY_LEVEL")
	if ok1 {
		log.VerbosityLevel, mainErr = strconv.Atoi(vl)
		if mainErr != nil {
			return
		}
	}

	bucket, ok2 := os.LookupEnv("S3_BUCKET_NAME")
	if !ok2 {
		mainErr = fmt.Errorf(web.Stderr.EnvVarUnset, "S3_BUCKET_NAME")
		return
	}

	s3svc := s3.NewClient(bucket, ilambda.GetContextWithTimeout(time.Second*5))
	if s3svc == nil {
		log.Errf(web.Stderr.NoS3ClientOrContext)
	}

	handler := ilambda.NewHandler(s3svc)
	lambda.Start(handler.Bootstrap)

	log.Infof("handler returned")
}
