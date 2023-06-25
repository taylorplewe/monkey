class disp

const FOLLOW_MONKEY_THRESH 120
const OBJ_TOP_TILE $f0
const OBJ_MED_TILE $f2
const OBJ_BOT_TILE $f4

const V_FLIP %10000000
const H_FLIP %01000000

const PPU_BUFF $0100

const BASE_PALS $0400

var [1] oamInd
var [1] scroll
var [1] xscroll ; (for shaking on death)
var [1] thornFrameAdd
var [1] scrollForNextGen
var [1] diff
var [4] score
var [1] deathCtr
var [1] bufflen
var [1] explX
var [1] explY
var [1] animcounter

; params:
;	xy - PPU address
;	dataaddr - address to tile data (attr data must immediately follow)
DrawNTTilesAndAttrs:
	var [2] dataaddr
	; draw BG tiles
	stx $2006
	sty $2006
	.tiles:
		ldy #0
		ldx #3
		.tileloop:
			lda [dataaddr], y
			sta $2007
			iny
			bne .tileloop
			inc dataaddr+1
			dex
			bne .tileloop
		.tileloop4:
			lda [dataaddr], y
			sta $2007
			iny
			cpy #192
			bne .tileloop4
	; attrs
		.attrloop:
			lda [dataaddr], y
			sta $2007
			iny
			bne .attrloop
	rts

; params:
;	paladdr - address to palette data
SetPalettes:
	var [2] paladdr
	lda #$3f
	sta $2006
	lda #$00
	sta $2006
	tay
	.loop:
		lda [paladdr], y
		sta $2007
		iny
		cpy #32
		bne .loop
	rts
InitGame:
	ldx #$20
	ldy #0
	lda #LOW(g.gametiles)
	sta DrawNTTilesAndAttrs.dataaddr
	lda #HIGH(g.gametiles)
	sta DrawNTTilesAndAttrs.dataaddr+1
	jsr DrawNTTilesAndAttrs

	ldx #$28
	ldy #0
	lda #LOW(g.gametiles2)
	sta DrawNTTilesAndAttrs.dataaddr
	lda #HIGH(g.gametiles2)
	sta DrawNTTilesAndAttrs.dataaddr+1
	jsr DrawNTTilesAndAttrs

	; score
	lda #0
	sta scrollForNextGen
	sta score
	sta scroll
	sta sky_col_ind
	jsr UpdateBasePals
	lda #$ff
	sta score + 1
	sta score + 2
	sta score + 3
	sta deathCtr

	rts

InitTitle:
	lda #LOW(titlepals)
	sta SetPalettes.paladdr
	lda #HIGH(titlepals)
	sta SetPalettes.paladdr+1
	jsr SetPalettes

	ldx #$20
	ldy #0
	lda #LOW(g.titletiles)
	sta DrawNTTilesAndAttrs.dataaddr
	lda #HIGH(g.titletiles)
	sta DrawNTTilesAndAttrs.dataaddr+1
	jsr DrawNTTilesAndAttrs

	lda #$ff
	jsr UpdateBasePals

	rts

var [1] upandup
const SPR0_TILE $2b
const SPR0_Y	140
UpdateTitle:
	; sprite 0
	lda #SPR0_TILE
	sta g.OAM_TILE
	lda #SPR0_Y
	sta g.OAM_Y
	lda #64
	sta g.OAM_X
	lda #%00100000 ; behind bg
	sta g.OAM_ATTR

	const ONE_Y 94
	const TWO_Y 114
	const ONE_TILE $4d
	const TWO_TILE $50
	const MONKEY_X 112
	var [1] multi
	lda #0
	sta multi
	lda g.boolParty
	and #g.BOOLS_MULTIPLAYER
	asl a
	asl a
	asl a
	rol multi

	; bob up & down
	lda g.counter
	and #%1111
	bne .bobend
		lda multi
		bne .multbob
		;singlebob:
			lda upandup
			eor #1
			sta upandup
			bpl .bobend ; jmp
		.multbob:
			lda upandup
			eor #2
			sta upandup
	.bobend:

	; 1
	lda #MONKEY_X - 16
	sta g.OAM_X + 4
	lda #ONE_TILE
	sta g.OAM_TILE + 4
	lda multi
	eor #1
	sta g.OAM_ATTR + 4
	sta SD_monkeyWord.attr
	lda #MONKEY_X
	sta SD_monkeyWord.x
	lda #6
	sta SD_monkeyWord.len
	lda upandup
	and #1
	bne .addy1up
		;addy1down:
		lda #ONE_Y
		sta g.OAM_Y + 4
		sta SD_monkeyWord.y
		lda #2
		bne .addy1st ; jmp
		.addy1up:
		lda #ONE_Y + 2
		sta g.OAM_Y + 4
		sta SD_monkeyWord.y
		lda #-2
	.addy1st:
	sta SD_monkeyWord.addy
	ldy #8
	jsr SD_monkeyWord

	; 2
	lda #MONKEY_X - 20
	sta g.OAM_X, y
	lda #TWO_TILE
	sta g.OAM_TILE, y
	lda multi
	sta g.OAM_ATTR, y
	sta SD_monkeyWord.attr
	lda #MONKEY_X - 4
	sta SD_monkeyWord.x
	lda #7
	sta SD_monkeyWord.len
	lda upandup
	and #2
	bne .addy2up
		;addy2down:
		lda #TWO_Y
		sta g.OAM_Y, y
		sta SD_monkeyWord.y
		lda #2
		bne .addy2st ; jmp
		.addy2up:
		lda #TWO_Y + 2
		sta g.OAM_Y, y
		sta SD_monkeyWord.y
		lda #-2
	.addy2st:
	sta SD_monkeyWord.addy
	iny
	iny
	iny
	iny
	jsr SD_monkeyWord

	.end: rts

SD_monkeyWord:
	var [1] len
	var [1] x
	var [1] y
	var [1] addy
	var [1] attr
	ldx #0
	.loop:
		lda monkeywordtiles, x
		sta g.OAM_TILE, y
		lda attr
		sta g.OAM_ATTR, y
		txa
		and #1
		bne >
			lda y
			clc
			adc addy
			bne .yst
		>
			lda y
		.yst:
		sta g.OAM_Y, y
		lda x
		sta g.OAM_X, y
		clc
		adc #8
		sta x
		iny
		iny
		iny
		iny
		inx
		cpx len
		bne .loop
	rts

Update:
	jsr ClearPPUBuff
	jsr ClearOAM

	; cloud
	lda g.counter
	and #%11
	bne .cloudxend
	lda deathCtr
	bpl .cloudxend
		inc cloudx
	.cloudxend:

	; death sequence
	lda deathCtr
	bmi .deathend
		lda ctrl.tiey
		beq >
			jsr SD_tie_word
		>
		lda ctrl.victorind
		beq >
			jsr SD_crown
		>
		jsr SD_deathSq
		lda deathCtr
		cmp #96
		bne >
			jsr ctrl.CrownWinner
		>
		cmp #$7f
		beq >
			inc deathCtr
		>
		jmp .alwaysdraw
	.deathend:

	lda ctrl.chasespeed
	jsr comm.SpeedToMvmt
	jsr ScrollUp

	inc animcounter
	jsr FollowBothMonkeys

	.alwaysdraw:
	jsr SD_score

	var [1] monkeyfront
	lda #0
	sta monkeyfront
	lda g.boolParty
	and #g.BOOLS_MONKEYINFRONT
	bne .front
	lda ctrl.victorind
	beq >
		.front:
		lda #1
		sta monkeyfront
	>

	lda monkeyfront
	beq >
		jsr SD_monkeys
		jsr SD_monkeyTails
	>
	jsr SoftDrawObjs
	lda monkeyfront
	bne >
		jsr SD_monkeys
		jsr SD_monkeyTails
	>
	jsr SD_effects
	jsr SD_cloud
	rts

FollowBothMonkeys:
	ldx #1
	jsr FollowMonkey
	lda g.boolParty
	and #g.BOOLS_MULTIPLAYER
	bne >
		rts
	>
	ldx #2
	jmp FollowMonkey

