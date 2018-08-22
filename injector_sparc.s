	.file	"injector_sparc.c"
	.common	packet_buffer,4,4
	.common	packet,4,4
	.common	result,4,4
	.common	ins,8,4
	.global search_range
	.section	".data"
	.align 4
	.type	search_range, #object
	.size	search_range, 20
search_range:
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.long	0
	.byte	-1
	.byte	-1
	.byte	-1
	.byte	-1
	.long	0
	.byte	0
	.skip	3
	.section	".text"
	.align 4
	.global initialize
	.type	initialize, #function
	.proc	020
initialize:
	save	%sp, -96, %sp
	nop
	restore
	jmp	%o7+8
	 nop
	.size	initialize, .-initialize
	.align 4
	.global postamble
	.type	postamble, #function
	.proc	020
postamble:
	save	%sp, -96, %sp
! 81 "injector_sparc.c" 1
	  			.global postamble_start                    
  			postamble_start:                           
			sethi %hi(resume), %g1                   
	                or %g1, %lo(resume), %g1		   
  			jmp %g1                                   
  			nop                                        
  			.global postamble_end                      
  			postamble_end:                             
  			
! 0 "" 2
	nop
	restore
	jmp	%o7+8
	 nop
	.size	postamble, .-postamble
	.section	".rodata"
	.align 8
.LLC0:
	.asciz	"%s: "
	.align 8
.LLC1:
	.asciz	" %02x"
	.section	".text"
	.align 4
	.global hexDump
	.type	hexDump, #function
	.proc	020
hexDump:
	save	%sp, -104, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	ld	[%fp+72], %g1
	st	%g1, [%fp-8]
	ld	[%fp+68], %g1
	cmp	%g1, 0
	be	.LL4
	 nop
	ld	[%fp+68], %o1
	sethi	%hi(.LLC0), %g1
	or	%g1, %lo(.LLC0), %o0
	call	printf, 0
	 nop
.LL4:
	st	%g0, [%fp-4]
	b	.LL5
	 nop
.LL6:
	ld	[%fp-4], %g1
	ld	[%fp-8], %g2
	add	%g2, %g1, %g1
	ldub	[%g1], %g1
	and	%g1, 0xff, %g1
	mov	%g1, %o1
	sethi	%hi(.LLC1), %g1
	or	%g1, %lo(.LLC1), %o0
	call	printf, 0
	 nop
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL5:
	ld	[%fp-4], %g2
	ld	[%fp+76], %g1
	cmp	%g2, %g1
	bl	.LL6
	 nop
	nop
	restore
	jmp	%o7+8
	 nop
	.size	hexDump, .-hexDump
	.align 4
	.global fault_handler
	.type	fault_handler, #function
	.proc	020
fault_handler:
	save	%sp, -96, %sp
	sethi	%hi(resume), %g1
	or	%g1, %lo(resume), %g1
! 116 "injector_sparc.c" 1
	      			rett %g1
		       
! 0 "" 2
	nop
	restore
	jmp	%o7+8
	 nop
	.size	fault_handler, .-fault_handler
	.align 4
	.global set_trap_handlers
	.type	set_trap_handlers, #function
	.proc	020
set_trap_handlers:
	save	%sp, -96, %sp
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	2, %o0
	call	bcc_set_trap, 0
	 nop
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	36, %o0
	call	bcc_set_trap, 0
	 nop
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	43, %o0
	call	bcc_set_trap, 0
	 nop
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	60, %o0
	call	bcc_set_trap, 0
	 nop
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	33, %o0
	call	bcc_set_trap, 0
	 nop
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	32, %o0
	call	bcc_set_trap, 0
	 nop
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	1, %o0
	call	bcc_set_trap, 0
	 nop
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	3, %o0
	call	bcc_set_trap, 0
	 nop
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	4, %o0
	call	bcc_set_trap, 0
	 nop
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	37, %o0
	call	bcc_set_trap, 0
	 nop
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	11, %o0
	call	bcc_set_trap, 0
	 nop
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	7, %o0
	call	bcc_set_trap, 0
	 nop
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	8, %o0
	call	bcc_set_trap, 0
	 nop
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	40, %o0
	call	bcc_set_trap, 0
	 nop
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	41, %o0
	call	bcc_set_trap, 0
	 nop
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	44, %o0
	call	bcc_set_trap, 0
	 nop
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	9, %o0
	call	bcc_set_trap, 0
	 nop
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	10, %o0
	call	bcc_set_trap, 0
	 nop
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	42, %o0
	call	bcc_set_trap, 0
	 nop
	nop
	restore
	jmp	%o7+8
	 nop
	.size	set_trap_handlers, .-set_trap_handlers
	.align 4
	.global move_next_instruction
	.type	move_next_instruction, #function
	.proc	00
