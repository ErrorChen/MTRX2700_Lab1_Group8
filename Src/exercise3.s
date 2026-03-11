#ifndef EXERCISE3_S
#define EXERCISE3_S

#include "definitions.s"

.syntax unified
.cpu cortex-m4
.fpu fpv4-sp-d16
.thumb

.global exercise3Entry
.global uart4Init
.global uart5Init
.global uartSendBuffer
.global uartReadByteBlocking
.global uartReceiveFramedMessage
.global uartSendAckMessage
.global uartSendNakMessage
.global computeUartBrrFromClock

.section .rodata.exercise3, "a", %progbits
.align 4
ex3_demo_payload:
    .asciz "UART4 TO UART5 DEMO"
ex3_ack_payload:
    .asciz "ACK"
ex3_nak_payload:
    .asciz "NAK"

.section .bss.exercise3, "aw", %nobits
.align 4
ex3_last_status:
    .word 0
ex3_last_payload_length:
    .word 0
ex3_last_frame_length:
    .word 0
ex3_tx_frame_buffer:
    .space MAX_FRAME_BYTES
ex3_rx_frame_buffer:
    .space MAX_FRAME_BYTES
ex3_payload_buffer:
    .space (MAX_PAYLOAD_BYTES + 1)

.section .text.exercise3, "ax", %progbits
.align 2

/* Purpose: Exercise 3 demonstration entry for UART framing and validation.
 * Inputs: none
 * Outputs: none (infinite loop)
 * Clobbers: r0-r4, lr
 * Preserves: r5-r11
 * Test: Press button to TX frame on UART4, RX/validate on UART5, then ACK/NAK.
 */
.type exercise3Entry, %function
.thumb_func
exercise3Entry:
    push {r4, lr}
    bl uart4Init
    bl uart5Init

exercise3_loop:
    bl waitForButtonPressDebounced

    ldr r0, =ex3_demo_payload
    ldr r1, =ex3_tx_frame_buffer
    bl buildFramedMessage
    ldr r4, =ex3_last_frame_length
    str r2, [r4]

    ldr r0, =UART4_BASE
    ldr r1, =ex3_tx_frame_buffer
    bl uartSendBuffer

    ldr r0, =UART5_BASE
    ldr r1, =ex3_rx_frame_buffer
    ldr r2, =ex3_payload_buffer
    bl uartReceiveFramedMessage

    cmp r3, #UART_STATUS_OK
    bne exercise3_send_nak

    ldr r0, =UART5_BASE
    bl uartSendAckMessage
    movs r0, #0xA5
    bl setLedBitmask
    b exercise3_loop

exercise3_send_nak:
    ldr r0, =UART5_BASE
    bl uartSendNakMessage
    movs r0, #0x3C
    bl setLedBitmask
    b exercise3_loop
.size exercise3Entry, . - exercise3Entry

/* Purpose: Initialise UART4 for polling-based 8N1 communication.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r3, lr
 * Preserves: r4-r11
 * Test: Observe BRR/CR1 registers and successful byte transmission.
 */
