class scen

safescenario:
	.db 60 ; how much scenario can vary X-wise
	.db 52, 96, 0, obj.TYPES.RIGHT ; x, -y (relative), type

; same for easy & hard
shared1scenarios:
	.db (.1_addrsend - .1_addrs) / 2
	.1_addrs:
		.dw .1_1, .1_2, .1_3, .1_4, .1_6, .1_7
		; .dw .1_6
	.1_addrsend:
	.1_1:
		.db 144 ; how much scenario can vary X-wise
		.db 52, 96, 1, obj.TYPES.NORMAL ; x, -y (relative), type
	.1_2:
		.db 144 ; how much scenario can vary X-wise
		.db 52, 96, 1, obj.TYPES.SHOCK ; x, -y (relative), type
	.1_3:
		.db 144 ; how much scenario can vary X-wise
		.db 52, 96, 1, obj.TYPES.FLIP ; x, -y (relative), type
	.1_4:
		.db 144 ; how much scenario can vary X-wise
		.db 52, 96, 0, obj.TYPES.CRUMBLE0 ; x, -y (relative), type
	.1_6:
		.db 144
		.db 52, 80, 0, obj.TYPES.BOUNCE
	.1_7:
		.db 144
		.db 52, 164, 0, obj.TYPES.DOWN
	
