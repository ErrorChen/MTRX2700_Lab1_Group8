.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

#include "definitions.s"

.global enablePeripheralClocks
.global initialiseDiscoveryBoard

.section .text
.align 2

/* Purpose: Enable GPIOA and GPIOE peripheral clocks.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r2
 * Preserves: r4-r11, lr
 * Test: inspect RCC->AHBENR bits IOPAEN and IOPEEN after call.
 */
.type enablePeripheralClocks, %function
.thumb_func
enablePeripheralClocks:
    ldr r0, =RCC_BASE
    ldr r1, [r0, #RCC_AHBENR_OFFSET]
    LDR r2, =(RCC_AHBENR_IOPAEN | RCC_AHBENR_IOPEEN)
    orrs r1, r1, r2
    str r1, [r0, #RCC_AHBENR_OFFSET]
    bx lr
.size enablePeripheralClocks, . - enablePeripheralClocks

/* Purpose: Configure board GPIO for LEDs and USER button.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r2
 * Preserves: r4-r11, lr
 * Test: GPIOE MODER[31:16] == 0x5555, PA0 mode=input, PA0 pulldown enabled.
 */
.type initialiseDiscoveryBoard, %function
.thumb_func
initialiseDiscoveryBoard:
    /* PE8..PE15 -> output mode (01) */
    ldr r0, =GPIOE_BASE
    ldr r1, [r0, #GPIO_MODER_OFFSET]
    ldr r2, =GPIOE_MODER_MASK_LOW16
    ands r1, r1, r2
    ldr r2, =GPIOE_MODER_OUTPUT_8_15
    orrs r1, r1, r2
    str r1, [r0, #GPIO_MODER_OFFSET]

    /* PA0 -> input mode (00) */
    ldr r0, =GPIOA_BASE
    ldr r1, [r0, #GPIO_MODER_OFFSET]
    ldr r2, =GPIOA_MODER_CLEAR_PA0
    ands r1, r1, r2
    str r1, [r0, #GPIO_MODER_OFFSET]

    /* PA0 pull-down (10) for a stable button input */
    ldr r1, [r0, #GPIO_PUPDR_OFFSET]
    ldr r2, =GPIOA_PUPDR_CLEAR_PA0
    ands r1, r1, r2
    ldr r2, =GPIOA_PUPDR_PULLDOWN_PA0
    orrs r1, r1, r2
    str r1, [r0, #GPIO_PUPDR_OFFSET]
    bx lr
.size initialiseDiscoveryBoard, . - initialiseDiscoveryBoard
