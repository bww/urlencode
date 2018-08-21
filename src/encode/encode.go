package main

import (
  "os"
  "fmt"
  "strings"
  "net/url"
  "io/ioutil"
)

var mode string 
const (
  encode = "enc"
  decode = "dec"
)

func main() {
  data, err := ioutil.ReadAll(os.Stdin)
  if err != nil {
    panic(err)
  }
  
  v := strings.TrimSpace(string(data))
  switch mode {
  case encode:
    fmt.Println(url.QueryEscape(v))
  case decode:
    d, err := url.QueryUnescape(v) 
    if err != nil {
      fmt.Printf("Invalid: %v\n", err)
    }
    fmt.Println(d)
  default:
    fmt.Printf("Unsupported mode: %v\n", mode)
  }
}
