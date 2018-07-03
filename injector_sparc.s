	.file	"injector_sparc.c"
	.common	packet_buffer,4,4
	.common	packet,4,4
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
	.byte	-1
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
	.section	".rodata"
	.align 8
.LLC0:
	.asciz	"Hi"
	.section	".text"
	.align 4
	.global fh
	.type	fh, #function
	.proc	020
fh:
	save	%sp, -96, %sp
	sethi	%hi(.LLC0), %g1
	or	%g1, %lo(.LLC0), %o0
	call	printf, 0
	 nop
	nop
	restore
	jmp	%o7+8
	 nop
	.size	fh, .-fh
	.section	".rodata"
	.align 8
.LLC1:
	.long	1072693248
	.long	0
	.align 8
.LLC2:
	.long	1073741824
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
	be	.LL3
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
	b	.LL4
	 nop
.LL3:
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldd	[%g1+8], %f10
	sethi	%hi(.LLC1), %g1
	or	%g1, %lo(.LLC1), %g1
	ldd	[%g1], %f8
	faddd	%f10, %f8, %f8
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	std	%f8, [%g1+8]
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldd	[%g1+8], %f10
	sethi	%hi(.LLC2), %g1
	or	%g1, %lo(.LLC2), %g1
	ldd	[%g1], %f8
	fcmped	%f10, %f8
	nop
	fbuge	.LL9
	 nop
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldub	[%g1+3], %g1
	add	%g1, 1, %g1
	mov	%g1, %g2
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	stb	%g2, [%g1+3]
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	ldd	[%g1+8], %f10
	sethi	%hi(.LLC1), %g1
	or	%g1, %lo(.LLC1), %g1
	ldd	[%g1], %f8
	faddd	%f10, %f8, %f8
	sethi	%hi(ins), %g1
	or	%g1, %lo(ins), %g1
	std	%f8, [%g1+8]
	mov	1, %g1
	st	%g1, [%fp-4]
	b	.LL4
	 nop
.LL9:
	st	%g0, [%fp-4]
.LL4:
	ld	[%fp-4], %g1
	cmp	%g0, %g1
	addx	%g0, 0, %g1
	and	%g1, 0xff, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	move_next_instruction, .-move_next_instruction
	.section	".rodata"
	.align 8
.LLC3:
	.asciz	"Instruction: %x\n"
	.section	".text"
	.align 4
	.global inject
	.type	inject, #function
	.proc	020
inject:
	save	%sp, -104, %sp
	sethi	%hi(packet_buffer), %g1
	or	%g1, %lo(packet_buffer), %g1
	ld	[%g1], %g2
	sethi	%hi(packet), %g1
	or	%g1, %lo(packet), %g1
	st	%g2, [%g1]
	st	%g0, [%fp-4]
	b	.LL11
	 nop
.LL12:
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
.LL11:
	ld	[%fp-4], %g1
	cmp	%g1, 3
	ble	.LL12
	 nop
	sethi	%hi(packet), %g1
	or	%g1, %lo(packet), %g1
	ld	[%g1], %g1
! 101 "injector_sparc.c" 1
	  			jmp %g1   
			nop        
			.global resume   
			resume:          
			or %psr, 10, %psr 
  			
! 0 "" 2
	sethi	%hi(packet), %g1
	or	%g1, %lo(packet), %g1
	ld	[%g1], %g1
	mov	%g1, %o1
	sethi	%hi(.LLC3), %g1
	or	%g1, %lo(.LLC3), %o0
	call	printf, 0
	 nop
	nop
	restore
	jmp	%o7+8
	 nop
	.size	inject, .-inject
	.align 4
	.global main
	.type	main, #function
	.proc	04
main:
	save	%sp, -96, %sp
	mov	32, %o0
	call	malloc, 0
	 nop
	mov	%o0, %g1
	mov	%g1, %g2
	sethi	%hi(packet_buffer), %g1
	or	%g1, %lo(packet_buffer), %g1
	st	%g2, [%g1]
	sethi	%hi(resume), %g1
	or	%g1, %lo(resume), %g1
	mov	%g1, %o1
	mov	2, %o0
	call	bcc_set_trap, 0
	 nop
	b	.LL14
	 nop
.LL15:
	call	inject, 0
	 nop
.LL14:
	call	move_next_instruction, 0
	 nop
	mov	%o0, %g1
	and	%g1, 0xff, %g1
	cmp	%g1, 0
	bne	.LL15
	 nop
	mov	0, %g1
	mov	%g1, %i0
	restore
	jmp	%o7+8
	 nop
	.size	main, .-main
	.ident	"GCC: (bcc-v2.0.2) 7.2.0"
