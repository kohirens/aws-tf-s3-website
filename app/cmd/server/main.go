//go:generate git-tool-belt semver -save info.go -format go -packageName main -varName rtc

package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"github.com/kohirens/aws-tf-s3-wesbite/app/pkg/web"
	"github.com/kohirens/stdlib/log"
	"os"
)

// config internal runtime storage for this application
type config struct {
	// CommitHash of the current version
	CommitHash string
	// CurrentVersion Official annotated tag of HEAD at the time of release
	CurrentVersion string
}

var rtc = &config{}

func main() {
	var mainErr error

	defer func() {
		if mainErr != nil {
			log.Fatf(web.Stderr.FatalHeader, mainErr)
			os.Exit(1)
		}
		os.Exit(0)
	}()

	if flags.version {
		log.Logf("%v, %v", rtc.CurrentVersion, rtc.CommitHash)
		return
	}

	log.VerbosityLevel = flags.verbosity

	res, e1 := start(flag.Args())
	if e1 != nil {
		mainErr = e1
		return
	}

	outBits, e2 := json.Marshal(res)
	if e2 != nil {
		mainErr = e2
		return
	}

	log.Logf("response: %s", outBits)
}

func start(ca []string) (*web.Response, error) {
	log.Dbugf("ca = %v", ca)
	if len(ca) < 4 {
		return nil, fmt.Errorf(web.Stderr.InsufficientArgs)
	}

	host := ca[0]
	method := ca[2]
	source := ca[3]

	redirect, e1 := web.ShouldRedirect(host)
	if e1 != nil {
		log.Errf(e1.Error())
	}

	if redirect {
		return web.Respond301Or308(method, host), nil
	}

	pagePath := ca[1]
	ct := web.GetPageTypeByExt(pagePath)

	res, e2 := web.LoadFile(source+pagePath, ct)
	if e2 != nil {
		return nil, e2
	}

	return res, nil
}
