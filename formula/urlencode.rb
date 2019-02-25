
class Urlencode < Formula
  homepage "https://github.com/bww/urlencode"
  url "https://github.com/bww/urlencode/releases/download/013bad5/urlencode-013bad5-darwin-amd64.tgz"
  sha256 "fc4ff4fb3aa0939b11bde2acc0402509d7ee6cfc451be51f9622176d6551e540"
  version "013bad5"
  
  def install
    system "install", "-d", "#{bin}"
    system "install", "-m", "0755", "bin/urlenc", "#{bin}/urlenc"
    system "install", "-m", "0755", "bin/urldec", "#{bin}/urldec"
  end
end