FollowMonkey:
	lda monkey.bools
	and #monkey.BOOLS_DEAD
	beq >
		.end0: rts
	>
	lda #FOLLOW_MONKEY_THRESH
	cmp monkey.y, x
	beq .end0
	bcc .end0
	; calc diff
		sec
		sbc monkey.y, x
		lsr a
		lsr a
		lsr a
		lsr a
		beq .end0
	; fall thru to ScrollUp

; params:
;	a - amt in pixels to scroll up
ScrollUp:
	sta diff
	; sub from current scroll
		lda scroll
		sec
		sbc diff
		sta scroll
		bcs >
			; passed top
			; align scroll (256 -> 240)
				sec
				sbc #16
				sta scroll
			; switch NTs
				lda g.ppuctrl
				eor #%00000010
				sta g.ppuctrl
			; inc score
				jsr IncreaseScore
				jsr ctrl.IncreaseHexScore
		>
		; move monkeys
			lda monkey.y+1
			clc
			adc diff
			sta monkey.y+1
			lda monkey.targYPos+1
			clc
			adc diff
			sta monkey.targYPos+1

			lda monkey.y+2
			clc
			adc diff
			sta monkey.y+2
			lda monkey.targYPos+2
			clc
			adc diff
			sta monkey.targYPos+2
		; move effects
		lda fx.EF_Y
		clc
		adc diff
		sta fx.EF_Y
		lda fx.EF_Y + fx.EF_RAM_ALLOC
		clc
		adc diff
		sta fx.EF_Y + fx.EF_RAM_ALLOC
		; keep track of correct generator Y & storey
		lda gen.cy
		pha
		clc
		adc diff
		sta gen.cy
		bcc .cstoreyadd
			dec gen.cstorey
			; prevent currently generating Y value from being inside the visible screen (too low)
			lda gen.cstorey
			cmp #2
			bcs .cstoreyadd
			; 1st storey = this screen = too low
			pla
			sta gen.cy
			inc gen.cstorey
			bne .nocystore ; jmp
		.cstoreyadd:
		pla
		.nocystore:
		; for tracking when to generate
		lda scrollForNextGen
		sec
		sbc diff
		sta scrollForNextGen
		bcs .lvlend
			dec gen.nextlvl
			bne .lvlend
			jsr gen.GenerateWholeHalf
		.lvlend:
		; move walls
		var [1] numw
		lda #obj.NUM_OBJS
		sta numw
		ldx #0
		.wallsloop:
			lda obj.STOREY, x
			beq .next
			lda obj.Y, x
			clc
			adc diff
			sta obj.Y, x
			; offcreen?
			bcc >
				dec obj.STOREY, x
			>
			.next:
			txa
			clc
			adc #obj.OBJ_RAM_ALLOC
			tax
			dec numw
			bne .wallsloop ; jmp
		.wallsend:

	.end: rts

ClearOAM:
	ldx oamInd
	lda #$ff
	.loop:
		sta g.OAM_Y, x
		dex
		bne .loop
	stx oamInd
	rts

; params:
;	a - eq -> gamepals
;		ne -> titlepals
UpdateBasePals:
	var [2] addr
	bne .titlepals
	;gamepals:
		lda #LOW(g.gamepals)
		sta addr
		lda #HIGH(g.gamepals)
		sta addr+1
		bne .setend ; jmp
	.titlepals:
		lda #LOW(g.titlepals)
		sta addr
		lda #HIGH(g.titlepals)
		sta addr+1
	.setend:

	ldy #32
	.loop:
		dey
		lda [addr], y
		sta BASE_PALS, y
		cpy #0
		bne .loop

	rts

SoftDrawObjs:
	var [1] cx
	var [1] cy
	var [1] numsg
	var [1] numw
	var [1] frameadd
	var [2] sdaddr
	; many different thorn drawing funcs use this
		lda animcounter
		and #%100000
		lsr a
		lsr a
		lsr a
		lsr a
		sta thornFrameAdd
	ldx #0
	ldy oamInd
	lda #obj.NUM_OBJS
	sta numw
	.loop:
		lda obj.NUMSEGS, x
		clc
		adc #2
		sta numsg
		lda obj.Y, x
		sta cy
		lda obj.X, x
		sta cx
		lda obj.STOREY, x
		beq .next
		cmp #1
		beq .startsgloop
		cmp #2
		bne .next
		.onscreenloop:
			dec numsg
			beq .next
			lda cy
			clc
			adc #16
			sta cy
			bcc .onscreenloop
		.startsgloop:
		txa
		pha
		lda obj.TYPE, x
		asl a
		tax
		lda g.sdaddrs, x
		sta sdaddr
		lda g.sdaddrs+1, x
		sta sdaddr+1
		pla
		tax
		jsr SD_jump
		.next:
		txa
		clc
		adc #obj.OBJ_RAM_ALLOC
		tax
		dec numw
		beq .end
		jmp .loop
	.end:
	sty oamInd
	rts

SD_jump:
	jmp [SoftDrawObjs.sdaddr]

SD_norm:
	.sgloop:
		; x
		jsr BounceShake
		sta g.OAM_X, y
		; y
		lda SoftDrawObjs.cy
		sta g.OAM_Y, y
		; tile
		;lda cy
		cmp obj.Y, x
		beq .top
		; bottom?
		lda SoftDrawObjs.numsg
		cmp #1
		beq .bot
		;medtile
			lda #1
			bne .jsrdraw ; jmp
		.bot:
			lda #2
			bne .jsrdraw ; jmp
		.top:
			lda #0
		.jsrdraw:
		jsr SD_wallSegment
		cmp #$ff
		beq >
			; attr
			lda #0
			sta g.OAM_ATTR, y
		>
		iny
		iny
		iny
		iny
		lda SoftDrawObjs.cy
		clc
		adc #16
		sta SoftDrawObjs.cy
		bcs .end
		dec SoftDrawObjs.numsg
		bne .sgloop
	.end: rts

; returns X of tile
BounceShake:
	var [1] ret
	tya
	pha
	lda SoftDrawObjs.cx
	sta ret

	ldy #0
	.loop:
		lda fx.BOUNCE_FRAMECTR, y
		beq .next
		txa
		cmp fx.BOUNCE_OBJIND, y
		bne .next
		lda fx.BOUNCE_SEGSDOWN, y
		cmp SoftDrawObjs.numsg
		bne .next
		lda fx.BOUNCE_FRAME, y
		tay
		lda fx.bouncexs, y
		clc
		adc ret
		sta ret
		jmp .end
		.next:
		tya
		clc
		adc #fx.BOUNCE_RAM_ALLOC
		tay
		cpy #fx.BOUNCE_RAM_ALLOC * 2
		bne .loop
	.end:
	pla
	tay
	lda ret
	rts

; params:
;	a = segtype, [0|1|2]
;	x = objs index
;	y = OAM index
SD_wallSegment:
	beq .top
	cmp #2
	beq .bot
	; med
		lda obj.TYPE, x
		cmp #obj.TYPES.BOUNCE
		beq .medbounce
		;mednorm:
			lda #OBJ_MED_TILE | 1
			jmp .tilest
		.medbounce:
			lda #$ea | 1
			sta g.OAM_TILE, y
			lda #3
			sta g.OAM_ATTR, y
			lda #$ff
			rts
	.bot:
		lda obj.TYPE, x
		beq .botnorm
		cmp #obj.TYPES.BOUNCE
		beq .botbounce
		;botmove:
			lda #$e0 | 1
			sta g.OAM_TILE, y
			lda #V_FLIP
			sta g.OAM_ATTR, y
			lda #$ff
			rts
		.botbounce:
			lda #$e8 | 1
			sta g.OAM_TILE, y
			lda #V_FLIP | 3
			sta g.OAM_ATTR, y
			lda #$ff
			rts
		.botnorm:
			lda #OBJ_BOT_TILE | 1
			bne .tilest ; jmp
	.top:
		lda obj.TYPE, x
		beq .topnorm
		cmp #obj.TYPES.BOUNCE
		beq .topbounce
		;topmove:
			lda #$e0 | 1
			sta g.OAM_TILE, y
			lda #%00000000
			sta g.OAM_ATTR, y
			lda #$ff
			rts
		.topbounce:
			lda #$e8 | 1
			sta g.OAM_TILE, y
			lda #3
			sta g.OAM_ATTR, y
			lda #$ff
			rts
		.topnorm:
			lda #OBJ_TOP_TILE | 1
	.tilest:
	sta g.OAM_TILE, y
	rts

