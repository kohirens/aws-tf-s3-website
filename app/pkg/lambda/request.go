package lambda

import "github.com/kohirens/stdlib/cli"

type Context struct {
	DistributionDomainName string `json:"distributionDomainName"`
	DistributionId         string `json:"distributionId"`
	EventType              string `json:"eventType"`
	RequestId              string `json:"requestId"`
}

type Http struct {
	Method    string `json:"method"`
	Path      string `json:"path"`
	Protocol  string `json:"protocol"`
	SourceIp  string `json:"sourceIp"`
	UserAgent string `json:"userAgent"`
}

type Iam struct {
	AccessKey       string      `json:"accessKey"`
	AccountId       string      `json:"accountId"`
	CallerId        string      `json:"callerId"`
	CognitoIdentity interface{} `json:"cognitoIdentity"`
	PrincipalOrgId  interface{} `json:"principalOrgId"`
	UserArn         string      `json:"userArn"`
	UserId          string      `json:"userId"`
}

type Authorizer struct {
	Iam Iam `json:"iam"`
}

type RequestContext struct {
	AccountId      string      `json:"accountId"`
	ApiId          string      `json:"apiId"`
	Authentication interface{} `json:"authentication"`
	Authorizer     Authorizer  `json:"authorizer"`
	DomainName     string      `json:"domainName"`
	DomainPrefix   string      `json:"domainPrefix"`
	Http           Http        `json:"http"`
	RequestId      string      `json:"requestId"`
	RouteKey       string      `json:"routeKey"`
	Stage          string      `json:"stage"`
	Time           string      `json:"time"`
	TimeEpoch      int64       `json:"timeEpoch"`
}

type Request struct {
	Context               Context        `json:"context"`
	Version               string         `json:"version"`
	RouteKey              string         `json:"routeKey"`
	RawPath               string         `json:"rawPath"`
	RawQueryString        string         `json:"rawQueryString"`
	Cookies               []string       `json:"cookies"`
	Headers               cli.StringMap  `json:"headers"`
	QueryStringParameters cli.StringMap  `json:"queryStringParameters"`
	RequestContext        RequestContext `json:"requestContext"`
	Body                  string         `json:"body"`
	PathParameters        interface{}    `json:"pathParameters"`
	IsBase64Encoded       bool           `json:"isBase64Encoded"`
	StageVariables        interface{}    `json:"stageVariables"`
}
