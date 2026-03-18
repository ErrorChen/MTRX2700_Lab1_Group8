# MTRX2700 Lab 1 Group 8

## English

### 1) Project Overview
- Course/lab: MTRX2700, Lab 1
- Target board/MCU: STM32F3 Discovery, STM32F303VCTx (Cortex-M4)
- Language: GNU Arm Assembly (`.s`)
- Toolchain/workflow: STM32CubeIDE managed build + GNU Arm (`arm-none-eabi`)

### 2) Current Architecture Overview
Runtime entry flow:

```text
Startup/startup_stm32f303vctx.s: Reset_Handler
  -> Src/main.s: SystemInit
  -> Src/main.s: main
     -> enablePeripheralClocks      (Src/board_init.s)
     -> initialiseDiscoveryBoard    (Src/board_init.s)
     -> timInit1MHz                 (Src/timer_io.s)
     -> dispatchExerciseById(ACTIVE_EXERCISE)
        -> exercise1Entry .. exercise5Entry
```

Authoritative ownership:
- Runtime entry + dispatch: `Src/main.s`
- Board/peripheral baseline init: `Src/board_init.s`
- Constants/register defs/compile-time selectors: `Src/platform_defs.inc`

### 3) Clean Final Source Tree

```text
Lab1_Group8/
|-- Src/
|   |-- board_init.s
|   |-- button_io.s
|   |-- counter_format.s
|   |-- delay_software.s
|   |-- exercise1.s
|   |-- exercise2.s
|   |-- exercise3.s
|   |-- exercise4.s
|   |-- exercise5.s
|   |-- frame_codec.s
|   |-- gpio_led.s
|   |-- main.s
|   |-- platform_defs.inc
|   |-- runtime_syscalls.s
|   |-- string_ops.s
|   |-- timer_io.s
|   `-- uart_io.s
|-- Startup/startup_stm32f303vctx.s
|-- STM32F303VCTX_FLASH.ld
|-- .project / .cproject
`-- README.md
```

### 4) Module Responsibility Table
| File | Responsibility |
|---|---|
| `main.s` | Defines `SystemInit`, `main`, and `dispatchExerciseById` (runtime owner). |
| `board_init.s` | Enables RCC clocks and configures GPIO baseline + UART AF pins + TIM2 clock. |
| `timer_io.s` | TIM2 1 MHz init and microsecond delay services (polling). |
| `gpio_led.s` | LED output helpers, error blink loop, and 3x flash indicator. |
| `button_io.s` | PA0 read and debounced button press/release wait (blocking). |
| `uart_io.s` | UART4/5 init, blocking TX/RX, frame receive validation, ACK/NAK, timeout wait. |
| `frame_codec.s` | STX/LEN/PAYLOAD/ETX/BCC framing and BCC verification. |
| `string_ops.s` | ASCII string length and in-place case conversion. |
| `counter_format.s` | Build/parse `COUNTER = XXX` payload format. |
| `delay_software.s` | Coarse software busy-loop delay utility. |
| `exercise1.s` | Exercise 1 orchestration (string/framing/checksum memory workflow). |
| `exercise2.s` | Exercise 2 orchestration (LED counter, button or timed stepping). |
| `exercise3.s` | Exercise 3 orchestration (UART framing RX validation and ACK/NAK response). |
| `exercise4.s` | Exercise 4 orchestration (timer validation and dual-rate LED service). |
| `exercise5.s` | Exercise 5 orchestration (TX/RX role-based framed counter protocol). |
| `runtime_syscalls.s` | Bare-metal newlib syscall stubs for link/runtime compatibility. |
| `platform_defs.inc` | Single source of project constants, addresses, selectors, and status codes. |

### 5) Exercise Mapping
| Exercise | Entry File | Core Focus |
|---|---|---|
| 1 | `Src/exercise1.s` (`exercise1Entry`) | String ops, frame generation, BCC validation in RAM/debug symbols. |
| 2 | `Src/exercise2.s` (`exercise2Entry`) | LED up/down counter service with button or timed stepping. |
| 3 | `Src/exercise3.s` (`exercise3Entry`) | UART4 send + UART5 receive frame check, ACK/NAK transmit, LED status. |
| 4 | `Src/exercise4.s` (`exercise4Entry`) | TIM2 timing check and dual independent LED blink schedules. |
| 5 | `Src/exercise5.s` (`exercise5Entry`) | UART4 framed counter protocol with TX/RX role selection and ACK/NAK flow. |

### 6) Configuration Points
Edit compile-time selectors in `Src/platform_defs.inc`:
- `ACTIVE_EXERCISE` (select exercise 1..5)
- `EX5_ACTIVE_ROLE` (`EX5_ROLE_TX` or `EX5_ROLE_RX`) for Exercise 5 role

Also available:
- `EX2_ACTIVE_MODE` (`EX2_MODE_BUTTON` or `EX2_MODE_TIMED`)

