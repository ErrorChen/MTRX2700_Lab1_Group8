.syntax unified
.thumb

#include "definitions.s"

@ ============================================================
@ enable_peripheral_clocks
@ Enable GPIO clocks for ports we may use
@ ============================================================
enable_peripheral_clocks:
    LDR R0, =RCC
    LDR R1, [R0, #AHBENR]
    ORR R1, R1, #(1 << GPIOE_ENABLE)
    ORR R1, R1, #(1 << GPIOD_ENABLE)
    ORR R1, R1, #(1 << GPIOC_ENABLE)
    ORR R1, R1, #(1 << GPIOB_ENABLE)
    ORR R1, R1, #(1 << GPIOA_ENABLE)
    STR R1, [R0, #AHBENR]
    BX LR


@ ============================================================
@ enable_uart
@ Configure PC4/PC5 for USART1 and enable USART1
@ ============================================================
enable_uart:
    @ Configure GPIO pins for alternate function
    LDR R0, =UART_GPIO

    @ Set alternate function AF7 on PC4/PC5
    LDR R1, [R0, #AFRREG]
    BIC R1, R1, #AFR_CLEAR_MASK
    ORR R1, R1, #AFR_SET_MASK
    STR R1, [R0, #AFRREG]

    @ Set PC4/PC5 to alternate function mode
    LDR R1, [R0, #GPIO_MODER]
    BIC R1, R1, #MODER_CLEAR_MASK
    ORR R1, R1, #MODER_ALT_MASK
    STR R1, [R0, #GPIO_MODER]

    @ Set PC4/PC5 high speed
    LDR R1, [R0, #GPIO_OSPEEDR]
    ORR R1, R1, #OSPEED_SET_MASK
    STR R1, [R0, #GPIO_OSPEEDR]

    @ Enable USART1 clock
    LDR R0, =RCC
    LDR R1, [R0, #APBENR]
    ORR R1, R1, #(1 << UART_EN)
    STR R1, [R0, #APBENR]

    @ Set baud rate
    LDR R0, =UART
    MOV R1, #BAUD_RATE
    STRH R1, [R0, #USART_BRR]

    @ Enable transmitter, receiver and USART
    LDR R1, [R0, #USART_CR1]
    ORR R1, R1, #(1 << UART_TE)
    ORR R1, R1, #(1 << UART_RE)
    ORR R1, R1, #(1 << UART_UE)
    STR R1, [R0, #USART_CR1]

    BX LR


@ ============================================================
@ change_clock_speed
@ Optional PLL clock setup
@ ============================================================
change_clock_speed:
    @ step 1: enable HSE
    LDR R0, =RCC
    LDR R1, [R0, #RCC_CR]
    LDR R2, =(1 << HSEBYP) | (1 << HSEON)
    ORR R1, R1, R2
    STR R1, [R0, #RCC_CR]

wait_for_HSERDY:
    LDR R1, [R0, #RCC_CR]
    TST R1, #(1 << HSERDY)
    BEQ wait_for_HSERDY

    @ step 2: configure PLL
    LDR R1, [R0, #RCC_CFGR]
    LDR R2, =(1 << 20) | (1 << PLLSRC) | (1 << 22)
    ORR R1, R1, R2
    STR R1, [R0, #RCC_CFGR]

    @ enable PLL
    LDR R1, [R0, #RCC_CR]
    ORR R1, R1, #(1 << PLLON)
    STR R1, [R0, #RCC_CR]

wait_for_PLLRDY:
    LDR R1, [R0, #RCC_CR]
    TST R1, #(1 << PLLRDY)
    BEQ wait_for_PLLRDY

    @ switch system clock to PLL
    LDR R1, [R0, #RCC_CFGR]
    MOV R2, #(1 << 10) | (1 << 1)
    ORR R1, R1, R2
    STR R1, [R0, #RCC_CFGR]

    LDR R1, [R0, #RCC_CFGR]
    ORR R1, R1, #(1 << USBPRE)
    STR R1, [R0, #RCC_CFGR]

    BX LR


@ ============================================================
@ initialise_power
@ ============================================================
initialise_power:
    LDR R0, =RCC

    @ Enable power interface clock
    LDR R1, [R0, #APB1ENR]
    ORR R1, R1, #(1 << PWREN)
    STR R1, [R0, #APB1ENR]

    @ Enable system configuration clock
    LDR R1, [R0, #APB2ENR]
    ORR R1, R1, #(1 << SYSCFGEN)
    STR R1, [R0, #APB2ENR]

    BX LR
