# URL Encode/Decode

A command line tool for manipulating URL-encoded query strings.

### URL-encode standard input
```
$ echo -n '@#$%^&*' | urlenc enc
%40%23%24%25%5E%26%2A
```

### URL-decode standard input
```
$ echo -n '%40%23%24%25%5E%26%2A' | urlenc dec
@#$%^&*
```

### Display a query string as a list
```
$ echo -n 'foo=bar&fizz=buzz' | urlenc list
fizz: buzz
 foo: bar
```

### Encode a list as a query string
```
$ urlenc query <<EOF
> fizz: buzz
>  foo: bar
> EOF
fizz=buzz&foo=bar
```

## Building

To build the tools:
```
$ make
```

To install the tools in `$GOPATH/bin`:
```
$ make install
```

