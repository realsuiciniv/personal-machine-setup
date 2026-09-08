{ stdenv, fetchurl }:
stdenv.mkDerivation {
  pname = "rtk";
  version = "0.48.0";
  src = fetchurl {
    url = "https://github.com/rtk-ai/rtk/releases/download/v0.48.0/rtk-aarch64-apple-darwin.tar.gz";
    sha256 = "1nz04cq1r7k3gjjg8qc0lfv78gxswl4a0lsf7ybbci57jg62b82g";
  };
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    tar -xzf $src -C $out/bin
    chmod +x $out/bin/rtk
  '';
}
