/* STM32F3DISCOVERY / STM32F303VCT6 hardware definitions */
/* LEDs on GPIOE:
 * LD4  -> PE8
 * LD3  -> PE9
 * LD5  -> PE10
 * LD7  -> PE11
 * LD9  -> PE12
 * LD10 -> PE13
 * LD8  -> PE14
 * LD6  -> PE15
 * User button B1 -> PA0
 */

.equ RCC_BASE,                    0x40021000
.equ RCC_AHBENR_OFFSET,           0x14
.equ RCC_AHBENR_IOPAEN,           (1 << 17)
.equ RCC_AHBENR_IOPEEN,           (1 << 21)

.equ GPIOA_BASE,                  0x48000000
.equ GPIOE_BASE,                  0x48001000

.equ GPIO_MODER_OFFSET,           0x00
.equ GPIO_PUPDR_OFFSET,           0x0C
.equ GPIO_IDR_OFFSET,             0x10
.equ GPIO_ODR_OFFSET,             0x14

.equ PATTERN_INIT,                0x55
.equ DELAY_LOOP_COUNT,            600000

.equ LED_ODR_HIGH_BYTE_OFFSET,    GPIO_ODR_OFFSET + 1
.equ GPIOE_MODER_MASK_LOW16,      0x0000FFFF
.equ GPIOE_MODER_OUTPUT_8_15,     0x55550000

.equ GPIOA_MODER_CLEAR_PA0,       0xFFFFFFFC
.equ GPIOA_PUPDR_CLEAR_PA0,       0xFFFFFFFC
.equ GPIOA_PUPDR_PULLDOWN_PA0,    0x00000002
