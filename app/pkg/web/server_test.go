package web

import (
	"os"
	"testing"
)

func TestDoRedirect(t *testing.T) {
	tests := []struct {
		name    string
		host    string
		rt      string
		rh      string
		want    bool
		wantErr bool
	}{
		{
			"env var REDIRECT_TO not set",
			"www.example.com",
			"",
			"",
			false,
			true,
		},
		{
			"does not redirect host",
			"www.example.com",
			"www.example.com",
			"example.com",
			false,
			false,
		},
		{
			"redirect host",
			"example.com",
			"www.example.com",
			"example.com",
			true,
			false,
		},
		{
			"redirect host",
			"example.com",
			"www.example.com",
			"example.com",
			true,
			false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if tt.rt != "" {
				_ = os.Setenv("REDIRECT_TO", tt.rt)
				defer func() { _ = os.Unsetenv("REDIRECT_TO") }()
			}
			if tt.rh != "" {
				_ = os.Setenv("REDIRECT_HOSTS", tt.rh)
				defer func() { _ = os.Unsetenv("REDIRECT_HOSTS") }()
			}

			got, err := ShouldRedirect(tt.host)

			if (err != nil) != tt.wantErr {
				t.Errorf("ShouldRedirect() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if tt.want != got {
				t.Errorf("ShouldRedirect() got = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestDoRedirect2(t *testing.T) {
	tests := []struct {
		name    string
		host    string
		to      string
		hosts   string
		want    bool
		wantErr bool
	}{
		{
			"cannot get host from request",
			"",
			"www.example.com",
			"example.com",
			false,
			true,
		},
		{
			"REDIRECT_TO is set to empty string",
			"www.example.com",
			"",
			"example.com",
			false,
			true,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_ = os.Setenv("REDIRECT_TO", tt.to)
			defer func() { _ = os.Unsetenv("REDIRECT_TO") }()
			_ = os.Setenv("REDIRECT_HOSTS", tt.hosts)
			defer func() { _ = os.Unsetenv("REDIRECT_HOSTS") }()

			got, err := ShouldRedirect(tt.host)

			if (err != nil) != tt.wantErr {
				t.Errorf("ShouldRedirect() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if tt.want != got {
				t.Errorf("ShouldRedirect() got = %v, want %v", got, tt.want)
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
