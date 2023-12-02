package s3

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/kohirens/stdlib/log"
	"io"
)

type Client struct {
	Name string
	Svc  *s3.S3
}

func (c *Client) Move(b []byte, oldKey, newKey string, ctx context.Context) error {
	log.Infof(Stdout.S3Move, oldKey, newKey)

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
	log.Infof(Stdout.S3Upload, key)
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
	log.Infof(Stdout.S3Download, key)

	obj, e1 := c.Svc.GetObject(&s3.GetObjectInput{
		Bucket: &c.Name,
		Key:    &key,
	})

	if e1 != nil {
		e := DecodeError(e1)
		return "", fmt.Errorf(Stderr.CannotDownLoadKey, key, c.Name, e.Error())
	}

	log.Infof(Stdout.ReadingObject, key)

	b, e2 := io.ReadAll(obj.Body)
	if e2 != nil {
		return "", fmt.Errorf(Stderr.CannotReadObject, key)
	}

	return string(b), nil
}

// DecodeError Put an S3 error into context or something more human relatable.
func DecodeError(e1 error) error {
	var aErr awserr.Error

	ok := errors.As(e1, &aErr)

	if ok {
		switch aErr.Code() {
		case s3.ErrCodeNoSuchKey:
			return fmt.Errorf(Stderr.NoSuchKey, aErr.Error())
		case s3.ErrCodeInvalidObjectState:
			return fmt.Errorf(Stderr.InvalidObjectState, aErr.Error())
		}
	}

	return e1
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
