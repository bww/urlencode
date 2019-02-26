package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"net/url"
	"os"
	"strings"
)

var ( // set at compile time via the linker
	version = "v0.0.0"
	githash = "000000"
)

func main() {
	var err error
	var extractKeys flagList

	cmdline := flag.NewFlagSet(os.Args[0], flag.ExitOnError)
	var (
		fEncode  = cmdline.Bool("enc", false, "URLencode the input.")
		fDecode  = cmdline.Bool("dec", false, "URLdecode the input.")
		fVerbose = cmdline.Bool("verbose", false, "Be more verbose.")
		fVersion = cmdline.Bool("version", false, "Display the version.")
	)
	cmdline.Var(&extractKeys, "key", "Extract the value associated with the provided key. Provide -key repeatedly to extract multiple values.")
	cmdline.Parse(os.Args[1:])

	if *fVersion {
		if version == githash {
			fmt.Println(version)
		} else {
			fmt.Printf("%s (%s)\n", version, githash)
		}
		return
	}

	data, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		panic(err)
	}

	v := strings.TrimSpace(string(data))
	if *fEncode {
		v = url.QueryEscape(v)
	} else if *fDecode {
		v, err = url.QueryUnescape(v)
		if err != nil {
			fmt.Printf("Invalid: %v\n", err)
		}
	}

	if len(extractKeys) < 1 {
		fmt.Println(v)
		return
	}

	u, err := url.ParseQuery(v)
	if err != nil {
		fmt.Printf("Invalid: %v\n", err)
	}
	for _, e := range extractKeys {
		if *fVerbose {
			fmt.Printf("%s: %s\n", e, u.Get(e))
		} else {
			fmt.Println(u.Get(e))
		}
	}
}

type flagList []string

func (s *flagList) Set(v string) error {
	*s = append(*s, v)
	return nil
}

func (s *flagList) String() string {
	return fmt.Sprintf("%+v", *s)
}
