
BIN=$(PWD)/bin
SRC=$(PWD)/src/encode

SOURCES=$(SRC)/encode.go

.PHONY: all encode decode

all: encode decode

encode: $(BIN)/encode

$(BIN)/encode: $(SOURCES)
	go build -ldflags "-X main.mode=enc" -o $(BIN)/encode $(SOURCES)

decode: $(BIN)/decode

$(BIN)/decode: $(SOURCES)
	go build -ldflags "-X main.mode=dec" -o $(BIN)/decode $(SOURCES)

