<!--
SPDX-FileCopyrightText: erdnaxe <erdnaxe@crans.org>
SPDX-License-Identifier: MIT
-->

# Firmware samples build scripts

Each script builds or downloads firmware samples from open-source firmware projects.

| Project         | Architectures                                         | Framework      | Samples |
|-----------------|-------------------------------------------------------|----------------|---------|
| AM32-Bootloader | ARM, Risc-V                                           | Vendor HAL+BSP | 70      |
| AM32            | ARM                                                   | Vendor HAL+BSP | 138     |
| Betaflight      | ARM                                                   | Vendor HAL+BSP | 55      |
| IronOS          | ARM, Risc-V                                           | Vendor HAL+BSP | 8       |
| LittleKernel    | ARM, Risc-V, m68k, MicroBlaze, PowerPC, SPARC, x86... | Vendor HAL+BSP | 55      |
| MicroPython     | ARM, ESP32, PowerPC,                                  | Vendor HAL+BSP | 83      |
| QMK             | ARM, AVR                                              | ChibiOS        | 825     |
| RMK             | ARM, Risc-V                                           | Embassy        | 6       |

Prebuilt samples are available at <https://github.com/erdnaxe/firmware-samples-bin>.

Build all samples using:
```
nix-build am32-bootloader.nix -o result/am32-bootloader
nix-build am32.nix -o result/am32
nix-build betaflight.nix -o result/betaflight
nix-build ironos.nix -o result/ironos
nix-build littlekernel.nix -o result/littlekernel
./micropython.sh
nix-build qmk.nix -o result/qmk
nix-build rmk.nix -o result/rmk
```