scenarios_easy:
	; organized by # objs
	.dw shared1scenarios, .2, .3, .4, .5, .6, .7, .8
	.2:
		.db (.2_addrsend - .2_addrs) / 2
		.2_addrs:
			.dw .2_1, .2_2, .2_3, .2_4, .2_5, .2_6, .2_7
		.2_addrsend:
		.2_1:
			.db 144
			.db 60, 80, 0, obj.TYPES.THORN_R_FLIP
			.db 52, 8, 1, obj.TYPES.FLIP
		.2_2:
			.db 144
			.db 52, 80, 0, obj.TYPES.CRUMBLE0
			.db 52, 110, 0, obj.TYPES.CRUMBLE0
		.2_3:
			.db 80
			.db 52, 88, 1, obj.TYPES.NORMAL
			.db 149, 68, 1, obj.TYPES.NORMAL
		.2_4:
			.db 40
			.db 68, 88, 0, obj.TYPES.THORN_R_R
			.db 60, 0, 0, obj.TYPES.RIGHT
		.2_5:
			.db 50
			.db 170, 88, 1, obj.TYPES.BOUNCE
			.db 52, 0, 1, obj.TYPES.BOUNCE
		.2_6:
			.db 120
			.db 52, 168, 5, obj.TYPES.SPDUP
			.db 44, 24, 0, obj.TYPES.THORN_TOP
		.2_7:
			.db 10
			.db 120, 88, 0, obj.TYPES.UPLEFT
			.db 120, 194, 0, obj.TYPES.DOWNRIGHT
	.3:
		.db (.3_addrsend - .3_addrs) / 2
		.3_addrs:
			.dw .3_1, .3_2, .3_3, .3_4, .3_5
		.3_addrsend:
		.3_1:
			.db 70
			.db 120, 120, 0, obj.TYPES.THORN_L
			.db 120, 80, 0, obj.TYPES.THORN_L
			.db 128, 40, 11, obj.TYPES.NORMAL
		.3_2:
			.db 70
			.db 24, 90, 1, obj.TYPES.NORMAL
			.db 30, 80, 0, obj.TYPES.SPIKE_DR
			.db 136, 0, 1, obj.TYPES.NORMAL
		.3_3:
			.db 1
			.db 210, 255, 10, obj.TYPES.NORMAL
			.db 30, 0, 10, obj.TYPES.NORMAL
			.db 120, 0, 10, obj.TYPES.NORMAL
		.3_4:
			.db 80
			.db 52, 88, 0, obj.TYPES.UPRIGHT
			.db 90, 50, 0, obj.TYPES.THORN
			.db 140, 140, 1, obj.TYPES.NORMAL
		.3_5:
			.db 25
			.db 52, 88, 1, obj.TYPES.NORMAL
			.db 200, 120, 1, obj.TYPES.NORMAL
			.db 52, 0, 0, obj.TYPES.DOWNRIGHT
	.4:
		.db (.4_addrsend - .4_addrs) / 2
		.4_addrs:
			.dw .4_1, .4_2, .4_3, .4_4
		.4_addrsend:
		.4_1:
			.db 60
			.db 80, 100, 0, obj.TYPES.THORN_R_UR
			.db 72, 0, 0, obj.TYPES.UPRIGHT
			.db 80, 255, 0, obj.TYPES.THORN_R_DR
			.db 72, 0, 0, obj.TYPES.DOWNRIGHT
		.4_2:
			.db 80
			.db 24, 80, 1, obj.TYPES.SHOCK
			.db 140, 80, 1, obj.TYPES.SHOCK
			.db 24, 80, 1, obj.TYPES.SHOCK
			.db 140, 80, 1, obj.TYPES.SHOCK
		.4_3:
			.db 80
			.db 132, 80, 0, obj.TYPES.THORN_L_FLIP
			.db 140, 8, 1, obj.TYPES.FLIP
			.db 22, 80, 0, obj.TYPES.THORN_L_FLIP
			.db 30, 8, 1, obj.TYPES.FLIP
		.4_4:
			.db 120
			.db 100, 80, 0, obj.TYPES.NORMAL
			.db 100, 164, 5, obj.TYPES.BOUNCE
			.db 24, 24, 9, obj.TYPES.BOUNCE
			.db 100, 66, 1, obj.TYPES.NORMAL
	.5:
		.db (.5_addrsend - .5_addrs) / 2
		.5_addrs:
			.dw .5_1, .5_2, .5_3, .5_4
		.5_addrsend:
		.5_1:
			.db 40
			.db 110, 176, 4, obj.TYPES.SPDDOWN
			.db 102, 24, 0, obj.TYPES.THORN_TOP
			.db 110, 88, 4, obj.TYPES.SPDDOWN
			.db 102, 24, 0, obj.TYPES.THORN_TOP
			.db 110, 88, 4, obj.TYPES.SPDDOWN
		.5_2:
			.db 40
			.db 140, 88, 1, obj.TYPES.SHOCK
			.db 52, 50, 1, obj.TYPES.BOUNCE
			.db 140, 50, 1, obj.TYPES.BOUNCE
			.db 52, 50, 1, obj.TYPES.BOUNCE
			.db 140, 50, 0, obj.TYPES.CRUMBLE0
		.5_3:
			.db 40
			.db 20, 80, 0, obj.TYPES.SPIKE_UR
			.db 168, 44, 3, obj.TYPES.NORMAL
			.db 52, 118, 4, obj.TYPES.NORMAL
			.db 168, 70, 1, obj.TYPES.NORMAL
			.db 20, 20, 0, obj.TYPES.SPIKE_DR
		.5_4:
			.db 144
			.db 44, 88, 0, obj.TYPES.THORN_L_FLIP
			.db 44, 32, 0, obj.TYPES.THORN_L_FLIP
			.db 60, 32, 0, obj.TYPES.THORN_R_FLIP
			.db 60, 32, 0, obj.TYPES.THORN_R_FLIP
			.db 52, 8, 7, obj.TYPES.FLIP
	.6:
		.db (.6_addrsend - .6_addrs) / 2
		.6_addrs:
			.dw .6_1, .6_2, .6_3, .6_4
		.6_addrsend:
		.6_1:
			.db 40
			.db 60, 80, 0, obj.TYPES.THORN_R_R
			.db 52, 0, 0, obj.TYPES.RIGHT
			.db 200, 80, 0, obj.TYPES.THORN_R_L
			.db 192, 0, 0, obj.TYPES.LEFT
			.db 60, 80, 0, obj.TYPES.THORN_R_R
			.db 52, 0, 0, obj.TYPES.RIGHT
		.6_2:
			.db 80
			.db 80, 80, 0, obj.TYPES.THORN_L_FLIP
			.db 88, 8, 1, obj.TYPES.FLIP
			.db 150, 148, 10, obj.TYPES.SPDUP
			.db 96, 0, 0, obj.TYPES.THORN_R_FLIP
			.db 88, 8, 1, obj.TYPES.FLIP
			.db 142, 16, 0, obj.TYPES.THORN_TOP
		.6_3:
			.db 20
			.db 60, 88, 0, obj.TYPES.THORN_R
			.db 52, 0, 0, obj.TYPES.NORMAL
			.db 140, 32, 0, obj.TYPES.THORN_R
			.db 132, 0, 0, obj.TYPES.NORMAL
			.db 220, 32, 0, obj.TYPES.THORN_R
			.db 212, 0, 0, obj.TYPES.NORMAL
		.6_4:
			.db 20
			.db 110, 88, 0, obj.TYPES.BOUNCE
			.db 44, 50, 0, obj.TYPES.CRUMBLE0
			.db 182, 0, 0, obj.TYPES.CRUMBLE0
			.db 52, 36, 0, obj.TYPES.SPIKE_R
			.db 44, 36, 0, obj.TYPES.CRUMBLE0
			.db 182, 0, 0, obj.TYPES.CRUMBLE0
	.7:
		.db (.7_addrsend - .7_addrs) / 2
		.7_addrs:
			.dw .7_1, .7_2, .7_3, .7_4, .7_5
		.7_addrsend:
		.7_1:
			.db 20
			.db 60, 120, 0, obj.TYPES.THORN_R
			.db 52, 60, 7, obj.TYPES.NORMAL
			.db 130, 0, 0, obj.TYPES.THORN
			.db 220, 90, 4, obj.TYPES.NORMAL
			.db 116, 16, 0, obj.TYPES.THORN_R
			.db 108, 0, 0, obj.TYPES.NORMAL
			.db 108, 140, 2, obj.TYPES.NORMAL
		.7_2:
			.db 144
			.db 44, 88, 0, obj.TYPES.THORN_L_FLIP
			.db 44, 32, 0, obj.TYPES.THORN_L_FLIP
			.db 44, 32, 0, obj.TYPES.THORN_L_FLIP
			.db 60, 32, 0, obj.TYPES.THORN_R_FLIP
			.db 60, 32, 0, obj.TYPES.THORN_R_FLIP
			.db 60, 32, 0, obj.TYPES.THORN_R_FLIP
			.db 52, 8, 11, obj.TYPES.FLIP
		.7_3:
			.db 50
			.db 52, 88, 0, obj.TYPES.THORN_L_FLIP
			.db 60, 8, 1, obj.TYPES.FLIP
			.db 176, 70, 1, obj.TYPES.NORMAL
			.db 68, 70, 0, obj.TYPES.THORN_R_FLIP
			.db 60, 8, 1, obj.TYPES.FLIP
			.db 168, 70, 0, obj.TYPES.THORN_L_FLIP
			.db 176, 8, 1, obj.TYPES.FLIP
		.7_4:
			.db 124
			.db 64, 116, 2, obj.TYPES.BOUNCE
			.db 56, 34, 0, obj.TYPES.THORN
			.db 64, 66, 2, obj.TYPES.BOUNCE
			.db 56, 34, 0, obj.TYPES.THORN
			.db 64, 66, 2, obj.TYPES.BOUNCE
			.db 56, 34, 0, obj.TYPES.THORN
			.db 64, 66, 2, obj.TYPES.BOUNCE
		.7_5:
			.db 124
			.db 64, 88, 0, obj.TYPES.CRUMBLE0
			.db 64, 112, 5, obj.TYPES.SPDUP
			.db 56, 24, 0, obj.TYPES.THORN_TOP
			.db 64, 104, 5, obj.TYPES.SPDUP
			.db 56, 24, 0, obj.TYPES.THORN_TOP
			.db 64, 104, 5, obj.TYPES.SPDUP
			.db 56, 24, 0, obj.TYPES.THORN_TOP
	.8:
		.db (.8_addrsend - .8_addrs) / 2
		.8_addrs:
			.dw .8_1, .8_2, .8_3, .8_4
		.8_addrsend:
		.8_1:
			.db 80
			.db 132, 80, 0, obj.TYPES.THORN_L_FLIP
			.db 140, 8, 1, obj.TYPES.FLIP
			.db 22, 80, 0, obj.TYPES.THORN_L_FLIP
			.db 30, 8, 1, obj.TYPES.FLIP
			.db 132, 80, 0, obj.TYPES.THORN_L_FLIP
			.db 140, 8, 1, obj.TYPES.FLIP
			.db 22, 80, 0, obj.TYPES.THORN_L_FLIP
			.db 30, 8, 1, obj.TYPES.FLIP
		.8_2:
			.db 40
			.db 200, 140, 3, obj.TYPES.NORMAL
			.db 100, 8, 0, obj.TYPES.THORN
			.db 20, 4, 2, obj.TYPES.NORMAL
			.db 20, 88, 1, obj.TYPES.NORMAL
			.db 108, 48, 0, obj.TYPES.THORN_R
			.db 100, 0, 0, obj.TYPES.NORMAL
			.db 208, 48, 0, obj.TYPES.THORN_R
			.db 200, 0, 0, obj.TYPES.NORMAL
		.8_3:
			.db 30
			.db 52, 88, 1, obj.TYPES.SPDDOWN
			.db 150, 78, 1, obj.TYPES.SPDDOWN
			.db 200, 78, 1, obj.TYPES.SPDDOWN
			.db 200, 116, 1, obj.TYPES.SPDDOWN
			.db 200, 116, 1, obj.TYPES.SPDDOWN
			.db 16, 0, 1, obj.TYPES.SPDDOWN
			.db 16, 116, 1, obj.TYPES.SPDDOWN
			.db 128, 58, 1, obj.TYPES.SPDDOWN
		.8_4:
			.db 60
			.db 56, 88, 0, obj.TYPES.THORN_R
			.db 48, 0, 0, obj.TYPES.NORMAL
			.db 140, 0, 0, obj.TYPES.THORN_L
			.db 148, 0, 0, obj.TYPES.NORMAL
			.db 40, 100, 0, obj.TYPES.THORN_L
			.db 48, 0, 0, obj.TYPES.NORMAL
			.db 156, 0, 0, obj.TYPES.THORN_R
			.db 148, 0, 0, obj.TYPES.NORMAL

