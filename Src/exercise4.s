#ifndef EXERCISE4_S
#define EXERCISE4_S

#include "definitions.s"

.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

.global exercise4Entry
.global timInit1MHz
.global delayUsTimer
.global delayUsTimerPreload
.global exercise4Count100usFor1Second
.global exercise4DualBlinkService

.section .bss.exercise4, "aw", %nobits
.align 4
ex4_count_100us_result:
    .word 0
ex4_led_state:
    .word 0
ex4_next_toggle_a:
    .word 0
ex4_next_toggle_b:
    .word 0
ex4_service_initialised:
    .word 0

.section .text.exercise4, "ax", %progbits
.align 2

/* Purpose: Exercise 4 entry; run timing proof then service dual independent blinks.
 * Inputs: none
 * Outputs: none (infinite loop)
 * Clobbers: r0-r3, lr
 * Preserves: r4-r11
 * Test: Verify ex4_count_100us_result == EX4_PERIODS_IN_1S and observe two blink rates.
 */
.type exercise4Entry, %function
.thumb_func
exercise4Entry:
    bl timInit1MHz
    bl exercise4Count100usFor1Second
    bl timInit1MHz

exercise4_main_loop:
    bl exercise4DualBlinkService
    b exercise4_main_loop
.size exercise4Entry, . - exercise4Entry

/* Purpose: Configure TIM2 so one timer tick equals 1 microsecond.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r2, lr
 * Preserves: r3-r11
 * Test: Confirm TIM2 PSC equals TIM2_PRESCALER_1MHZ and CNT increments at 1 MHz.
 */
