# Lab1_Group8

## MTRX2700 Assembly Language for STM32 Lab Repository
## MTRX2700 STM32 汇编语言实验仓库

This repository is a bilingual, assessment-oriented submission document for the `MTRX2700 Mechatronics 2` introduction lab, based on `MTRX2700_ASM_lab.pdf` dated `1 March 2026`.

本仓库是面向考核展示的中英双语实验仓库，对应 `MTRX2700 Mechatronics 2` 的 STM32 汇编语言导论实验，文档依据 `2026 年 3 月 1 日` 发布的 `MTRX2700_ASM_lab.pdf` 编写。

The README is written in final-submission style, but all technical claims below reflect the current repository state as inspected from the source tree.

本 README 按最终实验提交文档的形式组织，但其中所有技术描述都严格对应当前仓库中已经存在的代码与配置。

## 1. Project Details / 项目概况

### Course and assessment context / 课程与考核背景

- Course: `MTRX2700 Mechatronics 2`
- Lab handout: `MTRX2700_ASM_lab.pdf`
- Handout revision date: `1 March 2026`
- Assessment note from the handout: the README is the primary documentation viewed during the demonstration through the GitHub web interface

- 课程名称：`MTRX2700 Mechatronics 2`
- 实验说明：`MTRX2700_ASM_lab.pdf`
- 实验文档版本日期：`2026 年 3 月 1 日`
- 根据实验说明，README 是考核展示时会被重点查看的主要文档

### Target platform / 目标硬件平台

- Board: `STM32F3DISCOVERY`
- MCU: `STM32F303VCTx`
- Core: `ARM Cortex-M4`
- FPU setting in project configuration: `fpv4-sp-d16`, `hard float ABI`
- Linker memory layout from `STM32F303VCTX_FLASH.ld`:
  - Flash: `256 KB`
  - SRAM: `40 KB`
  - CCMRAM: `8 KB`

- 开发板：`STM32F3DISCOVERY`
- 微控制器：`STM32F303VCTx`
- 内核：`ARM Cortex-M4`
- 工程配置中的浮点设置：`fpv4-sp-d16`，`hard float ABI`
- 链接脚本 `STM32F303VCTX_FLASH.ld` 定义的存储资源：
  - Flash：`256 KB`
  - SRAM：`40 KB`
  - CCMRAM：`8 KB`

### Current repository status / 当前仓库状态

This repository currently contains a working pure-assembly baseline rather than a full completion of Exercises 1-5. The implemented code successfully brings up the board GPIO, configures LED outputs, and runs a repeating LED blink pattern. The repository is therefore suitable as an early-stage assessment snapshot or development baseline, but it is not yet a complete final lab solution.

当前仓库目前是一个可运行的纯汇编基础版本，而不是实验 1 到实验 5 的完整实现。现有代码能够完成开发板 GPIO 上电初始化、LED 输出配置，并持续执行 LED 闪烁模式。因此，它适合作为实验早期阶段的提交快照或后续开发基线，但还不是完整的最终实验解答。

## 2. Team Information / 小组信息

The lab handout requires group members, roles, and responsibilities to be documented in the README. Based on the current repository history, only one verifiable contributor can be confirmed from git metadata.

实验说明要求在 README 中写明小组成员、角色与职责。根据当前仓库的 git 历史，目前只能确认一位可验证的贡献者。

| Name / 姓名 | Evidence / 证据 | Current verifiable role / 当前可验证角色 |
| --- | --- | --- |
| Chen | `git shortlog -sne HEAD` | Current repository contributor and maintainer of the checked-in baseline / 当前仓库中可验证的提交者与基线维护者 |

Assessment note: if the final submission is presented by a larger group, the official member list, role allocation, and responsibilities should be completed before the week 5 demonstration.

考核说明：如果最终展示由多名组员共同完成，则应在第 5 周考核前补充正式的小组成员名单、任务分工与职责说明。

## 3. Assessment Alignment / 与实验要求的对应关系

The lab handout requires the repository README to cover:

- project details
- high-level information about the code and module structure
- instructions for the user
- testing procedures

实验说明要求仓库 README 至少覆盖以下内容：

- 项目基本信息
- 代码功能与模块划分的高层说明
- 用户使用说明
- 测试流程与验证方法

The current repository aligns with that documentation structure, but the code implementation is only partial. The table below states the actual implementation status as of `9 March 2026`.

当前仓库已经按照上述文档结构组织说明，但代码实现仍是部分完成状态。下表给出截至 `2026 年 3 月 9 日` 的真实实现情况。

