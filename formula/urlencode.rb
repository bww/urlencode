
class Urlencode < Formula
  homepage "https://github.com/bww/urlencode"
  url "https://github.com/bww/urlencode/releases/download/v1.1/urlencode-v1.1-darwin-amd64.tgz"
  sha256 "f6fb5d69af1c11c00aba3e4ef0093e8e522361ba438318476d904308e80efd9d"
  version "v1.1"
  
  def install
    system "install", "-d", "#{bin}"
    system "install", "-m", "0755", "bin/urlenc", "#{bin}/urlenc"
  end
end
