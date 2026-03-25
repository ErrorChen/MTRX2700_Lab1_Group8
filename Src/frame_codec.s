#include "platform_defs.inc"

.global buildFramedMessage
.global calcActiveChecksum
.global calcBcc
.global verifyFrameChecksum
.global verifyBcc

.extern stringLength
.extern calcCrc16
.extern verifyCrc16

.section .text.frame_codec, "ax", %progbits
.align 2

/* Purpose: Build [STX][LEN][PAYLOAD][ETX][CHECKSUM...] frame from ASCII payload.
 * Inputs: r0 = payload string pointer, r1 = destination frame buffer
 * Outputs: r2 = full frame length including active checksum bytes
 * Clobbers: r0-r3, r4-r8, lr
 * Preserved registers: r9-r11
 * Side effects: Writes framed message bytes to destination buffer.
 * Test idea: Build frame for "ABC" and verify LEN, ETX, and checksum bytes.
 */
.type buildFramedMessage, %function
.thumb_func
buildFramedMessage:
    push {r4-r8, lr}
    mov r4, r0
    mov r5, r1

    mov r1, r4
    bl stringLength
    mov r6, r2

    cmp r6, #MAX_PAYLOAD_BYTES
    bls buildFramedMessage_payloadLenOk
    movs r6, #MAX_PAYLOAD_BYTES

buildFramedMessage_payloadLenOk:
    adds r8, r6, #FRAME_MIN_LENGTH

    movs r3, #STX
    strb r3, [r5]
    strb r8, [r5, #1]

    mov r0, r4
    adds r1, r5, #2
    movs r7, #0

buildFramedMessage_copyPayload:
    cmp r7, r6
    bcs buildFramedMessage_payloadDone
    ldrb r3, [r0]
    strb r3, [r1]
    adds r0, r0, #1
    adds r1, r1, #1
    adds r7, r7, #1
    b buildFramedMessage_copyPayload

buildFramedMessage_payloadDone:
    movs r3, #ETX
    strb r3, [r1]

    mov r1, r5
    mov r2, r8
    subs r2, r2, #FRAME_CHECKSUM_BYTE_COUNT
    bl calcActiveChecksum

    adds r0, r5, r8
    subs r0, r0, #FRAME_CHECKSUM_BYTE_COUNT
.if CHECKSUM_ACTIVE_MODE == CHECKSUM_MODE_BCC
    strb r3, [r0]
.elseif CHECKSUM_ACTIVE_MODE == CHECKSUM_MODE_CRC16
    lsrs r1, r3, #8
    strb r1, [r0]
    strb r3, [r0, #1]
.else
    movs r1, #0
    strb r1, [r0]
.endif

    mov r2, r8
    pop {r4-r8, pc}
.size buildFramedMessage, . - buildFramedMessage

/* Purpose: Compute the checksum selected by CHECKSUM_ACTIVE_MODE.
 * Inputs: r1 = buffer pointer, r2 = number of bytes before checksum field
 * Outputs: r3 = checksum value (8-bit BCC or 16-bit CRC)
 * Clobbers: depends on selected checksum routine
 * Preserved registers: depends on selected checksum routine
 * Side effects: none
 * Test idea: Toggle CHECKSUM_ACTIVE_MODE and compare result with mode-specific helper.
 */
.type calcActiveChecksum, %function
.thumb_func
calcActiveChecksum:
.if CHECKSUM_ACTIVE_MODE == CHECKSUM_MODE_BCC
    b calcBcc
.elseif CHECKSUM_ACTIVE_MODE == CHECKSUM_MODE_CRC16
    b calcCrc16
.else
    movs r3, #0
    bx lr
.endif
.size calcActiveChecksum, . - calcActiveChecksum

/* Purpose: Compute 8-bit XOR checksum over a byte buffer.
 * Inputs: r1 = buffer pointer, r2 = number of bytes
 * Outputs: r3 = XOR checksum
 * Clobbers: r0, r2, r12
 * Preserved registers: r1, r4-r11, lr
 * Side effects: none
 * Test idea: Verify checksum of known vector against manual XOR.
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

/* Purpose: Validate the active frame checksum selected at build time.
 * Inputs: r1 = frame pointer, r2 = full frame length including checksum
 * Outputs: r3 = 1 (valid) or 0 (invalid)
 * Clobbers: depends on selected checksum routine
 * Preserved registers: depends on selected checksum routine
 * Side effects: none
 * Test idea: Corrupt one frame byte and verify function returns 0 in both modes.
 */
.type verifyFrameChecksum, %function
.thumb_func
verifyFrameChecksum:
.if CHECKSUM_ACTIVE_MODE == CHECKSUM_MODE_BCC
    b verifyBcc
.elseif CHECKSUM_ACTIVE_MODE == CHECKSUM_MODE_CRC16
    b verifyCrc16
.else
    movs r3, #0
    bx lr
.endif
.size verifyFrameChecksum, . - verifyFrameChecksum

/* Purpose: Validate BCC by XORing full frame including checksum byte.
 * Inputs: r1 = frame pointer, r2 = full frame length including checksum
 * Outputs: r3 = 1 (valid) or 0 (invalid)
 * Clobbers: r0-r3, lr
 * Preserved registers: r4-r11
 * Side effects: none
 * Test idea: Corrupt one frame byte and verify function returns 0.
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
