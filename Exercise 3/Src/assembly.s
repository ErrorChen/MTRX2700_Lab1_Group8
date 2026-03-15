.syntax unified
.thumb

.global main
.thumb_func

.type main, %function

#include "initialise.s"

.data
.align

tx_packet: .byte 0x02, 0x09, 'H', 'E', 'L', 'L', 'O', 0x03, 0x4A
tx_packet_len: .word 9

ack_packet: .byte 'A', 'C', 'K'
ack_packet_len: .word 3

nak_packet: .byte 'N', 'A', 'K'
nak_packet_len: .word 3

.bss
.align

rx_raw_buffer: .space 64

rx_string_buffer: .space 64

.text

main:
    BL initialise_power
    BL change_clock_speed
    BL enable_peripheral_clocks
    BL enable_uart

main_loop:
    BL button_press_tx
    BL uart_try_receive_packet
    B  main_loop

button_press_tx:
    PUSH {R4, LR}

    LDR R4, =GPIOA
    LDR R3, [R4, #GPIO_IDR]
    TST R3, #1
    BEQ button_not_pressed

    LDR R1, =tx_packet
    LDR R2, =tx_packet_len
    LDR R2, [R2]
    BL uart_tx_buffer

wait_release:
    LDR R3, [R4, #GPIO_IDR]
    TST R3, #1
    BNE wait_release

button_not_pressed:
    POP {R4, LR}
    BX LR

uart_tx_buffer:
    PUSH {R4-R6, LR}

    LDR R4, =UART
    MOV R5, R1
    MOV R6, R2

tx_loop:
    CMP R6, #0
    BEQ tx_done

wait_txe:
    LDR R3, [R4, #USART_ISR]
    TST R3, #(1 << UART_TXE)
    BEQ wait_txe

    LDRB R0, [R5], #1
    STRB R0, [R4, #USART_TDR]

    SUB R6, R6, #1
    B   tx_loop

tx_done:
    POP {R4-R6, LR}
    BX LR

uart_try_receive_packet:
    PUSH {R4-R7, LR}

    LDR R4, =UART
    LDR R5, [R4, #USART_ISR]
    TST R5, #(1 << UART_RXNE)
    BEQ rx_try_done

    LDR R1, =rx_raw_buffer
    LDR R2, =rx_string_buffer
    BL uart_rx_packet_validate

    CMP R3, #1
    BEQ send_ack_now

send_nak_now:
    LDR R1, =nak_packet
    LDR R2, =nak_packet_len
    LDR R2, [R2]
    BL uart_tx_buffer
    B rx_try_done

send_ack_now:
    LDR R1, =ack_packet
    LDR R2, =ack_packet_len
    LDR R2, [R2]
    BL uart_tx_buffer

rx_try_done:
    POP {R4-R7, LR}
    BX LR

uart_rx_packet_validate:
    PUSH {R4-R12, LR}

    MOV R8, R1
    MOV R9, R2

    BL uart_rx_byte_blocking
    STRB R0, [R8]
    CMP R0, #0x02
    BNE rx_invalid

    BL uart_rx_byte_blocking
    STRB R0, [R8, #1]
    MOV R10, R0

    CMP R10, #5
    BLT rx_invalid

    CMP R10, #64
    BGT rx_invalid

    SUB R11, R10, #2
    MOV R12, #2

rx_read_rest:
    CMP R11, #0
    BEQ rx_read_complete

    BL uart_rx_byte_blocking
    STRB R0, [R8, R12]
    ADD R12, R12, #1
    SUB R11, R11, #1
    B   rx_read_rest

rx_read_complete:
    SUB R4, R10, #2
    LDRB R5, [R8, R4]
    CMP R5, #0x03
    BNE rx_invalid

    MOV R1, R8
    MOV R2, R10
    BL bcc_verify_zero
    CMP R3, #1
    BNE rx_invalid

    MOV R4, #2
    MOV R5, #0
    SUB R6, R10, #2

    MOV R7, #0

rx_copy_body:
    CMP R4, R6
    BGE rx_copy_done

    LDRB R0, [R8, R4]
    STRB R0, [R9, R5]

    CMP R0, #0
    BEQ rx_found_nul

    ADD R4, R4, #1
    ADD R5, R5, #1
    B   rx_copy_body

rx_found_nul:
    MOV R7, #1
    B   rx_copy_done

rx_copy_done:
    CMP R7, #1
    BNE rx_invalid

    MOV R3, #1
    B   rx_finish

rx_invalid:
    MOV R3, #0

rx_finish:
    POP {R4-R12, LR}
    BX LR

uart_rx_byte_blocking:
    PUSH {R4, LR}
    LDR R4, =UART

rx_wait:
    LDR R1, [R4, #USART_ISR]

    TST R1, #(1 << UART_ORE)
    BNE rx_clear_error
    TST R1, #(1 << UART_FE)
    BNE rx_clear_error

    TST R1, #(1 << UART_RXNE)
    BEQ rx_wait

    LDRB R0, [R4, #USART_RDR]
    B rx_done

rx_clear_error:
    LDR R1, [R4, #USART_ICR]
    ORR R1, R1, #(1 << UART_ORECF)
    ORR R1, R1, #(1 << UART_FECF)
    STR R1, [R4, #USART_ICR]
    B rx_wait

rx_done:
    POP {R4, LR}
    BX LR

bcc_verify_zero:
    PUSH {R4-R6, LR}

    MOV R4, R1
    MOV R5, R2
    MOV R6, #0

bcc_loop:
    CMP R5, #0
    BEQ bcc_done

    LDRB R0, [R4], #1
    EOR R6, R6, R0
    SUB R5, R5, #1
    B   bcc_loop

bcc_done:
    CMP R6, #0
    BNE bcc_invalid
    MOV R3, #1
    B bcc_finish

bcc_invalid:
    MOV R3, #0

bcc_finish:
    POP {R4-R6, LR}
    BX LR
