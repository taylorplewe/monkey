	.inesprg 1    
	.ineschr 1    
	.inesmap 0    
	.inesmir 0    
	.bank 0
	.org $8000
reset:
	ldx #0
	stx $2000
	stx $2001
		txa
		.zeroLoop:
			sta <$00, x
			sta $0100, x
			sta $0300, x
			sta $0400, x
			inx
			bne .zeroLoop
		lda #$ff 
		.ffloop:
			sta $0200, x
			inx
			bne .ffloop
	tax
	txs
	lda $6000
	sta <s2
	lda $6001
	sta <s2+1
	ldx #2
	.sync1:
		lda $2002
		bpl .sync1
		dex
		bne .sync1
	lda #$ff
	jsr f3FamiToneInit
	ldx #LOW(sounds)
	ldy #HIGH(sounds)
	jsr f3FamiToneSfxInit
	jsr c4InitTitle
	lda <b10
	ora #b7
	sta <b10
	lda #%10000000
	sta $2000
	sta <p0
	lda #%00011110
	sta $2001
	sta <p1
	ldx #2
	.sync2:
		lda $2002
		bpl .sync2
		dex
		bne .sync2
forever:
	inc <c2
	inc <s2
	lda <s2
	bne .b0
		inc <s2+1
	.b0:
	jsr i0Read
	lda <b10
	and #b7
	bne .title
			jsr c4Pause
			lda <p2
			bne .pausedend
		lda <c4v0
		beq .b1
			jsr m8UpdateVictor
			jsr c4UpdateCrown
		.b1:
		lda <d1d1
		bpl .b2
			jsr o4Update
			jsr m8UpdateBothMonkeys
		.b2:
		jsr d1Update
		jsr c4UpdateGame
		lda <b10
		and #b4 | b3
		beq .forevershared
			and #b3
			beq .flip
				ldx #FT_SFX_CH0
				lda #s0
				jsr f3FamiToneSfxPlay
				jmp .tse
			.flip:
				ldx #FT_SFX_CH2
				lda #f0
				jsr f3FamiToneSfxPlay
			.tse:
			lda <b10
			and #(b4 | b3) ^ $ff
			sta <b10
			jmp .forevershared
	.title:
		jsr c4UpdateTitle
		jsr d1UpdateTitle
	.forevershared:
	lda <i0b8
	and #i0b2
	beq .b3
	.b3:
	.pausedend:
	jsr f3FamiToneUpdate
	lda <i0b8+1
	sta <i0b9+1
	lda <i0b8+2
	sta <i0b9+2
	lda <b10
	ora #%10000000
	sta <b10
	.waitnmi:
		lda <b10
		bmi .waitnmi
	jmp forever
nmi:
	pha
	tya
	pha
	txa
	pha
	lda <b10
	asl a
	bcc .recal 
	lda #0
	sta $2003 
	lda #$02
	sta $4014 
	ldx #0
	ldy d1p0
	beq .buffoloopend
	.buffoloop:
		inx
		lda d1p0, x
		sta $2006
		inx
		lda d1p0, x
		sta $2006
		inx
		.buffiloop:
			lda d1p0, x
			sta $2007
			inx
			dey
			bne .buffiloop
		.buffiloopend:
		ldy d1p0, x
		bne .buffoloop
	.buffoloopend:
	lda <b10
	and #%01111111
	sta <b10
	lda <d1x0 
	sta $2005
	lda <d1s0
	sta $2005
	.recal:
	lda <p0
	sta $2000
	lda <p1
	sta $2001
	pla
	tax
	pla
	tay
	pla
	rti
	

d1DrawNTTilesAndAttrs:
	stx $2006
	sty $2006
	.tiles:
		ldy #0
		ldx #3
		.tileloop:
			lda [d1DrawNTTilesAndAttrsd0], y
			sta $2007
			iny
			bne .tileloop
			inc <d1DrawNTTilesAndAttrsd0+1
			dex
			bne .tileloop
		.tileloop4:
			lda [d1DrawNTTilesAndAttrsd0], y
			sta $2007
			iny
			cpy #192
			bne .tileloop4
		.attrloop:
			lda [d1DrawNTTilesAndAttrsd0], y
			sta $2007
			iny
			bne .attrloop
	rts
d1SetPalettes:
	lda #$3f
	sta $2006
	lda #$00
	sta $2006
	tay
	.loop:
		lda [d1SetPalettesp0], y
		sta $2007
		iny
		cpy #32
		bne .loop
	rts
d1InitGame:
	ldx #$20
	ldy #0
	lda #LOW(gametiles)
	sta <d1DrawNTTilesAndAttrsd0
	lda #HIGH(gametiles)
	sta <d1DrawNTTilesAndAttrsd0+1
	jsr d1DrawNTTilesAndAttrs
	ldx #$28
	ldy #0
	lda #LOW(gametiles2)
	sta <d1DrawNTTilesAndAttrsd0
	lda #HIGH(gametiles2)
	sta <d1DrawNTTilesAndAttrsd0+1
	jsr d1DrawNTTilesAndAttrs
	lda #0
	sta <d1s1
	sta <d1s2
	sta <d1s0
	sta d1s5
	jsr d1UpdateBasePals
	lda #$ff
	sta <d1s2 + 1
	sta <d1s2 + 2
	sta <d1s2 + 3
	sta <d1d1
	rts
d1InitTitle:
	lda #LOW(titlepals)
	sta <d1SetPalettesp0
	lda #HIGH(titlepals)
	sta <d1SetPalettesp0+1
	jsr d1SetPalettes
	ldx #$20
	ldy #0
	lda #LOW(titletiles)
	sta <d1DrawNTTilesAndAttrsd0
	lda #HIGH(titletiles)
	sta <d1DrawNTTilesAndAttrsd0+1
	jsr d1DrawNTTilesAndAttrs
	lda #$ff
	jsr d1UpdateBasePals
	rts
d1UpdateTitle:
	lda #d1s3
	sta o1
	lda #d1s4
	sta o0
	lda #64
	sta o3
	lda #%00100000 
	sta o2
	lda #0
	sta <d1m1
	lda <b10
	and #b6
	asl a
	asl a
	asl a
	rol <d1m1
	lda <c2
	and #%1111
	bne .bobend
		lda <d1m1
		bne .multbob
			lda <d1u0
			eor #1
			sta <d1u0
			bpl .bobend 
		.multbob:
			lda <d1u0
			eor #2
			sta <d1u0
	.bobend:
	lda #d1m0 - 16
	sta o3 + 4
	lda #d1o5
	sta o1 + 4
	lda <d1m1
	eor #1
	sta o2 + 4
	sta <d1SD_monkeyWorda1
	lda #d1m0
	sta <d1SD_monkeyWordx0
	lda #6
	sta <d1SD_monkeyWordl0
	lda <d1u0
	and #1
	bne .addy1up
		lda #d1o4
		sta o0 + 4
		sta <d1SD_monkeyWordy0
		lda #2
		bne .addy1st 
		.addy1up:
		lda #d1o4 + 2
		sta o0 + 4
		sta <d1SD_monkeyWordy0
		lda #-2
	.addy1st:
	sta <d1SD_monkeyWorda0
	ldy #8
	jsr d1SD_monkeyWord
	lda #d1m0 - 20
	sta o3, y
	lda #d1t2
	sta o1, y
	lda <d1m1
	sta o2, y
	sta <d1SD_monkeyWorda1
	lda #d1m0 - 4
	sta <d1SD_monkeyWordx0
	lda #7
	sta <d1SD_monkeyWordl0
	lda <d1u0
	and #2
	bne .addy2up
		lda #d1t1
		sta o0, y
		sta <d1SD_monkeyWordy0
		lda #2
		bne .addy2st 
		.addy2up:
		lda #d1t1 + 2
		sta o0, y
		sta <d1SD_monkeyWordy0
		lda #-2
	.addy2st:
	sta <d1SD_monkeyWorda0
	iny
	iny
	iny
	iny
	jsr d1SD_monkeyWord
	.end: rts
d1SD_monkeyWord:
	ldx #0
	.loop:
		lda monkeywordtiles, x
		sta o1, y
		lda <d1SD_monkeyWorda1
		sta o2, y
		txa
		and #1
		bne .b0
			lda <d1SD_monkeyWordy0
			clc
			adc <d1SD_monkeyWorda0
			bne .yst
		.b0:
			lda <d1SD_monkeyWordy0
		.yst:
		sta o0, y
		lda <d1SD_monkeyWordx0
		sta o3, y
		clc
		adc #8
		sta <d1SD_monkeyWordx0
		iny
		iny
		iny
		iny
		inx
		cpx <d1SD_monkeyWordl0
		bne .loop
	rts
d1Update:
	jsr d1ClearPPUBuff
	jsr d1ClearOAM
	lda <c2
	and #%11
	bne .cloudxend
	lda <d1d1
	bpl .cloudxend
		inc <d1c4
	.cloudxend:
	lda <d1d1
	bmi .deathend
		lda <c4t1
		beq .b0
			jsr d1SD_tie_word
		.b0:
		lda <c4v0
		beq .b1
			jsr d1SD_crown
		.b1:
		jsr d1SD_deathSq
		lda <d1d1
		cmp #96
		bne .b2
			jsr c4CrownWinner
		.b2:
		cmp #$7f
		beq .b3
			inc <d1d1
		.b3:
		jmp .alwaysdraw
	.deathend:
	lda <c4c0
	jsr c3SpeedToMvmt
	jsr d1ScrollUp
	inc <d1a0
	jsr d1FollowBothMonkeys
	.alwaysdraw:
	jsr d1SD_score
	lda #0
	sta <d1m2
	lda <b10
	and #b1
	bne .front
	lda <c4v0
	beq .b4
		.front:
		lda #1
		sta <d1m2
	.b4:
	lda <d1m2
	beq .b5
		jsr d1SD_monkeys
		jsr d1SD_monkeyTails
	.b5:
	jsr d1SoftDrawObjs
	lda <d1m2
	bne .b6
		jsr d1SD_monkeys
		jsr d1SD_monkeyTails
	.b6:
	jsr d1SD_effects
	jsr d1SD_cloud
	rts
d1FollowBothMonkeys:
	ldx #1
	jsr d1FollowMonkey
	lda <b10
	and #b6
	bne .b0
		rts
	.b0:
	ldx #2
	jmp d1FollowMonkey
d1FollowMonkey:
	lda <m8b8
	and #m8b4
	beq .b0
		.end0: rts
	.b0:
	lda #d1f0
	cmp <m8y0, x
	beq .end0
	bcc .end0
		sec
		sbc <m8y0, x
		lsr a
		lsr a
		lsr a
		lsr a
		beq .end0
d1ScrollUp:
	sta <d1d0
		lda <d1s0
		sec
		sbc <d1d0
		sta <d1s0
		bcs .b0
				sec
				sbc #16
				sta <d1s0
				lda <p0
				eor #%00000010
				sta <p0
				jsr d1IncreaseScore
				jsr c4IncreaseHexScore
		.b0:
			lda <m8y0+1
			clc
			adc <d1d0
			sta <m8y0+1
			lda <m8t1+1
			clc
			adc <d1d0
			sta <m8t1+1
			lda <m8y0+2
			clc
			adc <d1d0
			sta <m8y0+2
			lda <m8t1+2
			clc
			adc <d1d0
			sta <m8t1+2
		lda f4e5
		clc
		adc <d1d0
		sta f4e5
		lda f4e5 + f4e7
		clc
		adc <d1d0
		sta f4e5 + f4e7
		lda <g0c0
		pha
		clc
		adc <d1d0
		sta <g0c0
		bcc .cstoreyadd
			dec <g0c1
			lda <g0c1
			cmp #2
			bcs .cstoreyadd
			pla
			sta <g0c0
			inc <g0c1
			bne .nocystore 
		.cstoreyadd:
		pla
		.nocystore:
		lda <d1s1
		sec
		sbc <d1d0
		sta <d1s1
		bcs .lvlend
			dec <g0n0
			bne .lvlend
			jsr g0GenerateWholeHalf
		.lvlend:
		lda #o4n2
		sta <d1n0
		ldx #0
		.wallsloop:
			lda o4s0, x
			beq .next
			lda o4y0, x
			clc
			adc <d1d0
			sta o4y0, x
			bcc .b1
				dec o4s0, x
			.b1:
			.next:
			txa
			clc
			adc #o4o0
			tax
			dec <d1n0
			bne .wallsloop 
		.wallsend:
	.end: rts
d1ClearOAM:
	ldx <d1o3
	lda #$ff
	.loop:
		sta o0, x
		dex
		bne .loop
	stx <d1o3
	rts
d1UpdateBasePals:
	bne .titlepals
		lda #LOW(gamepals)
		sta <d1UpdateBasePalsa0
		lda #HIGH(gamepals)
		sta <d1UpdateBasePalsa0+1
		bne .setend 
	.titlepals:
		lda #LOW(titlepals)
		sta <d1UpdateBasePalsa0
		lda #HIGH(titlepals)
		sta <d1UpdateBasePalsa0+1
	.setend:
	ldy #32
	.loop:
		dey
		lda [d1UpdateBasePalsa0], y
		sta d1b0, y
		cpy #0
		bne .loop
	rts
d1SoftDrawObjs:
		lda <d1a0
		and #%100000
		lsr a
		lsr a
		lsr a
		lsr a
		sta <d1t0
	ldx #0
	ldy <d1o3
	lda #o4n2
	sta <d1SoftDrawObjsn1
	.loop:
		lda o4n0, x
		clc
		adc #2
		sta <d1SoftDrawObjsn0
		lda o4y0, x
		sta <d1SoftDrawObjsc1
		lda o4x0, x
		sta <d1SoftDrawObjsc0
		lda o4s0, x
		beq .next
		cmp #1
		beq .startsgloop
		cmp #2
		bne .next
		.onscreenloop:
			dec <d1SoftDrawObjsn0
			beq .next
			lda <d1SoftDrawObjsc1
			clc
			adc #16
			sta <d1SoftDrawObjsc1
			bcc .onscreenloop
		.startsgloop:
		txa
		pha
		lda o4t0, x
		asl a
		tax
		lda sdaddrs, x
		sta <d1SoftDrawObjss0
		lda sdaddrs+1, x
		sta <d1SoftDrawObjss0+1
		pla
		tax
		jsr d1SD_jump
		.next:
		txa
		clc
		adc #o4o0
		tax
		dec <d1SoftDrawObjsn1
		beq .end
		jmp .loop
	.end:
	sty <d1o3
	rts
d1SD_jump:
	jmp [d1SoftDrawObjss0]
d1SD_norm:
	.sgloop:
		jsr d1BounceShake
		sta o3, y
		lda <d1SoftDrawObjsc1
		sta o0, y
		cmp o4y0, x
		beq .top
		lda <d1SoftDrawObjsn0
		cmp #1
		beq .bot
			lda #1
			bne .jsrdraw 
		.bot:
			lda #2
			bne .jsrdraw 
		.top:
			lda #0
		.jsrdraw:
		jsr d1SD_wallSegment
		cmp #$ff
		beq .b0
			lda #0
			sta o2, y
		.b0:
		iny
		iny
		iny
		iny
		lda <d1SoftDrawObjsc1
		clc
		adc #16
		sta <d1SoftDrawObjsc1
		bcs .end
		dec <d1SoftDrawObjsn0
		bne .sgloop
	.end: rts
d1BounceShake:
	tya
	pha
	lda <d1SoftDrawObjsc0
	sta <d1BounceShaker0
	ldy #0
	.loop:
		lda f4b3, y
		beq .next
		txa
		cmp f4b1, y
		bne .next
		lda f4b2, y
		cmp <d1SoftDrawObjsn0
		bne .next
		lda f4b4, y
		tay
		lda f4bouncexs, y
		clc
		adc <d1BounceShaker0
		sta <d1BounceShaker0
		jmp .end
		.next:
		tya
		clc
		adc #f4b5
		tay
		cpy #f4b5 * 2
		bne .loop
	.end:
	pla
	tay
	lda <d1BounceShaker0
	rts
d1SD_wallSegment:
	beq .top
	cmp #2
	beq .bot
		lda o4t0, x
		cmp #o4b0
		beq .medbounce
			lda #d1o1 | 1
			jmp .tilest
		.medbounce:
			lda #$ea | 1
			sta o1, y
			lda #3
			sta o2, y
			lda #$ff
			rts
	.bot:
		lda o4t0, x
		beq .botnorm
		cmp #o4b0
		beq .botbounce
			lda #$e0 | 1
			sta o1, y
			lda #d1v0
			sta o2, y
			lda #$ff
			rts
		.botbounce:
			lda #$e8 | 1
			sta o1, y
			lda #d1v0 | 3
			sta o2, y
			lda #$ff
			rts
		.botnorm:
			lda #d1o2 | 1
			bne .tilest 
	.top:
		lda o4t0, x
		beq .topnorm
		cmp #o4b0
		beq .topbounce
			lda #$e0 | 1
			sta o1, y
			lda #%00000000
			sta o2, y
			lda #$ff
			rts
		.topbounce:
			lda #$e8 | 1
			sta o1, y
			lda #3
			sta o2, y
			lda #$ff
			rts
		.topnorm:
			lda #d1o0 | 1
	.tilest:
	sta o1, y
	rts
d1SD_speed:
	lda o4t0, x
	cmp #o4s2
	beq .spdup
		lda #2
		sta <d1SD_speeda0
		lda #0
		sta <d1SD_speedf0
		beq .loop 
	.spdup:
		lda #3
		sta <d1SD_speeda0
		lda #d1v0
		sta <d1SD_speedf0
	.loop:
		lda <d1SoftDrawObjsc1
		cmp o4y0, x
		beq .top
		lda <d1SoftDrawObjsc1
		clc
		adc #8
		bcc .b0
			rts
		.b0:
		sta o0, y
		lda <d1SoftDrawObjsc0
		sta o3, y
		lda <d1SoftDrawObjsn0
		cmp #1
		beq .bot
			lda <d1a0
			and #%11
			asl a
			clc
			adc #$f8 | 1
			sta o1, y
			lda <d1SD_speeda0
			ora <d1SD_speedf0
			sta o2, y
			bne .next 
		.bot:
			lda #$f6 | 1
			sta o1, y
			lda <d1SD_speeda0
			sta o2, y
			iny
			iny
			iny
			iny
			rts
		.top:
				sta o0, y
				lda #$f6 | 1
				sta o1, y
				lda <d1SD_speeda0
				sta o2, y
			lda <d1SoftDrawObjsc0
			sta o3, y
			iny
			iny
			iny
			iny
				lda <d1SoftDrawObjsc1
				clc
				adc #8
				bcs .end
				 sta o0, y
				lda <d1SoftDrawObjsc0
				 sta o3, y
				lda <d1a0
				and #%11
				asl a
				clc
				adc #$f8 | 1
				 sta o1, y
				lda <d1SD_speeda0
				ora <d1SD_speedf0
				 sta o2, y
				bne .next 
		.next:
		iny
		iny
		iny
		iny
		lda <d1SoftDrawObjsc1
		clc
		adc #16
		sta <d1SoftDrawObjsc1
		bcs .end
		cmp #240
		bcs .end
		dec <d1SoftDrawObjsn0
		beq .end
		jmp .loop
	.end: rts
d1SD_spike:
	lda <d1SoftDrawObjsc1
	cmp o4y0, x
	bne .bot
	.top:
			lda <d1SoftDrawObjsc0
			sta o3, y
			lda <d1SoftDrawObjsc1
			sta o0, y
			lda #$e2 | 1
			sta o1, y
			lda #1
			sta o2, y
			lda <d1SoftDrawObjsc0
			clc
			adc #8
			sta <d1SoftDrawObjsc0
			lda <d1SoftDrawObjsc0
			sta o3 + 4, y
			lda <d1SoftDrawObjsc1
			sta o0 + 4, y
			lda #$e4 | 1
			sta o1 + 4, y
			lda #1
			sta o2 + 4, y
			lda <d1SoftDrawObjsc0
			clc
			adc #8
			sta <d1SoftDrawObjsc0
			lda <d1SoftDrawObjsc0
			sta o3 + 8, y
			lda <d1SoftDrawObjsc1
			sta o0 + 8, y
			lda #$e4 | 1
			sta o1 + 8, y
			lda #1 | d1h0
			sta o2 + 8, y
			lda <d1SoftDrawObjsc0
			clc
			adc #8
			sta <d1SoftDrawObjsc0
			lda <d1SoftDrawObjsc0
			sta o3 + 12, y
			lda <d1SoftDrawObjsc1
			sta o0 + 12, y
			lda #$e2 | 1
			sta o1 + 12, y
			lda #1 | d1h0
			sta o2 + 12, y
			lda <d1SoftDrawObjsc0
			sec
			sbc #24
			sta <d1SoftDrawObjsc0
			tya
			clc
			adc #16
			tay
			lda <d1SoftDrawObjsc1
			clc
			adc #16
			sta <d1SoftDrawObjsc1
			bcs .end2
	.bot:
			lda <d1SoftDrawObjsc0
			sta o3, y
			lda <d1SoftDrawObjsc1
			sta o0, y
			lda #$e2 | 1
			sta o1, y
			lda #1 | d1v0
			sta o2, y
			lda <d1SoftDrawObjsc0
			clc
			adc #8
			sta <d1SoftDrawObjsc0
			lda <d1SoftDrawObjsc0
			sta o3 + 4, y
			lda <d1SoftDrawObjsc1
			sta o0 + 4, y
			lda #$e4 | 1
			sta o1 + 4, y
			lda #1 | d1v0
			sta o2 + 4, y
			lda <d1SoftDrawObjsc0
			clc
			adc #8
			sta <d1SoftDrawObjsc0
			lda <d1SoftDrawObjsc0
			sta o3 + 8, y
			lda <d1SoftDrawObjsc1
			sta o0 + 8, y
			lda #$e4 | 1
			sta o1 + 8, y
			lda #1 | %11000000
			sta o2 + 8, y
			lda <d1SoftDrawObjsc0
			clc
			adc #8
			sta <d1SoftDrawObjsc0
			lda <d1SoftDrawObjsc0
			sta o3 + 12, y
			lda <d1SoftDrawObjsc1
			sta o0 + 12, y
			lda #$e2 | 1
			sta o1 + 12, y
			lda #1 | %11000000
			sta o2 + 12, y
			lda <d1SoftDrawObjsc0
			clc
			adc #8
			sta <d1SoftDrawObjsc0
	tya
	clc
	adc #16
	tay
	.end2: rts
d1SD_thorn:
	lda <d1SoftDrawObjsn0
	cmp #2
	beq .top
	bne .bot
		lda o4y0, x
		clc
		adc #8
		bcc .b0
			bcs .sides
		.b0:
		clc
		adc #8
		bcc .end2
		bcs .bot
	.top:
		lda <d1SoftDrawObjsc0
		clc
		adc #8
		sta o3, y
		lda <d1SoftDrawObjsc1
		sta o0, y
		lda <d1t0
		clc
		adc #$c0 | 1
		sta o1, y
		lda #0
		sta o2, y
		iny
		iny
		iny
		iny
		lda <d1SoftDrawObjsc1
		clc
		adc #8
		bcs .end2
		sta <d1SoftDrawObjsc1
	.sides:
		jsr d1SD_thorn_l
		lda <d1SoftDrawObjsc0
		clc
		adc #16
		sta <d1SoftDrawObjsc0
		jsr d1SD_thorn_r
		lda <d1SoftDrawObjsc0
		sec
		sbc #16
		sta <d1SoftDrawObjsc0
		tya
		clc
		adc #8
		tay
		lda <d1SoftDrawObjsc1
		clc
		adc #8
		bcs .end2
		sta <d1SoftDrawObjsc1
	.bot:
		lda <d1SoftDrawObjsc1
		sta o0, y
		lda <d1SoftDrawObjsc0
		clc
		adc #8
		sta o3, y
		lda <d1t0
		clc
		adc #$d0 | 1
		sta o1, y
		lda #0
		sta o2, y
		iny
		iny
		iny
		iny
	.end2: rts
