class Hugo < Formula
  desc "Tool to interact with snaps"
  homepage "https://snapcraft.io/"
  head "https://github.com/snapcore/snapd.git"

  bottle do
    cellar :any_skip_relocation
    rebuild 1
    sha256 "15301cbfe95b5b3dbefd02ecbd59bd1155fff891f6c027e226db196090446526" => :mojave
    sha256 "357be80e0723b7ba0684be4825a66fb8ce57ee72115040d7d8feed04a68d3b2f" => :high_sierra
    sha256 "c3eea992e8609032631c1fcdf071e6196bb9249b377b1220a1f275522abbfc9b" => :sierra
    sha256 "63d95d7fd585d159474e1618929da9fae205dd0f7dd674083e804e7607d54c83" => :el_capitan
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = HOMEBREW_CACHE/"go_cache"
    (buildpath/"src/github.com/snapcore/snapd").install buildpath.children

    cd "src/github.com/snapcore/snapd" do
      system "./get-deps.sh"
      system "go", "get", "golang.org/x/sys/unix"
      system "./mkversion.sh"
      system "go", "build", "-o", bin/"snap", "cmd/snap"

      # Build bash completion
      bash_completion.install "data/completion/snap"

      # Build manpage
      # system bin/"snap", "help", "--man", "> snap.8"
      # man8.install "snap.8"

      prefix.install_metafiles
    end
  end

  test do
    system "#{bin}/snap", "version"
  end
end