; params:
;	x = objs index
;	y = OAM index
;	other vars from SoftDrawObjs
SD_speed:
	var [1] attr ;ttribute
	var [1] flip
	lda obj.TYPE, x
	cmp #obj.TYPES.SPDUP
	beq .spdup
	;spddown
		lda #2
		sta attr
		lda #0
		sta flip
		beq .loop ; jmp
	.spdup:
		lda #3
		sta attr
		lda #V_FLIP
		sta flip
	.loop:
		; top?
		lda SoftDrawObjs.cy
		cmp obj.Y, x
		beq .top
		; ok then Y is gonna be 8px down
		lda SoftDrawObjs.cy
		clc
		adc #8
		bcc >
			rts
		>
		sta g.OAM_Y, y
		; x doesn't change
		lda SoftDrawObjs.cx
		sta g.OAM_X, y
		lda SoftDrawObjs.numsg
		cmp #1
		beq .bot
		; med
			lda animcounter
			and #%11
			asl a
			clc
			adc #$f8 | 1
			sta g.OAM_TILE, y
			lda attr
			ora flip
			sta g.OAM_ATTR, y
			bne .next ; jmp
		.bot:
			lda #$f6 | 1
			sta g.OAM_TILE, y
			lda attr
			sta g.OAM_ATTR, y
			iny
			iny
			iny
			iny
			rts
		.top:
			; do top block first
				sta g.OAM_Y, y
				lda #$f6 | 1
				sta g.OAM_TILE, y
				lda attr
				sta g.OAM_ATTR, y
			; x
			lda SoftDrawObjs.cx
			sta g.OAM_X, y
			; then bottom half
			iny
			iny
			iny
			iny
				lda SoftDrawObjs.cy
				clc
				adc #8
				bcs .end
				 sta g.OAM_Y, y
				lda SoftDrawObjs.cx
				 sta g.OAM_X, y
				lda animcounter
				and #%11
				asl a
				clc
				adc #$f8 | 1
				 sta g.OAM_TILE, y
				lda attr
				ora flip
				 sta g.OAM_ATTR, y
				bne .next ; jmp
		.next:
		iny
		iny
		iny
		iny
		lda SoftDrawObjs.cy
		clc
		adc #16
		sta SoftDrawObjs.cy
		bcs .end
		cmp #240
		bcs .end
		dec SoftDrawObjs.numsg
		beq .end
		jmp .loop
	.end: rts

; params:
;	x = objs index
;	y = OAM index
SD_spike:
	lda SoftDrawObjs.cy
	cmp obj.Y, x
	bne .bot
	.top:
		; 1
			lda SoftDrawObjs.cx
			sta g.OAM_X, y
			lda SoftDrawObjs.cy
			sta g.OAM_Y, y
			lda #$e2 | 1
			sta g.OAM_TILE, y
			lda #1
			sta g.OAM_ATTR, y
			
			lda SoftDrawObjs.cx
			clc
			adc #8
			sta SoftDrawObjs.cx
		; 2
			lda SoftDrawObjs.cx
			sta g.OAM_X + 4, y
			lda SoftDrawObjs.cy
			sta g.OAM_Y + 4, y
			lda #$e4 | 1
			sta g.OAM_TILE + 4, y
			lda #1
			sta g.OAM_ATTR + 4, y
			
			lda SoftDrawObjs.cx
			clc
			adc #8
			sta SoftDrawObjs.cx
		; 3
			lda SoftDrawObjs.cx
			sta g.OAM_X + 8, y
			lda SoftDrawObjs.cy
			sta g.OAM_Y + 8, y
			lda #$e4 | 1
			sta g.OAM_TILE + 8, y
			lda #1 | H_FLIP
			sta g.OAM_ATTR + 8, y
			
			lda SoftDrawObjs.cx
			clc
			adc #8
			sta SoftDrawObjs.cx
		; 4
			lda SoftDrawObjs.cx
			sta g.OAM_X + 12, y
			lda SoftDrawObjs.cy
			sta g.OAM_Y + 12, y
			lda #$e2 | 1
			sta g.OAM_TILE + 12, y
			lda #1 | H_FLIP
			sta g.OAM_ATTR + 12, y
			
			lda SoftDrawObjs.cx
			sec
			sbc #24
			sta SoftDrawObjs.cx

			tya
			clc
			adc #16
			tay
			lda SoftDrawObjs.cy
			clc
			adc #16
			sta SoftDrawObjs.cy
			bcs .end2
	.bot:
		; 1
			lda SoftDrawObjs.cx
			sta g.OAM_X, y
			lda SoftDrawObjs.cy
			sta g.OAM_Y, y
			lda #$e2 | 1
			sta g.OAM_TILE, y
			lda #1 | V_FLIP
			sta g.OAM_ATTR, y
			
			lda SoftDrawObjs.cx
			clc
			adc #8
			sta SoftDrawObjs.cx
		; 2
			lda SoftDrawObjs.cx
			sta g.OAM_X + 4, y
			lda SoftDrawObjs.cy
			sta g.OAM_Y + 4, y
			lda #$e4 | 1
			sta g.OAM_TILE + 4, y
			lda #1 | V_FLIP
			sta g.OAM_ATTR + 4, y
			
			lda SoftDrawObjs.cx
			clc
			adc #8
			sta SoftDrawObjs.cx
		; 3
			lda SoftDrawObjs.cx
			sta g.OAM_X + 8, y
			lda SoftDrawObjs.cy
			sta g.OAM_Y + 8, y
			lda #$e4 | 1
			sta g.OAM_TILE + 8, y
			lda #1 | %11000000
			sta g.OAM_ATTR + 8, y
			
			lda SoftDrawObjs.cx
			clc
			adc #8
			sta SoftDrawObjs.cx
		; 4
			lda SoftDrawObjs.cx
			sta g.OAM_X + 12, y
			lda SoftDrawObjs.cy
			sta g.OAM_Y + 12, y
			lda #$e2 | 1
			sta g.OAM_TILE + 12, y
			lda #1 | %11000000
			sta g.OAM_ATTR + 12, y
			
			lda SoftDrawObjs.cx
			clc
			adc #8
			sta SoftDrawObjs.cx
	tya
	clc
	adc #16
	tay
	.end2: rts

; params:
;	x = objs index
;	y = OAM index
SD_thorn:
	lda SoftDrawObjs.numsg
	cmp #2
	beq .top
	bne .bot
		; is at least partially offscreen
		lda obj.Y, x
		clc
		adc #8
		bcc >
			bcs .sides
		>
		clc
		adc #8
		bcc .end2
		bcs .bot
	.top:
		lda SoftDrawObjs.cx
		clc
		adc #8
		sta g.OAM_X, y
		lda SoftDrawObjs.cy
		sta g.OAM_Y, y
		lda thornFrameAdd
		clc
		adc #$c0 | 1
		sta g.OAM_TILE, y
		lda #0
		sta g.OAM_ATTR, y

		iny
		iny
		iny
		iny
		lda SoftDrawObjs.cy
		clc
		adc #8
		bcs .end2
		sta SoftDrawObjs.cy
	.sides:
		jsr SD_thorn_l

		lda SoftDrawObjs.cx
		clc
		adc #16
		sta SoftDrawObjs.cx
		
		jsr SD_thorn_r
		
		lda SoftDrawObjs.cx
		sec
		sbc #16
		sta SoftDrawObjs.cx

		tya
		clc
		adc #8
		tay
		lda SoftDrawObjs.cy
		clc
		adc #8
		bcs .end2
		sta SoftDrawObjs.cy
	.bot:
		lda SoftDrawObjs.cy
		sta g.OAM_Y, y
		lda SoftDrawObjs.cx
		clc
		adc #8
		sta g.OAM_X, y
		lda thornFrameAdd
		clc
		adc #$d0 | 1
		sta g.OAM_TILE, y
		lda #0
		sta g.OAM_ATTR, y
		iny
		iny
		iny
		iny
	.end2: rts

