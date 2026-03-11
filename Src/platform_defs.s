#ifndef PLATFORM_DEFS_S
#define PLATFORM_DEFS_S

/* Module: platform_defs.s
 * Purpose: Centralised register addresses, bit masks, and project constants.
 * Notes:
 * - Keep STM32F3DISCOVERY board mapping and shared constants here.
 * - Avoid scattering literal values across functional modules.
 */

/* ------------------------- RCC ------------------------- */
.equ RCC_BASE,                          0x40021000
.equ RCC_AHBENR_OFFSET,                 0x14
.equ RCC_APB2ENR_OFFSET,                0x18
.equ RCC_APB1ENR_OFFSET,                0x1C

.equ RCC_AHBENR_IOPAEN,                 (1 << 17)
.equ RCC_AHBENR_IOPEEN,                 (1 << 21)
.equ RCC_APB2ENR_USART1EN,              (1 << 14)
.equ RCC_APB1ENR_TIM2EN,                (1 << 0)

/* ------------------------ GPIO ------------------------- */
.equ GPIOA_BASE,                        0x48000000
.equ GPIOE_BASE,                        0x48001000

.equ GPIO_MODER_OFFSET,                 0x00
.equ GPIO_PUPDR_OFFSET,                 0x0C
.equ GPIO_IDR_OFFSET,                   0x10
.equ GPIO_ODR_OFFSET,                   0x14

.equ GPIO_PIN_0_MASK,                   0x00000001
.equ GPIO_PIN_0_SHIFT,                  0

.equ LED_ODR_HIGH_BYTE_OFFSET,          (GPIO_ODR_OFFSET + 1)
.equ GPIOE_MODER_MASK_LOW16,            0x0000FFFF
.equ GPIOE_MODER_OUTPUT_8_15,           0x55550000

.equ GPIOA_MODER_CLEAR_PA0,             0xFFFFFFFC
.equ GPIOA_PUPDR_CLEAR_PA0,             0xFFFFFFFC
.equ GPIOA_PUPDR_PULLDOWN_PA0,          0x00000002

/* ------------------------ UART ------------------------- */
.equ USART1_BASE,                       0x40013800
.equ USART_CR1_OFFSET,                  0x00
.equ USART_BRR_OFFSET,                  0x0C
.equ USART_ISR_OFFSET,                  0x1C
.equ USART_RDR_OFFSET,                  0x24
.equ USART_TDR_OFFSET,                  0x28

/* ------------------------ Timer ------------------------ */
.equ TIM2_BASE,                         0x40000000
.equ TIM_CR1_OFFSET,                    0x00
.equ TIM_CNT_OFFSET,                    0x24
.equ TIM_PSC_OFFSET,                    0x28
.equ TIM_ARR_OFFSET,                    0x2C

/* ------------------ Demo/dispatch modes ---------------- */
.equ DEMO_MODE_DEFAULT,                 0
.equ DEMO_MODE_EXERCISE_1,              1
.equ DEMO_MODE_EXERCISE_2,              2
.equ DEMO_MODE_EXERCISE_3,              3
.equ DEMO_MODE_EXERCISE_4,              4
.equ DEMO_MODE_EXERCISE_5,              5

/* ---------------- Project-wide constants --------------- */
.equ PATTERN_INIT,                      0x55
.equ DELAY_LOOP_COUNT,                  600000

.equ STATUS_OK,                         0
.equ STATUS_UNSUPPORTED,                0xFFFFFFFF

#endif /* PLATFORM_DEFS_S */