d1SD_thorn_l:
	lda <d1SoftDrawObjsc1
	sta o0, y
	lda <d1SoftDrawObjsc0
	sta o3, y
	lda <d1t0
	clc
	adc #$b0 | 1
	sta o1, y
	lda #0
	sta o2, y
	iny
	iny
	iny
	iny
	rts
d1SD_thorn_r:
	lda <d1SoftDrawObjsc1
	sta o0, y
	lda <d1SoftDrawObjsc0
	sta o3, y
	lda <d1t0
	clc
	adc #$b0 | 1
	sta o1, y
	lda #d1h0
	sta o2, y
	iny
	iny
	iny
	iny
	rts
d1SD_thorn_l_dbl:
	lda <d1SoftDrawObjsn0
	cmp #2
	bne .b0
		jsr d1SD_thorn_l
		lda <d1SoftDrawObjsc1
		clc
		adc #16
		sta <d1SoftDrawObjsc1
		bcs .end
	.b0:
	jsr d1SD_thorn_l
	.end: rts
d1SD_thorn_r_dbl:
	lda <d1SoftDrawObjsn0
	cmp #2
	bne .b0
		jsr d1SD_thorn_r
		lda <d1SoftDrawObjsc1
		clc
		adc #16
		sta <d1SoftDrawObjsc1
		bcs .end
	.b0:
	jsr d1SD_thorn_r
	.end: rts
d1sd_thorn_l_flip_tiles:
	.db $c4|1, $c6|1 
	.db $c8|1, $ca|1 
	.db $c8|1, 0 	 
	.db $c4|1, 0 	 
d1SD_thorn_l_flip:
	lda <o4t16
	cmp #4
	bcs .b0
		jmp d1SD_thorn_l_dbl
	.b0:
	lda #0
	sta <d1SD_thorn_flippingf0
	lda #HIGH(d1sd_thorn_l_flip_tiles)
	sta <d1SD_thorn_flippinga0+1
	lda <d1SoftDrawObjsc0
	sta <d1t3
	lda <o4t14
	sec
	sbc <o4t15
	cmp #8
	bcs .b1
		and #%11111110
		clc
		adc #LOW(d1sd_thorn_l_flip_tiles)
		sta <d1SD_thorn_flippinga0
		lda <d1SD_thorn_flippinga0+1
		adc #0
		sta <d1SD_thorn_flippinga0+1
		bne d1SD_thorn_flipping
	.b1:
	jmp d1SD_thorn_l_dbl
	rts
d1SD_thorn_flipping:
	txa
	pha
	tya
	tax 
	ldy #0
	.loop:
		lda [d1SD_thorn_flippinga0], y
		beq .r
		sta o1, x
		lda <d1SoftDrawObjsc1
		sta o0, x
		lda <d1SD_thorn_flippingf0
		sta o2, x
		lda <d1t3
		sta o3, x
		.r:
		iny
		lda [d1SD_thorn_flippinga0], y
		beq .next
		sta o1 + 4, x
		lda <d1t3
		clc
		adc #8
		sta o3 + 4, x
		lda <d1SoftDrawObjsc1
		sta o0 + 4, x
		lda <d1SD_thorn_flippingf0
		sta o2 + 4, x
		.next:
		dey
		txa
		clc
		adc #8
		tax
		lda <d1SoftDrawObjsc1
		clc
		adc #16
		sta <d1SoftDrawObjsc1
		bcs .end
		dec <d1SoftDrawObjsn0
		lda <d1SoftDrawObjsn0
		cmp #1
		beq .loop 
	.end:
	txa
	tay 
	pla
	tax
	rts
d1sd_thorn_r_flip_tiles:
	.db 0,	   $c4|1 
	.db 0,	   $c8|1 
	.db $ca|1, $c8|1 
	.db $c6|1, $c4|1 
d1SD_thorn_r_flip:
	lda <o4t16
	cmp #4
	bcs .b0
		jmp d1SD_thorn_r_dbl
	.b0:
	lda #d1h0
	sta <d1SD_thorn_flippingf0
	lda #HIGH(d1sd_thorn_r_flip_tiles)
	sta <d1SD_thorn_flippinga0+1
	lda <d1SoftDrawObjsc0
	sec
	sbc #8
	sta <d1t3
	lda <o4t14
	sec
	sbc <o4t15
	cmp #8
	bcs .b1
		and #%11111110
		clc
		adc #LOW(d1sd_thorn_r_flip_tiles)
		sta <d1SD_thorn_flippinga0
		lda <d1SD_thorn_flippinga0+1
		adc #0
		sta <d1SD_thorn_flippinga0+1
		jmp d1SD_thorn_flipping
	.b1:
	jmp d1SD_thorn_r_dbl
	rts
d1timerwalltiles:
	.db $b4|1, $22|1, $24|1, 0 
	.db $20|1, $22|1, $24|1, $46|1 
d1SD_timer:
	txa
	pha
	lda o4y0, x
	sta <d1SD_timery0
		lda o4t0, x
		sec
		sbc #o4s3
		asl a
		asl a
		tax
	lda <d1SoftDrawObjsc0
	sec
	sbc #4
	sta <d1SD_timerx0
	lda <o4t16
	cmp #4
	bcs .action
	jmp .norm
	.action:
		pla
		tax
		lda o4t0, x
		cmp #o4f0
		bne .b0
			jmp d1SD_flip
		.b0:
		lda <d1d1
		bpl .shocksoundend
		lda <o4t14
		sec
		sbc <o4t15
		bne .shocksoundend
			lda <b10
			ora #b3
			sta <b10
		.shocksoundend:
			lda <d1a0
			and #%10
			bne .b1
				lda #16
				bne .shockst 
			.b1:
			lda #0
		.shockst:
		sta <d1SD_timern0
			lda <d1SoftDrawObjsn0
			cmp #2
			beq .smiddle
			cmp #1
			bne .stop
			jmp .sbottom
		.stop:
			lda <d1SD_timerx0
			sta o3, y
			lda <d1SoftDrawObjsc1
			sta o0, y
			lda #$80 | 1
			clc
			adc <d1SD_timern0
			sta o1, y
			lda #2
			sta o2, y
			lda <d1SD_timerx0
			clc
			adc #8
			sta o3 + 4, y
			lda <d1SoftDrawObjsc1
			sta o0 + 4, y
			lda #$82 | 1
			clc
			adc <d1SD_timern0
			sta o1 + 4, y
			lda #2
			sta o2 + 4, y
		tya
		clc
		adc #8
		tay
		lda <d1SoftDrawObjsc1
		clc
		adc #16
		sta <d1SoftDrawObjsc1
		bcs .send
		.smiddle:
			lda <d1SD_timerx0
			sta o3, y
			lda <d1SoftDrawObjsc1
			sta o0, y
			lda #$84 | 1
			clc
			adc <d1SD_timern0
			sta o1, y
			lda #2
			sta o2, y
			lda <d1SD_timerx0
			clc
			adc #8
			sta o3 + 4, y
			lda <d1SoftDrawObjsc1
			sta o0 + 4, y
			lda #$86 | 1
			clc
			adc <d1SD_timern0
			sta o1 + 4, y
			lda #2
			sta o2 + 4, y
		tya
		clc
		adc #8
		tay
		lda <d1SoftDrawObjsc1
		clc
		adc #16
		sta <d1SoftDrawObjsc1
		bcs .send
		.sbottom:
			lda <d1SD_timerx0
			sta o3, y
			lda <d1SoftDrawObjsc1
			sta o0, y
			lda #$88 | 1
			clc
			adc <d1SD_timern0
			sta o1, y
			lda #2
			sta o2, y
			lda <d1SD_timerx0
			clc
			adc #8
			sta o3 + 4, y
			lda <d1SoftDrawObjsc1
			sta o0 + 4, y
			lda #$8a | 1
			clc
			adc <d1SD_timern0
			sta o1 + 4, y
			lda #2
			sta o2 + 4, y
		tya
		clc
		adc #8
		tay
		.send: rts
	.norm:
		cmp #3
		bne .noffs
			lda <d1a0
			and #%100
			bne .b2
				lda <o4t16
				clc
				adc #1
				bne .noffs 
			.b2:
			lda <o4t16
		.noffs:
		asl a
		asl a 
		sta <d1SD_timern0
			lda <d1SoftDrawObjsc1
			cmp <d1SD_timery0
			beq .top
			lda <d1SoftDrawObjsn0
			cmp #2
			bcs .middle
			cmp #1
			bne .b3
				jmp .bottom
			.b3:
		.top:
			lda <d1SD_timerx0
			sta o3, y
			lda <d1SoftDrawObjsc1
			sta o0, y
			lda d1timerwalltiles, x
			sta o1, y
			lda #3
			sta o2, y
			lda <d1SD_timerx0
			clc
			adc #8
			sta o3 + 4, y
			lda <d1SoftDrawObjsc1
			sta o0 + 4, y
			lda d1timerwalltiles, x
			sta o1 + 4, y
			lda #3 | d1h0
			sta o2 + 4, y
		tya
		clc
		adc #8
		tay
		lda <d1SoftDrawObjsc1
		clc
		adc #16
		sta <d1SoftDrawObjsc1
		bcc .b4
			jmp .end
		.b4:
		dec <d1SoftDrawObjsn0
		.middle:
				lda <d1SoftDrawObjsn0
				and #1
				beq .b5
					lda <d1SD_timern0
					ora #%10000000
					sta <d1SD_timern0
				.b5:
			lda <d1SoftDrawObjsc1
			sta o0, y
			lda <d1SD_timerx0
			sta o3, y
				lda <d1SD_timern0
				bmi .oddml
				clc
				adc d1timerwalltiles + 1, x
				bne .middlelst 
				.oddml:
				lda d1timerwalltiles + 3, x
			.middlelst:
			sta o1, y
			lda #3
			sta o2, y
		.middler:
			lda <d1SD_timerx0
			clc
			adc #8
			sta o3 + 4, y
			lda <d1SoftDrawObjsc1
			sta o0 + 4, y
				lda <d1SD_timern0
				bmi .oddmr
				clc
				adc d1timerwalltiles + 2, x
			sta o1 + 4, y
			lda #3
			sta o2 + 4, y
			bne .middledone
			.oddmr:
			lda d1timerwalltiles + 3, x
			sta o1 + 4, y
			lda #3 | d1h0
			sta o2 + 4, y
		.middledone:
		tya
		clc
		adc #8
		tay
		lda <d1SoftDrawObjsc1
		clc
		adc #16
		sta <d1SoftDrawObjsc1
		bcs .end
		lda <d1SD_timern0
		and #%01111111
		sta <d1SD_timern0
		dec <d1SoftDrawObjsn0
		lda <d1SoftDrawObjsn0
		cmp #2
		bcs .middle
		.bottom:
			lda <d1SoftDrawObjsc1
			sta o0, y
			lda <d1SD_timerx0
			sta o3, y
			lda d1timerwalltiles, x
			sta o1, y
			lda #3 | d1v0
			sta o2, y
			lda <d1SD_timerx0
			clc
			adc #8
			sta o3 + 4, y
			lda <d1SoftDrawObjsc1
			sta o0 + 4, y
			lda d1timerwalltiles, x
			sta o1 + 4, y
			lda #3 | %11000000
			sta o2 + 4, y
		tya
		clc
		adc #8
		tay
	.end:
	pla
	tax
	rts
d1flippingwalltiles:
	.db $36|1, $3c|1, $38|1, $3a|1 
	.db $3c|1, $3e|1, $40|1, $42|1 
	.db $3e|1, $3c|1, $42|1, $40|1 
	.db $3c|1, $36|1, $3a|1, $38|1 
	.db $20|1, $20|1, $44|1, $44|1 
d1flippingwallattrs:
	.db 3, 3|d1h0, 3, 3
	.db 3, 3, 3, 3
	.db 3|d1h0, 3|d1h0, 3|d1h0, 3|d1h0
	.db 3, 3|d1h0, 3|d1h0, 3|d1h0
	.db 3, 3|d1h0, 3, 3|d1h0
d1flippingbetweentiles:
	.db $48|1, $4a|1, 0, 0
	.db $4a|1, $4c|1, 0, 0
	.db $4c|1, $4a|1, 0, 0
	.db $4a|1, $48|1, 0, 0
	.db $46|1, $46|1, 0, 0
d1flippingbetweenattrs:
	.db 3, 3|d1h0, 0, 0
	.db 3, 3, 0, 0
	.db 3|d1h0, 3|d1h0, 0, 0
	.db 3, 3|d1h0, 0, 0
	.db 3, 3|d1h0, 0, 0
d1SD_flip:
	txa
	pha
	lda <o4t14
	sec
	sbc <o4t15
	pha
	cmp #8
	bcs .straighton
	asl a
	and #%11111100
	tax
	bpl .st 
	.straighton:
		ldx #16
	.st:
		lda <d1SoftDrawObjsc1
		cmp <d1SD_timery0
		beq .top
		lda <d1SoftDrawObjsn0
		cmp #2
		bcs .med
		cmp #1
		bne .b0
			jmp .bot
		.b0:
	.top:
		lda <d1SD_timerx0
		sta o3, y
		lda <d1SoftDrawObjsc1
		sta o0, y
		lda d1flippingwalltiles, x
		sta o1, y
		lda d1flippingwallattrs, x
		sta o2, y
		lda <d1SD_timerx0
		clc
		adc #8
		sta o3 + 4, y
		lda <d1SoftDrawObjsc1
		sta o0 + 4, y
		lda d1flippingwalltiles + 1, x
		sta o1 + 4, y
		lda d1flippingwallattrs + 1, x
		sta o2 + 4, y
		lda <d1SoftDrawObjsc1
		clc
		adc #16
		bcc .b1
			jmp .end
		.b1:
		sta <d1SoftDrawObjsc1
		tya
		clc
		adc #8
		tay
		dec <d1SoftDrawObjsn0
	.med:
			lda d1flippingwalltiles + 2, x
			sta <d1t4
			lda d1flippingwalltiles + 3, x
			sta <d1t4+1
			lda d1flippingwallattrs + 2, x
			sta <d1a1
			lda d1flippingwallattrs + 3, x
			sta <d1a1+1
			lda <d1SoftDrawObjsn0
			and #1
			beq .b2
				lda d1flippingbetweentiles, x
				sta <d1t4
				lda d1flippingbetweentiles+1, x
				sta <d1t4+1
				lda d1flippingbetweenattrs, x
				sta <d1a1
				lda d1flippingbetweenattrs+1, x
				sta <d1a1+1
			.b2:
		lda <d1SD_timerx0
		sta o3, y
		lda <d1SoftDrawObjsc1
		sta o0, y
		lda <d1t4
		sta o1, y
		lda <d1a1
		sta o2, y
		lda <d1SD_timerx0
		clc
		adc #8
		sta o3 + 4, y
		lda <d1SoftDrawObjsc1
		sta o0 + 4, y
		lda <d1t4 + 1
		sta o1 + 4, y
		lda <d1a1 + 1
		sta o2 + 4, y
		lda <d1SoftDrawObjsc1
		clc
		adc #16
		bcs .end
		sta <d1SoftDrawObjsc1
		tya
		clc
		adc #8
		tay
		dec <d1SoftDrawObjsn0
		lda <d1SoftDrawObjsn0
		cmp #2
		bcs .med
	.bot:
		lda <d1SD_timerx0
		sta o3, y
		lda <d1SoftDrawObjsc1
		sta o0, y
		lda d1flippingwalltiles, x
		sta o1, y
		lda d1flippingwallattrs, x
		ora #d1v0
		sta o2, y
		lda <d1SD_timerx0
		clc
		adc #8
		sta o3 + 4, y
		lda <d1SoftDrawObjsc1
		sta o0 + 4, y
		lda d1flippingwalltiles + 1, x
		sta o1 + 4, y
		lda d1flippingwallattrs + 1, x
		ora #d1v0
		sta o2 + 4, y
		tya
		clc
		adc #8
		tay
	.end:
	pla
	bne .flipsoundend
	lda <d1d1
	bpl .flipsoundend
		lda <b10
		ora #b4
		sta <b10
	.flipsoundend:
	pla
	tax
	rts
d1crumblytiles:
	.db $00|1, $02|1, $ff, $ff
	.db $04|1, $06|1, $ff, $ff
	.db $08|1, $0a|1, $ff, $ff
	.db $0c|1, $0e|1, $10|1, $ff
	.db $12|1, $14|1, $16|1, $ff
	.db $18|1, $1a|1, $ff, $ff
	.db $1c|1, $1e|1, $ff, $ff
d1SD_crumble:
	txa
	pha
		lda o4t0, x
		sec
		sbc #o4c0
		asl a
		asl a
		tax
	lda <d1SoftDrawObjsn0
	cmp #2
	bne .bot
	lda <d1SoftDrawObjsc0
	sta o3, y
	lda <d1SoftDrawObjsc1
	sta o0, y
	lda d1crumblytiles, x
	sta o1, y
	lda #1
	sta o2, y
	lda <d1SoftDrawObjsc1
	clc
	adc #16
	bcs .end
	sta <d1SoftDrawObjsc1
	iny
	iny
	iny
	iny
	.bot:
	lda <d1SoftDrawObjsc0
	sta o3, y
	lda <d1SoftDrawObjsc1
	sta o0, y
	lda d1crumblytiles+1, x
	sta o1, y
	lda #1
	sta o2, y
	lda <d1SoftDrawObjsc1
	clc
	adc #16
	bcs .end
	sta <d1SoftDrawObjsc1
	iny
	iny
	iny
	iny
	lda d1crumblytiles+2, x
	bmi .end 
	sta o1, y
	lda <d1SoftDrawObjsc0
	sta o3, y
	lda <d1SoftDrawObjsc1
	sta o0, y
	lda #1
	sta o2, y
	iny
	iny
	iny
	iny
	.end:
	pla
	tax
	rts
d1IncreaseScore:
	inc <d1s2
	lda <d1s2
	cmp #10
	bcc .end
		lda #0
		sta <d1s2
		inc <d1s2+1
		bne .b0
			inc <d1s2+1 
		.b0:
		lda <d1s2+1
		cmp #10
		bcc .end
			lda #0
			sta <d1s2+1
			inc <d1s2+2
			bne .b1
				inc <d1s2+2
			.b1:
			lda <d1s2+2
			cmp #10
			bcc .end
				lda #0
				sta <d1s2+2
				inc <d1s2+3
				bne .b2
					inc <d1s2+3
				.b2:
	.end: rts
d1SD_score:
		lda #0
		sta <d1SD_scores0
		ldx #1
		.posloop:
			lda <d1s2, x
			bmi .posloopend
			inc <d1SD_scores0
			inx
			cpx #4
			bne .posloop
		.posloopend:
		lda <d1SD_scores0
		asl a
		asl a
		sta <d1SD_scores0
		lda #124
		clc
		adc <d1SD_scores0
		sta <d1SD_scorex0
	ldy <d1o3
	ldx #0
	.loop:
		lda <d1s2, x
		bmi .end
		asl a
		clc
		adc #d1t5
		sta o1, y
		lda <d1SD_scorex0
		sta o3, y
		lda #d1y0
		sta o0, y
		lda #2
		sta o2, y
		iny
		iny
		iny
		iny
		lda <d1SD_scorex0
		sec
		sbc #8
		sta <d1SD_scorex0
		inx
		cpx #4
		bcc .loop
	.end:
	sty <d1o3
	rts
d1shakes:
	.db 4, 4, -4, -4, 3, 3, -3, -3, 3, 3, -3, -3, 2, 2, -2, -2, 2, 2, -2, -2, 1, 1, -1, -1, 1, 1, -1, -1, 1, 1, -1, -1
d1shakesend:
d1explosiontiles:
	.db $bc|1, $cc|1, $dc|1, $ec|1, $50|1, $54|1, $8c|1
d1SD_deathSq:
	lda <d1e0
	cmp #$ff
	beq .end0
	lda <d1d1
	bmi .end0
	cmp #0
	bne .b0
		jmp d1BuffAllWhite 
	.b0:
	cmp #2
	bcs .b1
		.end0: rts
	.b1:
	bne .b2
		pha
		lda #$ff 
		ldx #0
		jsr d1BuffPals 
		pla
	.b2:
	sec
	sbc #2
	pha
		tax
		cmp #d1shakesend - d1shakes
		bcs .noshake
			lda d1shakes, x
			bne .shakeend 
			.noshake:
			lda #0
		.shakeend:
		sta <d1x0
	pla
	cmp #28
	bcc .b3
		bne .end
		lda #0
		tax
		jmp d1BuffPals
	.b3:
	and #%11111100 
	lsr a
	lsr a
	tax
	lda d1explosiontiles, x
	sta <d1e2
	ldx <d1o3
	ldy #0
	.explloop:
			tya
			and #1
			beq .b4
				lda <d1e2
				eor #%10
				sta <d1e2
			.b4:
			lda <d1e2
			sta o1, x
			tya
			and #%11
			asl a
			asl a
			asl a
			clc
			adc <d1e0
			sec
			sbc #8
			sta o3, x
			tya
			and #%100
			asl a
			asl a
			clc
			adc <d1e1
			sta o0, x
			tya
			and #%110 
			asl a
			asl a
			asl a
			asl a
			asl a
			ora #1
			sta o2, x
		inx
		inx
		inx
		inx
		iny
		cpy #8
		bne .explloop
	stx <d1o3
	.end: rts
d1BuffAllWhite:
	ldx <d1b1
		lda #32
		sta d1p0, x
		tay
		inx
		lda #$3f
		sta d1p0, x
		inx
		lda #0
		sta d1p0, x
		inx
	lda #$20 
	.loop:
		sta d1p0, x
		inx
		dey
		bne .loop
	stx <d1b1
	stx $01a6
	rts
d1BuffPals: 
	pha
	ldx <d1b1
		lda #32
		sta d1p0, x
		inx
		lda #$3f
		sta d1p0, x
		inx
		lda #0
		sta d1p0, x
		inx
	ldy #0
	.loop:
		lda d1b0, y
		sta d1p0, x
		inx
		iny
		cpy #32
		bne .loop
	pla
	beq .end
	bpl .crown
		lda #$06
		sta d1p0-11, x
		lda #$38
		sta d1p0-10, x
		lda #$20
		sta d1p0-9, x
		bne .end 
	.crown:
		lda #$0d
		sta d1p0-11, x
		lda #$18
		sta d1p0-10, x
		lda #$28
		sta d1p0-9, x
	.end:
	stx <d1b1
	rts
d1sky_cols:
	.db $31, $32, $33, $34, $35, $36, $26
d1sky_cols_end:
d1sky_col_levels:
	.db 9,  29,  59,  89, 138, 174, 199
d1UpdateSkyColor:
	ldx d1s5
	cpx #d1n1
	bcs .end
	lda <c4h0
	cmp d1sky_col_levels, x
	bne .end
	ldx d1s5
	inc d1s5
	lda d1sky_cols, x
	sta d1b0+$10
	lda #0
	jmp d1BuffPals
	.end: rts
d1ClearPPUBuff:
	ldy <d1b1
	beq .end
	lda #0
	.loop:
		dey
		sta d1p0, y
		cpy #0
		bne .loop
	sty <d1b1
	.end: rts
d1mmonkeytiles:
	.db $00, $02, $04, $06, $08, $0a, 0, 0 
	.db $00, $02, $04, $06, $0c, $0e, 0, 0 
	.db $10, $12, $14, $16, $18, $1a, 0, 0 
	.db $10, $12, $14, $16, $1c, $1e 
	.db $20, $22, $24, $26, $28, $2a 
	.db $2c, $2e, $30, $32, $34, $36 
	.db $38, $3a, $3c, $3e, $40, $42 
