package web

import (
	"encoding/base64"
	"fmt"
	"os"
	"strings"
)

const (
	basicUserEnv = "BASIC_USER"
	basicPassEnv = "BASIC_PASS"
)

// Authenticate Challenge user access.
func Authenticate(headers map[string]string) error {
	user, uOk := os.LookupEnv(basicUserEnv)
	if !uOk {
		return fmt.Errorf(Stderr.AuthServer)
	}

	pass, pOk := os.LookupEnv(basicPassEnv)
	if !pOk {
		return fmt.Errorf(Stderr.AuthServer)
	}

	authString := "Basic " + base64.StdEncoding.EncodeToString([]byte(user+":"+pass))
	authHeader := ""
	for k, v := range headers {
		if strings.ToLower(k) == "authorization" {
			authHeader = v
			break
		}
	}

	if authHeader == "" {
		return fmt.Errorf("missing authorization header")

	}

	if authString != authHeader {
		return fmt.Errorf("incorrect username or password")
	}

	return nil
}
