#ifndef DEFINITIONS_S
#define DEFINITIONS_S

.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

/* ============================== RCC ============================== */
.equ RCC_BASE,                           0x40021000
.equ RCC_AHBENR_OFFSET,                  0x14
.equ RCC_APB2ENR_OFFSET,                 0x18
.equ RCC_APB1ENR_OFFSET,                 0x1C

.equ RCC_AHBENR_IOPAEN,                  (1 << 17)
.equ RCC_AHBENR_IOPCEN,                  (1 << 19)
.equ RCC_AHBENR_IOPDEN,                  (1 << 20)
.equ RCC_AHBENR_IOPEEN,                  (1 << 21)

.equ RCC_APB1ENR_TIM2EN,                 (1 << 0)
.equ RCC_APB1ENR_UART4EN,                (1 << 19)
.equ RCC_APB1ENR_UART5EN,                (1 << 20)

/* ============================== GPIO ============================= */
.equ GPIOA_BASE,                         0x48000000
.equ GPIOC_BASE,                         0x48000800
.equ GPIOD_BASE,                         0x48000C00
.equ GPIOE_BASE,                         0x48001000

.equ GPIO_MODER_OFFSET,                  0x00
.equ GPIO_OTYPER_OFFSET,                 0x04
.equ GPIO_OSPEEDR_OFFSET,                0x08
.equ GPIO_PUPDR_OFFSET,                  0x0C
.equ GPIO_IDR_OFFSET,                    0x10
.equ GPIO_ODR_OFFSET,                    0x14
.equ GPIO_BSRR_OFFSET,                   0x18
.equ GPIO_AFRL_OFFSET,                   0x20
.equ GPIO_AFRH_OFFSET,                   0x24

.equ GPIO_MODE_INPUT,                    0x0
.equ GPIO_MODE_OUTPUT,                   0x1
.equ GPIO_MODE_AF,                       0x2
.equ GPIO_MODE_ANALOG,                   0x3

/* LEDs: PE8..PE15 */
.equ LED_ODR_HIGH_BYTE_OFFSET,           (GPIO_ODR_OFFSET + 1)
.equ LED_ALL_MASK,                       0xFF
.equ LED_ERROR_PATTERN_A,                0xAA
.equ LED_ERROR_PATTERN_B,                0x55
.equ LED_EX4_A_MASK,                     0x01
.equ LED_EX4_B_MASK,                     0x80

.equ GPIOE_LED_MODER_CLEAR_MASK,         0x0000FFFF
.equ GPIOE_LED_MODER_OUTPUT,             0x55550000

/* User button: PA0 */
.equ USER_BUTTON_PIN_MASK,               0x00000001
.equ GPIOA_PA0_MODER_CLEAR_MASK,         0xFFFFFFFC
.equ GPIOA_PA0_PUPDR_CLEAR_MASK,         0xFFFFFFFC
.equ GPIOA_PA0_PUPDR_PULLDOWN,           0x00000002

/* UART pin mux
 * UART4: PC10(TX), PC11(RX)
 * UART5: PC12(TX), PD2(RX)
 * AF selection: AF5
 */
.equ GPIOC_UART_PINS_MODER_CLEAR_MASK,   0xFC0FFFFF
.equ GPIOC_UART_PINS_MODER_AF,           0x02A00000
.equ GPIOD_UART5_RX_MODER_CLEAR_MASK,    0xFFFFFFCF
.equ GPIOD_UART5_RX_MODER_AF,            0x00000020

.equ GPIOC_UART_AFRH_CLEAR_MASK,         0xFFF000FF
.equ GPIOC_UART_AFRH_AF5,                0x00055500
.equ GPIOD_UART_AFRL_CLEAR_MASK,         0xFFFFF0FF
.equ GPIOD_UART_AFRL_AF5,                0x00000500

/* ============================= Message =========================== */
.equ STX,                                0x02
.equ ETX,                                0x03
.equ ASCII_NUL,                          0x00
.equ ASCII_ZERO,                         0x30
.equ ASCII_NINE,                         0x39
.equ ASCII_UPPER_A,                      0x41
.equ ASCII_UPPER_Z,                      0x5A
.equ ASCII_LOWER_A,                      0x61
.equ ASCII_LOWER_Z,                      0x7A
.equ ASCII_CASE_DELTA,                   0x20

