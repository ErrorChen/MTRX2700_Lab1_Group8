#include "platform_defs.inc"

.global enablePeripheralClocks
.global initialiseDiscoveryBoard
.global initialiseUartGpioPins
.global initialiseTimerClock

.section .text.board_init, "ax", %progbits
.align 2

/* Purpose: Enable clocks required by GPIO, UART, and TIM2 modules.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r2
 * Preserved registers: r3-r11, lr
 * Side effects: Updates RCC AHBENR/APB1ENR bits.
 * Test idea: Inspect RCC registers in debugger after call.
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

/* Purpose: Configure board LEDs PE8..PE15 and USER button PA0 baseline modes.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r2
 * Preserved registers: r3-r11, lr
 * Side effects: Writes GPIOE/GPIOA MODER/PUPDR/ODR registers.
 * Test idea: Verify LEDs can be driven and PA0 reads low-high-low when pressed.
 */
.type initialiseDiscoveryBoard, %function
.thumb_func
initialiseDiscoveryBoard:
    ldr r0, =GPIOE_BASE
    ldr r1, [r0, #GPIO_MODER_OFFSET]
    ldr r2, =GPIOE_LED_MODER_CLEAR_MASK
    ands r1, r1, r2
    ldr r2, =GPIOE_LED_MODER_OUTPUT
    orrs r1, r1, r2
    str r1, [r0, #GPIO_MODER_OFFSET]

    movs r1, #0
    strb r1, [r0, #LED_ODR_HIGH_BYTE_OFFSET]

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

/* Purpose: Configure alternate-function pin mapping for UART4 and UART5.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r2
 * Preserved registers: r3-r11, lr
 * Side effects: Writes GPIOC/GPIOD MODER and AFR registers.
 * Test idea: Check AF5 mapping on PC10/11/12 and PD2 in debugger.
 */
.type initialiseUartGpioPins, %function
.thumb_func
initialiseUartGpioPins:
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
 * Preserved registers: r3-r11, lr
 * Side effects: Sets RCC APB1ENR TIM2EN bit.
 * Test idea: Read APB1ENR bit 0 after call.
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
