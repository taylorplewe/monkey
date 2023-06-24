class ctrl

var [1] startctr
var [1] titlescroll
var [1] victorind
var [1] tiey ; for displaying the word "TIE!"
var [1] chasespeed ; screen starts chasing you on higher scores!  Haha,
var [2] hexscore ; just a hex repr. of display score; easier to do calculations on

InitTitle:
	jsr disp.InitTitle
	lda #$ff
	sta startctr
	lda #3
	sta m2p
	rts
InitGame:
	lda g.boolParty
	and #g.BOOLS_TITLE ^ $ff
	sta g.boolParty
	lda #0
	sta g.ppuctrl
	sta g.ppumask
	sta $2000
	sta $2001
	sta victorind
	sta tiey
	sta crowny
	sta chasespeed
	sta hexscore
	sta hexscore+1
	jsr monkey.Init
	jsr disp.InitGame
	jsr obj.Init
	jsr gen.Init
	jsr disp.Update
	; reenable; big sprites
	lda #%10100000
	sta $2000
	sta g.ppuctrl
	lda #%00011110
	sta $2001
	sta g.ppumask
	rts

UpdateTitle:
	lda g.counter
	and #%11
	bne >
		inc titlescroll
	>

	lda startctr
	cmp #$ff
	beq >
		dec startctr
		bne TitleSpr0
		jsr disp.FadeToWhite
		jsr InitGame
		jsr disp.FadeToBase
		.getouttahere:
			lda $2002
			bpl .getouttahere
			ldx #$ff
			txs
			jmp g.forever
	>

	; up/down
	jsr thomas_c_farraday
	lda input.buttonsPressed+1
	and #input.BTN_U | input.BTN_D | input.BTN_SELECT
	beq .select
		lda g.boolParty
		eor #g.BOOLS_MULTIPLAYER
		sta g.boolParty
		ldx #FT_SFX_CH0
		lda #g.SOUNDS.CHANGE_SELECT
		jsr ft.FamiToneSfxPlay
		jmp TitleSpr0

	.select: ; A or start
	lda input.buttonsDown+1
	and #input.BTN_A | input.BTN_START
	beq TitleSpr0
		; bne InitGame
		lda #64
		sta startctr
		ldx #FT_SFX_CH0
		lda #g.SOUNDS.SELECT
		jsr ft.FamiToneSfxPlay
		jmp TitleSpr0
	.end: rts

TitleSpr0:
	lda g.OAM_TILE
	cmp #disp.SPR0_TILE
	bne .end
	.spr0wait1: ; first wait til it gets cleared
	lda $2002
	asl a
	bmi .spr0wait1
	.spr0wait2:
	lda $2002
	asl a
	bpl .spr0wait2
	; set scroll
	lda titlescroll
	sta $2005
	lda #0
	sta $2005
	lda g.ppuctrl
	sta $2000
	; now wait again HAHA
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
	; then set scroll
	stx $2005
	stx $2005
	lda g.ppuctrl
	sta $2000
	.end: rts

UpdateGame:
	jsr fx.UpdateEffects
	jsr fx.UpdateBounces
	jsr Peek
	; possible update tie word
	lda tiey
	beq >
		jsr UpdateTieWord
	>

	lda disp.deathCtr
	bmi .end
	cmp #64
	bcc .end
	lda input.buttonsPressed+1
	beq .p2
		bne ResetGame ; jsr, rts
	.p2:
	lda g.boolParty
	and #g.BOOLS_MULTIPLAYER
	beq .end
	lda input.buttonsPressed+2
	beq .end
		bne ResetGame ; jsr, rts
	.end: rts

ResetGame:
	; fade out, restt everything, fade back in
	jsr disp.FadeToWhite
	jsr InitGame
	jmp disp.FadeToBase

CrownWinner:
	lda g.boolParty
	and #g.BOOLS_MULTIPLAYER
	beq .end
	; find out who the winner is
	ldx #1
	lda monkey.bools + 1
	and #monkey.BOOLS_DEAD
	beq >
		lda monkey.bools + 2
		and #monkey.BOOLS_DEAD
		bne .tie
		inx
	>
	stx victorind
	lda #monkey.STATE.JUMP
	sta monkey.state, x
	lda monkey.y, x
	cmp #200
	bcc >
		lda #200
		sta monkey.y, x
	>
	lda monkey.bools, x
	and #monkey.BOOLS_OFFSCR
	beq .xcorrectend
		lda monkey.bools, x
		and #monkey.BOOLS_OFFSCR ^ $ff
		sta monkey.bools, x
		lda monkey.x, x
		bmi .lside
		;rside:
			lda #$f0
			sta monkey.x, x
			bne .xcorrectend ; jmp
		.lside:
			lda #0
			sta monkey.x, x
	.xcorrectend:
	; buffer crown palette
	lda #1 ; pl but not eq
	ldx #0
	jsr disp.BuffPals
	; play sound
		ldx #FT_SFX_CH1
		lda #g.SOUNDS.VICTORY
		jsr ft.FamiToneSfxPlay
	.end: rts
	.tie:
	lda #$ff
	sta tiey
	rts

