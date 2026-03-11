#ifndef EXERCISE5_S
#define EXERCISE5_S

#include "definitions.s"

.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

.global exercise5Entry
.global exercise5RunTransmitterRole
.global exercise5RunReceiverRole
.global buildCounterAsciiMessage
.global parseCounterAsciiMessage
.global flashAllLedsThreeTimes
.global waitForAckOrNakWithTimeout
.global displayCounterOnLeds

.section .rodata.exercise5, "a", %progbits
.align 4
ex5_counter_prefix:
    .ascii "COUNTER = "

.section .bss.exercise5, "aw", %nobits
.align 4
ex5_counter_value:
    .word 0
ex5_last_ack_result:
    .word 0
ex5_last_rx_status:
    .word 0
ex5_last_parse_ok:
    .word 0
ex5_tx_payload_buffer:
    .space 20
ex5_tx_frame_buffer:
    .space MAX_FRAME_BYTES
ex5_rx_frame_buffer:
    .space MAX_FRAME_BYTES
ex5_rx_payload_buffer:
    .space (MAX_PAYLOAD_BYTES + 1)
ex5_ack_frame_buffer:
    .space MAX_FRAME_BYTES

.section .text.exercise5, "ax", %progbits
.align 2

/* Purpose: Exercise 5 integration entry with compile-time TX/RX role selection.
 * Inputs: none
 * Outputs: none (never returns)
 * Clobbers: r0-r3, lr
 * Preserves: r4-r11
 * Test: Set EX5_ACTIVE_ROLE and verify selected role executes.
 */
.type exercise5Entry, %function
.thumb_func
exercise5Entry:
    bl uart4Init

    movs r0, #EX5_ACTIVE_ROLE
    cmp r0, #EX5_ROLE_TX
    beq exercise5Entry_run_tx
    cmp r0, #EX5_ROLE_RX
    beq exercise5Entry_run_rx
    b ledErrorLoop

exercise5Entry_run_tx:
    b exercise5RunTransmitterRole

exercise5Entry_run_rx:
    b exercise5RunReceiverRole
.size exercise5Entry, . - exercise5Entry

/* Purpose: Run Exercise 5 transmitter workflow with ACK/NAK handling.
 * Inputs: none
 * Outputs: none (infinite loop)
 * Clobbers: r0-r3, lr
 * Preserves: r4-r11
 * Test: Connect to RX board and observe counter advance/reset behaviour.
 */
.type exercise5RunTransmitterRole, %function
.thumb_func
exercise5RunTransmitterRole:
    ldr r0, =ex5_counter_value
    movs r1, #0
    str r1, [r0]

exercise5RunTransmitterRole_loop:
    ldr r1, =EX5_MESSAGE_PERIOD_US
    bl delayUsTimer

    ldr r3, =ex5_counter_value
    ldr r0, [r3]
    ldr r1, =ex5_tx_payload_buffer
    bl buildCounterAsciiMessage

    ldr r0, =ex5_tx_payload_buffer
    ldr r1, =ex5_tx_frame_buffer
    bl buildFramedMessage

    ldr r0, =UART4_BASE
    ldr r1, =ex5_tx_frame_buffer
    bl uartSendBuffer

    ldr r0, =UART4_BASE
    bl waitForAckOrNakWithTimeout
    ldr r1, =ex5_last_ack_result
    str r0, [r1]

    cmp r0, #ACK_WAIT_ACK
    beq exercise5RunTransmitterRole_ack

    bl flashAllLedsThreeTimes
    ldr r0, =ex5_counter_value
    movs r1, #0
    str r1, [r0]
    movs r0, #0
    bl displayCounterOnLeds
    b exercise5RunTransmitterRole_loop

exercise5RunTransmitterRole_ack:
    ldr r3, =ex5_counter_value
    ldr r0, [r3]
    adds r0, r0, #1
    ldr r1, =1000
    cmp r0, r1
    blo exercise5RunTransmitterRole_store_counter
    movs r0, #0

exercise5RunTransmitterRole_store_counter:
    str r0, [r3]
    bl displayCounterOnLeds
    b exercise5RunTransmitterRole_loop
.size exercise5RunTransmitterRole, . - exercise5RunTransmitterRole

/* Purpose: Run Exercise 5 receiver workflow with frame and payload validation.
 * Inputs: none
 * Outputs: none (infinite loop)
 * Clobbers: r0-r3, lr
 * Preserves: r4-r11
 * Test: Send valid/invalid COUNTER frames and verify ACK/NAK responses.
 */
