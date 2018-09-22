class Snap < Formula
  desc "Tool to interact with snaps"
  homepage "https://snapcraft.io/"
  head "https://github.com/snapcore/snapd.git"

  depends_on "go" => :build
  depends_on "squashfs"

  def install
    ENV["GOPATH"] = "#{buildpath}"
    ENV["GOCACHE"] = "#{HOMEBREW_CACHE}/go_cache"
    (buildpath/"src/github.com/snapcore/snapd").install buildpath.children

    cd "src/github.com/snapcore/snapd" do
      system "./get-deps.sh"
      system "go", "get", "golang.org/x/sys/unix"
      system "./mkversion.sh"
      system "go", "build", "-o", bin/"snap", "./cmd/snap"

      # Build bash completion
      bash_completion.install "data/completion/snap"

      # Build manpage
      system "sh", "-c", "#{bin}/snap help --man > snap.8"
      man8.install "snap.8"

      prefix.install_metafiles
    end
  end

  test do
    system "#{bin}/snap", "version"
  end
end
