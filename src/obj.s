class obj

const MOVE_CTR_AMT 64

const OBJ_RAM_ALLOC	5
const X			objs
const Y			objs + 1
const NUMSEGS	objs + 2
const STOREY	objs + 3
const TYPE		objs + 4

idset TYPES {
	NORMAL
	DOWNRIGHT
	DOWNLEFT
	UPRIGHT
	UPLEFT
	DOWN
	UP
	RIGHT
	LEFT
	SPDDOWN
	SPDUP
	SHOCK
	FLIP ; must come right after shock
	BOUNCE
	CRUMBLE0
	CRUMBLE1
	CRUMBLE2
	CRUMBLE3
	CRUMBLE4
	CRUMBLE5
	CRUMBLE6
	SPIKE_DR
	SPIKE_R
	SPIKE_UR
	SPIKE_UL
	SPIKE_D
	THORN
	THORN_TOP
	THORN_L
	THORN_R
	THORN_R_R
	THORN_R_L
	THORN_L_DR
	THORN_R_DR
	THORN_L_UR
	THORN_R_UR
	THORN_L_FLIP ; only flip thorns after this
	THORN_R_FLIP
}

update_vectors:
	.dw nix ; NORMAL
	.dw MvmtDownRight ; DOWNRIGHT
	.dw MvmtDownLeft ; DOWNLEFT
	.dw MvmtUpRight ; UPRIGHT
	.dw MvmtUpLeft ; UPLEFT
	.dw MvmtDown ; DOWN
	.dw MvmtUp ; UP
	.dw MvmtRight ; RIGHT
	.dw MvmtLeft ; LEFT
	.dw nix ; SPDDOWN
	.dw nix ; SPDUP
	.dw nix ; SHOCK
	.dw nix ; FLIP ; must come right after shock
	.dw nix ; BOUNCE
	.dw nix ; CRUMBLE0
	.dw UpdateCrumbly ; CRUMBLE1
	.dw UpdateCrumbly ; CRUMBLE2
	.dw UpdateCrumbly ; CRUMBLE3
	.dw UpdateCrumbly ; CRUMBLE4
	.dw UpdateCrumbly ; CRUMBLE5
	.dw UpdateCrumbly ; CRUMBLE6
	.dw MvmtDownRight ; SPIKE_DR
	.dw MvmtRight ; SPIKE_R
	.dw MvmtUpRight ; SPIKE_UR
	.dw MvmtUpLeft ; SPIKE_UL
	.dw MvmtDown ; SPIKE_D
	.dw nix; THORN
	.dw nix ; THORN_TOP
	.dw nix ; THORN_L
	.dw nix ; THORN_R
	.dw MvmtRight ; THORN_R_R
	.dw MvmtLeft ; THORN_R_L
	.dw MvmtDownRight ; THORN_L_DR
	.dw MvmtDownRight ; THORN_R_DR
	.dw MvmtUpRight ; THORN_L_UR
	.dw MvmtUpRight ; THORN_R_UR
	.dw FlipThorn ; THORN_L_FLIP ; only flip thorns after this
	.dw FlipThorn ; THORN_R_FLIP

const NUM_OBJS 24
var [120] objs ; 24 total spots for objects; 12 per loaded half
var [1] movctr
var [1] movmode ; back forth movement

Init:
	lda #TIMER_WALL_CTR_AMT
	sta timerWallCtrAmt
	sta timerWallCtr
	lda #MOVE_CTR_AMT
	sta movctr
	lda g.boolParty
	ora #g.BOOLS_LHALFFREE
	sta g.boolParty
	lda #0
	sta movmode
	sta backForthSpeed
	sta backForthMvmt
	sta backForthOffset
	sta timerWallMode
	sta crumbleCtr

	rts

const BACK_FORTH_MAX 6
var [1] backForthSpeed
var [1] backForthMvmt
var [1] backForthOffset

