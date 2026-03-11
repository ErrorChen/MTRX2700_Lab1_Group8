#ifndef EXERCISE2_S
#define EXERCISE2_S

#include "definitions.s"

.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

.global exercise2Entry
.global setLedBitmask
.global readUserButton
.global waitForButtonPressDebounced
.global exercise2StepCounterState
.global exercise2TimedStep

.section .bss.exercise2, "aw", %nobits
.align 4
ex2_counter_value:
    .word 0
ex2_direction_flag:
    .word 0
ex2_mode_flag:
    .word 0

.section .text.exercise2, "ax", %progbits
.align 2

/* Purpose: Exercise 2 state-machine entry for LED counter/button interaction.
 * Inputs: none
 * Outputs: none (infinite loop)
 * Clobbers: r0-r3, lr
 * Preserves: r4-r11
 * Test: Press button in mode 0, or switch EX2_ACTIVE_MODE to timed mode.
 */
.type exercise2Entry, %function
.thumb_func
exercise2Entry:
    ldr r0, =ex2_counter_value
    movs r1, #0
    str r1, [r0]

    ldr r0, =ex2_direction_flag
    movs r1, #0
    str r1, [r0]

    ldr r0, =ex2_mode_flag
    movs r1, #EX2_ACTIVE_MODE
    str r1, [r0]

exercise2_main_loop:
    ldr r1, =ex2_counter_value
    ldr r0, [r1]
    bl setLedBitmask

    ldr r1, =ex2_mode_flag
    ldr r1, [r1]
    cmp r1, #EX2_MODE_BUTTON
    bne exercise2_timed_mode

    bl waitForButtonPressDebounced
    bl exercise2StepCounterState
    b exercise2_main_loop

exercise2_timed_mode:
    bl exercise2TimedStep
    b exercise2_main_loop
.size exercise2Entry, . - exercise2Entry

/* Purpose: Drive board LEDs PE8..PE15 from an 8-bit bitmask.
 * Inputs: r0 = LED bitmask
 * Outputs: none
 * Clobbers: r0, lr
 * Preserves: r1-r11
 * Test: Call with 0x01 and verify only PE8 LED is lit.
 */
.type setLedBitmask, %function
.thumb_func
setLedBitmask:
    ands r0, r0, #LED_ALL_MASK
    b ledWritePattern
.size setLedBitmask, . - setLedBitmask

/* Purpose: Read user button B1 state on PA0.
 * Inputs: none
 * Outputs: r0 = 0 (released) or 1 (pressed)
 * Clobbers: r1
 * Preserves: r2-r11, lr
 * Test: Observe r0 toggling while pressing button.
 */
.type readUserButton, %function
.thumb_func
readUserButton:
    ldr r1, =GPIOA_BASE
    ldr r0, [r1, #GPIO_IDR_OFFSET]
    ands r0, r0, #USER_BUTTON_PIN_MASK
    bx lr
.size readUserButton, . - readUserButton

/* Purpose: Wait for one debounced press event and full release.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r1, lr
 * Preserves: r2-r11
 * Test: Hold button down; function should trigger only once until release.
 */
.type waitForButtonPressDebounced, %function
.thumb_func
waitForButtonPressDebounced:
    push {lr}

waitForButtonPressDebounced_wait_press:
    bl readUserButton
    cmp r0, #0
    beq waitForButtonPressDebounced_wait_press

    ldr r1, =EX2_DEBOUNCE_US
    bl delayUsTimer

    bl readUserButton
    cmp r0, #0
    beq waitForButtonPressDebounced_wait_press

waitForButtonPressDebounced_wait_release:
    bl readUserButton
    cmp r0, #0
    bne waitForButtonPressDebounced_wait_release

    ldr r1, =EX2_DEBOUNCE_US
    bl delayUsTimer

    bl readUserButton
    cmp r0, #0
    bne waitForButtonPressDebounced_wait_release

    pop {pc}
.size waitForButtonPressDebounced, . - waitForButtonPressDebounced

/* Purpose: Advance Exercise 2 counter and handle up/down reversal at limits.
 * Inputs: none
 * Outputs: r0 = updated counter value (0x00..0xFF)
 * Clobbers: r1-r3
 * Preserves: r4-r11, lr
 * Test: Step repeatedly and verify direction toggles at 0x00 and 0xFF.
 */
.type exercise2StepCounterState, %function
.thumb_func
exercise2StepCounterState:
    ldr r1, =ex2_counter_value
    ldr r0, [r1]
    ands r0, r0, #LED_ALL_MASK

    ldr r2, =ex2_direction_flag
    ldr r3, [r2]

    cmp r3, #0
    bne exercise2StepCounterState_count_down

    /* Count up mode. */
    cmp r0, #LED_ALL_MASK
    beq exercise2StepCounterState_switch_down
    adds r0, r0, #1
    cmp r0, #LED_ALL_MASK
    bne exercise2StepCounterState_store

exercise2StepCounterState_switch_down:
    movs r3, #1
    str r3, [r2]
    b exercise2StepCounterState_store

exercise2StepCounterState_count_down:
    /* Count down mode. */
    cmp r0, #0
    beq exercise2StepCounterState_switch_up
    subs r0, r0, #1
    cmp r0, #0
    bne exercise2StepCounterState_store

exercise2StepCounterState_switch_up:
    movs r3, #0
    str r3, [r2]

exercise2StepCounterState_store:
    ands r0, r0, #LED_ALL_MASK
    str r0, [r1]
    bx lr
.size exercise2StepCounterState, . - exercise2StepCounterState

/* Purpose: Perform one timed counter step for demo mode.
 * Inputs: none
 * Outputs: r0 = updated counter value
 * Clobbers: r0-r1, lr
 * Preserves: r2-r11
 * Test: EX2_MODE_TIMED should step automatically at configured period.
 */
.type exercise2TimedStep, %function
.thumb_func
exercise2TimedStep:
    push {lr}
    ldr r1, =EX2_TIMED_STEP_US
    bl delayUsTimer
    bl exercise2StepCounterState
    pop {pc}
.size exercise2TimedStep, . - exercise2TimedStep

#endif /* EXERCISE2_S */
