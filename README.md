# MTRX2700 Lab 1 Group 8
## STM32 Assembly Architecture Scaffold / STM32 汇编架构脚手架

## 1. Project Title / 项目标题
**EN:** MTRX2700 Lab 1 root repository architecture refactor (assembly-only).  
**中文：** MTRX2700 Lab 1 根仓库架构重构（仅汇编）。

## 2. Overview / 项目概述
**EN:**  
This repository contains an STM32F3DISCOVERY project for MTRX2700.  
This revision is an architecture-first pass: the root assembly project was refactored from a flat layout into a modular scaffold to support later Exercise 1-5 implementation.

**中文：**  
本仓库是 MTRX2700 的 STM32F3DISCOVERY 工程。  
本次提交是“先架构后功能”的重构阶段：已将根目录中的扁平汇编结构重构为模块化脚手架，便于后续实现 Exercise 1-5。

## 3. Course Context / 课程背景
**EN:**  
- Course: `MTRX2700 Mechatronics 2`  
- Platform: `STM32F3DISCOVERY` (`STM32F303VCTx`, Cortex-M4)  
- Primary handout: `MTRX2700_ASM_lab.pdf`

**中文：**  
- 课程：`MTRX2700 Mechatronics 2`  
- 平台：`STM32F3DISCOVERY`（`STM32F303VCTx`，Cortex-M4）  
- 主要实验文档：`MTRX2700_ASM_lab.pdf`

## 4. Current Development Stage / 当前开发阶段
**EN:**  
Status as of **12 March 2026**: architecture scaffold complete, full exercise logic not implemented.  
This stage focuses on:
- module boundaries
- naming and comments
- build-safe source organisation
- honest documentation

**中文：**  
截至 **2026 年 3 月 12 日**：架构脚手架已完成，练习细节逻辑尚未实现。  
本阶段重点：
- 模块边界划分
- 命名与注释规范
- 在不破坏构建的前提下重组源码
- 如实文档说明

## 5. Root Repository Structure / 根目录结构
```text
Lab1_Group8/
├─ Src/
│  ├─ assembly.s
│  ├─ definitions.s
│  ├─ initialise.s
│  ├─ main.s
│  ├─ platform_defs.s
│  ├─ board_init.s
│  ├─ gpio_io.s
│  ├─ uart_io.s
│  ├─ timer_io.s
│  ├─ demo_dispatch.s
│  └─ runtime_support.s
├─ Startup/
│  └─ startup_stm32f303vctx.s
├─ Meeting Minutes/
├─ STM32F303VCTX_FLASH.ld
├─ MTRX2700_ASM_lab.pdf
└─ README.md
```

**EN:** `Exercise 1/` exists in the repository but is intentionally treated as an abandoned draft in this refactor pass.  
**中文：** 仓库中仍有 `Exercise 1/`，但本次重构明确将其视为废弃草稿，不作为设计参考。

## 6. Source Module Architecture / 源码模块架构
| File | Role (EN) | 作用（中文） |
| --- | --- | --- |
| `Src/assembly.s` | Thin compatibility aggregation unit; includes modular files to keep existing managed build expectations stable. | 兼容聚合文件；通过 `#include` 汇总模块，保持现有托管构建稳定。 |
| `Src/platform_defs.s` | Central register map, offsets, masks, constants, demo mode IDs, shared status codes. | 集中定义寄存器地址、偏移、掩码、常量、演示模式与状态码。 |
| `Src/main.s` | Owns `main` and `SystemInit`; provides clean top-level flow. | 管理 `main` 与 `SystemInit`；提供清晰顶层流程。 |
| `Src/board_init.s` | Board/peripheral bootstrap APIs and legacy init aliases. | 板级与外设初始化接口，并保留旧初始化函数别名。 |
| `Src/gpio_io.s` | LED/button helper interfaces (`gpioWriteLedPattern`, button reads, compatibility alias). | LED/按键辅助接口（含兼容别名）。 |
| `Src/uart_io.s` | UART interface boundaries and placeholders (clock gate baseline only). | UART 接口边界与占位实现（当前仅保留时钟使能基线）。 |
| `Src/timer_io.s` | Timer interface boundaries and delay placeholders; keeps `softwareDelay` alias. | 定时器接口边界与延时占位实现；保留 `softwareDelay` 兼容别名。 |
| `Src/demo_dispatch.s` | Demo/exercise dispatch layer and default loop state. | 演示/练习分发层与默认循环状态管理。 |
| `Src/runtime_support.s` | newlib syscall stubs and `_sbrk` support for link completeness. | newlib 系统调用桩与 `_sbrk`，用于保证链接完整。 |
| `Src/definitions.s` | Compatibility wrapper pointing to `platform_defs.s`. | 兼容包装文件，转接到 `platform_defs.s`。 |
| `Src/initialise.s` | Compatibility wrapper; real init logic moved to `board_init.s`. | 兼容包装文件；真实初始化逻辑已迁移到 `board_init.s`。 |