### 7) Build Instructions
STM32CubeIDE:
1. Import/open project root `Lab1_Group8`.
2. Confirm toolchain is GNU Arm Embedded (`arm-none-eabi`).
3. Run `Project -> Clean` then `Build Project`.

Command line (if CubeIDE-generated `Debug/` makefiles are present):
1. Ensure `arm-none-eabi-*` tools are in `PATH`.
2. Run `make -C Debug clean all`.

### 8) Run / Demo Instructions
1. In `Src/platform_defs.inc`, set `ACTIVE_EXERCISE`.
2. For Exercise 5, set `EX5_ACTIVE_ROLE` per board role.
3. Program and run under STM32CubeIDE debugger.
4. Observe LEDs/UART according to the selected exercise.

### 9) Testing / Verification Guide
- Exercise 1: Inspect `exercise1*` RAM symbols; confirm corrupted frame fails BCC validation.
- Exercise 2: Verify LED counter changes one step per debounced press (or timed step mode).
- Exercise 3: Trigger with USER button; verify UART frame receive status and ACK/NAK LED pattern.
- Exercise 4: Confirm `exercise4Count100usResult == EX4_PERIODS_IN_1S`; verify two LED blink rates.
- Exercise 5 TX: Verify periodic framed send, ACK increments counter, timeout/NAK flashes LEDs and resets counter.
- Exercise 5 RX: Verify valid payload updates LED counter and sends ACK; invalid frame/payload sends NAK with flash.

### 10) UART Wiring and Timer Assumptions
- UART pin mapping (AF5):
  - UART4: PC10 (TX), PC11 (RX)
  - UART5: PC12 (TX), PD2 (RX)
- Exercise 3 assumes UART4->UART5 data path is wired (typical local loop: PC10 to PD2).
- Exercise 5 assumes two-board UART4 cross-link:
  - Board A PC10(TX) -> Board B PC11(RX)
  - Board B PC10(TX) -> Board A PC11(RX)
  - Common GND required.
- Timer assumptions:
  - TIM2 configured to 1 MHz tick in `timInit1MHz`.
  - Timing/UART constants currently assume 8 MHz clock constants from `platform_defs.inc`.
- UART/button/timer services are polling/blocking (no interrupt-driven runtime).

### 11) Cleanup Note
Legacy placeholder files `Src/assembly.s`, `Src/initialise.s`, and `Src/definitions.s` were removed.
The active architecture is now documented around the real owners (`main.s`, `board_init.s`, `platform_defs.inc`).

---

## 简体中文

### 1）项目概览
- 课程/实验：MTRX2700，Lab 1
- 目标板卡/MCU：STM32F3 Discovery，STM32F303VCTx（Cortex-M4）
- 语言：GNU Arm 汇编（`.s`）
- 工具链/流程：STM32CubeIDE 管理构建 + GNU Arm（`arm-none-eabi`）

### 2）当前架构概览
运行入口流程：

```text
Startup/startup_stm32f303vctx.s: Reset_Handler
  -> Src/main.s: SystemInit
  -> Src/main.s: main
     -> enablePeripheralClocks      (Src/board_init.s)
     -> initialiseDiscoveryBoard    (Src/board_init.s)
     -> timInit1MHz                 (Src/timer_io.s)
     -> dispatchExerciseById(ACTIVE_EXERCISE)
        -> exercise1Entry .. exercise5Entry
```

权威归属：
- 运行入口与分发：`Src/main.s`
- 板级/外设基础初始化：`Src/board_init.s`
- 常量/寄存器定义/编译期选择：`Src/platform_defs.inc`

### 3）清理后的源文件树

```text
Lab1_Group8/
|-- Src/
|   |-- board_init.s
|   |-- button_io.s
|   |-- counter_format.s
|   |-- delay_software.s
|   |-- exercise1.s
|   |-- exercise2.s
|   |-- exercise3.s
|   |-- exercise4.s
|   |-- exercise5.s
|   |-- frame_codec.s
|   |-- gpio_led.s
|   |-- main.s
|   |-- platform_defs.inc
|   |-- runtime_syscalls.s
|   |-- string_ops.s
|   |-- timer_io.s
|   `-- uart_io.s
|-- Startup/startup_stm32f303vctx.s
|-- STM32F303VCTX_FLASH.ld
|-- .project / .cproject
`-- README.md
```