d1SD_monkey:
	lda <m8b8, x
	and #m8b4
	beq .b0
		rts
	.b0:
	lda <m8b8, x
	and #m8b5
	beq .arrowend
	lda <m8x0, x
	cmp #$f0
	bcs .arrowend
		ldy <d1o3
		lda #d1a2
		sta o1, y
		lda <m8y0, x
		clc
		adc #12
		sta o0, y
		cpx #2
		beq .arrowpal2
			lda #0
			beq .arrowpalst
		.arrowpal2:
			lda c4m0
		.arrowpalst:
		sta o2, y
		lda <m8x0, x
		bmi .arrowl
			lda #256 - 16
			sta o3, y
			lda o2, y
			ora #d1h0
			sta o2, y
			bne .arrowrest 
		.arrowl:
			lda #8
			sta o3, y
		.arrowrest:
		iny
		iny
		iny
		iny
		sty <d1o3
	.arrowend:
			lda <m8b8, x
			and #m8b5
			cmp #1
			lda #0
			rol a
			sta <d1SD_monkeyo0
		lda <m8x0, x
		sta <d1SD_monkeyx0
		pha
		lda <m8y0, x
		sta <d1SD_monkeyy0
		lda #8
		sta <d1SD_monkeya1
		lda #16
		sta <d1SD_monkeya2
		lda <m8b8, x
		bpl .b1
			pla
			clc
			adc #16
			sta <d1SD_monkeyx0
			pha
			bcc .offend
				lda <d1SD_monkeyo0
				eor #1
				sta <d1SD_monkeyo0
			.offend:
			lda #-8
			sta <d1SD_monkeya1
			lda <d1SD_monkeya0
			ora #d1h0
			sta <d1SD_monkeya0
		.b1:
	lda <m8s0, x
	cmp #m8j1
	beq .jump
	cmp #m8b7
	beq .bflip
	txa 
	asl a
	asl a
	asl a
	eor <d1a0
	eor #%11000
	and #%11000 
	tax
	bpl .draw 
	.jump:
	ldx #30
	bne .draw 
	.bflip:
		lda <d1a0
		and #%100
		bne .fliph
			lda #-16
			sta <d1SD_monkeya2
			lda <d1SD_monkeyy0
			clc
			adc #16
			sta <d1SD_monkeyy0
			lda <d1SD_monkeya0
			ora #d1v0
			sta <d1SD_monkeya0
			bne .bflipx 
		.fliph:
			lda <d1SD_monkeya0
			eor #d1h0
			sta <d1SD_monkeya0
			pla
			lda <d1SD_monkeya1
			asl a
			bmi .flipxmi
				clc
				adc <d1SD_monkeyx0
				sta <d1SD_monkeyx0
				bcc .flipaddx
				lda <d1SD_monkeyo0
				eor #1
				sta <d1SD_monkeyo0
				bpl .flipaddx 
			.flipxmi:
				clc
				adc <d1SD_monkeyx0
				sta <d1SD_monkeyx0
				bcs .flipaddx
				lda <d1SD_monkeyo0
				eor #1
				sta <d1SD_monkeyo0
			.flipaddx:
			lda <d1SD_monkeyx0
			pha 
			lda <d1SD_monkeya1
			sec
			sbc #1
			eor #$ff
			sta <d1SD_monkeya1
		.bflipx:
		lda <d1a0
		and #%10
		bne .b2
			ldx #36
			bne .draw 
		.b2:
		ldx #42
	.draw:
	lda <d1SD_monkeyo0
	pha
	lda #0
	sta <d1SD_monkeyc0
	ldy <d1o3
	.loop:
		lda <d1SD_monkeyo0
		bne .nexto
		lda <d1SD_monkeyx0
		sta o3, y
		lda <d1SD_monkeyy0
		sta o0, y
		lda d1mmonkeytiles, x
		sta o1, y
		lda <d1SD_monkeya0
		sta o2, y
		iny
		iny
		iny
		iny
		.nexto:
		inx
		inc <d1SD_monkeyc0
		lda <d1SD_monkeyc0
		cmp #3
		beq .3
		cmp #6
		beq .end
			lda <d1SD_monkeya1
			bmi .addxmi
				clc
				adc <d1SD_monkeyx0
				sta <d1SD_monkeyx0
				bcc .addxend
				lda <d1SD_monkeyo0
				eor #1
				sta <d1SD_monkeyo0
				bpl .addxend 
			.addxmi:
				clc
				adc <d1SD_monkeyx0
				sta <d1SD_monkeyx0
				bcs .addxend
				lda <d1SD_monkeyo0
				eor #1
				sta <d1SD_monkeyo0
			.addxend:
			jmp .loop
		.3:
			pla
			sta <d1SD_monkeyo0
			pla
			sta <d1SD_monkeyx0
			lda <d1SD_monkeya2
			bmi .addymi
				lda <d1SD_monkeyy0
				clc
				adc <d1SD_monkeya2
				sta <d1SD_monkeyy0
				bcs .end
				bcc .loop
			.addymi:
				lda <d1SD_monkeyy0
				clc
				adc <d1SD_monkeya2
				sta <d1SD_monkeyy0
				bcc .end
				bcs .loop
	.end:
	sty <d1o3
	rts
d1SD_monkeys:
	ldx #1
	lda #0
	sta <d1SD_monkeya0
	jsr d1SD_monkey
	lda <b10
	and #b6
	bne .b0
		rts
	.b0:
	ldx #2
	lda c4m0
	sta <d1SD_monkeya0
	jmp d1SD_monkey
d1SD_monkeyTails:
	lda <m8b8+1
	and #m8b5 | m8b4
	bne .monkey2
	lda <m8s0+1
	cmp #m8j1
	bne .monkey2
		ldx #1
		jsr .draw
	.monkey2:
	lda <m8b8+2
	and #m8b5 | m8b4
	bne .end
	lda <m8s0+2
	cmp #m8j1
	bne .end
		ldx #2
		jmp .draw
	.end: rts
	.draw:
		ldy <d1o3
		lda <m8y0, x
		clc
		adc #d1t9
		bcs .drawret
		sta o0, y
		lda #d1t6
		sta o1, y
		lda <m8b8, x
		pha
		and #m8b0
		lsr a
		sta o2, y
			cpx #2
			beq .pal2
				lda #0
				beq .palst
			.pal2:
				lda c4m0
			.palst:
		ora o2, y
		sta o2, y
		pla
		bpl .b0
			lda #d1t8
			bne .drawend 
		.b0:
		lda #d1t7
		.drawend:
		clc
		adc <m8x0, x
		sta o3, y
		iny
		iny
		iny
		iny
		sty <d1o3
		.drawret: rts
d1FadeToWhite:
	ldy #0
	.writeloop:
		lda d1b0, y
		sta d1p0+3, y
		iny
		cpy #32
		bne .writeloop
	sty d1p0
	lda #$3f
	sta d1p0+1
	ldy #0
	sty d1p0+2
	ldx #0
	.fadeloop:
		lda d1p0+3, x
		cmp #d1w0
		bne .b0
			iny
			bne .next 
		.b0:
		and #$f0
		cmp #$30
		bne .b1
			lda #d1w0
			sta d1p0+3, x
			iny
			bne .next 
		.b1:
		lda d1p0+3, x
		clc
		adc #$10
		sta d1p0+3, x
		.next:
		inx
		cpx #32
		bne .fadeloop
	cpy #32
	beq .b2
		lda <b10
		ora #b0
		sta <b10
		ldx #2
		.waitloop:
			txa
			pha
			jsr f3FamiToneUpdate
			jsr c4TitleSpr0
			pla
			tax
			.waitwait:
				lda $2002
				bpl .waitwait
			dex
			bne .waitloop
			ldy #0
			beq .fadeloop 
	.b2:
	ldx #2
	jsr c3WaitNumFrames
	rts
d1FadeToBase:
	ldx #0
	ldy #4
	.writeloop:
		lda d1b0, x
		and #$0f
		ora #$30
		sta d1p0+3, x
		inx
		cpx #32
		bne .writeloop
		stx <d1b1
		beq .2framer
	.fadeloop:
		lda d1p0+3, x
		cmp gamepals, x
		bne .b0
			beq .next 
		.b0:
		sec
		sbc #$10
		sta d1p0+3, x
		.next:
		inx
		cpx #32
		bne .fadeloop
	dey
	beq .b1
		.2framer:
		ldx #2
		jsr c3WaitNumFrames
		jmp .fadeloop
	.b1:
	rts
d1tiewordtiles:
	.db $44, $46, $48, $4a
d1smoothtieys:
	.db -2, 0, 2, 4, 5, 6, 5, 4, 2, 0, -2, -4, -5, -6, -5, -4
d1SD_tie_word:
	lda #128 - ((8 * 4) / 2)
	sta <d1SD_tie_wordx0
	ldx #0
	ldy <d1o3
	.loop:
		lda d1tiewordtiles, x
		sta o1, y
		lda #2
		sta o2, y
		lda <c2
		and #%11111100
		lsr a
		lsr a
		sta <d1c0
		txa
		pha
		clc
		adc <d1c0
		and #%1111
		tax
		lda d1smoothtieys, x
		clc
		adc <c4t1
		sta o0, y
		pla
		tax
		lda <d1SD_tie_wordx0
		sta o3, y
		iny
		iny
		iny
		iny
		inx
		lda <d1SD_tie_wordx0
		clc
		adc #8
		sta <d1SD_tie_wordx0
		cpx #4
		bne .loop
	sty <d1o3
	rts
d1SD_crown:
	lda <c2
	and #%11
	bne .frameincend
		lda <d1c1
		clc
		adc #1
		sta <d1c1
		cmp #3
		bcc .frameincend
		lda #0
		sta <d1c1
	.frameincend:
	ldy <d1o3
	lda #1
	sta o2, y
	sta o2+4, y
	sta o2+8, y
	lda <c4c1
	sta o0, y
	sta o0+4, y
	sta o0+8, y
			lda <d1c1
			asl a
			asl a
			sta <d1f2
			lda <d1c1
			asl a
			clc
			adc <d1f2
			adc #d1c2
		sta o1, y
		adc #2
		sta o1+4, y
		adc #2
		sta o1+8, y
	lda #d1c3
	sta o3, y
	lda #d1c3+8
	sta o3+4, y
	lda #d1c3+16
	sta o3+8, y
	tya
	clc
	adc #12
	sta <d1o3
	rts
d1effecttiles:
	.db $b6|1, $b8|1, $ba|1 
d1SD_effects:
	ldx #0
	lda f4e1
	beq .next
	jsr .draw
	.next:
	ldx #f4e7
	lda f4e1 + f4e7
	beq .end
	bne .draw 
	.end: rts
	.draw:
		ldy <d1o3
		lda f4e4, x
		sta o3, y
		lda f4e5, x
		sta o0, y
		lda f4e1, x
		and #d1h0
		ora #2
		sta o2, y
		lda f4e1, x
		and #%1111
		tax
		lda d1effecttiles, x
		sta o1, y
		iny
		iny
		iny
		iny
		sty <d1o3
		rts
d1cloudtiles:
	.db $9c|1, $9e|1, $ac|1, $ae|1, $58|1, $9a
d1SD_cloud:
	lda #d1c5
	sta <d1SD_cloudy0
	lda <d1c4
	sta <d1SD_cloudx0
	ldx #0
	ldy <d1o3
	beq .end 
	.loop:
		lda d1cloudtiles, x
		sta o1, y
		lda <d1SD_cloudy0
		sta o0, y
		txa
		asl a
		asl a
		asl a
		clc
		adc <d1SD_cloudx0
		sta o3, y
		lda #2 | %00100000
		sta o2, y
		iny
		iny
		iny
		iny
		beq .end 
		inx
		cpx #6
		bne .loop
	lda <d1SD_cloudy0
	cmp #d1c5
	bne .b0
		clc
		adc #16
		sta <d1SD_cloudy0
		lda <d1SD_cloudx0
		clc
		adc #98
		sta <d1SD_cloudx0
		ldx #0
		beq .loop
	.b0:
	.end:
	sty <d1o3
	rts
	

m8startx:
	.db 0, 60, 106
m8starty:
	.db 0, 120, 120
m8initbools:
	.db 0, m8b1, m8b1 | m8b0
m8initwallinds:
	.db 0, o4o0, 0
m8Init:
	lda <b10
	and #b1 ^ $ff
	sta <b10
	ldx #2
	.loop:
		lda #0
		sta <m8x1, x
		sta <m8y1, x
		sta <m8i2, x
		sta <m8u1, x
		lda m8startx, x
		sta <m8x0, x
		lda m8starty, x
		sta <m8y0, x
		lda m8initbools, x
		sta <m8b8, x
		lda #m8i1
		sta <m8s0, x
		lda #1
		sta <m8y1, x
		lda #$ff
		sta <m8t0, x
		lda m8initwallinds, x
		sta <m8w1, x
		dex
		bne .loop
	rts
m8UpdateBothMonkeys:
	ldx #1
	.loop:
			lda <i0b8, x
			sta <i0b8
			lda <i0b9, x
			sta <i0b9
			lda <m8b8, x
			sta <m8b8
			lda <m8x0, x
			sta <m8x0
			lda <m8y0, x
			sta <m8y0
			lda <m8x1, x
			sta <m8x1
			lda <m8y1, x
			sta <m8y1
			lda <m8s0, x
			sta <m8s0
			lda <m8u1, x
			sta <m8u1
			lda <m8w1, x
			sta <m8w1
			lda <m8t0, x
			sta <m8t0
			lda <m8t1, x
			sta <m8t1
			lda <m8i2, x
			sta <m8i2
		txa
		pha
		jsr m8Update
		pla
		tax
			lda <m8i2
			sta <m8i2, x
			lda <m8t0
			sta <m8t0, x
			lda <m8t1
			sta <m8t1, x
			lda <m8b8
			sta <m8b8, x
			lda <m8x0
			sta <m8x0, x
			lda <m8y0
			sta <m8y0, x
			lda <m8x1
			sta <m8x1, x
			lda <m8y1
			sta <m8y1, x
			lda <m8s0
			sta <m8s0, x
			lda <m8u1
			sta <m8u1, x
			lda <m8w1
			sta <m8w1, x
		lda <b10
		and #b6
		beq .end 
		lda <b10
		eor #b5
		sta <b10
		inx
		cpx #3
		bcc .loop
	.end: rts
m8Update:
	lda <m8i2
	beq .b0
		dec <m8i2
	.b0:
	lda <m8t0
	cmp #$ff
	beq .targend
		cmp <m8x0
		bne .followtarg
			lda <m8t1
			cmp <m8y0
			beq .targoff
		.followtarg:
		jsr m8FollowTarg
		jmp .jump
		.targoff:
		lda #$ff
		sta <m8t0
		lda <b10
		and #b1 ^ $ff
		sta <b10
	.targend:
	lda <m8b8
	and #m8b1
	bne .onwall
		lda <m8u1
		beq .nouheld
			dec <m8u1
			bne .airstuffend 
		.nouheld:
			inc <m8y1 
			jmp .airstuffend
	.onwall:
		jsr m8CheckFlip
		jsr m8CheckStillOnWall
	.airstuffend:
	jsr m8CollideWithObjs
	jsr m8CollideWithEdges
	.jump:
	jsr m8Jump
		lda <m8x1
		jsr c3SpeedToMvmt
		bmi .l
			clc
			adc <m8x0
			sta <m8x0
			bcc .m8y0
			lda <m8b8
			eor #m8b5
			sta <m8b8
			jmp .m8y0
		.l:
			clc
			adc <m8x0
			sta <m8x0
			bcs .m8y0
			lda <m8b8
			eor #m8b5
			sta <m8b8
	.m8y0:
		lda <m8y1
		jsr c3SpeedToMvmt
		pha
		clc
		adc <m8y0
		sta <m8y0
		pla
		clc
		adc <m8t1
		sta <m8t1
	.end: rts
m8Jump:
	lda <i0b8
	and #i0b0
	beq .noa
		lda <m8b8 
		and #m8b2
		bne .end
		lda <i0b9
		and #i0b0
		bne .end
			jsr m8PlayJumpSound
			jmp m8JumpAction 
	.noa:
	lda <m8b8
	and #m8b3
	bne .end
	lda #0
	sta <m8u1
	.end: rts
m8PlayJumpSound:
	lda <b10
	and #b5
	pha
		bne .2
			lda #FT_SFX_CH3
			jmp .xend
		.2:
			lda #FT_SFX_CH2
		.xend:
		sta <m8PlayJumpSoundc0
	pla
	lsr a
	lsr a
	sta <m8PlayJumpSoundw0
	lda #4
	jsr c3ModRandomNum
	clc
	adc #m0
	adc <m8PlayJumpSoundw0
	ldx <m8PlayJumpSoundc0
	jsr f3FamiToneSfxPlay
	rts
m8JumpAction:
	lda <m8t0
	cmp #$ff
	beq .b0
		sta <m8x0
		lda <m8t1
		sta <m8y0
		lda #$ff
		sta <m8t0
	.b0:
		lda #-m8j0
		sta <m8y1
	lda #m8u0
	sta <m8u1
	ldx <m8w1
	lda o4t0, x
	cmp #o4c0
	bcc .nocrumble
	cmp #o4c3
	bcs .nocrumble
		lda #1
		sta <o4c7
		lda #o4c3
		sta o4t0, x
		ldx #FT_SFX_CH1
		lda #c0
		jsr f3FamiToneSfxPlay
	.nocrumble:
	lda <m8x1
	beq .onwall 
	lda <m8b8
	and #m8b1
	bne .onwall
			dec <m8x1
			lda <m8x1
			eor #$ff
			sta <m8x1
		lda #m8b7
		sta <m8s0
		lda <m8b8
		ora #m8b2
		eor #m8b0
		sta <m8b8
		bne .rest 
	.onwall:
		lda #m8i0
		sta <m8i2
		lda #m8j1
		sta <m8s0
		lda <m8b8
		bmi .startl
			lda #m8j0
			sta <m8x1
			bne .rest 
		.startl:
			lda #-m8j0
			sta <m8x1
	.rest:
		ldx <m8w1
		lda o4t0, x
		cmp #o4b0
		beq .tuftend
		lda <m8b8
		and #m8b5
		bne .tuftend
		lda <m8b8
		bmi .mi
			ldx <m8x0
			jmp .effrest
		.mi:
			lda <m8x0
			clc
			adc #m8w0 - 8
			bcs .tuftend
			tax
		.effrest:
		lda <m8y0
		clc
		adc #m8h0 - 16
		tay
		lda <m8b8
		and #m8b0
		lsr a
		sta <f4CreateEffectf0
		lda #f4e2
		jsr f4CreateEffect
		.tuftend:
	lda <m8b8
	and #(m8b1 | m8b3) ^ $ff
	sta <m8b8
	lda <b10
	and #b1 ^ $ff
	sta <b10
	lda #$ff
	sta <m8w1
	rts
m8CollideWithEdges:
	lda <m8y0
	cmp #240
	bcc .b0
		jmp m8FallToDeath
	.b0:
	rts
m8CollideWithObjs:
	lda <m8t0
	cmp #$ff
	beq .b0
		.getouttahere: rts
	.b0:
	lda <m8b8
	and #m8b5
	bne .getouttahere
	ldx #(o4n2 * o4o0) - o4o0
	ldy #o4n2
	.loop:
		cpx <m8w1
		bne .b1
			jmp .next 
		.b1:
		lda o4s0, x
		bne .b2
			jmp .next 
		.b2:
		lda o4t0, x
		cmp #o4s4
		bcc .wall
		cmp #o4t2
		beq .thorntop
		cmp #o4t1
		beq .thorn
		cmp #o4t3
		bcs .thornside
			lda #32
			sta <m8CollideWithObjso1
			sta <m8CollideWithObjso2
			bne .dimsend 
		.thorntop:
			lda #24
			sta <m8CollideWithObjso1
			lda #16
			sta <m8CollideWithObjso2
			bne .dimsend 
		.thorn:
			lda #24
			sta <m8CollideWithObjso1
			sta <m8CollideWithObjso2
			bne .dimsend 
		.thornside:
			lda #8
			sta <m8CollideWithObjso1
			lda #32
			sta <m8CollideWithObjso2
			bne .dimsend
		.wall:
			lda #8
			sta <m8CollideWithObjso1
			lda o4n0, x ; num middle segments
			asl a
			asl a
			asl a
			asl a 
			clc
			adc #26 
			sta <m8CollideWithObjso2
		.dimsend:
		lda o4y0, x
		sta <m8CollideWithObjso0
		lda o4s0, x
		cmp #3
		bcc .b3
			jmp .next
		.b3:
		cmp #2
		bcc .b4
			lda <m8CollideWithObjso0
			clc
			adc <m8CollideWithObjso2
			bcc .next 
			sta <m8CollideWithObjso2
			lda #0
			sta <m8CollideWithObjso0
		.b4:
			lda <m8x0
			clc
			adc #m8w0
			cmp o4x0, x
			bcc .next
			lda o4x0, x
			clc
			adc <m8CollideWithObjso1
			cmp <m8x0
			bcc .next
			lda <m8y0
			clc
			adc #20 
			cmp <m8CollideWithObjso0
			bcc .next
			lda <m8CollideWithObjso2
			clc
			adc <m8CollideWithObjso0 
			bcs .coll
			cmp <m8y0
			bcc .next
		bcs .coll 
		.next:
		txa
		sec
		sbc #o4o0
		tax
		dey
		beq .end0
		jmp .loop
	.coll:
	lda o4t0, x
	cmp #o4s4
	bcc .b5
		jmp m8Explode
	.b5:
	cmp #o4c0
	bcc .nocrumble
	cmp #o4c6+1
	bcs .nocrumble
		cmp #o4c3
		bcs .end0
		jsr m8Crumble
		jmp .shockdieend
	.nocrumble:
	cmp #o4s3
	bne .shockdieend
		lda <o4t16
		cmp #4
		bne .shockdieend
		jmp m8Explode
	.shockdieend:
	cmp #o4b0
	bne .b6
		lda <m8x1
		beq .end0
	.b6:
	lda <m8b8
	and #m8b1
	beq .b7
		.end0: rts
	.b7:
	jsr m8AlignToWall
	lda <m8x1
	beq .nospd
	lda o4t0, x
	cmp #o4b0
	bne .b8
		stx <m8w1
		lda <m8y0
		jsr f4CreateBounce
			lda <m8t0
			sta <m8x0
			lda <m8t1
			sta <m8y0
			lda #$ff
			sta <m8t0
		jsr m8JumpAction
		lda #m8j1
		sta <m8s0
		lda <m8b8
		and #m8b2 ^ $ff
		ora #m8b3
		eor #m8b0
		sta <m8b8
		ldx #FT_SFX_CH1
		lda #b8
		jsr f3FamiToneSfxPlay
		rts
	.b8:
	.nospd:
	stx <m8w1
	lda <m8b8
	ora #m8b1
	and #m8b2 ^ $ff
	sta <m8b8
	lda #m8i1
	sta <m8s0
	lda #0
	sta <m8x1
	lda o4t0, x ; type
	beq .yspd1
	cmp #o4s3
	beq .yspd1
	cmp #o4s1
	beq .yspd6
	cmp #o4s2
	beq .yspdn6
	bne .yspd0
	.yspd1:
		lda #1
		bne .yspdst 
	.yspdn6:
		lda #-6
		bne .yspdst 
	.yspd6:
		lda #6
		bne .yspdst 
	.yspd0:
		lda #0
	.yspdst:
	sta <m8y1
	.end: rts
