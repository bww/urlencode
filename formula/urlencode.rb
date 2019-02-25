
class Urlencode < Formula
  homepage "https://github.com/bww/urlencode"
  url "https://github.com/bww/urlencode/releases/download/v1.0/urlencode-v1.0-darwin-amd64.tgz"
  sha256 "4fcf5164fc01b85ac42b10f783cf59fa5344ee4bec84aed3737671e84ab62eff"
  version "v1.0"
  
  def install
    system "install", "-d", "#{bin}"
    system "install", "-m", "0755", "bin/urlenc", "#{bin}/urlenc"
    system "install", "-m", "0755", "bin/urldec", "#{bin}/urldec"
  end
end
