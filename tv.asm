; h.asm

extern printf

section .data
	SLEEP			equ	0x23
	IOCTL			equ	0x10

	ECHO			equ	0x8
	ICANON			equ	0x2

	TCGETS			equ	0x5401
	TCSETS			equ	0x5402

	STDIN			equ	0x00

	fd_set			dd	0x00

	pollfd:
		fd		dd	0x00
		events		dw	0x01
		revents		dw	0x00

	WRITE		equ	0x01

	HOME_SEQ	db	0x1b, "[H"
	HOME_LEN	equ	$ - HOME_SEQ
	CLSC_SEQ	db	0x1b, "[2J"
	CLSC_LEN	equ	$ - CLSC_SEQ

	empty_pixel	db	"."
	filled_pixel	db	"0"
	pixel_len	equ	$ - filled_pixel

section .bss
	content			resb	4
	char			resb	1
	sigaction:
		sa_handler	resq	1
		sa_sigaction	resq	1
		sa_mask		resq	1
		sa_flags	resq	1
		sa_restorer	resq	1

	canon_terminal:
		ciflag		resb	4
		coflag		resb	4
		ccflag		resb	4
		slflag		resb	4
		srest		resb	44
	noncan_terminal:
		iflag		resb	4
		oflag		resb	4
		cflag		resb	4
		lflag		resb	4
		nrest		resb	44
	MVCR_SEQ	resb	10	; 0x1b, "[%d;%dH", 0x00
	MVCR_LEN	resq	1
	divisor		resq	1

section .text
	global		setcanon
	global		setnoncan
	global 		clear_screen
	global		move_cursor
	global		main

setnoncan:
	push	rbp
	mov	rbp, rsp

	mov	rax, IOCTL
	mov	rdi, STDIN
	mov	rsi, TCGETS
	mov	rdx, canon_terminal
	syscall

	mov	rax, IOCTL
	mov	rdi, STDIN
	mov	rsi, TCGETS
	mov	rdx, noncan_terminal
	syscall

	and	dword[lflag], (~ECHO)
	and	dword[lflag], (~ICANON)

	mov	rax, IOCTL
	mov	rdi, STDIN
	mov	rsi, TCSETS
	mov	rdx, noncan_terminal
	syscall

	mov	rsp, rbp
	pop	rbp
	ret

setcanon:
	push	rbp
	mov	rbp, rsp

	mov	rax, IOCTL
	mov	rdi, STDIN
	mov	rsi, TCSETS
	mov	rdx, canon_terminal
	syscall

	mov	rsp, rbp
	pop	rbp
	ret

move_cursor:
	push	rbp
	mov	rbp, rsp

	mov	byte[MVCR_SEQ], 0x1b		; <ESC>
	mov	byte[MVCR_SEQ+1], 0x5b		; '['

	push	rsi				; Columns number
	mov	qword[divisor], 0x0a

	xor	rdx, rdx			; Fill the line number
	mov	rax, rdi			; Divide to 10
	idiv	qword[divisor]			; Leftovers to string
	add	rdx, 0x30			; Adding 0x30 makes a char from num
	mov	byte[MVCR_SEQ+4], dl

	xor	rdx, rdx
	idiv	qword[divisor]
	add	rdx, 0x30
	mov	byte[MVCR_SEQ+3], dl


	xor	rdx, rdx
	idiv	qword[divisor]
	add	rdx, 0x30
	mov	byte[MVCR_SEQ+2], dl

	mov	byte[MVCR_SEQ+5], 0x3b		; Put the ';'

	xor	rdx, rdx			; Fill the column number
	pop	rax				; Similar scheme
	idiv	qword[divisor]
	add	rdx, 0x30
	mov	byte[MVCR_SEQ+8], dl

	xor	rdx, rdx
	idiv	qword[divisor]
	add	rdx, 0x30
	mov	byte[MVCR_SEQ+7], dl

	xor	rdx, rdx
	idiv	qword[divisor]
	add	rdx, 0x30
	mov	byte[MVCR_SEQ+6], dl

	mov	byte[MVCR_SEQ+9], 0x48		; Put the 'H'
	mov	byte[MVCR_SEQ+10], 0x00		; Put the EOL

	mov	rax, WRITE			; Write
	mov	rdi, 0x01			; move_cursor
	mov	rsi, MVCR_SEQ			; command
	mov	rdx, 0x0a
	syscall

	mov	rsp, rbp
	pop	rbp
	ret

clear_screen:
	push	rbp
	mov 	rbp, rsp

	mov	rax, WRITE
	mov  	rdi, 0x01
	mov  	rsi, HOME_SEQ
	mov  	rdx, HOME_LEN
	syscall

	mov  	rax, WRITE
	mov  	rdi, 0x01
	mov  	rsi, CLSC_SEQ
	mov  	rdx, CLSC_LEN
	syscall

	mov  	rsp, rbp
	pop  	rbp
	ret

main:
	push rbp
	mov rbp, rsp

	call	setnoncan

	call	clear_screen

	mov	rax, 0x00
	mov	rsi, 0x00
	call	move_cursor

	mov	rax, WRITE
	mov	rdi, 0x01
	mov	rsi, empty_pixel
	mov	rdx, pixel_len
	syscall

	mov	eax, 0x02
	mov	

	mov rsp, rbp
	pop rbp
	ret
