# SPDX-FileCopyrightText: erdnaxe <erdnaxe@crans.org>
# SPDX-License-Identifier: MIT

let
  # NixPkgs stable as of 2025-02-25
  pkgs_source = import (
    fetchTarball "https://github.com/NixOS/nixpkgs/archive/f5a32fa27df91dfc4b762671a0e0a859a8a0058f.tar.gz"
  );
  pkgs = pkgs_source { };
  pkgs_arm = pkgs_source {
    crossSystem = {
      config = "arm-none-eabi";
      libc = "newlib-nano";
    };
  };
  pkgs_riscv = pkgs_source {
    crossSystem = {
      config = "riscv32-none-elf";
      libc = "newlib-nano";
    };
  };
  python3_bdflib = pkgs.python3Packages.buildPythonPackage rec {
    pname = "bdflib";
    version = "2.1.0";
    src = pkgs.fetchPypi {
      pname = "bdflib";
      inherit version;
      hash = "sha256-brf+Dm9rBrQaebGUVY8H6IEpm1SMZ0i1PsNX9RRX8u4=";
    };
    pythonImportsCheck = [ "bdflib" ];
  };
  variants = [
    { model = "TS100"; pkgs = pkgs_arm; }
    { model = "TS80"; pkgs = pkgs_arm; }
    { model = "TS80P"; pkgs = pkgs_arm; }
    { model = "TS101"; pkgs = pkgs_arm; }
    # TODO: see https://sourceware.org/pipermail/newlib-cvs/2020q1/004176.html
    # { model = "Pinecil"; pkgs = pkgs_riscv; }
    # { model = "Pinecilv2"; pkgs = pkgs_riscv; }
    { model = "MHP30"; pkgs = pkgs_arm; }
    { model = "S60"; pkgs = pkgs_arm; }
    { model = "S60P"; pkgs = pkgs_arm; }
    { model = "T55"; pkgs = pkgs_arm; }
  ];
  buildVariants = pkgs.lib.strings.concatMapStringsSep " " (
    attrs:
    attrs.pkgs.stdenv.mkDerivation rec {
      pname = "ironos";
      version = "2.23-rc3";

      src = pkgs.fetchFromGitHub {
        owner = "Ralim";
        repo = "IronOS";
        rev = "v${version}";
        hash = "sha256-lhLX8BfWsAuOwo+p3JkxkSj4aYje4FpGlZrxqkHDcLE=";
        fetchSubmodules = true;
      };
      sourceRoot = "source/source";

      patchPhase = ''
        substituteInPlace Makefile \
          --replace "riscv-none-elf" "riscv32-none-elf"
      '';

      nativeBuildInputs = [
        pkgs.python3
        python3_bdflib
      ];

      makeFlags = [
        "model=${attrs.model}"
        "firmware-EN"
      ];

      installPhase = ''
        runHook preInstall

        cp -r Hexfile $out

        runHook postInstall
      '';
    }
  ) variants;
in
pkgs.runCommand "ironos" { } ''
  mkdir $out
  for path in ${buildVariants}; do
    cp $path/*.bin $out/
  done
''