### 4）模块职责表
| 文件 | 职责 |
|---|---|
| `main.s` | 定义 `SystemInit`、`main`、`dispatchExerciseById`（运行时入口主控）。 |
| `board_init.s` | 完成 RCC 时钟使能、GPIO 基础配置、UART 复用配置、TIM2 时钟使能。 |
| `timer_io.s` | TIM2 1MHz 初始化与微秒级延时（轮询）。 |
| `gpio_led.s` | LED 输出工具、错误闪烁循环、三次全闪提示。 |
| `button_io.s` | PA0 按键读取与消抖后的按下/释放阻塞等待。 |
| `uart_io.s` | UART4/5 初始化、阻塞收发、帧校验接收、ACK/NAK、超时等待。 |
| `frame_codec.s` | STX/LEN/PAYLOAD/ETX/BCC 组帧与 BCC 校验。 |
| `string_ops.s` | ASCII 字符串长度与原地大小写转换。 |
| `counter_format.s` | `COUNTER = XXX` 载荷的构建与解析。 |
| `delay_software.s` | 粗粒度软件忙等待延时。 |
| `exercise1.s` | 练习1编排（字符串/组帧/校验流程）。 |
| `exercise2.s` | 练习2编排（LED 计数，按键或定时步进）。 |
| `exercise3.s` | 练习3编排（UART 帧接收校验与 ACK/NAK 响应）。 |
| `exercise4.s` | 练习4编排（定时验证与双速 LED 服务）。 |
| `exercise5.s` | 练习5编排（TX/RX 角色化计数帧协议）。 |
| `runtime_syscalls.s` | 裸机 newlib 系统调用桩，保证链接/运行时兼容。 |
| `platform_defs.inc` | 全项目唯一常量、地址、选择开关、状态码定义源。 |

### 5）练习映射
| 练习 | 入口文件 | 核心内容 |
|---|---|---|
| 1 | `Src/exercise1.s` (`exercise1Entry`) | 字符串处理、组帧、BCC 校验（主要看内存符号）。 |
| 2 | `Src/exercise2.s` (`exercise2Entry`) | LED 往返计数，支持按键模式或定时模式。 |
| 3 | `Src/exercise3.s` (`exercise3Entry`) | UART4 发送 + UART5 接收校验，并发送 ACK/NAK。 |
| 4 | `Src/exercise4.s` (`exercise4Entry`) | TIM2 定时验证与两路独立闪烁节奏。 |
| 5 | `Src/exercise5.s` (`exercise5Entry`) | UART4 计数帧协议，按 TX/RX 角色运行。 |

### 6）配置入口
在 `Src/platform_defs.inc` 中修改编译期选择：
- `ACTIVE_EXERCISE`：选择练习 1..5
- `EX5_ACTIVE_ROLE`：练习5角色（`EX5_ROLE_TX` 或 `EX5_ROLE_RX`）

可选：
- `EX2_ACTIVE_MODE`：练习2模式（按键或定时）

### 7）构建说明
STM32CubeIDE：
1. 导入/打开项目根目录 `Lab1_Group8`。
2. 确认使用 GNU Arm Embedded 工具链（`arm-none-eabi`）。
3. 执行 `Project -> Clean`，再执行 `Build Project`。

命令行（已存在 CubeIDE 生成的 `Debug/` makefile 时）：
1. 确保 `arm-none-eabi-*` 在 `PATH` 中。
2. 执行 `make -C Debug clean all`。

### 8）运行 / 演示
1. 在 `Src/platform_defs.inc` 设置 `ACTIVE_EXERCISE`。
2. 练习5按板子角色设置 `EX5_ACTIVE_ROLE`。
3. 通过 STM32CubeIDE 下载并调试运行。
4. 按对应练习观察 LED/UART 行为。

### 9）测试 / 验证指引
- 练习1：查看 `exercise1*` 变量，确认故意破坏帧后 BCC 校验失败。
- 练习2：验证每次消抖按键（或每个定时步进）只推进一格计数。
- 练习3：按键触发一次事务，检查接收状态与 ACK/NAK 对应灯型。
- 练习4：确认 `exercise4Count100usResult == EX4_PERIODS_IN_1S`，并观察双频闪烁。
- 练习5 TX：ACK 时计数递增；超时或 NAK 时三闪并清零。
- 练习5 RX：有效载荷更新 LED 并回 ACK；无效帧/载荷回 NAK 并三闪。

### 10）UART 连线与定时假设
- UART 引脚（AF5）：
  - UART4：PC10（TX），PC11（RX）
  - UART5：PC12（TX），PD2（RX）
- 练习3假设 UART4->UART5 数据路径已连通（常见本地回环：PC10 接 PD2）。
- 练习5假设双板 UART4 交叉连线：
  - A 板 PC10(TX) -> B 板 PC11(RX)
  - B 板 PC10(TX) -> A 板 PC11(RX)
  - 两板必须共地。
- 定时假设：
  - `timInit1MHz` 将 TIM2 配置为 1MHz tick。
  - 计时/UART 常量目前按 `platform_defs.inc` 中 8MHz 时钟常量。
- UART/按键/定时服务均为轮询阻塞实现（非中断驱动）。

### 11）清理说明
已移除历史占位文件：`Src/assembly.s`、`Src/initialise.s`、`Src/definitions.s`。
README 已按当前真实架构更新，核心归属为 `main.s`、`board_init.s`、`platform_defs.inc`。