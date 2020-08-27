class Snap < Formula
  desc "The snap tool enable systems to work with .snap files"
  homepage "https://snapcraft.io/"
  license "GPL-3.0-only"

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
    ENV["GOPATH"] = buildpath
    ENV["GOCACHE"] = "#{HOMEBREW_CACHE}/go_cache"
    (buildpath/"src/github.com/snapcore/snapd").install buildpath.children

    cd "src/github.com/snapcore/snapd" do
      if version.head?
        system "./get-deps.sh"
        system "./mkversion.sh"
      elsif revision.positive?
        system "./mkversion.sh", "#{version}-#{revision}"
      else
        system "./mkversion.sh", version
      end

      system "go", "build", "-o", bin/"snap", "./cmd/snap"

      # Build bash completion.
      bash_completion.install "data/completion/bash/snap"

      # Build zsh completion.
      zsh_completion.install "data/completion/zsh/_snap"

      # Build manpage.
      system "sh", "-c", "#{bin}/snap help --man > snap.8"
      man8.install "snap.8"

      prefix.install_metafiles
    end
  end

  test do
    (testpath/"pkg/meta").mkpath
    (testpath/"pkg/meta/snap.yaml").write "name: test-snap\nversion: 1.0.0\nsummary: s\ndescription: d"
    system "#{bin}/snap", "pack", "pkg"
    system "#{bin}/snap", "version"
  end
end
