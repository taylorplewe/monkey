	.inesprg 1    ; Defines the number of 16kb PRG banks
	.ineschr 1    ; Defines the number of 8kb CHR banks
	.inesmap 0    ; Defines the NES mapper
	.inesmir 0    ; Defines VRAM mirroring of banks

const OAM_Y		$0200
const OAM_TILE	OAM_Y + 1
const OAM_ATTR	OAM_Y + 2
const OAM_X		OAM_Y + 3

const BOOLS_NMI_READY		%10000000
const BOOLS_MONKEYINFRONT	%00000001
const BOOLS_LHALFFREE		%00000010
const BOOLS_PLAYSHOCKSND	%00000100
const BOOLS_PLAYFLIPSND		%00001000
const BOOLS_UPDATEM2		%00010000
const BOOLS_MULTIPLAYER		%00100000
const BOOLS_TITLE			%01000000

idset SOUNDS {
	BOUNCE
	CRUMBLE
	DIE
	FLIP
	LAND
	SHOCK
	MONKEY_CHIRP1
	MONKEY_CHIRP2
	MONKEY_CHIRP3
	MONKEY_CHIRP4
	MONKEY2_CHIRP1
	MONKEY2_CHIRP2
	MONKEY2_CHIRP3
	MONKEY2_CHIRP4
	CHANGE_SELECT
	SELECT
	FALL
	VICTORY
	FLIP_MONKEY
}

var [1] boolParty
var [1] counter
var [1] ppuctrl
var [1] ppumask
var [2] seed
var [2] score ; total # NT's risen
var [1] paused ; added last minute lmao

	; PRG
	.bank 0
	.org $8000

reset:
	; disable graphics and stuff
	ldx #0
	stx $2000
	stx $2001

	; reset all RAM
		; not every NES (or NES emulator) is created equal;
		; it should never be expected that RAM will start up with all zeros
		txa
		.zeroLoop:
			sta <$00, x
			sta $0100, x
			sta $0300, x
			sta $0400, x
			; sta $0500, x
			; sta $0600, x
			; sta $0700, x
			inx
			bne .zeroLoop
		lda #$ff ; put all unused sprites offscreen
		.ffloop:
			sta $0200, x
			inx
			bne .ffloop

	; reset stack pointer
	;ldx #$ff
	tax
	txs

	; put whatever's in $6000.6001 into the seed; hopefully this is random, if not that's fine too
	lda $6000
	sta seed
	lda $6001
	sta seed+1

	; wait for PPU and CPU to get synced up
	ldx #2
	.sync1:
		lda $2002
		bpl .sync1
		dex
		bne .sync1

	lda #$ff
	jsr ft.FamiToneInit
	ldx #LOW(sounds)
	ldy #HIGH(sounds)
	jsr ft.FamiToneSfxInit

	jsr ctrl.InitTitle

	lda boolParty
	ora #BOOLS_TITLE
	sta boolParty

	; re-enable stuff
	lda #%10000000
	sta $2000
	sta ppuctrl
	lda #%00011110
	sta $2001
	sta ppumask

	; wait for PPU and CPU to get synced up
	ldx #2
	.sync2:
		lda $2002
		bpl .sync2
		dex
		bne .sync2
forever:
	inc counter
	inc seed
	lda seed
	bne >
		inc seed+1
	>
	jsr input.Read

	; on title screen?
	lda boolParty
	and #BOOLS_TITLE
	bne .title
	; game loop
		; pause logic
			jsr ctrl.Pause
			lda paused
			bne .pausedend
		lda ctrl.victorind
		beq >
			jsr monkey.UpdateVictor
			jsr ctrl.UpdateCrown
		>
		lda disp.deathCtr
		bpl >
			jsr obj.Update
			jsr monkey.UpdateBothMonkeys
		>
		jsr disp.Update
		jsr ctrl.UpdateGame
		; play sounds
		lda boolParty
		and #BOOLS_PLAYFLIPSND | BOOLS_PLAYSHOCKSND
		beq .forevershared
			and #BOOLS_PLAYSHOCKSND
			beq .flip
				ldx #FT_SFX_CH0
				lda #SOUNDS.SHOCK
				jsr ft.FamiToneSfxPlay
				jmp .tse
			.flip:
				ldx #FT_SFX_CH2
				lda #SOUNDS.FLIP
				jsr ft.FamiToneSfxPlay
			.tse:
			lda boolParty
			and #(BOOLS_PLAYFLIPSND | BOOLS_PLAYSHOCKSND) ^ $ff
			sta boolParty
			jmp .forevershared
	.title:
		jsr ctrl.UpdateTitle
		jsr disp.UpdateTitle
	.forevershared:

	; DEBUG
	lda input.buttonsDown
	and #input.BTN_SELECT
	beq >
		; jsr disp.IncreaseScore
		; jsr ctrl.IncreaseHexScore
	>

	.pausedend:

	jsr ft.FamiToneUpdate

	lda input.buttonsDown+1
	sta input.buttonsPrev+1
	lda input.buttonsDown+2
	sta input.buttonsPrev+2

	; done
	lda boolParty
	ora #%10000000
	sta boolParty
	.waitnmi:
		lda boolParty
		bmi .waitnmi
	jmp forever
