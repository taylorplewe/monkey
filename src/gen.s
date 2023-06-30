class gen

; current values
var [1] cy ; current Y
var [1] cstorey
var [1] spotsleft
var [1] nextlvl ; NT's to rise before generating more
var [1] objind
var [1] gensafe ; !0 = generate the safe scenario next (if x is too far to the right on last one)
const NUM_SLOTS obj.NUM_OBJS / 2
const OBJ_SCEN_ALLOC 4
_OBJ_SCEN_ALLOC = 4 ; NESASM3 doesn't always see my saturated cosnt's well

initscenario:
	.db 130, 236, 8, obj.TYPES.NORMAL, 0
	.db 52, 20, 10, obj.TYPES.NORMAL, 0
	.db 52, 106, 0, obj.TYPES.NORMAL, 0
	.db 130, 60, 1, obj.TYPES.NORMAL, 0
	.db 130, 98, 1, obj.TYPES.NORMAL, 0
Init:
	; clear objects
	ldx #obj.NUM_OBJS * obj.OBJ_RAM_ALLOC
	lda #0
	.clearloop:
		dex
		sta obj.objs, x
		cpx #0
		bne .clearloop
	sta nextlvl

	lda g.boolParty
	ora #g.BOOLS_LHALFFREE
	sta g.boolParty
	; init generator values
		lda #$ff
		sta cy
		lda #1
		sta cstorey
		lda #12
		sta spotsleft
	; create first objects
	ldx #0
	ldy #NUM_INIT_OBJS
	.loop:
		lda initscenario, x
		sta obj.X, x
		lda cy
		sec
		sbc initscenario+1, x
		sta obj.Y, x
		sta cy
		bcs >
			inc cstorey
			inc nextlvl
		>
		lda initscenario+2, x
		sta obj.NUMSEGS, x
		lda initscenario+3, x
		sta obj.TYPE, x
		lda cstorey
		sta obj.STOREY, x
		txa
		clc
		adc #obj.OBJ_RAM_ALLOC
		tax
		dec spotsleft
		dey
		bne .loop
	
	; generate rest of half-objs[]
	; lda #LOW(scenarios)
	; sta Generate.addr
	; lda #HIGH(scenarios)
	; sta Generate.addr+1
	stx objind
	jmp Generate

	rts
NUM_INIT_OBJS = (Init - initscenario) / 5

const HARD_LVL_1 50
const HARD_LVL_2 120
const HARD_LVL_3 200
const HARD_LVL_0_FRAC 10
const HARD_LVL_1_FRAC 52	; OUT OF 256
const HARD_LVL_2_FRAC 139
const HARD_LVL_3_FRAC 200

GenerateWholeHalf:
	lda #NUM_SLOTS
	sta spotsleft
	lda g.boolParty
	and #g.BOOLS_LHALFFREE
	bne .l
	;r:
		lda #NUM_SLOTS * obj.OBJ_RAM_ALLOC
		bne .lrend ; jmp
	.l:
		lda #0
	.lrend:
	sta objind
	; fall thru

Generate:
	var [2] addr
	var [1] mirrored

	lda gensafe
	beq >
		lda #LOW(scen.safescenario)
		sta addr
		lda #HIGH(scen.safescenario)
		sta addr+1
		lda #1
		sta CreateObjs.numobjs
		dec spotsleft
		jsr CreateObjs
		jmp .next
	>

	lda spotsleft
	cmp #9
	bcc >
		lda #8 ; even though there could be more empty spots, I only made scenarios for at most 8 walls at a time
	>
	jsr comm.ModRandomNum
	pha
	asl a
	tay
	pla
	clc
	adc #1
	sta CreateObjs.numobjs
	lda spotsleft
	sec
	sbc CreateObjs.numobjs
	sta spotsleft

	; which difficulty pool
	jsr comm.RandomNum
	tax
	lda ctrl.hexscore
	cmp #HARD_LVL_3
	bcs .lvl3
	cmp #HARD_LVL_2
	bcs .lvl2
	cmp #HARD_LVL_1
	bcs .lvl1
	bcc .lvl0
	.lvl3:
		cpx #HARD_LVL_3_FRAC
		bcc .hard
		bcs .easy
	.lvl2:
		cpx #HARD_LVL_2_FRAC
		bcc .hard
		bcs .easy
	.lvl1:
		cpx #HARD_LVL_1_FRAC
		bcc .hard
		bcs .easy
	.lvl0:
		cpx #HARD_LVL_0_FRAC
		bcs .easy
	.hard:
		lda scen.scenarios_hard, y
		sta addr
		lda scen.scenarios_hard+1, y
		sta addr+1
		jmp .difficultyend
	.easy:
		lda scen.scenarios_easy, y
		sta addr
		lda scen.scenarios_easy+1, y
		sta addr+1
	.difficultyend:
	ldy #0
	; num scenarios in this #obj group
		lda [addr], y
		jsr comm.ModRandomNum
		asl a
		clc
		adc #1
		tay
		lda [addr], y
		pha
		iny
		lda [addr], y
		sta addr+1
		pla
		sta addr

	; mirrored?
	jsr comm.RandomNum
	and #1
	sta mirrored

	jsr CreateObjs

	.next:
	lda spotsleft
	beq >
		jmp Generate
	>
	lda g.boolParty
	eor #g.BOOLS_LHALFFREE
	sta g.boolParty
	rts