UpdateTieWord:
	const TIE_Y_TARG (240 / 2) - 4
	lda tiey
	sta comm.SmoothToTarg.curr
	lda #TIE_Y_TARG
	jsr comm.SmoothToTarg
	sta tiey
	rts

var [1] crowny
UpdateCrown:
	const CROWN_Y_TARG 120 - (16 + 16 + 3)
	lda crowny
	sta comm.SmoothToTarg.curr
	lda #CROWN_Y_TARG
	jsr comm.SmoothToTarg
	sta crowny
	rts
	
IncreaseHexScore:
	const CHASE_LEVEL_1 80
	const CHASE_LEVEL_2 157
	const CHASE_LEVEL_4 255
	const TIMER_WALL_CTR_DEC_LVL 167 ; level at which timer walls speed up
	inc hexscore
	bne >
		inc hexscore+1
	>
	lda hexscore+1
	bne .end
	jsr disp.UpdateSkyColor
	lda hexscore
	cmp #CHASE_LEVEL_1
	beq .chase1
	cmp #CHASE_LEVEL_2
	beq .chase2
	cmp #TIMER_WALL_CTR_DEC_LVL
	beq .timerspdup
	rts
	.chase1:
		lda #1
		sta chasespeed
		.end: rts
	.chase2:
		lda #2
		sta chasespeed
		rts
	.timerspdup:
		lda #20
		sta obj.timerWallCtrAmt
		rts

Pause:
	; p1
	lda input.buttonsPressed+1
	and #input.BTN_START
	bne .act
	.p2:
	lda g.boolParty
	and #g.BOOLS_MULTIPLAYER
	beq .end
	lda input.buttonsPressed+2
	and #input.BTN_START
	beq .end
		.act:
		lda g.paused
		beq .pause
		;unpause
			lda #0
			sta g.paused
			lda g.ppumask
			and #%00011111
			sta g.ppumask
			rts
		.pause:
			lda #1
			sta g.paused
			lda g.ppumask
			ora #%11100000
			sta g.ppumask
	.end: rts

const PEEKING_MONKEY_Y_MAX $ba
Peek:
	lda disp.deathCtr
	bpl .end
	lda victorind
	bne .end
	lda g.boolParty
	and #g.BOOLS_MULTIPLAYER
	bne .mult
	;sing
		lda input.buttonsDown+1
		and #input.BTN_U
		beq .end
		lda monkey.y+1
		cmp #PEEKING_MONKEY_Y_MAX
		bcs .end
		bcc .act ; jmp
	.mult:
		lda #input.BTN_U
		and input.buttonsDown+1
		and input.buttonsDown+2
		beq .end
		lda #PEEKING_MONKEY_Y_MAX
		cmp monkey.y+1
		bcc .end
		cmp monkey.y+2
		bcc .end
	.act:
	lda #1
	jsr disp.ScrollUp

	.end: rts

; top secret, don't look
_tcf:
	.dw $0202, $0101, $0102, $0102
_tcfe:
const TCF_CTR_AMT 128
const TCF_L _tcfe - _tcf
tcf = $01a0
tcf_ctr = $01a1
const m2p $01a3
thomas_c_farraday:
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
	lda input.buttonsPressed+2
	beq .end
	cmp _tcf, x
	bne .nn
		lda tcf_ctr
		bne >
			lda #TCF_CTR_AMT
			sta tcf_ctr
		>
		inc tcf
		lda tcf
		cmp #TCF_L
		bne .end
			lda #$ff
			sta tcf
			lda #2
			sta m2p
			jsr .f
			jsr disp.BuffAllWhite
			jsr .f
			ldx #1
			lda #0
			jsr disp.BuffPals
			jsr .f
			jsr .f
			jsr disp.BuffAllWhite
			jsr .f
			ldx #1
			lda #0
			jsr disp.BuffPals
			jsr .f
		.end: rts 
	.nn:
		lda #0
		sta tcf
		sta tcf_ctr

	rts
	.f:
		ldx #2
		jsr comm.WaitNumFrames
		jmp disp.ClearPPUBuff