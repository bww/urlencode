
class Urlencode < Formula
  homepage "https://github.com/bww/urlencode"
  url "https://github.com/bww/urlencode/releases/download/v1.0/urlencode-v1.0-darwin-amd64.tgz"
  sha256 "b220951113eb8511a17bb72a87a066cecc5cadea988df5c34605945a252f3a95"
  version "v1.0"
  
  def install
    system "install", "-d", "#{bin}"
    system "install", "-m", "0755", "bin/urlenc", "#{bin}/urlenc"
    system "install", "-m", "0755", "bin/urldec", "#{bin}/urldec"
  end
end
