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
const HARD_LVL_1_FRAC 22	; OUT OF 256
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
	bcc .easy
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
			jsr ApplyXOffset
			clc
			adc addx
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
		bne .loop
	; if a scenario ends very far to the right & the next one starts to the left, it could be impossible to make the jump; hence the safe scenario which is just a platform moving left to right across screen, bandaid fix but it is what it is
	const TOO_FAR_RIGHT_X 190
	lda #0
	sta gensafe
	lda lastx
	cmp #TOO_FAR_RIGHT_X
	bcc >
		dec gensafe
	>
	rts

; params:
;	a - original X value of new object
; returns:
;	a - actual, real, down-to-earth, auTHENtic X value of obj
ApplyXOffset:
	var [1] newx
	sta newx
	lda obj.TYPE, x
	cmp #obj.TYPES.RIGHT
	beq .r
	cmp #obj.TYPES.THORN_R_R
	beq .r
	cmp #obj.TYPES.LEFT
	beq .l
	cmp #obj.TYPES.UPLEFT
	beq .l
	cmp #obj.TYPES.THORN_R_L
	beq .l
	cmp #obj.TYPES.SPIKE_DR
	beq .r
	cmp #obj.TYPES.SPIKE_R
	beq .r
	cmp #obj.TYPES.SPIKE_UR
	beq .r
	cmp #obj.TYPES.SPIKE_UL
	beq .l
	cmp #obj.TYPES.THORN_L_DR
	beq .r
	cmp #obj.TYPES.DOWNRIGHT
	beq .r
	cmp #obj.TYPES.THORN_R_UR
	beq .r
	cmp #obj.TYPES.THORN_R_DR
	beq .r
	cmp #obj.TYPES.UPRIGHT
	beq .r
	bne .nah ; jmp
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

; params:
;	a - old Y
; returns:
;	a - new Y
ApplyYOffset:
	var [1] newy
	sta newy
	lda obj.TYPE, x
	cmp #obj.TYPES.DOWN
	beq .d
	cmp #obj.TYPES.DOWNRIGHT
	beq .d
	cmp #obj.TYPES.UP
	beq .u
	cmp #obj.TYPES.UPRIGHT
	beq .u
	cmp #obj.TYPES.UPLEFT
	beq .u
	cmp #obj.TYPES.THORN_L_DR
	beq .d
	cmp #obj.TYPES.THORN_L_UR
	beq .u
	cmp #obj.TYPES.THORN_R_UR
	beq .u
	cmp #obj.TYPES.THORN_R_DR
	beq .d
	cmp #obj.TYPES.SPIKE_DR
	beq .d
	cmp #obj.TYPES.SPIKE_UR
	beq .u
	cmp #obj.TYPES.SPIKE_UL
	beq .u
	cmp #obj.TYPES.SPIKE_D
	beq .d
	bne .nah ; jmp
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