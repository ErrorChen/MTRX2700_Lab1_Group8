.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

/* ----------------------------------------------------------------------------
 * Compatibility aggregation unit.
 *
 * Why this file still exists:
 * - The checked-in generated build metadata currently compiles:
 *     Src/assembly.s
 *     Src/definitions.s
 *     Src/initialise.s
 * - To avoid destabilising STM32CubeIDE managed build behaviour in this
 *   architecture pass, this file now acts as a thin orchestrator that includes
 *   the modular source units below.
 *
 * Real ownership has moved to dedicated modules in Src/.
 * ----------------------------------------------------------------------------
 */

#include "platform_defs.s"
#include "gpio_io.s"
#include "uart_io.s"
#include "timer_io.s"
#include "board_init.s"
#include "demo_dispatch.s"
#include "main.s"
#include "runtime_support.s"
