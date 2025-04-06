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
  pname = "am32";
  version = "2.16";

  # need recent version for .gitmodules
  src = pkgs.fetchFromGitHub {
    owner = "am32-firmware";
    repo = "AM32";
    rev = "v${version}";
    hash = "sha256-6O/uzV04vhlKc+07j/tq96J8DPXbrVOLIRFJQBkKuiU=";
  };

  nativeBuildInputs = [
    pkgs.gcc-arm-embedded-10
  ];

  makeFlags = [
    "ARM_SDK_PREFIX=arm-none-eabi-"
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r obj/*.bin $out

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "Firmware for ARM based speed controllers";
    homepage = "https://github.com/am32-firmware/AM32";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ erdnaxe ];
  };
}
