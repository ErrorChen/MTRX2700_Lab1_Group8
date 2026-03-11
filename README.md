# MTRX2700 Lab 1 Group 8 - STM32F3 Assembly Implementation

## English

### 1. Project Overview
This repository contains a pure-assembly STM32F3DISCOVERY implementation for MTRX2700 Lab 1 (Exercises 1-5).  
Application logic is fully written in GNU Arm assembly (`.s`) and organised by exercise modules.

### 2. Hardware Platform
- Board: `STM32F3DISCOVERY`
- MCU: `STM32F303VCTx` (Cortex-M4)
- Toolchain: GNU Arm Embedded (STM32CubeIDE managed project)
- Startup / Linker: `Startup/startup_stm32f303vctx.s`, `STM32F303VCTX_FLASH.ld`

### 3. Source Structure
```text
Src/
  assembly.s      # top-level entry, dispatcher, shared helpers, syscall stubs
  definitions.s   # shared constants (RCC/GPIO/UART/TIM/message/config)
  initialise.s    # board/peripheral initialisation helpers
  exercise1.s     # memory, string, framing, BCC
  exercise2.s     # digital I/O counter, debounce, mode switching
  exercise3.s     # UART4/UART5 polling communication and frame validation
  exercise4.s     # TIM2 microsecond delays and dual-rate LED timing
  exercise5.s     # full TX/RX integration role logic
```

### 4. Top-Level Dispatcher (`Src/assembly.s`)
- Defines `SystemInit` and `main`.
- Calls:
  - `enablePeripheralClocks`
  - `initialiseDiscoveryBoard`
  - `timInit1MHz`
- Uses compile-time selector:
  - `.equ ACTIVE_EXERCISE, 1..5`
- Dispatches to:
  - `exercise1Entry` / `exercise2Entry` / `exercise3Entry` / `exercise4Entry` / `exercise5Entry`
- If selector is invalid, enters a visible LED error loop.

### 5. Exercise 1 Implementation
Implemented in `exercise1.s`:
- `stringLength` (`R1` input, `R2` output)
- `stringConvertCaseInPlace` (`R1` string, `R2` mode)
- `buildFramedMessage` (`[STX][LEN][BODY][ETX][BCC]`)
- `calcBcc` and `verifyBcc` (8-bit XOR checksum)
- `exercise1Entry` demonstrates all required operations and stores results in RAM labels for debugger inspection.

### 6. Exercise 2 Implementation
Implemented in `exercise2.s`:
- `setLedBitmask` drives `PE8..PE15`
- `readUserButton` reads `PA0`
- `waitForButtonPressDebounced` with ~50 ms debounce and release gating
- `exercise2StepCounterState` handles up/down direction reversal at `0x00`/`0xFF`
- `exercise2TimedStep` supports timed stepping
- Mode select via `.equ EX2_ACTIVE_MODE`:
  - `EX2_MODE_BUTTON`
  - `EX2_MODE_TIMED`

### 7. Exercise 3 Implementation
Implemented in `exercise3.s`:
- `uart4Init`, `uart5Init`
- `uartSendBuffer`, `uartReadByteBlocking`
- `uartReceiveFramedMessage` validates STX, LEN, ETX, checksum, payload string rules
- `uartSendAckMessage`, `uartSendNakMessage`
- `computeUartBrrFromClock`
- RX/TX buffers and status words are kept in `.bss` for debugging.

### 8. Exercise 4 Implementation
Implemented in `exercise4.s`:
- `timInit1MHz` configures TIM2 for 1 us tick
- `delayUsTimer` (counter-based polling delay)
- `delayUsTimerPreload` (ARR preload path, `ARPE=1`)
- `exercise4Count100usFor1Second` counts 100 us periods over 1 s
- `exercise4DualBlinkService` runs two independent LED blink schedules using absolute-time checks

### 9. Exercise 5 Integration
Implemented in `exercise5.s`:
- Compile-time role selection:
  - `EX5_ROLE_TX`, `EX5_ROLE_RX`
  - `.equ EX5_ACTIVE_ROLE, ...`
- Transmitter role:
  - Builds `COUNTER = XXX`
  - Frames and sends message
  - Waits up to 5 s for ACK/NAK
  - ACK: increment counter
  - NAK/timeout: flash LEDs three times (0.5 s intervals), reset counter
