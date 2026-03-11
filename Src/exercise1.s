#ifndef EXERCISE1_S
#define EXERCISE1_S

#include "definitions.s"

.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

.global exercise1Entry
.global stringLength
.global stringConvertCaseInPlace
.global buildFramedMessage
.global calcBcc
.global verifyBcc

.section .data.exercise1, "aw", %progbits
.align 4
ex1_upper_sample:
    .asciz "mechatronics lab one"
ex1_lower_sample:
    .asciz "ASSEMBLY STRING TEST"
ex1_frame_source:
    .asciz "Lab1-Frame-Demo"

.section .bss.exercise1, "aw", %nobits
.align 4
ex1_length_result:
    .word 0
ex1_upper_length_result:
    .word 0
ex1_lower_length_result:
    .word 0
ex1_frame_length_result:
    .word 0
ex1_bcc_value_result:
    .word 0
ex1_verify_result:
    .word 0
ex1_verify_corrupt_result:
    .word 0
ex1_frame_buffer:
    .space MAX_FRAME_BYTES
ex1_frame_buffer_corrupt:
    .space MAX_FRAME_BYTES

.section .text.exercise1, "ax", %progbits
.align 2

/* Purpose: Exercise 1 demonstration entry for string/framing/checksum tasks.
 * Inputs: none
 * Outputs: none (loops forever)
 * Clobbers: r0-r7, lr
 * Preserves: r8-r11
 * Test: Inspect ex1_* result symbols and buffers in debugger.
 */
.type exercise1Entry, %function
.thumb_func
exercise1Entry:
    push {r4-r7, lr}

    ldr r1, =ex1_upper_sample
    bl stringLength
    ldr r0, =ex1_length_result
    str r2, [r0]

    ldr r1, =ex1_upper_sample
    movs r2, #1
    bl stringConvertCaseInPlace
    ldr r1, =ex1_upper_sample
    bl stringLength
    ldr r0, =ex1_upper_length_result
    str r2, [r0]

    ldr r1, =ex1_lower_sample
    movs r2, #0
    bl stringConvertCaseInPlace
    ldr r1, =ex1_lower_sample
    bl stringLength
    ldr r0, =ex1_lower_length_result
    str r2, [r0]

    ldr r0, =ex1_frame_source
    ldr r1, =ex1_frame_buffer
    bl buildFramedMessage
    ldr r4, =ex1_frame_length_result
    str r2, [r4]

    ldr r1, =ex1_frame_buffer
    ldr r2, [r4]
    subs r2, r2, #1
    bl calcBcc
    ldr r0, =ex1_bcc_value_result
    str r3, [r0]

    ldr r1, =ex1_frame_buffer
    ldr r2, [r4]
    bl verifyBcc
    ldr r0, =ex1_verify_result
    str r3, [r0]

    /* Copy frame into second buffer, corrupt one byte, and re-verify. */
    ldr r5, =ex1_frame_buffer
    ldr r6, =ex1_frame_buffer_corrupt
    ldr r7, [r4]
ex1_copy_loop:
    cmp r7, #0
    beq ex1_copy_done
    ldrb r0, [r5]
    strb r0, [r6]
    adds r5, r5, #1
    adds r6, r6, #1
    subs r7, r7, #1
    b ex1_copy_loop
ex1_copy_done:

    ldr r0, =ex1_frame_length_result
    ldr r2, [r0]
    cmp r2, #FRAME_MIN_LENGTH
    bls ex1_skip_corrupt
    ldr r1, =ex1_frame_buffer_corrupt
    adds r1, r1, #2
    ldrb r0, [r1]
    eors r0, r0, #1
    strb r0, [r1]
ex1_skip_corrupt:

    ldr r1, =ex1_frame_buffer_corrupt
    ldr r0, =ex1_frame_length_result
    ldr r2, [r0]
    bl verifyBcc
    ldr r0, =ex1_verify_corrupt_result
    str r3, [r0]

    pop {r4-r7, lr}
ex1_done_loop:
    b ex1_done_loop
.size exercise1Entry, . - exercise1Entry

/* Purpose: Compute length of a NUL-terminated ASCII string.
 * Inputs: r1 = pointer to string
 * Outputs: r2 = length excluding NUL
 * Clobbers: r2-r3
 * Preserves: r0-r1, r4-r11, lr
 * Test: Pass known literals and compare expected length.
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

/* Purpose: Convert string case in place (upper/lower) for alphabetic ASCII.
 * Inputs: r1 = pointer to string, r2 = mode (0 lowercase, non-zero uppercase)
 * Outputs: modified string in memory
 * Clobbers: r3
 * Preserves: r0-r2, r4-r11, lr
 * Test: Run with mixed-case input and verify only letters change.
 */
