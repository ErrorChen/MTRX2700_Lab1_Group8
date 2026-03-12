#include "platform_defs.inc"

.global softwareDelayCycles

.section .text.delay_software, "ax", %progbits
.align 2

/* Purpose: Busy-loop delay for coarse timing without timer peripherals.
 * Inputs: r0 = loop iterations
 * Outputs: none
 * Clobbers: r0
 * Preserved registers: r1-r11, lr
 * Side effects: Consumes CPU cycles while blocking.
 * Test idea: Toggle an LED around the call and measure pulse width trend.
 */
.type softwareDelayCycles, %function
.thumb_func
softwareDelayCycles:
    cmp r0, #0
    beq softwareDelayCycles_done

softwareDelayCycles_loop:
    subs r0, r0, #1
    bne softwareDelayCycles_loop

softwareDelayCycles_done:
    bx lr
.size softwareDelayCycles, . - softwareDelayCycles
