#include "platform_defs.inc"

.global readUserButton
.global waitForButtonPressDebounced

.extern delayUsTimer

.section .text.button_io, "ax", %progbits
.align 2

/* Purpose: Read USER button state from PA0.
 * Inputs: none
 * Outputs: r0 = 0 (released) or non-zero (pressed)
 * Clobbers: r1
 * Preserved registers: r2-r11, lr
 * Side effects: none
 * Test idea: Watch r0 while pressing/releasing the blue button.
 */
.type readUserButton, %function
.thumb_func
readUserButton:
    ldr r1, =GPIOA_BASE
    ldr r0, [r1, #GPIO_IDR_OFFSET]
    ands r0, r0, #USER_BUTTON_PIN_MASK
    bx lr
.size readUserButton, . - readUserButton

/* Purpose: Block until one debounced press-and-release button event occurs.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r1, lr
 * Preserved registers: r2-r11
 * Side effects: Busy-waits on button state and timer delay.
 * Test idea: Hold button down; function should only complete after full release.
 */
.type waitForButtonPressDebounced, %function
.thumb_func
waitForButtonPressDebounced:
    push {lr}

waitForButtonPressDebounced_waitPress:
    bl readUserButton
    cmp r0, #0
    beq waitForButtonPressDebounced_waitPress

    ldr r1, =EX2_DEBOUNCE_US
    bl delayUsTimer

    bl readUserButton
    cmp r0, #0
    beq waitForButtonPressDebounced_waitPress

waitForButtonPressDebounced_waitRelease:
    bl readUserButton
    cmp r0, #0
    bne waitForButtonPressDebounced_waitRelease

    ldr r1, =EX2_DEBOUNCE_US
    bl delayUsTimer

    bl readUserButton
    cmp r0, #0
    bne waitForButtonPressDebounced_waitRelease

    pop {pc}
.size waitForButtonPressDebounced, . - waitForButtonPressDebounced
