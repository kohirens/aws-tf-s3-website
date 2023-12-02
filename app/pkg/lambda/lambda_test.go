package lambda

import "testing"

func TestGetCookie(t *testing.T) {
	tests := []struct {
		name    string
		cookies []string
		cname   string
		want    string
	}{
		{"cookie1", []string{"Cookie_1=Value1; Expires=21 Oct 2021 07:48 GMT"}, "Cookie_1", "Value1"},
		{"cookie2", []string{"Cookie_2=Value2; Max-Age=78000"}, "Cookie_2", "Value2"},
		{"cookie2", []string{"Cc3=Value3"}, "Cc3", "Value3"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := GetCookie(tt.cookies, tt.cname); got != tt.want {
				t.Errorf("GetCookie() = %v, want %v", got, tt.want)
			}
		})
	}
}
