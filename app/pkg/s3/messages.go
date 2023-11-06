package s3

var Stdout = struct {
	ReadingObject string
}{
	ReadingObject: "reading object %v",
}

var Stderr = struct {
	CannotDownLoadKey  string
	CannotReadObject   string
	InvalidObjectState string
	NoSuchKey          string
}{
	CannotDownLoadKey:  "cannot download key %v from bucket %v: %v",
	CannotReadObject:   "cannot read object key %v: %v",
	InvalidObjectState: "s3 invalid object state: %v",
	NoSuchKey:          "no such key %v",
}