m8CheckStillOnWall:
	ldx <m8w1
	lda o4t0, x
	cmp #o4c3
	beq .fall
		lda o4y0, x
		sta <m8CheckStillOnWallo1
		lda o4n0, x ; num middle segments
		asl a
		asl a
		asl a
		asl a 
		clc
		adc #26 
		sta <m8CheckStillOnWallo0
	lda o4s0, x
	cmp #1
	beq .b0
		lda <m8CheckStillOnWallo1
		clc
		adc <m8CheckStillOnWallo0
		sta <m8CheckStillOnWallo0
		lda #0
		sta <m8CheckStillOnWallo1
	.b0:
	lda <m8CheckStillOnWallo0
	clc
	adc <m8CheckStillOnWallo1
	bcs .stillon 
	cmp <m8y0
	bcs .stillon 
	.fall:
	lda <m8b8
	and #m8b1 ^ $ff
	sta <m8b8
	lda #m8j1
	sta <m8s0
	rts
	.stillon:
	lda o4t0, x
	cmp #o4s3
	bne .b1
		lda <o4t16
		cmp #4
		bne .end
		jsr m8Explode
	.b1:
	cmp #o4f0
	bne .end
		jsr m8Flip
	.end: rts
m8Flip:
	lda <o4t16
	cmp #4
	bne .end
	lda <o4t15
	cmp <o4t14
	bne .end
	beq m8FlipAction 
	.end: rts
m8FlipAction:
		lda #f2
		ldx #FT_SFX_CH3
		jsr f3FamiToneSfxPlay
	ldx <m8w1
	lda <m8y0
	sta <m8t1
	lda <m8b8
	eor #%10000000
	sta <m8b8
	bmi .l
		lda o4x0, x
		clc
		adc #8
		sta <m8t0
		lda <m8x0
		clc
		adc #8
		sta <m8x0
		lda <b10
		ora #b1
		sta <b10
		.end: rts
	.l:
		lda o4x0, x
		sec
		sbc #m8w0
		sta <m8t0
		lda <m8x0
		sec
		sbc #8
		sta <m8x0
		rts
m8Explode:
	lda <m8i2
	bne .end
	lda #0
	sta <d1d1
	lda <m8b8
	ora #m8b4
	sta <m8b8
		ldx #FT_SFX_CH0
		lda #d0
		jsr f3FamiToneSfxPlay
	lda <m8x0
	sta <d1e0
	lda <m8y0
	sta <d1e1
	.end: rts
m8FallToDeath:
	lda #$ff
	sta <d1e0 
	lda #0
	sta <d1d1
	lda <m8b8
	ora #m8b4
	sta <m8b8
		ldx #FT_SFX_CH0
		lda #f1
		jmp f3FamiToneSfxPlay
m8Crumble:
	lda #1
	sta <o4c7
	lda o4t0, x
	cmp #o4c0
	bne .b0
		inc o4t0, x
	.b0:
	rts
m8AlignToWall:
	lda o4t0, x
	cmp #o4b0
	beq .b0
		txa
		pha
		ldx #FT_SFX_CH0
		lda #l0
		jsr f3FamiToneSfxPlay
		pla
		tax
	.b0:
		lda o4s0, x
		cmp #2
		bcs .noyneededbaby
		lda o4y0, x
		sec
		sbc #10
		bcc .noyneededbaby
		cmp <m8y0
		bcc .noyneededbaby
			sta <m8t1
			jsr m8CheckThornsOnWall
			tya 
			beq .b1
				bmi .collr
				bne .colll
			.b1:
			lda <m8x1
			beq .m8x0
			lda <m8b8
			bmi .colll
			bpl .collr
		.noyneededbaby:
		lda <m8y0
		sta <m8t1
	.m8x0:
	lda <m8x0
	cmp o4x0, x
	bcs .colll
	.collr:
		lda o4x0, x
		sec
		sbc #m8w0
		sta <m8t0
		lda <m8b8
		ora #m8b0
		sta <m8b8
		rts
	.colll:
		lda o4x0, x
		clc
		adc #8
		sta <m8t0
		lda <m8b8
		and #m8b0 ^ $ff
		sta <m8b8
	.end: rts
m8CheckThornsOnWall:
	ldy #0
	lda o4s0 - o4o0, x
	cmp #1
	bne .end
	lda o4t0 - o4o0, x
	cmp #o4t1
	bcc .end
	lda o4y0, x
	clc
	adc #8
	cmp o4y0 - o4o0, x
	bcc .end
	lda o4y0 - o4o0, x
	cmp o4y0, x
	bcc .end
	lda o4x0, x
	sec
	sbc #8
	cmp o4x0 - o4o0, x
	beq .l
	lda o4x0, x
	clc
	adc #8
	cmp o4x0 - o4o0, x
	beq .r
	rts
	.l:
		iny
		.end: rts
	.r:
		dey
		rts
m8FollowTarg:
		lda <m8t0
		sec
		sbc <m8x0
			pha
			asl a
			pla
			ror a
		bne .addx
		.xrola:
		rol a
		.addx:
		clc
		adc <m8x0
		sta <m8x0
		lda <m8t1
		sec
		sbc <m8y0
			pha
			asl a
			pla
			ror a
		bne .addy
		.yrola:
		rol a
		.addy:
		clc
		adc <m8y0
		sta <m8y0
	rts
m8CheckFlip:
	lda <i0b8
	and #i0b1
	beq .end
	lda <i0b9
	and #i0b1
	bne .end
	jsr m8FlipAction
	.end: rts
m8UpdateVictor:
	ldx <c4v0
	lda <m8x0, x
	sta <c3SmoothToTargc0
	lda #m8x2
	jsr c3SmoothToTarg
	sta <m8x0, x
	.m8y0:
	lda <m8y0, x
	sta <c3SmoothToTargc0
	lda #m8y2
	jsr c3SmoothToTarg
	sta <m8y0, x
	.end: rts
	

c3SpeedToMvmt:
	sta <c3SpeedToMvmts0
	and #%11111100
	sta <c3SpeedToMvmtw0	
		asl a 
		lda <c3SpeedToMvmtw0
		ror a
		sta <c3SpeedToMvmtw0
		asl a 
		lda <c3SpeedToMvmtw0
		ror a
		sta <c3SpeedToMvmtw0
		lda <c3SpeedToMvmts0
		and #%00000011
		beq .add
		cmp #1
		beq .25
		cmp #2
		beq .50
		bne .75
		.25:
			lda <c2
			and #%11
			bne .0
			beq .1
		.50:
			lda <c2
			and #1
			bne .0
			beq .1
		.75:
			lda <c2
			and #%11
			bne .1
			beq .add
		.0:
		lda #0
		beq .add 
		.1:
		lda #1
	.add:
	clc
	adc <c3SpeedToMvmtw0
	rts
c3SmoothToTarg:
	sec
	sbc <c3SmoothToTargc0
	beq .eq
		pha
		asl a
		pla
		ror a
		pha
		asl a
		pla
		ror a
	bne .b0
		lda #1
	.b0:
	jsr c3SpeedToMvmt
	clc
	adc <c3SmoothToTargc0
	rts
	.eq:
	lda <c3SmoothToTargc0
	rts
c3RandomNum:
	lda	<s2
	ldx	#8
	.loop:
		asl	a
		rol	<s2 + 1
		bcc	.b0
			eor	#$39
		.b0:
		dex
		bne	.loop
	sta	<s2
	rts
c3ModRandomNum:
	cmp #1
	bne .b0
		lda #0
		.end: rts 
	.b0:
	sta <c3ModRandomNumm0
	jsr c3RandomNum
	cmp <c3ModRandomNumm0
	bcc .end 
	sta <c3ModRandomNumr0
	lda <c3ModRandomNumm0
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
		lda <c3ModRandomNumr0
		and #%1
		rts
	.4:
		lda <c3ModRandomNumr0
		and #%11
		rts
	.8:
		lda <c3ModRandomNumr0
		and #%111
		rts
	.16:
		lda <c3ModRandomNumr0
		and #%1111
		.end2: rts
	.below16:
		lda <c3ModRandomNumr0
		and #%1111
		bne .modloop 
	.16andabove:
		lda <c3ModRandomNumr0
	.modloop:
		cmp <c3ModRandomNumm0
		bcc .end2
		sec
		sbc <c3ModRandomNumm0
		jmp .modloop
c3WaitNumFrames:
	lda <b10
	ora #b0
	sta <b10
	.loop:
		txa
		pha
		tya
		pha
		jsr f3FamiToneUpdate
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
	

i0Read:
	lda #$01
	sta i0c0
	lsr a 
	sta i0c0
	ldx #8
	.loop:
		lda i0c0
		lsr a
		rol <i0b8+1
		lda i0c1
		lsr a
		rol <i0b8+2
		dex
		bne .loop
	.end: rts
	

o4Init:
	lda #o4t13
	sta <o4t14
	sta <o4t15
	lda #o4m0
	sta <o4m1
	lda <b10
	ora #b2
	sta <b10
	lda #0
	sta <o4m2
	sta <o4b2
	sta <o4b3
	sta <o4b4
	sta <o4t16
	sta <o4c7
	rts
o4Update:
	dec <o4m1
	bne .b0
		lda #o4m0
		sta <o4m1
		lda <o4m2
		clc
		adc #1
		and #%11
		sta <o4m2
	.b0:
	inc <o4c7
	dec <o4t15
	bne .b1
		lda <o4t14
		sta <o4t15
		lda <o4t16
		clc
		adc #1
		cmp #5
		bcc .timerst
			lda #0
		.timerst:
		sta <o4t16
	.b1:
	lda <c2
	and #11
	bne .stopend
	lda <o4m2
	beq .spdup
	cmp #3
	beq .spdup
	.spddn:
		dec <o4b2
		jmp .spdend
	.spdup:
		inc <o4b2
	.spdend:
	ldx <o4b2
	ldy #0
	lda <o4m2
	beq .stop0
	cmp #1
	beq .stop1
	cmp #2
	beq .stop2
		txa
		bmi .stopend
		sty <o4b2
		jmp .stopend
	.stop0:
		cpx #o4b1
		bcc .stopend
		lda #o4b1
		sta <o4b2
		bne .stopend 
	.stop1:
		txa
		bpl .stopend
		sty <o4b2
		jmp .stopend
	.stop2:
		cpx #-o4b1
		bcs .stopend
		lda #-o4b1
		sta <o4b2
	.stopend:
	lda <o4b2
	jsr c3SpeedToMvmt
	sta <o4b3
	clc
	adc <o4b4
	sta <o4b4
	ldx #0
	.loop:
		lda o4s0, x
		bne .b2
			jmp .next
		.b2:
		lda o4x0, x
		sta <o4o2
		lda o4y0, x
		sta <o4o3
		lda o4t0, x
		bne .b3
			jmp .next
		.b3:
		cmp #o4t7
		beq .downright
		cmp #o4t8
		beq .downright
		cmp #o4t5
		beq .right
		cmp #o4t6
		beq .left
		cmp #o4d0
		beq .downright
		cmp #o4u0
		beq .upright
		cmp #o4u1
		beq .upleft
		cmp #o4t10
		beq .upright
		cmp #o4s4
		beq .downright
		cmp #o4s6
		beq .upright
		cmp #o4s7
		beq .upleft
		cmp #o4d1
		beq .down
		cmp #o4u2
		beq .up
		cmp #o4r0
		beq .right
		cmp #o4l0
		beq .left
		cmp #o4s5
		beq .right
		cmp #o4s8
		beq .down
		cmp #o4c1 
		bcc .nocrumble
			cmp #o4c6+1
			bcs .nocrumble
			jsr o4UpdateCrumbly
		.nocrumble:
		cmp #o4t11
		bcs .thorn_flip
		jmp .next 
		.downright:
			jsr o4MvmtDownRight
			jmp .jmpdone
		.upright:
			jsr o4MvmtUpRight
			jmp .jmpdone
		.upleft:
			jsr o4MvmtUpLeft
			jmp .jmpdone
		.down:
			jsr o4MvmtDown
			jmp .jmpdone
		.up:
			jsr o4MvmtUp
			jmp .jmpdone
		.right:
			jsr o4MvmtRight
			jmp .jmpdone
		.left:
			jsr o4MvmtLeft
			jmp .jmpdone
		.thorn_flip:
			jsr o4FlipThorn
		.jmpdone:
		lda o4x0, x
		cmp <o4o2
		bne .b4
			lda o4y0, x
			cmp <o4o3
			beq .next
		.b4:
		txa
		tay
		ldx #1
		.movemonkeyloop:
			lda <m8b8, x
			and #m8b4
			bne .nextm
				lda <m8w1, x
				sta <o4w0
				cpy <o4w0
				bne .nextm
			lda <m8b8, x
			and #m8b1
			beq .nextm
					lda o4x0, y
					sec
					sbc <o4o2
					pha
					lda <m8t0, x
					cmp #$ff
					beq .b5
						pla
						pha
						clc
						adc <m8t0, x
						sta <m8t0, x
					.b5:
					pla
					clc
					adc <m8x0, x
					sta <m8x0, x
					lda o4y0, y
					sec
					sbc <o4o3
					pha
					clc
					adc <m8t1, x
					sta <m8t1, x
					pla
					clc
					adc <m8y0, x
					sta <m8y0, x
			.nextm:
			lda <b10
			and #b6
			beq .nom
			inx 
			cpx #3
			bcc .movemonkeyloop
		.nom:
		tya
		tax
		.next:
		txa
		clc
		adc #o4o0
		tax
		cpx #o4n2 * o4o0
		bcs .end
		jmp .loop
	.end: rts
o4MvmtUp:
	lda <o4b3
	bmi .mi
		lda o4y0, x
		sec
		sbc <o4b3
		sta o4y0, x
		bcs .end
		inc o4s0, x
		rts
	.mi:
		lda o4y0, x
		sec
		sbc <o4b3
		sta o4y0, x
		bcc .end
		dec o4s0, x
	.end: rts
o4MvmtDown:
	lda <o4b3
	bmi .mi
		lda o4y0, x
		clc
		adc <o4b3
		sta o4y0, x
		bcc .end
		dec o4s0, x
		rts
	.mi:
		lda o4y0, x
		clc
		adc <o4b3
		sta o4y0, x
		bcs .end
		inc o4s0, x
	.end: rts
o4MvmtDownRight:
	lda <o4b3
	bmi .mi
		lda o4x0, x
		clc
		adc <o4b3
		sta o4x0, x
		lda o4y0, x
		clc
		adc <o4b3
		sta o4y0, x
		bcc .end
		dec o4s0, x
		rts
	.mi:
		lda o4x0, x
		clc
		adc <o4b3
		sta o4x0, x
		lda o4y0, x
		clc
		adc <o4b3
		sta o4y0, x
		bcs .end
		inc o4s0, x
	.end: rts
o4MvmtUpRight:
	lda <o4b3
	bmi .mi
		lda o4x0, x
		clc
		adc <o4b3
		sta o4x0, x
		lda o4y0, x
		sec
		sbc <o4b3
		sta o4y0, x
		bcs .end
		inc o4s0, x
		rts
	.mi:
		lda o4x0, x
		clc
		adc <o4b3
		sta o4x0, x
		lda o4y0, x
		sec
		sbc <o4b3
		sta o4y0, x
		bcc .end
		dec o4s0, x
	.end: rts
o4MvmtUpLeft:
	lda <o4b3
	bmi .mi
		lda o4x0, x
		sec
		sbc <o4b3
		sta o4x0, x
		lda o4y0, x
		sec
		sbc <o4b3
		sta o4y0, x
		bcs .end
		inc o4s0, x
		rts
	.mi:
		lda o4x0, x
		sec
		sbc <o4b3
		sta o4x0, x
		lda o4y0, x
		sec
		sbc <o4b3
		sta o4y0, x
		bcc .end
		dec o4s0, x
	.end: rts
o4MvmtDownLeft:
	lda <o4b3
	bmi .mi
		lda o4x0, x
		sec
		sbc <o4b3
		sta o4x0, x
		lda o4y0, x
		clc
		adc <o4b3
		sta o4y0, x
		bcc .end
		dec o4s0, x
		rts
	.mi:
		lda o4x0, x
		sec
		sbc <o4b3
		sta o4x0, x
		lda o4y0, x
		clc
		adc <o4b3
		sta o4y0, x
		bcs .end
		inc o4s0, x
	.end: rts
o4MvmtRight:
	lda o4x0, x
	clc
	adc <o4b3
	sta o4x0, x
	rts
o4MvmtLeft:
	lda o4x0, x
	sec
	sbc <o4b3
	sta o4x0, x
	rts
o4UpdateCrumbly:
	lda <o4c7
	and #%111
	bne .end
	lda o4t0, x
	clc
	adc #1
	cmp #o4c3
	beq .end
	sta o4t0, x
	cmp #o4c6+1
	bcc .b0
		lda #0
		sta o4s0, x ; destroy wall
	.b0:
	.end: rts
o4FlipThorn:
	lda <o4t16
	cmp #4
	bne .end
	lda <o4t14
	sec
	sbc #4
	cmp <o4t15
	bne .end
	lda o4t0, x
	cmp #o4t11
	beq .toR
		dec o4t0, x
		lda o4x0, x
		sec
		sbc #16
		sta o4x0, x
		.end: rts
	.toR:
		inc o4t0, x
		lda o4x0, x
		clc
		adc #16
		sta o4x0, x
		rts
	

_g0o1 = 4 
g0initscenario:
	.db 130, 236, 8, o4n1, 0
	.db 52, 20, 10, o4n1, 0
	.db 52, 106, 0, o4n1, 0
	.db 130, 60, 1, o4n1, 0
	.db 130, 98, 1, o4n1, 0
g0Init:
	ldx #o4n2 * o4o0
	lda #0
	.clearloop:
		dex
		sta <o4o1, x
		cpx #0
		bne .clearloop
	sta <g0n0
	lda <b10
	ora #b2
	sta <b10
		lda #$ff
		sta <g0c0
		lda #1
		sta <g0c1
		lda #12
		sta <g0s0
	ldx #0
	ldy #NUM_INIT_OBJS
	.loop:
		lda g0initscenario, x
		sta o4x0, x
		lda <g0c0
		sec
		sbc g0initscenario+1, x
		sta o4y0, x
		sta <g0c0
		bcs .b0
			inc <g0c1
			inc <g0n0
		.b0:
		lda g0initscenario+2, x
		sta o4n0, x
		lda g0initscenario+3, x
		sta o4t0, x
		lda <g0c1
		sta o4s0, x
		txa
		clc
		adc #o4o0
		tax
		dec <g0s0
		dey
		bne .loop
	stx <g0o0
	jmp g0Generate
	rts
NUM_INIT_OBJS = (g0Init - g0initscenario) / 5
g0GenerateWholeHalf:
	lda #g0n1
	sta <g0s0
	lda <b10
	and #b2
	bne .l
		lda #g0n1 * o4o0
		bne .lrend 
	.l:
		lda #0
	.lrend:
	sta <g0o0
g0Generate:
	lda <g0g0
	beq .b0
		lda #LOW(s4safescenario)
		sta <g0Generatea0
		lda #HIGH(s4safescenario)
		sta <g0Generatea0+1
		lda #1
		sta <g0CreateObjsn0
		dec <g0s0
		jsr g0CreateObjs
		jmp .next
	.b0:
	lda <g0s0
	cmp #9
	bcc .b1
		lda #8 
	.b1:
	jsr c3ModRandomNum
	pha
	asl a
	tay
	pla
	clc
	adc #1
	sta <g0CreateObjsn0
	lda <g0s0
	sec
	sbc <g0CreateObjsn0
	sta <g0s0
	jsr c3RandomNum
	tax
	lda <c4h0
	cmp #g0h2
	bcs .lvl3
	cmp #g0h1
	bcs .lvl2
	cmp #g0h0
	bcs .lvl1
	bcc .lvl0
	.lvl3:
		cpx #g0h6
		bcc .hard
		bcs .easy
	.lvl2:
		cpx #g0h5
		bcc .hard
		bcs .easy
	.lvl1:
		cpx #g0h4
		bcc .hard
		bcs .easy
	.lvl0:
		cpx #g0h3
		bcs .easy
	.hard:
		lda s4scenarios_hard, y
		sta <g0Generatea0
		lda s4scenarios_hard+1, y
		sta <g0Generatea0+1
		jmp .difficultyend
	.easy:
		lda s4scenarios_easy, y
		sta <g0Generatea0
		lda s4scenarios_easy+1, y
		sta <g0Generatea0+1
	.difficultyend:
	ldy #0
		lda [g0Generatea0], y
		jsr c3ModRandomNum
		asl a
		clc
		adc #1
		tay
		lda [g0Generatea0], y
		pha
		iny
		lda [g0Generatea0], y
		sta <g0Generatea0+1
		pla
		sta <g0Generatea0
	jsr g0CreateObjs
	.next:
	lda <g0s0
	beq .b2
		jmp g0Generate
	.b2:
	lda <b10
	eor #b2
	sta <b10
	rts
g0CreateObjs:
	ldy #0
	lda [g0Generatea0], y
	jsr c3ModRandomNum
	sta <g0CreateObjsa0
	ldx <g0o0
		lda <g0Generatea0
		clc
		adc #1
		sta <g0Generatea0
		lda <g0Generatea0+1
		adc #0
		sta <g0Generatea0+1
	.loop:
		lda <g0c1
		sta <g0CreateObjsm0
		ldy #g0o1 - 1
		lda [g0Generatea0], y
		sta o4t0, x
		dey
		lda [g0Generatea0], y
		sta o4n0, x
		dey
			lda <g0c0
			sec
			sbc [g0Generatea0], y
			bcs .b0
				inc <g0c1
				inc <g0CreateObjsm0
				inc <g0n0
			.b0:
			sta <g0c0
			jsr g0ApplyYOffset
			sta o4y0, x
			dey
			lda [g0Generatea0], y
			jsr g0ApplyXOffset
			clc
			adc <g0CreateObjsa0
			sta o4x0, x
			sta <g0CreateObjsl0
		lda <g0CreateObjsm0
		sta o4s0, x
		txa
		clc
		adc #o4o0
		sta <g0o0
		tax
		lda <g0Generatea0
		clc
		adc #g0o1
		sta <g0Generatea0
		lda <g0Generatea0+1
		adc #0
		sta <g0Generatea0+1
		dec <g0CreateObjsn0
		bne .loop
	lda #0
	sta <g0g0
	lda <g0CreateObjsl0
	cmp #g0t0
	bcc .b1
		dec <g0g0
	.b1:
	rts
g0ApplyXOffset:
	sta <g0ApplyXOffsetn0
	lda o4t0, x
	cmp #o4r0
	beq .r
	cmp #o4t5
	beq .r
	cmp #o4l0
	beq .l
	cmp #o4u1
	beq .l
	cmp #o4t6
	beq .l
	cmp #o4s4
	beq .r
	cmp #o4s5
	beq .r
	cmp #o4s6
	beq .r
	cmp #o4s7
	beq .l
	cmp #o4t7
	beq .r
	cmp #o4d0
	beq .r
	cmp #o4t10
	beq .r
	cmp #o4t8
	beq .r
	cmp #o4u0
	beq .r
	bne .nah 
	.r:
		lda <g0ApplyXOffsetn0
		clc
		adc <o4b4
		.end: rts
	.l:
		lda <g0ApplyXOffsetn0
		sec
		sbc <o4b4
		rts
	.nah:
	lda <g0ApplyXOffsetn0
	rts