scenarios_hard:
	; organized by # objs
	.dw shared1scenarios, .2, .3, .4, .5, .6, .7, .8
	.2:
		.db (.2_addrsend - .2_addrs) / 2
		.2_addrs:
			.dw .2_1, .2_2, .2_3
		.2_addrsend:
		.2_1:
			.db 80
			.db 90, 120, 0, obj.TYPES.THORN
			.db 98, 38, 0, obj.TYPES.DOWN
		.2_2:
			.db 70
			.db 150, 88, 0, obj.TYPES.LEFT
			.db 52, 0, 0, obj.TYPES.SPIKE_R
		.2_3:
			.db 70
			.db 52, 88, 0, obj.TYPES.RIGHT
			.db 92, 0, 0, obj.TYPES.THORN
	.3:
		.db (.3_addrsend - .3_addrs) / 2
		.3_addrs:
			.dw .3_1, .3_2, .3_3, .3_4
		.3_addrsend:
		.3_1:
			.db 144
			.db 52, 120, 0, obj.TYPES.THORN_TOP
			.db 52, 80, 0, obj.TYPES.THORN_TOP
			.db 60, 40, 11, obj.TYPES.SPDDOWN
		.3_2:
			.db 144
			.db 52, 90, 0, obj.TYPES.THORN_L_FLIP
			.db 68, 32, 0, obj.TYPES.THORN_R_FLIP
			.db 60, 8, 3, obj.TYPES.FLIP
		.3_3:
			.db 100
			.db 140, 96, 1, obj.TYPES.NORMAL
			.db 52, 48, 1, obj.TYPES.BOUNCE
			.db 140, 48, 1, obj.TYPES.SHOCK
		.3_4:
			.db 50
			.db 170, 88, 1, obj.TYPES.BOUNCE
			.db 60, 1, 0, obj.TYPES.SPIKE_UR
			.db 52, 106, 1, obj.TYPES.NORMAL
	.4:
		.db (.4_addrsend - .4_addrs) / 2
		.4_addrs:
			.dw .4_1, .4_2, .4_3, .4_4
		.4_addrsend:
		.4_1:
			.db 40
			.db 180, 80, 0, obj.TYPES.UP
			.db 88, 140, 1, obj.TYPES.BOUNCE
			.db 20, 40, 0, obj.TYPES.SPIKE_R
			.db 88, 136, 6, obj.TYPES.NORMAL
		.4_2:
			.db 40
			.db 42, 88, 0, obj.TYPES.CRUMBLE0
			.db 170, 48, 0, obj.TYPES.CRUMBLE0
			.db 42, 48, 0, obj.TYPES.CRUMBLE0
			.db 98, 16, 0, obj.TYPES.SPIKE_D
		.4_3:
			.db 60
			.db 52, 88, 0, obj.TYPES.UP
			.db 160, 154, 1, obj.TYPES.BOUNCE
			.db 52, 180, 0, obj.TYPES.DOWN
			.db 160, 88, 0, obj.TYPES.CRUMBLE0
		.4_4:
			.db 40
			.db 140, 88, 1, obj.TYPES.SHOCK
			.db 52, 50, 1, obj.TYPES.BOUNCE
			.db 140, 50, 1, obj.TYPES.BOUNCE
			.db 52, 50, 1, obj.TYPES.SHOCK
	.5:
		.db (.5_addrsend - .5_addrs) / 2
		.5_addrs:
			.dw .5_1, .5_2, .5_3, .5_4
		.5_addrsend:
		.5_1:
			.db 40
			.db 52, 92, 1, obj.TYPES.NORMAL
			.db 44, 110, 0, obj.TYPES.THORN_L_DR
			.db 52, 0, 0, obj.TYPES.DOWNRIGHT
			.db 160, 0, 0, obj.TYPES.THORN_L
			.db 168, 8, 1, obj.TYPES.NORMAL
		.5_2:
			.db 80
			.db 126, 100, 0, obj.TYPES.THORN
			.db 126, 32, 0, obj.TYPES.THORN
			.db 126, 32, 0, obj.TYPES.THORN
			.db 126, 32, 0, obj.TYPES.THORN
			.db 52, 32, 10, obj.TYPES.BOUNCE
		.5_3:
			.db 1
			.db 148, 150, 0, obj.TYPES.THORN_R_DR
			.db 140, 0, 0, obj.TYPES.DOWNRIGHT
			.db 32, 96, 2, obj.TYPES.BOUNCE
			.db 110, 0, 0, obj.TYPES.SPIKE_UL
			.db 140, 68, 1, obj.TYPES.NORMAL
		.5_4:
			.db 40
			.db 140, 88, 1, obj.TYPES.SHOCK
			.db 52, 50, 1, obj.TYPES.BOUNCE
			.db 140, 50, 1, obj.TYPES.BOUNCE
			.db 52, 50, 1, obj.TYPES.BOUNCE
			.db 140, 50, 1, obj.TYPES.SHOCK
	.6:
		.db (.6_addrsend - .6_addrs) / 2
		.6_addrs:
			.dw .6_1, .6_2, .6_3
		.6_addrsend:
		.6_1:
			.db 70
			.db 160, 132, 0, obj.TYPES.THORN_L
			.db 168, 48, 6, obj.TYPES.NORMAL
			.db 29+8, 0, 0, obj.TYPES.THORN_R_UR
			.db 29, 0, 0, obj.TYPES.UPRIGHT
			.db 29+8, 255, 0, obj.TYPES.THORN_R_DR
			.db 29, 0, 0, obj.TYPES.DOWNRIGHT
		.6_2:
			.db 60
			.db 60, 190, 0, obj.TYPES.THORN_R_DR
			.db 52, 0, 0, obj.TYPES.DOWNRIGHT
			.db 100, 88, 0, obj.TYPES.CRUMBLE0
			.db 60, 88, 0, obj.TYPES.THORN_R_UR
			.db 52, 0, 0, obj.TYPES.UPRIGHT
			.db 160, 160, 0, obj.TYPES.CRUMBLE0
		.6_3:
			.db 20
			.db 220, 88, 0, obj.TYPES.THORN_R
			.db 212, 0, 0, obj.TYPES.NORMAL
			.db 130, 12, 0, obj.TYPES.THORN_R
			.db 122, 0, 0, obj.TYPES.NORMAL
			.db 40, 12, 0, obj.TYPES.THORN_R
			.db 32, 0, 0, obj.TYPES.NORMAL
	.7:
		.db (.7_addrsend - .7_addrs) / 2
		.7_addrs:
			.dw .7_1, .7_2, .7_3, .7_4
		.7_addrsend:
		.7_1:
			.db 10
			.db 16, 80, 0, obj.TYPES.SPIKE_UR
			.db 182, 40, 2, obj.TYPES.NORMAL
			.db 64, 100, 2, obj.TYPES.NORMAL
			.db 16, 40, 0, obj.TYPES.SPIKE_R
			.db 64, 72, 2, obj.TYPES.NORMAL
			.db 160, 118, 4, obj.TYPES.NORMAL
			.db 16, 0, 0, obj.TYPES.SPIKE_DR
		.7_2:
			.db 60
			.db 128, 88, 0, obj.TYPES.BOUNCE
			.db 64, 88, 0, obj.TYPES.BOUNCE
			.db 160, 88, 0, obj.TYPES.BOUNCE
			.db 90, 88, 0, obj.TYPES.BOUNCE
			.db 24, 88, 0, obj.TYPES.BOUNCE
			.db 96, 88, 0, obj.TYPES.BOUNCE
			.db 160, 88, 0, obj.TYPES.BOUNCE
		.7_3:
			.db 60
			.db 148, 88, 1, obj.TYPES.NORMAL
			.db 52, 64, 1, obj.TYPES.BOUNCE
			.db 148, 64, 1, obj.TYPES.NORMAL
			.db 52, 0, 0, obj.TYPES.SPIKE_DR
			.db 52, 64, 1, obj.TYPES.BOUNCE
			.db 148, 64, 1, obj.TYPES.NORMAL
			.db 52, 0, 0, obj.TYPES.SPIKE_DR
		.7_4:
			.db 48
			.db 60, 88, 0, obj.TYPES.UP
			.db 116, 96, 0, obj.TYPES.THORN
			.db 190, 96, 0, obj.TYPES.DOWN
			.db 116, 20, 0, obj.TYPES.THORN
			.db 60, 20, 0, obj.TYPES.UP
			.db 116, 106, 0, obj.TYPES.THORN
			.db 124, 38, 0, obj.TYPES.BOUNCE
	.8:
		.db (.8_addrsend - .8_addrs) / 2
		.8_addrs:
			.dw .8_1, .8_2, .8_3
		.8_addrsend:
		.8_1:
			.db 20
			.db 160, 112, 2, obj.TYPES.SPDUP
			.db 152, 24, 0, obj.TYPES.THORN_TOP
			.db 90, 80, 0, obj.TYPES.THORN_L_FLIP
			.db 98, 8, 1, obj.TYPES.FLIP
			.db 20, 180, 12, obj.TYPES.SPDUP
			.db 106, 0, 0, obj.TYPES.THORN_R_FLIP
			.db 98, 8, 1, obj.TYPES.FLIP
			.db 12, 16, 0, obj.TYPES.THORN_TOP
		.8_2:
			.db 80
			.db 60, 88, 0, obj.TYPES.THORN_R
			.db 52, 0, 0, obj.TYPES.NORMAL
			.db 150, 69, 0, obj.TYPES.BOUNCE
			.db 60, 70, 0, obj.TYPES.THORN_R_FLIP
			.db 52, 8, 1, obj.TYPES.FLIP
			.db 150, 60, 0, obj.TYPES.NORMAL
			.db 68, 24, 0, obj.TYPES.THORN_R
			.db 60, 0, 0, obj.TYPES.NORMAL
		.8_3:
			.db 50
			.db 52, 152, 4, obj.TYPES.SPDUP
			.db 44, 24, 0, obj.TYPES.THORN_TOP
			.db 152, 100, 4, obj.TYPES.SPDUP
			.db 144, 24, 0, obj.TYPES.THORN_TOP
			.db 52, 100, 4, obj.TYPES.SPDUP
			.db 44, 24, 0, obj.TYPES.THORN_TOP
			.db 152, 100, 4, obj.TYPES.SPDUP
			.db 144, 24, 0, obj.TYPES.THORN_TOP