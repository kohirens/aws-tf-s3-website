package web

import (
	"fmt"
	"os"
)

const (
	authHeader = "Authorization"
)

// Authenticate Challenge user access.
//
//	Expected format = "Basic " + base64("username:password")
//	In Go  for example example:
//	  auth := "Basic " + base64.StdEncoding.EncodeToString([]byte(user+":"+pass))
func Authenticate(headers map[string]string) error {
	ah := GetHeader(headers, authHeader)
	if ah == "" {
		return fmt.Errorf(Stderr.AuthHeaderMissing)
	}

	code, ok := os.LookupEnv(authHeader)
	if !ok {
		return fmt.Errorf(Stderr.AuthCodeNotSet)
	}

	if ah != "Basic "+code {
		return fmt.Errorf(Stderr.AuthCodeInvalid)
	}

	return nil
}
