#include "platform_defs.inc"

.global timInit1MHz
.global delayUsTimer
.global delayUsTimerPreload

.extern initialiseTimerClock

.section .text.timer_io, "ax", %progbits
.align 2

/* Purpose: Configure TIM2 to run at 1 MHz (1 tick = 1 us).
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r2, lr
 * Preserved registers: r3-r11
 * Side effects: Reconfigures TIM2 control, prescaler, ARR, CNT, SR.
 * Test idea: Inspect TIM2 PSC register equals TIM2_PRESCALER_1MHZ.
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

/* Purpose: Delay for r1 microseconds using free-running TIM2 counter polling.
 * Inputs: r1 = delay in microseconds
 * Outputs: none
 * Clobbers: r0-r3
 * Preserved registers: r4-r11, lr
 * Side effects: Busy-waits until elapsed counter delta reaches target.
 * Test idea: Toggle LED around call and verify period with oscilloscope.
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

/* Purpose: Delay for r1 microseconds using ARR preload and UIF polling.
 * Inputs: r1 = delay in microseconds
 * Outputs: none
 * Clobbers: r0-r2
 * Preserved registers: r3-r11, lr
 * Side effects: Temporarily reconfigures TIM2 ARR/CNT/SR/CEN state.
 * Test idea: Repeat 100 us delay loop and confirm stable 1 second total.
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