.equ FRAME_MIN_LENGTH,                   4
.equ FRAME_HEADER_LENGTH,                2
.equ FRAME_TRAILER_LENGTH,               2
.equ MAX_PAYLOAD_BYTES,                  64
.equ MAX_FRAME_BYTES,                    80

/* ============================== UART ============================= */
.equ UART4_BASE,                         0x40004C00
.equ UART5_BASE,                         0x40005000

.equ USART_CR1_OFFSET,                   0x00
.equ USART_BRR_OFFSET,                   0x0C
.equ USART_ISR_OFFSET,                   0x1C
.equ USART_RDR_OFFSET,                   0x24
.equ USART_TDR_OFFSET,                   0x28

.equ USART_CR1_UE,                       (1 << 0)
.equ USART_CR1_RE,                       (1 << 2)
.equ USART_CR1_TE,                       (1 << 3)

.equ USART_ISR_RXNE,                     (1 << 5)
.equ USART_ISR_TC,                       (1 << 6)
.equ USART_ISR_TXE,                      (1 << 7)

/* ============================== Timer ============================ */
.equ TIM2_BASE,                          0x40000000
.equ TIM_CR1_OFFSET,                     0x00
.equ TIM_SR_OFFSET,                      0x10
.equ TIM_EGR_OFFSET,                     0x14
.equ TIM_CNT_OFFSET,                     0x24
.equ TIM_PSC_OFFSET,                     0x28
.equ TIM_ARR_OFFSET,                     0x2C

.equ TIM_CR1_CEN,                        (1 << 0)
.equ TIM_CR1_ARPE,                       (1 << 7)
.equ TIM_SR_UIF,                         (1 << 0)
.equ TIM_EGR_UG,                         (1 << 0)

/* ========================== Clock Config ========================= */
.equ SYSTEM_CLOCK_HZ,                    8000000
.equ APB1_CLOCK_HZ,                      8000000
.equ UART_DEFAULT_BAUD,                  115200

.equ TIM2_INPUT_CLOCK_HZ,                8000000
.equ TIM2_TICK_HZ,                       1000000
.equ TIM2_PRESCALER_1MHZ,                ((TIM2_INPUT_CLOCK_HZ / TIM2_TICK_HZ) - 1)

/* ====================== Compile-Time Selectors =================== */
.equ EX2_MODE_BUTTON,                    0
.equ EX2_MODE_TIMED,                     1
.equ EX2_ACTIVE_MODE,                    EX2_MODE_BUTTON

.equ EX5_ROLE_TX,                        0
.equ EX5_ROLE_RX,                        1
.equ EX5_ACTIVE_ROLE,                    EX5_ROLE_TX

/* ======================== Exercise Constants ===================== */
.equ EX2_DEBOUNCE_US,                    50000
.equ EX2_TIMED_STEP_US,                  100000

.equ EX4_PERIOD_100US,                   100
.equ EX4_PERIODS_IN_1S,                  10000
.equ EX4_LED_A_HALF_PERIOD_US,           200000
.equ EX4_LED_B_HALF_PERIOD_US,           350000

.equ EX5_MESSAGE_PERIOD_US,              1000000
.equ EX5_ACK_TIMEOUT_US,                 5000000
.equ EX5_FLASH_INTERVAL_US,              500000

/* ============================ Status ============================= */
.equ UART_STATUS_OK,                     0
.equ UART_STATUS_LENGTH_ERROR,           1
.equ UART_STATUS_ETX_ERROR,              2
.equ UART_STATUS_BCC_ERROR,              3
.equ UART_STATUS_PAYLOAD_ERROR,          4
.equ UART_STATUS_TIMEOUT,                5

.equ ACK_WAIT_TIMEOUT,                   0
.equ ACK_WAIT_ACK,                       1
.equ ACK_WAIT_NAK,                       2

#endif /* DEFINITIONS_S */