; params:
;	x - index into objs[] to start creating
; clobbers:
;	y
CreateObjs:
	var [1] numobjs
	var [1] addx
	var [1] mystorey
	var [1] lastx
	ldy #0
	lda [Generate.addr], y
	jsr comm.ModRandomNum
	sta addx
	ldx objind
	; go over x-vary byte
		lda Generate.addr
		clc
		adc #1
		sta Generate.addr
		lda Generate.addr+1
		adc #0
		sta Generate.addr+1
	.loop:
		lda cstorey
		sta mystorey
		ldy #OBJ_SCEN_ALLOC - 1
		lda [Generate.addr], y
		sta obj.TYPE, x
		dey
			; mirrored?
			lda Generate.mirrored
			beq >
				tya
				pha
				lda obj.TYPE, x
				tay
				lda obj.mirrored_types, y
				sta obj.TYPE, x
				pla
				tay
			>
		lda [Generate.addr], y
		sta obj.NUMSEGS, x
		dey
		; y
			lda cy
			sec
			sbc [Generate.addr], y
			bcs >
				inc cstorey
				inc mystorey
				inc nextlvl
			>
			sta cy
			jsr ApplyYOffset
			sta obj.Y, x
			dey
		; x
			lda [Generate.addr], y
			sta obj.X, x
				; mirrored?
				lda Generate.mirrored
				beq >
					ldy obj.TYPE, x
					lda #$ff
					sec
					sbc obj.X, x
					sbc obj.ex_widths, y
					sta obj.X, x
				>
			lda obj.X, x
			jsr ApplyXOffset
			sta obj.X, x
				; mirrored?
				ldy Generate.mirrored
				beq .addx
				;subx:
					sec
					sbc addx
					jmp .addxend
				.addx:
					clc
					adc addx
				.addxend:
			sta obj.X, x
			sta lastx
		lda mystorey
		sta obj.STOREY, x
		txa
		clc
		adc #obj.OBJ_RAM_ALLOC
		sta objind
		tax
		lda Generate.addr
		clc
		adc #OBJ_SCEN_ALLOC
		sta Generate.addr
		lda Generate.addr+1
		adc #0
		sta Generate.addr+1
		dec numobjs
		beq >
			jmp .loop
		>
		; bne .loop
	; if a scenario ends very far to the side & the next one starts too far to the other side, it could be impossible to make the jump; hence the safe scenario which is just a platform moving left to right across screen, bandaid fix but it is what it is
	const TOO_FAR_RIGHT_X 196
	const TOO_FAR_LEFT_X 60
	lda #0
	sta gensafe
	lda lastx
	cmp #TOO_FAR_RIGHT_X
	bcc >
		dec gensafe
		rts
	>
	cmp #TOO_FAR_LEFT_X
	bcs >
		dec gensafe
	>
	rts

