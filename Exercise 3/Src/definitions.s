@ ============================================================
@ RCC / clock registers
@ ============================================================
.equ RCC,               0x40021000
.equ RCC_CR,            0x00
.equ RCC_CFGR,          0x04
.equ AHBENR,            0x14
.equ APB2ENR,           0x18
.equ APB1ENR,           0x1C

@ ============================================================
@ GPIO base addresses
@ ============================================================
.equ GPIOA,             0x48000000
.equ GPIOB,             0x48000400
.equ GPIOC,             0x48000800
.equ GPIOD,             0x48000C00
.equ GPIOE,             0x48001000

@ GPIO clock enable bits
.equ GPIOA_ENABLE,      17
.equ GPIOB_ENABLE,      18
.equ GPIOC_ENABLE,      19
.equ GPIOD_ENABLE,      20
.equ GPIOE_ENABLE,      21

@ GPIO register offsets
.equ GPIO_MODER,        0x00
.equ GPIO_IDR,          0x10
.equ AFRL,              0x20
.equ AFRH,              0x24
.equ GPIO_OSPEEDR,      0x08

@ ============================================================
@ USART1 on PC4 / PC5 for ST-LINK virtual COM port
@ ============================================================
.equ UART,              0x40013800      @ USART1
.equ UART_EN,           14
.equ APBENR,            APB2ENR

.equ UART_GPIO,         GPIOC
.equ UART_GPIO_EN,      GPIOC_ENABLE

@ PC4 and PC5 -> alternate function mode
.equ MODER_CLEAR_MASK,  (0xF << 8)
.equ MODER_ALT_MASK,    (0xA << 8)

@ PC4/PC5 use AFRL bits [23:16], AF7 = 0111
.equ AFRREG,            AFRL
.equ AFR_CLEAR_MASK,    (0xFF << 16)
.equ AFR_SET_MASK,      (0x77 << 16)

@ High speed for PC4/PC5
.equ OSPEED_SET_MASK,   (0xF << 8)

@ 8 MHz clock -> 9600 baud
.equ BAUD_RATE,         5000

@ ============================================================
@ USART register offsets
@ ============================================================
.equ USART_CR1,         0x00
.equ USART_BRR,         0x0C
.equ USART_ISR,         0x1C
.equ USART_ICR,         0x20
.equ USART_RDR,         0x24
.equ USART_TDR,         0x28
.equ USART_RQR,         0x18

@ USART bit positions
.equ UART_UE,           0
.equ UART_RE,           2
.equ UART_TE,           3

.equ UART_FE,           1
.equ UART_ORE,          3
.equ UART_RXNE,         5
.equ UART_TXE,          7

.equ UART_FECF,         1
.equ UART_ORECF,        3
.equ UART_RXFRQ,        3

@ ============================================================
@ Clock setup bits
@ ============================================================
.equ HSEON,             16
.equ HSERDY,            17
.equ HSEBYP,            18
.equ PLLON,             24
.equ PLLRDY,            25
.equ PLLSRC,            16
.equ USBPRE,            22

.equ PWREN,             28
.equ SYSCFGEN,          0
