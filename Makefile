
# products
PRODUCT=urlenc

# build and packaging
MAIN := ./cmd/urlenc
BIN = $(PWD)/bin
SRC = $(shell find cmd -name \*.go -print)

# fix our gopath
GOPATH := $(GOPATH):$(PWD)
GOOS   ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)

# build and packaging for release
GITHASH := $(shell git log --pretty=format:'%h' -n 1)
VERSION ?= $(GITHASH)
RELEASE_BUILD = $(PWD)/target
RELEASE_TARGETS = $(PWD)/target/$(GOOS)_$(GOARCH)
RELEASE_PRODUCT = $(PRODUCT)-$(GITHASH)
RELEASE_ARCHIVE = $(RELEASE_PRODUCT)-$(GOOS)-$(GOARCH).tgz
RELEASE_PACKAGE = $(RELEASE_TARGETS)/$(RELEASE_ARCHIVE)
RELEASE_BASE = $(RELEASE_TARGETS)/$(RELEASE_PRODUCT)/bin

TEST_PKGS ?= encode/...

.PHONY: all test urlenc install release build archive clean

all: build

# build and install
PREFIX ?= /usr/local

.PHONY: all encode decode

all: urlenc

$(TARGETS):
	mkdir -p $(TARGETS)

urlenc: $(BIN)/$(PRODUCT)

$(BIN)/$(PRODUCT): $(TARGETS) $(SRC)
	go build -ldflags "-X main.mode=enc -X main.version=$(VERSION) -X main.githash=$(GITHASH)" -o $(BIN)/$(PRODUCT) $(MAIN)

install: urlenc ## Build and install
	install -m 0755 $(BIN)/$(PRODUCT) $(PREFIX)/bin 

$(RELEASE_BASE)/$(PRODUCT): $(SRC)
	go build -ldflags "-X main.mode=enc -X main.version=$(VERSION) -X main.githash=$(GITHASH)" -o $(RELEASE_BASE)/$(PRODUCT) $(MAIN)

$(RELEASE_PACKAGE): $(RELEASE_BASE)/$(PRODUCT)
	(cd $(RELEASE_TARGETS) && tar -zcf $(RELEASE_ARCHIVE) $(RELEASE_PRODUCT))

archive: $(RELEASE_PACKAGE)

test: ## Run tests
	go test $(TEST_PKGS)

clean: ## Delete the built product and any generated files
	rm -rf $(BIN) $(RELEASE_BUILD)
