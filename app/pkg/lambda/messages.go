package lambda

var Stdout = struct {
}{}

var Stderr = struct {
	CannotLoadPage     string
	S3InvalidObjectState string
	S3NoSuchKey        string
    CannotDownLoadKey string
}{
	CannotLoadPage:     "could not load the page %v",
	S3InvalidObjectState: "s3 invalid object state: %v",
	S3NoSuchKey:        "no such key %v",
}