g0ApplyYOffset:
	sta <g0ApplyYOffsetn0
	lda o4t0, x
	cmp #o4d1
	beq .d
	cmp #o4d0
	beq .d
	cmp #o4u2
	beq .u
	cmp #o4u0
	beq .u
	cmp #o4u1
	beq .u
	cmp #o4t7
	beq .d
	cmp #o4t9
	beq .u
	cmp #o4t10
	beq .u
	cmp #o4t8
	beq .d
	cmp #o4s4
	beq .d
	cmp #o4s6
	beq .u
	cmp #o4s7
	beq .u
	cmp #o4s8
	beq .d
	bne .nah 
	.d:
		lda <o4b4
		bmi .dm
			clc
			adc <g0ApplyYOffsetn0
			bcc .end
			dec <g0CreateObjsm0
			rts
		.dm:
			clc
			adc <g0ApplyYOffsetn0
			bcs .end
			inc <g0CreateObjsm0
			.end: rts
	.u:
		lda <o4b4
		bmi .um
			lda <g0ApplyYOffsetn0
			sec
			sbc <o4b4
			bcs .end
			inc <g0CreateObjsm0
			rts
		.um:
			lda <g0ApplyYOffsetn0
			sec
			sbc <o4b4
			bcc .end
			dec <g0CreateObjsm0
			rts
	.nah:
	lda <g0ApplyYOffsetn0
	rts
	.bank 1
	.org $a000
	

c4InitTitle:
	jsr d1InitTitle
	lda #$ff
	sta <c4s0
	lda #3
	sta c4m0
	rts
c4InitGame:
	lda <b10
	and #b7 ^ $ff
	sta <b10
	lda #0
	sta <p0
	sta <p1
	sta $2000
	sta $2001
	sta <c4v0
	sta <c4t1
	sta <c4c1
	sta <c4c0
	sta <c4h0
	sta <c4h0+1
	jsr m8Init
	jsr d1InitGame
	jsr o4Init
	jsr g0Init
	jsr d1Update
	lda #%10100000
	sta $2000
	sta <p0
	lda #%00011110
	sta $2001
	sta <p1
	rts
c4UpdateTitle:
	lda <c2
	and #%11
	bne .b0
		inc <c4t0
	.b0:
	lda <c4s0
	cmp #$ff
	beq .b1
		dec <c4s0
		bne c4TitleSpr0
		jsr d1FadeToWhite
		jsr c4InitGame
		jsr d1FadeToBase
		.getouttahere:
			lda $2002
			bpl .getouttahere
			ldx #$ff
			txs
			jmp forever
	.b1:
	jsr c4thomas_c_farraday
	lda <i0b8+1
	and #i0b4 | i0b5 | i0b2
	beq .select
	lda <i0b9+1
	and #i0b4 | i0b5 | i0b2
	bne .select
		lda <b10
		eor #b6
		sta <b10
		ldx #FT_SFX_CH0
		lda #c1
		jsr f3FamiToneSfxPlay
		jmp c4TitleSpr0
	.select: 
	lda <i0b8+1
	and #i0b0 | i0b3
	beq c4TitleSpr0
		lda #64
		sta <c4s0
		ldx #FT_SFX_CH0
		lda #s1
		jsr f3FamiToneSfxPlay
		jmp c4TitleSpr0
	.end: rts
c4TitleSpr0:
	lda o1
	cmp #d1s3
	bne .end
	.spr0wait1: 
	lda $2002
	asl a
	bmi .spr0wait1
	.spr0wait2:
	lda $2002
	asl a
	bpl .spr0wait2
	lda <c4t0
	sta $2005
	lda #0
	sta $2005
	lda <p0
	sta $2000
	ldx #0
	.spr0wait3:
		nop
		nop
		nop
		nop
		nop
		nop
		dex
		bne .spr0wait3
	stx $2005
	stx $2005
	lda <p0
	sta $2000
	.end: rts
c4UpdateGame:
	jsr f4UpdateEffects
	jsr f4UpdateBounces
	lda <c4t1
	beq .b0
		jsr c4UpdateTieWord
	.b0:
	lda <d1d1
	bmi .end
	cmp #64
	bcc .end
	lda <i0b8+1
	beq .p2
	lda <i0b9+1
	cmp <i0b8+1
	beq .p2
		bne c4ResetGame 
	.p2:
	lda <b10
	and #b6
	beq .end
	lda <i0b8+2
	beq .end
	lda <i0b9+2
	cmp <i0b8+2
	beq .end
		bne c4ResetGame 
	.end: rts
c4ResetGame:
	jsr d1FadeToWhite
	jsr c4InitGame
	jmp d1FadeToBase
c4CrownWinner:
	lda <b10
	and #b6
	beq .end
	ldx #1
	lda <m8b8 + 1
	and #m8b4
	beq .b0
		lda <m8b8 + 2
		and #m8b4
		bne .tie
		inx
	.b0:
	stx <c4v0
	lda #m8j1
	sta <m8s0, x
	lda <m8y0, x
	cmp #200
	bcc .b1
		lda #200
		sta <m8y0, x
	.b1:
	lda <m8b8, x
	and #m8b5
	beq .xcorrectend
		lda <m8b8, x
		and #m8b5 ^ $ff
		sta <m8b8, x
		lda <m8x0, x
		bmi .lside
			lda #$f0
			sta <m8x0, x
			bne .xcorrectend 
		.lside:
			lda #0
			sta <m8x0, x
	.xcorrectend:
	lda #1 
	ldx #0
	jsr d1BuffPals
		ldx #FT_SFX_CH1
		lda #v0
		jsr f3FamiToneSfxPlay
	.end: rts
	.tie:
	lda #$ff
	sta <c4t1
	rts
c4UpdateTieWord:
	lda <c4t1
	sta <c3SmoothToTargc0
	lda #c4t2
	jsr c3SmoothToTarg
	sta <c4t1
	rts
c4UpdateCrown:
	lda <c4c1
	sta <c3SmoothToTargc0
	lda #c4c2
	jsr c3SmoothToTarg
	sta <c4c1
	rts
c4IncreaseHexScore:
	inc <c4h0
	bne .b0
		inc <c4h0+1
	.b0:
	lda <c4h0+1
	bne .end
	jsr d1UpdateSkyColor
	lda <c4h0
	cmp #c4c3
	beq .chase1
	cmp #c4c4
	beq .chase2
	cmp #c4t3
	beq .timerspdup
	rts
	.chase1:
		lda #1
		sta <c4c0
		.end: rts
	.chase2:
		lda #2
		sta <c4c0
		rts
	.timerspdup:
		lda #20
		sta <o4t14
		rts
c4Pause:
	lda <i0b8+1
	and #i0b3
	beq .p2
	lda <i0b9+1
	and #i0b3
	beq .act
	.p2:
	lda <b10
	and #b6
	beq .end
	lda <i0b8+2
	and #i0b3
	beq .end
	lda <i0b9+2
	and #i0b3
	bne .end
		.act:
		lda <p2
		beq .pause
			lda #0
			sta <p2
			lda <p1
			and #%00011111
			sta <p1
			rts
		.pause:
			lda #1
			sta <p2
			lda <p1
			ora #%11100000
			sta <p1
	.end: rts
_tcf:
	.dw $0202, $0101, $0102, $0102
_tcfe:
tcf = $01a0
tcf_ctr = $01a1
batting_practice = $01a2
c4thomas_c_farraday:
	lda tcf
	cmp #$ff
	beq .end
	lda tcf_ctr
	beq .n
		dec tcf_ctr
		lda tcf_ctr
		bne .n
		lda #0
		sta tcf
	.n:
	ldx tcf
	lda <i0b9+1
	eor #$ff
	and <i0b8+1
	sta batting_practice
	beq .end
	cmp _tcf, x
	bne .nn
		lda tcf_ctr
		bne .b0
			lda #c4t4
			sta tcf_ctr
		.b0:
		inc tcf
		lda tcf
		cmp #c4t5
		bne .end
			lda #$ff
			sta tcf
			lda #2
			sta c4m0
			jsr .f
			jsr d1BuffAllWhite
			jsr .f
			ldx #1
			lda #0
			jsr d1BuffPals
			jsr .f
			jsr .f
			jsr d1BuffAllWhite
			jsr .f
			ldx #1
			lda #0
			jsr d1BuffPals
			jsr .f
		.end: rts 
	.nn:
		lda #0
		sta tcf
		sta tcf_ctr
	rts
	.f:
		ldx #2
		jsr c3WaitNumFrames
		jmp d1ClearPPUBuff
	

FT_BASE_ADR		= $0300	
FT_TEMP			= $fd	
FT_DPCM_OFF		= $c000	
FT_SFX_STREAMS	= 4		
FT_SFX_ENABLE			
FT_NTSC_SUPPORT			
	.ifdef FT_PAL_SUPPORT
	.ifdef FT_NTSC_SUPPORT
FT_PITCH_FIX			
	.endif
	.endif
FT_DPCM_PTR		= (FT_DPCM_OFF&$3fff)>>6
FT_TEMP_PTR			= FT_TEMP		
FT_TEMP_PTR_L		= FT_TEMP_PTR+0
FT_TEMP_PTR_H		= FT_TEMP_PTR+1
FT_TEMP_VAR1		= FT_TEMP+2
FT_TEMP_SIZE        = 3
FT_ENVELOPES_ALL	= 3+3+3+2	
FT_ENV_STRUCT_SIZE	= 5
FT_ENV_VALUE		= FT_BASE_ADR+0*FT_ENVELOPES_ALL
FT_ENV_REPEAT		= FT_BASE_ADR+1*FT_ENVELOPES_ALL
FT_ENV_ADR_L		= FT_BASE_ADR+2*FT_ENVELOPES_ALL
FT_ENV_ADR_H		= FT_BASE_ADR+3*FT_ENVELOPES_ALL
FT_ENV_PTR			= FT_BASE_ADR+4*FT_ENVELOPES_ALL
FT_CHANNELS_ALL		= 5
FT_CHN_STRUCT_SIZE	= 9
FT_CHN_PTR_L		= FT_BASE_ADR+0*FT_CHANNELS_ALL
FT_CHN_PTR_H		= FT_BASE_ADR+1*FT_CHANNELS_ALL
FT_CHN_NOTE			= FT_BASE_ADR+2*FT_CHANNELS_ALL
FT_CHN_INSTRUMENT	= FT_BASE_ADR+3*FT_CHANNELS_ALL
FT_CHN_REPEAT		= FT_BASE_ADR+4*FT_CHANNELS_ALL
FT_CHN_RETURN_L		= FT_BASE_ADR+5*FT_CHANNELS_ALL
FT_CHN_RETURN_H		= FT_BASE_ADR+6*FT_CHANNELS_ALL
FT_CHN_REF_LEN		= FT_BASE_ADR+7*FT_CHANNELS_ALL
FT_CHN_DUTY			= FT_BASE_ADR+8*FT_CHANNELS_ALL
FT_ENVELOPES	= FT_BASE_ADR
FT_CH1_ENVS		= FT_ENVELOPES+0
FT_CH2_ENVS		= FT_ENVELOPES+3
FT_CH3_ENVS		= FT_ENVELOPES+6
FT_CH4_ENVS		= FT_ENVELOPES+9
FT_CHANNELS		= FT_ENVELOPES+FT_ENVELOPES_ALL*FT_ENV_STRUCT_SIZE
FT_CH1_VARS		= FT_CHANNELS+0
FT_CH2_VARS		= FT_CHANNELS+1
FT_CH3_VARS		= FT_CHANNELS+2
FT_CH4_VARS		= FT_CHANNELS+3
FT_CH5_VARS		= FT_CHANNELS+4
FT_CH1_NOTE			= FT_CH1_VARS+LOW(FT_CHN_NOTE)
FT_CH2_NOTE			= FT_CH2_VARS+LOW(FT_CHN_NOTE)
FT_CH3_NOTE			= FT_CH3_VARS+LOW(FT_CHN_NOTE)
FT_CH4_NOTE			= FT_CH4_VARS+LOW(FT_CHN_NOTE)
FT_CH5_NOTE			= FT_CH5_VARS+LOW(FT_CHN_NOTE)
FT_CH1_INSTRUMENT	= FT_CH1_VARS+LOW(FT_CHN_INSTRUMENT)
FT_CH2_INSTRUMENT	= FT_CH2_VARS+LOW(FT_CHN_INSTRUMENT)
FT_CH3_INSTRUMENT	= FT_CH3_VARS+LOW(FT_CHN_INSTRUMENT)
FT_CH4_INSTRUMENT	= FT_CH4_VARS+LOW(FT_CHN_INSTRUMENT)
FT_CH5_INSTRUMENT	= FT_CH5_VARS+LOW(FT_CHN_INSTRUMENT)
FT_CH1_DUTY			= FT_CH1_VARS+LOW(FT_CHN_DUTY)
FT_CH2_DUTY			= FT_CH2_VARS+LOW(FT_CHN_DUTY)
FT_CH3_DUTY			= FT_CH3_VARS+LOW(FT_CHN_DUTY)
FT_CH4_DUTY			= FT_CH4_VARS+LOW(FT_CHN_DUTY)
FT_CH5_DUTY			= FT_CH5_VARS+LOW(FT_CHN_DUTY)
FT_CH1_VOLUME		= FT_CH1_ENVS+LOW(FT_ENV_VALUE)+0
FT_CH2_VOLUME		= FT_CH2_ENVS+LOW(FT_ENV_VALUE)+0
FT_CH3_VOLUME		= FT_CH3_ENVS+LOW(FT_ENV_VALUE)+0
FT_CH4_VOLUME		= FT_CH4_ENVS+LOW(FT_ENV_VALUE)+0
FT_CH1_NOTE_OFF		= FT_CH1_ENVS+LOW(FT_ENV_VALUE)+1
FT_CH2_NOTE_OFF		= FT_CH2_ENVS+LOW(FT_ENV_VALUE)+1
FT_CH3_NOTE_OFF		= FT_CH3_ENVS+LOW(FT_ENV_VALUE)+1
FT_CH4_NOTE_OFF		= FT_CH4_ENVS+LOW(FT_ENV_VALUE)+1
FT_CH1_PITCH_OFF	= FT_CH1_ENVS+LOW(FT_ENV_VALUE)+2
FT_CH2_PITCH_OFF	= FT_CH2_ENVS+LOW(FT_ENV_VALUE)+2
FT_CH3_PITCH_OFF	= FT_CH3_ENVS+LOW(FT_ENV_VALUE)+2
FT_VARS			= FT_CHANNELS+FT_CHANNELS_ALL*FT_CHN_STRUCT_SIZE
FT_PAL_ADJUST	= FT_VARS+0
FT_SONG_LIST_L	= FT_VARS+1
FT_SONG_LIST_H	= FT_VARS+2
FT_INSTRUMENT_L = FT_VARS+3
FT_INSTRUMENT_H = FT_VARS+4
FT_TEMPO_STEP_L	= FT_VARS+5
FT_TEMPO_STEP_H	= FT_VARS+6
FT_TEMPO_ACC_L	= FT_VARS+7
FT_TEMPO_ACC_H	= FT_VARS+8
FT_SONG_SPEED	= FT_CH5_INSTRUMENT
FT_PULSE1_PREV	= FT_CH3_DUTY
FT_PULSE2_PREV	= FT_CH5_DUTY
FT_DPCM_LIST_L	= FT_VARS+9
FT_DPCM_LIST_H	= FT_VARS+10
FT_DPCM_EFFECT  = FT_VARS+11
FT_OUT_BUF		= FT_VARS+12	
FT_SFX_ADR_L		= FT_VARS+23
FT_SFX_ADR_H		= FT_VARS+24
FT_SFX_BASE_ADR		= FT_VARS+25
FT_SFX_STRUCT_SIZE	= 15
FT_SFX_REPEAT		= FT_SFX_BASE_ADR+0
FT_SFX_PTR_L		= FT_SFX_BASE_ADR+1
FT_SFX_PTR_H		= FT_SFX_BASE_ADR+2
FT_SFX_OFF			= FT_SFX_BASE_ADR+3
FT_SFX_BUF			= FT_SFX_BASE_ADR+4	
FT_BASE_SIZE 		= FT_SFX_BUF+11-FT_BASE_ADR
FT_SFX_CH0			= FT_SFX_STRUCT_SIZE*0
FT_SFX_CH1			= FT_SFX_STRUCT_SIZE*1
FT_SFX_CH2			= FT_SFX_STRUCT_SIZE*2
FT_SFX_CH3			= FT_SFX_STRUCT_SIZE*3
APU_PL1_VOL		= $4000
APU_PL1_SWEEP	= $4001
APU_PL1_LO		= $4002
APU_PL1_HI		= $4003
APU_PL2_VOL		= $4004
APU_PL2_SWEEP	= $4005
APU_PL2_LO		= $4006
APU_PL2_HI		= $4007
APU_TRI_LINEAR	= $4008
APU_TRI_LO		= $400a
APU_TRI_HI		= $400b
APU_NOISE_VOL	= $400c
APU_NOISE_LO	= $400e
APU_NOISE_HI	= $400f
APU_DMC_FREQ	= $4010
APU_DMC_RAW		= $4011
APU_DMC_START	= $4012
APU_DMC_LEN		= $4013
APU_SND_CHN		= $4015
	.ifndef FT_SFX_ENABLE				
FT_MR_PULSE1_V		= APU_PL1_VOL
FT_MR_PULSE1_L		= APU_PL1_LO
FT_MR_PULSE1_H		= APU_PL1_HI
FT_MR_PULSE2_V		= APU_PL2_VOL
FT_MR_PULSE2_L		= APU_PL2_LO
FT_MR_PULSE2_H		= APU_PL2_HI
FT_MR_TRI_V			= APU_TRI_LINEAR
FT_MR_TRI_L			= APU_TRI_LO
FT_MR_TRI_H			= APU_TRI_HI
FT_MR_NOISE_V		= APU_NOISE_VOL
FT_MR_NOISE_F		= APU_NOISE_LO
	.else								
FT_MR_PULSE1_V		= FT_OUT_BUF
FT_MR_PULSE1_L		= FT_OUT_BUF+1
FT_MR_PULSE1_H		= FT_OUT_BUF+2
FT_MR_PULSE2_V		= FT_OUT_BUF+3
FT_MR_PULSE2_L		= FT_OUT_BUF+4
FT_MR_PULSE2_H		= FT_OUT_BUF+5
FT_MR_TRI_V			= FT_OUT_BUF+6
FT_MR_TRI_L			= FT_OUT_BUF+7
FT_MR_TRI_H			= FT_OUT_BUF+8
FT_MR_NOISE_V		= FT_OUT_BUF+9
FT_MR_NOISE_F		= FT_OUT_BUF+10
	.endif
f3FamiToneInit:
	stx FT_SONG_LIST_L		
	sty FT_SONG_LIST_H
	stx <FT_TEMP_PTR_L
	sty <FT_TEMP_PTR_H
	.ifdef FT_PITCH_FIX
	tax						
	beq .pal
	lda #64
.pal:
	.else
	.ifdef FT_PAL_SUPPORT
	lda #0
	.endif
	.ifdef FT_NTSC_SUPPORT
	lda #64
	.endif
	.endif
	sta FT_PAL_ADJUST
	jsr f3FamiToneMusicStop	
	ldy #1
	lda [FT_TEMP_PTR],y		;get instrument list address
	sta FT_INSTRUMENT_L
	iny
	lda [FT_TEMP_PTR],y
	sta FT_INSTRUMENT_H
	iny
	lda [FT_TEMP_PTR],y		;get sample list address
	sta FT_DPCM_LIST_L
	iny
	lda [FT_TEMP_PTR],y
	sta FT_DPCM_LIST_H
	lda #$ff				
	sta FT_PULSE1_PREV
	sta FT_PULSE2_PREV
	lda #$0f				
	sta APU_SND_CHN
	lda #$80				
	sta APU_TRI_LINEAR
	lda #$00				
	sta APU_NOISE_HI
	lda #$30				
	sta APU_PL1_VOL
	sta APU_PL2_VOL
	sta APU_NOISE_VOL
	lda #$08				
	sta APU_PL1_SWEEP
	sta APU_PL2_SWEEP
f3FamiToneMusicStop:
	lda #0
	sta FT_SONG_SPEED		
	sta FT_DPCM_EFFECT		
	ldx #LOW(FT_CHANNELS)	
.set_channels:
	lda #0
	sta FT_CHN_REPEAT,x
	sta FT_CHN_INSTRUMENT,x
	sta FT_CHN_NOTE,x
	sta FT_CHN_REF_LEN,x
	lda #$30
	sta FT_CHN_DUTY,x
	inx						
	cpx #LOW(FT_CHANNELS)+FT_CHANNELS_ALL
	bne .set_channels
	ldx #LOW(FT_ENVELOPES)	
.set_envelopes:
	lda #LOW (_FT2DummyEnvelope)
	sta FT_ENV_ADR_L,x
	lda #HIGH(_FT2DummyEnvelope)
	sta FT_ENV_ADR_H,x
	lda #0
	sta FT_ENV_REPEAT,x
	sta FT_ENV_VALUE,x
	inx
	cpx #LOW(FT_ENVELOPES)+FT_ENVELOPES_ALL
	bne .set_envelopes
	jmp f3FamiToneSampleStop
f3FamiToneMusicPlay:
	ldx FT_SONG_LIST_L
	stx <FT_TEMP_PTR_L
	ldx FT_SONG_LIST_H
	stx <FT_TEMP_PTR_H
	ldy #0
	cmp [FT_TEMP_PTR],y		;check if there is such sub song
	bcs .skip
	asl a					
	sta <FT_TEMP_PTR_L		
	asl a
	tax
	asl a
	adc <FT_TEMP_PTR_L
	stx <FT_TEMP_PTR_L
	adc <FT_TEMP_PTR_L
	adc #5					
	tay
	lda FT_SONG_LIST_L		
	sta <FT_TEMP_PTR_L
	jsr f3FamiToneMusicStop	
	ldx #LOW(FT_CHANNELS)	
.set_channels:
	lda [FT_TEMP_PTR],y		;read channel pointers
	sta FT_CHN_PTR_L,x
	iny
	lda [FT_TEMP_PTR],y
	sta FT_CHN_PTR_H,x
	iny
	lda #0
	sta FT_CHN_REPEAT,x
	sta FT_CHN_INSTRUMENT,x
	sta FT_CHN_NOTE,x
	sta FT_CHN_REF_LEN,x
	lda #$30
	sta FT_CHN_DUTY,x
	inx						
	cpx #LOW(FT_CHANNELS)+FT_CHANNELS_ALL
	bne .set_channels
	lda FT_PAL_ADJUST		
	beq .pal
	iny
	iny
.pal:
	lda [FT_TEMP_PTR],y		;read the tempo step
	sta FT_TEMPO_STEP_L
	iny
	lda [FT_TEMP_PTR],y
	sta FT_TEMPO_STEP_H
	lda #0					
	sta FT_TEMPO_ACC_L
	lda #6					
	sta FT_TEMPO_ACC_H
	sta FT_SONG_SPEED		
.skip:
	rts
f3FamiToneMusicPause:
	tax					
	beq .unpause
.pause:
	jsr f3FamiToneSampleStop
	lda #0				
	sta FT_CH1_VOLUME
	sta FT_CH2_VOLUME
	sta FT_CH3_VOLUME
	sta FT_CH4_VOLUME
	lda FT_SONG_SPEED	
	ora #$80
	bne .done
.unpause:
	lda FT_SONG_SPEED	
	and #$7f
.done:
	sta FT_SONG_SPEED
	rts
f3FamiToneUpdate:
	.ifdef FT_THREAD
	lda FT_TEMP_PTR_L
	pha
	lda FT_TEMP_PTR_H
	pha
	.endif
	lda FT_SONG_SPEED		
	bmi .pause				
	bne .update
.pause:
	jmp .update_sound
.update:
	clc						
	lda FT_TEMPO_ACC_L
	adc FT_TEMPO_STEP_L
	sta FT_TEMPO_ACC_L
	lda FT_TEMPO_ACC_H
	adc FT_TEMPO_STEP_H
	cmp FT_SONG_SPEED
	bcs .update_row			
	sta FT_TEMPO_ACC_H		
	jmp .update_envelopes
