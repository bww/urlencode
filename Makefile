
# products
PRODUCT=urlenc

# build and packaging
MAIN := ./cmd/urlenc
BIN = $(PWD)/bin
SRC = $(shell find cmd -name \*.go -print)

# fix our gopath
GOPATH := $(GOPATH):$(PWD)

# build and packaging for release
GITHASH := $(shell git log --pretty=format:'%h' -n 1)
VERSION ?= $(GITHASH)
RELEASE_BUILD = $(PWD)/target
RELEASE_TARGETS = $(PWD)/target/$(GOOS)_$(GOARCH)
RELEASE_PRODUCT = urlencode-$(VERSION)
RELEASE_ARCHIVE = $(RELEASE_PRODUCT)-$(GOOS)-$(GOARCH).tgz
RELEASE_PACKAGE = $(RELEASE_TARGETS)/$(RELEASE_ARCHIVE)
RELEASE_BASE = $(RELEASE_TARGETS)/$(RELEASE_PRODUCT)/bin

TEST_PKGS ?= encode/...

.PHONY: all test urlenc install release build build_release build_formula clean

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