SD_thorn_l:
	lda SoftDrawObjs.cy
	sta g.OAM_Y, y
	lda SoftDrawObjs.cx
	sta g.OAM_X, y
	lda thornFrameAdd
	clc
	adc #$b0 | 1
	sta g.OAM_TILE, y
	lda #0
	sta g.OAM_ATTR, y
	iny
	iny
	iny
	iny
	rts

SD_thorn_r:
	lda SoftDrawObjs.cy
	sta g.OAM_Y, y
	lda SoftDrawObjs.cx
	sta g.OAM_X, y
	lda thornFrameAdd
	clc
	adc #$b0 | 1
	sta g.OAM_TILE, y
	lda #H_FLIP
	sta g.OAM_ATTR, y
	iny
	iny
	iny
	iny
	rts

SD_thorn_l_dbl:
	lda SoftDrawObjs.numsg
	cmp #2
	bne >
		jsr SD_thorn_l
		lda SoftDrawObjs.cy
		clc
		adc #16
		sta SoftDrawObjs.cy
		bcs .end
	>
	jsr SD_thorn_l
	.end: rts

SD_thorn_r_dbl:
	lda SoftDrawObjs.numsg
	cmp #2
	bne >
		jsr SD_thorn_r
		lda SoftDrawObjs.cy
		clc
		adc #16
		sta SoftDrawObjs.cy
		bcs .end
	>
	jsr SD_thorn_r
	.end: rts

sd_thorn_l_flip_tiles:
	.db $c4|1, $c6|1 ; frame 0, 1
	.db $c8|1, $ca|1 ; frame 2, 3
	.db $c8|1, 0 	 ; frame 4, 5
	.db $c4|1, 0 	 ; frame 6, 7
SD_thorn_l_flip:
	lda obj.timerWallMode
	cmp #4
	bcs >
		jmp SD_thorn_l_dbl
	>
	lda #0
	sta SD_thorn_flipping.flip
	lda #HIGH(sd_thorn_l_flip_tiles)
	sta SD_thorn_flipping.addr+1
	lda SoftDrawObjs.cx
	sta temp_x
	lda obj.timerWallCtrAmt
	sec
	sbc obj.timerWallCtr
	cmp #8
	bcs >
		and #%11111110
		clc
		adc #LOW(sd_thorn_l_flip_tiles)
		sta SD_thorn_flipping.addr
		lda SD_thorn_flipping.addr+1
		adc #0
		sta SD_thorn_flipping.addr+1
		bne SD_thorn_flipping
	>
	jmp SD_thorn_l_dbl
	rts

SD_thorn_flipping:
	var [2] addr
	var [1] flip
	txa
	pha
	tya
	tax ; x is now temporarily the OAM index
	ldy #0
	.loop:
		lda [addr], y
		beq .r
		sta g.OAM_TILE, x
		lda SoftDrawObjs.cy
		sta g.OAM_Y, x
		lda flip
		sta g.OAM_ATTR, x
		lda temp_x
		sta g.OAM_X, x
		.r:
		iny
		lda [addr], y
		beq .next
		sta g.OAM_TILE + 4, x
		lda temp_x
		clc
		adc #8
		sta g.OAM_X + 4, x
		lda SoftDrawObjs.cy
		sta g.OAM_Y + 4, x
		lda flip
		sta g.OAM_ATTR + 4, x
		.next:
		dey
		txa
		clc
		adc #8
		tax
		lda SoftDrawObjs.cy
		clc
		adc #16
		sta SoftDrawObjs.cy
		bcs .end
		dec SoftDrawObjs.numsg
		lda SoftDrawObjs.numsg
		cmp #1
		beq .loop ; there's only 2
	.end:
	txa
	tay ; y is up to date with OAM index again
	pla
	tax
	rts

var [1] temp_x

sd_thorn_r_flip_tiles:
	.db 0,	   $c4|1 ; frame 0, 1
	.db 0,	   $c8|1 ; frame 2, 4
	.db $ca|1, $c8|1 
	.db $c6|1, $c4|1 
SD_thorn_r_flip:
	lda obj.timerWallMode
	cmp #4
	bcs >
		jmp SD_thorn_r_dbl
	>
	lda #H_FLIP
	sta SD_thorn_flipping.flip
	lda #HIGH(sd_thorn_r_flip_tiles)
	sta SD_thorn_flipping.addr+1
	lda SoftDrawObjs.cx
	sec
	sbc #8
	sta temp_x
	lda obj.timerWallCtrAmt
	sec
	sbc obj.timerWallCtr
	cmp #8
	bcs >
		and #%11111110
		clc
		adc #LOW(sd_thorn_r_flip_tiles)
		sta SD_thorn_flipping.addr
		lda SD_thorn_flipping.addr+1
		adc #0
		sta SD_thorn_flipping.addr+1
		jmp SD_thorn_flipping
	>
	jmp SD_thorn_r_dbl
	rts

timerwalltiles:
	.db $b4|1, $22|1, $24|1, 0 ; shock
	.db $20|1, $22|1, $24|1, $46|1 ; flip