move_next_instruction:
	save	%sp, -104, %sp
	sethi	%hi(search_range), %g1
	or	%g1, %lo(search_range), %g1
	ldub	[%g1+16], %g1
	xor	%g1, 1, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL10
	 nop
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	sethi	%hi(search_range), %g2
	or	%g2, %lo(search_range), %g2
	ld	[%g2], %g3
	st	%g3, [%g1]
	ld	[%g2+4], %g2
	st	%g2, [%g1+4]
	sethi	%hi(search_range), %g1
	or	%g1, %lo(search_range), %g1
	mov	1, %g2
	stb	%g2, [%g1+16]
	mov	1, %g1
	st	%g1, [%fp-4]
	b	.LL11
	 nop
.LL10:
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldub	[%g1+3], %g2
	sethi	%hi(search_range), %g1
	or	%g1, %lo(search_range), %g1
	ldub	[%g1+11], %g1
	and	%g2, 0xff, %g2
	and	%g1, 0xff, %g1
	cmp	%g2, %g1
	bgeu	.LL12
	 nop
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldub	[%g1+3], %g1
	add	%g1, 1, %g1
	mov	%g1, %g2
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	stb	%g2, [%g1+3]
	mov	1, %g1
	st	%g1, [%fp-4]
	b	.LL11
	 nop
.LL12:
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldub	[%g1+2], %g2
	sethi	%hi(search_range), %g1
	or	%g1, %lo(search_range), %g1
	ldub	[%g1+10], %g1
	and	%g2, 0xff, %g2
	and	%g1, 0xff, %g1
	cmp	%g2, %g1
	bgeu	.LL13
	 nop
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	stb	%g0, [%g1+3]
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldub	[%g1+2], %g1
	add	%g1, 1, %g1
	mov	%g1, %g2
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	stb	%g2, [%g1+2]
	mov	1, %g1
	st	%g1, [%fp-4]
	b	.LL11
	 nop
.LL13:
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldub	[%g1+1], %g2
	sethi	%hi(search_range), %g1
	or	%g1, %lo(search_range), %g1
	ldub	[%g1+9], %g1
	and	%g2, 0xff, %g2
	and	%g1, 0xff, %g1
	cmp	%g2, %g1
	bgeu	.LL14
	 nop
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	stb	%g0, [%g1+3]
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	stb	%g0, [%g1+2]
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldub	[%g1+1], %g1
	add	%g1, 1, %g1
	mov	%g1, %g2
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	stb	%g2, [%g1+1]
	mov	1, %g1
	st	%g1, [%fp-4]
	b	.LL11
	 nop
.LL14:
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldub	[%g1], %g2
	sethi	%hi(search_range), %g1
	or	%g1, %lo(search_range), %g1
	ldub	[%g1+8], %g1
	and	%g2, 0xff, %g2
	and	%g1, 0xff, %g1
	cmp	%g2, %g1
	bgeu	.LL15
	 nop
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	stb	%g0, [%g1+3]
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	stb	%g0, [%g1+2]
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	stb	%g0, [%g1+1]
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldub	[%g1], %g1
	add	%g1, 1, %g1
	mov	%g1, %g2
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	stb	%g2, [%g1]
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldub	[%g1], %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 3
	bleu	.LL16
	 nop
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	mov	8, %g2
	stb	%g2, [%g1]
.LL16:
	mov	1, %g1
	st	%g1, [%fp-4]
	b	.LL11
	 nop
.LL15:
	st	%g0, [%fp-4]
.LL11:
	ld	[%fp-4], %g1
	cmp	%g0, %g1
	addx	%g0, 0, %g1
	and	%g1, 0xff, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	move_next_instruction, .-move_next_instruction
	.align 4
	.global inject
	.type	inject, #function
	.proc	020