| Exercise / 练习 | Required by handout / 实验要求 | Current status / 当前状态 | Notes / 说明 |
| --- | --- | --- | --- |
| Exercise 1: Memory and pointers / 内存与指针 | String length, case conversion, framing, BCC checksum | Not implemented / 未实现 | No string-processing functions currently exist in source |
| Exercise 2: Digital I/O / 数字输入输出 | LED control, button counter, debounce, timed visualisation | Partially implemented / 部分实现 | LED pattern output is implemented; button counting, state machine, and debounce are not implemented |
| Exercise 3: Serial communication / 串口通信 | UART transmit, receive, ACK/NAK, baud/clock discussion | Not implemented / 未实现 | No UART peripheral configuration or buffer protocol code is present |
| Exercise 4: Hardware timers / 硬件定时器 | Timer-based delays and multi-rate blinking | Not implemented / 未实现 | Only a software busy-wait delay exists |
| Exercise 5: Integration / 综合集成 | Two-board UART counter integration | Not implemented / 未实现 | Dependent modules from Exercises 1-4 are not yet available |

### Current demonstrable behavior / 当前可演示行为

- The board enables GPIO clocks for `GPIOA` and `GPIOE`
- `PE8` to `PE15` are configured as outputs
- `PA0` is configured as an input with pull-down
- The program writes an 8-bit pattern to the upper byte of `GPIOE->ODR`
- The LED pattern alternates between `0x55` and `0xAA` forever

- 程序会开启 `GPIOA` 和 `GPIOE` 的时钟
- `PE8` 到 `PE15` 被配置为输出
- `PA0` 被配置为带下拉的输入
- 程序将 8 位图案写入 `GPIOE->ODR` 的高字节
- LED 会在 `0x55` 与 `0xAA` 两种图案之间无限交替

## 4. Repository Structure and Module Breakdown / 仓库结构与模块划分

| Path / 路径 | Type / 类型 | Purpose / 功能 |
| --- | --- | --- |
| `Src/assembly.s` | Custom assembly module / 自定义汇编模块 | Defines `main`, `SystemInit`, LED output helper, software delay, newlib syscall stubs, and `_sbrk` |
| `Src/initialise.s` | Custom assembly module / 自定义汇编模块 | Enables GPIO peripheral clocks and configures LED/button GPIO modes |
| `Src/definitions.s` | Constant definition file / 常量定义文件 | Stores board mapping, register base addresses, offsets, patterns, and masks |
| `Startup/startup_stm32f303vctx.s` | ST/CubeIDE startup file / ST 自动生成启动文件 | Provides vector table, reset handler, and runtime startup flow |
| `STM32F303VCTX_FLASH.ld` | Linker script / 链接脚本 | Defines memory layout, stack, heap reservation, and section placement |
| `Src/main.c.bak` | Disabled C source / 已禁用 C 文件 | Original CubeIDE `main.c`, renamed to avoid duplicate `main` |
| `Src/syscalls.c.bak` | Disabled C source / 已禁用 C 文件 | Original CubeIDE syscall layer, replaced by assembly stubs |
| `Src/sysmem.c.bak` | Disabled C source / 已禁用 C 文件 | Original CubeIDE `_sbrk` implementation, replaced by assembly version |
| `Meeting Minutes/` | Documentation folder / 文档目录 | Stores meeting notes and template |
| `MTRX2700_ASM_lab.pdf` | Assessment handout / 实验说明 | Primary reference for expected exercises and documentation |

### High-level module logic / 高层逻辑说明

1. `Reset_Handler` in the startup file sets the stack, runs `SystemInit`, initializes `.data` and `.bss`, calls `__libc_init_array`, then branches to `main`.
2. `main` calls `enablePeripheralClocks` and `initialiseDiscoveryBoard`.
3. `main` loads the initial pattern `0x55`, writes it to the LED port, toggles it with XOR `0xFF`, waits using `softwareDelay`, and loops forever.
4. Minimal syscall stubs are provided so the project links correctly against newlib-nano without relying on the disabled C sources.

1. 启动文件中的 `Reset_Handler` 会设置栈指针，调用 `SystemInit`，初始化 `.data` 与 `.bss`，执行 `__libc_init_array`，然后跳转到 `main`。
2. `main` 依次调用 `enablePeripheralClocks` 和 `initialiseDiscoveryBoard`。
3. `main` 先加载初始图案 `0x55`，将其写入 LED 端口，再通过与 `0xFF` 异或完成翻转，调用 `softwareDelay` 延时后重复循环。
4. 工程还提供了最小化的 syscall stub，以便在禁用默认 C 文件后仍能与 newlib-nano 正常链接。

## 5. Hardware Mapping / 硬件映射

### LED outputs / LED 输出

| LED | Pin |
| --- | --- |
| `LD4` | `PE8` |
| `LD3` | `PE9` |
| `LD5` | `PE10` |
| `LD7` | `PE11` |
| `LD9` | `PE12` |
| `LD10` | `PE13` |
| `LD8` | `PE14` |
| `LD6` | `PE15` |

### User input / 用户输入

