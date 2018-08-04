class Shfmt < Formula
  desc "Autoformat shell script source code"
  homepage "https://github.com/mvdan/sh"
  url "https://github.com/mvdan/sh/archive/v2.5.1.tar.gz"
  sha256 "e0886ee00514dd15b86d64df069ccf2b2b8defbf8c6692204d51a14a7a01b3c9"
  head "https://github.com/mvdan/sh.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "5f71a2d719627a206ad64e71a90453422ed630de5491b67ab66c758bc7609c32" => :high_sierra
    sha256 "94824ec285a4b319bfcc1fb3ff918dda0db69dd0f923cc387c52db10e18c9033" => :sierra
    sha256 "290697caa8e172e202e67d4f08e07cac6ea10e9329448be2e590137b137aa285" => :el_capitan
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/mvdan.cc").mkpath
    ln_sf buildpath, buildpath/"src/mvdan.cc/sh"
    system "go", "build", "-a", "-tags", "production brew", "-o", "#{bin}/shfmt", "mvdan.cc/sh/cmd/shfmt"
  end

  test do
    (testpath/"test").write "\t\techo foo"
    system "#{bin}/shfmt", testpath/"test"
  end
end
