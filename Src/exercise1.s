#include "platform_defs.inc"

.global exercise1Entry

.extern stringLength
.extern stringConvertCaseInPlace
.extern buildFramedMessage
.extern calcActiveChecksum
.extern calcCrc16
.extern verifyFrameChecksum

.section .data.exercise1, "aw", %progbits
.align 4
exercise1UppercaseSample:
    .asciz "mechatronics lab one"
exercise1LowercaseSample:
    .asciz "ASSEMBLY STRING TEST"
exercise1FrameSource:
    .asciz "Lab1-Frame-Demo"

.section .rodata.exercise1, "a", %progbits
.align 4
exercise1Crc16SelfTestPayload:
    .asciz "123456789"

.section .bss.exercise1, "aw", %nobits
.align 4
exercise1ActiveChecksumMode:
    .word 0
exercise1ActiveChecksumBytes:
    .word 0
exercise1InitialLength:
    .word 0
exercise1UppercaseLength:
    .word 0
exercise1LowercaseLength:
    .word 0
exercise1FrameLength:
    .word 0
exercise1ChecksumValue:
    .word 0
exercise1ChecksumValid:
    .word 0
exercise1CorruptChecksumValid:
    .word 0
exercise1Crc16SelfTestExpected:
    .word 0
exercise1Crc16SelfTestActual:
    .word 0
exercise1Crc16SelfTestPass:
    .word 0
exercise1FrameBuffer:
    .space MAX_FRAME_BYTES
exercise1CorruptFrameBuffer:
    .space MAX_FRAME_BYTES

.section .text.exercise1, "ax", %progbits
.align 2

/* Purpose: Exercise 1 orchestration for string, framing, and checksum workflow.
 * Inputs: none
 * Outputs: none (loops forever for debugger inspection)
 * Clobbers: r0-r8, lr
 * Preserved registers: r9-r11
 * Side effects: Writes intermediate results into exercise1* RAM symbols.
 * Test idea: Validate checksum flag flips after deliberate frame corruption.
 */
.type exercise1Entry, %function
.thumb_func
exercise1Entry:
    push {r4-r8, lr}

    ldr r0, =exercise1ActiveChecksumMode
    ldr r1, =CHECKSUM_ACTIVE_MODE
    str r1, [r0]

    ldr r0, =exercise1ActiveChecksumBytes
    ldr r1, =FRAME_CHECKSUM_BYTE_COUNT
    str r1, [r0]

    ldr r1, =exercise1UppercaseSample
    bl stringLength
    ldr r0, =exercise1InitialLength
    str r2, [r0]

    ldr r1, =exercise1UppercaseSample
    movs r2, #1
    bl stringConvertCaseInPlace
    ldr r1, =exercise1UppercaseSample
    bl stringLength
    ldr r0, =exercise1UppercaseLength
    str r2, [r0]

    ldr r1, =exercise1LowercaseSample
    movs r2, #0
    bl stringConvertCaseInPlace
    ldr r1, =exercise1LowercaseSample
    bl stringLength
    ldr r0, =exercise1LowercaseLength
    str r2, [r0]

    ldr r0, =exercise1FrameSource
    ldr r1, =exercise1FrameBuffer
    bl buildFramedMessage
    ldr r4, =exercise1FrameLength
    str r2, [r4]

    ldr r1, =exercise1FrameBuffer
    ldr r2, [r4]
    subs r2, r2, #FRAME_CHECKSUM_BYTE_COUNT
    bl calcActiveChecksum
    ldr r0, =exercise1ChecksumValue
    str r3, [r0]

    ldr r1, =exercise1FrameBuffer
    ldr r2, [r4]
    bl verifyFrameChecksum
    ldr r0, =exercise1ChecksumValid
    str r3, [r0]

    ldr r5, =exercise1FrameBuffer
    ldr r6, =exercise1CorruptFrameBuffer
    ldr r7, [r4]

exercise1CopyFrameLoop:
    cmp r7, #0
    beq exercise1CopyFrameDone
    ldrb r0, [r5]
    strb r0, [r6]
    adds r5, r5, #1
    adds r6, r6, #1
    subs r7, r7, #1
    b exercise1CopyFrameLoop

exercise1CopyFrameDone:
    ldr r2, [r4]
    cmp r2, #FRAME_MIN_LENGTH
    bls exercise1SkipCorruption

    ldr r1, =exercise1CorruptFrameBuffer
    adds r1, r1, #2
    ldrb r0, [r1]
    eors r0, r0, #1
    strb r0, [r1]

exercise1SkipCorruption:
    ldr r1, =exercise1CorruptFrameBuffer
    ldr r2, [r4]
    bl verifyFrameChecksum
    ldr r0, =exercise1CorruptChecksumValid
    str r3, [r0]

    ldr r1, =exercise1Crc16SelfTestPayload
    bl stringLength
    mov r5, r2

    ldr r1, =exercise1Crc16SelfTestPayload
    mov r2, r5
    bl calcCrc16
    ldr r0, =exercise1Crc16SelfTestActual
    str r3, [r0]

    ldr r6, =CRC16_CCITT_FALSE_CHECK_123456789
    ldr r0, =exercise1Crc16SelfTestExpected
    str r6, [r0]

    cmp r3, r6
    ite eq
    moveq r7, #1
    movne r7, #0
    ldr r0, =exercise1Crc16SelfTestPass
    str r7, [r0]

    pop {r4-r8, lr}

exercise1DoneLoop:
    b exercise1DoneLoop
.size exercise1Entry, . - exercise1Entry