## 7. Design Principles / 设计原则
**EN:**
- Keep assembly-only implementation (`.s`) and GNU ARM compatibility.
- Separate responsibilities by module, not by exercise copy-paste.
- Preserve startup/linker integration and symbol clarity.
- Prefer explicit stubs over half-finished hidden logic.
- Keep future extension paths obvious for tutors and teammates.

**中文：**
- 保持纯汇编实现（`.s`）与 GNU ARM 兼容性。
- 按职责拆分模块，而非按练习堆叠代码。
- 保持启动文件/链接脚本集成与符号归属清晰。
- 采用明确占位桩函数，不伪造“已完成”逻辑。
- 让后续扩展路径对助教与队友都清晰可读。

## 8. Build and Import Instructions / 构建与导入说明
**EN:**
1. Open the project in `STM32CubeIDE`.
2. Ensure build configuration is `Debug` (or `Release` if configured).
3. Run `Project -> Clean`.
4. Run `Project -> Build Project`.
5. Flash/debug as normal via ST-LINK.

**中文：**
1. 使用 `STM32CubeIDE` 打开本工程。
2. 确认构建配置为 `Debug`（或已配置的 `Release`）。
3. 执行 `Project -> Clean`。
4. 执行 `Project -> Build Project`。
5. 通过 ST-LINK 正常下载与调试。

## 9. Implemented vs Not Yet Implemented / 已完成与未完成内容
**EN (implemented in this stage):**
- Modular assembly architecture in root `Src/`.
- Clean entry flow: `main -> boardInit -> initialiseDemoState -> dispatchDemoMode`.
- Baseline board GPIO setup and LED pattern loop.
- Runtime/link support stubs (`SystemInit`, syscall layer, `_sbrk`).
- Compatibility wrappers for existing generated build inputs.

**EN (not implemented yet):**
- Full Exercise 1 string/framing/checksum logic.
- Full Exercise 2 button counter/debounce/state machine.
- Full Exercise 3 UART TX/RX protocol behaviour.
- Full Exercise 4 hardware timer scheduling logic.
- Full Exercise 5 multi-board integrated protocol flow.

**中文（本阶段已完成）：**
- 根目录 `Src/` 的模块化汇编架构。
- 清晰入口流程：`main -> boardInit -> initialiseDemoState -> dispatchDemoMode`。
- 板级 GPIO 初始化与基础 LED 模式循环。
- 运行时/链接支持桩函数（`SystemInit`、syscall、`_sbrk`）。
- 面向现有构建输入的兼容包装层。

**中文（尚未完成）：**
- Exercise 1 的字符串/封包/BCC 校验完整逻辑。
- Exercise 2 的按键计数/去抖/状态机完整逻辑。
- Exercise 3 的 UART 收发协议完整行为。
- Exercise 4 的硬件定时器调度完整逻辑。
- Exercise 5 的双板通信集成完整流程。

## 10. Next Development Plan / 后续开发计划
**EN:**
1. Implement exercise-specific logic inside existing module interfaces (no architecture rollback).
2. Replace placeholder UART/timer routines with hardware-backed implementations.
3. Add deterministic button handling (polling + debounce strategy).
4. Add test checklist updates per exercise completion.

**中文：**
1. 在现有模块接口内逐步实现各练习逻辑（不回退架构）。
2. 将 UART/定时器占位实现替换为真实硬件实现。
3. 增加可重复验证的按键处理（轮询 + 去抖策略）。
4. 随练习进度同步更新测试检查表。

## 11. Notes for Assessors / 给考核者的说明
**EN:**
- This README intentionally reports architecture status honestly and does not claim Exercise 1-5 completion.
- `Meeting Minutes/` was kept unchanged for repository continuity; rename can be done later if required by marking rubric wording.
- FPU/ABI note: project build settings are hard-float (`fpv4-sp-d16`, hard ABI). ST startup file remains vendor-managed (`.fpu softvfp`) to minimise risk; application modules do not rely on startup-stage FP instructions.

**中文：**
- 本 README 有意如实反映“架构阶段”状态，不宣称 Exercise 1-5 已完成。
- `Meeting Minutes/` 目录本次未改名，以保持仓库连续性；若评分细则要求，可后续统一改名。
- FPU/ABI 说明：工程构建配置为硬浮点（`fpv4-sp-d16`，hard ABI）。ST 启动文件保持厂商默认（`.fpu softvfp`）以降低风险；应用模块不依赖启动阶段浮点指令。