.type stringConvertCaseInPlace, %function
.thumb_func
stringConvertCaseInPlace:
stringConvertCaseInPlace_loop:
    ldrb r3, [r1]
    cmp r3, #ASCII_NUL
    beq stringConvertCaseInPlace_done

    cmp r2, #0
    beq stringConvertCaseInPlace_to_lower

    /* Uppercase mode: 'a'..'z' -> 'A'..'Z'. */
    cmp r3, #ASCII_LOWER_A
    blt stringConvertCaseInPlace_advance
    cmp r3, #ASCII_LOWER_Z
    bgt stringConvertCaseInPlace_advance
    subs r3, r3, #ASCII_CASE_DELTA
    strb r3, [r1]
    b stringConvertCaseInPlace_advance

stringConvertCaseInPlace_to_lower:
    /* Lowercase mode: 'A'..'Z' -> 'a'..'z'. */
    cmp r3, #ASCII_UPPER_A
    blt stringConvertCaseInPlace_advance
    cmp r3, #ASCII_UPPER_Z
    bgt stringConvertCaseInPlace_advance
    adds r3, r3, #ASCII_CASE_DELTA
    strb r3, [r1]

stringConvertCaseInPlace_advance:
    adds r1, r1, #1
    b stringConvertCaseInPlace_loop

stringConvertCaseInPlace_done:
    bx lr
.size stringConvertCaseInPlace, . - stringConvertCaseInPlace

/* Purpose: Build framed message [STX][LEN][BODY][ETX][BCC] from source string.
 * Inputs: r0 = source string pointer, r1 = destination buffer pointer
 * Outputs: r2 = total framed length including checksum
 * Clobbers: r0-r3, r4-r8, lr
 * Preserves: r9-r11
 * Test: Verify frame bytes and checksum against manual XOR calculation.
 */
.type buildFramedMessage, %function
.thumb_func
buildFramedMessage:
    push {r4-r8, lr}
    mov r4, r0
    mov r5, r1

    /* Measure source payload length (excluding NUL). */
    movs r6, #0
buildFramedMessage_measure_loop:
    ldrb r3, [r4, r6]
    cmp r3, #ASCII_NUL
    beq buildFramedMessage_measure_done
    adds r6, r6, #1
    b buildFramedMessage_measure_loop
buildFramedMessage_measure_done:

    /* LEN is one byte, keep payload bounded. */
    cmp r6, #MAX_PAYLOAD_BYTES
    bls buildFramedMessage_len_ok
    movs r6, #MAX_PAYLOAD_BYTES
buildFramedMessage_len_ok:

    adds r8, r6, #FRAME_MIN_LENGTH

    movs r3, #STX
    strb r3, [r5]
    strb r8, [r5, #1]

    mov r0, r4
    adds r1, r5, #2
    movs r7, #0
buildFramedMessage_copy_loop:
    cmp r7, r6
    bcs buildFramedMessage_copy_done
    ldrb r3, [r0]
    strb r3, [r1]
    adds r0, r0, #1
    adds r1, r1, #1
    adds r7, r7, #1
    b buildFramedMessage_copy_loop
buildFramedMessage_copy_done:

    movs r3, #ETX
    strb r3, [r1]

    /* Compute checksum over frame bytes excluding final checksum byte. */
    mov r1, r5
    mov r2, r8
    subs r2, r2, #1
    bl calcBcc

    adds r0, r5, r2
    strb r3, [r0]

    mov r2, r8
    pop {r4-r8, pc}
.size buildFramedMessage, . - buildFramedMessage

/* Purpose: Compute 8-bit XOR BCC over a memory buffer.
 * Inputs: r1 = buffer pointer, r2 = length
 * Outputs: r3 = 8-bit XOR checksum
 * Clobbers: r0, r2, r12
 * Preserves: r1, r4-r11, lr
 * Test: Feed known vectors and compare with expected XOR output.
 */
.type calcBcc, %function
.thumb_func
calcBcc:
    movs r3, #0
    cmp r2, #0
    beq calcBcc_done

    mov r0, r1
calcBcc_loop:
    ldrb r12, [r0]
    eors r3, r3, r12
    uxtb r3, r3
    adds r0, r0, #1
    subs r2, r2, #1
    bne calcBcc_loop
calcBcc_done:
    bx lr
.size calcBcc, . - calcBcc

/* Purpose: Verify BCC by XORing the full framed message including checksum.
 * Inputs: r1 = framed buffer pointer, r2 = full length including checksum
 * Outputs: r3 = 1 if valid, 0 if invalid
 * Clobbers: r0-r3, lr
 * Preserves: r4-r11
 * Test: Validate unmodified frame returns 1; tampered frame returns 0.
 */
.type verifyBcc, %function
.thumb_func
verifyBcc:
    push {lr}
    bl calcBcc
    cmp r3, #0
    ite eq
    moveq r3, #1
    movne r3, #0
    pop {pc}
.size verifyBcc, . - verifyBcc

#endif /* EXERCISE1_S */
