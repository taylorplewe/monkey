class fx

var [8] effects
const EF_DATA		effects + 0
	; 0httffff | horizontal flip, type, frame
	const EF_TYPE_TUFT		%00010000
	const EF_TYPE_BOUNCE	%00100000
const EF_X			effects + 1
const EF_Y			effects + 2
const EF_FRAMECTR	effects + 3
const EF_RAM_ALLOC	4

; objInd of bouncy wall
; # segments down
; framectr
; frame
var [8] bounces ; effects
const BOUNCE_OBJIND		bounces + 0
const BOUNCE_SEGSDOWN	bounces + 1
const BOUNCE_FRAMECTR	bounces + 2
const BOUNCE_FRAME		bounces + 3
const BOUNCE_RAM_ALLOC 4

; params:
;	a - type
;	x - x
;	y - y
;	flip - horizontally flipped
CreateEffect:
	var [1] flip
	var [1] ef2frame
	pha
	lda EF_DATA
	beq .spot1
	lda EF_DATA + EF_RAM_ALLOC
	beq .spot2
	; both being used, whichever is further along gets axed
	and #%1111
	sta ef2frame
	lda EF_DATA
	and #%1111
	cmp ef2frame
	bcc .spot2
	.spot1:
		stx EF_X
		ldx #0
		beq .store
	.spot2:
		stx EF_X + EF_RAM_ALLOC
		ldx #EF_RAM_ALLOC
	.store:
	pla
	and #disp.H_FLIP ^ $ff
	ora flip
	sta EF_DATA, x
	tya
	sta EF_Y, x
	lda #1
	sta EF_FRAMECTR, x
	rts

UpdateEffects:
	ldx #0
	lda EF_DATA
	beq .next
	jsr .update
	.next:
	ldx #EF_RAM_ALLOC
	lda EF_DATA + EF_RAM_ALLOC
	bne .update
	.end: rts
	.update:
		lda EF_FRAMECTR, x
		and #%111
		bne .updateend
		lda EF_DATA, x
		clc
		adc #1
		sta EF_DATA, x
		and #%11
		pha
			; move tuft over
			cmp #1
			bne .moveend
				dec EF_Y, x
				dec EF_Y, x
				dec EF_Y, x
				lda EF_DATA, x
				and #disp.H_FLIP
				bne >
					inc EF_X, x
					inc EF_X, x
					inc EF_X, x
					jmp .moveend
				>
				dec EF_X, x
				dec EF_X, x
				dec EF_X, x
			.moveend:
		pla
		eor #%11 ; max frame # 3 (come back and change)
		bne .updateend
		; destroy
		lda #0
		sta EF_DATA, x
		.updateend:
		inc EF_FRAMECTR, x
		rts

; params:
;	x - objInd of bouncy wall
;	a - monkey.y
; clobbers y
CreateBounce:
	var [1] b2frame
	var [1] segsdown
	var [1] objy
	clc
	adc #8
	pha
	lda BOUNCE_FRAMECTR
	beq .spot1
	lda BOUNCE_FRAMECTR + BOUNCE_RAM_ALLOC
	beq .spot2
	; both being used, whichever is further along gets axed
	lda BOUNCE_FRAME + BOUNCE_RAM_ALLOC
	and #%1111
	sta b2frame
	lda BOUNCE_FRAME
	and #%1111
	cmp b2frame
	bcc .spot2
	.spot1:
		ldy #0
		beq .spotsend
	.spot2:
		ldy #BOUNCE_RAM_ALLOC
	.spotsend:

	lda #0
	sta segsdown
	lda obj.Y, x
	sta objy

	lda obj.STOREY, x
	cmp #2
	bcc .cmpy
		lda obj.Y, x
		.yloop:
			inc segsdown
			clc
			adc #16
			bcc .yloop
		sta objy
	.cmpy:
	pla
	sec
	sbc objy
	bcs >
		lda #0
	>
	lsr a
	lsr a
	lsr a
	lsr a
	clc
	adc segsdown
	sta BOUNCE_SEGSDOWN, y
	lda obj.NUMSEGS, x
	clc
	adc #2
	sec
	sbc BOUNCE_SEGSDOWN, y
	beq .one
	bcs .oneend
		.one:
		lda #1
	.oneend:
	sta BOUNCE_SEGSDOWN, y
	lda #1
	sta BOUNCE_FRAMECTR, y
	lsr a ; lda #0
	sta BOUNCE_FRAME, y
	txa
	sta BOUNCE_OBJIND, y
	rts

bouncexs:
	.db -4, 3, -2, 2, -1, 1, -1, 1
bouncexsend:
const BOUNCEXS_LEN bouncexsend - bouncexs
UpdateBounces:
	ldx #0
	lda BOUNCE_FRAMECTR
	beq .next
	jsr .update
	.next:
	ldx #BOUNCE_RAM_ALLOC
	lda BOUNCE_FRAMECTR + BOUNCE_RAM_ALLOC
	beq .end
	bne .update ; jsr, rts
	.end: rts
	.update:
		inc BOUNCE_FRAMECTR, x
		lda BOUNCE_FRAMECTR, x
		and #%1
		bne .end
		inc BOUNCE_FRAME, x
		lda BOUNCE_FRAME, x
		cmp #BOUNCEXS_LEN
		bne .end
		; destroy bounce effect
		lda #0
		sta BOUNCE_FRAMECTR, x
		rts