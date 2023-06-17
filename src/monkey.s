class monkey ;lol

const BOOLS_FACING	%10000000
const BOOLS_ONWALL	%00000001
const BOOLS_BFLIP	%00000010
const BOOLS_BOUNCED	%00000100
const BOOLS_DEAD	%00001000
const BOOLS_OFFSCR	%00010000
const BOOLS_VICTOR	%00100000
const UHELDCTR_AMT 20
const JUMP_SPD 12
const WIDTH 24
const HEIGHT 32
const INVINCIBILITY_TIME 8 ; frames (after jumping)

idset STATE {
	IDLE
	JUMP
	BFLIP
}

; 3 bytes for each var
	; spot 0: working var space; all monkey update logic works on this slot.
	; spot 1: monkey 1's vars
	; spot 2: monkey 2's vars
	; (each frame, both monkeys' vars are copied into spot 0 and logic is done on them, then copied back into their respective slots afterwards. I do this to avoid having to keep track of x, or to keep setting x everywhere, throughout all of those update logic functions.)
var [3] bools
var [3] x
var [3] y
var [3] xspd
var [3] yspd
var [3] state
var [3] uheldctr
var [3] wallInd
var [3] targXPos
var [3] targYPos
var [3] invincibilityctr

startx:
	.db 0, 60, 106
starty:
	.db 0, 120, 120
initbools:
	.db 0, BOOLS_ONWALL, BOOLS_ONWALL | BOOLS_FACING
initwallinds:
	.db 0, obj.OBJ_RAM_ALLOC, 0
Init:
	lda g.boolParty
	and #g.BOOLS_MONKEYINFRONT ^ $ff
	sta g.boolParty
	ldx #2
	.loop:
		lda #0
		sta xspd, x
		sta yspd, x
		sta invincibilityctr, x
		sta uheldctr, x
		lda startx, x
		sta x, x
		lda starty, x
		sta y, x
		lda initbools, x
		sta bools, x
		lda #STATE.IDLE
		sta state, x
		lda #1
		sta yspd, x
		lda #$ff
		sta targXPos, x
		lda initwallinds, x
		sta wallInd, x
		dex
		bne .loop
	rts

UpdateBothMonkeys:
	ldx #1
	.loop:
		; copy all of this monkey's vars to working var space
			lda input.buttonsDown, x
			sta input.buttonsDown
			lda input.buttonsPressed, x
			sta input.buttonsPressed
			lda bools, x
			sta bools
			lda x, x
			sta x
			lda y, x
			sta y
			lda xspd, x
			sta xspd
			lda yspd, x
			sta yspd
			lda state, x
			sta state
			lda uheldctr, x
			sta uheldctr
			lda wallInd, x
			sta wallInd
			lda targXPos, x
			sta targXPos
			lda targYPos, x
			sta targYPos
			lda invincibilityctr, x
			sta invincibilityctr
		txa
		pha
		jsr Update
		pla
		tax
		; copy all working var space vars into monkey's
			lda invincibilityctr
			sta invincibilityctr, x
			lda targXPos
			sta targXPos, x
			lda targYPos
			sta targYPos, x
			lda bools
			sta bools, x
			lda x
			sta x, x
			lda y
			sta y, x
			lda xspd
			sta xspd, x
			lda yspd
			sta yspd, x
			lda state
			sta state, x
			lda uheldctr
			sta uheldctr, x
			lda wallInd
			sta wallInd, x
		lda g.boolParty
		and #g.BOOLS_MULTIPLAYER
		beq .end ; only one boi
		lda g.boolParty
		eor #g.BOOLS_UPDATEM2
		sta g.boolParty
		inx
		cpx #3
		bcc .loop
	.end: rts

Update:
	lda invincibilityctr
	beq >
		dec invincibilityctr
	>

	; move towards target position
	lda targXPos
	cmp #$ff
	beq .targend
		cmp x
		bne .followtarg
			lda targYPos
			cmp y
			beq .targoff
		.followtarg:
		jsr FollowTarg
		jmp .jump
		.targoff:
		lda #$ff
		sta targXPos
		; draw monkey behind again
		lda g.boolParty
		and #g.BOOLS_MONKEYINFRONT ^ $ff
		sta g.boolParty
	.targend:

	lda bools
	and #BOOLS_ONWALL
	bne .onwall
	; in air
		lda uheldctr
		beq .nouheld
			dec uheldctr
			bne .airstuffend ; jmp (sort of)
		.nouheld:
			inc yspd ; gravity
			jmp .airstuffend
	.onwall:
		jsr CheckFlip
		jsr CheckStillOnWall
	.airstuffend:
	jsr CollideWithObjs
	jsr CollideWithEdges
	
	.jump:
	jsr Jump

	; move x
		lda xspd
		jsr comm.SpeedToMvmt
		bmi .l
		;r:
			clc
			adc x
			sta x
			bcc .y
			lda bools
			eor #BOOLS_OFFSCR
			sta bools
			jmp .y
		.l:
			clc
			adc x
			sta x
			bcs .y
			lda bools
			eor #BOOLS_OFFSCR
			sta bools
	.y:
	; move y
		lda yspd
		jsr comm.SpeedToMvmt
		pha
		clc
		adc y
		sta y
		pla
		clc
		adc targYPos
		sta targYPos
	.end: rts

Jump:
	; did player press A
	lda input.buttonsDown
	and #input.BTN_A
	beq .noa
		lda bools 
		and #BOOLS_BFLIP
		bne .end
		lda input.buttonsPressed
		and #input.BTN_A
		bne .end
			jsr PlayJumpSound
			jmp JumpAction ; jsr, rts
	.noa:
	lda bools
	and #BOOLS_BOUNCED
	bne .end
	lda #0
	sta uheldctr
	.end: rts

PlayJumpSound:
	var [1] whichmonkeyhahatimes4
	var [1] channel
	lda g.boolParty
	and #g.BOOLS_UPDATEM2
	pha
		; different channels
		bne .2
		;3:
			lda #FT_SFX_CH3
			jmp .xend
		.2:
			lda #FT_SFX_CH2
		.xend:
		sta channel
	pla
	lsr a
	lsr a
	sta whichmonkeyhahatimes4
	lda #4
	jsr comm.ModRandomNum
	clc
	adc #g.SOUNDS.MONKEY_CHIRP1
	adc whichmonkeyhahatimes4
	ldx channel
	jsr ft.FamiToneSfxPlay
	rts

JumpAction:
	; first, forego little animation and just snap to target pos
	lda targXPos
	cmp #$ff
	beq >
		sta x
		lda targYPos
		sta y
		lda #$ff
		sta targXPos
	>
	; the meat and potatoes:
		lda #-JUMP_SPD
		sta yspd
	lda #UHELDCTR_AMT
	sta uheldctr
	ldx wallInd
	lda obj.TYPE, x
	cmp #obj.TYPES.CRUMBLE0
	bcc .nocrumble
	cmp #obj.TYPES.CRUMBLE3
	bcs .nocrumble
		lda #1
		sta obj.crumbleCtr
		lda #obj.TYPES.CRUMBLE3
		sta obj.TYPE, x
		ldx #FT_SFX_CH1
		lda #g.SOUNDS.CRUMBLE
		jsr ft.FamiToneSfxPlay
	.nocrumble:
	; first jump or second (backflip)?
	lda xspd
	beq .onwall ; if fell from a wall above
	lda bools
	and #BOOLS_ONWALL
	bne .onwall
	;bflip:
		; xpsd = -xspd
			dec xspd
			lda xspd
			eor #$ff
			sta xspd
		lda #STATE.BFLIP
		sta state
		lda bools
		ora #BOOLS_BFLIP
		eor #BOOLS_FACING
		sta bools
		bne .rest ; jmp
	.onwall:
		lda #INVINCIBILITY_TIME
		sta invincibilityctr
		lda #STATE.JUMP
		sta state
		lda bools
		bmi .startl
		;startr:
			lda #JUMP_SPD
			sta xspd
			bne .rest ; jmp
		.startl:
			lda #-JUMP_SPD
			sta xspd
	.rest:
		; create little air tuft effect
		ldx wallInd
		lda obj.TYPE, x
		cmp #obj.TYPES.BOUNCE
		beq .tuftend
		lda bools
		and #BOOLS_OFFSCR
		bne .tuftend
		lda bools
		bmi .mi
		;pl:
			ldx x
			jmp .effrest
		.mi:
			lda x
			clc
			adc #WIDTH - 8
			bcs .tuftend
			tax
		.effrest:
		lda y
		clc
		adc #HEIGHT - 16
		tay
		lda bools
		and #BOOLS_FACING
		lsr a
		sta fx.CreateEffect.flip
		lda #fx.EF_TYPE_TUFT
		jsr fx.CreateEffect
		.tuftend:
	lda bools
	and #(BOOLS_ONWALL | BOOLS_BOUNCED) ^ $ff
	sta bools
	lda g.boolParty
	and #g.BOOLS_MONKEYINFRONT ^ $ff
	sta g.boolParty
	lda #$ff
	sta wallInd
	rts

CollideWithEdges:
	lda y
	cmp #240
	bcc >
		jmp FallToDeath
	>
	rts

; this is method is a monster
CollideWithObjs:
	var [1] objy
	var [1] objwidth
	var [1] objheight
	lda targXPos
	cmp #$ff
	beq >
		.getouttahere: rts
	>
	lda bools
	and #BOOLS_OFFSCR
	bne .getouttahere
	ldx #(obj.NUM_OBJS * obj.OBJ_RAM_ALLOC) - obj.OBJ_RAM_ALLOC
	ldy #obj.NUM_OBJS
	.loop:
		cpx wallInd
		bne >
			jmp .next ; wall we're already on
		>
		lda obj.STOREY, x
		bne >
			jmp .next ; offscreen downwards
		>
		lda obj.TYPE, x
		cmp #obj.TYPES.SPIKE_DR
		bcc .wall
		cmp #obj.TYPES.THORN_TOP
		beq .thorntop
		cmp #obj.TYPES.THORN
		beq .thorn
		cmp #obj.TYPES.THORN_L
		bcs .thornside
		;spike:
			lda #32
			sta objwidth
			sta objheight
			bne .dimsend ; jmp
		.thorntop:
			lda #24
			sta objwidth
			lda #16
			sta objheight
			bne .dimsend ; jmp
		.thorn:
			lda #24
			sta objwidth
			sta objheight
			bne .dimsend ; jmp
		.thornside:
			lda #8
			sta objwidth
			lda #32
			sta objheight
			bne .dimsend
		.wall:
			lda #8
			sta objwidth
			lda obj.NUMSEGS, x ; num middle segments
			asl a
			asl a
			asl a
			asl a ; x16 px high
			clc
			adc #26 ; top & bottom height
			sta objheight
		.dimsend:
		lda obj.Y, x
		sta objy
		; offscreen upwards?  Might reach into this NT
		lda obj.STOREY, x
		cmp #3
		bcc >
			jmp .next
		>
		cmp #2
		bcc >
			lda objy
			clc
			adc objheight
			bcc .next ; nope it's all up there
			; yes, it's reaching into this NT
			; pretend like it has a Y of 0
			;  and a total height = the remaining height
			sta objheight
			lda #0
			sta objy
		>
		; past its left edge
			lda x
			clc
			adc #WIDTH
			cmp obj.X, x
			bcc .next
		; past its right edge
			lda obj.X, x
			clc
			adc objwidth
			cmp x
			bcc .next
		; past its top edge
			lda y
			clc
			adc #20 ; not full height, looks weird
			cmp objy
			bcc .next
		; past its bottom edge
			lda objheight
			clc
			adc objy ; y
			bcs .coll
			cmp y
			bcc .next
		bcs .coll ; jmp
		.next:
		txa
		sec
		sbc #obj.OBJ_RAM_ALLOC
		tax
		dey
		beq .end0
		jmp .loop
	.coll:
	lda obj.TYPE, x
	; spike just die
	cmp #obj.TYPES.SPIKE_DR
	bcc >
		jmp Explode
	>
	; crumbly
	cmp #obj.TYPES.CRUMBLE0
	bcc .nocrumble
	cmp #obj.TYPES.CRUMBLE6+1
	bcs .nocrumble
		cmp #obj.TYPES.CRUMBLE3
		bcs .end0
		jsr Crumble
		jmp .shockdieend
	.nocrumble:
	; shock, die if is shocking
	cmp #obj.TYPES.SHOCK
	bne .shockdieend
		lda obj.timerWallMode
		cmp #4
		bne .shockdieend
		jmp Explode
	.shockdieend:
	; ignore bouncy if no xspd
	cmp #obj.TYPES.BOUNCE
	bne >
		lda xspd
		beq .end0
	>
	; at this point, we could still be on a wall so just quit
	lda bools
	and #BOOLS_ONWALL
	beq >
		.end0: rts
	>
	jsr AlignToWall
	lda xspd
	beq .nospd
	; bouncy
	lda obj.TYPE, x
	cmp #obj.TYPES.BOUNCE
	bne >
		stx wallInd
		lda y
		jsr fx.CreateBounce
		; undo that aligning stuff we just did
			lda targXPos
			sta x
			lda targYPos
			sta y
			lda #$ff
			sta targXPos
		jsr JumpAction
		lda #STATE.JUMP
		sta state
		lda bools
		and #BOOLS_BFLIP ^ $ff
		ora #BOOLS_BOUNCED
		eor #BOOLS_FACING
		sta bools
		; play sound
		ldx #FT_SFX_CH1
		lda #g.SOUNDS.BOUNCE
		jsr ft.FamiToneSfxPlay
		rts
	>
	; hit wall
	.nospd:
	stx wallInd
	lda bools
	ora #BOOLS_ONWALL
	and #BOOLS_BFLIP ^ $ff
	sta bools
	lda #STATE.IDLE
	sta state
	lda #0
	sta xspd
	lda obj.TYPE, x ; type
	beq .yspd1
	cmp #obj.TYPES.SHOCK
	beq .yspd1
	cmp #obj.TYPES.SPDDOWN
	beq .yspd6
	cmp #obj.TYPES.SPDUP
	beq .yspdn6
	bne .yspd0
	.yspd1:
		lda #1
		bne .yspdst ; jmp
	.yspdn6:
		lda #-6
		bne .yspdst ; jmp
	.yspd6:
		lda #6
		bne .yspdst ; jmp
	.yspd0:
		lda #0
	.yspdst:
	sta yspd
	.end: rts

CheckStillOnWall:
	var [1] objheight
	var [1] objy
	ldx wallInd
	lda obj.TYPE, x
	cmp #obj.TYPES.CRUMBLE3
	beq .fall
	; NOTE: next ~15 lines of code is duplicate of code in CollideWithObjs
	; check
		lda obj.Y, x
		sta objy
		lda obj.NUMSEGS, x ; num middle segments
		asl a
		asl a
		asl a
		asl a ; x16 px high
		clc
		adc #26 ; top & bottom height minus a little bit
		sta objheight
	; storey?
	lda obj.STOREY, x
	cmp #1
	beq >
		; pretend like it has a y of 0 and height of (leftover)
		lda objy
		clc
		adc objheight
		sta objheight
		lda #0
		sta objy
	>
	lda objheight
	clc
	adc objy
	bcs .stillon ; off bottom of screen
	cmp y
	bcs .stillon ; we're good
	.fall:
	lda bools
	and #BOOLS_ONWALL ^ $ff
	sta bools
	lda #STATE.JUMP
	sta state
	rts
	.stillon:
	lda obj.TYPE, x
	cmp #obj.TYPES.SHOCK
	bne >
		lda obj.timerWallMode
		cmp #4
		bne .end
		jsr Explode
	>
	cmp #obj.TYPES.FLIP
	bne .end
		jsr Flip
	.end: rts
	; italy...

Flip:
	lda obj.timerWallMode
	cmp #4
	bne .end
	lda obj.timerWallCtr
	cmp obj.timerWallCtrAmt
	bne .end
	beq FlipAction ; jsr, rts
	.end: rts

FlipAction:
	; banana
	ldx wallInd
	lda y
	sta targYPos
	lda bools
	eor #%10000000
	sta bools
	bmi .l
	;r:
		lda obj.X, x
		clc
		adc #8
		sta targXPos
		; headstart
		lda x
		clc
		adc #8
		sta x
		; draw monkey in front of wall
		lda g.boolParty
		ora #g.BOOLS_MONKEYINFRONT
		sta g.boolParty
		.end: rts
	.l:
		lda obj.X, x
		sec
		sbc #WIDTH
		sta targXPos
		; headstart
		lda x
		sec
		sbc #8
		sta x
		rts

Explode:
	lda invincibilityctr
	bne .end
	lda #0
	sta disp.deathCtr
	lda bools
	ora #BOOLS_DEAD
	sta bools
	; play sound
		ldx #FT_SFX_CH0
		lda #g.SOUNDS.DIE
		jsr ft.FamiToneSfxPlay
	lda x
	sta disp.explX
	lda y
	sta disp.explY
	.end: rts

FallToDeath:
	lda #$ff
	sta disp.explX ; don't draw explosion PLEASE
	lda #0
	sta disp.deathCtr
	lda bools
	ora #BOOLS_DEAD
	sta bools
	; play sound
		ldx #FT_SFX_CH0
		lda #g.SOUNDS.FALL
		jmp ft.FamiToneSfxPlay

; params:
;	x - obj index of crumbly wall
Crumble:
	lda #1
	sta obj.crumbleCtr
	lda obj.TYPE, x
	cmp #obj.TYPES.CRUMBLE0
	bne >
		inc obj.TYPE, x
	>
	rts

; params:
;	x - index to obj (wall)
AlignToWall:
	lda obj.TYPE, x
	cmp #obj.TYPES.BOUNCE
	beq >
		txa
		pha
		ldx #FT_SFX_CH0
		lda #g.SOUNDS.LAND
		jsr ft.FamiToneSfxPlay
		pla
		tax
	>
	; y
		lda obj.STOREY, x
		cmp #2
		bcs .noyneededbaby
		lda obj.Y, x
		sec
		sbc #10
		bcc .noyneededbaby
		cmp y
		bcc .noyneededbaby
		; my Y needs to be.... "corrected" :(
			sta targYPos
			jsr CheckThornsOnWall
			tya ; get flags based on y
			beq >
				bmi .collr
				bne .colll
			>
			lda xspd
			beq .x
			lda bools
			bmi .colll
			bpl .collr
		.noyneededbaby:
		lda y
		sta targYPos
	.x:
	lda x
	cmp obj.X, x
	bcs .colll
	.collr:
		lda obj.X, x
		sec
		sbc #WIDTH
		sta targXPos
		lda bools
		ora #BOOLS_FACING
		sta bools
		rts
	.colll:
		lda obj.X, x
		clc
		adc #8
		sta targXPos
		lda bools
		and #BOOLS_FACING ^ $ff
		sta bools
	.end: rts

; params:
;	x - index to obj
; returns:
;	y - 0 = no thorn
;		1 = thorn on l
;		$ff = thorn on r
CheckThornsOnWall:
	ldy #0
	lda obj.STOREY - obj.OBJ_RAM_ALLOC, x
	cmp #1
	bne .end
	; check next obj type
	lda obj.TYPE - obj.OBJ_RAM_ALLOC, x
	cmp #obj.TYPES.THORN
	bcc .end
	; is a thorn, check pos
	lda obj.Y, x
	clc
	adc #8
	cmp obj.Y - obj.OBJ_RAM_ALLOC, x
	bcc .end
	lda obj.Y - obj.OBJ_RAM_ALLOC, x
	cmp obj.Y, x
	bcc .end
	; left side?
	lda obj.X, x
	sec
	sbc #8
	cmp obj.X - obj.OBJ_RAM_ALLOC, x
	beq .l
	; right side?
	lda obj.X, x
	clc
	adc #8
	cmp obj.X - obj.OBJ_RAM_ALLOC, x
	beq .r
	; same Y but far away, not on this wall
	rts
	.l:
		iny
		.end: rts
	.r:
		dey
		rts

FollowTarg:
	; x
		lda targXPos
		sec
		sbc x
		; asr
		; 	pha
		; 	asl a
		; 	pla
		; 	ror a
		; beq .xrola
		; asr
			pha
			asl a
			pla
			ror a
		bne .addx
		.xrola:
		rol a
		.addx:
		clc
		adc x
		sta x
	; y
		lda targYPos
		sec
		sbc y
		; asr
		; 	pha
		; 	asl a
		; 	pla
		; 	ror a
		; beq .yrola
		; asr
			pha
			asl a
			pla
			ror a
		bne .addy
		.yrola:
		rol a
		.addy:
		clc
		adc y
		sta y
	rts

CheckFlip:
	; did player press B
	lda input.buttonsDown
	and #input.BTN_B
	beq .end
	lda input.buttonsPressed
	and #input.BTN_B
	bne .end
	jsr FlipAction
	.end: rts

; make victor monkey move to center of screen
UpdateVictor:
	const XTARG (256 / 2) - (WIDTH / 2)
	const YTARG (240 / 2) - (HEIGHT / 2)

	ldx ctrl.victorind
	; x
	lda x, x
	sta comm.SmoothToTarg.curr
	lda #XTARG
	jsr comm.SmoothToTarg
	sta x, x
	.y:
	lda y, x
	sta comm.SmoothToTarg.curr
	lda #YTARG
	jsr comm.SmoothToTarg
	sta y, x

	.end: rts