	.file	"injector_sparc.c"
	.common	packet_buffer,4,4
	.common	packet,4,4
	.common	result,4,4
	.common	ins,24,8
	.global search_range
	.section	".data"
	.align 8
	.type	search_range, #object
	.size	search_range, 56
search_range:
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.skip	4
	.long	0
	.long	0
	.long	0
	.skip	4
	.byte	0
	.byte	-1
	.byte	-1
	.byte	-1
	.skip	4
	.long	1078001664
	.long	0
	.long	0
	.skip	4
	.byte	0
	.skip	7
	.global trap_totals
	.section	".bss"
	.align 4
	.type	trap_totals, #object
	.size	trap_totals, 88
trap_totals:
	.skip	88
	.section	".text"
	.align 4
	.global postamble
	.type	postamble, #function
	.proc	020
postamble:
	save	%sp, -96, %sp
! 88 "injector_sparc.c" 1
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
	.align 8
.LLC2:
	.asciz	"   "
	.align 8
.LLC3:
	.asciz	"  %s\n"
	.section	".text"
	.align 4
	.global hexDump
	.type	hexDump, #function
	.proc	020
hexDump:
	save	%sp, -128, %sp
	st	%i0, [%fp+68]
	st	%i1, [%fp+72]
	st	%i2, [%fp+76]
	ld	[%fp+72], %g1
	st	%g1, [%fp-8]
	ld	[%fp+68], %g1
	cmp	%g1, 0
	be	.LL3
	 nop
	ld	[%fp+68], %o1
	sethi	%hi(.LLC0), %g1
	or	%g1, %lo(.LLC0), %o0
	call	printf, 0
	 nop
.LL3:
	st	%g0, [%fp-4]
	b	.LL4
	 nop
.LL8:
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
	ld	[%fp-8], %g2
	add	%g2, %g1, %g1
	ldub	[%g1], %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 31
	bleu	.LL5
	 nop
	ld	[%fp-4], %g1
	ld	[%fp-8], %g2
	add	%g2, %g1, %g1
	ldub	[%g1], %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 126
	bleu	.LL6
	 nop
.LL5:
	ld	[%fp-4], %g2
	sra	%g2, 31, %g1
	srl	%g1, 28, %g1
	add	%g2, %g1, %g2
	and	%g2, 15, %g2
	sub	%g2, %g1, %g1
	add	%fp, %g1, %g1
	mov	46, %g2
	stb	%g2, [%g1-32]
	b	.LL7
	 nop
.LL6:
	ld	[%fp-4], %g1
	ld	[%fp-8], %g2
	add	%g2, %g1, %g3
	ld	[%fp-4], %g2
	sra	%g2, 31, %g1
	srl	%g1, 28, %g1
	add	%g2, %g1, %g2
	and	%g2, 15, %g2
	sub	%g2, %g1, %g1
	ldub	[%g3], %g2
	add	%fp, %g1, %g1
	stb	%g2, [%g1-32]
.LL7:
	ld	[%fp-4], %g2
	sra	%g2, 31, %g1
	srl	%g1, 28, %g1
	add	%g2, %g1, %g2
	and	%g2, 15, %g2
	sub	%g2, %g1, %g1
	add	%g1, 1, %g1
	add	%fp, %g1, %g1
	stb	%g0, [%g1-32]
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL4:
	ld	[%fp-4], %g2
	ld	[%fp+76], %g1
	cmp	%g2, %g1
	bl	.LL8
	 nop
	b	.LL9
	 nop
.LL10:
	sethi	%hi(.LLC2), %g1
	or	%g1, %lo(.LLC2), %o0
	call	printf, 0
	 nop
	ld	[%fp-4], %g1
	add	%g1, 1, %g1
	st	%g1, [%fp-4]
.LL9:
	ld	[%fp-4], %g1
	and	%g1, 15, %g1
	cmp	%g1, 0
	bne	.LL10
	 nop
	add	%fp, -32, %g1
	mov	%g1, %o1
	sethi	%hi(.LLC3), %g1
	or	%g1, %lo(.LLC3), %o0
	call	printf, 0
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
! 146 "injector_sparc.c" 1
	      			rett %g1
		       
! 0 "" 2
	nop
	restore
	jmp	%o7+8
	 nop
	.size	fault_handler, .-fault_handler
	.section	".rodata"
	.align 8
.LLC4:
	.long	1072693248
	.long	0
	.section	".text"
	.align 4
	.global move_next_instruction
	.type	move_next_instruction, #function
	.proc	00
move_next_instruction:
	save	%sp, -104, %sp
	sethi	%hi(search_range), %g1
	or	%g1, %lo(search_range), %g1
	ldub	[%g1+48], %g1
	xor	%g1, 1, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	be	.LL13
	 nop
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	sethi	%hi(search_range), %g2
	or	%g2, %lo(search_range), %g2
	ldd	[%g2], %i4
	std	%i4, [%g1]
	ldd	[%g2+8], %i4
	std	%i4, [%g1+8]
	ldd	[%g2+16], %g2
	std	%g2, [%g1+16]
	sethi	%hi(search_range), %g1
	or	%g1, %lo(search_range), %g1
	mov	1, %g2
	stb	%g2, [%g1+48]
	mov	1, %g1
	st	%g1, [%fp-4]
	b	.LL14
	 nop
