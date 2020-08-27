class Snap < Formula
  desc "Tool to interact with snaps"
  homepage "https://snapcraft.io/"

  stable do
    version "2.46"
    url "https://github.com/snapcore/snapd/releases/download/#{version}/snapd_#{version}.vendor.tar.xz"
    sha256 "c4f532018ca9d2a5f87a95909b3674f8e299e97ba5cb5575895bcdd29be23db3"
  end

  head do
    url "https://github.com/snapcore/snapd.git"
  end

  depends_on "go" => :build
  depends_on "squashfs"

  def install
    ENV["GOPATH"] = "#{buildpath}"
    ENV["GOCACHE"] = "#{HOMEBREW_CACHE}/go_cache"
    (buildpath/"src/github.com/snapcore/snapd").install buildpath.children

    cd "src/github.com/snapcore/snapd" do
      system "go", "get", "golang.org/x/sys/unix"

      if version.head?
        system "./get-deps.sh"
        system "./mkversion.sh"
      elsif revision > 0
        system "./mkversion.sh", "#{version}-#{revision}"
      else
        system "./mkversion.sh", "#{version}"
      end

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