; timer walls (shock & flip)
const TIMER_WALL_CTR_AMT 32
var [1] timerWallCtrAmt
var [1] timerWallCtr
var [1] timerWallMode

var [1] crumbleCtr

Update:
	dec movctr
	bne >
		lda #MOVE_CTR_AMT
		sta movctr
		lda movmode
		clc
		adc #1
		and #%11
		sta movmode
	>

	inc crumbleCtr
	
	dec timerWallCtr
	bne >
		lda timerWallCtrAmt
		sta timerWallCtr
		lda timerWallMode
		clc
		adc #1
		cmp #5
		bcc .timerst
			lda #0
		.timerst:
		sta timerWallMode
	>

	lda g.counter
	and #11
	bne .stopend

	; speed up or slow down
	lda movmode
	beq .spdup
	cmp #3
	beq .spdup
	.spddn:
		dec backForthSpeed
		jmp .spdend
	.spdup:
		inc backForthSpeed
	.spdend:
	; speed guards
	ldx backForthSpeed
	ldy #0
	lda movmode
	beq .stop0
	cmp #1
	beq .stop1
	cmp #2
	beq .stop2
	;stop3
		txa
		bmi .stopend
		sty backForthSpeed
		jmp .stopend
	.stop0:
		cpx #BACK_FORTH_MAX
		bcc .stopend
		lda #BACK_FORTH_MAX
		sta backForthSpeed
		bne .stopend ; jmp
	.stop1:
		txa
		bpl .stopend
		sty backForthSpeed
		jmp .stopend
	.stop2:
		cpx #-BACK_FORTH_MAX
		bcs .stopend
		lda #-BACK_FORTH_MAX
		sta backForthSpeed
	.stopend:
	lda backForthSpeed
	jsr comm.SpeedToMvmt
	sta backForthMvmt

	clc
	adc backForthOffset
	sta backForthOffset

	var [1] oldX
	var [1] oldY

	ldx #0
	.loop:
		lda STOREY, x
		bne >
			jmp .next
		>

		lda X, x
		sta oldX
		lda Y, x
		sta oldY

		; update wall movements
		txa
		pha
		lda TYPE, x ; type
		asl a
		tax
		lda update_vectors, x
		sta UpdateJump.addr
		lda update_vectors+1, x
		sta UpdateJump.addr+1
		pla
		tax
		jsr UpdateJump

		; move monkey
		lda X, x
		cmp oldX
		bne >
			lda Y, x
			cmp oldY
			beq .next
		>
		txa
		tay
		ldx #1
		.movemonkeyloop:
			lda monkey.bools, x
			and #monkey.BOOLS_DEAD
			bne .nextm
				; is monkey even on this wall lmao
				var [1] wi
				lda monkey.wallInd, x
				sta wi
				cpy wi
				bne .nextm
			lda monkey.bools, x
			and #monkey.BOOLS_ONWALL
			beq .nextm
				; x
					lda X, y
					sec
					sbc oldX
					pha
					lda monkey.targXPos, x
					cmp #$ff
					beq >
						pla
						pha
						clc
						adc monkey.targXPos, x
						sta monkey.targXPos, x
					>
					pla
					clc
					adc monkey.x, x
					sta monkey.x, x
				; y
					lda Y, y
					sec
					sbc oldY
					pha
					clc
					adc monkey.targYPos, x
					sta monkey.targYPos, x
					pla
					clc
					adc monkey.y, x
					sta monkey.y, x
			.nextm:
			lda g.boolParty
			and #g.BOOLS_MULTIPLAYER
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
		adc #OBJ_RAM_ALLOC
		tax
		cpx #NUM_OBJS * OBJ_RAM_ALLOC
		bcs .end
		jmp .loop
	.end: rts

UpdateJump:
	var [2] addr
	jmp [addr]
nix:
	rts

