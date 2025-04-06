# SPDX-FileCopyrightText: erdnaxe <erdnaxe@crans.org>
# SPDX-License-Identifier: MIT

let
  rust-overlay = import (
    fetchTarball "https://github.com/oxalica/rust-overlay/archive/b4734ce867252f92cdc7d25f8cc3b7cef153e703.tar.gz"
  );

  # NixPkgs stable as of 2025-03-24
  pkgs =
    import
      (fetchTarball "https://github.com/NixOS/nixpkgs/archive/dd613136ee91f67e5dba3f3f41ac99ae89c5406b.tar.gz")
      { overlays = [ rust-overlay ]; };

  # Use crane for crosscompilation Rust toolchain
  crane-src = pkgs.fetchFromGitHub {
    owner = "ipetkov";
    repo = "crane";
    rev = "b62437f7e7e11fd2b456af29c25d04734fc49aa2";
    hash = "sha256-6ERwwMADv5VW+Eq6vrKZqFnGAj5+tL4vizGDmTWJjPc=";
  };
  craneLib =
    (import crane-src {
      pkgs = pkgs;
    }).overrideToolchain
      (
        p:
        p.rust-bin.nightly."2025-04-04".default.override {
          targets = [
            "riscv32imafc-unknown-none-elf"
            "thumbv6m-none-eabi"
            "thumbv7m-none-eabi"
            "thumbv7em-none-eabihf"
          ];
        }
      );

  version = "0.5.1";
  rmk-src = pkgs.fetchFromGitHub {
    owner = "HaoboGu";
    repo = "rmk";
    rev = "rmk-v${version}";
    hash = "sha256-C5YFb1PQeZwCN3ZOSE1rpYsxEmzcr+Co2uiZLjBsRlo=";
  };
  variants = [
    #"ch32v307" # fails on sequential-storage
    #"esp32c3_ble" # require toolchain on esp channel
    #"esp32c6_ble" # require toolchain on esp channel
    #"esp32s3_ble" # require toolchain on esp channel
    #"hpm5300" # cannot find linker script memory.x
    "nrf52832_ble"
    "nrf52840_ble_split"
    "nrf52840_ble"
    "nrf52840"
    "py32f07x"
    "rp2040_direct_pin"
    "rp2040_split"
    "rp2040"
    "stm32f1"
    "stm32f4"
    "stm32h7"
  ];
  buildVariants = pkgs.lib.strings.concatMapStringsSep " " (
    variant:
    craneLib.buildPackage {
      pname = "rmk-${variant}";
      version = version;

      src = rmk-src;
      strictDeps = true;
      doCheck = false;
      nativeBuildInputs = [ pkgs.flip-link ];

      cargoLock = "${rmk-src}/examples/use_rust/${variant}/Cargo.lock";
      cargoToml = "${rmk-src}/examples/use_rust/${variant}/Cargo.toml";
      postUnpack = ''
        cd $sourceRoot/examples/use_rust/${variant}
        sourceRoot="."
      '';
      # FIXME: flip-link fails to understand memory map
      postPatch = ''
        substituteInPlace .cargo/config.toml \
          --replace 'linker = "flip-link"' '#linker = "flip-link"'
        substituteInPlace .cargo/config.toml \
          --replace 'build-std =' '#build-std ='
      '';

      postInstall = ''
        for path in $out/bin/*; do
          ${pkgs.llvm}/bin/llvm-objcopy -O binary "$path" "$path.bin"
          rm "$path"
        done
      '';

      meta = with pkgs.lib; {
        description = "Feature-rich Rust keyboard firmware";
        homepage = "https://github.com/HaoboGu/rmk";
        license = licenses.mit; # dual MIT and asl20
        maintainers = with maintainers; [ erdnaxe ];
      };
    }
  ) variants;
in
pkgs.runCommand "rmk" { } ''
  mkdir $out
  for path in ${buildVariants}; do
    cp -r $path/bin "$out/$(basename $path | cut -c34-)"
  done
''
