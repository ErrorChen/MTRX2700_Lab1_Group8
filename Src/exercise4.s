#include "platform_defs.inc"

.global exercise4Entry
.global exercise4Count100usFor1Second
.global exercise4DualBlinkService

.extern timInit1MHz
.extern delayUsTimerPreload
.extern setLedBitmask

.section .bss.exercise4, "aw", %nobits
.align 4
exercise4Count100usResult:
    .word 0
exercise4LedState:
    .word 0
exercise4NextToggleA:
    .word 0
exercise4NextToggleB:
    .word 0
exercise4ServiceInitialised:
    .word 0

.section .text.exercise4, "ax", %progbits
.align 2

/* Purpose: Exercise 4 orchestration for timer validation and dual-rate LED blinking.
 * Inputs: none
 * Outputs: none (infinite loop)
 * Clobbers: r0-r3, lr
 * Preserved registers: r4-r11
 * Side effects: Uses TIM2 and continuously updates LED state.
 * Test idea: Confirm exercise4Count100usResult equals EX4_PERIODS_IN_1S.
 */
.type exercise4Entry, %function
.thumb_func
exercise4Entry:
    bl timInit1MHz
    bl exercise4Count100usFor1Second
    bl timInit1MHz

exercise4MainLoop:
    bl exercise4DualBlinkService
    b exercise4MainLoop
.size exercise4Entry, . - exercise4Entry

/* Purpose: Count 100 us timer periods for one second reference interval.
 * Inputs: none
 * Outputs: exercise4Count100usResult updated
 * Clobbers: r0-r2, r4-r5, lr
 * Preserved registers: r3, r6-r11
 * Side effects: Performs repeated timer-preload delays.
 * Test idea: Debug symbol should read exactly 10000 after completion.
 */
.type exercise4Count100usFor1Second, %function
.thumb_func
exercise4Count100usFor1Second:
    push {r4-r5, lr}
    movs r4, #0
    ldr r5, =EX4_PERIODS_IN_1S

exercise4CountLoop:
    ldr r1, =EX4_PERIOD_100US
    bl delayUsTimerPreload
    adds r4, r4, #1
    cmp r4, r5
    blo exercise4CountLoop

    ldr r0, =exercise4Count100usResult
    str r4, [r0]
    pop {r4-r5, pc}
.size exercise4Count100usFor1Second, . - exercise4Count100usFor1Second

/* Purpose: Service two independent LED toggle schedules using TIM2 absolute time.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r5, lr
 * Preserved registers: r6-r11
 * Side effects: Updates LED state machine and writes LED output pattern.
 * Test idea: Change half-period constants and verify independent blink rates.
 */
.type exercise4DualBlinkService, %function
.thumb_func
exercise4DualBlinkService:
    push {r4-r5, lr}

    ldr r0, =TIM2_BASE
    ldr r4, [r0, #TIM_CNT_OFFSET]

    ldr r0, =exercise4ServiceInitialised
    ldr r1, [r0]
    cmp r1, #0
    bne exercise4DualBlinkServiceReady

    movs r1, #1
    str r1, [r0]

    ldr r0, =exercise4LedState
    movs r1, #0
    str r1, [r0]

    ldr r0, =exercise4NextToggleA
    ldr r1, =EX4_LED_A_HALF_PERIOD_US
    adds r1, r1, r4
    str r1, [r0]

    ldr r0, =exercise4NextToggleB
    ldr r1, =EX4_LED_B_HALF_PERIOD_US
    adds r1, r1, r4
    str r1, [r0]
    b exercise4DualBlinkServiceApply

exercise4DualBlinkServiceReady:
    ldr r0, =exercise4NextToggleA
    ldr r1, [r0]
    subs r2, r4, r1
    bmi exercise4DualBlinkServiceSkipA

    ldr r2, =EX4_LED_A_HALF_PERIOD_US
    adds r1, r1, r2
    str r1, [r0]

    ldr r0, =exercise4LedState
    ldr r1, [r0]
    eors r1, r1, #LED_EX4_A_MASK
    str r1, [r0]

exercise4DualBlinkServiceSkipA:
    ldr r0, =exercise4NextToggleB
    ldr r1, [r0]
    subs r2, r4, r1
    bmi exercise4DualBlinkServiceApply

    ldr r2, =EX4_LED_B_HALF_PERIOD_US
    adds r1, r1, r2
    str r1, [r0]

    ldr r0, =exercise4LedState
    ldr r1, [r0]
    eors r1, r1, #LED_EX4_B_MASK
    str r1, [r0]

exercise4DualBlinkServiceApply:
    ldr r0, =exercise4LedState
    ldr r0, [r0]
    bl setLedBitmask

    pop {r4-r5, pc}
.size exercise4DualBlinkService, . - exercise4DualBlinkService
