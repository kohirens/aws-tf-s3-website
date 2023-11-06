package web

var Stdout = struct {
	BytesRead  string
	ConnectTo  string
	LoadPage   string
	RunCli     string
	S3Download string
	S3Move     string
	S3Upload   string
}{
	BytesRead:  "number of bytes read from %v is %d",
	ConnectTo:  "connecting to %v",
	LoadPage:   "loading the %v page",
	RunCli:     "Running CLI",
	S3Download: "will download file %v to %v ",
	S3Move:     "will move file from %v to %v ",
	S3Upload:   "will upload file %v to %v ",
}

var Stderr = struct {
	AuthCodeInvalid     string
	AuthCodeNotSet      string
	AuthHeaderMissing   string
	AuthServer          string
	CannotCloseFile     string
	CannotGetExt        string
	CannotLoadPage      string
	CannotOpenFile      string
	CannotParseFile     string
	CannotReadFile      string
	EnvVarUnset         string
	FatalHeader         string
	FileNotFound        string
	InsufficientArgs    string
	InvalidArgs         string
	NoS3ClientOrContext string
	S3Move              string
	S3Upload            string
}{
	AuthCodeInvalid:     "incorrect authorization code was sent",
	AuthCodeNotSet:      "authorization code was not set in the environment",
	AuthHeaderMissing:   "authorization header missing",
	AuthServer:          "unable to authenticate there is a problem on the server",
	CannotCloseFile:     "failed to close file: %v",
	CannotGetExt:        "failed to close file: %v",
	CannotLoadPage:      "could not load the page %v",
	CannotOpenFile:      "failed to open file: %v",
	CannotParseFile:     "failed to parse XSD: %v",
	CannotReadFile:      "failed to read file %v: %v",
	EnvVarUnset:         "environment variable %v has not been set",
	FatalHeader:         "fatal error detected: %v",
	FileNotFound:        "could not find file %v",
	InsufficientArgs:    "please provide required arguments domain, path, method, and a directory public website files",
	InvalidArgs:         "please specify a correct type of (types are invoice|pick-ticket|purchase-order)",
	NoS3ClientOrContext: "could not init an s3 client or context",
	S3Move:              "could not move %v file in s3: %v",
	S3Upload:            "could not upload %v file to s3: %v",
}
