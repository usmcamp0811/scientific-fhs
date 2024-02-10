{ lib, stdenv, poetry, zlib, glib, xorg, dbus, fontconfig, freetype, libGL, python3Packages }:
let
patchPoetry = stdenv.mkDerivation rec {
  pname = "poetry";
  version = "1.0.0";

  nativeBuildInputs = [ poetry ];

  buildInputs = [
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
    python3Packages.python
  ];

  installPhase = ''
    mkdir -p $out
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
in
patchPoetry