.update_row:
	sec
	sbc FT_SONG_SPEED
	sta FT_TEMPO_ACC_H
	ldx #LOW(FT_CH1_VARS)	
	jsr _FT2ChannelUpdate
	bcc .no_new_note1
	ldx #LOW(FT_CH1_ENVS)
	lda FT_CH1_INSTRUMENT
	jsr _FT2SetInstrument
	sta FT_CH1_DUTY
.no_new_note1:
	ldx #LOW(FT_CH2_VARS)	
	jsr _FT2ChannelUpdate
	bcc .no_new_note2
	ldx #LOW(FT_CH2_ENVS)
	lda FT_CH2_INSTRUMENT
	jsr _FT2SetInstrument
	sta FT_CH2_DUTY
.no_new_note2:
	ldx #LOW(FT_CH3_VARS)	
	jsr _FT2ChannelUpdate
	bcc .no_new_note3
	ldx #LOW(FT_CH3_ENVS)
	lda FT_CH3_INSTRUMENT
	jsr _FT2SetInstrument
.no_new_note3:
	ldx #LOW(FT_CH4_VARS)	
	jsr _FT2ChannelUpdate
	bcc .no_new_note4
	ldx #LOW(FT_CH4_ENVS)
	lda FT_CH4_INSTRUMENT
	jsr _FT2SetInstrument
	sta FT_CH4_DUTY
.no_new_note4:
	.ifdef FT_DPCM_ENABLE
	ldx #LOW(FT_CH5_VARS)	
	jsr _FT2ChannelUpdate
	bcc .no_new_note5
	lda FT_CH5_NOTE
	bne .play_sample
	jsr f3FamiToneSampleStop
	bne .no_new_note5		
.play_sample:
	jsr f3FamiToneSamplePlayM
.no_new_note5:
	.endif
.update_envelopes:
	ldx #LOW(FT_ENVELOPES)	
.env_process:
	lda FT_ENV_REPEAT,x		;check envelope repeat counter
	beq .env_read			
	dec FT_ENV_REPEAT,x		;otherwise decrement the counter
	bne .env_next
.env_read:
	lda FT_ENV_ADR_L,x		;load envelope data address into temp
	sta <FT_TEMP_PTR_L
	lda FT_ENV_ADR_H,x
	sta <FT_TEMP_PTR_H
	ldy FT_ENV_PTR,x		
.env_read_value:
	lda [FT_TEMP_PTR],y		;read a byte of the envelope data
	bpl .env_special		
	clc						
	adc #256-192
	sta FT_ENV_VALUE,x		;store the output value
	iny						
	bne .env_next_store_ptr 
.env_special:
	bne .env_set_repeat		
	iny						
	lda [FT_TEMP_PTR],y		;read loop position
	tay						
	jmp .env_read_value		
.env_set_repeat:
	iny
	sta FT_ENV_REPEAT,x		;store the repeat counter value
.env_next_store_ptr:
	tya						
	sta FT_ENV_PTR,x
.env_next:
	inx						
	cpx #LOW(FT_ENVELOPES)+FT_ENVELOPES_ALL
	bne .env_process
.update_sound:
	lda FT_CH1_NOTE
	beq .ch1cut
	clc
	adc FT_CH1_NOTE_OFF
	.ifdef FT_PITCH_FIX
	ora FT_PAL_ADJUST
	.endif
	tax
	lda FT_CH1_PITCH_OFF
	tay
	adc _FT2NoteTableLSB,x
	sta FT_MR_PULSE1_L
	tya						
	ora #$7f
	bmi .ch1sign
	lda #0
.ch1sign:
	adc _FT2NoteTableMSB,x
	.ifndef FT_SFX_ENABLE
	cmp FT_PULSE1_PREV
	beq .ch1prev
	sta FT_PULSE1_PREV
	.endif
	sta FT_MR_PULSE1_H
.ch1prev:
	lda FT_CH1_VOLUME
.ch1cut:
	ora FT_CH1_DUTY
	sta FT_MR_PULSE1_V
	lda FT_CH2_NOTE
	beq .ch2cut
	clc
	adc FT_CH2_NOTE_OFF
	.ifdef FT_PITCH_FIX
	ora FT_PAL_ADJUST
	.endif
	tax
	lda FT_CH2_PITCH_OFF
	tay
	adc _FT2NoteTableLSB,x
	sta FT_MR_PULSE2_L
	tya
	ora #$7f
	bmi .ch2sign
	lda #0
.ch2sign:
	adc _FT2NoteTableMSB,x
	.ifndef FT_SFX_ENABLE
	cmp FT_PULSE2_PREV
	beq .ch2prev
	sta FT_PULSE2_PREV
	.endif
	sta FT_MR_PULSE2_H
.ch2prev:
	lda FT_CH2_VOLUME
.ch2cut:
	ora FT_CH2_DUTY
	sta FT_MR_PULSE2_V
	lda FT_CH3_NOTE
	beq .ch3cut
	clc
	adc FT_CH3_NOTE_OFF
	.ifdef FT_PITCH_FIX
	ora FT_PAL_ADJUST
	.endif
	tax
	lda FT_CH3_PITCH_OFF
	tay
	adc _FT2NoteTableLSB,x
	sta FT_MR_TRI_L
	tya
	ora #$7f
	bmi .ch3sign
	lda #0
.ch3sign:
	adc _FT2NoteTableMSB,x
	sta FT_MR_TRI_H
	lda FT_CH3_VOLUME
.ch3cut:
	ora #$80
	sta FT_MR_TRI_V
	lda FT_CH4_NOTE
	beq .ch4cut
	clc
	adc FT_CH4_NOTE_OFF
	and #$0f
	eor #$0f
	sta <FT_TEMP_VAR1
	lda FT_CH4_DUTY
	asl a
	and #$80
	ora <FT_TEMP_VAR1
	sta FT_MR_NOISE_F
	lda FT_CH4_VOLUME
.ch4cut:
	ora #$f0
	sta FT_MR_NOISE_V
	.ifdef FT_SFX_ENABLE
	.if FT_SFX_STREAMS>0
	ldx #FT_SFX_CH0
	jsr _FT2SfxUpdate
	.endif
	.if FT_SFX_STREAMS>1
	ldx #FT_SFX_CH1
	jsr _FT2SfxUpdate
	.endif
	.if FT_SFX_STREAMS>2
	ldx #FT_SFX_CH2
	jsr _FT2SfxUpdate
	.endif
	.if FT_SFX_STREAMS>3
	ldx #FT_SFX_CH3
	jsr _FT2SfxUpdate
	.endif
	lda FT_OUT_BUF		
	sta APU_PL1_VOL
	lda FT_OUT_BUF+1	
	sta APU_PL1_LO
	lda FT_OUT_BUF+2	
	cmp FT_PULSE1_PREV
	beq .no_pulse1_upd
	sta FT_PULSE1_PREV
	sta APU_PL1_HI
.no_pulse1_upd:
	lda FT_OUT_BUF+3	
	sta APU_PL2_VOL
	lda FT_OUT_BUF+4	
	sta APU_PL2_LO
	lda FT_OUT_BUF+5	
	cmp FT_PULSE2_PREV
	beq .no_pulse2_upd
	sta FT_PULSE2_PREV
	sta APU_PL2_HI
.no_pulse2_upd:
	lda FT_OUT_BUF+6	
	sta APU_TRI_LINEAR
	lda FT_OUT_BUF+7	
	sta APU_TRI_LO
	lda FT_OUT_BUF+8	
	sta APU_TRI_HI
	lda FT_OUT_BUF+9	
	sta APU_NOISE_VOL
	lda FT_OUT_BUF+10	
	sta APU_NOISE_LO
	.endif
	.ifdef FT_THREAD
	pla
	sta FT_TEMP_PTR_H
	pla
	sta FT_TEMP_PTR_L
	.endif
	rts
_FT2SetInstrument:
	asl a					
	tay
	lda FT_INSTRUMENT_H
	adc #0					
	sta <FT_TEMP_PTR_H
	lda FT_INSTRUMENT_L
	sta <FT_TEMP_PTR_L
	lda [FT_TEMP_PTR],y		;duty cycle
	sta <FT_TEMP_VAR1
	iny
	lda [FT_TEMP_PTR],y		;instrument pointer LSB
	sta FT_ENV_ADR_L,x
	iny
	lda [FT_TEMP_PTR],y		;instrument pointer MSB
	iny
	sta FT_ENV_ADR_H,x
	inx						
	lda [FT_TEMP_PTR],y		;instrument pointer LSB
	sta FT_ENV_ADR_L,x
	iny
	lda [FT_TEMP_PTR],y		;instrument pointer MSB
	sta FT_ENV_ADR_H,x
	lda #0
	sta FT_ENV_REPEAT-1,x	;reset env1 repeat counter
	sta FT_ENV_PTR-1,x		;reset env1 pointer
	sta FT_ENV_REPEAT,x		;reset env2 repeat counter
	sta FT_ENV_PTR,x		;reset env2 pointer
	cpx #LOW(FT_CH4_ENVS)	
	bcs .no_pitch
	inx						
	iny
	sta FT_ENV_REPEAT,x		;reset env3 repeat counter
	sta FT_ENV_PTR,x		;reset env3 pointer
	lda [FT_TEMP_PTR],y		;instrument pointer LSB
	sta FT_ENV_ADR_L,x
	iny
	lda [FT_TEMP_PTR],y		;instrument pointer MSB
	sta FT_ENV_ADR_H,x
.no_pitch:
	lda <FT_TEMP_VAR1
	rts
_FT2ChannelUpdate:
	lda FT_CHN_REPEAT,x		;check repeat counter
	beq .no_repeat
	dec FT_CHN_REPEAT,x		;decrease repeat counter
	clc						
	rts
.no_repeat:
	lda FT_CHN_PTR_L,x		;load channel pointer into temp
	sta <FT_TEMP_PTR_L
	lda FT_CHN_PTR_H,x
	sta <FT_TEMP_PTR_H
.no_repeat_r:
	ldy #0
.read_byte:
	lda [FT_TEMP_PTR],y		;read byte of the channel
	inc <FT_TEMP_PTR_L		
	bne .no_inc_ptr1
	inc <FT_TEMP_PTR_H
.no_inc_ptr1:
	ora #0
	bmi .special_code		
	lsr a					
	bcc .no_empty_row
	inc FT_CHN_REPEAT,x		;set repeat counter to 1
.no_empty_row:
	sta FT_CHN_NOTE,x		;store note code
	sec						
	bcs .done 
.special_code:
	and #$7f
	lsr a
	bcs .set_empty_rows
	asl a
	asl a
	sta FT_CHN_INSTRUMENT,x	;store instrument number*4
	bcc .read_byte 
.set_empty_rows:
	cmp #$3d
	bcc .set_repeat
	beq .set_speed
	cmp #$3e
	beq .set_loop
.set_reference:
	clc						
	lda <FT_TEMP_PTR_L
	adc #3
	sta FT_CHN_RETURN_L,x
	lda <FT_TEMP_PTR_H
	adc #0
	sta FT_CHN_RETURN_H,x
	lda [FT_TEMP_PTR],y		;read length of the reference (how many rows)
	sta FT_CHN_REF_LEN,x
	iny
	lda [FT_TEMP_PTR],y		;read 16-bit absolute address of the reference
	sta <FT_TEMP_VAR1		
	iny
	lda [FT_TEMP_PTR],y
	sta <FT_TEMP_PTR_H
	lda <FT_TEMP_VAR1
	sta <FT_TEMP_PTR_L
	ldy #0
	jmp .read_byte
.set_speed:
	lda [FT_TEMP_PTR],y
	sta FT_SONG_SPEED
	inc <FT_TEMP_PTR_L		
	bne .read_byte
	inc <FT_TEMP_PTR_H
	bne .read_byte 
.set_loop:
	lda [FT_TEMP_PTR],y
	sta <FT_TEMP_VAR1
	iny
	lda [FT_TEMP_PTR],y
	sta <FT_TEMP_PTR_H
	lda <FT_TEMP_VAR1
	sta <FT_TEMP_PTR_L
	dey
	jmp .read_byte
.set_repeat:
	sta FT_CHN_REPEAT,x		;set up repeat counter, carry is clear, no new note
.done:
	lda FT_CHN_REF_LEN,x	;check reference row counter
	beq .no_ref				
	dec FT_CHN_REF_LEN,x	;decrease row counter
	bne .no_ref
	lda FT_CHN_RETURN_L,x	;end of a reference, return to previous pointer
	sta FT_CHN_PTR_L,x
	lda FT_CHN_RETURN_H,x
	sta FT_CHN_PTR_H,x
	rts
.no_ref:
	lda <FT_TEMP_PTR_L
	sta FT_CHN_PTR_L,x
	lda <FT_TEMP_PTR_H
	sta FT_CHN_PTR_H,x
	rts
f3FamiToneSampleStop:
	lda #%00001111
	sta APU_SND_CHN
	rts
	.ifdef FT_DPCM_ENABLE
f3FamiToneSamplePlayM:		
	ldx FT_DPCM_EFFECT
	beq _FT2SamplePlay
	tax
	lda APU_SND_CHN
	and #16
	beq .not_busy
	rts
.not_busy:
	sta FT_DPCM_EFFECT
	txa
	jmp _FT2SamplePlay
f3FamiToneSamplePlay:
	ldx #1
	stx FT_DPCM_EFFECT
_FT2SamplePlay:
	sta <FT_TEMP		
	asl a
	clc
	adc <FT_TEMP
	adc FT_DPCM_LIST_L
	sta <FT_TEMP_PTR_L
	lda #0
	adc FT_DPCM_LIST_H
	sta <FT_TEMP_PTR_H
	lda #%00001111			
	sta APU_SND_CHN
	ldy #0
	lda [FT_TEMP_PTR],y		;sample offset
	sta APU_DMC_START
	iny
	lda [FT_TEMP_PTR],y		;sample length
	sta APU_DMC_LEN
	iny
	lda [FT_TEMP_PTR],y		;pitch and loop
	sta APU_DMC_FREQ
	lda #32					
	sta APU_DMC_RAW
	lda #%00011111			
	sta APU_SND_CHN
	rts
	.endif
	.ifdef FT_SFX_ENABLE
f3FamiToneSfxInit:
	stx <FT_TEMP_PTR_L
	sty <FT_TEMP_PTR_H
	ldy #0
	.ifdef FT_PITCH_FIX
	lda FT_PAL_ADJUST		
	bne .ntsc
	iny
	iny
.ntsc:
	.endif
	lda [FT_TEMP_PTR],y		;read and store pointer to the effects list
	sta FT_SFX_ADR_L
	iny
	lda [FT_TEMP_PTR],y
	sta FT_SFX_ADR_H
	ldx #FT_SFX_CH0			
.set_channels:
	jsr _FT2SfxClearChannel
	txa
	clc
	adc #FT_SFX_STRUCT_SIZE
	tax
	cpx #FT_SFX_STRUCT_SIZE*FT_SFX_STREAMS
	bne .set_channels
	rts
_FT2SfxClearChannel:
	lda #0
	sta FT_SFX_PTR_H,x		;this stops the effect
	sta FT_SFX_REPEAT,x
	sta FT_SFX_OFF,x
	sta FT_SFX_BUF+6,x		;mute triangle
	lda #$30
	sta FT_SFX_BUF+0,x		;mute pulse1
	sta FT_SFX_BUF+3,x		;mute pulse2
	sta FT_SFX_BUF+9,x		;mute noise
	rts
f3FamiToneSfxPlay:
	asl a					
	tay
	jsr _FT2SfxClearChannel	
	lda FT_SFX_ADR_L
	sta <FT_TEMP_PTR_L
	lda FT_SFX_ADR_H
	sta <FT_TEMP_PTR_H
	lda [FT_TEMP_PTR],y		;read effect pointer from the table
	sta FT_SFX_PTR_L,x		;store it
	iny
	lda [FT_TEMP_PTR],y
	sta FT_SFX_PTR_H,x		;this write enables the effect
	rts
_FT2SfxUpdate:
	lda FT_SFX_REPEAT,x		;check if repeat counter is not zero
	beq .no_repeat
	dec FT_SFX_REPEAT,x		;decrement and return
	bne .update_buf			
.no_repeat:
	lda FT_SFX_PTR_H,x		;check if MSB of the pointer is not zero
	bne .sfx_active
	rts						
.sfx_active:
	sta <FT_TEMP_PTR_H		
	lda FT_SFX_PTR_L,x
	sta <FT_TEMP_PTR_L
	ldy FT_SFX_OFF,x
	clc
.read_byte:
	lda [FT_TEMP_PTR],y		;read byte of effect
	bmi .get_data			
	beq .eof
	iny
	sta FT_SFX_REPEAT,x		;if bit 7 is reset, it is number of repeats
	tya
	sta FT_SFX_OFF,x
	jmp .update_buf
.get_data:
	iny
	stx <FT_TEMP_VAR1		
	adc <FT_TEMP_VAR1		
	tax
	lda [FT_TEMP_PTR],y		;read value
	iny
	sta FT_SFX_BUF-128,x	;store into output buffer
	ldx <FT_TEMP_VAR1
	jmp .read_byte			
.eof:
	sta FT_SFX_PTR_H,x		;mark channel as inactive
.update_buf:
	lda FT_OUT_BUF			
	and #$0f				
	sta <FT_TEMP_VAR1		
	lda FT_SFX_BUF+0,x
	and #$0f
	cmp <FT_TEMP_VAR1
	bcc .no_pulse1
	lda FT_SFX_BUF+0,x
	sta FT_OUT_BUF+0
	lda FT_SFX_BUF+1,x
	sta FT_OUT_BUF+1
	lda FT_SFX_BUF+2,x
	sta FT_OUT_BUF+2
.no_pulse1:
	lda FT_OUT_BUF+3		
	and #$0f
	sta <FT_TEMP_VAR1
	lda FT_SFX_BUF+3,x
	and #$0f
	cmp <FT_TEMP_VAR1
	bcc .no_pulse2
	lda FT_SFX_BUF+3,x
	sta FT_OUT_BUF+3
	lda FT_SFX_BUF+4,x
	sta FT_OUT_BUF+4
	lda FT_SFX_BUF+5,x
	sta FT_OUT_BUF+5
.no_pulse2:
	lda FT_SFX_BUF+6,x		;overwrite triangle of main output buffer if it is active
	beq .no_triangle
	sta FT_OUT_BUF+6
	lda FT_SFX_BUF+7,x
	sta FT_OUT_BUF+7
	lda FT_SFX_BUF+8,x
	sta FT_OUT_BUF+8
.no_triangle:
	lda FT_OUT_BUF+9		
	and #$0f
	sta <FT_TEMP_VAR1
	lda FT_SFX_BUF+9,x
	and #$0f
	cmp <FT_TEMP_VAR1
	bcc .no_noise
	lda FT_SFX_BUF+9,x
	sta FT_OUT_BUF+9
	lda FT_SFX_BUF+10,x
	sta FT_OUT_BUF+10
.no_noise:
	rts
	.endif
_FT2DummyEnvelope:
	.db $c0,$00,$00
_FT2NoteTableLSB:
	.ifdef FT_PAL_SUPPORT
	.db $00,$33,$da,$86,$36,$eb,$a5,$62,$23,$e7,$af,$7a,$48,$19,$ec,$c2
	.db $9a,$75,$52,$30,$11,$f3,$d7,$bc,$a3,$8c,$75,$60,$4c,$3a,$28,$17
	.db $08,$f9,$eb,$dd,$d1,$c5,$ba,$af,$a5,$9c,$93,$8b,$83,$7c,$75,$6e
	.db $68,$62,$5c,$57,$52,$4d,$49,$45,$41,$3d,$3a,$36,$33,$30,$2d,$2b
	.endif
	.ifdef FT_NTSC_SUPPORT
	.db $00,$ad,$4d,$f2,$9d,$4c,$00,$b8,$74,$34,$f7,$be,$88,$56,$26,$f8
	.db $ce,$a5,$7f,$5b,$39,$19,$fb,$de,$c3,$aa,$92,$7b,$66,$52,$3f,$2d
	.db $1c,$0c,$fd,$ee,$e1,$d4,$c8,$bd,$b2,$a8,$9f,$96,$8d,$85,$7e,$76
	.db $70,$69,$63,$5e,$58,$53,$4f,$4a,$46,$42,$3e,$3a,$37,$34,$31,$2e
	.endif
_FT2NoteTableMSB:
	.ifdef FT_PAL_SUPPORT
	.db $00,$06,$05,$05,$05,$04,$04,$04,$04,$03,$03,$03,$03,$03,$02,$02
	.db $02,$02,$02,$02,$02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.endif
	.ifdef FT_NTSC_SUPPORT
	.db $00,$06,$06,$05,$05,$05,$05,$04,$04,$04,$03,$03,$03,$03,$03,$02
	.db $02,$02,$02,$02,$02,$02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
	.db $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.endif

	

f4CreateEffect:
	pha
	lda f4e1
	beq .spot1
	lda f4e1 + f4e7
	beq .spot2
	and #%1111
	sta <f4CreateEffecte0
	lda f4e1
	and #%1111
	cmp <f4CreateEffecte0
	bcc .spot2
	.spot1:
		stx f4e4
		ldx #0
		beq .store
	.spot2:
		stx f4e4 + f4e7
		ldx #f4e7
	.store:
	pla
	and #d1h0 ^ $ff
	ora <f4CreateEffectf0
	sta f4e1, x
	tya
	sta f4e5, x
	lda #1
	sta f4e6, x
	rts
f4UpdateEffects:
	ldx #0
	lda f4e1
	beq .next
	jsr .update
	.next:
	ldx #f4e7
	lda f4e1 + f4e7
	bne .update
	.end: rts
	.update:
		lda f4e6, x
		and #%111
		bne .updateend
		lda f4e1, x
		clc
		adc #1
		sta f4e1, x
		and #%11
		pha
			cmp #1
			bne .moveend
				dec f4e5, x
				dec f4e5, x
				dec f4e5, x
				lda f4e1, x
				and #d1h0
				bne .b0
					inc f4e4, x
					inc f4e4, x
					inc f4e4, x
					jmp .moveend
				.b0:
				dec f4e4, x
				dec f4e4, x
				dec f4e4, x
			.moveend:
		pla
		eor #%11 
		bne .updateend
		lda #0
		sta f4e1, x
		.updateend:
		inc f4e6, x
		rts
f4CreateBounce:
	clc
	adc #8
	pha
	lda f4b3
	beq .spot1
	lda f4b3 + f4b5
	beq .spot2
	lda f4b4 + f4b5
	and #%1111
	sta <f4CreateBounceb0
	lda f4b4
	and #%1111
	cmp <f4CreateBounceb0
	bcc .spot2
	.spot1:
		ldy #0
		beq .spotsend
	.spot2:
		ldy #f4b5
	.spotsend:
	lda #0
	sta <f4CreateBounces0
	lda o4y0, x
	sta <f4CreateBounceo0
	lda o4s0, x
	cmp #2
	bcc .cmpy
		lda o4y0, x
		.yloop:
			inc <f4CreateBounces0
			clc
			adc #16
			bcc .yloop
		sta <f4CreateBounceo0
	.cmpy:
	pla
	sec
	sbc <f4CreateBounceo0
	bcs .b1
		lda #0
	.b1:
	lsr a
	lsr a
	lsr a
	lsr a
	clc
	adc <f4CreateBounces0
	sta f4b2, y
	lda o4n0, x
	clc
	adc #2
	sec
	sbc f4b2, y
	sta f4b2, y
	lda #1
	sta f4b3, y
	lsr a 
	sta f4b4, y
	txa
	sta f4b1, y
	rts
