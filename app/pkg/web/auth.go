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

// RequiredCode Look for a header REQUIRED_CODE and match it against an
// environment variable, allowing access if they match.
func RequiredCode(headers map[string]string) error {
	requiredCode := GetHeader(headers, "REQUIRED_CODE")

	if requiredCode == "" {
		return fmt.Errorf(Stderr.AuthHeaderMissing)
	}

	localRequiredCode, uOk := os.LookupEnv("REQUIRED_CODE")
	if !uOk {
		return fmt.Errorf(Stderr.AuthCodeNotSet)
	}

	if requiredCode != localRequiredCode {
		return fmt.Errorf(Stderr.AuthCodeInvalid)
	}

	return nil
}
