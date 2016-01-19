;
;
;  merge plusieur effet  VERSION 1
; start 1 juin 2015
;
;todolist:
;	raster sur les point
;	effacement dans cerc6b par des move specifique et non un cls
;	faire les sinus dot et l'inclure
; 	faire la gestion memoire, liberer de la memoire
;	inclure 2 ou 3 pic


STANDALONE	equ 0
enablesound	equ 1

mymerge:
	*move.l sp,oldsp
	move.l 4(sp),a0
	move.l 12(a0),d0	code
	add.l 20(a0),d0		data
	add.l 28(a0),d0		bss
	;add.l #256+4096,d0		; 300 de pile
	;addq.l #1,d0
	;bclr #0,d0	; even
	;lea (a0,d0),sp		

	move.l d0,-(sp)
	move.l a0,-(sp)
	clr.w -(sp)
	move.w #$4a,-(sp)		mshrink
	trap #1
	lea 12(sp),sp
	tst.l d0
	beq.s .itsok
	jmp finfinfin
.itsok	
	

	jmp MERGESTART
; divers lib
	include 'MYMEM.S'
	include 'CERC6B.S'
	include '2PIXGL3.S'
	include 'SINLIB2.S'
	TEXT	

;_2PIX:
;	include '2PIXGL3.S'
;_CIRCLE:
;	include 'CERC6.S'		; cerc7 ?
;_6SINUSDOT:
;	include '??'
;_RUBAN:
;

mutevbl	macro
	move.w #$2700,sr
	move.l #vblidl,$70.w
	move.w #$2300,sr
	endm

TEMPS_EFFET	equ 450
MERGESTART
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	*move.l d0,oldsp
	
	jsr wvbl

	move.b $ffff8260.w,oldresol

	move.w #0,-(sp)
	move.l $44e.w,d0
	move.l d0,-(sp)
	move.l d0,-(sp)
	move.w #5,-(sp)		;setscren
	trap #14
	lea 12(sp),sp
	

	jsr initmemall
	movem.l $ffff8240.w,d0-d7
	movem.l d0-d7,oldpalette
* ici on declare n ecran sur une limite de 64k
* et on va ajouter chaque 32k a une liste de bloc ram dispo
	*jmp .toptoto
	move.l #65536*2+65536,d0	; 4 ecran sur une limite 64k max
	jsr getMem	; retour a0 = adresse
	move.l a0,d1
	add.l #65535,d1
	clr.w d1
	; d1 = adresse boundary64k
	;move.l d1,-(sp)
	move.l d1,ecranram1
	move.l #65536,d2
	add.l d2,d1
	move.l d1,ecranram2
	add.l d2,d1
	move.l d1,ecranram3
	add.l d2,d1
	move.l d1,ecranram4	ecranramx est l'adresse en memoire de l'ecran y compris la partie pour le cliping
	;move.l (sp)+,d1
	move.l #32000+160*8,d2   160*8=1280 octet  33280 octet= ecran +8 ligne de clip
	move.l #65536,d3	;32000+1536-160*8,d3
	; d1 = ecranram1
	move.l ecranram1,d1
	add.l d2,d1
	move.l d1,d0
	jsr addzoneram32256	; d0=adresse juste apres ecran1
	add.l d3,d0
	jsr addzoneram32256	; ecran2
	add.l d3,d0	
	jsr addzoneram32256	; ecran3
	add.l d3,d0		; adresse apres ecran4: fait partie de la memoire
	jsr addzoneram32256	; apres ecran4	; plus facile a gerer pour l'instant

	jsr setnewbasemem


.toptoto:
	move.l ecranram1,d0
	move.l d0,ecran1
	move.l ecranram2,d0
	move.l d0,ecran2
	move.l ecranram3,d0
	move.l d0,ecran3
	move.l ecranram4,d0
	move.l d0,ecran4

	move.l #listeworkscr1,d0
	move.l d0,whatlistscreen
	moveq #0,d0
	move.w d0,numeroworkscr

	ifne enablesound
	jsr SOUND
	endc

	*jsr CERC6_depart
	jsr pixbender2bitstart
	lea palet1,a0
	movem.l (a0),d0-d7
	movem.l d0-d7,$ffff8240.w	
	jsr wvbl
	move.l #main_2pixgl_,d0
	jsr modifroutvbl
	move.L #300,d0
	jsr start_to_countvbl
	move.w #$2700,sr
	move.l $70.w,oldvbl
	move.l #itvbl,$70.w
	move.w #$2300,sr
	
	move.l #exitALL0,d0
	jsr set_adr_exit	

	jsr CERC6_depart
