.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

#include "definitions.s"

.global enablePeripheralClocks
.global initialiseDiscoveryBoard
.global initialiseUartGpioPins
.global initialiseTimerClock

.section .text.initialise, "ax", %progbits
.align 2

/* Purpose: Enable clocks required by GPIO, UART, and timer modules.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r2
 * Preserves: r3-r11, lr
 * Test: Read RCC AHBENR/APB1ENR in debugger after return.
 */
.type enablePeripheralClocks, %function
.thumb_func
enablePeripheralClocks:
    ldr r0, =RCC_BASE

    ldr r1, [r0, #RCC_AHBENR_OFFSET]
    ldr r2, =(RCC_AHBENR_IOPAEN | RCC_AHBENR_IOPCEN | RCC_AHBENR_IOPDEN | RCC_AHBENR_IOPEEN)
    orrs r1, r1, r2
    str r1, [r0, #RCC_AHBENR_OFFSET]

    ldr r1, [r0, #RCC_APB1ENR_OFFSET]
    ldr r2, =(RCC_APB1ENR_TIM2EN | RCC_APB1ENR_UART4EN | RCC_APB1ENR_UART5EN)
    orrs r1, r1, r2
    str r1, [r0, #RCC_APB1ENR_OFFSET]
    bx lr
.size enablePeripheralClocks, . - enablePeripheralClocks

/* Purpose: Configure on-board LEDs (PE8..PE15) and user button (PA0).
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r2
 * Preserves: r3-r11, lr
 * Test: Verify PE8..PE15 output mode and PA0 pulldown input mode.
 */
.type initialiseDiscoveryBoard, %function
.thumb_func
initialiseDiscoveryBoard:
    /* PE8..PE15 -> output mode. */
    ldr r0, =GPIOE_BASE
    ldr r1, [r0, #GPIO_MODER_OFFSET]
    ldr r2, =GPIOE_LED_MODER_CLEAR_MASK
    ands r1, r1, r2
    ldr r2, =GPIOE_LED_MODER_OUTPUT
    orrs r1, r1, r2
    str r1, [r0, #GPIO_MODER_OFFSET]

    /* Turn all LEDs off at startup. */
    movs r1, #0
    strb r1, [r0, #LED_ODR_HIGH_BYTE_OFFSET]

    /* PA0 -> input mode with pulldown. */
    ldr r0, =GPIOA_BASE

    ldr r1, [r0, #GPIO_MODER_OFFSET]
    ldr r2, =GPIOA_PA0_MODER_CLEAR_MASK
    ands r1, r1, r2
    str r1, [r0, #GPIO_MODER_OFFSET]

    ldr r1, [r0, #GPIO_PUPDR_OFFSET]
    ldr r2, =GPIOA_PA0_PUPDR_CLEAR_MASK
    ands r1, r1, r2
    ldr r2, =GPIOA_PA0_PUPDR_PULLDOWN
    orrs r1, r1, r2
    str r1, [r0, #GPIO_PUPDR_OFFSET]
    bx lr
.size initialiseDiscoveryBoard, . - initialiseDiscoveryBoard

/* Purpose: Configure GPIO alternate-function mappings for UART4/UART5.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r2
 * Preserves: r3-r11, lr
 * Test: Check GPIOC MODER/AFRH and GPIOD MODER/AFRL bits for AF5.
 */
.type initialiseUartGpioPins, %function
.thumb_func
initialiseUartGpioPins:
    /* GPIOC pins 10,11,12 to AF mode. */
    ldr r0, =GPIOC_BASE
    ldr r1, [r0, #GPIO_MODER_OFFSET]
    ldr r2, =GPIOC_UART_PINS_MODER_CLEAR_MASK
    ands r1, r1, r2
    ldr r2, =GPIOC_UART_PINS_MODER_AF
    orrs r1, r1, r2
    str r1, [r0, #GPIO_MODER_OFFSET]

    ldr r1, [r0, #GPIO_AFRH_OFFSET]
    ldr r2, =GPIOC_UART_AFRH_CLEAR_MASK
    ands r1, r1, r2
    ldr r2, =GPIOC_UART_AFRH_AF5
    orrs r1, r1, r2
    str r1, [r0, #GPIO_AFRH_OFFSET]

    /* GPIOD pin 2 to AF mode. */
    ldr r0, =GPIOD_BASE
    ldr r1, [r0, #GPIO_MODER_OFFSET]
    ldr r2, =GPIOD_UART5_RX_MODER_CLEAR_MASK
    ands r1, r1, r2
    ldr r2, =GPIOD_UART5_RX_MODER_AF
    orrs r1, r1, r2
    str r1, [r0, #GPIO_MODER_OFFSET]

    ldr r1, [r0, #GPIO_AFRL_OFFSET]
    ldr r2, =GPIOD_UART_AFRL_CLEAR_MASK
    ands r1, r1, r2
    ldr r2, =GPIOD_UART_AFRL_AF5
    orrs r1, r1, r2
    str r1, [r0, #GPIO_AFRL_OFFSET]
    bx lr
.size initialiseUartGpioPins, . - initialiseUartGpioPins

/* Purpose: Ensure TIM2 peripheral clock is enabled.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r2
 * Preserves: r3-r11, lr
 * Test: Read RCC APB1ENR TIM2 bit after call.
 */
.type initialiseTimerClock, %function
.thumb_func
initialiseTimerClock:
    ldr r0, =RCC_BASE
    ldr r1, [r0, #RCC_APB1ENR_OFFSET]
    ldr r2, =RCC_APB1ENR_TIM2EN
    orrs r1, r1, r2
    str r1, [r0, #RCC_APB1ENR_OFFSET]
    bx lr
.size initialiseTimerClock, . - initialiseTimerClock
