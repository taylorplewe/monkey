class comm

; 4 = 1px/fr
SpeedToMvmt:
	var [1] speed
	var [1] whole
	sta speed
	and #%11111100
	sta whole	
	; asr
		asl a ; set carry
		lda whole
		ror a
		sta whole
	; asr
		asl a ; set carry
		lda whole
		ror a
		sta whole
	; fraction part
		lda speed
		and #%00000011
		beq .add
		cmp #1
		beq .25
		cmp #2
		beq .50
		bne .75
		.25:
			lda g.counter
			and #%11
			bne .0
			beq .1
		.50:
			lda g.counter
			and #1
			bne .0
			beq .1
		.75:
			lda g.counter
			and #%11
			bne .1
			beq .add
		.0:
		lda #0
		beq .add ; jmp
		.1:
		lda #1
	.add:
	clc
	adc whole
	rts

; params:
;	a - targ pos
;	curr - current pos
SmoothToTarg:
	var [1] curr
	sec
	sbc curr
	beq .eq
	; asr a
		pha
		asl a
		pla
		ror a
	; asr a
		pha
		asl a
		pla
		ror a
	bne >
		lda #1
	>
	jsr SpeedToMvmt
	clc
	adc curr
	rts
	.eq:
	lda curr
	rts

RandomNum:
	; Galois linear feedback shift register
	; https://wiki.nesdev.org/w/index.php?title=Random_number_generator
	lda	g.seed
	ldx	#8
	.loop:
		asl	a
		rol	g.seed + 1
		bcc	>
			eor	#$39
		>
		dex
		bne	.loop
	sta	g.seed
	rts

; params:
;	a - max number (exclusive)
ModRandomNum:
	var [1] mod
	var [1] ran
	cmp #1
	bne >
		lda #0
		.end: rts ; get outta here
	>
	sta mod
	jsr RandomNum
	cmp mod
	bcc .end ; random num is already less than mod, we're good
	sta ran
	; powers of 2 are easy; just and off unneeded bits
	lda mod
	cmp #2
	beq .2
	cmp #4
	beq .4
	cmp #8
	beq .8
	cmp #16
	beq .16
	bcc .below16
	bcs .16andabove
	.2:
		lda ran
		and #%1
		rts
	.4:
		lda ran
		and #%11
		rts
	.8:
		lda ran
		and #%111
		rts
	.16:
		lda ran
		and #%1111
		.end2: rts
	.below16:
		lda ran
		and #%1111
		bne .modloop ; jmp
	.16andabove:
		lda ran
	.modloop:
		cmp mod
		bcc .end2
		sec
		sbc mod
		jmp .modloop

; params:
;	x - number of frames to wait
WaitNumFrames:
	lda g.boolParty
	ora #g.BOOLS_NMI_READY
	sta g.boolParty
	.loop:
		txa
		pha
		tya
		pha
		jsr ft.FamiToneUpdate
		pla
		tay
		pla
		tax
		.wait:
			lda $2002
			bpl .wait
		dex
		bne .loop
	rts