MvmtUp:
	lda backForthMvmt
	bmi .mi
	;pl
		lda Y, x
		sec
		sbc backForthMvmt
		sta Y, x
		bcs .end
		inc STOREY, x
		rts
	.mi:
		lda Y, x
		sec
		sbc backForthMvmt
		sta Y, x
		bcc .end
		dec STOREY, x
	.end: rts

MvmtDown:
	lda backForthMvmt
	bmi .mi
	;pl
		lda Y, x
		clc
		adc backForthMvmt
		sta Y, x
		bcc .end
		dec STOREY, x
		rts
	.mi:
		lda Y, x
		clc
		adc backForthMvmt
		sta Y, x
		bcs .end
		inc STOREY, x
	.end: rts

MvmtDownRight:
	lda backForthMvmt
	bmi .mi
	;pl:
		lda X, x
		clc
		adc backForthMvmt
		sta X, x
		lda Y, x
		clc
		adc backForthMvmt
		sta Y, x
		bcc .end
		dec STOREY, x
		rts
	.mi:
		lda X, x
		clc
		adc backForthMvmt
		sta X, x
		lda Y, x
		clc
		adc backForthMvmt
		sta Y, x
		bcs .end
		inc STOREY, x
	.end: rts

MvmtUpRight:
	lda backForthMvmt
	bmi .mi
	;pl:
		lda X, x
		clc
		adc backForthMvmt
		sta X, x
		lda Y, x
		sec
		sbc backForthMvmt
		sta Y, x
		bcs .end
		inc STOREY, x
		rts
	.mi:
		lda X, x
		clc
		adc backForthMvmt
		sta X, x
		lda Y, x
		sec
		sbc backForthMvmt
		sta Y, x
		bcc .end
		dec STOREY, x
	.end: rts

MvmtUpLeft:
	lda backForthMvmt
	bmi .mi
	;pl:
		lda X, x
		sec
		sbc backForthMvmt
		sta X, x
		lda Y, x
		sec
		sbc backForthMvmt
		sta Y, x
		bcs .end
		inc STOREY, x
		rts
	.mi:
		lda X, x
		sec
		sbc backForthMvmt
		sta X, x
		lda Y, x
		sec
		sbc backForthMvmt
		sta Y, x
		bcc .end
		dec STOREY, x
	.end: rts

MvmtDownLeft:
	lda backForthMvmt
	bmi .mi
	;pl:
		lda X, x
		sec
		sbc backForthMvmt
		sta X, x
		lda Y, x
		clc
		adc backForthMvmt
		sta Y, x
		bcc .end
		dec STOREY, x
		rts
	.mi:
		lda X, x
		sec
		sbc backForthMvmt
		sta X, x
		lda Y, x
		clc
		adc backForthMvmt
		sta Y, x
		bcs .end
		inc STOREY, x
	.end: rts

MvmtRight:
	lda X, x
	clc
	adc backForthMvmt
	sta X, x
	rts

MvmtLeft:
	lda X, x
	sec
	sbc backForthMvmt
	sta X, x
	rts

UpdateCrumbly:
	lda crumbleCtr
	and #%111
	bne .end
	lda TYPE, x
	clc
	adc #1
	cmp #TYPES.CRUMBLE3
	beq .end
	sta TYPE, x
	cmp #TYPES.CRUMBLE6+1
	bcc >
		lda #0
		sta STOREY, x ; destroy wall
	>
	.end: rts

FlipThorn:
	lda timerWallMode
	cmp #4
	bne .end
	lda timerWallCtrAmt
	sec
	sbc #4
	cmp timerWallCtr
	bne .end
	; swap sides
	lda TYPE, x
	cmp #TYPES.THORN_L_FLIP
	beq .toR
	;toL:
		dec TYPE, x
		lda X, x
		sec
		sbc #16
		sta X, x
		.end: rts
	.toR:
		inc TYPE, x
		lda X, x
		clc
		adc #16
		sta X, x
		rts