f4bouncexs:
	.db -4, 3, -2, 2, -1, 1, -1, 1
f4bouncexsend:
f4UpdateBounces:
	ldx #0
	lda f4b3
	beq .next
	jsr .update
	.next:
	ldx #f4b5
	lda f4b3 + f4b5
	beq .end
	bne .update 
	.end: rts
	.update:
		inc f4b3, x
		lda f4b3, x
		and #%1
		bne .end
		inc f4b4, x
		lda f4b4, x
		cmp #f4b6
		bne .end
		lda #0
		sta f4b3, x
		rts
sounds:
	
sounds:
	.dw .ntsc
	.dw .ntsc
.ntsc:
	.dw .sfx_ntsc_bounce
	.dw .sfx_ntsc_crumble
	.dw .sfx_ntsc_die
	.dw .sfx_ntsc_flip
	.dw .sfx_ntsc_land
	.dw .sfx_ntsc_shock
	.dw .sfx_ntsc_monkey_chirp1
	.dw .sfx_ntsc_monkey_chirp2
	.dw .sfx_ntsc_monkey_chirp3
	.dw .sfx_ntsc_monkey_chirp4
	.dw .sfx_ntsc_monkey2_chirp1
	.dw .sfx_ntsc_monkey2_chirp2
	.dw .sfx_ntsc_monkey2_chirp3
	.dw .sfx_ntsc_monkey2_chirp4
	.dw .sfx_ntsc_change_selection
	.dw .sfx_ntsc_select
	.dw .sfx_ntsc_fall
	.dw .sfx_ntsc_backflip
	.dw .sfx_ntsc_victory
	.dw .sfx_ntsc_flip_monkey
.sfx_ntsc_bounce:
	.db $82,$01,$81,$70,$80,$3f,$85,$03,$84,$79,$83,$3d,$87,$eb,$88,$03
	.db $86,$8f,$89,$f0,$01,$81,$64,$84,$6a,$87,$de,$01,$81,$58,$80,$3c
	.db $84,$5a,$83,$3a,$87,$d1,$01,$81,$4c,$84,$4b,$87,$c4,$01,$81,$40
	.db $84,$3b,$87,$b7,$01,$81,$34,$80,$39,$84,$2c,$83,$37,$87,$aa,$01
	.db $81,$28,$84,$1c,$87,$9d,$01,$81,$1c,$84,$0d,$87,$90,$01,$81,$10
	.db $85,$02,$84,$fd,$87,$83,$01,$81,$04,$84,$ee,$87,$76,$01,$82,$00
	.db $81,$f8,$80,$37,$84,$de,$83,$35,$87,$69,$01,$81,$ec,$84,$cf,$87
	.db $5c,$01,$81,$e0,$80,$35,$84,$bf,$83,$34,$87,$4f,$01,$81,$d4,$84
	.db $b0,$87,$42,$01,$81,$c8,$84,$a0,$87,$35,$01,$81,$bc,$80,$33,$84
	.db $91,$83,$32,$87,$28,$01,$81,$b0,$84,$81,$87,$1b,$01,$81,$a4,$84
	.db $72,$87,$0e,$01,$81,$98,$80,$31,$84,$62,$83,$31,$87,$01,$01,$81
	.db $8e,$84,$5c,$87,$f9,$88,$02,$01,$80,$30,$83,$30,$86,$80,$7f,$7f
	.db $7f,$7f,$0d,$82,$01,$81,$fb,$80,$31,$01,$00
.sfx_ntsc_crumble:
	.db $8a,$0d,$89,$3e,$03,$8a,$0f,$04,$8a,$0d,$03,$8a,$0f,$89,$3d,$03
	.db $8a,$0d,$89,$3c,$04,$8a,$0f,$89,$3a,$03,$8a,$0d,$03,$8a,$0f,$89
	.db $39,$04,$8a,$0d,$89,$37,$03,$8a,$0f,$89,$35,$03,$89,$34,$01,$8a
	.db $0d,$03,$8a,$0f,$03,$8a,$0d,$89,$33,$03,$89,$32,$01,$8a,$0f,$03
	.db $8a,$0d,$89,$31,$03,$8a,$0f,$04,$00
.sfx_ntsc_die:
	.db $8a,$04,$89,$3f,$03,$8a,$0f,$04,$8a,$0e,$89,$3e,$03,$8a,$0f,$03
	.db $8a,$0e,$01,$89,$3d,$03,$8a,$0f,$03,$8a,$0e,$89,$3c,$02,$89,$3b
	.db $01,$8a,$0f,$04,$8a,$0e,$89,$39,$03,$8a,$0f,$03,$8a,$0e,$89,$37
	.db $04,$8a,$0f,$03,$8a,$0e,$89,$35,$03,$8a,$0f,$04,$8a,$0e,$02,$89
	.db $33,$01,$8a,$0f,$03,$8a,$0e,$02,$89,$32,$02,$8a,$0f,$03,$8a,$0e
	.db $89,$31,$03,$00
.sfx_ntsc_flip:
	.db $8a,$0b,$89,$38,$01,$8a,$0a,$01,$8a,$09,$01,$8a,$08,$01,$8a,$07
	.db $01,$8a,$06,$01,$8a,$05,$01,$00
.sfx_ntsc_land:
	.db $8a,$0c,$89,$35,$02,$89,$f0,$03,$89,$32,$03,$00
.sfx_ntsc_shock:
	.db $8a,$04,$89,$38,$02,$8a,$07,$03,$8a,$04,$03,$8a,$06,$02,$8a,$04
	.db $02,$8a,$0a,$03,$8a,$04,$03,$8a,$07,$02,$8a,$04,$02,$8a,$06,$03
	.db $8a,$04,$03,$8a,$09,$02,$8a,$04,$02,$8a,$07,$03,$8a,$04,$03,$8a
	.db $0a,$02,$00
.sfx_ntsc_monkey_chirp1:
	.db $82,$00,$81,$97,$80,$35,$89,$f0,$01,$81,$8f,$80,$34,$01,$81,$87
	.db $80,$33,$01,$81,$7f,$01,$81,$77,$80,$32,$01,$81,$70,$80,$31,$01
	.db $00
.sfx_ntsc_monkey_chirp2:
	.db $82,$00,$81,$a0,$80,$35,$89,$f0,$01,$81,$98,$80,$34,$01,$81,$8f
	.db $80,$33,$01,$81,$87,$01,$81,$7e,$80,$32,$01,$81,$77,$80,$31,$01
	.db $00
.sfx_ntsc_monkey_chirp3:
	.db $82,$00,$81,$aa,$80,$35,$89,$f0,$01,$81,$a1,$80,$34,$01,$81,$98
	.db $80,$33,$01,$81,$8f,$01,$81,$86,$80,$32,$01,$81,$7e,$80,$31,$01
	.db $00
.sfx_ntsc_monkey_chirp4:
	.db $82,$00,$81,$b3,$80,$35,$89,$f0,$01,$81,$aa,$80,$34,$01,$81,$a0
	.db $80,$33,$01,$81,$97,$01,$81,$8d,$80,$32,$01,$81,$86,$80,$31,$01
	.db $00
.sfx_ntsc_monkey2_chirp1:
	.db $85,$01,$84,$bc,$83,$35,$89,$f0,$01,$84,$b5,$01,$84,$ad,$83,$34
	.db $01,$84,$a6,$01,$84,$9e,$83,$33,$01,$84,$97,$01,$84,$8f,$83,$32
	.db $01,$84,$88,$01,$84,$80,$83,$31,$01,$84,$7c,$01,$00
.sfx_ntsc_monkey2_chirp2:
	.db $85,$01,$84,$d7,$83,$35,$89,$f0,$01,$84,$cf,$01,$84,$c7,$83,$34
	.db $01,$84,$bf,$01,$84,$b7,$83,$33,$01,$84,$af,$01,$84,$a7,$83,$32
	.db $01,$84,$9f,$01,$84,$97,$83,$31,$01,$84,$93,$01,$00
.sfx_ntsc_monkey2_chirp3:
	.db $85,$01,$84,$f3,$83,$35,$89,$f0,$01,$84,$eb,$01,$84,$e3,$83,$34
	.db $01,$84,$db,$01,$84,$d3,$83,$33,$01,$84,$cb,$01,$84,$c3,$83,$32
	.db $01,$84,$bb,$01,$84,$b3,$83,$31,$01,$84,$ab,$01,$00
.sfx_ntsc_monkey2_chirp4:
	.db $85,$02,$84,$11,$83,$35,$89,$f0,$01,$84,$08,$01,$85,$01,$84,$ff
	.db $83,$34,$01,$84,$f6,$01,$84,$ed,$83,$33,$01,$84,$e4,$01,$84,$db
	.db $83,$32,$01,$84,$d2,$01,$84,$c9,$83,$31,$01,$84,$c4,$01,$00
.sfx_ntsc_change_selection:
	.db $82,$00,$81,$a9,$80,$3f,$89,$f0,$02,$80,$30,$03,$80,$35,$01,$80
	.db $34,$01,$80,$33,$01,$80,$32,$01,$80,$31,$01,$00
.sfx_ntsc_select:
	.db $82,$00,$81,$fd,$80,$3f,$89,$f0,$03,$81,$c9,$04,$81,$a9,$03,$81
	.db $7e,$03,$81,$fd,$80,$39,$03,$81,$c9,$04,$81,$a9,$80,$37,$03,$81
	.db $7e,$03,$80,$30,$01,$81,$fd,$80,$34,$03,$81,$c9,$04,$81,$a9,$03
	.db $81,$7e,$03,$81,$fd,$80,$31,$03,$81,$c9,$04,$81,$a9,$03,$81,$7e
	.db $03,$00
.sfx_ntsc_fall:
	.db $82,$00,$81,$c9,$80,$3c,$89,$f0,$01,$81,$ca,$02,$81,$cb,$02,$81
	.db $cc,$02,$81,$cd,$01,$80,$3b,$01,$81,$ce,$02,$81,$cf,$02,$81,$d0
	.db $02,$81,$d1,$01,$80,$3a,$01,$81,$d2,$02,$81,$d3,$02,$81,$d4,$02
	.db $81,$d5,$01,$80,$39,$01,$81,$d6,$02,$81,$d7,$02,$81,$d8,$02,$81
	.db $d9,$01,$80,$38,$01,$81,$da,$02,$81,$db,$02,$81,$dc,$02,$81,$dd
	.db $01,$80,$37,$01,$81,$de,$02,$81,$df,$02,$81,$e0,$02,$81,$e1,$01
	.db $80,$36,$01,$81,$e2,$02,$81,$e3,$02,$81,$e4,$02,$81,$e5,$01,$80
	.db $35,$01,$81,$e6,$02,$81,$e7,$02,$81,$e8,$02,$81,$e9,$01,$80,$34
	.db $01,$81,$ea,$02,$81,$eb,$02,$81,$ec,$02,$81,$ed,$01,$80,$33,$01
	.db $81,$ee,$02,$81,$ef,$02,$81,$f0,$02,$81,$f1,$01,$80,$32,$01,$81
	.db $f2,$02,$81,$f3,$02,$81,$f4,$02,$81,$f5,$01,$80,$31,$01,$81,$f6
	.db $02,$81,$f7,$02,$81,$f8,$02,$81,$f9,$01,$00
.sfx_ntsc_backflip:
	.db $8a,$07,$89,$32,$01,$8a,$04,$89,$36,$01,$8a,$03,$02,$89,$f0,$01
	.db $8a,$08,$89,$39,$01,$8a,$05,$89,$3c,$01,$8a,$04,$02,$89,$f0,$01
	.db $8a,$0a,$89,$37,$01,$8a,$06,$89,$3a,$01,$8a,$05,$02,$89,$f0,$01
	.db $8a,$0b,$89,$35,$01,$8a,$08,$89,$39,$01,$8a,$07,$02,$89,$f0,$01
	.db $8a,$0d,$89,$34,$01,$8a,$0a,$89,$37,$01,$8a,$09,$02,$89,$f0,$01
	.db $8a,$0f,$89,$32,$01,$8a,$0c,$89,$35,$01,$8a,$0b,$01,$00
.sfx_ntsc_victory:
	.db $82,$00,$81,$bd,$80,$3f,$89,$f0,$05,$81,$fd,$05,$81,$bd,$05,$81
	.db $96,$05,$81,$7e,$85,$00,$84,$fd,$83,$35,$05,$81,$96,$84,$bd,$05
	.db $81,$7e,$83,$30,$05,$81,$5e,$05,$84,$96,$83,$39,$01,$80,$3d,$04
	.db $84,$7e,$03,$80,$3b,$02,$84,$5e,$05,$80,$3a,$84,$96,$83,$37,$05
	.db $84,$7e,$01,$80,$37,$04,$84,$5e,$03,$80,$35,$02,$84,$96,$83,$35
	.db $04,$80,$33,$01,$84,$7e,$03,$80,$31,$02,$80,$30,$84,$5e,$05,$84
	.db $96,$83,$33,$05,$84,$7e,$05,$84,$5e,$05,$84,$96,$83,$31,$05,$84
	.db $7e,$05,$84,$5e,$05,$00
.sfx_ntsc_flip_monkey:
	.db $8a,$06,$01,$89,$31,$02,$89,$32,$01,$89,$33,$01,$00
titletiles:
	
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $60, $63, $64, $60, $6b, $6c, $6d, $6e, $60, $77, $60, $62, $7a, $7b, $7c, $60, $87, $88, $8e, $8f, $90, $91, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $60, $65, $66, $60, $6f, $70, $71, $72, $60, $60, $60, $62, $7d, $7e, $7f, $60, $89, $8a, $92, $60, $93, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $60, $67, $68, $60, $73, $60, $60, $74, $60, $78, $60, $62, $80, $81, $82, $60, $8b, $8c, $9c, $60, $94, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $61, $69, $6a, $61, $9c, $75, $76, $9c, $61, $79, $61, $83, $84, $85, $86, $61, $61, $8d, $9c, $61, $95, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $4b, $4b, $cc, $cd, $ce, $cf, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $a4, $a5, $a6, $4b, $4b, $4b, $c0, $c1, $c2, $c2, $c2, $a8, $a9, $aa, $ab, $4b, $4b, $4b
	.db $dc, $dd, $de, $df, $fe, $ff, $c2, $c2, $c2, $c2, $c2, $c2, $a7, $c2, $b4, $b5, $b6, $4b, $4b, $4b, $d0, $d1, $c2, $c2, $c2, $b8, $b9, $ba, $bb, $9f, $4b, $4b
	.db $ec, $ed, $ee, $ef, $bf, $c2, $c2, $c2, $c2, $c2, $c2, $a0, $a1, $a2, $a3, $b7, $af, $4b, $4b, $4b, $e0, $e1, $c2, $c2, $c2, $c2, $9d, $9e, $ac, $ad, $ae, $4b
	.db $fc, $fd, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $b0, $b1, $b2, $b3, $4b, $4b, $4b, $4b, $4b, $f0, $f1, $c2, $c2, $c2, $c2, $c2, $c2, $bc, $bd, $be, $4b
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $52, $5f, $53, $58, $58, $9c, $99, $56, $54, $99, $4c, $5c, $98, $52, $9c, $5b, $5e, $5c, $55, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $97, $5e, $97, $51, $9c, $55, $53, $96, $58, $5e, $5c, $9c, $5b, $58, $4c, $5f, $4c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c
	.db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c

titleattrs:
	
	.db $00, $00, $00, $00, $00, $00, $00, $00
	.db $00, $00, $00, $00, $00, $00, $00, $00
	.db $00, $00, $00, $00, $00, $00, $00, $00
	.db $00, $00, $00, $00, $00, $00, $00, $00
	.db $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0
	.db $5f, $5f, $5f, $5f, $5f, $5f, $5f, $5f
	.db $55, $55, $55, $55, $55, $55, $55, $55
	.db $05, $05, $05, $05, $05, $05, $05, $05

gametiles:
	
	.db $4b, $4b, $4b, $4b, $cc, $cd, $ce, $cf, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c6, $c7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $dc, $dd, $de, $df, $fe, $ff, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $d6, $d7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $ec, $ed, $ee, $ef, $bf, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $e6, $e7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $fc, $fd, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $f6, $f7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $c0, $c1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c6, $c7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $d0, $d1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $d6, $d7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $e0, $e1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $e6, $e7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $f0, $f1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $f6, $f7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $c0, $c1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $a4, $a5, $a6, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $d0, $d1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $a7, $c2, $b4, $b5, $b6, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $e0, $e1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $a0, $a1, $a2, $a3, $b7, $af, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $f0, $f1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $b0, $b1, $b2, $b3, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $c0, $c1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $a8, $a9, $aa, $ab, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $d0, $d1, $c2, $c2, $c2, $c2, $c2, $c3, $c4, $c5, $c2, $c2, $c2, $c2, $b8, $b9, $ba, $bb, $9f, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $e0, $e1, $c2, $c2, $c2, $c2, $d2, $d3, $d4, $d5, $c2, $c2, $c2, $c2, $c2, $9d, $9e, $ac, $ad, $ae, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $f0, $f1, $c2, $c2, $c2, $c2, $e2, $e3, $e4, $e5, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $bc, $bd, $be, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $c0, $c1, $c2, $c2, $c2, $c2, $f2, $f3, $f4, $f5, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $a8, $a9, $aa, $ab, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $d0, $d1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $b8, $b9, $ba, $bb, $9f, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $e0, $e1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $9d, $9e, $ac, $ad, $ae, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $f0, $f1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $bc, $bd, $be, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $c8, $c9, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c6, $c7, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $d8, $d9, $da, $db, $ca, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $d6, $d7, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $e8, $e9, $ea, $eb, $d9, $cb, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $e6, $e7, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $f8, $f9, $fa, $fb, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $f6, $f7, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $c8, $c9, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $a8, $a9, $aa, $ab, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $d8, $d9, $da, $db, $ca, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $b8, $b9, $ba, $bb, $9f, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $e8, $e9, $ea, $eb, $d9, $cb, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $9d, $9e, $ac, $ad, $ae, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $f8, $f9, $fa, $fb, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $bc, $bd, $be, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $c0, $c1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c6, $c7, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $d0, $d1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $d6, $d7, $4b, $4b
	
	.db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
gametiles2:
	
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $e0, $e1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $e6, $e7, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $f0, $f1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c3, $c4, $c5, $c2, $c2, $c2, $f6, $f7, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $c8, $c9, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $d2, $d3, $d4, $d5, $c2, $c2, $c2, $c6, $c7, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $d8, $d9, $da, $db, $ca, $c2, $c2, $c2, $c2, $c2, $c2, $e2, $e3, $e4, $e5, $c2, $c2, $c2, $d6, $d7, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $e8, $e9, $ea, $eb, $d9, $cb, $c2, $c2, $c2, $c2, $c2, $f2, $f3, $f4, $f5, $c2, $c2, $c2, $e6, $e7, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $f8, $f9, $fa, $fb, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $f6, $f7, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $c0, $c1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $a4, $a5, $a6, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $d0, $d1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $a7, $c2, $b4, $b5, $b6, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $e0, $e1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $a0, $a1, $a2, $a3, $b7, $af, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $f0, $f1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $b0, $b1, $b2, $b3, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $c0, $c1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c6, $c7, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $d0, $d1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $d6, $d7, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $e0, $e1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $e6, $e7, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $f0, $f1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $f6, $f7, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $cc, $cd, $ce, $cf, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $a4, $a5, $a6, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $dc, $dd, $de, $df, $fe, $ff, $c2, $c2, $c2, $c2, $c2, $a7, $c2, $b4, $b5, $b6, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $ec, $ed, $ee, $ef, $bf, $c2, $c2, $c2, $c2, $c2, $a0, $a1, $a2, $a3, $b7, $af, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $fc, $fd, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $b0, $b1, $b2, $b3, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $cc, $cd, $ce, $cf, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c6, $c7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $dc, $dd, $de, $df, $fe, $ff, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $d6, $d7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $ec, $ed, $ee, $ef, $bf, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $e6, $e7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $fc, $fd, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $f6, $f7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $c0, $c1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c6, $c7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $d0, $d1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $d6, $d7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $e0, $e1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $e6, $e7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $f0, $f1, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $c2, $f6, $f7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $c0, $c1, $c2, $c2, $c2, $c2, $c2, $c3, $c4, $c5, $c2, $c2, $c2, $c2, $c6, $c7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $d0, $d1, $c2, $c2, $c2, $c2, $d2, $d3, $d4, $d5, $c2, $c2, $c2, $c2, $d6, $d7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $e0, $e1, $c2, $c2, $c2, $c2, $e2, $e3, $e4, $e5, $c2, $c2, $c2, $c2, $e6, $e7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db $4b, $4b, $4b, $4b, $4b, $4b, $f0, $f1, $c2, $c2, $c2, $c2, $f2, $f3, $f4, $f5, $c2, $c2, $c2, $c2, $f6, $f7, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b, $4b
	.db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	.db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	

s4safescenario:
	.db 60 
	.db 52, 96, 0, o4r0 
s4shared1scenarios:
	.db (.1_addrsend - .1_addrs) / 2
	.1_addrs:
		.dw .1_1, .1_2, .1_3, .1_4, .1_6, .1_7
	.1_addrsend:
	.1_1:
		.db 144 
		.db 52, 96, 1, o4n1 
	.1_2:
		.db 144 
		.db 52, 96, 1, o4s3 
	.1_3:
		.db 144 
		.db 52, 96, 1, o4f0 
	.1_4:
		.db 144 
		.db 52, 96, 0, o4c0 
	.1_6:
		.db 144
		.db 52, 80, 0, o4b0
	.1_7:
		.db 144
		.db 52, 150, 0, o4d1
