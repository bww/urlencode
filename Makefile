
BIN=$(PWD)/bin
SRC=$(PWD)/src/encode

SOURCES=$(SRC)/encode.go

ENCODE=urlenc
DECODE=urldec

.PHONY: all encode decode

all: encode decode

encode: $(BIN)/$(ENCODE)

$(BIN)/$(ENCODE): $(SOURCES)
	go build -ldflags "-X main.mode=enc" -o $(BIN)/$(ENCODE) $(SOURCES)

decode: $(BIN)/$(DECODE)

$(BIN)/$(DECODE): $(SOURCES)
	go build -ldflags "-X main.mode=dec" -o $(BIN)/$(DECODE) $(SOURCES)

