#include "platform_defs.inc"

.global calcCrc16
.global verifyCrc16

.section .text.crc16, "ax", %progbits
.align 2

/* Purpose: Compute CRC-16/CCITT-FALSE over a byte buffer in software.
 * Inputs: r1 = buffer pointer, r2 = number of bytes
 * Outputs: r3 = 16-bit CRC value
 * Clobbers: r0-r4, r12
 * Preserved registers: r5-r11, lr
 * Side effects: none
 * Test idea: "123456789" should produce CRC16_CCITT_FALSE_CHECK_123456789.
 */
.type calcCrc16, %function
.thumb_func
calcCrc16:
    push {r4}
    mov r4, r1
    ldr r0, =CRC16_POLYNOMIAL
    ldr r3, =CRC16_INITIAL_VALUE

    cmp r2, #0
    beq calcCrc16_applyFinalXor

calcCrc16_byteLoop:
    ldrb r12, [r4]
    adds r4, r4, #1
    lsls r12, r12, #8
    eors r3, r3, r12
    movs r1, #8

calcCrc16_bitLoop:
    tst r3, #CRC16_TOPBIT
    beq calcCrc16_shiftOnly

    lsls r3, r3, #1
    eors r3, r3, r0
    uxth r3, r3
    subs r1, r1, #1
    bne calcCrc16_bitLoop
    b calcCrc16_nextByte

calcCrc16_shiftOnly:
    lsls r3, r3, #1
    uxth r3, r3
    subs r1, r1, #1
    bne calcCrc16_bitLoop

calcCrc16_nextByte:
    subs r2, r2, #1
    bne calcCrc16_byteLoop

calcCrc16_applyFinalXor:
    ldr r0, =CRC16_FINAL_XOR_VALUE
    eors r3, r3, r0
    uxth r3, r3
    pop {r4}
    bx lr
.size calcCrc16, . - calcCrc16

/* Purpose: Validate CRC-16/CCITT-FALSE stored as [CRC_H][CRC_L] at frame end.
 * Inputs: r1 = frame pointer, r2 = full frame length including CRC bytes
 * Outputs: r3 = 1 (valid) or 0 (invalid)
 * Clobbers: r0-r3, r4-r7, lr
 * Preserved registers: r8-r11
 * Side effects: none
 * Test idea: Corrupt one payload byte and verify function returns 0.
 */
.type verifyCrc16, %function
.thumb_func
verifyCrc16:
    push {r4-r7, lr}
    mov r4, r1
    mov r5, r2

    cmp r5, #(FRAME_HEADER_LENGTH + FRAME_ETX_LENGTH + CRC16_CHECKSUM_BYTE_COUNT)
    blo verifyCrc16_invalid

    mov r1, r4
    mov r2, r5
    subs r2, r2, #CRC16_CHECKSUM_BYTE_COUNT
    bl calcCrc16

    adds r0, r4, r5
    subs r0, r0, #CRC16_CHECKSUM_BYTE_COUNT
    ldrb r6, [r0]
    ldrb r7, [r0, #1]
    lsls r6, r6, #8
    orrs r6, r6, r7

    cmp r3, r6
    ite eq
    moveq r3, #1
    movne r3, #0
    pop {r4-r7, pc}

verifyCrc16_invalid:
    movs r3, #0
    pop {r4-r7, pc}
.size verifyCrc16, . - verifyCrc16