.type uart4Init, %function
.thumb_func
uart4Init:
    push {lr}
    bl initialiseUartGpioPins

    ldr r0, =RCC_BASE
    ldr r1, [r0, #RCC_APB1ENR_OFFSET]
    ldr r2, =(RCC_APB1ENR_UART4EN | RCC_APB1ENR_UART5EN)
    orrs r1, r1, r2
    str r1, [r0, #RCC_APB1ENR_OFFSET]

    ldr r0, =UART4_BASE
    ldr r1, =APB1_CLOCK_HZ
    ldr r2, =UART_DEFAULT_BAUD
    bl computeUartBrrFromClock
    str r3, [r0, #USART_BRR_OFFSET]

    ldr r1, =(USART_CR1_UE | USART_CR1_TE | USART_CR1_RE)
    str r1, [r0, #USART_CR1_OFFSET]
    pop {pc}
.size uart4Init, . - uart4Init

/* Purpose: Initialise UART5 for polling-based 8N1 communication.
 * Inputs: none
 * Outputs: none
 * Clobbers: r0-r3, lr
 * Preserves: r4-r11
 * Test: Loopback with UART4 and confirm received data integrity.
 */
.type uart5Init, %function
.thumb_func
uart5Init:
    push {lr}
    bl initialiseUartGpioPins

    ldr r0, =RCC_BASE
    ldr r1, [r0, #RCC_APB1ENR_OFFSET]
    ldr r2, =(RCC_APB1ENR_UART4EN | RCC_APB1ENR_UART5EN)
    orrs r1, r1, r2
    str r1, [r0, #RCC_APB1ENR_OFFSET]

    ldr r0, =UART5_BASE
    ldr r1, =APB1_CLOCK_HZ
    ldr r2, =UART_DEFAULT_BAUD
    bl computeUartBrrFromClock
    str r3, [r0, #USART_BRR_OFFSET]

    ldr r1, =(USART_CR1_UE | USART_CR1_TE | USART_CR1_RE)
    str r1, [r0, #USART_CR1_OFFSET]
    pop {pc}
.size uart5Init, . - uart5Init

/* Purpose: Send buffer over selected UART using polling.
 * Inputs: r0 = UART base, r1 = buffer pointer, r2 = length
 * Outputs: none
 * Clobbers: r1-r4
 * Preserves: r0, r5-r11, lr
 * Test: Send known frame and capture bytes with logic analyzer/UART terminal.
 */
.type uartSendBuffer, %function
.thumb_func
uartSendBuffer:
    push {r4, lr}
    mov r4, r2

uartSendBuffer_loop:
    cmp r4, #0
    beq uartSendBuffer_wait_tc

uartSendBuffer_wait_txe:
    ldr r3, [r0, #USART_ISR_OFFSET]
    tst r3, #USART_ISR_TXE
    beq uartSendBuffer_wait_txe

    ldrb r3, [r1]
    strb r3, [r0, #USART_TDR_OFFSET]
    adds r1, r1, #1
    subs r4, r4, #1
    b uartSendBuffer_loop

uartSendBuffer_wait_tc:
    ldr r3, [r0, #USART_ISR_OFFSET]
    tst r3, #USART_ISR_TC
    beq uartSendBuffer_wait_tc

    pop {r4, pc}
.size uartSendBuffer, . - uartSendBuffer

/* Purpose: Receive one byte from selected UART using blocking polling.
 * Inputs: r0 = UART base
 * Outputs: r1 = received byte
 * Clobbers: r2
 * Preserves: r0, r3-r11, lr
 * Test: Inject known byte stream and confirm sequential reads.
 */
.type uartReadByteBlocking, %function
.thumb_func
uartReadByteBlocking:
uartReadByteBlocking_wait:
    ldr r2, [r0, #USART_ISR_OFFSET]
    tst r2, #USART_ISR_RXNE
    beq uartReadByteBlocking_wait

    ldrb r1, [r0, #USART_RDR_OFFSET]
    bx lr
.size uartReadByteBlocking, . - uartReadByteBlocking

/* Purpose: Receive and validate framed message, then decode payload string.
 * Inputs: r0 = UART base, r1 = frame scratch buffer, r2 = payload destination
 * Outputs: r3 = status code (UART_STATUS_*)
 * Clobbers: r0-r3, r4-r8, lr
 * Preserves: r9-r11
 * Test: Feed valid/invalid frames and verify status and decoded payload.
 */
.type uartReceiveFramedMessage, %function
.thumb_func
uartReceiveFramedMessage:
    push {r4-r8, lr}
    mov r4, r0
    mov r5, r1
    mov r6, r2

    /* Sync to STX. */
uartReceiveFramedMessage_wait_stx:
    mov r0, r4
    bl uartReadByteBlocking
    cmp r1, #STX
    bne uartReceiveFramedMessage_wait_stx
    strb r1, [r5]

    /* Length byte. */
    mov r0, r4
    bl uartReadByteBlocking
    uxtb r7, r1
    strb r1, [r5, #1]

    cmp r7, #FRAME_MIN_LENGTH
    blo uartReceiveFramedMessage_length_error
    cmp r7, #MAX_FRAME_BYTES
    bhi uartReceiveFramedMessage_length_error

    /* Read remaining LEN-2 bytes into scratch. */
    subs r8, r7, #2
    adds r2, r5, #2
uartReceiveFramedMessage_read_rest:
    cmp r8, #0
    beq uartReceiveFramedMessage_read_done

    mov r0, r4
    bl uartReadByteBlocking
    strb r1, [r2]
    adds r2, r2, #1
    subs r8, r8, #1
    b uartReceiveFramedMessage_read_rest
uartReceiveFramedMessage_read_done:

    /* ETX location: frame[len - 2]. */
    subs r2, r7, #2
    adds r2, r5, r2
    ldrb r0, [r2]
    cmp r0, #ETX
    bne uartReceiveFramedMessage_etx_error

    mov r1, r5
    mov r2, r7
    bl verifyBcc
    cmp r3, #1
    bne uartReceiveFramedMessage_bcc_error

    /* Decode payload into destination and append NUL. */
    subs r8, r7, #FRAME_MIN_LENGTH
    cmp r8, #MAX_PAYLOAD_BYTES
    bhi uartReceiveFramedMessage_payload_error

    adds r1, r5, #2
    mov r2, r6
    mov r0, r8
uartReceiveFramedMessage_copy_payload:
    cmp r0, #0
    beq uartReceiveFramedMessage_copy_done
    ldrb r12, [r1]
    cmp r12, #ASCII_NUL
    beq uartReceiveFramedMessage_payload_error
    strb r12, [r2]
    adds r1, r1, #1
    adds r2, r2, #1
    subs r0, r0, #1
    b uartReceiveFramedMessage_copy_payload
uartReceiveFramedMessage_copy_done:
    movs r12, #ASCII_NUL
    strb r12, [r2]

    ldr r0, =ex3_last_payload_length
    str r8, [r0]
    ldr r0, =ex3_last_frame_length
    str r7, [r0]

    movs r3, #UART_STATUS_OK
    b uartReceiveFramedMessage_store_status

uartReceiveFramedMessage_length_error:
    movs r3, #UART_STATUS_LENGTH_ERROR
    b uartReceiveFramedMessage_store_status

uartReceiveFramedMessage_etx_error:
    movs r3, #UART_STATUS_ETX_ERROR
    b uartReceiveFramedMessage_store_status

uartReceiveFramedMessage_bcc_error:
    movs r3, #UART_STATUS_BCC_ERROR
    b uartReceiveFramedMessage_store_status

uartReceiveFramedMessage_payload_error:
    movs r3, #UART_STATUS_PAYLOAD_ERROR

uartReceiveFramedMessage_store_status:
    ldr r0, =ex3_last_status
    str r3, [r0]
    pop {r4-r8, pc}
.size uartReceiveFramedMessage, . - uartReceiveFramedMessage

/* Purpose: Send framed ACK payload on selected UART.
 * Inputs: r0 = UART base
 * Outputs: none
 * Clobbers: r0-r2, r4, lr
 * Preserves: r5-r11
 * Test: Inspect outgoing frame contains ACK payload and valid checksum.
 */
.type uartSendAckMessage, %function
.thumb_func
uartSendAckMessage:
    push {r4, lr}
    mov r4, r0

    ldr r0, =ex3_ack_payload
    ldr r1, =ex3_tx_frame_buffer
    bl buildFramedMessage

    mov r0, r4
    ldr r1, =ex3_tx_frame_buffer
    bl uartSendBuffer
    pop {r4, pc}
.size uartSendAckMessage, . - uartSendAckMessage

/* Purpose: Send framed NAK payload on selected UART.
 * Inputs: r0 = UART base
 * Outputs: none
 * Clobbers: r0-r2, r4, lr
 * Preserves: r5-r11
 * Test: Inspect outgoing frame contains NAK payload and valid checksum.
 */
.type uartSendNakMessage, %function
.thumb_func
uartSendNakMessage:
    push {r4, lr}
    mov r4, r0

    ldr r0, =ex3_nak_payload
    ldr r1, =ex3_tx_frame_buffer
    bl buildFramedMessage

    mov r0, r4
    ldr r1, =ex3_tx_frame_buffer
    bl uartSendBuffer
    pop {r4, pc}
.size uartSendNakMessage, . - uartSendNakMessage

/* Purpose: Compute USART BRR value from peripheral clock and baud rate.
 * Inputs: r1 = peripheral clock Hz, r2 = desired baud
 * Outputs: r3 = BRR register value
 * Clobbers: r0-r1
 * Preserves: r2, r4-r11, lr
 * Test: Compare BRR against manual calculation for known clocks/bauds.
 */
.type computeUartBrrFromClock, %function
.thumb_func
computeUartBrrFromClock:
    cmp r2, #0
    beq computeUartBrrFromClock_zero

    lsrs r0, r2, #1
    adds r1, r1, r0
    udiv r3, r1, r2
    bx lr

computeUartBrrFromClock_zero:
    movs r3, #0
    bx lr
.size computeUartBrrFromClock, . - computeUartBrrFromClock

#endif /* EXERCISE3_S */
