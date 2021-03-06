class Syncthing < Formula
  desc "Open source continuous file synchronization application"
  homepage "https://syncthing.net/"
  url "https://github.com/syncthing/syncthing.git",
    :tag => "v0.13.0", :revision => "2ea22b18503f7e0c2fbed0f7c68f58f609125e5f"

  head "https://github.com/syncthing/syncthing.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "e3eaf16a00433e74d8489524e619eeef6d8d75613014eb5e9961a7845ecb0a4c" => :el_capitan
    sha256 "ecc6f6f9774c4026e7f32130244e8522dc27e5ac54373a8488abab78e3b3a2b7" => :yosemite
    sha256 "41297fdc6f99370169a791fac294cd1d88ad39e6a2ccf4a489171a444278608a" => :mavericks
  end

  depends_on "go" => :build
  depends_on :hg => :build

  def install
    ENV["GOPATH"] = cached_download
    mv cached_download, "/tmp/.syncthing-build"
    mkdir_p cached_download/"src/github.com/syncthing"
    mv "/tmp/.syncthing-build", cached_download/"src/github.com/syncthing/syncthing"
    ENV.append_path "PATH", "#{ENV["GOPATH"]}/bin"

    cd cached_download/"src/github.com/syncthing/syncthing"
    system "./build.sh", "noupgrade"
    bin.install "syncthing"
    cd cached_download
    rm_rf cached_download/"src/"
  end

  plist_options :manual => "syncthing"

  def plist; <<-EOS.undent
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/syncthing</string>
          <string>-no-browser</string>
          <string>-no-restart</string>
        </array>
        <key>KeepAlive</key>
        <dict>
          <key>Crashed</key>
          <true/>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
        <key>ProcessType</key>
        <string>Background</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/syncthing.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/syncthing.log</string>
      </dict>
    </plist>
    EOS
  end

  test do
    system bin/"syncthing", "-generate", "./"
  end
end