s4scenarios_easy:
	.dw s4shared1scenarios, .2, .3, .4, .5, .6, .7, .8
	.2:
		.db (.2_addrsend - .2_addrs) / 2
		.2_addrs:
			.dw .2_1, .2_2, .2_3, .2_4, .2_5, .2_6, .2_7
		.2_addrsend:
		.2_1:
			.db 144
			.db 60, 80, 0, o4t12
			.db 52, 8, 1, o4f0
		.2_2:
			.db 144
			.db 52, 80, 0, o4c0
			.db 52, 110, 0, o4c0
		.2_3:
			.db 80
			.db 52, 88, 1, o4n1
			.db 149, 68, 1, o4n1
		.2_4:
			.db 40
			.db 68, 88, 0, o4t5
			.db 60, 0, 0, o4r0
		.2_5:
			.db 50
			.db 170, 88, 1, o4b0
			.db 52, 0, 1, o4b0
		.2_6:
			.db 120
			.db 52, 168, 5, o4s2
			.db 44, 24, 0, o4t2
		.2_7:
			.db 10
			.db 120, 88, 0, o4u1
			.db 120, 194, 0, o4d0
	.3:
		.db (.3_addrsend - .3_addrs) / 2
		.3_addrs:
			.dw .3_1, .3_2, .3_3, .3_4, .3_5
		.3_addrsend:
		.3_1:
			.db 70
			.db 120, 120, 0, o4t3
			.db 120, 80, 0, o4t3
			.db 128, 40, 11, o4n1
		.3_2:
			.db 70
			.db 24, 90, 1, o4n1
			.db 30, 80, 0, o4s4
			.db 136, 0, 1, o4n1
		.3_3:
			.db 1
			.db 210, 255, 10, o4n1
			.db 120, 0, 10, o4n1
			.db 30, 0, 10, o4n1
		.3_4:
			.db 80
			.db 52, 88, 0, o4u0
			.db 90, 50, 0, o4t1
			.db 140, 140, 1, o4n1
		.3_5:
			.db 25
			.db 52, 88, 1, o4n1
			.db 200, 120, 1, o4n1
			.db 52, 0, 0, o4d0
	.4:
		.db (.4_addrsend - .4_addrs) / 2
		.4_addrs:
			.dw .4_1, .4_2, .4_3, .4_4
		.4_addrsend:
		.4_1:
			.db 60
			.db 80, 100, 0, o4t10
			.db 72, 0, 0, o4u0
			.db 80, 255, 0, o4t8
			.db 72, 0, 0, o4d0
		.4_2:
			.db 80
			.db 24, 80, 1, o4s3
			.db 140, 80, 1, o4s3
			.db 24, 80, 1, o4s3
			.db 140, 80, 1, o4s3
		.4_3:
			.db 80
			.db 132, 80, 0, o4t11
			.db 140, 8, 1, o4f0
			.db 22, 80, 0, o4t11
			.db 30, 8, 1, o4f0
		.4_4:
			.db 120
			.db 100, 80, 0, o4n1
			.db 100, 164, 5, o4b0
			.db 24, 24, 9, o4b0
			.db 100, 66, 1, o4n1
	.5:
		.db (.5_addrsend - .5_addrs) / 2
		.5_addrs:
			.dw .5_1, .5_2, .5_3, .5_4
		.5_addrsend:
		.5_1:
			.db 40
			.db 110, 176, 4, o4s1
			.db 102, 24, 0, o4t2
			.db 110, 88, 4, o4s1
			.db 102, 24, 0, o4t2
			.db 110, 88, 4, o4s1
		.5_2:
			.db 40
			.db 140, 88, 1, o4s3
			.db 52, 50, 1, o4b0
			.db 140, 50, 1, o4b0
			.db 52, 50, 1, o4b0
			.db 140, 50, 0, o4c0
		.5_3:
			.db 40
			.db 20, 80, 0, o4s6
			.db 168, 44, 3, o4n1
			.db 52, 118, 4, o4n1
			.db 168, 70, 1, o4n1
			.db 20, 20, 0, o4s4
		.5_4:
			.db 144
			.db 44, 88, 0, o4t11
			.db 44, 32, 0, o4t11
			.db 60, 32, 0, o4t12
			.db 60, 32, 0, o4t12
			.db 52, 8, 7, o4f0
	.6:
		.db (.6_addrsend - .6_addrs) / 2
		.6_addrs:
			.dw .6_1, .6_2, .6_3
		.6_addrsend:
		.6_1:
			.db 40
			.db 60, 80, 0, o4t5
			.db 52, 0, 0, o4r0
			.db 200, 80, 0, o4t6
			.db 192, 0, 0, o4l0
			.db 60, 80, 0, o4t5
			.db 52, 0, 0, o4r0
		.6_2:
			.db 80
			.db 80, 80, 0, o4t11
			.db 88, 8, 1, o4f0
			.db 150, 116, 8, o4s2
			.db 96, 0, 0, o4t12
			.db 88, 8, 1, o4f0
			.db 142, 16, 0, o4t2
		.6_3:
			.db 20
			.db 60, 88, 0, o4t4
			.db 52, 0, 0, o4n1
			.db 140, 32, 0, o4t4
			.db 132, 0, 0, o4n1
			.db 220, 32, 0, o4t4
			.db 212, 0, 0, o4n1
	.7:
		.db (.7_addrsend - .7_addrs) / 2
		.7_addrs:
			.dw .7_1, .7_2, .7_3
		.7_addrsend:
		.7_1:
			.db 20
			.db 60, 120, 0, o4t4
			.db 52, 60, 7, o4n1
			.db 130, 0, 0, o4t1
			.db 220, 90, 4, o4n1
			.db 116, 16, 0, o4t4
			.db 108, 0, 0, o4n1
			.db 108, 140, 2, o4n1
		.7_2:
			.db 144
			.db 44, 88, 0, o4t11
			.db 44, 32, 0, o4t11
			.db 44, 32, 0, o4t11
			.db 60, 32, 0, o4t12
			.db 60, 32, 0, o4t12
			.db 60, 32, 0, o4t12
			.db 52, 8, 11, o4f0
		.7_3:
			.db 50
			.db 52, 88, 0, o4t11
			.db 60, 8, 1, o4f0
			.db 176, 70, 1, o4n1
			.db 68, 70, 0, o4t12
			.db 60, 8, 1, o4f0
			.db 168, 70, 0, o4t11
			.db 176, 8, 1, o4f0
	.8:
		.db (.8_addrsend - .8_addrs) / 2
		.8_addrs:
			.dw .8_1, .8_2, .8_3
		.8_addrsend:
		.8_1:
			.db 80
			.db 132, 80, 0, o4t11
			.db 140, 8, 1, o4f0
			.db 22, 80, 0, o4t11
			.db 30, 8, 1, o4f0
			.db 132, 80, 0, o4t11
			.db 140, 8, 1, o4f0
			.db 22, 80, 0, o4t11
			.db 30, 8, 1, o4f0
		.8_2:
			.db 40
			.db 200, 140, 3, o4n1
			.db 100, 8, 0, o4t1
			.db 20, 4, 2, o4n1
			.db 20, 88, 1, o4n1
			.db 108, 48, 0, o4t4
			.db 100, 0, 0, o4n1
			.db 208, 48, 0, o4t4
			.db 200, 0, 0, o4n1
		.8_3:
			.db 30
			.db 52, 88, 1, o4s1
			.db 150, 78, 1, o4s1
			.db 200, 78, 1, o4s1
			.db 200, 116, 1, o4s1
			.db 200, 116, 1, o4s1
			.db 16, 0, 1, o4s1
			.db 16, 116, 1, o4s1
			.db 128, 58, 1, o4s1
s4scenarios_hard:
	.dw s4shared1scenarios, .2, .3, .4, .5, .6, .7, .8
	.2:
		.db (.2_addrsend - .2_addrs) / 2
		.2_addrs:
			.dw .2_1, .2_2, .2_3
		.2_addrsend:
		.2_1:
			.db 80
			.db 90, 120, 0, o4t1
			.db 98, 38, 0, o4d1
		.2_2:
			.db 70
			.db 150, 88, 0, o4l0
			.db 52, 0, 0, o4s5
		.2_3:
			.db 70
			.db 52, 88, 0, o4r0
			.db 92, 0, 0, o4t1
	.3:
		.db (.3_addrsend - .3_addrs) / 2
		.3_addrs:
			.dw .3_1, .3_2, .3_3, .3_4
		.3_addrsend:
		.3_1:
			.db 144
			.db 52, 120, 0, o4t2
			.db 52, 80, 0, o4t2
			.db 60, 40, 11, o4s1
		.3_2:
			.db 144
			.db 52, 90, 0, o4t11
			.db 68, 32, 0, o4t12
			.db 60, 8, 3, o4f0
		.3_3:
			.db 100
			.db 140, 96, 1, o4n1
			.db 52, 48, 1, o4b0
			.db 140, 48, 1, o4s3
		.3_4:
			.db 50
			.db 170, 88, 1, o4b0
			.db 60, 1, 0, o4s6
			.db 52, 106, 1, o4n1
	.4:
		.db (.4_addrsend - .4_addrs) / 2
		.4_addrs:
			.dw .4_1, .4_2, .4_3, .4_4
		.4_addrsend:
		.4_1:
			.db 40
			.db 180, 80, 0, o4u2
			.db 88, 140, 1, o4b0
			.db 20, 40, 0, o4s5
			.db 88, 136, 6, o4n1
		.4_2:
			.db 40
			.db 42, 88, 0, o4c0
			.db 170, 48, 0, o4c0
			.db 42, 48, 0, o4c0
			.db 98, 16, 0, o4s8
		.4_3:
			.db 60
			.db 52, 88, 0, o4u2
			.db 160, 154, 1, o4b0
			.db 52, 180, 0, o4d1
			.db 160, 88, 0, o4c0
		.4_4:
			.db 40
			.db 140, 88, 1, o4s3
			.db 52, 50, 1, o4b0
			.db 140, 50, 1, o4b0
			.db 52, 50, 1, o4s3
	.5:
		.db (.5_addrsend - .5_addrs) / 2
		.5_addrs:
			.dw .5_1, .5_2, .5_3, .5_4
		.5_addrsend:
		.5_1:
			.db 40
			.db 52, 92, 1, o4n1
			.db 44, 110, 0, o4t7
			.db 52, 0, 0, o4d0
			.db 160, 0, 0, o4t3
			.db 168, 8, 1, o4n1
		.5_2:
			.db 80
			.db 126, 100, 0, o4t1
			.db 126, 32, 0, o4t1
			.db 126, 32, 0, o4t1
			.db 126, 32, 0, o4t1
			.db 52, 32, 10, o4b0
		.5_3:
			.db 1
			.db 148, 150, 0, o4t8
			.db 140, 0, 0, o4d0
			.db 32, 60, 0, o4b0
			.db 110, 0, 0, o4s7
			.db 140, 68, 1, o4n1
		.5_4:
			.db 40
			.db 140, 88, 1, o4s3
			.db 52, 50, 1, o4b0
			.db 140, 50, 1, o4b0
			.db 52, 50, 1, o4b0
			.db 140, 50, 1, o4s3
	.6:
		.db (.6_addrsend - .6_addrs) / 2
		.6_addrs:
			.dw .6_1, .6_2, .6_3
		.6_addrsend:
		.6_1:
			.db 70
			.db 160, 132, 0, o4t3
			.db 168, 48, 6, o4n1
			.db 29+8, 0, 0, o4t10
			.db 29, 0, 0, o4u0
			.db 29+8, 255, 0, o4t8
			.db 29, 0, 0, o4d0
		.6_2:
			.db 60
			.db 60, 190, 0, o4t8
			.db 52, 0, 0, o4d0
			.db 100, 88, 0, o4c0
			.db 60, 88, 0, o4t10
			.db 52, 0, 0, o4u0
			.db 160, 160, 0, o4c0
		.6_3:
			.db 20
			.db 220, 88, 0, o4t4
			.db 212, 0, 0, o4n1
			.db 130, 12, 0, o4t4
			.db 122, 0, 0, o4n1
			.db 40, 12, 0, o4t4
			.db 32, 0, 0, o4n1
	.7:
		.db (.7_addrsend - .7_addrs) / 2
		.7_addrs:
			.dw .7_1, .7_2, .7_3
		.7_addrsend:
		.7_1:
			.db 57
			.db 16, 80, 0, o4s6
			.db 182, 40, 2, o4n1
			.db 64, 100, 2, o4n1
			.db 16, 40, 0, o4s5
			.db 64, 72, 2, o4n1
			.db 160, 70, 1, o4n1
			.db 16, 48, 0, o4s4
		.7_2:
			.db 60
			.db 128, 88, 0, o4b0
			.db 64, 88, 0, o4b0
			.db 160, 88, 0, o4b0
			.db 90, 88, 0, o4b0
			.db 24, 88, 0, o4b0
			.db 96, 88, 0, o4b0
			.db 160, 88, 0, o4b0
		.7_3:
			.db 60
			.db 148, 88, 1, o4n1
			.db 52, 64, 1, o4b0
			.db 148, 64, 1, o4n1
			.db 52, 0, 0, o4s4
			.db 52, 64, 1, o4b0
			.db 148, 64, 1, o4n1
			.db 52, 0, 0, o4s4
	.8:
		.db (.8_addrsend - .8_addrs) / 2
		.8_addrs:
			.dw .8_1, .8_2, .8_3
		.8_addrsend:
		.8_1:
			.db 20
			.db 160, 112, 2, o4s2
			.db 152, 24, 0, o4t2
			.db 90, 80, 0, o4t11
			.db 98, 8, 1, o4f0
			.db 20, 116, 8, o4s2
			.db 106, 0, 0, o4t12
			.db 98, 8, 1, o4f0
			.db 12, 16, 0, o4t2
		.8_2:
			.db 80
			.db 60, 88, 0, o4t4
			.db 52, 0, 0, o4n1
			.db 150, 69, 0, o4b0
			.db 60, 70, 0, o4t12
			.db 52, 8, 1, o4f0
			.db 150, 60, 0, o4n1
			.db 68, 24, 0, o4t4
			.db 60, 0, 0, o4n1
		.8_3:
			.db 50
			.db 52, 152, 4, o4s2
			.db 44, 24, 0, o4t2
			.db 152, 100, 4, o4s2
			.db 144, 24, 0, o4t2
			.db 52, 100, 4, o4s2
			.db 44, 24, 0, o4t2
			.db 152, 100, 4, o4s2
			.db 144, 24, 0, o4t2
monkeywordtiles:
	.db $59, $4e, $5a, $57, $48, $4f, $5d
titlepals:
	.db $21, $0d, $10, $20
	.db $21, $0d, $0c, $2b
	.db $21, 0, 0, 0
	.db $21, $01, $0d, $0d
	.db $21, $0d, $00, $00
	.db $21, $00, $00, $20
	.db $21, 0, 0, 0
	.db $21, 0, 0, 0
gamepals:
	.db $21, $0c, $1b, $29
	.db $21, 0, 0, 0
	.db $21, 0, 0, 0
	.db $21, 0, 0, 0
	.db $21, $0d, $17, $27
	.db $21, $0d, $00, $10
	.db $21, $0d, $21, $20
	.db $21, $0d, $16, $37
sdaddrs:
	.dw d1SD_norm			
	.dw d1SD_norm			
	.dw d1SD_norm			
	.dw d1SD_norm			
	.dw d1SD_norm			
	.dw d1SD_norm			
	.dw d1SD_norm			
	.dw d1SD_norm			
	.dw d1SD_speed			
	.dw d1SD_speed			
	.dw d1SD_timer			
	.dw d1SD_timer			
	.dw d1SD_norm			
	.dw d1SD_crumble			
	.dw d1SD_crumble			
	.dw d1SD_crumble			
	.dw d1SD_crumble			
	.dw d1SD_crumble			
	.dw d1SD_crumble			
	.dw d1SD_crumble			
	.dw d1SD_spike			
	.dw d1SD_spike			
	.dw d1SD_spike			
	.dw d1SD_spike			
	.dw d1SD_spike			
	.dw d1SD_thorn			
	.dw d1SD_thorn			
	.dw d1SD_thorn_l_dbl		
	.dw d1SD_thorn_r_dbl		
	.dw d1SD_thorn_r_dbl		
	.dw d1SD_thorn_r_dbl		
	.dw d1SD_thorn_l_dbl		
	.dw d1SD_thorn_r_dbl		
	.dw d1SD_thorn_l_dbl		
	.dw d1SD_thorn_r_dbl		
	.dw d1SD_thorn_l_flip	
	.dw d1SD_thorn_r_flip	
	.org $fffa
	.dw nmi
	.dw reset
	.dw 0
	.bank 2
	.org $0000
	.incbin "bin/graphics.chr"
	.rsset 0
d1SetPalettesp0 .rs 2
	.rsset 0
d1DrawNTTilesAndAttrsd0 .rs 2
	.rsset 0
d1UpdateBasePalsa0 .rs 2
	.rsset 0
c3SpeedToMvmts0 .rs 1
c3SpeedToMvmtw0 .rs 1
	.rsset 2
c3SmoothToTargc0 .rs 1
	.rsset 0
m8CheckStillOnWallo0 .rs 1
m8CheckStillOnWallo1 .rs 1
	.rsset 0
f4CreateBounceb0 .rs 1
f4CreateBounces0 .rs 1
f4CreateBounceo0 .rs 1
	.rsset 0
f4CreateEffectf0 .rs 1
f4CreateEffecte0 .rs 1
	.rsset 3
m8CollideWithObjso1 .rs 1
m8CollideWithObjso0 .rs 1
m8CollideWithObjso2 .rs 1
	.rsset 0
c3ModRandomNumm0 .rs 1
c3ModRandomNumr0 .rs 1
	.rsset 2
m8PlayJumpSoundc0 .rs 1
m8PlayJumpSoundw0 .rs 1
	.rsset 0
d1SD_tie_wordx0 .rs 1
	.rsset 0
d1SD_scores0 .rs 1
d1SD_scorex0 .rs 1
	.rsset 0
d1SD_monkeya1 .rs 1
d1SD_monkeyx0 .rs 1
d1SD_monkeyc0 .rs 1
d1SD_monkeya0 .rs 1
d1SD_monkeyy0 .rs 1
d1SD_monkeyo0 .rs 1
d1SD_monkeya2 .rs 1
	.rsset 0
d1SoftDrawObjss0 .rs 2
d1SoftDrawObjsf0 .rs 1
d1SoftDrawObjsn0 .rs 1
d1SoftDrawObjsn1 .rs 1
d1SoftDrawObjsc1 .rs 1
d1SoftDrawObjsc0 .rs 1
	.rsset 0
d1SD_cloudx0 .rs 1
d1SD_cloudy0 .rs 1
	.rsset 0
d1SD_monkeyWordx0 .rs 1
d1SD_monkeyWordl0 .rs 1
d1SD_monkeyWorda1 .rs 1
d1SD_monkeyWordy0 .rs 1
d1SD_monkeyWorda0 .rs 1
	.rsset 0
d1BounceShaker0 .rs 1
	.rsset 0
d1SD_thorn_flippingf0 .rs 1
d1SD_thorn_flippinga0 .rs 2
	.rsset 0
d1SD_speedf0 .rs 1
d1SD_speeda0 .rs 1
	.rsset 0
d1SD_timerx0 .rs 1
d1SD_timern0 .rs 1
d1SD_timery0 .rs 1
	.rsset 0
g0ApplyYOffsetn0 .rs 1
	.rsset 0
g0ApplyXOffsetn0 .rs 1
	.rsset 2
g0CreateObjsa0 .rs 1
g0CreateObjsn0 .rs 1
g0CreateObjsl0 .rs 1
g0CreateObjsm0 .rs 1
	.rsset 6
g0Generatea0 .rs 2
	.rsset 8
b5 = %00010000
c4t5 = _tcfe- _tcf
c4c2 = 120 - (16 + 16 + 3)
c4t4 = 128
c4t3 = 167 
c4c5 = 255
c4c3 = 80
c4m0 = $01a3
c4t2 = (240 / 2) - 4
c4c4 = 157
m3 = 9
f2 = 19
f0 = 3
m7 = 13
m4 = 10
s1 = 15
d0 = 2
v0 = 18
m0 = 6
l0 = 4
b8 = 0
c1 = 14
f1 = 16
m5 = 11
b9 = 17
m1 = 7
m6 = 12
s0 = 5
m2 = 8
c0 = 1
b7 = %01000000
m8b2 = %00000010
m8b0 = %10000000
m8b5 = %00010000
m8b3 = %00000100
m8b4 = %00001000
m8h0 = 32
m8y2 = (240 / 2) - (m8h0/ 2)
m8w0 = 24
m8b1 = %00000001
m8i0 = 8 
m8u0 = 20
m8b6 = %00100000
m8j1 = 1
m8i1 = 0
m8b7 = 2
m8j0 = 12
m8x2 = (256 / 2) - (m8w0/ 2)
b4 = %00001000
f4e2 = %00010000
f4e0 .rs 8
f4e5 = f4e0+ 2
f4b5 = 4
f4e1 = f4e0+ 0
f4e7 = 4
f4b0 .rs 8
f4b2 = f4b0+ 1
f4e3 = %00100000
f4b6 = f4bouncexsend- f4bouncexs
f4e6 = f4e0+ 3
f4b1 = f4b0+ 0
f4b4 = f4b0+ 3
f4e4 = f4e0+ 1
f4b3 = f4b0+ 2
b1 = %00000001
o4t13 = 32
o4o0 = 5
o4b1 = 6
o4m0 = 64
o4u2 = 5
o4u1 = 3
o4u0 = 2
o4s5 = 21
o4f0 = 11
o4t5 = 29
o4s7 = 23
o4t7 = 31
o4t11 = 35
o4c1 = 14
o4t8 = 32
o4s2 = 9
o4c6 = 19
o4t12 = 36
o4t9 = 33
o4s8 = 24
o4t4 = 28
o4t3 = 27
o4s4 = 20
o4d1 = 4
o4c2 = 15
o4t10 = 34
o4s6 = 22
o4b0 = 12
o4t1 = 25
o4c3 = 16
o4r0 = 6
o4t2 = 26
o4l0 = 7
o4s3 = 10
o4c4 = 17
o4n1 = 0
o4t6 = 30
o4d0 = 1
o4c0 = 13
o4s1 = 8
o4c5 = 18
o4n2 = 24
o4o1 .rs 120
o4n0 = o4o1+ 2
o4x0 = o4o1
o4t0 = o4o1+ 4
o4y0 = o4o1+ 1
o4s0 = o4o1+ 3
i0b1 = %01000000
i0c0 = $4016
i0b0 = %10000000
i0b6 = %00000010
i0b7 = %00000001
i0b3 = %00010000
i0b2 = %00100000
i0b5 = %00000100
i0b4 = %00001000
i0c1 = $4017
b0 = %10000000
b3 = %00000100
o0 = $0200
o3 = o0+ 3
o1 = o0+ 1
d1t6 = $4e| 1
d1o0 = $f0
d1o1 = $f2
d1o2 = $f4
d1a2 = $e6| 1
d1t9 = 6
d1m0 = 112
d1f1 = 2
d1s4 = 140
d1t7 = -5
d1c5 = 32
d1v0 = %10000000
d1t1 = 114
d1o5 = $4d
d1s5 = $01c0
d1t2 = $50
d1w0 = $20
d1t5 = $6c| 1
d1o4 = 94
d1f0 = 120
d1n1 = d1sky_cols_end- d1sky_cols
d1h0 = %01000000
d1b0 = $0400
d1y0 = 16
d1c2 = $5a| 1
d1t8 = m8w0- 3
d1p0 = $0100
d1s3 = $2b
d1c3 = 128 - 12
g0h6 = 200
g0h2 = 200
g0h4 = 52	
g0o1 = 4
g0h1 = 120
g0h5 = 139
g0n1 = o4n2/ 2
g0t0 = 190
g0h3 = 10
g0h0 = 50
b2 = %00000010
o2 = o0+ 2
b6 = %00100000
p1 .rs 1
b10 .rs 1
p0 .rs 1
c2 .rs 1
p2 .rs 1
s2 .rs 2
s3 .rs 2
c4t0 .rs 1
c4t1 .rs 1
c4c0 .rs 1
c4v0 .rs 1
c4h0 .rs 2
c4c1 .rs 1
c4s0 .rs 1
m8x0 .rs 3
m8b8 .rs 3
m8t0 .rs 3
m8y1 .rs 3
m8y0 .rs 3
m8s0 .rs 3
m8u1 .rs 3
m8w1 .rs 3
m8x1 .rs 3
m8t1 .rs 3
m8i2 .rs 3
o4t16 .rs 1
o4w0 .rs 1
o4c7 .rs 1
o4b4 .rs 1
o4o3 .rs 1
o4o2 .rs 1
o4b2 .rs 1
o4b3 .rs 1
o4m1 .rs 1
o4m2 .rs 1
o4t14 .rs 1
o4t15 .rs 1
i0b8 .rs 3
i0b9 .rs 3
d1c0 .rs 1
d1o3 .rs 1
d1s0 .rs 1
d1e1 .rs 1
d1t3 .rs 1
d1a1 .rs 2
d1a0 .rs 1
d1e2 .rs 1
d1t0 .rs 1
d1s1 .rs 1
d1d1 .rs 1
d1d0 .rs 1
d1e0 .rs 1
d1u0 .rs 1
d1m2 .rs 1
d1b1 .rs 1
d1f2 .rs 1
d1t4 .rs 2
d1n0 .rs 1
d1m1 .rs 1
d1c4 .rs 1
d1s2 .rs 4
d1x0 .rs 1
d1c1 .rs 1
g0n0 .rs 1
g0s0 .rs 1
g0g0 .rs 1
g0c0 .rs 1
g0o0 .rs 1
g0c1 .rs 1
