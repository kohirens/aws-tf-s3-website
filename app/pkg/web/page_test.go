package web

import (
	"testing"
)

func TestGetHeader(t *testing.T) {
	tests := []struct {
		name    string
		headers map[string]string
		header  string
		want    string
	}{
		{"get host header", map[string]string{"host": "example.com"}, "host", "example.com"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := GetHeader(tt.headers, tt.header)

			if got != tt.want {
				t.Errorf("GetHeader() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestGetPageType(t *testing.T) {
	tests := []struct {
		name    string
		headers map[string]string
		want    string
	}{
		{"html-type", map[string]string{"content-type": "text/html"}, "text/html"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := GetPageType(tt.headers); got != tt.want {
				t.Errorf("GetPageType() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestGetPageTypeByExt(t *testing.T) {
	tests := []struct {
		name     string
		pagePath string
		want     string
	}{
		{"html", "page.html", "text/html; charset=utf-8"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := GetPageTypeByExt(tt.pagePath)

			if got != tt.want {
				t.Errorf("GetPageTypeByExt() = %v, want %v", got, tt.want)
			}
		})
	}
}
