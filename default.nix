let
  sources = import ./nix/sources.nix;
  nixpkgs-mozilla = import sources.nixpkgs-mozilla;
  pkgs = import sources.nixpkgs {
    overlays = [
      nixpkgs-mozilla
    ];
  };
in
  with pkgs;
  stdenv.mkDerivation {
    name = "bevy-learn";
    src = ./.;

    nativeBuildInputs = [
      clang lld
      rustup
      pkgconfig
      cmake
      glfw
      udev
      alsaLib
      glxinfo
      x11
      mesa
      xorg.libX11 xorg.libXcursor xorg.libXrandr xorg.libXi xorg.libXinerama
      vulkan-tools vulkan-headers vulkan-loader 
      vulkan-validation-layers
      pkgs.latest.rustChannels.stable.rust
    ];

    shellHook = ''export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${lib.makeLibraryPath [
      alsaLib
      udev
      vulkan-loader
      xorg.libXcursor
      xorg.libXrandr 
      xorg.libXi
    ]}"'';

    buildPhase = ''
      if ["$PROFILE" = "RELEASE"]; then
        cargo build --release
      else
        cargo build
      fi
    '';

    installPhase = ''
      cargo build --release
      mkdir -p $out/bin
      cargo install --path . --target-dir $out/bin
    '';
  }