inject:
	save	%sp, -112, %sp
	sethi	%hi(postamble_start), %g1
	or	%g1, %lo(postamble_start), %g1
	st	%g1, [%fp-8]
	sethi	%hi(postamble_end), %g1
	or	%g1, %lo(postamble_end), %g1
	st	%g1, [%fp-12]
	ld	[%fp-12], %g2
	ld	[%fp-8], %g1
	sub	%g2, %g1, %g1
	st	%g1, [%fp-16]
	sethi	%hi(packet_buffer), %g1
	or	%g1, %lo(packet_buffer), %g1
	ld	[%g1], %g2
	sethi	%hi(packet), %g1
	or	%g1, %lo(packet), %g1
	st	%g2, [%g1]
	st	%g0, [%fp-4]
	b	.LL19
	 nop
.LL20:
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g2
	ld	[%fp-4], %g1
	add	%g2, %g1, %g1
	ldub	[%g1], %g3
	sethi	%hi(packet), %g1
	or	%g1, %lo(packet), %g1
	ld	[%g1], %g2
	ld	[%fp-4], %g1
	add	%g2, %g1, %g1
	mov	%g3, %g2
	stb	%g2, [%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL19:
	ld	[%fp-4], %g1
	cmp	%g1, 3
	ble	.LL20
	 nop
	st	%g0, [%fp-4]
	b	.LL21
	 nop
.LL22:
	ld	[%fp-4], %g2
	sethi	%hi(postamble_start), %g1
	or	%g1, %lo(postamble_start), %g1
	add	%g2, %g1, %g2
	sethi	%hi(packet), %g1
	or	%g1, %lo(packet), %g1
	ld	[%g1], %g3
	ld	[%fp-4], %g1
	add	%g1, 4, %g1
	add	%g3, %g1, %g1
	ldub	[%g2], %g2
	stb	%g2, [%g1]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL21:
	ld	[%fp-4], %g2
	ld	[%fp-16], %g1
	cmp	%g2, %g1
	bl	.LL22
	 nop
	sethi	%hi(packet), %g1
	or	%g1, %lo(packet), %g1
	ld	[%g1], %g1
! 222 "injector_sparc.c" 1
	  			jmp %g1   
			nop        
			.global resume   
			resume:          
			mov %tbr, %g2 
  			
! 0 "" 2
	sethi	%hi(result), %g1
	or	%g1, %lo(result), %g1
	st	%g2, [%g1]
	nop
	restore
	jmp	%o7+8
	 nop
	.size	inject, .-inject
	.section	".rodata"
	.align 8
.LLC2:
	.asciz	"  0x%02x\n"
	.section	".text"
	.align 4
	.global handle_result
	.type	handle_result, #function
	.proc	020
handle_result:
	save	%sp, -104, %sp
	sethi	%hi(result), %g1
	or	%g1, %lo(result), %g1
	ld	[%g1], %g1
	st	%g1, [%fp-4]
	ld	[%fp-4], %g1
	srl	%g1, 4, %g1
	and	%g1, 255, %g1
	st	%g1, [%fp-8]
	ld	[%fp-8], %o1
	sethi	%hi(.LLC2), %g1
	or	%g1, %lo(.LLC2), %o0
	call	printf, 0
	 nop
	nop
	nop
	restore
	jmp	%o7+8
	 nop
	.size	handle_result, .-handle_result
	.section	".rodata"
	.align 8
.LLC3:
	.asciz	"Search finished!"
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -96, %sp
	call	initialize, 0
	 nop
	call	set_trap_handlers, 0
	 nop
	mov	320, %o0
	call	malloc, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %g2
	sethi	%hi(packet_buffer), %g1
	or	%g1, %lo(packet_buffer), %g1
	st	%g2, [%g1]
	b	.LL25
	 nop
.LL26:
	call	inject, 0
	 nop
	sethi	%hi(packet), %g1
	or	%g1, %lo(packet), %g1
	ld	[%g1], %g1
	mov	4, %o2
	mov	%g1, %o1
	mov	0, %o0
	call	hexDump, 0
	 nop
	call	handle_result, 0
	 nop
.LL25:
	call	move_next_instruction, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL26
	 nop
	sethi	%hi(.LLC3), %g1
	or	%g1, %lo(.LLC3), %o0
	call	puts, 0
	 nop
	mov	0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	main, .-main
	.ident	"GCC: (bcc-v2.0.2) 7.2.0"