| Signal | Pin | Current use / 当前用途 |
| --- | --- | --- |
| User button `B1` | `PA0` | Configured as input with pull-down, but not yet read by application logic |

The current LED helper function writes an 8-bit bitmask directly to `GPIOE->ODR[15:8]` through the byte address `ODR + 1`.

当前 LED 输出函数通过 `ODR + 1` 的字节地址，直接向 `GPIOE->ODR[15:8]` 写入 8 位图案。

## 6. Build, Flash, and Debug Instructions / 构建、烧录与调试说明

### Recommended environment / 推荐环境

- IDE: `STM32CubeIDE`
- Project metadata present: `.project`, `.cproject`, `.settings/`
- Build configuration present: `Debug`
- Generated makefiles reference: `GNU Tools for STM32 14.3.rel1`
- Existing debug launch file: `Lab1_Group8 Debug.launch`

- 推荐使用：`STM32CubeIDE`
- 工程元数据已包含：`.project`、`.cproject`、`.settings/`
- 当前已有构建配置：`Debug`
- 自动生成的 makefile 指向：`GNU Tools for STM32 14.3.rel1`
- 当前已有调试启动配置：`Lab1_Group8 Debug.launch`

### Import and build / 导入与构建

1. Open `STM32CubeIDE`.
2. Import the repository as an existing STM32CubeIDE project.
3. Confirm that the active build configuration is `Debug`.
4. Run `Project -> Clean`.
5. Run `Project -> Build Project`.

1. 打开 `STM32CubeIDE`。
2. 以已有 STM32CubeIDE 工程的方式导入本仓库。
3. 确认当前激活的构建配置为 `Debug`。
4. 执行 `Project -> Clean`。
5. 执行 `Project -> Build Project`。

### Flash and run / 烧录与运行

1. Connect the `STM32F3DISCOVERY` board through ST-LINK.
2. Use `Run` or `Debug` in CubeIDE.
3. If using the checked-in launch configuration, the debugger is configured to stop at `main`.
4. Resume execution and observe the 8 LEDs alternate between `0x55` and `0xAA`.

1. 通过 ST-LINK 连接 `STM32F3DISCOVERY` 开发板。
2. 在 CubeIDE 中点击 `Run` 或 `Debug`。
3. 如果使用仓库中已有的调试配置，调试器会默认在 `main` 处停下。
4. 继续运行后，观察 8 个 LED 在 `0x55` 与 `0xAA` 图案之间交替闪烁。

### Current demo scope / 当前演示范围

The current repository can demonstrate only the digital output baseline and basic project startup flow. It does not yet demonstrate button interaction, UART communication, timer-based delays, string processing, or integration behavior from the later exercises.

当前仓库只能演示数字输出基线功能和项目启动流程，还不能演示按键交互、串口通信、硬件定时器延时、字符串处理，或后续综合集成行为。

## 7. Testing Procedures / 测试流程

The handout explicitly requires testing procedures to be documented. The following checks reflect both the current implementation and the expected demonstration workflow.

实验说明明确要求给出测试流程。以下测试项同时对应当前实现情况与演示时可采用的验证流程。

### A. Static code inspection / 静态代码检查

- Confirm that `main` is defined in `Src/assembly.s`
- Confirm that `SystemInit` exists so the startup file links correctly
- Confirm that `Src/main.c.bak` is not compiled as `main.c`
- Confirm that GPIO register addresses and masks in `Src/definitions.s` match the STM32F3DISCOVERY mapping
- Confirm that `enablePeripheralClocks` sets `RCC_AHBENR_IOPAEN` and `RCC_AHBENR_IOPEEN`
- Confirm that `initialiseDiscoveryBoard` sets `PE8-PE15` to output mode and `PA0` to pull-down input

- 确认 `main` 定义在 `Src/assembly.s`
- 确认 `SystemInit` 已实现，以满足启动文件的链接需求
- 确认 `Src/main.c.bak` 不会以 `main.c` 参与编译
- 确认 `Src/definitions.s` 中 GPIO 地址与掩码和 STM32F3DISCOVERY 映射一致
- 确认 `enablePeripheralClocks` 会设置 `RCC_AHBENR_IOPAEN` 与 `RCC_AHBENR_IOPEEN`
- 确认 `initialiseDiscoveryBoard` 会把 `PE8-PE15` 配为输出，把 `PA0` 配为带下拉的输入

### B. Build verification / 构建验证

- Clean the project successfully
- Build the `Debug` configuration successfully
- Verify there are no undefined references to `main`, `SystemInit`, `_sbrk`, or syscall stubs
- Verify the ELF, MAP, and LIST files are generated under `Debug/`

- 工程可以成功清理
- `Debug` 配置可以成功构建
- 链接阶段不会出现 `main`、`SystemInit`、`_sbrk` 或 syscall stub 未定义错误
- `Debug/` 目录下会生成 ELF、MAP 和 LIST 文件