nmi:
	pha
	tya
	pha
	txa
	pha

	; ready to draw?
	lda boolParty
	asl a
	bcc .recal ; nope

	lda #0
	sta $2003 ; "It is common practice to initialize it to 0 with a write to OAMADDR before the DMA transfer." (http://wiki.nesdev.com/w/index.php/PPU_registers#OAMDMA)
	lda #$02
	sta $4014 ; draw all sprites

	; apply PPU buffer
	ldx #0
	ldy disp.PPU_BUFF
	beq .buffoloopend
	.buffoloop:
		inx
		lda disp.PPU_BUFF, x
		sta $2006
		inx
		lda disp.PPU_BUFF, x
		sta $2006
		inx
		.buffiloop:
			lda disp.PPU_BUFF, x
			sta $2007
			inx
			dey
			bne .buffiloop
		.buffiloopend:
		ldy disp.PPU_BUFF, x
		bne .buffoloop
	.buffoloopend:

	lda boolParty
	and #%01111111
	sta boolParty

	; scroll
	lda disp.xscroll ; mainly for shake effect & title screen scroll effect
	sta $2005
	lda disp.scroll
	sta $2005

	.recal:
	lda ppuctrl
	sta $2000
	lda ppumask
	sta $2001

	pla
	tax
	pla
	tay
	pla
	rti

	.include "src/disp.s"
	.include "src/monkey.s"
	.include "src/comm.s"
	.include "src/input.s"
	.include "src/obj.s"
	.include "src/gen.s"
	
;
	.bank 1
	.org $a000
	.include "src/ctrl.s"
	.include "src/famitone2.s"
	.include "src/fx.s"
sounds:
	.include "src/data/sounds.s"
titletiles:
	.include "src/data/title-tiles.s"
titleattrs:
	.include "src/data/title-attrs.s"
gametiles:
	.include "src/data/start-map.s"
gametiles2:
	.include "src/data/start-map2.s"
	
	.include "src/data/scenarios.s"
monkeywordtiles:
	.db $59, $4e, $5a, $57, $48, $4f, $5d

titlepals:
	; bg
	.db $21, $0d, $10, $20
	.db $21, $0d, $0c, $2b
	.db $21, 0, 0, 0
	.db $21, $01, $0d, $0d
	; spr
	.db $21, $0d, $00, $00
	.db $21, $00, $00, $20
	.db $21, 0, 0, 0
	.db $21, 0, 0, 0
gamepals:
	; bg
	.db $21, $0c, $1b, $29
	.db $21, 0, 0, 0
	.db $21, 0, 0, 0
	.db $21, 0, 0, 0
	; spr
	.db $21, $0d, $17, $27
	.db $21, $0d, $00, $10
	.db $21, $0d, $21, $20
	; .db $21, $0d, $16, $20
	.db $21, $0d, $16, $37

; a table of which method should be invoked when drawing each particular wall type
sdaddrs:
	.dw disp.SD_norm			; normal
	.dw disp.SD_norm			; downright
	.dw disp.SD_norm			; downleft
	.dw disp.SD_norm			; upright
	.dw disp.SD_norm			; upleft
	.dw disp.SD_norm			; down
	.dw disp.SD_norm			; up
	.dw disp.SD_norm			; right
	.dw disp.SD_norm			; left
	.dw disp.SD_speed			; spddown
	.dw disp.SD_speed			; spdup
	.dw disp.SD_timer			; shock
	.dw disp.SD_timer			; flip
	.dw disp.SD_norm			; bounce
	.dw disp.SD_crumble			; crumble0
	.dw disp.SD_crumble			; crumble1
	.dw disp.SD_crumble			; crumble2
	.dw disp.SD_crumble			; crumble3
	.dw disp.SD_crumble			; crumble4
	.dw disp.SD_crumble			; crumble5
	.dw disp.SD_crumble			; crumble6
	.dw disp.SD_spike			; spike_dr
	.dw disp.SD_spike			; spike_dl
	.dw disp.SD_spike			; spike_r
	.dw disp.SD_spike			; spike_l
	.dw disp.SD_spike			; spike_ur
	.dw disp.SD_spike			; spike_ul
	.dw disp.SD_spike			; spike_d
	.dw disp.SD_thorn			; thorn
	.dw disp.SD_thorn			; thorn_top
	.dw disp.SD_thorn_l_dbl		; thorn_l
	.dw disp.SD_thorn_r_dbl		; thorn_r
	.dw disp.SD_thorn_r_dbl		; thorn_r_r
	.dw disp.SD_thorn_l_dbl		; thorn_l_r
	.dw disp.SD_thorn_r_dbl		; thorn_r_l
	.dw disp.SD_thorn_l_dbl		; thorn_l_l
	.dw disp.SD_thorn_l_dbl		; thorn_l_dr
	.dw disp.SD_thorn_r_dbl		; thorn_r_dr
	.dw disp.SD_thorn_l_dbl		; thorn_l_dl
	.dw disp.SD_thorn_r_dbl		; thorn_r_dl
	.dw disp.SD_thorn_l_dbl		; thorn_l_ur
	.dw disp.SD_thorn_r_dbl		; thorn_r_ur
	.dw disp.SD_thorn_l_dbl		; thorn_l_ul
	.dw disp.SD_thorn_r_dbl		; thorn_r_ul
	.dw disp.SD_thorn_l_flip	; thorn_l_flip
	.dw disp.SD_thorn_r_flip	; thorn_r_flip

	.org $fffa
	.dw nmi
	.dw reset
	.dw 0

	; CHR
	.bank 2
	.org $0000
	.incbin "bin/graphics.chr"