SD_timer:
	var [1] x
	var [1] y
	var [1] numberTileOffset
	txa
	pha
	lda obj.Y, x
	sta y
	; get right tiles for type
		lda obj.TYPE, x
		sec
		sbc #obj.TYPES.SHOCK
		asl a
		asl a
		tax
	lda SoftDrawObjs.cx
	sec
	sbc #4
	sta x
	; tiles
		; normal:
		;	b4   b4H
		;	b5   b5H
		;	9c   9e			(+ 4*mode)
		;	9d   9f			(+ 4*mode)
		;	b5V  b5HV
		;	b4V  b4HV

	lda obj.timerWallMode
	cmp #4
	bcs .action
	jmp .norm
	.action:
		pla
		tax
		lda obj.TYPE, x
		cmp #obj.TYPES.FLIP
		bne >
			jmp SD_flip
		>
		; play shock sound
		lda deathCtr
		bpl .shocksoundend
		lda obj.timerWallCtrAmt
		sec
		sbc obj.timerWallCtr
		bne .shocksoundend
			lda g.boolParty
			ora #g.BOOLS_PLAYSHOCKSND
			sta g.boolParty
		.shocksoundend:
		; alternate quickly between frames
			lda animcounter
			and #%10
			bne >
				lda #16
				bne .shockst ; jmp
			>
			lda #0
		.shockst:
		sta numberTileOffset
		; how far down?
			lda SoftDrawObjs.numsg
			cmp #2
			beq .smiddle
			cmp #1
			bne .stop
			jmp .sbottom
		.stop:
			lda x
			sta g.OAM_X, y
			lda SoftDrawObjs.cy
			sta g.OAM_Y, y
			lda #$80 | 1
			clc
			adc numberTileOffset
			sta g.OAM_TILE, y
			lda #2
			sta g.OAM_ATTR, y

			lda x
			clc
			adc #8
			sta g.OAM_X + 4, y
			lda SoftDrawObjs.cy
			sta g.OAM_Y + 4, y
			lda #$82 | 1
			clc
			adc numberTileOffset
			sta g.OAM_TILE + 4, y
			lda #2
			sta g.OAM_ATTR + 4, y
		tya
		clc
		adc #8
		tay
		lda SoftDrawObjs.cy
		clc
		adc #16
		sta SoftDrawObjs.cy
		bcs .send
		.smiddle:
			lda x
			sta g.OAM_X, y
			lda SoftDrawObjs.cy
			sta g.OAM_Y, y
			lda #$84 | 1
			clc
			adc numberTileOffset
			sta g.OAM_TILE, y
			lda #2
			sta g.OAM_ATTR, y

			lda x
			clc
			adc #8
			sta g.OAM_X + 4, y
			lda SoftDrawObjs.cy
			sta g.OAM_Y + 4, y
			lda #$86 | 1
			clc
			adc numberTileOffset
			sta g.OAM_TILE + 4, y
			lda #2
			sta g.OAM_ATTR + 4, y
		tya
		clc
		adc #8
		tay
		lda SoftDrawObjs.cy
		clc
		adc #16
		sta SoftDrawObjs.cy
		bcs .send
		.sbottom:
			lda x
			sta g.OAM_X, y
			lda SoftDrawObjs.cy
			sta g.OAM_Y, y
			lda #$88 | 1
			clc
			adc numberTileOffset
			sta g.OAM_TILE, y
			lda #2
			sta g.OAM_ATTR, y

			lda x
			clc
			adc #8
			sta g.OAM_X + 4, y
			lda SoftDrawObjs.cy
			sta g.OAM_Y + 4, y
			lda #$8a | 1
			clc
			adc numberTileOffset
			sta g.OAM_TILE + 4, y
			lda #2
			sta g.OAM_ATTR + 4, y
		tya
		clc
		adc #8
		tay
		.send: rts
	.norm:
		;lda obj.timerWallMode
		cmp #3
		bne .noffs
			lda animcounter
			and #%100
			bne >
				lda obj.timerWallMode
				clc
				adc #1
				bne .noffs ; jmp
			>
			lda obj.timerWallMode
		.noffs:
		asl a
		asl a ; x4
		sta numberTileOffset
		; how far down?
			lda SoftDrawObjs.cy
			cmp y
			beq .top
			lda SoftDrawObjs.numsg
			cmp #2
			bcs .middle
			cmp #1
			bne >
				jmp .bottom
			>
		.top:
			lda x
			sta g.OAM_X, y
			lda SoftDrawObjs.cy
			sta g.OAM_Y, y
			lda timerwalltiles, x
			sta g.OAM_TILE, y
			lda #3
			sta g.OAM_ATTR, y
		; top r
			lda x
			clc
			adc #8
			sta g.OAM_X + 4, y
			lda SoftDrawObjs.cy
			sta g.OAM_Y + 4, y
			lda timerwalltiles, x
			sta g.OAM_TILE + 4, y
			lda #3 | H_FLIP
			sta g.OAM_ATTR + 4, y
		tya
		clc
		adc #8
		tay
		lda SoftDrawObjs.cy
		clc
		adc #16
		sta SoftDrawObjs.cy
		bcc >
			jmp .end
		>
		dec SoftDrawObjs.numsg
		.middle:
			; alternate middle tiles
				lda SoftDrawObjs.numsg
				and #1
				beq >
					lda numberTileOffset
					ora #%10000000
					sta numberTileOffset
				>
			lda SoftDrawObjs.cy
			sta g.OAM_Y, y
			lda x
			sta g.OAM_X, y
			; which number tile?
				lda numberTileOffset
				bmi .oddml
				clc
				adc timerwalltiles + 1, x
				bne .middlelst ; jmp
				.oddml:
				lda timerwalltiles + 3, x
			.middlelst:
			sta g.OAM_TILE, y
			lda #3
			sta g.OAM_ATTR, y
		.middler:
			lda x
			clc
			adc #8
			sta g.OAM_X + 4, y
			lda SoftDrawObjs.cy
			sta g.OAM_Y + 4, y
			; which number tile?
				lda numberTileOffset
				bmi .oddmr
				clc
				adc timerwalltiles + 2, x
			sta g.OAM_TILE + 4, y
			lda #3
			sta g.OAM_ATTR + 4, y
			bne .middledone
			.oddmr:
			lda timerwalltiles + 3, x
			sta g.OAM_TILE + 4, y
			lda #3 | H_FLIP
			sta g.OAM_ATTR + 4, y
		.middledone:
		tya
		clc
		adc #8
		tay
		lda SoftDrawObjs.cy
		clc
		adc #16
		sta SoftDrawObjs.cy
		bcs .end
		lda numberTileOffset
		and #%01111111
		sta numberTileOffset
		dec SoftDrawObjs.numsg
		lda SoftDrawObjs.numsg
		cmp #2
		bcs .middle
		.bottom:
			lda SoftDrawObjs.cy
			sta g.OAM_Y, y
			lda x
			sta g.OAM_X, y
			lda timerwalltiles, x
			sta g.OAM_TILE, y
			lda #3 | V_FLIP
			sta g.OAM_ATTR, y
		; bottom r
			lda x
			clc
			adc #8
			sta g.OAM_X + 4, y
			lda SoftDrawObjs.cy
			sta g.OAM_Y + 4, y
			lda timerwalltiles, x
			sta g.OAM_TILE + 4, y
			lda #3 | %11000000
			sta g.OAM_ATTR + 4, y
		tya
		clc
		adc #8
		tay
	.end:
	pla
	tax
	rts

flippingwalltiles:
	.db $36|1, $3c|1, $38|1, $3a|1 ; 1st turn fram
	.db $3c|1, $3e|1, $40|1, $42|1 ; 2nd turn frame
	.db $3e|1, $3c|1, $42|1, $40|1 ; 4th turn frame
	.db $3c|1, $36|1, $3a|1, $38|1 ; 3rd turn fram
	.db $20|1, $20|1, $44|1, $44|1 ; straight on w/ no number
flippingwallattrs:
	.db 3, 3|H_FLIP, 3, 3
	.db 3, 3, 3, 3
	.db 3|H_FLIP, 3|H_FLIP, 3|H_FLIP, 3|H_FLIP
	.db 3, 3|H_FLIP, 3|H_FLIP, 3|H_FLIP
	.db 3, 3|H_FLIP, 3, 3|H_FLIP
flippingbetweentiles:
	.db $48|1, $4a|1, 0, 0
	.db $4a|1, $4c|1, 0, 0
	.db $4c|1, $4a|1, 0, 0
	.db $4a|1, $48|1, 0, 0
	.db $46|1, $46|1, 0, 0
flippingbetweenattrs:
	.db 3, 3|H_FLIP, 0, 0
	.db 3, 3, 0, 0
	.db 3|H_FLIP, 3|H_FLIP, 0, 0
	.db 3, 3|H_FLIP, 0, 0
	.db 3, 3|H_FLIP, 0, 0
