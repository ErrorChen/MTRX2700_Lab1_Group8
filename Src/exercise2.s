#include "platform_defs.inc"

.global exercise2Entry

.extern setLedBitmask
.extern waitForButtonPressDebounced
.extern delayUsTimer

.section .bss.exercise2, "aw", %nobits
.align 4
exercise2CounterValue:
    .word 0
exercise2DirectionState:
    .word 0

.section .text.exercise2, "ax", %progbits
.align 2

/* Purpose: Exercise 2 orchestration for LED counter with button/timed stepping.
 * Inputs: none
 * Outputs: none (infinite loop)
 * Clobbers: r0-r3, lr
 * Preserved registers: r4-r11
 * Side effects: Updates counter state and continuously writes LED pattern.
 * Test idea: In button mode, each debounced press advances one counter step.
 */
.type exercise2Entry, %function
.thumb_func
exercise2Entry:
    ldr r0, =exercise2CounterValue
    movs r1, #0
    str r1, [r0]

    ldr r0, =exercise2DirectionState
    movs r1, #0
    str r1, [r0]

exercise2MainLoop:
    ldr r1, =exercise2CounterValue
    ldr r0, [r1]
    bl setLedBitmask

    .if EX2_ACTIVE_MODE == EX2_MODE_BUTTON
        bl waitForButtonPressDebounced
    .else
        ldr r1, =EX2_TIMED_STEP_US
        bl delayUsTimer
    .endif

    bl exercise2AdvanceCounter
    b exercise2MainLoop
.size exercise2Entry, . - exercise2Entry

.type exercise2AdvanceCounter, %function
.thumb_func
exercise2AdvanceCounter:
    ldr r1, =exercise2CounterValue
    ldr r0, [r1]
    ands r0, r0, #LED_ALL_MASK

    ldr r2, =exercise2DirectionState
    ldr r3, [r2]

    cmp r3, #0
    bne exercise2CountDown

    cmp r0, #LED_ALL_MASK
    beq exercise2SwitchToDown
    adds r0, r0, #1
    cmp r0, #LED_ALL_MASK
    bne exercise2StoreCounter

exercise2SwitchToDown:
    movs r3, #1
    str r3, [r2]
    b exercise2StoreCounter

exercise2CountDown:
    cmp r0, #0
    beq exercise2SwitchToUp
    subs r0, r0, #1
    cmp r0, #0
    bne exercise2StoreCounter

exercise2SwitchToUp:
    movs r3, #0
    str r3, [r2]

exercise2StoreCounter:
    ands r0, r0, #LED_ALL_MASK
    str r0, [r1]
    bx lr
.size exercise2AdvanceCounter, . - exercise2AdvanceCounter
