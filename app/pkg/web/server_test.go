package web

import (
	"os"
	"testing"
)

func TestDoRedirect(t *testing.T) {
	tests := []struct {
		name    string
		host    string
		method  string
		to      string
		hosts   string
		want    *Response
		wantErr bool
	}{
		{
			"env var REDIRECT_TO not set",
			"www.example.com",
			"GET",
			"",
			"",
			nil,
			true,
		},
		{
			"does not redirect host",
			"www.example.com",
			"GET",
			"www.example.com",
			"example.com",
			nil,
			false,
		},
		{
			"redirect host",
			"example.com",
			"GET",
			"www.example.com",
			"example.com",
			&Response{StatusCode: 301},
			false,
		},
		{
			"redirect host",
			"example.com",
			"POST",
			"www.example.com",
			"example.com",
			&Response{StatusCode: 308},
			false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if tt.to != "" {
				_ = os.Setenv("REDIRECT_TO", tt.to)
				defer func() { _ = os.Unsetenv("REDIRECT_TO") }()
			}
			if tt.hosts != "" {
				_ = os.Setenv("REDIRECT_HOSTS", tt.hosts)
				defer func() { _ = os.Unsetenv("REDIRECT_HOSTS") }()
			}

			got, err := DoRedirect(tt.host, tt.method)

			if (err != nil) != tt.wantErr {
				t.Errorf("DoRedirect() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if tt.want != nil && got.StatusCode != tt.want.StatusCode {
				t.Errorf("DoRedirect() got = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestDoRedirect2(t *testing.T) {
	tests := []struct {
		name    string
		host    string
		method  string
		to      string
		hosts   string
		want    *Response
		wantErr bool
	}{
		{
			"cannot get host from request",
			"",
			"GET",
			"www.example.com",
			"example.com",
			nil,
			true,
		},
		{
			"REDIRECT_TO is set to empty string",
			"www.example.com",
			"GET",
			"",
			"example.com",
			nil,
			true,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_ = os.Setenv("REDIRECT_TO", tt.to)
			defer func() { _ = os.Unsetenv("REDIRECT_TO") }()
			_ = os.Setenv("REDIRECT_HOSTS", tt.hosts)
			defer func() { _ = os.Unsetenv("REDIRECT_HOSTS") }()

			got, err := DoRedirect(tt.host, tt.method)

			if (err != nil) != tt.wantErr {
				t.Errorf("DoRedirect() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if tt.want != nil {
				t.Errorf("DoRedirect() got = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestNotImplemented(t *testing.T) {
	tests := []struct {
		name   string
		method string
		want   bool
	}{
		{"head", "HEAD", true},
		{"get", "GET", false},
		{"POST", "POST", false},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := NotImplemented(tt.method); got != tt.want {
				t.Errorf("NotImplemented() = %v, want %v", got, tt.want)
			}
		})
	}
}