### C. Runtime verification / 运行时验证

- After flashing, the LEDs should alternate between two complementary patterns
- The visible sequence should correspond to `0x55` then `0xAA`
- The program should remain in an infinite application loop without faulting

- 烧录后，LED 应在两组互补图案之间交替
- 可见序列应对应 `0x55` 和 `0xAA`
- 程序应稳定停留在主循环中，不进入异常状态

### D. Debug register checks / 调试寄存器检查

- `RCC->AHBENR`: bits for `IOPAEN` and `IOPEEN` should be set
- `GPIOE->MODER[31:16]` should correspond to output mode for `PE8-PE15`
- `GPIOA->PUPDR[1:0]` should correspond to pull-down on `PA0`
- `GPIOE->ODR[15:8]` should toggle between the two LED patterns

- `RCC->AHBENR` 中 `IOPAEN` 与 `IOPEEN` 位应被置位
- `GPIOE->MODER[31:16]` 应体现 `PE8-PE15` 的输出模式配置
- `GPIOA->PUPDR[1:0]` 应体现 `PA0` 下拉配置
- `GPIOE->ODR[15:8]` 应在两种 LED 图案之间切换

### E. Assessment-readiness checks / 面向考核的检查

- README should be readable through GitHub and explain the current implementation honestly
- Meeting records should be available in the repository
- Before final assessment, check whether the meeting folder should be renamed from `Meeting Minutes/` to `minutes/` to match the handout wording exactly

- README 应可通过 GitHub 直接阅读，并如实解释当前实现状态
- 仓库中应保留会议记录
- 在最终考核前，建议确认是否需要把 `Meeting Minutes/` 重命名为实验说明要求的 `minutes/`

## 8. Current Limitations and Next Development Work / 当前限制与后续工作

### Known limitations / 已知限制

- No Exercise 1 string or checksum module exists yet
- The button input on `PA0` is configured but not used
- There is no button counter, no debounce, and no LED state machine
- There is no UART transmit or receive implementation
- There is no timer-based delay implementation
- There is no two-board integration logic

- 目前还没有实验 1 所需的字符串与校验和模块
- `PA0` 按键输入虽然已配置，但尚未接入程序逻辑
- 当前没有按键计数、去抖动或 LED 状态机
- 当前没有 UART 发送或接收实现
- 当前没有基于硬件定时器的延时实现
- 当前没有双板通信的综合集成逻辑

### Recommended next steps / 建议的后续开发顺序

1. Complete Exercise 2 button-driven logic on top of the existing GPIO baseline.
2. Implement Exercise 1 string length, framing, and checksum helpers.
3. Add UART transmit and receive support for Exercise 3.
4. Replace `softwareDelay` with timer-based delay functions for Exercise 4.
5. Integrate the modules into the two-board protocol required by Exercise 5.

1. 在当前 GPIO 基线之上完成实验 2 的按键驱动逻辑。
2. 实现实验 1 的字符串长度、封包与校验和函数。
3. 为实验 3 加入 UART 收发支持。
4. 用基于定时器的延时函数替换 `softwareDelay`，完成实验 4。
5. 将上述模块整合为实验 5 所要求的双板通信协议。

## 9. License / 许可证

This project includes an MIT license for original coursework material authored by the repository contributors. See the root `LICENSE` file.

本项目对仓库贡献者原创的课程作业内容采用 MIT 许可证，详见根目录 `LICENSE` 文件。

Important scope note:

- The MIT license applies to original project content unless a file states otherwise.
- Files carrying STMicroelectronics or other third-party notices are not relicensed by this repository.
- This includes ST-generated or retained support files such as:
  - `Startup/startup_stm32f303vctx.s`
  - `STM32F303VCTX_FLASH.ld`
  - `Src/main.c.bak`
  - `Src/syscalls.c.bak`
  - `Src/sysmem.c.bak`

重要范围说明：

- MIT 许可仅适用于本仓库中未声明其他许可的原创项目内容。
- 带有 STMicroelectronics 或其他第三方版权声明的文件，不因本仓库而被重新授权为 MIT。
- 这类文件包括但不限于：
  - `Startup/startup_stm32f303vctx.s`
  - `STM32F303VCTX_FLASH.ld`
  - `Src/main.c.bak`
  - `Src/syscalls.c.bak`
  - `Src/sysmem.c.bak`

## 10. References / 参考资料

- `MTRX2700_ASM_lab.pdf`
- `Startup/startup_stm32f303vctx.s`
- `STM32F303VCTX_FLASH.ld`
- `Src/assembly.s`
- `Src/definitions.s`
- `Src/initialise.s`
- `.cproject`
- `Debug/makefile`
- `Lab1_Group8 Debug.launch`