.LL13:
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldub	[%g1+3], %g2
	sethi	%hi(search_range), %g1
	or	%g1, %lo(search_range), %g1
	ldub	[%g1+27], %g1
	and	%g2, 0xff, %g2
	and	%g1, 0xff, %g1
	cmp	%g2, %g1
	bgeu	.LL15
	 nop
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldd	[%g1+8], %f10
	sethi	%hi(.LLC4), %g1
	or	%g1, %lo(.LLC4), %g1
	ldd	[%g1], %f8
	faddd	%f10, %f8, %f8
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	std	%f8, [%g1+8]
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
	b	.LL14
	 nop
.LL15:
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldub	[%g1+2], %g2
	sethi	%hi(search_range), %g1
	or	%g1, %lo(search_range), %g1
	ldub	[%g1+26], %g1
	and	%g2, 0xff, %g2
	and	%g1, 0xff, %g1
	cmp	%g2, %g1
	bgeu	.LL16
	 nop
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldd	[%g1+8], %f10
	sethi	%hi(.LLC4), %g1
	or	%g1, %lo(.LLC4), %g1
	ldd	[%g1], %f8
	faddd	%f10, %f8, %f8
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	std	%f8, [%g1+8]
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
	b	.LL14
	 nop
.LL16:
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldub	[%g1+1], %g2
	sethi	%hi(search_range), %g1
	or	%g1, %lo(search_range), %g1
	ldub	[%g1+25], %g1
	and	%g2, 0xff, %g2
	and	%g1, 0xff, %g1
	cmp	%g2, %g1
	bgeu	.LL17
	 nop
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldd	[%g1+8], %f10
	sethi	%hi(.LLC4), %g1
	or	%g1, %lo(.LLC4), %g1
	ldd	[%g1], %f8
	faddd	%f10, %f8, %f8
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	std	%f8, [%g1+8]
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
	b	.LL14
	 nop
.LL17:
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldub	[%g1], %g2
	sethi	%hi(search_range), %g1
	or	%g1, %lo(search_range), %g1
	ldub	[%g1+24], %g1
	and	%g2, 0xff, %g2
	and	%g1, 0xff, %g1
	cmp	%g2, %g1
	bgeu	.LL18
	 nop
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldd	[%g1+8], %f10
	sethi	%hi(.LLC4), %g1
	or	%g1, %lo(.LLC4), %g1
	ldd	[%g1], %f8
	faddd	%f10, %f8, %f8
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	std	%f8, [%g1+8]
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
	mov	1, %g1
	st	%g1, [%fp-4]
	b	.LL14
	 nop
.LL18:
	st	%g0, [%fp-4]
.LL14:
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
	b	.LL21
	 nop
.LL22:
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
.LL21:
	ld	[%fp-4], %g1
	cmp	%g1, 3
	ble	.LL22
	 nop
	st	%g0, [%fp-4]
	b	.LL23
	 nop
.LL24:
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
.LL23:
	ld	[%fp-4], %g2
	ld	[%fp-16], %g1
	cmp	%g2, %g1
	bl	.LL24
	 nop
	sethi	%hi(packet), %g1
	or	%g1, %lo(packet), %g1
	ld	[%g1], %g1
! 226 "injector_sparc.c" 1
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
	ld	[%fp-8], %g1
	cmp	%g1, 2
	be	.LL27
	 nop
	b	.LL28
	 nop
.LL27:
	sethi	%hi(trap_totals), %g1
	or	%g1, %lo(trap_totals), %g1
	ld	[%g1], %g1
	add	%g1, 1, %g2
	sethi	%hi(trap_totals), %g1
	or	%g1, %lo(trap_totals), %g1
	st	%g2, [%g1]
	nop
.LL28:
	nop
	restore
	jmp	%o7+8
	 nop
	.size	handle_result, .-handle_result
	.section	".rodata"
	.align 8
.LLC5:
	.asciz	"Instruction"
	.align 8
.LLC6:
	.asciz	"Search finished!"
	.align 8
.LLC7:
	.asciz	"Total illegal instructions: %d\n"
	.section	".text"
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -96, %sp
	mov	160, %o0
	call	malloc, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %g2
	sethi	%hi(packet_buffer), %g1
	or	%g1, %lo(packet_buffer), %g1
	st	%g2, [%g1]
	sethi	%hi(fault_handler), %g1
	or	%g1, %lo(fault_handler), %o1
	mov	2, %o0
	call	bcc_set_trap, 0
	 nop
	b	.LL30
	 nop
.LL31:
	sethi	%hi(packet), %g1
	or	%g1, %lo(packet), %g1
	ld	[%g1], %g1
	mov	4, %o2
	mov	%g1, %o1
	sethi	%hi(.LLC5), %g1
	or	%g1, %lo(.LLC5), %o0
	call	hexDump, 0
	 nop
	call	inject, 0
	 nop
	call	handle_result, 0
	 nop
.LL30:
	call	move_next_instruction, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL31
	 nop
	sethi	%hi(.LLC6), %g1
	or	%g1, %lo(.LLC6), %o0
	call	puts, 0
	 nop
	sethi	%hi(trap_totals), %g1
	or	%g1, %lo(trap_totals), %g1
	ld	[%g1], %g1
	mov	%g1, %o1
	sethi	%hi(.LLC7), %g1
	or	%g1, %lo(.LLC7), %o0
	call	printf, 0
	 nop
	mov	0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	main, .-main
	.ident	"GCC: (bcc-v2.0.2) 7.2.0"