.type timInit1MHz, %function
.thumb_func
timInit1MHz:
    push {lr}
    bl initialiseTimerClock

    ldr r0, =TIM2_BASE

    ldr r1, [r0, #TIM_CR1_OFFSET]
    bic r1, r1, #TIM_CR1_CEN
    orrs r1, r1, #TIM_CR1_ARPE
    str r1, [r0, #TIM_CR1_OFFSET]

    ldr r1, =TIM2_PRESCALER_1MHZ
    str r1, [r0, #TIM_PSC_OFFSET]

    ldr r1, =0xFFFFFFFF
    str r1, [r0, #TIM_ARR_OFFSET]

    movs r1, #0
    str r1, [r0, #TIM_CNT_OFFSET]
    movs r1, #TIM_EGR_UG
    str r1, [r0, #TIM_EGR_OFFSET]
    movs r1, #0
    str r1, [r0, #TIM_SR_OFFSET]

    ldr r1, [r0, #TIM_CR1_OFFSET]
    orrs r1, r1, #TIM_CR1_CEN
    str r1, [r0, #TIM_CR1_OFFSET]
    pop {pc}
.size timInit1MHz, . - timInit1MHz

/* Purpose: Delay for R1 microseconds using free-running TIM2 counter polling.
 * Inputs: r1 = delay in microseconds
 * Outputs: none
 * Clobbers: r0-r3
 * Preserves: r4-r11, lr
 * Test: Compare elapsed pulse width against oscilloscope measurement.
 */
.type delayUsTimer, %function
.thumb_func
delayUsTimer:
    cmp r1, #0
    beq delayUsTimer_done

    ldr r0, =TIM2_BASE
    ldr r2, [r0, #TIM_CNT_OFFSET]

delayUsTimer_wait:
    ldr r3, [r0, #TIM_CNT_OFFSET]
    subs r3, r3, r2
    cmp r3, r1
    blo delayUsTimer_wait

delayUsTimer_done:
    bx lr
.size delayUsTimer, . - delayUsTimer

/* Purpose: Delay for R1 microseconds using ARR preload (ARPE=1) and UIF polling.
 * Inputs: r1 = delay in microseconds
 * Outputs: none
 * Clobbers: r0-r2
 * Preserves: r3-r11, lr
 * Test: Verify repeated 100 us intervals are stable over 1 second measurement.
 */
.type delayUsTimerPreload, %function
.thumb_func
delayUsTimerPreload:
    cmp r1, #0
    beq delayUsTimerPreload_done

    ldr r0, =TIM2_BASE

    ldr r2, [r0, #TIM_CR1_OFFSET]
    bic r2, r2, #TIM_CR1_CEN
    orrs r2, r2, #TIM_CR1_ARPE
    str r2, [r0, #TIM_CR1_OFFSET]

    ldr r2, =TIM2_PRESCALER_1MHZ
    str r2, [r0, #TIM_PSC_OFFSET]

    subs r2, r1, #1
    str r2, [r0, #TIM_ARR_OFFSET]

    movs r2, #0
    str r2, [r0, #TIM_CNT_OFFSET]

    movs r2, #TIM_EGR_UG
    str r2, [r0, #TIM_EGR_OFFSET]

    movs r2, #0
    str r2, [r0, #TIM_SR_OFFSET]

    ldr r2, [r0, #TIM_CR1_OFFSET]
    orrs r2, r2, #TIM_CR1_CEN
    str r2, [r0, #TIM_CR1_OFFSET]

delayUsTimerPreload_wait:
    ldr r2, [r0, #TIM_SR_OFFSET]
    tst r2, #TIM_SR_UIF
    beq delayUsTimerPreload_wait

    movs r2, #0
    str r2, [r0, #TIM_SR_OFFSET]

    ldr r2, [r0, #TIM_CR1_OFFSET]
    bic r2, r2, #TIM_CR1_CEN
    str r2, [r0, #TIM_CR1_OFFSET]

delayUsTimerPreload_done:
    bx lr
.size delayUsTimerPreload, . - delayUsTimerPreload

/* Purpose: Demonstrate 0.1 ms timing by counting 100 us periods for 1 second.
 * Inputs: none
 * Outputs: ex4_count_100us_result updated
 * Clobbers: r0-r2, r4-r5, lr
 * Preserves: r3, r6-r11
 * Test: ex4_count_100us_result should equal EX4_PERIODS_IN_1S.
 */
.type exercise4Count100usFor1Second, %function
.thumb_func
exercise4Count100usFor1Second:
    push {r4-r5, lr}
    movs r4, #0
    ldr r5, =EX4_PERIODS_IN_1S

exercise4Count100usFor1Second_loop:
    ldr r1, =EX4_PERIOD_100US
    bl delayUsTimerPreload
    adds r4, r4, #1
    cmp r4, r5
    blo exercise4Count100usFor1Second_loop

    ldr r0, =ex4_count_100us_result
    str r4, [r0]
    pop {r4-r5, pc}
.size exercise4Count100usFor1Second, . - exercise4Count100usFor1Second

/* Purpose: Service two independent LED blink schedules using absolute time checks.
 * Inputs: none
 * Outputs: LED pattern updated on PE8..PE15
 * Clobbers: r0-r5, lr
 * Preserves: r6-r11
 * Test: Change EX4_LED_A/B_HALF_PERIOD_US and verify independent rates.
 */
.type exercise4DualBlinkService, %function
.thumb_func
exercise4DualBlinkService:
    push {r4-r5, lr}

    ldr r0, =TIM2_BASE
    ldr r4, [r0, #TIM_CNT_OFFSET]

    ldr r0, =ex4_service_initialised
    ldr r1, [r0]
    cmp r1, #0
    bne exercise4DualBlinkService_ready

    movs r1, #1
    str r1, [r0]

    ldr r0, =ex4_led_state
    movs r1, #0
    str r1, [r0]

    ldr r0, =ex4_next_toggle_a
    ldr r1, =EX4_LED_A_HALF_PERIOD_US
    adds r1, r1, r4
    str r1, [r0]

    ldr r0, =ex4_next_toggle_b
    ldr r1, =EX4_LED_B_HALF_PERIOD_US
    adds r1, r1, r4
    str r1, [r0]
    b exercise4DualBlinkService_apply

exercise4DualBlinkService_ready:
    ldr r0, =ex4_next_toggle_a
    ldr r1, [r0]
    subs r2, r4, r1
    bmi exercise4DualBlinkService_skip_a

    ldr r2, =EX4_LED_A_HALF_PERIOD_US
    adds r1, r1, r2
    str r1, [r0]

    ldr r0, =ex4_led_state
    ldr r1, [r0]
    eors r1, r1, #LED_EX4_A_MASK
    str r1, [r0]

exercise4DualBlinkService_skip_a:
    ldr r0, =ex4_next_toggle_b
    ldr r1, [r0]
    subs r2, r4, r1
    bmi exercise4DualBlinkService_apply

    ldr r2, =EX4_LED_B_HALF_PERIOD_US
    adds r1, r1, r2
    str r1, [r0]

    ldr r0, =ex4_led_state
    ldr r1, [r0]
    eors r1, r1, #LED_EX4_B_MASK
    str r1, [r0]

exercise4DualBlinkService_apply:
    ldr r0, =ex4_led_state
    ldr r0, [r0]
    bl setLedBitmask

    pop {r4-r5, pc}
.size exercise4DualBlinkService, . - exercise4DualBlinkService

#endif /* EXERCISE4_S */