SD_flip:
	const FRAME_AMT 2
	txa
	pha
	; which frame?
	lda obj.timerWallCtrAmt
	sec
	sbc obj.timerWallCtr
	pha
	cmp #8
	bcs .straighton
	; change every 2 frames
	asl a
	and #%11111100
	tax
	bpl .st ; jmp
	.straighton:
		ldx #16
	.st:
	; how far down?
		lda SoftDrawObjs.cy
		cmp SD_timer.y
		beq .top
		lda SoftDrawObjs.numsg
		cmp #2
		bcs .med
		cmp #1
		bne >
			jmp .bot
		>
	.top:
		lda SD_timer.x
		sta g.OAM_X, y
		lda SoftDrawObjs.cy
		sta g.OAM_Y, y
		lda flippingwalltiles, x
		sta g.OAM_TILE, y
		lda flippingwallattrs, x
		sta g.OAM_ATTR, y

		lda SD_timer.x
		clc
		adc #8
		sta g.OAM_X + 4, y
		lda SoftDrawObjs.cy
		sta g.OAM_Y + 4, y
		lda flippingwalltiles + 1, x
		sta g.OAM_TILE + 4, y
		lda flippingwallattrs + 1, x
		sta g.OAM_ATTR + 4, y

		lda SoftDrawObjs.cy
		clc
		adc #16
		bcc >
			jmp .end
		>
		sta SoftDrawObjs.cy
		tya
		clc
		adc #8
		tay
		dec SoftDrawObjs.numsg
	.med:
		var [2] tile
		var [2] attr
		; alternate middle tiles
			lda flippingwalltiles + 2, x
			sta tile
			lda flippingwalltiles + 3, x
			sta tile+1
			lda flippingwallattrs + 2, x
			sta attr
			lda flippingwallattrs + 3, x
			sta attr+1
			lda SoftDrawObjs.numsg
			and #1
			beq >
				lda flippingbetweentiles, x
				sta tile
				lda flippingbetweentiles+1, x
				sta tile+1
				lda flippingbetweenattrs, x
				sta attr
				lda flippingbetweenattrs+1, x
				sta attr+1
			>
		lda SD_timer.x
		sta g.OAM_X, y
		lda SoftDrawObjs.cy
		sta g.OAM_Y, y
		lda tile
		sta g.OAM_TILE, y
		lda attr
		sta g.OAM_ATTR, y

		lda SD_timer.x
		clc
		adc #8
		sta g.OAM_X + 4, y
		lda SoftDrawObjs.cy
		sta g.OAM_Y + 4, y
		lda tile + 1
		sta g.OAM_TILE + 4, y
		lda attr + 1
		sta g.OAM_ATTR + 4, y

		lda SoftDrawObjs.cy
		clc
		adc #16
		bcs .end
		sta SoftDrawObjs.cy
		tya
		clc
		adc #8
		tay
		dec SoftDrawObjs.numsg
		lda SoftDrawObjs.numsg
		cmp #2
		bcs .med
	.bot:
		lda SD_timer.x
		sta g.OAM_X, y
		lda SoftDrawObjs.cy
		sta g.OAM_Y, y
		lda flippingwalltiles, x
		sta g.OAM_TILE, y
		lda flippingwallattrs, x
		ora #V_FLIP
		sta g.OAM_ATTR, y

		lda SD_timer.x
		clc
		adc #8
		sta g.OAM_X + 4, y
		lda SoftDrawObjs.cy
		sta g.OAM_Y + 4, y
		lda flippingwalltiles + 1, x
		sta g.OAM_TILE + 4, y
		lda flippingwallattrs + 1, x
		ora #V_FLIP
		sta g.OAM_ATTR + 4, y

		tya
		clc
		adc #8
		tay
	.end:
	pla
	bne .flipsoundend
	lda deathCtr
	bpl .flipsoundend
		lda g.boolParty
		ora #g.BOOLS_PLAYFLIPSND
		sta g.boolParty
	.flipsoundend:
	pla
	tax
	rts

crumblytiles:
	.db $00|1, $02|1, $ff, $ff
	.db $04|1, $06|1, $ff, $ff
	.db $08|1, $0a|1, $ff, $ff
	.db $0c|1, $0e|1, $10|1, $ff
	.db $12|1, $14|1, $16|1, $ff
	.db $18|1, $1a|1, $ff, $ff
	.db $1c|1, $1e|1, $ff, $ff

SD_crumble:
	txa
	pha
	; TODO draw halfway down if needs be
	; get frame
		lda obj.TYPE, x
		sec
		sbc #obj.TYPES.CRUMBLE0
		asl a
		asl a
		tax
	; how far down
	lda SoftDrawObjs.numsg
	cmp #2
	bne .bot
	; draw each of the 3 tiles
	lda SoftDrawObjs.cx
	sta g.OAM_X, y
	lda SoftDrawObjs.cy
	sta g.OAM_Y, y
	lda crumblytiles, x
	sta g.OAM_TILE, y
	lda #1
	sta g.OAM_ATTR, y
	lda SoftDrawObjs.cy
	clc
	adc #16
	bcs .end
	sta SoftDrawObjs.cy
	iny
	iny
	iny
	iny

	.bot:
	lda SoftDrawObjs.cx
	sta g.OAM_X, y
	lda SoftDrawObjs.cy
	sta g.OAM_Y, y
	lda crumblytiles+1, x
	sta g.OAM_TILE, y
	lda #1
	sta g.OAM_ATTR, y
	lda SoftDrawObjs.cy
	clc
	adc #16
	bcs .end
	sta SoftDrawObjs.cy
	iny
	iny
	iny
	iny

	lda crumblytiles+2, x
	bmi .end ; $ff = no tile here
	sta g.OAM_TILE, y
	lda SoftDrawObjs.cx
	sta g.OAM_X, y
	lda SoftDrawObjs.cy
	sta g.OAM_Y, y
	lda #1
	sta g.OAM_ATTR, y
	iny
	iny
	iny
	iny

	.end:
	pla
	tax
	rts

IncreaseScore:
	; 1 place digit
	inc score
	lda score
	cmp #10
	bcc .end
		; 10 place digit
		lda #0
		sta score
		inc score+1
		bne >
			inc score+1 ; initialized to $ff
		>
		lda score+1
		cmp #10
		bcc .end
			; 100 place digit
			lda #0
			sta score+1
			inc score+2
			bne >
				inc score+2
			>
			lda score+2
			cmp #10
			bcc .end
				; 1,000 place digit
				lda #0
				sta score+2
				inc score+3
				bne >
					inc score+3
				>
	.end: rts
SD_score:
	const TILE $6c | 1
	const Y 16
	var [1] x
	var [1] sexyx
	; figure out position
		lda #0
		sta sexyx
		ldx #1
		.posloop:
			lda score, x
			bmi .posloopend
			inc sexyx
			inx
			cpx #4
			bne .posloop
		.posloopend:
		lda sexyx
		asl a
		asl a
		sta sexyx
		lda #124
		clc
		adc sexyx
		sta x
	ldy oamInd
	ldx #0
	.loop:
		lda score, x
		bmi .end
		asl a
		clc
		adc #TILE
		sta g.OAM_TILE, y
		lda x
		sta g.OAM_X, y
		lda #Y
		sta g.OAM_Y, y
		lda #2
		sta g.OAM_ATTR, y
		iny
		iny
		iny
		iny
		lda x
		sec
		sbc #8
		sta x
		inx
		cpx #4
		bcc .loop
	.end:
	sty oamInd
	rts

shakes:
	.db 4, 4, -4, -4, 3, 3, -3, -3, 3, 3, -3, -3, 2, 2, -2, -2, 2, 2, -2, -2, 1, 1, -1, -1, 1, 1, -1, -1, 1, 1, -1, -1
shakesend:
explosiontiles:
	.db $bc|1, $cc|1, $dc|1, $ec|1, $50|1, $54|1, $8c|1
SD_deathSq:
	lda explX
	cmp #$ff
	beq .end0
	lda deathCtr
	bmi .end0
	cmp #0
	bne >
		jmp BuffAllWhite ; jsr, rts
	>
	cmp #2
	bcs >
		.end0: rts
	>
	bne >
		pha
		lda #$ff ; buffer explosion palette
		ldx #0
		jsr BuffPals ; jsr, rts
		pla
	>
	; draw explosion
	var [1] etile
	sec
	sbc #2
	pha
		tax
		; shake it up gay boy! :)
		cmp #shakesend - shakes
		bcs .noshake
			; Am I a Gay Boy?
			lda shakes, x
			bne .shakeend ; jmp
			.noshake:
			lda #0
			; No, I'm Not a "Gay Boy"
		.shakeend:
		sta xscroll
	pla
	cmp #28
	bcc >
		bne .end
		lda #0
		tax
		jmp BuffPals
	>
	and #%11111100 ; advance anim frame every 2 game frames
	lsr a
	lsr a
	tax
	lda explosiontiles, x
	sta etile
	ldx oamInd
	ldy #0
	.explloop:
		; tile
			tya
			and #1
			beq >
				lda etile
				eor #%10
				sta etile
			>
			lda etile
			sta g.OAM_TILE, x
		; x
			tya
			and #%11
			asl a
			asl a
			asl a
			clc
			adc explX
			sec
			sbc #8
			sta g.OAM_X, x
		; y
			tya
			and #%100
			asl a
			asl a
			clc
			adc explY
			sta g.OAM_Y, x
		; attr
			tya
			and #%110 ; conveniently, H_FLIP and V_FLIP are in correct spots, shifted over
			asl a
			asl a
			asl a
			asl a
			asl a
			ora #1
			sta g.OAM_ATTR, x
		; next
		inx
		inx
		inx
		inx
		iny
		cpy #8
		bne .explloop
	stx oamInd

	.end: rts

