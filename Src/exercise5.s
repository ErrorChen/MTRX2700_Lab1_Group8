#include "platform_defs.inc"

.global exercise5Entry
.global exercise5RunTransmitterRole
.global exercise5RunReceiverRole

.extern uart4Init
.extern buildCounterAsciiMessage
.extern parseCounterAsciiMessage
.extern buildFramedMessage
.extern uartSendBuffer
.extern uartReceiveFramedMessage
.extern uartSendAckMessage
.extern uartSendNakMessage
.extern waitForAckOrNakWithTimeout
.extern flashAllLedsThreeTimes
.extern displayCounterOnLeds
.extern delayUsTimer
.extern ledErrorLoop

.section .bss.exercise5, "aw", %nobits
.align 4
exercise5CounterValue:
    .word 0
exercise5LastAckResult:
    .word 0
exercise5LastReceiveStatus:
    .word 0
exercise5LastParseOk:
    .word 0
exercise5TxPayloadBuffer:
    .space 20
exercise5TxFrameBuffer:
    .space MAX_FRAME_BYTES
exercise5RxFrameBuffer:
    .space MAX_FRAME_BYTES
exercise5RxPayloadBuffer:
    .space (MAX_PAYLOAD_BYTES + 1)

.section .text.exercise5, "ax", %progbits
.align 2

/* Purpose: Exercise 5 role selector entry (TX or RX) for framed counter protocol.
 * Inputs: none
 * Outputs: none (never returns intentionally)
 * Clobbers: r0-r3, lr
 * Preserved registers: r4-r11
 * Side effects: Initialises UART4 and transfers control to selected role loop.
 * Test idea: Switch EX5_ACTIVE_ROLE and verify correct role path runs.
 */
.type exercise5Entry, %function
.thumb_func
exercise5Entry:
    bl uart4Init

    movs r0, #EX5_ACTIVE_ROLE
    cmp r0, #EX5_ROLE_TX
    beq exercise5Entry_runTx
    cmp r0, #EX5_ROLE_RX
    beq exercise5Entry_runRx
    b ledErrorLoop

exercise5Entry_runTx:
    b exercise5RunTransmitterRole

exercise5Entry_runRx:
    b exercise5RunReceiverRole
.size exercise5Entry, . - exercise5Entry

/* Purpose: Exercise 5 transmitter loop with periodic send and ACK/NAK handling.
 * Inputs: none
 * Outputs: none (infinite loop)
 * Clobbers: r0-r3, lr
 * Preserved registers: r4-r11
 * Side effects: Sends UART frames and updates LED counter/error indication.
 * Test idea: Disconnect RX side to force timeout and verify reset + flashes.
 */
.type exercise5RunTransmitterRole, %function
.thumb_func
exercise5RunTransmitterRole:
    ldr r0, =exercise5CounterValue
    movs r1, #0
    str r1, [r0]

exercise5RunTransmitterRole_loop:
    ldr r1, =EX5_MESSAGE_PERIOD_US
    bl delayUsTimer

    ldr r3, =exercise5CounterValue
    ldr r0, [r3]
    ldr r1, =exercise5TxPayloadBuffer
    bl buildCounterAsciiMessage

    ldr r0, =exercise5TxPayloadBuffer
    ldr r1, =exercise5TxFrameBuffer
    bl buildFramedMessage

    ldr r0, =UART4_BASE
    ldr r1, =exercise5TxFrameBuffer
    bl uartSendBuffer

    ldr r0, =UART4_BASE
    bl waitForAckOrNakWithTimeout
    ldr r1, =exercise5LastAckResult
    str r0, [r1]

    cmp r0, #ACK_WAIT_ACK
    beq exercise5RunTransmitterRole_ack

    bl flashAllLedsThreeTimes
    ldr r0, =exercise5CounterValue
    movs r1, #0
    str r1, [r0]
    movs r0, #0
    bl displayCounterOnLeds
    b exercise5RunTransmitterRole_loop

exercise5RunTransmitterRole_ack:
    ldr r3, =exercise5CounterValue
    ldr r0, [r3]
    adds r0, r0, #1
    ldr r1, =COUNTER_DECIMAL_WRAP
    cmp r0, r1
    blo exercise5RunTransmitterRole_storeCounter
    movs r0, #0

exercise5RunTransmitterRole_storeCounter:
    str r0, [r3]
    bl displayCounterOnLeds
    b exercise5RunTransmitterRole_loop
.size exercise5RunTransmitterRole, . - exercise5RunTransmitterRole

/* Purpose: Exercise 5 receiver loop with frame and payload validation.
 * Inputs: none
 * Outputs: none (infinite loop)
 * Clobbers: r0-r3, lr
 * Preserved registers: r4-r11
 * Side effects: Receives frames, updates LED display, and sends ACK/NAK replies.
 * Test idea: Send malformed payload and verify NAK + flash path.
 */
.type exercise5RunReceiverRole, %function
.thumb_func
exercise5RunReceiverRole:
exercise5RunReceiverRole_loop:
    ldr r0, =UART4_BASE
    ldr r1, =exercise5RxFrameBuffer
    ldr r2, =exercise5RxPayloadBuffer
    bl uartReceiveFramedMessage

    ldr r0, =exercise5LastReceiveStatus
    str r3, [r0]

    cmp r3, #UART_STATUS_OK
    bne exercise5RunReceiverRole_invalid

    ldr r1, =exercise5RxPayloadBuffer
    bl parseCounterAsciiMessage

    ldr r1, =exercise5LastParseOk
    str r0, [r1]

    cmp r0, #1
    bne exercise5RunReceiverRole_invalid

    ldr r1, =exercise5CounterValue
    str r2, [r1]

    mov r0, r2
    bl displayCounterOnLeds

    ldr r0, =UART4_BASE
    bl uartSendAckMessage
    b exercise5RunReceiverRole_loop

exercise5RunReceiverRole_invalid:
    bl flashAllLedsThreeTimes
    ldr r0, =UART4_BASE
    bl uartSendNakMessage
    b exercise5RunReceiverRole_loop
.size exercise5RunReceiverRole, . - exercise5RunReceiverRole
