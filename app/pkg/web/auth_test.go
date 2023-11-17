package web

import (
	"encoding/base64"
	"os"
	"testing"
)

func TestAuthentication(tRunner *testing.T) {
	fixedCreds := "Basic " + base64.StdEncoding.EncodeToString([]byte("abcd:0123"))
	testcases := []struct {
		name    string
		headers map[string]string
		want    error
		wantErr bool
	}{
		{"goodCreds", map[string]string{"authorization": fixedCreds}, nil, false},
		{"wrongCreds", map[string]string{"authorization": "Basic " + "wxyz:12334"}, nil, true},
		{"missingHeader", map[string]string{"header1": "0"}, nil, true},
		{"noHeaders", nil, nil, true},
	}

	_ = os.Setenv(authHeader, fixedCreds)
	defer func() { _ = os.Unsetenv(authHeader) }()

	for _, tc := range testcases {
		tRunner.Run(tc.name, func(t *testing.T) {
			gotErr := Authenticate(tc.headers)

			if gotErr != nil && !tc.wantErr {
				tRunner.Errorf("got error %v, want no error", gotErr)
				return
			}

			if gotErr == nil && tc.wantErr {
				tRunner.Errorf("got no error, wantErr %v", tc.wantErr)
				return
			}
		})
	}
}
