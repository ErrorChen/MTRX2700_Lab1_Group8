# Lab1_Group8 - STM32F3 Pure Assembly Skeleton

## Project Overview
This is a pure-assembly STM32CubeIDE project skeleton for STM32F3DISCOVERY (MCU: STM32F303VCT6, Cortex-M4).
Application logic is built from `Src/assembly.s` as a single entry module, with startup and linker files kept from CubeIDE.

Resource constraints for planning:
- Flash: 256 KB
- RAM total: 48 KB (40 KB SRAM + 8 KB CCMRAM)

This baseline is intended to be extended for MTRX2700 ASM Lab Exercise 1 to 5.

## Hardware Mapping
- Board: STM32F3DISCOVERY
- LEDs on GPIOE:
- LD4 -> PE8
- LD3 -> PE9
- LD5 -> PE10
- LD7 -> PE11
- LD9 -> PE12
- LD10 -> PE13
- LD8 -> PE14
- LD6 -> PE15
- User button B1 -> PA0

LED control strategy:
- Write an 8-bit pattern to `GPIOE->ODR[15:8]` through `ODR + 1` byte address.

## Repository Structure
- `Startup/startup_stm32f303vctx.s`: CubeIDE startup and vector table (unchanged)
- `STM32F303VCTX_FLASH.ld`: linker script (unchanged)
- `Src/definitions.s`: board and register constants
- `Src/initialise.s`: GPIO clock and board initialization functions
- `Src/assembly.s`: main assembly entry, LED write/delay, SystemInit and syscall stubs
- `Src/main.c.bak`, `Src/syscalls.c.bak`, `Src/sysmem.c.bak`: disabled C sources
- `Meeting Minutes/template.md`: meeting template

## Calling Convention (AAPCS Simplified)
- `R0-R3`: argument/temp registers (caller-saved)
- `R0`: return value
- `R4-R11`: callee-saved
- Any function that calls another function must preserve LR (if needed) and return correctly.

## Build and Run (CubeIDE)
1. Open the project in STM32CubeIDE.
2. `Project -> Clean`.
3. `Project -> Build`.
4. `Run` or `Debug` to download to STM32F3DISCOVERY.
5. Observe LEDs alternating between `0x55` and `0xAA`.

## Troubleshooting
- `multiple definition of main`:
  - Ensure `Src/main.c` is renamed to `Src/main.c.bak` (already done).
- `undefined reference to SystemInit`:
  - Ensure `SystemInit` exists in `Src/assembly.s`.
- Large immediate constant errors:
  - Use `LDR Rx, =imm` form, not unsupported immediate forms in `MOV`.
- Include file errors from assembly:
  - Keep `.include "definitions.s"` in assembly sources.

## Test Plan
1. Build succeeds with no missing symbols (`main`, `SystemInit`, `_sbrk`, syscall stubs).
2. Runtime LED behavior:
- Pattern alternates between `0x55` and `0xAA`.
3. Debug register checks:
- `RCC->AHBENR`: `IOPAEN` and `IOPEEN` are set.
- `GPIOE->MODER[31:16] == 0x5555`.
- `GPIOE->ODR[15:8]` toggles each loop.

## Future Work (Exercise 1 to 5)
- Add string/array operations module
- Add button-driven input logic
- Add UART output/input module
- Replace software delay with timer-based delay
- Add interrupt-driven architecture where required
