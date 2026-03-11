#ifndef TIMER_IO_S
#define TIMER_IO_S

#include "platform_defs.s"

.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

.global timerInit
.global timerDelayCycles
.global timerDelayMilliseconds
.global timerGetTick
.global softwareDelay

.section .text.timer_io, "ax", %progbits
.align 2

/* Purpose: Timer layer initialisation entry point.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r2
 * Preserves: r4-r11, lr
 * Notes/TODO:
 * - Architecture-stage baseline only.
 * - Currently enables TIM2 peripheral clock only.
 * - Timer mode, prescaler, period, and ISR logic are deferred.
 */
.type timerInit, %function
.thumb_func
timerInit:
    ldr r0, =RCC_BASE
    ldr r1, [r0, #RCC_APB1ENR_OFFSET]
    ldr r2, =RCC_APB1ENR_TIM2EN
    orrs r1, r1, r2
    str r1, [r0, #RCC_APB1ENR_OFFSET]
    bx lr
.size timerInit, . - timerInit

/* Purpose: Architecture baseline delay primitive using software loops.
 * Inputs: r0 = loop count
 * Outputs: none
 * Clobbers: r0
 * Preserves: r1-r11, lr
 * Notes/TODO: Replace with calibrated hardware timer delays in next pass.
 */
.type timerDelayCycles, %function
.thumb_func
timerDelayCycles:
    cmp r0, #0
    beq timerDelayCycles_done
timerDelayCycles_loop:
    subs r0, r0, #1
    bne timerDelayCycles_loop
timerDelayCycles_done:
    bx lr
.size timerDelayCycles, . - timerDelayCycles

/* Purpose: Backward-compatible alias for previous API name.
 * Inputs: r0 = loop count
 * Outputs: none
 * Clobbers: r0
 * Preserves: r1-r11, lr
 */
.type softwareDelay, %function
.thumb_func
softwareDelay:
    b timerDelayCycles
.size softwareDelay, . - softwareDelay

/* Purpose: Millisecond delay API boundary.
 * Inputs: r0 = delay in milliseconds
 * Outputs: none
 * Clobbers: r0
 * Preserves: r1-r11, lr
 * Notes/TODO: Placeholder only; currently no calibrated ms timing.
 */
.type timerDelayMilliseconds, %function
.thumb_func
timerDelayMilliseconds:
    bx lr
.size timerDelayMilliseconds, . - timerDelayMilliseconds

/* Purpose: Monotonic tick query API boundary.
 * Inputs: none
 * Outputs: r0 = current tick count
 * Clobbers: r0
 * Preserves: r1-r11, lr
 * Notes/TODO: Placeholder returns zero until timer scheduling is implemented.
 */
.type timerGetTick, %function
.thumb_func
timerGetTick:
    movs r0, #0
    bx lr
.size timerGetTick, . - timerGetTick

#endif /* TIMER_IO_S */