- Receiver role:
  - Receives and validates framed message
  - Parses counter payload and displays low 8 bits on LEDs
  - Sends ACK on success, NAK on invalid data

### 10. Build Instructions
#### STM32CubeIDE
1. Import/open project `Lab1_Group8`.
2. Select build configuration (`Debug`).
3. `Project -> Clean`.
4. `Project -> Build Project`.

#### Command line (from repository root)
```powershell
make -C Debug clean
make -C Debug -j
```

### 11. Run / Demo Instructions
1. Open `Src/assembly.s` and set `.equ ACTIVE_EXERCISE` to the exercise to demonstrate.
2. Build and flash using ST-LINK.
3. For Exercise 5, set `.equ EX5_ACTIVE_ROLE` in `Src/definitions.s`:
   - board A: `EX5_ROLE_TX`
   - board B: `EX5_ROLE_RX`
4. Rebuild and flash both boards.

### 12. Testing and Verification Procedure
- Exercise 1: inspect `ex1_*` RAM symbols for length, framed buffer, BCC verification.
- Exercise 2: verify binary LED counter transitions and direction reversal boundaries.
- Exercise 3: verify framed TX/RX, status codes, and ACK/NAK responses in memory.
- Exercise 4: verify `ex4_count_100us_result == 10000` and independent dual blink frequencies.
- Exercise 5: verify TX counter progression on ACK and reset-on-error behaviour.

### 13. UART Wiring and Timer Assumptions
- UART GPIO mapping used in code:
  - UART4: `PC10` TX, `PC11` RX (AF5)
  - UART5: `PC12` TX, `PD2` RX (AF5)
- Two-board UART4 link for integration demo:
  - Board A `PC10 (TX)` -> Board B `PC11 (RX)`
  - Board A `PC11 (RX)` <- Board B `PC10 (TX)`
  - Common GND between boards
- Optional single-board Exercise 3 loopback:
  - `PC10 -> PD2`, `PC12 -> PC11`
- Timer assumption:
  - `SystemInit` is minimal, clock is treated as default 8 MHz source
  - TIM2 prescaler sets 1 MHz timer tick

### 14. Team
- MTRX2700 Lab 1 Group 8

## 中文

### 1. 项目概述
本仓库是 MTRX2700 Lab 1（Exercise 1-5）的 STM32F3DISCOVERY 纯汇编实现。  
应用逻辑全部使用 GNU Arm 汇编（`.s`）完成，并按练习模块化组织。

### 2. 硬件平台
- 开发板：`STM32F3DISCOVERY`
- MCU：`STM32F303VCTx`（Cortex-M4）
- 工具链：GNU Arm Embedded（STM32CubeIDE 托管工程）
- 启动/链接文件：`Startup/startup_stm32f303vctx.s`、`STM32F303VCTX_FLASH.ld`

### 3. 源码结构
```text
Src/
  assembly.s      # 顶层入口、分发器、共享辅助函数、syscall 桩
  definitions.s   # 全局常量（RCC/GPIO/UART/TIM/消息/配置）
  initialise.s    # 板级与外设初始化函数
  exercise1.s     # 内存、字符串、封包、BCC
  exercise2.s     # 数字 I/O 计数器、去抖、模式切换
  exercise3.s     # UART4/UART5 轮询通信与帧校验
  exercise4.s     # TIM2 微秒级延时与双频 LED 定时
  exercise5.s     # 发射/接收角色整合逻辑
```

### 4. 顶层分发（`Src/assembly.s`）
- 定义 `SystemInit` 与 `main`。
- `main` 依次调用：
  - `enablePeripheralClocks`
  - `initialiseDiscoveryBoard`
  - `timInit1MHz`
- 使用编译期选择器：
  - `.equ ACTIVE_EXERCISE, 1..5`
- 分发到：
  - `exercise1Entry` / `exercise2Entry` / `exercise3Entry` / `exercise4Entry` / `exercise5Entry`
- 选择器非法时进入可见 LED 错误循环。

### 5. Exercise 1 实现
`exercise1.s` 实现：
- `stringLength`（输入 `R1`，输出 `R2`）
- `stringConvertCaseInPlace`（`R1` 字符串，`R2` 模式）
- `buildFramedMessage`（`[STX][LEN][BODY][ETX][BCC]`）
- `calcBcc` 与 `verifyBcc`（8 位异或校验）
- `exercise1Entry` 完成全部演示并将结果写入 RAM 变量，便于调试器检查。