;	move.w #$750,$ffff8240.w
;	move.w #100,d0
;	;jsr start_to_countvbl

mainloop:
			;	jsr main_2pixgl3
	jsr wvbl
	cmp.w #1,EXIT_STATUS
	bne.s mainloop
	; ici on quite l'effet mais pas forcement la demo
	move.w #0,EXIT_STATUS
	cmp.w #1,exitdemostatus
	beq.s exitALL0
	
	; ici on passe a l'effet suivant	
	bra.s exit0
twicefx:
	move.l workscr,d0
	move.l d0,logscr
	jsr effacebande
	add.l #32+2,workscr
	jsr CIRCLE_main
	sub.l #32+2,workscr 
	jsr main_2pixgl3
	;not $ffff8240.w
	;not $ffff8240.w
	rts
main_2pixgl_:
	move.l workscr,logscr
	jsr effacebande
	jsr main_2pixgl3
	rts
exitALL0:
	mutevbl
	jsr exit_2pixgl3
	bra.s exitALL
exit0
	jsr wvbl
	move.w #0,EXIT_STATUS
	move.l #twicefx,d0		;move.l #CIRCLE_main,d0
	jsr modifroutvbl
	move.L #200800,d0
	jsr start_to_countvbl
;	move.w #$2700,sr
;	move.l #myvbl2,$70.w
;	move.w #TEMPS_EFFET,compteurVBL
;	move.w #$2300,sr
	*jsr exit_2pixgl3

	
	*jsr CERC6_depart
	;move.w #TEMPS_EFFET,compteurVBL
mainb	*jsr CIRCLE_main

	jsr wvbl
	cmp.w #1,EXIT_STATUS
	bne.s mainb
.exit	
	*mutevbl
exitALL:
	mutevbl
	ifne ENABLESOUND
	jsr SOUND+4
	endc
	*jsr exit_2pixgl3
	jsr wvbl
	move.w #$2700,sr
	move.l oldvbl,$70.w
	move.w #$2300,sr
	move.l $44e.w,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w

	movem.l oldpalette,d0-d7
	movem.l d0-d7,$ffff8240.w

	;jsr wvbl
	;move.b #1,$ffff8260.w
	;jsr wvbl


	moveq #0,d1
	move.b oldresol,d1
	move.w d1,-(sp)
	move.l $44e.w,d0
	move.l d0,-(sp)
	move.l d0,-(sp)
	move.w #5,-(sp)		;setscren
	trap #14
	lea 12(sp),sp


	
	*move.l oldsp,sp
	


	move.w #$4c,-(sp)
	clr.w -(sp)
	trap #1

iaminvbl	dc.w 0
vbl_loss	dc.w 0
seuilvbl	dc.l 0		; a metre en bss

itvbl:
	tst.w iaminvbl
	beq.s .1
	addq.w #1,vbl_loss	indique qu'on a louper un coche
;	move.w d0,-(sp)
;	move.w vbl_loss,d0
;	cmp.w #2,d0
;	beq.s .urgence
	rte		; au cas ou ca depasse la vbl on fait pas des itvbl dans des itvbl
;.urgence:	move.w #$4e75,itvbl
;	rte
.1
	move.w #1,iaminvbl	: on declare qu'on est dans la vbl
	addq.l #1,$466.w
	movem.l d0-d7/a0-a6,-(sp)
	ifne enablesound
	jsr SOUND+8
	endc
; sequenceur: on doit tester a quel moment on est
	move.l $466.w,d0
	move.l seuilvbl,d1
	cmp.l d0,d1
	blt.s idlevbl   on repasse a une routine dummy histoire de pas avoir de probleme pour la transition d'un effet a lautre
	cmp.b #$39,$fffffc02.w
	beq.s quitdemo
	jsr getworkscr
automodifroutinevbl:
	jsr $12345678	adresse de la routine de l'effet graphique

	
	movem.l (sp)+,d0-d7/a0-a6
	move.w #0,iaminvbl
	rte
