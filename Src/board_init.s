#ifndef BOARD_INIT_S
#define BOARD_INIT_S

#include "platform_defs.s"

.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

.global boardInit
.global boardEnableGpioClocks
.global boardConfigureLedPins
.global boardConfigureUserButton
.global enablePeripheralClocks
.global initialiseDiscoveryBoard

.section .text.board_init, "ax", %progbits
.align 2

/* Purpose: Board-level hardware bootstrap for this project stage.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r3, lr
 * Preserves: r4-r11
 * Notes:
 * - Enables GPIO clocks and configures LED/button pins.
 * - Calls UART/timer module init entry points for layered architecture.
 * - Full peripheral runtime behaviour is intentionally deferred.
 */
.type boardInit, %function
.thumb_func
boardInit:
    push {lr}
    bl boardEnableGpioClocks
    bl boardConfigureLedPins
    bl boardConfigureUserButton
    bl uartInit
    bl timerInit
    pop {pc}
.size boardInit, . - boardInit

/* Purpose: Enable GPIOA and GPIOE peripheral clocks.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r2
 * Preserves: r4-r11, lr
 */
.type boardEnableGpioClocks, %function
.thumb_func
boardEnableGpioClocks:
    ldr r0, =RCC_BASE
    ldr r1, [r0, #RCC_AHBENR_OFFSET]
    ldr r2, =(RCC_AHBENR_IOPAEN | RCC_AHBENR_IOPEEN)
    orrs r1, r1, r2
    str r1, [r0, #RCC_AHBENR_OFFSET]
    bx lr
.size boardEnableGpioClocks, . - boardEnableGpioClocks

/* Purpose: Configure PE8..PE15 as push-pull GPIO outputs for board LEDs.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r2
 * Preserves: r4-r11, lr
 */
.type boardConfigureLedPins, %function
.thumb_func
boardConfigureLedPins:
    ldr r0, =GPIOE_BASE
    ldr r1, [r0, #GPIO_MODER_OFFSET]
    ldr r2, =GPIOE_MODER_MASK_LOW16
    ands r1, r1, r2
    ldr r2, =GPIOE_MODER_OUTPUT_8_15
    orrs r1, r1, r2
    str r1, [r0, #GPIO_MODER_OFFSET]
    bx lr
.size boardConfigureLedPins, . - boardConfigureLedPins

/* Purpose: Configure PA0 as pulldown input for the B1 user button.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r2
 * Preserves: r4-r11, lr
 */
.type boardConfigureUserButton, %function
.thumb_func
boardConfigureUserButton:
    ldr r0, =GPIOA_BASE

    /* PA0 mode = input (00). */
    ldr r1, [r0, #GPIO_MODER_OFFSET]
    ldr r2, =GPIOA_MODER_CLEAR_PA0
    ands r1, r1, r2
    str r1, [r0, #GPIO_MODER_OFFSET]

    /* PA0 pull = pulldown (10). */
    ldr r1, [r0, #GPIO_PUPDR_OFFSET]
    ldr r2, =GPIOA_PUPDR_CLEAR_PA0
    ands r1, r1, r2
    ldr r2, =GPIOA_PUPDR_PULLDOWN_PA0
    orrs r1, r1, r2
    str r1, [r0, #GPIO_PUPDR_OFFSET]
    bx lr
.size boardConfigureUserButton, . - boardConfigureUserButton

/* Purpose: Backward-compatible alias from legacy layout.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r2
 * Preserves: r4-r11, lr
 */
.type enablePeripheralClocks, %function
.thumb_func
enablePeripheralClocks:
    b boardEnableGpioClocks
.size enablePeripheralClocks, . - enablePeripheralClocks

/* Purpose: Backward-compatible alias from legacy layout.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r2, lr
 * Preserves: r4-r11
 */
.type initialiseDiscoveryBoard, %function
.thumb_func
initialiseDiscoveryBoard:
    push {lr}
    bl boardConfigureLedPins
    bl boardConfigureUserButton
    pop {pc}
.size initialiseDiscoveryBoard, . - initialiseDiscoveryBoard

#endif /* BOARD_INIT_S */
