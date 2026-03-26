#include "platform_defs.inc"

.global main
.global SystemInit
.global dispatchExerciseById

.extern enablePeripheralClocks
.extern initialiseDiscoveryBoard
.extern timInit1MHz
.extern ledErrorLoop

.extern exercise1Entry
.extern exercise2Entry
.extern exercise3Entry
.extern exercise4Entry
.extern exercise5Entry

.section .text.main, "ax", %progbits
.align 2

/* Purpose: CMSIS startup hook called by Reset_Handler before C runtime init.
 * Inputs: none
 * Outputs: none
 * Clobbers: none
 * Preserved registers: all
 * Side effects: none
 * Test idea: Reset target and verify control reaches main.
 */
.type SystemInit, %function
.thumb_func
SystemInit:
    bx lr
.size SystemInit, . - SystemInit

/* Purpose: Top-level runtime entry that performs board init and exercise dispatch.
 * Inputs: none
 * Outputs: none (never intentionally returns)
 * Clobbers: r0-r3, lr
 * Preserved registers: r4-r11
 * Side effects: Initialises peripherals then runs selected exercise.
 * Test idea: Change ACTIVE_EXERCISE and confirm selected entry executes.
 */
.type main, %function
.thumb_func
main:
    bl enablePeripheralClocks
    bl initialiseDiscoveryBoard
    bl timInit1MHz

    ldr r0, =ACTIVE_EXERCISE
    bl dispatchExerciseById

    b ledErrorLoop
.size main, . - main

/* Purpose: Dispatch a numeric exercise ID to the corresponding exercise entry.
 * Inputs: r0 = exercise ID
 * Outputs: none
 * Clobbers: condition flags
 * Preserved registers: r0-r11, lr (except via called entry)
 * Side effects: Branches into selected exercise entry.
 * Test idea: IDs 1..5 jump to expected exercise; invalid IDs return.
 */
.type dispatchExerciseById, %function
.thumb_func
dispatchExerciseById:
    cmp r0, #1
    beq dispatchExerciseById_ex1
    cmp r0, #2
    beq dispatchExerciseById_ex2
    cmp r0, #3
    beq dispatchExerciseById_ex3
    cmp r0, #4
    beq dispatchExerciseById_ex4
    cmp r0, #5
    beq dispatchExerciseById_ex5
    bx lr

dispatchExerciseById_ex1:
    b exercise1Entry

dispatchExerciseById_ex2:
    bl exercise2Entry

dispatchExerciseById_ex3:
    b exercise3Entry

dispatchExerciseById_ex4:
    b exercise4Entry

dispatchExerciseById_ex5:
    b exercise5Entry
.size dispatchExerciseById, . - dispatchExerciseById