BuffAllWhite:
	ldx bufflen
	; info bytes
		lda #32
		sta PPU_BUFF, x
		tay
		inx
		lda #$3f
		sta PPU_BUFF, x
		inx
		lda #0
		sta PPU_BUFF, x
		inx
	; data bytes
	lda #$20 ; white
	.loop:
		sta PPU_BUFF, x
		inx
		dey
		bne .loop
	stx bufflen
	rts

; params:
;	a - eq -> palette 1 = gray
;		mi -> palette 1 = explosion
;		pl -> palette 1 = crown
BuffPals: ;lmao
	pha
	ldx bufflen
	; info bytes
		lda #32
		sta PPU_BUFF, x
		inx
		lda #$3f
		sta PPU_BUFF, x
		inx
		lda #0
		sta PPU_BUFF, x
		inx
	; data bytes
	ldy #0
	.loop:
		lda BASE_PALS, y
		sta PPU_BUFF, x
		inx
		iny
		cpy #32
		bne .loop
	; go back and insert new explosion colors
	pla
	beq .end
	bpl .crown
		lda #$06
		sta PPU_BUFF-11, x
		lda #$38
		sta PPU_BUFF-10, x
		lda #$20
		sta PPU_BUFF-9, x
		bne .end ; jmp
	.crown:
		lda #$0d
		sta PPU_BUFF-11, x
		lda #$18
		sta PPU_BUFF-10, x
		lda #$28
		sta PPU_BUFF-9, x
	.end:
	stx bufflen
	rts

sky_cols:
	.db $31, $32, $33, $34, $35, $36, $26
sky_cols_end:
sky_col_levels:
	.db 9,  29,  59,  89, 127, 152, 179
const NUM_SKY_COLS sky_cols_end - sky_cols
const sky_col_ind $01a8
UpdateSkyColor:
	; time to change it?
	ldx sky_col_ind
	cpx #NUM_SKY_COLS
	bcs .end
	lda ctrl.hexscore
	cmp sky_col_levels, x
	bne .end

	; yes change it
	ldx sky_col_ind
	inc sky_col_ind
	lda sky_cols, x
	sta BASE_PALS+$10
	lda #0
	jmp BuffPals
	.end: rts

ClearPPUBuff:
	ldy bufflen
	beq .end
	lda #0
	.loop:
		dey
		sta PPU_BUFF, y
		cpy #0
		bne .loop
	sty bufflen
	.end: rts

mmonkeytiles:
	.db $00, $02, $04, $06, $08, $0a, 0, 0 ; idle0
	.db $00, $02, $04, $06, $0c, $0e, 0, 0 ; idle1
	.db $10, $12, $14, $16, $18, $1a, 0, 0 ; idle2
	.db $10, $12, $14, $16, $1c, $1e ; idle3
	.db $20, $22, $24, $26, $28, $2a ; jump
	.db $2c, $2e, $30, $32, $34, $36 ; bflip1
	.db $38, $3a, $3c, $3e, $40, $42 ; bflip2
SD_monkey:
	var [1] attr
	var [1] x
	var [1] addx
	var [1] y
	var [1] addy
	var [1] col
	var [1] off
	const ARROW_TILE $e6 | 1
	lda monkey.bools, x
	and #monkey.BOOLS_DEAD
	beq >
		rts
	>

	; draw little offscreen arrow
	lda monkey.bools, x
	and #monkey.BOOLS_OFFSCR
	beq .arrowend
	lda monkey.x, x
	cmp #$f0
	bcs .arrowend
		ldy oamInd
		lda #ARROW_TILE
		sta g.OAM_TILE, y
		lda monkey.y, x
		clc
		adc #12
		sta g.OAM_Y, y
		; attr
		cpx #2
		beq .arrowpal2
		;arrowpal1:
			lda #0
			beq .arrowpalst
		.arrowpal2:
			lda ctrl.m2p
		.arrowpalst:
		sta g.OAM_ATTR, y
		lda monkey.x, x
		bmi .arrowl
		;arrowr:
			lda #256 - 16
			sta g.OAM_X, y
			lda g.OAM_ATTR, y
			ora #H_FLIP
			sta g.OAM_ATTR, y
			bne .arrowrest ; jmp
		.arrowl:
			lda #8
			sta g.OAM_X, y
		.arrowrest:
		iny
		iny
		iny
		iny
		sty oamInd
	.arrowend:

	; init
		; offscreen
			lda monkey.bools, x
			and #monkey.BOOLS_OFFSCR
			cmp #1
			lda #0
			rol a
			sta off
		lda monkey.x, x
		sta x
		pha
		lda monkey.y, x
		sta y
		lda #8
		sta addx
		lda #16
		sta addy
	; flipped?
		lda monkey.bools, x
		bpl >
			pla
			clc
			adc #16
			sta x
			pha
			bcc .offend
				lda off
				eor #1
				sta off
			.offend:
			lda #-8
			sta addx
			lda attr
			ora #H_FLIP
			sta attr
		>
	lda monkey.state, x
	cmp #monkey.STATE.JUMP
	beq .jump
	cmp #monkey.STATE.BFLIP
	beq .bflip
	;idle:
	txa ; monkey ind, 01 or 10
	asl a
	asl a
	asl a
	eor animcounter
	eor #%11000
	and #%11000 ; conveniently in right spot
	tax
	bpl .draw ; jmp
	.jump:
	ldx #30
	bne .draw ; jmp
	.bflip:
		lda animcounter
		and #%100
		bne .fliph
			lda #-16
			sta addy
			lda y
			clc
			adc #16
			sta y
			lda attr
			ora #V_FLIP
			sta attr
			bne .bflipx ; jmp
		.fliph:
			lda attr
			eor #H_FLIP
			sta attr
			pla
			lda addx
			asl a
			bmi .flipxmi
			;flipxpl:
				clc
				adc x
				sta x
				bcc .flipaddx
				lda off
				eor #1
				sta off
				bpl .flipaddx ; jmp
			.flipxmi:
				clc
				adc x
				sta x
				bcs .flipaddx
				lda off
				eor #1
				sta off
			.flipaddx:
			lda x
			pha ; x
			; addx = -addx
			lda addx
			sec
			sbc #1
			eor #$ff
			sta addx
		.bflipx:
		lda animcounter
		and #%10
		bne >
			ldx #36
			bne .draw ; jmp
		>
		ldx #42
	.draw:
	lda off
	pha
	lda #0
	sta col
	ldy oamInd
	.loop:
		lda off
		bne .nexto
		lda x
		sta g.OAM_X, y
		lda y
		sta g.OAM_Y, y
		lda mmonkeytiles, x
		sta g.OAM_TILE, y
		lda attr
		sta g.OAM_ATTR, y
		iny
		iny
		iny
		iny
		.nexto:
		inx
		inc col
		lda col
		cmp #3
		beq .3
		cmp #6
		beq .end
		;reg:
			lda addx
			bmi .addxmi
			;addxpl:
				clc
				adc x
				sta x
				bcc .addxend
				lda off
				eor #1
				sta off
				bpl .addxend ; jmp
			.addxmi:
				clc
				adc x
				sta x
				bcs .addxend
				lda off
				eor #1
				sta off
			.addxend:
			jmp .loop
		.3:
			pla
			sta off
			pla
			sta x
			lda addy
			bmi .addymi
			;addypl:
				lda y
				clc
				adc addy
				sta y
				bcs .end
				bcc .loop
			.addymi:
				lda y
				clc
				adc addy
				sta y
				bcc .end
				bcs .loop
	.end:
	sty oamInd
	rts

SD_monkeys:
	ldx #1
	lda #0
	sta SD_monkey.attr
	jsr SD_monkey
	lda g.boolParty
	and #g.BOOLS_MULTIPLAYER
	bne >
		rts
	>
	ldx #2
	lda ctrl.m2p
	sta SD_monkey.attr
	jmp SD_monkey

