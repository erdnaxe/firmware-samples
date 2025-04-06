# SPDX-FileCopyrightText: erdnaxe <erdnaxe@crans.org>
# SPDX-License-Identifier: MIT

let
  # NixPkgs stable as of 2025-02-25
  pkgs =
    import
      (fetchTarball "https://github.com/NixOS/nixpkgs/archive/f5a32fa27df91dfc4b762671a0e0a859a8a0058f.tar.gz")
      { };

  toolchainsName = [
    { name = "aarch64-elf"; version = "14.2.0"; hash = "sha256-3TL/mlGaQ8YlRPfLzkR0M2O6eXr+jP0dDF/ir8vJfgE="; }
    { name = "arm-eabi"; version = "14.2.0"; hash = "sha256-5yUTQh17neGxAUteoR3qynQ3iHxhf5nMSSgp3uifRhY="; }
    { name = "i386-elf"; version = "14.2.0"; hash = "sha256-rzp/fpcsWiKzlY6Cne9TEYiuNu8dQJ9aSX3mBRETWk4="; }
    # { name = "i586-elf"; version = "4.8.1"; hash = "sha256-GCPpxChvBLDfykOY53nNwaS7FT3dkIpyhrXxH6i/PHo="; }
    # { name = "i686-elf"; version = "5.2.0"; hash = "sha256-IVmhnftlyO1uooGSzHr7iR5Omc7K/ycYKX5UqKbysSY="; }
    { name = "m68k-elf"; version = "14.2.0"; hash = "sha256-qqeCZJM/Em61ySkNlKrd0/LMQ5iI9X3FzNTEqmJfeRU="; }
    { name = "microblaze-elf"; version = "14.2.0"; hash = "sha256-CaqO8FySTB32UyRYeTh9Nyq0H40Aojp80njDoA6eWGE="; }
    { name = "mips-elf"; version = "14.2.0"; hash = "sha256-/FCD2ZdAqFU+uDTNY2kL6j5ziEmZwajmoiebZzPHYOI="; }
    { name = "nios2-elf"; version = "13.2.0"; hash = "sha256-opBS/vcpxGlWiX5R3rh+zOT1CXFeo2K4c1vffIswJsI="; }
    { name = "or1k-elf"; version = "14.2.0"; hash = "sha256-KPs6O2eqb7AvKc9ITkIr0ASF+qLoReGg9cVdYJw6a+0="; }
    { name = "pdp11-aout"; version = "14.2.0"; hash = "sha256-TU7Vd7zOMUJOKsbTQxi/a8gmZ207waZpsuP5fjQ7oVg="; }
    { name = "powerpc-elf"; version = "14.2.0"; hash = "sha256-6JUbt0tUu6i4QEM2ZXR8ZsZo4pKiieIGS1ARLpFjt1g="; }
    { name = "riscv32-elf"; version = "14.2.0"; hash = "sha256-ZJh9kYlXJ6oSYCtH+S/1FZKpuwcaGGvbzTQRYD8A+s8="; }
    { name = "riscv64-elf"; version = "14.2.0"; hash = "sha256-cUqDtoyaz+bZsv0k9+Mw7cVL8xB9c1rCLnjB9VKCU1Q="; }
    { name = "sh-elf"; version = "14.2.0"; hash = "sha256-lxPhaQUN267mOqPXs0UKJCzwc0RRl4pExdG3qKqR2Ww="; }
    { name = "sparc64-elf"; version = "14.2.0"; hash = "sha256-RmmmO0KPIx/Twc4zPT5zi1nGiLF5V/icH/Kcvm547mQ="; }
    { name = "sparc-elf"; version = "14.2.0"; hash = "sha256-80Tc/03babLEIQOFqSU4Sj2hOdnuKIsg5dPD8mMNCAA="; }
    # { name = "vax-linux"; version = "7.3.0"; hash = "sha256-8qIJE2A+WKCUbC8JZ6yXQ7gbswdrhfgBp89SICmMpDo="; }
    { name = "x86_64-elf"; version = "14.2.0"; hash = "sha256-VVeM6NpB4rN8XBVLcNDqkrIdvaS9Z+eHxVEXDSatdfc="; }
  ];

  toolchains = map (
    toolchainAttrs:
    pkgs.stdenv.mkDerivation {
      pname = "newos-toolchain-${toolchainAttrs.name}";
      version = toolchainAttrs.version;

      src = pkgs.fetchurl {
        url = "https://newos.org/toolchains/${toolchainAttrs.name}-${toolchainAttrs.version}-Linux-x86_64.tar.xz";
        hash = toolchainAttrs.hash;
      };
      buildInputs = with pkgs; [
        expat
        gmp
        libgcc
        mpfr
        ncurses6
        python310
        xz
        zlib
        zstd
      ];
      nativeBuildInputs = [ pkgs.autoPatchelfHook ];
      installPhase = ''
        runHook preInstall
        cp -r . $out
        runHook postInstall
      '';
    }
  ) toolchainsName;
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "lk-tests";
  version = "unstable-20250120";

  src = pkgs.fetchFromGitHub {
    owner = "littlekernel";
    repo = "lk";
    rev = "3543217461c9717b2a70b948dad9f23115c15c01";
    hash = "sha256-bdcwaC46KjdL6zgenBiDkl/AnTqZMemv+RsvaVcq3Jk=";
  };

  postPatch = ''
    patchShebangs .
  '';

  nativeBuildInputs =
    with pkgs;
    [
      which
      python3
    ]
    ++ toolchains;

  buildPhase = ''
    runHook preBuild

    make armemu-test
    make bananapi-f3-test
    make dartuinoP0-bootloader
    make dartuinoP0-test
    make helio-test
    make lm3s6965evb-test
    make lpcexpresso1549-test
    make lpclink2-lpcboot
    make lpclink2-mdebug
    make lpcxpresso4337-test
    make mt6735
    make mt6797
    make nrf51-pca10000-test
    make nrf51-pca10028-test
    make nrf52-pca10040-test
    make nrf52-pca10056-test
    make nucleo-f072rb
    make or1ksim
    make pc-x86-64-test
    make pc-x86-legacy-test
    make pc-x86-test
    make pico-test
    make qemu-m4-test
    make qemu-microblaze-test
    make qemu-mips-test
    make qemu-sifive-u-test
    make qemu-virt-arm32-minimal
    make qemu-virt-arm32-test
    make qemu-virt-arm64-test
    make qemu-virt-m68k-test
    make qemu-virt-riscv32-test
    make qemu-virt-riscv64-supervisor-test
    make qemu-virt-riscv64-test
    make rosco-m68k-test
    make rpi2-test
    make rpi3-test
    make sifive-e-test
    make sifive-unleashed-test
    make stellaris-launchpad-test
    make stm32-h103-test
    make stm32-p107-test
    make stm32-p407-test
    make stm3220g-eval
    make stm32746g-eval2-test
    make stm32f4-discovery-test
    make stm32f429i-disco-test
    make stm32f746g-disco-test
    make uzed-bootloader
    make uzed-dram-test
    make uzed-test
    make vim2-test
    make visionfive2-test
    make zybo-dram-test
    make zybo-microblaze-test
    make zybo-test

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    for folder in build-*; do
      mv "$folder/lk.elf" "$out/$folder.elf"
      mv "$folder/lk.bin" "$out/$folder.bin"
    done

    runHook postInstall
  '';
}
