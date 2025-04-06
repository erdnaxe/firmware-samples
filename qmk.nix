# SPDX-FileCopyrightText: erdnaxe <erdnaxe@crans.org>
# SPDX-License-Identifier: MIT

let
  # NixPkgs stable as of 2025-02-25
  pkgs =
    import
      (fetchTarball "https://github.com/NixOS/nixpkgs/archive/f5a32fa27df91dfc4b762671a0e0a859a8a0058f.tar.gz")
      { };
in
pkgs.stdenvNoCC.mkDerivation rec {
  pname = "qmk";
  version = "0.27.12";

  src = pkgs.fetchFromGitHub {
    owner = "qmk";
    repo = "qmk_firmware";
    rev = version;
    hash = "sha256-SaMLVD+GQ6kkNU4qzhEdbP2fbgMNjvRC15eQPW7OlpE=";
    fetchSubmodules = true;
    # TODO: patch build scripts to remove .git requirement
    leaveDotGit = true;
  };

  nativeBuildInputs = with pkgs; [
    qmk
    git
  ];

  # TODO: fix UF2 creation
  buildPhase = ''
    runHook preBuild

    # handwired_onekey_sipeed_longan_nano, rubi and terrazzo are expected to fail
    qmk mass-compile -t -j 8 || true

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp *.bin *.hex *.uf2 .build/failed.log* $out/

    for path in $out/*.hex; do
      arm-none-eabi-objcopy -I ihex -O binary "$path" "''${path%.hex}.bin"
      rm "$path"
    done

    runHook postInstall
  '';
}
