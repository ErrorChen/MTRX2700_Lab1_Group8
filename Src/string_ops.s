#include "platform_defs.inc"

.global stringLength
.global stringConvertCaseInPlace

.section .text.string_ops, "ax", %progbits
.align 2

/* Purpose: Compute length of a NUL-terminated ASCII string.
 * Inputs: r1 = pointer to source string
 * Outputs: r2 = length excluding terminator
 * Clobbers: r2-r3
 * Preserved registers: r0-r1, r4-r11, lr
 * Side effects: none
 * Test idea: Pass "ABC\0" and verify r2 == 3.
 */
.type stringLength, %function
.thumb_func
stringLength:
    movs r2, #0

stringLength_loop:
    ldrb r3, [r1, r2]
    cmp r3, #ASCII_NUL
    beq stringLength_done
    adds r2, r2, #1
    b stringLength_loop

stringLength_done:
    bx lr
.size stringLength, . - stringLength

/* Purpose: Convert alphabetic ASCII string in place to lower or upper case.
 * Inputs: r1 = string pointer, r2 = mode (0 lower-case, non-zero upper-case)
 * Outputs: none
 * Clobbers: r3
 * Preserved registers: r0-r2, r4-r11, lr
 * Side effects: Mutates bytes in source buffer.
 * Test idea: Use mixed-case input and verify only A-Z/a-z characters change.
 */
.type stringConvertCaseInPlace, %function
.thumb_func
stringConvertCaseInPlace:
stringConvertCaseInPlace_loop:
    ldrb r3, [r1]
    cmp r3, #ASCII_NUL
    beq stringConvertCaseInPlace_done

    cmp r2, #0
    beq stringConvertCaseInPlace_toLower

    cmp r3, #ASCII_LOWER_A
    blt stringConvertCaseInPlace_next
    cmp r3, #ASCII_LOWER_Z
    bgt stringConvertCaseInPlace_next
    subs r3, r3, #ASCII_CASE_DELTA
    strb r3, [r1]
    b stringConvertCaseInPlace_next

stringConvertCaseInPlace_toLower:
    cmp r3, #ASCII_UPPER_A
    blt stringConvertCaseInPlace_next
    cmp r3, #ASCII_UPPER_Z
    bgt stringConvertCaseInPlace_next
    adds r3, r3, #ASCII_CASE_DELTA
    strb r3, [r1]

stringConvertCaseInPlace_next:
    adds r1, r1, #1
    b stringConvertCaseInPlace_loop

stringConvertCaseInPlace_done:
    bx lr
.size stringConvertCaseInPlace, . - stringConvertCaseInPlace
