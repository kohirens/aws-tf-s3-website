package s3

import (
	"bytes"
	"context"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/kohirens/aws-tf-s3-wesbite/app/pkg/web"
	"github.com/kohirens/stdlib/log"
)

type Client struct {
	Name string
	Svc  *s3.S3
}

func NewClient(bucketName string) *Client {
	sess := session.Must(session.NewSession())

	// Create service client value configured for credentials
	// from assumed role.
	return &Client{
		Name: bucketName,
		Svc:  s3.New(sess),
	}
}

func (c *Client) Move(b []byte, oldKey, newKey string, ctx context.Context) error {
	log.Infof(web.Stdout.S3Move, oldKey, newKey)

	// Uploads the object to S3. The Context will interrupt the request if the
	// timeout expires.
	put, err1 := c.Svc.PutObjectWithContext(ctx, &s3.PutObjectInput{
		Bucket:               &c.Name,
		Key:                  &newKey,
		Body:                 aws.ReadSeekCloser(bytes.NewReader(b)),
		ServerSideEncryption: aws.String("AES256"),
	})

	if err1 != nil {
		return err1
	}

	log.Infof("%v", put.String())

	// Delete an object from S3. The Context will interrupt the request if the
	// timeout expires.
	del, err2 := c.Svc.DeleteObjectWithContext(ctx, &s3.DeleteObjectInput{
		Bucket: &c.Name,
		Key:    &oldKey,
	})

	if err2 != nil {
		return err2
	}

	log.Logf("%v", del.String())

	return nil
}

// Upload Uploads an object to S3. The Context will interrupt the request if the timeout expires
// see also https://docs.aws.amazon.com/sdk-for-go/api/service/s3/#example_S3_PutObject_shared00
func (c *Client) Upload(b []byte, key string, svc *s3.S3, ctx context.Context) error {
	log.Infof(web.Stdout.S3Upload, key)
	put, err1 := svc.PutObjectWithContext(ctx, &s3.PutObjectInput{
		Bucket:               &c.Name,
		Key:                  &key,
		Body:                 aws.ReadSeekCloser(bytes.NewReader(b)), //bytes.NewReader(b),
		ServerSideEncryption: aws.String("AES256"),
	})

	if err1 != nil {
		return err1
	}

	log.Logf("%v", put.String())

	return nil
}

// Download an object to S3. The Context will interrupt the request if the timeout expires
// see also https://docs.aws.amazon.com/sdk-for-go/api/service/s3/#example_S3_GetObject_shared00
func (c *Client) Download(key string, ctx context.Context) (string, error) {
	log.Infof(web.Stdout.S3Download, key)

	out, err1 := c.Svc.GetObject(&s3.GetObjectInput{
		Bucket: &c.Name,
		Key:    &key,
	})

	if err1 != nil {
		return "", err1
	}

	log.Logf("%v", out.String())

	return out.String(), nil
}