; draw monkeys' tails separately when jumping
; they have least priority & thus won't always appear
const TAIL_TILE $4e | 1
const TAIL_REL_XMI -5
const TAIL_REL_XPL monkey.WIDTH - 3
const TAIL_REL_Y 6
SD_monkeyTails:
	;monkey1:
	lda monkey.bools+1
	and #monkey.BOOLS_OFFSCR | monkey.BOOLS_DEAD
	bne .monkey2
	lda monkey.state+1
	cmp #monkey.STATE.JUMP
	bne .monkey2
		ldx #1
		jsr .draw
	.monkey2:
	lda monkey.bools+2
	and #monkey.BOOLS_OFFSCR | monkey.BOOLS_DEAD
	bne .end
	lda monkey.state+2
	cmp #monkey.STATE.JUMP
	bne .end
		ldx #2
		jmp .draw
	.end: rts
	.draw:
		ldy oamInd
		lda monkey.y, x
		clc
		adc #TAIL_REL_Y
		bcs .drawret
		sta g.OAM_Y, y
		lda #TAIL_TILE
		sta g.OAM_TILE, y
		lda monkey.bools, x
		pha
		and #monkey.BOOLS_FACING
		lsr a
		sta g.OAM_ATTR, y
			; color
			cpx #2
			beq .pal2
			;pal1:
				lda #0
				beq .palst
			.pal2:
				lda ctrl.m2p
			.palst:
		ora g.OAM_ATTR, y
		sta g.OAM_ATTR, y
		pla
		bpl >
			lda #TAIL_REL_XPL
			bne .drawend ; jmp
		>
		lda #TAIL_REL_XMI
		.drawend:
		clc
		adc monkey.x, x
		sta g.OAM_X, y
		iny
		iny
		iny
		iny
		sty oamInd
		.drawret: rts

const WHITE $20
FadeToWhite:
	ldy #0
	.writeloop:
		lda BASE_PALS, y
		sta PPU_BUFF+3, y
		iny
		cpy #32
		bne .writeloop
	sty PPU_BUFF
	lda #$3f
	sta PPU_BUFF+1
	ldy #0
	sty PPU_BUFF+2
	ldx #0
	.fadeloop:
		lda PPU_BUFF+3, x
		cmp #WHITE
		bne >
			iny
			bne .next ; jmp
		>
		and #$f0
		cmp #$30
		bne >
			lda #WHITE
			sta PPU_BUFF+3, x
			iny
			bne .next ; jmp
		>
		lda PPU_BUFF+3, x
		clc
		adc #$10
		sta PPU_BUFF+3, x
		.next:
		inx
		cpx #32
		bne .fadeloop
	cpy #32
	beq >
		lda g.boolParty
		ora #g.BOOLS_NMI_READY
		sta g.boolParty
		ldx #2
		.waitloop:
			txa
			pha
			jsr ft.FamiToneUpdate
			jsr ctrl.TitleSpr0
			pla
			tax
			.waitwait:
				lda $2002
				bpl .waitwait
			dex
			bne .waitloop
			ldy #0
			beq .fadeloop ; jmp
	>

	; now wait 2 more frames
	ldx #2
	jsr comm.WaitNumFrames
	rts

FadeToBase:
	ldx #0
	ldy #4
	.writeloop:
		lda BASE_PALS, x
		and #$0f
		ora #$30
		sta PPU_BUFF+3, x
		inx
		cpx #32
		bne .writeloop
		stx bufflen
		beq .2framer
	.fadeloop:
		lda PPU_BUFF+3, x
		cmp gamepals, x
		bne >
			beq .next ; jmp
		>
		; lda PPU_BUFF+3, x
		sec
		sbc #$10
		sta PPU_BUFF+3, x
		.next:
		inx
		cpx #32
		bne .fadeloop
	dey
	beq >
		.2framer:
		ldx #2
		jsr comm.WaitNumFrames
		jmp .fadeloop
	>
	rts

; "TIE!"
tiewordtiles:
	.db $44, $46, $48, $4a
smoothtieys:
	; must be 16 of them!
	.db -2, 0, 2, 4, 5, 6, 5, 4, 2, 0, -2, -4, -5, -6, -5, -4
SD_tie_word:
	var [1] x
	lda #128 - ((8 * 4) / 2)
	sta x
	ldx #0
	ldy oamInd
	.loop:
		lda tiewordtiles, x
		sta g.OAM_TILE, y
		lda #2
		sta g.OAM_ATTR, y
		; smooth floaty animation
		var [1] ctr
		lda g.counter
		and #%11111100
		lsr a
		lsr a
		sta ctr
		txa
		pha
		clc
		adc ctr
		and #%1111
		tax
		lda smoothtieys, x
		clc
		adc ctrl.tiey
		sta g.OAM_Y, y
		pla
		tax
		lda x
		sta g.OAM_X, y
		iny
		iny
		iny
		iny
		inx
		lda x
		clc
		adc #8
		sta x
		cpx #4
		bne .loop
	sty oamInd
	rts

var [1] crownframe
SD_crown:
	const CROWN_FIRST_TILE $5a | 1
	const CROWN_X 128 - 12
	lda g.counter
	and #%11
	bne .frameincend
		lda crownframe
		clc
		adc #1
		sta crownframe
		cmp #3
		bcc .frameincend
		lda #0
		sta crownframe
	.frameincend:

	ldy oamInd
	lda #1
	sta g.OAM_ATTR, y
	sta g.OAM_ATTR+4, y
	sta g.OAM_ATTR+8, y
	lda ctrl.crowny
	sta g.OAM_Y, y
	sta g.OAM_Y+4, y
	sta g.OAM_Y+8, y
	; tile = (crownframe * 6) + CROWN_FIRST_TILE
		; crownframe * 6
			var [1] frame
			lda crownframe
			asl a
			asl a
			sta frame
			lda crownframe
			asl a
			clc
			adc frame
		; + CROWN_FIRST_TILE
			adc #CROWN_FIRST_TILE
		sta g.OAM_TILE, y
		adc #2
		sta g.OAM_TILE+4, y
		adc #2
		sta g.OAM_TILE+8, y
	; x
	lda #CROWN_X
	sta g.OAM_X, y
	lda #CROWN_X+8
	sta g.OAM_X+4, y
	lda #CROWN_X+16
	sta g.OAM_X+8, y
	tya
	clc
	adc #12
	sta oamInd
	rts

effecttiles:
	.db $b6|1, $b8|1, $ba|1 ; air tuft
SD_effects:
	ldx #0
	lda fx.EF_DATA
	beq .next
	jsr .draw
	.next:
	ldx #fx.EF_RAM_ALLOC
	lda fx.EF_DATA + fx.EF_RAM_ALLOC
	beq .end
	bne .draw ; jsr, rts
	.end: rts
	.draw:
		ldy oamInd
		lda fx.EF_X, x
		sta g.OAM_X, y
		lda fx.EF_Y, x
		sta g.OAM_Y, y
		lda fx.EF_DATA, x
		and #H_FLIP
		ora #2
		sta g.OAM_ATTR, y
		lda fx.EF_DATA, x
		and #%1111
		tax
		lda effecttiles, x
		sta g.OAM_TILE, y
		iny
		iny
		iny
		iny
		sty oamInd
		; TODO make versatile for more ef types
		rts

cloudtiles:
	.db $9c|1, $9e|1, $ac|1, $ae|1, $58|1, $9a
var [1] cloudx
SD_cloud:
	const CLOUD_Y 32
	var [1] x
	var [1] y
	lda #CLOUD_Y
	sta y
	lda cloudx
	sta x
	ldx #0
	ldy oamInd
	beq .end ; OAM is full get outta here pickel
	.loop:
		lda cloudtiles, x
		sta g.OAM_TILE, y
		lda y
		sta g.OAM_Y, y
		txa
		asl a
		asl a
		asl a
		clc
		adc x
		sta g.OAM_X, y
		lda #2 | %00100000
		sta g.OAM_ATTR, y
		; next
		iny
		iny
		iny
		iny
		beq .end ; OAM is full
		inx
		cpx #6
		bne .loop
	lda y
	cmp #CLOUD_Y
	bne >
		clc
		adc #16
		sta y
		lda x
		clc
		adc #98
		sta x
		ldx #0
		beq .loop
	>
	.end:
	sty oamInd
	rts