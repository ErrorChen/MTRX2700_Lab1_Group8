#ifndef GPIO_IO_S
#define GPIO_IO_S

#include "platform_defs.s"

.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

.global gpioWriteLedPattern
.global gpioReadUserButton
.global gpioReadButtonDebounced
.global gpioSetAllLedsOff
.global ledWritePattern

.section .text.gpio_io, "ax", %progbits
.align 2

/* Purpose: Write an 8-bit LED pattern to PE8..PE15.
 * Inputs: r0 = LED bit pattern (bit0->PE8 ... bit7->PE15)
 * Outputs: none
 * Clobbers: r1
 * Preserves: r2-r11, lr
 */
.type gpioWriteLedPattern, %function
.thumb_func
gpioWriteLedPattern:
    ldr r1, =GPIOE_BASE
    strb r0, [r1, #LED_ODR_HIGH_BYTE_OFFSET]
    bx lr
.size gpioWriteLedPattern, . - gpioWriteLedPattern

/* Purpose: Backward-compatible alias for previous API name.
 * Inputs: r0 = LED bit pattern
 * Outputs: none
 * Clobbers: r1
 * Preserves: r2-r11, lr
 */
.type ledWritePattern, %function
.thumb_func
ledWritePattern:
    b gpioWriteLedPattern
.size ledWritePattern, . - ledWritePattern

/* Purpose: Read B1 user button state from PA0.
 * Inputs: none
 * Outputs: r0 = 0 (released) or 1 (pressed)
 * Clobbers: r1
 * Preserves: r2-r11, lr
 */
.type gpioReadUserButton, %function
.thumb_func
gpioReadUserButton:
    ldr r1, =GPIOA_BASE
    ldr r0, [r1, #GPIO_IDR_OFFSET]
    ands r0, r0, #GPIO_PIN_0_MASK
    lsrs r0, r0, #GPIO_PIN_0_SHIFT
    bx lr
.size gpioReadUserButton, . - gpioReadUserButton

/* Purpose: Debounced button-read interface.
 * Inputs: none
 * Outputs: r0 = 0/1 logical button state
 * Clobbers: r1
 * Preserves: r2-r11, lr
 * Notes/TODO: Placeholder currently performs a direct read only.
 */
.type gpioReadButtonDebounced, %function
.thumb_func
gpioReadButtonDebounced:
    b gpioReadUserButton
.size gpioReadButtonDebounced, . - gpioReadButtonDebounced

/* Purpose: Turn off all user LEDs.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r1
 * Preserves: r2-r11, lr
 */
.type gpioSetAllLedsOff, %function
.thumb_func
gpioSetAllLedsOff:
    movs r0, #0
    b gpioWriteLedPattern
.size gpioSetAllLedsOff, . - gpioSetAllLedsOff

#endif /* GPIO_IO_S */
