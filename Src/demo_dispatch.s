#ifndef DEMO_DISPATCH_S
#define DEMO_DISPATCH_S

#include "platform_defs.s"

.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

.global initialiseDemoState
.global dispatchDemoMode
.global runDefaultDemoLoop
.global runExercisePlaceholder

.section .bss.demo_state, "aw", %nobits
.align 4
g_demo_mode:
    .word 0
g_led_pattern:
    .word 0

.section .text.demo_dispatch, "ax", %progbits
.align 2

/* Purpose: Prepare default runtime state for dispatch-based demos.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r1
 * Preserves: r2-r11, lr
 */
.type initialiseDemoState, %function
.thumb_func
initialiseDemoState:
    ldr r0, =g_demo_mode
    movs r1, #DEMO_MODE_DEFAULT
    str r1, [r0]

    ldr r0, =g_led_pattern
    movs r1, #PATTERN_INIT
    str r1, [r0]
    bx lr
.size initialiseDemoState, . - initialiseDemoState

/* Purpose: Route control to the active demo/exercise mode.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0, lr
 * Preserves: r1-r11
 * Notes/TODO:
 * - Additional exercise paths are intentionally stubbed for this stage.
 */
.type dispatchDemoMode, %function
.thumb_func
dispatchDemoMode:
    ldr r0, =g_demo_mode
    ldr r0, [r0]
    cmp r0, #DEMO_MODE_DEFAULT
    beq runDefaultDemoLoop

    bl runExercisePlaceholder
    bx lr
.size dispatchDemoMode, . - dispatchDemoMode

/* Purpose: Baseline default demo loop for architecture bring-up.
 * Inputs: none
 * Outputs: none (infinite loop)
 * Clobbers: r0-r1
 * Preserves: not applicable
 */
.type runDefaultDemoLoop, %function
.thumb_func
runDefaultDemoLoop:
runDefaultDemoLoop_loop:
    ldr r1, =g_led_pattern
    ldr r0, [r1]
    bl gpioWriteLedPattern
    eors r0, r0, #0xFF
    ands r0, r0, #0xFF
    ldr r1, =g_led_pattern
    str r0, [r1]
    ldr r0, =DELAY_LOOP_COUNT
    bl timerDelayCycles
    b runDefaultDemoLoop_loop
.size runDefaultDemoLoop, . - runDefaultDemoLoop

/* Purpose: Placeholder entry for unimplemented exercise modes.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0, lr
 * Preserves: r1-r11
 */
.type runExercisePlaceholder, %function
.thumb_func
runExercisePlaceholder:
    bl gpioSetAllLedsOff
    bx lr
.size runExercisePlaceholder, . - runExercisePlaceholder

#endif /* DEMO_DISPATCH_S */