exitdemostatus	dc.w 0
EXIT_STATUS	dc.w 0
quitdemo move.w #1,exitdemostatus
idlevbl:
	move.l #dummyrout,d0
	move.l d0,automodifroutinevbl+2
	move.w #1,EXIT_STATUS		; status de sortie de l'effet
	move.w #0,iaminvbl
	movem.l (sp)+,d0-d7/a0-a6
	rte

start_to_countvbl:		; d0 = nombre de vbl a attendre
	add.l $466.w,d0
	move.l d0,seuilvbl
	rts

modifroutvbl:
	move.l d0,automodifroutinevbl+2
	rts

; deprecated
vblidl:
	addq.l #1,$466.w
	rte	
; fin deprecated

test_exit_demo:
; dans les routines de calcul qui prenne plusieurs vbl,
; l'appel de cette routine check si on veut quitter la demo
; et dans ce cas retabli la pile ou il faut et jmp direct
; a une adresse mis dans une variable prealable (idem pour le sp d'exit)
; c'est l'adresse ou aller au cas ou on appui sur space par exemple
; cette routine ne doit pas etre appeler dans l'it vbl   
; sr doit etre = a 2300 en gros
	cmp.w #1,exitdemostatus
	bne.s .1
; ici on doit interompre la routine courante
	move.w #$2700,sr		; on change le sp, on doit etre en 2700 dans le sr
	move.l whereismysp,a7
	move.l whereismyexitadr,a2
	move.w #$2300,sr
	jmp (a2)
.1	;not $ffff8240.w		; pour voir si la frequence des test est correct
	;nop
	;nop
	;nop
	;nop
	;not $ffff8240.w
	rts
set_adr_exit:
	; d0=adresse d'exit
	move.l sp,d1
	addq.l #4,d1	; le jsr a placer 4 octet = adresse de retour
	move.l d1,whereismysp
	move.l d0,whereismyexitadr
	rts


finfinfin
	move.w #1,-(sp)
	move.l $44e.w,d0
	move.l d0,-(sp)
	move.l d0,-(sp)
	move.w #5,-(sp)		;setscren
	trap #14
	lea 12(sp),sp


	clr.w -(sp)
	move.w #$4c,-(sp)
	trap #1
	DATA
listeworkscr1
	dc.l ecran1
	dc.l ecran2
	dc.l -1
listeworkscr2
	dc.l ecran3
	dc.l ecran4
	dc.l -1
listeworkscr3
	dc.l ecran1,ecran2,ecran3,ecran4
	dc.l -1


	BSS
ecran1	ds.l 1	; adresse constante
ecran2	ds.l 1
ecran3	ds.l 1
ecran4	ds.l 1
ecranram1	ds.l 1
ecranram2	ds.l 1
ecranram3	ds.l 1
ecranram4	ds.l 1

workscr	ds.l 1		; (ecran1 a ecran4)= adresse ram ecran ou l'effet travaille
numeroworkscr: ds.w 1	; numero dans la sequence listeworkscrX
whatlistscreen	ds.l 1  ; = listeworkscrX
	TEXT
getworkscr:
	move.w numeroworkscr,d0
	move.l whatlistscreen,a1
	add d0,d0
	add d0,d0
	move.l (a1,d0),a2	; ptr ecranN
	move.l (a2),d1
	move.l d1,workscr
	lsr.w #8,d1
	move.l d1,$ffff8200.w
	addq.l #4,d0
	tst.l (a1,d0)
	bpl.s .itsok
	moveq #0,d0
.itsok
	move.l (a1,d0),a2
	move.l (a2),d1
	lsr #2,d0
	move.w d0,numeroworkscr
	*lsr.w #8,d1
	*move.l d1,$ffff8200.w	; l'ecran suivant sera le futur ecran physique
				; a tester
	rts

	DATA
	dc.w 0,1,3,2
palet1	dc.w $124,$337,$677,$457,$777,$777,$777,$777
	;dc.w $124,$773,$776,$754,$777,$777,$777,$777
	dcb.w 8,$727	

	even
SOUND	incbin "POURGLKY.SND"


	BSS
oldresol ds.b 1
	even
*oldsp	ds.l 1
oldvbl	ds.l 1
oldpalette	ds.l 8
compteurvbl	ds.w 1
whereismysp:	ds.l 1
whereismyexitadr:	ds.l 1

