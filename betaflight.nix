# SPDX-FileCopyrightText: erdnaxe <erdnaxe@crans.org>
# SPDX-License-Identifier: MIT

let
  # NixPkgs stable as of 2025-02-25
  pkgs =
    import
      (fetchTarball "https://github.com/NixOS/nixpkgs/archive/f5a32fa27df91dfc4b762671a0e0a859a8a0058f.tar.gz")
      { };
in
pkgs.stdenv.mkDerivation rec {
  pname = "betaflight";
  version = "unstable-20250322";

  # need recent version for .gitmodules
  src = pkgs.fetchFromGitHub {
    owner = "betaflight";
    repo = "betaflight";
    rev = "3ae8056ec6178b589f2f61a499f11643defb949f";
    hash = "sha256-tYTk0cS0Fl589kMVzIyA8J7Ir5CgcS7+vS5uZj80zK0=";
    fetchSubmodules = true;
  };

  # betaflight requires ARM toolchain, pkgsCross doesn't seem to work
  nativeBuildInputs = [
    pkgs.gcc-arm-embedded-13
    pkgs.openssl
    pkgs.tinyxxd
  ];

  makeFlags = [ "all" ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r obj/*.hex obj/main/*.elf $out
    for path in $out/*.hex; do
      arm-none-eabi-objcopy -I ihex -O binary "$path" "''${path%.hex}.bin"
    done
    rm $out/*.hex

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Open source flight controller firmware";
    homepage = "https://betaflight.com/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ erdnaxe ];
  };
}
