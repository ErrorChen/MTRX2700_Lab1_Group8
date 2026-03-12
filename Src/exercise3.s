#include "platform_defs.inc"

.global exercise3Entry

.extern waitForButtonPressDebounced
.extern buildFramedMessage
.extern uart4Init
.extern uart5Init
.extern uartSendBuffer
.extern uartReceiveFramedMessage
.extern uartSendAckMessage
.extern uartSendNakMessage
.extern setLedBitmask

.section .rodata.exercise3, "a", %progbits
.align 4
exercise3DemoPayload:
    .asciz "UART4 TO UART5 DEMO"

.section .bss.exercise3, "aw", %nobits
.align 4
exercise3LastStatus:
    .word 0
exercise3LastPayloadLength:
    .word 0
exercise3LastFrameLength:
    .word 0
exercise3TransmitFrameBuffer:
    .space MAX_FRAME_BYTES
exercise3ReceiveFrameBuffer:
    .space MAX_FRAME_BYTES
exercise3ReceivePayloadBuffer:
    .space (MAX_PAYLOAD_BYTES + 1)

.section .text.exercise3, "ax", %progbits
.align 2

/* Purpose: Exercise 3 orchestration for UART framing, RX validation, ACK/NAK flow.
 * Inputs: none
 * Outputs: none (infinite loop)
 * Clobbers: r0-r4, lr
 * Preserved registers: r5-r11
 * Side effects: Sends/receives UART frames and updates debug state symbols.
 * Test idea: Force frame corruption and confirm NAK path with fail LED pattern.
 */
.type exercise3Entry, %function
.thumb_func
exercise3Entry:
    push {r4, lr}
    bl uart4Init
    bl uart5Init

exercise3MainLoop:
    bl waitForButtonPressDebounced

    ldr r0, =exercise3DemoPayload
    ldr r1, =exercise3TransmitFrameBuffer
    bl buildFramedMessage
    ldr r4, =exercise3LastFrameLength
    str r2, [r4]

    ldr r0, =UART4_BASE
    ldr r1, =exercise3TransmitFrameBuffer
    bl uartSendBuffer

    ldr r0, =UART5_BASE
    ldr r1, =exercise3ReceiveFrameBuffer
    ldr r2, =exercise3ReceivePayloadBuffer
    bl uartReceiveFramedMessage

    ldr r0, =exercise3LastStatus
    str r3, [r0]
    ldr r0, =exercise3LastPayloadLength
    str r2, [r0]

    cmp r3, #UART_STATUS_OK
    bne exercise3SendNak

    ldr r0, =UART5_BASE
    bl uartSendAckMessage
    movs r0, #0xA5
    bl setLedBitmask
    b exercise3MainLoop

exercise3SendNak:
    ldr r0, =UART5_BASE
    bl uartSendNakMessage
    movs r0, #0x3C
    bl setLedBitmask
    b exercise3MainLoop
.size exercise3Entry, . - exercise3Entry
