{ stdenv, lib, fetchurl, zlib, glib, xorg, dbus, fontconfig, freetype, libGL, juliaVersion }:

let

  versionShasLinux = {
    "1.10.0" = "sha256-pymCB/cvKyeyqxzjkqbqN6+9H77g8fjRkLBU3KuoeP4=";
    "1.10.0-beta2" = "sha256-8aF/WlKYDBZ0Fsvk7aFEGdgY87dphUARVKOlZ4edZHc=";
    "1.10.0-beta1" = "sha256-zaOKLdWw7GBcwH/6RO/T6f4QctsmUllT0eJPtDLgv08=";
    "1.9.3" = "sha256-12ZwzJuj4P1MFUXdPQAmnAaUl2oRdjEnlevOFpLTI9E=";
    "1.9.2" = "sha256-TC15n0Qtf+cYgnsZ2iusty6gQbnOVfJO7nsTE/V8Q4M=";    
    "1.9.0" = "sha256-AMYURm75gJwusjSA440ZaixXf/8nMMT4PRNbkT1HM1k=";    
    "1.8.3" = "sha256-M8Owk1b/qiXTMxw2RrHy1LCZROj5P8uZSVeAG4u/WKk=";
    "1.7.2" = "sha256-p1JEck87LeDnJJyGH79kB4JXwW+0IDvnjxz03VlzupU=";
    "1.6.7" = "sha256-bEUi1ZXky80AFXrEWKcviuwBdXBT0gc/mdqjnkQrKjY=";
  };
  versionShasMac = {
    # Add your macOS SHAs here
    "1.10.0" = "sha256-FhzbxPQmDZtVWdB8BE3EYRJze96ihoXIgbEpe5VqRLY=";
  };
  platformShas = if stdenv.hostPlatform.isDarwin then versionShasMac else versionShasLinux;


  makeStdJulia = version: let
    baseurlLinux = "https://julialang-s3.julialang.org/bin/linux/x64/${lib.versions.majorMinor version}";
    baseurlMac = "https://julialang-s3.julialang.org/bin/mac/aarch64/${lib.versions.majorMinor version}";
    baseurl = if stdenv.hostPlatform.isDarwin then baseurlMac else baseurlLinux;
    architectureSuffix = if stdenv.hostPlatform.isDarwin then "macaarch64" else "linux-x86_64";
    filename = "julia-${version}-${architectureSuffix}.tar.gz";
    url = "${baseurl}/julia-${version}-${architectureSuffix}.tar.gz";
    src = fetchurl {
      inherit url;
      sha256 = platformShas.${version};
    };
  in makeJulia version src;
  makeJulia = version: src:
    stdenv.mkDerivation {
      name = "julia-${version}";
      src = src;
      installPhase = ''
        mkdir $out
        cp -R * $out/

        # Patch for https://github.com/JuliaInterop/RCall.jl/issues/339.

        echo "patching $out"
        cp -L ${stdenv.cc.cc.lib}/lib/libstdc++.so.6 $out/lib/julia/
      '';
      dontStrip = true;
      ldLibraryPath = lib.makeLibraryPath [
        stdenv.cc.cc
        zlib
        glib
        xorg.libXi
        xorg.libxcb
        xorg.libXrender
        xorg.libX11
        xorg.libSM
        xorg.libICE
        xorg.libXext
        dbus
        fontconfig
        freetype
        libGL
      ];
    };
  julia = (makeStdJulia juliaVersion);
in
julia
