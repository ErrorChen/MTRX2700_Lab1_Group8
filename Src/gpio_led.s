#include "platform_defs.inc"

.global ledWritePattern
.global setLedBitmask
.global displayCounterOnLeds
.global ledErrorLoop
.global flashAllLedsThreeTimes

.extern softwareDelayCycles
.extern delayUsTimer

.section .text.gpio_led, "ax", %progbits
.align 2

/* Purpose: Write an 8-bit LED pattern to PE8..PE15.
 * Inputs: r0 = LED bitmask
 * Outputs: none
 * Clobbers: r1
 * Preserved registers: r2-r11, lr
 * Side effects: Updates GPIOE ODR high byte.
 * Test idea: Write 0x55 and confirm alternating LEDs.
 */
.type ledWritePattern, %function
.thumb_func
ledWritePattern:
    ldr r1, =GPIOE_BASE
    strb r0, [r1, #LED_ODR_HIGH_BYTE_OFFSET]
    bx lr
.size ledWritePattern, . - ledWritePattern

/* Purpose: Apply LED bitmask after constraining to valid 8 LED bits.
 * Inputs: r0 = requested LED bitmask
 * Outputs: none
 * Clobbers: r0, lr
 * Preserved registers: r1-r11
 * Side effects: Writes GPIOE output pattern.
 * Test idea: Input 0x1FF should light same pattern as 0xFF.
 */
.type setLedBitmask, %function
.thumb_func
setLedBitmask:
    ands r0, r0, #LED_ALL_MASK
    b ledWritePattern
.size setLedBitmask, . - setLedBitmask

/* Purpose: Display low 8 bits of a counter value on board LEDs.
 * Inputs: r0 = counter value
 * Outputs: none
 * Clobbers: r0, lr
 * Preserved registers: r1-r11
 * Side effects: Writes LED output state.
 * Test idea: Input 0x5A should show binary 01011010 on LEDs.
 */
.type displayCounterOnLeds, %function
.thumb_func
displayCounterOnLeds:
    ands r0, r0, #LED_ALL_MASK
    b ledWritePattern
.size displayCounterOnLeds, . - displayCounterOnLeds

/* Purpose: Visible fallback loop when active exercise selection is invalid.
 * Inputs: none
 * Outputs: none (infinite loop)
 * Clobbers: r0, lr
 * Preserved registers: r1-r11
 * Side effects: Continuously toggles LED error patterns.
 * Test idea: Set ACTIVE_EXERCISE to an invalid value and observe blinking.
 */
.type ledErrorLoop, %function
.thumb_func
ledErrorLoop:
ledErrorLoop_loop:
    movs r0, #LED_ERROR_PATTERN_A
    bl ledWritePattern
    ldr r0, =ERROR_BLINK_DELAY_CYCLES
    bl softwareDelayCycles

    movs r0, #LED_ERROR_PATTERN_B
    bl ledWritePattern
    ldr r0, =ERROR_BLINK_DELAY_CYCLES
    bl softwareDelayCycles
    b ledErrorLoop_loop
.size ledErrorLoop, . - ledErrorLoop

/* Purpose: Flash all LEDs three times for error/attention signalling.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r1, r4, lr
 * Preserved registers: r2-r3, r5-r11
 * Side effects: Drives LEDs and blocks for 3 on/off intervals.
 * Test idea: Call once and verify exactly three full flashes.
 */
.type flashAllLedsThreeTimes, %function
.thumb_func
flashAllLedsThreeTimes:
    push {r4, lr}
    movs r4, #3

flashAllLedsThreeTimes_loop:
    movs r0, #LED_ALL_MASK
    bl setLedBitmask
    ldr r1, =EX5_FLASH_INTERVAL_US
    bl delayUsTimer

    movs r0, #0
    bl setLedBitmask
    ldr r1, =EX5_FLASH_INTERVAL_US
    bl delayUsTimer

    subs r4, r4, #1
    bne flashAllLedsThreeTimes_loop
    pop {r4, pc}
.size flashAllLedsThreeTimes, . - flashAllLedsThreeTimes