.type exercise5RunReceiverRole, %function
.thumb_func
exercise5RunReceiverRole:
exercise5RunReceiverRole_loop:
    ldr r0, =UART4_BASE
    ldr r1, =ex5_rx_frame_buffer
    ldr r2, =ex5_rx_payload_buffer
    bl uartReceiveFramedMessage

    ldr r0, =ex5_last_rx_status
    str r3, [r0]

    cmp r3, #UART_STATUS_OK
    bne exercise5RunReceiverRole_invalid

    ldr r1, =ex5_rx_payload_buffer
    bl parseCounterAsciiMessage

    ldr r1, =ex5_last_parse_ok
    str r0, [r1]

    cmp r0, #1
    bne exercise5RunReceiverRole_invalid

    ldr r1, =ex5_counter_value
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

/* Purpose: Build payload string "COUNTER = XXX" with fixed 3-digit decimal value.
 * Inputs: r0 = counter value, r1 = destination buffer
 * Outputs: r2 = payload length (13 bytes, excluding NUL)
 * Clobbers: r0-r3, r12
 * Preserves: r4-r11, lr
 * Test: For input 7, output should be "COUNTER = 007".
 */
.type buildCounterAsciiMessage, %function
.thumb_func
buildCounterAsciiMessage:
    /* Reduce to 0..999. */
    ldr r3, =1000
    udiv r2, r0, r3
    mul r2, r2, r3
    subs r0, r0, r2

    /* Copy 10-byte prefix. */
    ldr r3, =ex5_counter_prefix
    ldrb r2, [r3]
    strb r2, [r1]
    ldrb r2, [r3, #1]
    strb r2, [r1, #1]
    ldrb r2, [r3, #2]
    strb r2, [r1, #2]
    ldrb r2, [r3, #3]
    strb r2, [r1, #3]
    ldrb r2, [r3, #4]
    strb r2, [r1, #4]
    ldrb r2, [r3, #5]
    strb r2, [r1, #5]
    ldrb r2, [r3, #6]
    strb r2, [r1, #6]
    ldrb r2, [r3, #7]
    strb r2, [r1, #7]
    ldrb r2, [r3, #8]
    strb r2, [r1, #8]
    ldrb r2, [r3, #9]
    strb r2, [r1, #9]

    /* Hundreds digit. */
    movs r3, #100
    udiv r12, r0, r3
    mul r2, r12, r3
    subs r0, r0, r2
    adds r12, r12, #ASCII_ZERO
    strb r12, [r1, #10]

    /* Tens digit. */
    movs r3, #10
    udiv r12, r0, r3
    mul r2, r12, r3
    subs r0, r0, r2
    adds r12, r12, #ASCII_ZERO
    strb r12, [r1, #11]

    /* Ones digit. */
    adds r0, r0, #ASCII_ZERO
    strb r0, [r1, #12]

    movs r0, #ASCII_NUL
    strb r0, [r1, #13]

    movs r2, #13
    bx lr
.size buildCounterAsciiMessage, . - buildCounterAsciiMessage

/* Purpose: Parse payload string "COUNTER = XXX" into numeric value.
 * Inputs: r1 = payload pointer (NUL-terminated)
 * Outputs: r0 = 1 valid / 0 invalid, r2 = parsed value if valid
 * Clobbers: r2-r3, r12
 * Preserves: r1, r4-r11, lr
 * Test: "COUNTER = 123" -> r0=1,r2=123; malformed strings -> r0=0.
 */
.type parseCounterAsciiMessage, %function
.thumb_func
parseCounterAsciiMessage:
    ldrb r3, [r1]
    cmp r3, #0x43          /* C */
    bne parseCounterAsciiMessage_invalid
    ldrb r3, [r1, #1]
    cmp r3, #0x4F          /* O */
    bne parseCounterAsciiMessage_invalid
    ldrb r3, [r1, #2]
    cmp r3, #0x55          /* U */
    bne parseCounterAsciiMessage_invalid
    ldrb r3, [r1, #3]
    cmp r3, #0x4E          /* N */
    bne parseCounterAsciiMessage_invalid
    ldrb r3, [r1, #4]
    cmp r3, #0x54          /* T */
    bne parseCounterAsciiMessage_invalid
    ldrb r3, [r1, #5]
    cmp r3, #0x45          /* E */
    bne parseCounterAsciiMessage_invalid
    ldrb r3, [r1, #6]
    cmp r3, #0x52          /* R */
    bne parseCounterAsciiMessage_invalid
    ldrb r3, [r1, #7]
    cmp r3, #0x20          /* space */
    bne parseCounterAsciiMessage_invalid
    ldrb r3, [r1, #8]
    cmp r3, #0x3D          /* = */
    bne parseCounterAsciiMessage_invalid
    ldrb r3, [r1, #9]
    cmp r3, #0x20          /* space */
    bne parseCounterAsciiMessage_invalid

    movs r2, #0

    ldrb r3, [r1, #10]
    cmp r3, #ASCII_ZERO
    blo parseCounterAsciiMessage_invalid
    cmp r3, #ASCII_NINE
    bhi parseCounterAsciiMessage_invalid
    subs r3, r3, #ASCII_ZERO
    movs r12, #100
    mul r3, r3, r12
    adds r2, r2, r3

    ldrb r3, [r1, #11]
    cmp r3, #ASCII_ZERO
    blo parseCounterAsciiMessage_invalid
    cmp r3, #ASCII_NINE
    bhi parseCounterAsciiMessage_invalid
    subs r3, r3, #ASCII_ZERO
    movs r12, #10
    mul r3, r3, r12
    adds r2, r2, r3

    ldrb r3, [r1, #12]
    cmp r3, #ASCII_ZERO
    blo parseCounterAsciiMessage_invalid
    cmp r3, #ASCII_NINE
    bhi parseCounterAsciiMessage_invalid
    subs r3, r3, #ASCII_ZERO
    adds r2, r2, r3

    ldrb r3, [r1, #13]
    cmp r3, #ASCII_NUL
    bne parseCounterAsciiMessage_invalid

    movs r0, #1
    bx lr

parseCounterAsciiMessage_invalid:
    movs r0, #0
    movs r2, #0
    bx lr
.size parseCounterAsciiMessage, . - parseCounterAsciiMessage

/* Purpose: Flash all LEDs three times with 0.5 second on/off intervals.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r1, r4, lr
 * Preserves: r2-r3, r5-r11
 * Test: Trigger error path and verify 3 full flashes at configured interval.
 */
.type flashAllLedsThreeTimes, %function
.thumb_func
flashAllLedsThreeTimes:
    push {r4, lr}
    movs r4, #3

flashAllLedsThreeTimes_loop:
    movs r0, #LED_ALL_MASK
    bl setLedBitmask
    ldr r1, =EX5_FLASH_INTERVAL_US
    bl delayUsTimer

    movs r0, #0
    bl setLedBitmask
    ldr r1, =EX5_FLASH_INTERVAL_US
    bl delayUsTimer

    subs r4, r4, #1
    bne flashAllLedsThreeTimes_loop
    pop {r4, pc}
.size flashAllLedsThreeTimes, . - flashAllLedsThreeTimes

/* Purpose: Wait up to 5 seconds for framed ACK/NAK reply on selected UART.
 * Inputs: r0 = UART base
 * Outputs: r0 = ACK_WAIT_ACK / ACK_WAIT_NAK / ACK_WAIT_TIMEOUT
 * Clobbers: r1-r3, r4-r8, lr
 * Preserves: r9-r11
 * Test: Send ACK frame, NAK frame, and no response to verify all paths.
 */
.type waitForAckOrNakWithTimeout, %function
.thumb_func
waitForAckOrNakWithTimeout:
    push {r4-r8, lr}
    mov r4, r0

    ldr r0, =TIM2_BASE
    ldr r5, [r0, #TIM_CNT_OFFSET]
    ldr r6, =ex5_ack_frame_buffer

waitForAckOrNakWithTimeout_wait_stx:
    ldr r1, [r4, #USART_ISR_OFFSET]
    tst r1, #USART_ISR_RXNE
    bne waitForAckOrNakWithTimeout_got_stx_byte

    ldr r0, =TIM2_BASE
    ldr r1, [r0, #TIM_CNT_OFFSET]
    subs r1, r1, r5
    ldr r2, =EX5_ACK_TIMEOUT_US
    cmp r1, r2
    blo waitForAckOrNakWithTimeout_wait_stx

    movs r0, #ACK_WAIT_TIMEOUT
    b waitForAckOrNakWithTimeout_done

waitForAckOrNakWithTimeout_got_stx_byte:
    ldrb r1, [r4, #USART_RDR_OFFSET]
    cmp r1, #STX
    bne waitForAckOrNakWithTimeout_wait_stx
    strb r1, [r6]

waitForAckOrNakWithTimeout_wait_len:
    ldr r1, [r4, #USART_ISR_OFFSET]
    tst r1, #USART_ISR_RXNE
    bne waitForAckOrNakWithTimeout_got_len

    ldr r0, =TIM2_BASE
    ldr r1, [r0, #TIM_CNT_OFFSET]
    subs r1, r1, r5
    ldr r2, =EX5_ACK_TIMEOUT_US
    cmp r1, r2
    blo waitForAckOrNakWithTimeout_wait_len

    movs r0, #ACK_WAIT_TIMEOUT
    b waitForAckOrNakWithTimeout_done

waitForAckOrNakWithTimeout_got_len:
    ldrb r1, [r4, #USART_RDR_OFFSET]
    uxtb r7, r1
    strb r1, [r6, #1]

    cmp r7, #FRAME_MIN_LENGTH
    blo waitForAckOrNakWithTimeout_nak
    cmp r7, #MAX_FRAME_BYTES
    bhi waitForAckOrNakWithTimeout_nak

    subs r8, r7, #2
    adds r2, r6, #2
waitForAckOrNakWithTimeout_read_rest:
    cmp r8, #0
    beq waitForAckOrNakWithTimeout_validate

waitForAckOrNakWithTimeout_wait_next:
    ldr r1, [r4, #USART_ISR_OFFSET]
    tst r1, #USART_ISR_RXNE
    bne waitForAckOrNakWithTimeout_got_next

    ldr r0, =TIM2_BASE
    ldr r1, [r0, #TIM_CNT_OFFSET]
    subs r1, r1, r5
    ldr r3, =EX5_ACK_TIMEOUT_US
    cmp r1, r3
    blo waitForAckOrNakWithTimeout_wait_next

    movs r0, #ACK_WAIT_TIMEOUT
    b waitForAckOrNakWithTimeout_done

waitForAckOrNakWithTimeout_got_next:
    ldrb r1, [r4, #USART_RDR_OFFSET]
    strb r1, [r2]
    adds r2, r2, #1
    subs r8, r8, #1
    b waitForAckOrNakWithTimeout_read_rest

waitForAckOrNakWithTimeout_validate:
    subs r2, r7, #2
    adds r2, r6, r2
    ldrb r1, [r2]
    cmp r1, #ETX
    bne waitForAckOrNakWithTimeout_nak

    mov r1, r6
    mov r2, r7
    bl verifyBcc
    cmp r3, #1
    bne waitForAckOrNakWithTimeout_nak

    subs r8, r7, #FRAME_MIN_LENGTH
    cmp r8, #3
    bne waitForAckOrNakWithTimeout_nak

    adds r2, r6, #2
    ldrb r1, [r2]
    cmp r1, #0x41          /* A */
    bne waitForAckOrNakWithTimeout_check_nak
    ldrb r1, [r2, #1]
    cmp r1, #0x43          /* C */
    bne waitForAckOrNakWithTimeout_nak
    ldrb r1, [r2, #2]
    cmp r1, #0x4B          /* K */
    bne waitForAckOrNakWithTimeout_nak
    movs r0, #ACK_WAIT_ACK
    b waitForAckOrNakWithTimeout_done

waitForAckOrNakWithTimeout_check_nak:
    ldrb r1, [r2]
    cmp r1, #0x4E          /* N */
    bne waitForAckOrNakWithTimeout_nak
    ldrb r1, [r2, #1]
    cmp r1, #0x41          /* A */
    bne waitForAckOrNakWithTimeout_nak
    ldrb r1, [r2, #2]
    cmp r1, #0x4B          /* K */
    bne waitForAckOrNakWithTimeout_nak
    movs r0, #ACK_WAIT_NAK
    b waitForAckOrNakWithTimeout_done

waitForAckOrNakWithTimeout_nak:
    movs r0, #ACK_WAIT_NAK

waitForAckOrNakWithTimeout_done:
    pop {r4-r8, pc}
.size waitForAckOrNakWithTimeout, . - waitForAckOrNakWithTimeout

/* Purpose: Display low 8 bits of counter value on board LEDs.
 * Inputs: r0 = counter value
 * Outputs: none
 * Clobbers: r0, lr
 * Preserves: r1-r11
 * Test: Call with 0x5A and verify LED binary pattern matches.
 */
.type displayCounterOnLeds, %function
.thumb_func
displayCounterOnLeds:
    ands r0, r0, #LED_ALL_MASK
    b setLedBitmask
.size displayCounterOnLeds, . - displayCounterOnLeds

#endif /* EXERCISE5_S */
