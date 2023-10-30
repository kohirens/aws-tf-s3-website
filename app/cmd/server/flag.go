package main

import (
	"flag"
	"github.com/kohirens/stdlib/log"
)

type flagOptions struct {
	version   bool
	verbosity int
}

var flags = &flagOptions{}

var um = map[string]string{
	"version":   "Print build version information and exit 0.",
	"verbosity": "Set the verbosity level from 0-6, 6 being the loudest.",
}

// Define all application flags.
func init() {
	flag.BoolVar(&flags.version, "version", false, um["version"])
	flag.IntVar(&flags.verbosity, "verbosity", log.VerboseLvlLog, um["verbosity"])
	flag.Parse()
}
