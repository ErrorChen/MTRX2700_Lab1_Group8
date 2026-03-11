#ifndef MAIN_S
#define MAIN_S

#include "platform_defs.s"

.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

.global main
.global SystemInit

.section .text.main, "ax", %progbits
.align 2

/* Purpose: Startup system hook used by Reset_Handler in ST startup file.
 * Inputs: none
 * Outputs: none
 * Clobbers: none
 * Preserves: all registers
 * Notes/TODO:
 * - Kept intentionally minimal in this stage.
 * - Clock-tree customisation can be added here in a later pass if required.
 */
.type SystemInit, %function
.thumb_func
SystemInit:
    bx lr
.size SystemInit, . - SystemInit

/* Purpose: Application entry point.
 * Inputs: none
 * Outputs: does not return in normal operation
 * Clobbers: r0-r3, lr
 * Preserves: r4-r11
 * High-level flow:
 *   main -> boardInit -> initialiseDemoState -> dispatchDemoMode
 */
.type main, %function
.thumb_func
main:
    bl boardInit
    bl initialiseDemoState
    bl dispatchDemoMode

    /* Defensive trap if dispatcher unexpectedly returns. */
main_unexpected_return:
    b main_unexpected_return
.size main, . - main

#endif /* MAIN_S */
