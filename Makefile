
# products
ENCODE=urlenc
DECODE=urldec

# build and packaging
MAIN := ./src/encode
BIN = $(PWD)/bin
SRC = $(shell find src -name \*.go -print)

# fix our gopath
GOPATH := $(GOPATH):$(PWD)

# build and packaging for release
GITHASH := $(shell git log --pretty=format:'%h' -n 1)
VERSION ?= $(GITHASH)
RELEASE_BUILD = $(PWD)/target
RELEASE_TARGETS = $(PWD)/target/$(GOOS)_$(GOARCH)
RELEASE_PRODUCT = urldecode-$(VERSION)
RELEASE_ARCHIVE = $(RELEASE_PRODUCT)-$(GOOS)-$(GOARCH).tgz
RELEASE_PACKAGE = $(RELEASE_TARGETS)/$(RELEASE_ARCHIVE)
RELEASE_BASE = $(RELEASE_TARGETS)/$(RELEASE_PRODUCT)/bin

TEST_PKGS ?= encode/...

.PHONY: all test encode decode install release build build_release build_formula clean

all: build

# build and install
PREFIX ?= /usr/local

.PHONY: all encode decode

all: encode decode

$(TARGETS):
	mkdir -p $(TARGETS)

encode: $(BIN)/$(ENCODE)

$(BIN)/$(ENCODE): $(TARGETS) $(SRC)
	go build -ldflags "-X main.mode=enc -X main.version=$(VERSION) -X main.githash=$(GITHASH)" -o $(BIN)/$(ENCODE) $(MAIN)

decode: $(BIN)/$(DECODE)

$(BIN)/$(DECODE): $(TARGETS) $(SRC)
	go build -ldflags "-X main.mode=dec -X main.version=$(VERSION) -X main.githash=$(GITHASH)" -o $(BIN)/$(DECODE) $(MAIN)

install: encode decode ## Build and install
	install -m 0755 $(BIN)/$(ENCODE) $(BIN)/$(DECODE) $(PREFIX)/bin 

$(RELEASE_BASE)/$(ENCODE): $(SRC)
	go build -ldflags "-X main.mode=enc -X main.version=$(VERSION) -X main.githash=$(GITHASH)" -o $(RELEASE_BASE)/$(ENCODE) $(MAIN)

$(RELEASE_BASE)/$(DECODE): $(SRC)
	go build -ldflags "-X main.mode=dec -X main.version=$(VERSION) -X main.githash=$(GITHASH)" -o $(RELEASE_BASE)/$(DECODE) $(MAIN)

$(RELEASE_PACKAGE): $(RELEASE_BASE)/$(ENCODE) $(RELEASE_BASE)/$(DECODE)
	(cd $(RELEASE_TARGETS) && tar -zcf $(RELEASE_ARCHIVE) $(RELEASE_PRODUCT))

build_release: $(RELEASE_PACKAGE)

build_formula: build_release
	$(PWD)/tools/update-formula -v $(VERSION) -o $(PWD)/formula/urlencode.rb $(RELEASE_PACKAGE)

release: test ## Build for all supported architectures
	make build_release GOOS=linux GOARCH=amd64
	make build_release GOOS=freebsd GOARCH=amd64
	make build_formula GOOS=darwin GOARCH=amd64

test: ## Run tests
	go test $(TEST_PKGS)

clean: ## Delete the built product and any generated files
	rm -rf $(BIN) $(RELEASE_BUILD)