; params:
;	a - original X value of new object
; returns:
;	a - actual, real, down-to-earth, auTHENtic X value of obj
ApplyXOffset:
	var [1] newx
	var [2] addr
	sta newx
	txa
	pha
	lda obj.TYPE, x
	asl a
	tax
	lda .jumpaddrs, x
	sta addr
	lda .jumpaddrs+1, x
	sta addr+1
	pla
	tax
	jmp [addr]

	.r:
		lda newx
		clc
		adc obj.backForthOffset
		.end: rts
	.l:
		lda newx
		sec
		sbc obj.backForthOffset
		rts
	.nah:
	lda newx
	rts
	.jumpaddrs:
		.dw .nah ; NORMAL
		.dw .r ; DOWNRIGHT
		.dw .l ; DOWNLEFT
		.dw .r ; UPRIGHT
		.dw .l ; UPLEFT
		.dw .nah ; DOWN
		.dw .nah ; UP
		.dw .r ; RIGHT
		.dw .l ; LEFT
		.dw .nah ; SPDDOWN
		.dw .nah ; SPDUP
		.dw .nah ; SHOCK
		.dw .nah ; FLIP ; must come right after shock
		.dw .nah ; BOUNCE
		.dw .nah ; CRUMBLE0
		.dw .nah ; CRUMBLE1
		.dw .nah ; CRUMBLE2
		.dw .nah ; CRUMBLE3
		.dw .nah ; CRUMBLE4
		.dw .nah ; CRUMBLE5
		.dw .nah ; CRUMBLE6
		.dw .r ; SPIKE_DR
		.dw .l ; SPIKE_DL
		.dw .r ; SPIKE_R
		.dw .l ; SPIKE_L
		.dw .r ; SPIKE_UR
		.dw .l ; SPIKE_UL
		.dw .nah ; SPIKE_D
		.dw .nah ; THORN
		.dw .nah ; THORN_TOP
		.dw .nah ; THORN_L
		.dw .nah ; THORN_R
		.dw .r ; THORN_R_R
		.dw .r ; THORN_L_R
		.dw .l ; THORN_R_L
		.dw .l ; THORN_L_L
		.dw .r ; THORN_L_DR
		.dw .r ; THORN_R_DR
		.dw .l ; THORN_L_DL
		.dw .l ; THORN_R_DL
		.dw .r ; THORN_L_UR
		.dw .r ; THORN_R_UR
		.dw .l ; THORN_L_UL
		.dw .l ; THORN_R_UL
		.dw .nah ; THORN_L_FLIP ; only flip thorns after this
		.dw .nah ; THORN_R_FLIP

; params:
;	a - old Y
; returns:
;	a - new Y
ApplyYOffset:
	var [1] newy
	var [2] addr
	sta newy

	txa
	pha
	lda obj.TYPE, x
	asl a
	tax
	lda .jumpaddrs, x
	sta addr
	lda .jumpaddrs+1, x
	sta addr+1
	pla
	tax
	jmp [addr]

	.d:
		lda obj.backForthOffset
		bmi .dm
		;dp:
			clc
			adc newy
			bcc .end
			dec CreateObjs.mystorey
			rts
		.dm:
			clc
			adc newy
			bcs .end
			inc CreateObjs.mystorey
			.end: rts
	.u:
		lda obj.backForthOffset
		bmi .um
		;up:
			lda newy
			sec
			sbc obj.backForthOffset
			bcs .end
			inc CreateObjs.mystorey
			rts
		.um:
			lda newy
			sec
			sbc obj.backForthOffset
			bcc .end
			dec CreateObjs.mystorey
			rts
	.nah:
	lda newy
	rts
	.jumpaddrs:
		.dw .nah ; NORMAL
		.dw .d ; DOWNRIGHT
		.dw .d ; DOWNLEFT
		.dw .u ; UPRIGHT
		.dw .u ; UPLEFT
		.dw .d ; DOWN
		.dw .u ; UP
		.dw .nah ; RIGHT
		.dw .nah ; LEFT
		.dw .nah ; SPDDOWN
		.dw .nah ; SPDUP
		.dw .nah ; SHOCK
		.dw .nah ; FLIP ; must come right after shock
		.dw .nah ; BOUNCE
		.dw .nah ; CRUMBLE0
		.dw .nah ; CRUMBLE1
		.dw .nah ; CRUMBLE2
		.dw .nah ; CRUMBLE3
		.dw .nah ; CRUMBLE4
		.dw .nah ; CRUMBLE5
		.dw .nah ; CRUMBLE6
		.dw .d ; SPIKE_DR
		.dw .d ; SPIKE_DL
		.dw .nah ; SPIKE_R
		.dw .nah ; SPIKE_L
		.dw .u ; SPIKE_UR
		.dw .u ; SPIKE_UL
		.dw .d ; SPIKE_D
		.dw .nah ; THORN
		.dw .nah ; THORN_TOP
		.dw .nah ; THORN_L
		.dw .nah ; THORN_R
		.dw .nah ; THORN_R_R
		.dw .nah ; THORN_L_R
		.dw .nah ; THORN_R_L
		.dw .nah ; THORN_L_L
		.dw .d ; THORN_L_DR
		.dw .d ; THORN_R_DR
		.dw .d ; THORN_L_DL
		.dw .d ; THORN_R_DL
		.dw .u ; THORN_L_UR
		.dw .u ; THORN_R_UR
		.dw .u ; THORN_L_UL
		.dw .u ; THORN_R_UL
		.dw .nah ; THORN_L_FLIP ; only flip thorns after this
		.dw .nah ; THORN_R_FLIP