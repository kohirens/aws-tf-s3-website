package web

var Stdout = struct {
	BytesRead   string
	ConnectTo   string
	EnvVarEmpty string
	LoadPage    string
	RunCli      string
}{
	BytesRead:   "number of bytes read from %v is %d",
	ConnectTo:   "connecting to %v",
	EnvVarEmpty: "environment variable $v is empty",
	LoadPage:    "loading the %v page",
	RunCli:      "Running CLI",
}

var Stderr = struct {
	AuthCodeInvalid     string
	AuthCodeNotSet      string
	AuthHeaderMissing   string
	CannotCloseFile     string
	CannotEncodeToJson  string
	CannotGetExt        string
	CannotLoadPage      string
	CannotOpenFile      string
	CannotParseFile     string
	CannotReadFile      string
	EnvVarUnset         string
	FatalHeader         string
	FileNotFound        string
	HostNotSet          string
	InsufficientArgs    string
	InvalidArgs         string
	DoNoRedirectToSelf  string
	NoS3ClientOrContext string
	RedirectToEmpty     string
	S3Move              string
	S3Upload            string
}{
	AuthCodeInvalid:     "incorrect authorization code was sent",
	AuthCodeNotSet:      "authorization code was not set in the environment",
	AuthHeaderMissing:   "authorization header is missing",
	CannotCloseFile:     "failed to close file: %v",
	CannotEncodeToJson:  "failed to JSON encode content: %v",
	CannotGetExt:        "failed to close file: %v",
	CannotLoadPage:      "could not load the page %v",
	CannotOpenFile:      "failed to open file: %v",
	CannotParseFile:     "failed to parse XSD: %v",
	CannotReadFile:      "failed to read file %v: %v",
	EnvVarUnset:         "environment variable %v has not been set",
	FatalHeader:         "fatal error detected: %v",
	FileNotFound:        "could not find file %v",
	HostNotSet:          "could not retrieve the host from the request",
	InsufficientArgs:    "please provide required arguments domain, path, method, and a directory public website files",
	InvalidArgs:         "please specify a correct type of (types are invoice|pick-ticket|purchase-order)",
	DoNoRedirectToSelf:  "do not redirect %v to host %v",
	NoS3ClientOrContext: "could not init an s3 client or context",
	RedirectToEmpty:     "the REDIRECT_TO environment variables was empty",
	S3Move:              "could not move %v file in s3: %v",
	S3Upload:            "could not upload %v file to s3: %v",
}
