# SPDX-FileCopyrightText: erdnaxe <erdnaxe@crans.org>
# SPDX-License-Identifier: MIT

let
  # NixPkgs stable as of 2025-02-25
  pkgsSrc = import (
    fetchTarball "https://github.com/NixOS/nixpkgs/archive/f5a32fa27df91dfc4b762671a0e0a859a8a0058f.tar.gz"
  );
  pkgs = pkgsSrc { };
  riscvCC =
    (pkgsSrc {
      crossSystem = {
        config = "riscv32-none-elf";
        libc = "newlib-nano";
        gcc = {
          arch = "rv32imac_zicsr";
          abi = "ilp32";
        };
      };
    }).stdenv.cc;
in
pkgs.stdenv.mkDerivation rec {
  pname = "am32-bootloader";
  version = "13.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "am32-firmware";
    repo = "AM32-bootloader";
    rev = "v${version}";
    hash = "sha256-frUn2kFqSeoI6Oj1ORohCIwiVZ7ODw16MTvqGIHEFkI=";
  };

  # HACK: V203 build is larger than 4k, raise flash size
  patchPhase = ''
    substituteInPlace v203makefile.mk \
      --replace "march=rv32imac" "march=rv32imac_zicsr"
    substituteInPlace Mcu/v203/Link.ld \
      --replace "LENGTH = 4K" "LENGTH = 5K"
  '';

  nativeBuildInputs = [
    pkgs.gcc-arm-embedded-10
    riscvCC
  ];

  makeFlags = [
    "ARM_SDK_PREFIX=arm-none-eabi-"
    "RISCV_SDK_PREFIX=riscv32-none-elf-"
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r obj/*.bin $out

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Bootloader for the AM32 project";
    homepage = "https://github.com/am32-firmware/AM32-bootloader";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ erdnaxe ];
  };
}
