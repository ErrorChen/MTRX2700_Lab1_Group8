#include "platform_defs.inc"

.global buildCounterAsciiMessage
.global parseCounterAsciiMessage

.section .rodata.counter_format, "a", %progbits
.align 4
counterMessagePrefix:
    .ascii "COUNTER = "

.section .text.counter_format, "ax", %progbits
.align 2

/* Purpose: Build payload string "COUNTER = XXX" with 3-digit decimal suffix.
 * Inputs: r0 = counter value, r1 = destination buffer
 * Outputs: r2 = payload length (COUNTER_MESSAGE_LENGTH)
 * Clobbers: r0-r3, r4-r7, r12, lr
 * Preserved registers: r8-r11
 * Side effects: Writes 14 bytes (13 payload + NUL terminator).
 * Test idea: Input 7 should generate "COUNTER = 007".
 */
.type buildCounterAsciiMessage, %function
.thumb_func
buildCounterAsciiMessage:
    push {r4-r7, lr}
    mov r4, r0
    mov r5, r1

    ldr r6, =COUNTER_DECIMAL_WRAP
    udiv r7, r4, r6
    mul r7, r7, r6
    subs r4, r4, r7

    ldr r6, =counterMessagePrefix
    movs r7, #0

buildCounterAsciiMessage_copyPrefix:
    cmp r7, #10
    bcs buildCounterAsciiMessage_prefixDone
    ldrb r3, [r6, r7]
    strb r3, [r5, r7]
    adds r7, r7, #1
    b buildCounterAsciiMessage_copyPrefix

buildCounterAsciiMessage_prefixDone:
    movs r6, #100
    udiv r7, r4, r6
    mul r12, r7, r6
    subs r4, r4, r12
    adds r7, r7, #ASCII_ZERO
    strb r7, [r5, #10]

    movs r6, #10
    udiv r7, r4, r6
    mul r12, r7, r6
    subs r4, r4, r12
    adds r7, r7, #ASCII_ZERO
    strb r7, [r5, #11]

    adds r4, r4, #ASCII_ZERO
    strb r4, [r5, #12]

    movs r3, #ASCII_NUL
    strb r3, [r5, #13]

    movs r2, #COUNTER_MESSAGE_LENGTH
    pop {r4-r7, pc}
.size buildCounterAsciiMessage, . - buildCounterAsciiMessage

/* Purpose: Parse payload string "COUNTER = XXX" to numeric counter value.
 * Inputs: r1 = payload pointer
 * Outputs: r0 = 1 if valid else 0, r2 = parsed counter when valid
 * Clobbers: r2-r3, r4-r7, r12, lr
 * Preserved registers: r1, r8-r11
 * Side effects: none
 * Test idea: "COUNTER = 123" returns r0=1,r2=123; malformed input returns r0=0.
 */
.type parseCounterAsciiMessage, %function
.thumb_func
parseCounterAsciiMessage:
    push {r4-r7, lr}

    movs r2, #0
    mov r5, r1
    ldr r4, =counterMessagePrefix
    movs r6, #0

parseCounterAsciiMessage_checkPrefix:
    cmp r6, #10
    bcs parseCounterAsciiMessage_digits
    ldrb r3, [r5, r6]
    ldrb r7, [r4, r6]
    cmp r3, r7
    bne parseCounterAsciiMessage_invalid
    adds r6, r6, #1
    b parseCounterAsciiMessage_checkPrefix

parseCounterAsciiMessage_digits:
    ldrb r3, [r5, #10]
    cmp r3, #ASCII_ZERO
    blo parseCounterAsciiMessage_invalid
    cmp r3, #ASCII_NINE
    bhi parseCounterAsciiMessage_invalid
    subs r3, r3, #ASCII_ZERO
    movs r12, #100
    mul r3, r3, r12
    adds r2, r2, r3

    ldrb r3, [r5, #11]
    cmp r3, #ASCII_ZERO
    blo parseCounterAsciiMessage_invalid
    cmp r3, #ASCII_NINE
    bhi parseCounterAsciiMessage_invalid
    subs r3, r3, #ASCII_ZERO
    movs r12, #10
    mul r3, r3, r12
    adds r2, r2, r3

    ldrb r3, [r5, #12]
    cmp r3, #ASCII_ZERO
    blo parseCounterAsciiMessage_invalid
    cmp r3, #ASCII_NINE
    bhi parseCounterAsciiMessage_invalid
    subs r3, r3, #ASCII_ZERO
    adds r2, r2, r3

    ldrb r3, [r5, #13]
    cmp r3, #ASCII_NUL
    bne parseCounterAsciiMessage_invalid

    movs r0, #1
    pop {r4-r7, pc}

parseCounterAsciiMessage_invalid:
    movs r0, #0
    movs r2, #0
    pop {r4-r7, pc}
.size parseCounterAsciiMessage, . - parseCounterAsciiMessage
