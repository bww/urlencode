package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"net/url"
	"os"
	"path"
	"strings"
)

var ( // set at compile time via the linker
	version = "v0.0.0"
	githash = "000000"
)

var (
	verbose bool
	pretty  bool
	exe     string
)

func init() {
	exe = path.Base(os.Args[0])
}

func main() {
	err := cmd()
	if err != nil {
		fmt.Println("***", err)
		os.Exit(1)
	}
}

func cmd() error {
	cmdline := flag.NewFlagSet(os.Args[0], flag.ExitOnError)
	var (
		fVerbose = cmdline.Bool("verbose", false, "Be more verbose.")
		fPretty  = cmdline.Bool("pretty", false, "Print output more legibly.")
	)
	cmdline.Parse(os.Args[1:])

	verbose = *fVerbose
	pretty = *fPretty

	args := cmdline.Args()
	if len(args) < 1 {
		return help()
	}

	switch c := args[0]; c {
	case "enc":
		return encode(args[1:])
	case "dec":
		return decode(args[1:])
	case "list":
		return list(args[1:])
	case "query":
		return query(args[1:])
	case "version":
		return info()
	case "help":
		return help()
	default:
		return fmt.Errorf("Unsupported command: %v;\n\ttry: %v help", c, exe)
	}
}

func encode(args []string) error {
	data, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		return err
	}

	v := url.QueryEscape(strings.TrimSpace(string(data)))
	fmt.Println(v)

	return nil
}

func decode(args []string) error {
	var extractKeys flagList

	cmdline := flag.NewFlagSet(os.Args[0], flag.ExitOnError)
	cmdline.Var(&extractKeys, "key", "Extract the value associated with the provided key. Provide -key repeatedly to extract multiple values.")
	cmdline.Parse(os.Args[1:])

	data, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		return err
	}

	v, err := url.QueryUnescape(strings.TrimSpace(string(data)))
	if err != nil {
		return err
	}

	if len(extractKeys) < 1 {
		fmt.Println(v)
		return nil
	}

	u, err := url.ParseQuery(v)
	if err != nil {
		return err
	}

	for _, e := range extractKeys {
		if verbose {
			fmt.Printf("%s: %s\n", e, u.Get(e))
		} else {
			fmt.Println(u.Get(e))
		}
	}

	return nil
}

func query(args []string) error {
	data, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		return err
	}

	params := url.Values{}
	lines := strings.Split(strings.TrimSpace(string(data)), "\n")
	for _, e := range lines {
		e = strings.TrimSpace(e)
		if x := strings.IndexAny(e, ":="); x > 0 {
			params.Add(strings.TrimSpace(e[:x]), strings.TrimSpace(e[x+1:]))
		}
	}

	fmt.Println(params.Encode())
	return nil
}

func list(args []string) error {
	data, err := ioutil.ReadAll(os.Stdin)
	if err != nil {
		return err
	}

	u, err := url.ParseQuery(strings.TrimSpace(string(data)))
	if err != nil {
		return err
	}

	var w int
	var wf string
	for k, _ := range u {
		if l := len(k); l > w {
			w = l
		}
	}
	wf = fmt.Sprintf("%%%ds", w)

	for k, v := range u {
		fmt.Printf(wf+": %s\n", k, strings.Join(v, ", "))
	}

	return nil
}

func info() error {
	if version == githash {
		fmt.Println(version)
	} else {
		fmt.Printf("%s (%s)\n", version, githash)
	}
	return nil
}

func help() error {
	fmt.Printf(`%s [global options] <command> [options]

Commands:
    enc        Encode URL parameters
    dec        Decode URL parameters
    list       Parse and list URL parameters
    query      Parse key/value pairs and encode the output as a query string
    version    Display version information
    help       Display this help information

For help on a command, use:
    $ %s <command> -h

`, exe, exe)
	return nil
}

type flagList []string

func (s *flagList) Set(v string) error {
	*s = append(*s, v)
	return nil
}

func (s *flagList) String() string {
	return fmt.Sprintf("%+v", *s)
}