### 6. Exercise 2 实现
`exercise2.s` 实现：
- `setLedBitmask` 驱动 `PE8..PE15`
- `readUserButton` 读取 `PA0`
- `waitForButtonPressDebounced`（约 50 ms 去抖，且等待按键释放）
- `exercise2StepCounterState` 在 `0x00`/`0xFF` 边界切换方向
- `exercise2TimedStep` 支持定时步进
- 通过 `.equ EX2_ACTIVE_MODE` 选择模式：
  - `EX2_MODE_BUTTON`
  - `EX2_MODE_TIMED`

### 7. Exercise 3 实现
`exercise3.s` 实现：
- `uart4Init`、`uart5Init`
- `uartSendBuffer`、`uartReadByteBlocking`
- `uartReceiveFramedMessage`（校验 STX、LEN、ETX、校验和、字符串规则）
- `uartSendAckMessage`、`uartSendNakMessage`
- `computeUartBrrFromClock`
- RX/TX 缓冲区与状态变量放在 `.bss`，便于调试观察。

### 8. Exercise 4 实现
`exercise4.s` 实现：
- `timInit1MHz`：配置 TIM2 为 1 us/tick
- `delayUsTimer`：基于计数器轮询延时
- `delayUsTimerPreload`：基于 ARR 预装载路径（`ARPE=1`）
- `exercise4Count100usFor1Second`：统计 1 秒内 100 us 周期次数
- `exercise4DualBlinkService`：基于绝对时间比较实现双 LED 独立频率闪烁

### 9. Exercise 5 整合
`exercise5.s` 实现：
- 编译期角色选择：
  - `EX5_ROLE_TX`、`EX5_ROLE_RX`
  - `.equ EX5_ACTIVE_ROLE, ...`
- 发送端：
  - 生成 `COUNTER = XXX`
  - 封包并发送
  - 最长等待 5 秒 ACK/NAK
  - 收到 ACK：计数加一
  - NAK/超时：LED 以 0.5 秒间隔闪烁 3 次并清零计数
- 接收端：
  - 接收并校验帧
  - 解析计数并显示到 LED（低 8 位）
  - 正确回复 ACK，错误回复 NAK

### 10. 构建说明
#### STM32CubeIDE
1. 导入/打开工程 `Lab1_Group8`。
2. 选择构建配置（`Debug`）。
3. 执行 `Project -> Clean`。
4. 执行 `Project -> Build Project`。

#### 命令行（仓库根目录）
```powershell
make -C Debug clean
make -C Debug -j
```

### 11. 运行与演示说明
1. 在 `Src/assembly.s` 设置 `.equ ACTIVE_EXERCISE` 选择演示练习。
2. 编译并通过 ST-LINK 下载。
3. Exercise 5 在 `Src/definitions.s` 设置 `.equ EX5_ACTIVE_ROLE`：
   - 板 A：`EX5_ROLE_TX`
   - 板 B：`EX5_ROLE_RX`
4. 两块板分别重新编译并下载。

### 12. 测试与验证流程
- Exercise 1：检查 `ex1_*` 变量（长度、封包缓冲区、BCC 校验结果）。
- Exercise 2：验证 LED 二进制计数与上下边界反转。
- Exercise 3：验证帧收发、状态码和 ACK/NAK 回复。
- Exercise 4：验证 `ex4_count_100us_result == 10000` 及双频独立闪烁。
- Exercise 5：验证 ACK 正常递增，异常时闪烁并清零重启。

### 13. UART 接线与定时假设
- 代码使用的 UART 引脚：
  - UART4：`PC10` TX、`PC11` RX（AF5）
  - UART5：`PC12` TX、`PD2` RX（AF5）
- 双板 Exercise 5（UART4）连接：
  - A 板 `PC10 (TX)` -> B 板 `PC11 (RX)`
  - A 板 `PC11 (RX)` <- B 板 `PC10 (TX)`
  - 两板必须共地
- 单板 Exercise 3 可选回环：
  - `PC10 -> PD2`，`PC12 -> PC11`
- 定时假设：
  - `SystemInit` 保持最小实现，按默认 8 MHz 时钟源处理
  - TIM2 通过预分频配置为 1 MHz 计数

### 14. 团队
- MTRX2700 Lab 1 Group 8
