package lambda

var Stdout = struct {
}{}

var Stderr = struct {
	CannotLoadPage     string
	InvalidObjectState string
	S3NoSuchKey        string
}{
	CannotLoadPage:     "could not load the page %v",
	InvalidObjectState: "s3 invalid object state: %v",
	S3NoSuchKey:        "no such key %v",
}
