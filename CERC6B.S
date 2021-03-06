;
;	circles of dots
;	code by gloky / mjj prod
;   
;
;

	TEXT
*standalone EQU 1		; cette ligne en rem: source utilis� dans un merge de plusieur effet
				; cette ligne activ�: le source fonctionne en standalone
blitter_cls	equ 0 1		; =0 pas de blitter cls pure 68k
tmachinecerc	equ 0 1

CONFIG	equ 1
	ifeq CONFIG
NBDOTPERCIRCLE	equ 32
NB_POSDOTPERCIRCLE	equ 32*8
NBCIRCLES	equ 90
RAYON_START	equ 6
RAYONMIN	equ RAYON_START
ANGLEWRAP	equ 8			; combien de version du cercle pour angle
	endc

	ifeq (CONFIG-1)
NBDOTPERCIRCLE	equ 53
NB_POSDOTPERCIRCLE	equ 32*16
NBCIRCLES	equ 15
RAYON_START	equ 30
STEP_RAYON	equ 4
RAYONMIN	equ RAYON_START
ANGLEWRAP	equ 16			; combien de version du cercle pour angle
	endc


*STANDALONE	equ 1
CERC6_depart

	ifne STANDALONE
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	ENDC

	
	ifne standalone
	lea ptrscr,a0
	move.l #screen+256,d0
	clr.b d0
	move.l d0,(a0)+
	add.l #32000,d0
	move.l d0,(a0)
	endc
	ifeq standalone
	move.l workscr,d0
	move.l d0,ptrscr
	endc
	
	ifne standalone
	jsr initmemall
	endc
	move.l #truc,d0
	jsr getMem
	move.l a0,d0
	move.l d0,basebss

	jsr wvbl
	move.b #0,$ffff8260.w

	ifne standalone
	move.l ptrscr,a0
	moveq.l #0,d0
	move.w #7999,d1
cls	move.l d0,(a0)+
	move.l d0,(a0)+
	dbf d1,cls	
	endc
	jsr initsomething
	

	jsr initWaves	; doit etre lancé apres initsomething

	ifne standalone
	move.w #$135,$ffff8240.w
	move.w #$777,$ffff8242.w 
	endc	

	ifne blitter_cls
	jsr gloky_blitter_clear_init
	endc

	move.w #100,d0
.clearpos:
	move.w d0,-(sp)
	jsr calcSpot
	move.w (sp)+,d0
	dbf d0,.clearpos

	ifeq STANDALONE
	rts
	endc

CIRCLE_main


	
;	ifeq standalone
;	move.w #$135,$ffff8240.w
;	move.w #$777,$ffff8242.w 
;
;	endc
	cmp.b #$b9,$fffffc02.w
	beq.w .fin
	
	ifne standalone
	move.l ptrscr,a0
	endc
	ifeq standalone
	move.l workscr,a0
	endc
	ifne blitter_cls
	jsr gloky_blitter_clear
	endc
	ifeq blitter_cls
	jsr clear_circle
	endc
	*move.w #$11,$ffff8240.w
	
	jsr calcwave

	*not.w $ffff8240.w
	
	ifne standalone
	move.l ptrscr,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w

	move.l ptrscr,d0
	move.l ptrscr+4,d1
	move.l d1,ptrscr
	move.l d0,ptrscr+4
	endc

	;not $ffff8240.w
	;not $ffff8240.w
	ifne tmachinecerc 
	eor.w #$157,$ffff8240.w
	endc


	ifne STANDALONE

	jsr wvbl
	endc

	ifne tmachinecerc 
	eor.w #$157,$ffff8240.w
	endc

	IFNE STANDALONE
	bra CIRCLE_main
	ENDC
.fin
	ifeq STANDALONE
	rts
	endc
	
	move.l $44e.w,d0
	lsr.w #8,d0
	move.l d0,$ffff8200.w

	move.w #$777,$ffff8240.w
	move.b #1,$ffff8260.w

	clr.w -(sp)
	trap #1
	
wvbl:	move.l $466.w,d0
.loop	cmp.l $466.w,d0
		beq.s .loop
		rts

	ifne blitter_cls
gloky_blitter_clear:
; a0: @ ecran destination 
;-----------------------------------------------------------------------------
	;move.l	a1,-(sp)
        lea     $ff8a00,a1              ; blitter address
        move.l  a0,$32(a1)              ; dest address
        move.w  #200,$38(a1)               ; nbre of lines
        move.b  #%11000000,$3c(a1)      ; start blit (HOG mode)
	;move.l	(sp)+,a1
 	rts
	
	endc

init_generatedCode
*;_mkconvx
*	lea convX,a0
*	moveq #0,d1
*	move.w #$0200,d2	+0200= or.b d1,dep(a0) puis or.b d2,dep(a0), etc..
*
*.0	move #$8128,d0
*.1	
*	move.w d0,(a0)+
*	move.w d1,(a0)+
*	add d2,d0
*	cmp.w #$8128+8*$200,d0
*	bne.s .1
*	
*	addq #1,d1
*	move.w #$8128,d0
*.2	
*	move.w d0,(a0)+
*	move.w d1,(a0)+
*	
*	add d2,d0
*	cmp.w #$8128+8*$200,d0
*	bne.s .2
*	addq #7,d1
*	
*	cmp.w #8*20,d1
*	bne.s .0
;*_mkconvx fin
	
	move.l basebss,a0
	add.l #convx,a0
	moveq #0,d0
	move.w #19,d1
	moveq #0,d2
.0
	move.w d0,(a0)+
	addq #2,d0
	move.w d2,(a0)+		; offset
	cmp.w #32,d0
	bne.s .0
	addq #8,d2		; offset +16 pixel
	moveq #0,d0
	dbf d1,.0

	move.l basebss,d1
	lea lstptrcode,a3
	add.l d1,a3
	lea bsscode,a1
	add.l d1,a1
	lea convX,a2
	add.l d1,a2
	lea lstorcount,a4
	add.l d1,a4
	lea lstor0,a5
	add.l d1,a5
	 			

	moveq #NBCIRCLES-1,d7
.looptaille:
	
	move.w d7,d6
	add d7,d6
	add d7,d6
	add #RAYON_START,d6		; =1, 
	;add d7,d6
	add d6,d6			; d6=64*2 au depart
	
	move.w #ANGLEWRAP-1,d5		; 8-1
	lea circletable,a0
	
.loopAngle:
	ifeq STANDALONE
	jsr test_exit_demo
	endc
	move.w d5,-(sp)
	
	;move.l a1,(a3)+


	
	move.l basebss,d0
	lea lstorcount,a4
	add.l d0,a4
	moveq #0,d0
	rept 8
	move.l d0,(a4)+
	endr		; effacer les 16 compteurs
	*lea lstorcount,a4
	lea -8*4(a4),a4
	move.l basebss,d0
	lea lstor0,a5
	add.l d0,a5
	moveq #0,d0
	move.w #NBDOTPERCIRCLE-1,d5		; 32-1 calcul d'un cercle de 32 dot
.loopCircle
	ifeq STANDALONE
	jsr test_exit_demo
	endc
	move.w (a0)+,d0		; x
	move.w (a0)+,d1		; y
	ext.l d0
	ext.l d1
	
	muls d6,d0
	muls d6,d1
	swap d0
	swap d1
	;add.w #96-48,d0		; + centre
	
	lsr #1,d6
	add d6,d0
	add d6,d1
	add d6,d6
	;add.w #96,d0
	;add.w #96,d1

	;move.w d6,d3		
	;lsr #2,d3
	;add d3,d0

	; now a partir de d2 et d3 on creer un or.b dn,dep(a0)
	; a2 = convX 1 pixel (pas de subpixel)
	; d0 = x
	move.w d0,d3
	add d3,d3
	add d3,d3
	move.w (a2,d3),-(sp)		; numero de bit*2
	move.w 2(a2,d3),d4	; offset x

	; calcul de l'offset adequat: int(d2/16)*8+d3*160
	
	; mulu #160,d1
	lsl #5,d1  *32
	move.w d1,d3
	; * 128 + *32
	;lsl #2,d3  *128;
	add d3,d3
	add d3,d3
	add d3,d1  *160
	
	add d1,d4		; d4 = offsetx+y

;	move.l d4,(a1)+
	
	;a4 = lstorcount
	;a5 = lstor0

	move.w (sp)+,d1			; numero de bit*2

	move.w (a4,d1),d3		; count lstX	(*2)
	move.w d1,d0
	lsl #5,d0
	lea (a5,d0),a6		; a6=lstX
	add d3,a6			; + countlstx

	move.w d4,(a6)		; lstX+count*2=offsettotal
	addq #2,d3
	move.w d3,(a4,d1)
	
	dbra d5,.loopCircle

;******	now on a 16 liste d'offsets	; on genere les 16 routine qui affiche le cercle
	; a4 = count lstX
	; a5 = lst0
;	

	;lea whereIScode,a6
	move.l basebss,d5
	lea lstorcount+32,a4
	add.l d5,a4
	move.w #15,d5		; 16 decalage/routine
	move.l a1,a6
.loopcgmake1
	move.l a1,(a3)+		; a3  = lstptrroutine
	*move.l a6,(a3)+
	move.l basebss,d0
	lea lstor0,a5
	add.l d0,a5
	moveq #0,d0
	move d5,d0
	ext.l d0		; a voir si faut enlever
	lsl #6,d0		; *64
	add d0,a5			; a5 = lstF puis lstE etc  // deprecated: puis lst1 puis lst2 etc
	move.w -(a4),d4			; d4 = countX	
	bne.s .dot
; nodot:
	** a a modifier ici
;	move.l #routinevide,-4(a3)
	bra.s .nodot
.dot
	lsr #1,d4
	subq #1,d4
.bcl
	move.w #$8168,(a1)+			; or.w d0,$1234(a0)
	move.w (a5)+,(a1)+
	dbf d4,.bcl
.nodot
	;move.w #RTS,(a1)+
	move.w #$D040,(a1)+			; add d0,d0 pour prochain points

	dbf d5,.loopcgmake1
	move.w #$4e75,(a1)+
; ***

;********	
	move.w (sp)+,d5
	dbra d5,.loopAngle
	ifeq STANDALONE
	jsr test_exit_demo
	endc	
	dbra d7,.looptaille

routinevide	rts
	
initOneWave
; d0 = rayon
; d1 = pas interne
	lea sinwave,a0
	move.l basebss,d4
	lea buffer1,a1
	add.l d4,a1
	
	move.w #511,d7
		
	move.w d0,d2
	add d2,d2
	
.loop
	move.w (a0)+,d4
	muls d2,d4
	swap d4
	add d0,d4
	add d4,d4
	add d4,d4
	move.w d4,(a1)+
	dbf d7,.loop
	
	move.l basebss,d7
	lea buffer1,a0
	add.l d7,a0
	move.l a6,a1			; reftablesinus
	move.w d1,d0			; pas interne
	move.w #NBCIRCLES,d1	; NBCIRCLES=96
	move.w #512,d2
	bsr createSpecialSin
	
	rts
	
initWaves
		move.w #150,d0
		*move.w #512-17,d1
		move.l basebss,d1	a6
		LEA memoire,a2
		add.l d1,a2
		lea refs1,a6
		add.l d1,a6
		move.w #512-17,d1
		bsr initOneWave
	
		move.w #100,d0
		*move.w #2,d1
		move.l basebss,d1
		lea refs2,a6
		add.l d1,a6
		moveq #2,d1
		bsr initOneWave
		
		move.w #83,d0
		*move.w #512-2,d1
		move.l basebss,d1
		lea refs3,a6
		add.l d1,a6
		move.w #512-2,d1
		bsr initOneWave

		move.w #224,d0
		*move.w #4,d1
		move.l basebss,d1
		lea refs4,a6
		add.l d1,a6
		moveq #4,d1
		bsr initOneWave


		
		rts
	
calcwave
		move.l basebss,d7
		lea refs1,a6
		add.l d7,a6
		move.w curangle1,d0
		add d0,d0
		add d0,d0
		move.l (a6,d0),a0
		
		lea refs2,a6
		add.l d7,a6
		move.w curangle2,d0
		add d0,d0
		add d0,d0
		move.l (a6,d0),a1
		
		lea refs3,a6
		add.l d7,a6
		move.w curangle3,d0
		add d0,d0
		add d0,d0
		move.l (a6,d0),a2

		lea refs4,a6
		add.l d7,a6
		move.w curangle4,d0
		add d0,d0
		add d0,d0
		move.l (a6,d0),a3


		
		;lea result,a6

		lea calcsinbuffer,a5		; buffer de 96 word
		add.l d7,a5

		move.w #NBCIRCLES-1,d7		; 96-1
		ifeq (ANGLEWRAP-8)
		move.w #%000000111000000,d6
		endc
		ifeq (ANGLEWRAP-16)
		move.w #%000001111000000,d6
		endc

.loooop
		move.w (a0)+,d0
		add (a1)+,d0
		add (a2)+,d0
		add (a3)+,d0
	*	lsr #3,d0
	*	and #%0000000000011100,d0
		; d0 =angle*2 , 
	*	lsl #5,d0	; *32			; angle*32 long

		;add d0,d0
		;add d0,d0
		and d6,d0

		move.w d0,(a5)+
		dbf d7,.loooop
		
		*lea (a5,d0),a4
		*move.l (a4)+,(a6)+		; adresse appel			; A MODIF
		*move.l (a4)+,(a6)+		; adresse ou il faut placer le rts
		
		*lea 32*4(a5),a5	; passer au cercle suivant
		*dbf d7,.loooop
	
		; now dans calcsinbuffer on a 96 valeur correspondant au sinus
		
		jsr calcSpot		; calcul de spot+scroll+realposition
				
		*move.w #NBCIRCLES-1,d7	;96-1
		move.l basebss,d7
		lea realposition,a6
		lea calcsinbuffer,a5
		lea lstptrcode,a4
		add.l d7,a6
		add.l d7,a5
		add.l d7,a4
		moveq #0,d7
		move.w #NBCIRCLES-1,d7
			
		move.w #$4e75,d6
		;move.w #$8168,d5 la plupart du temps c'est 8168 sinon c'est un rts
		
.loooop2
		move.w (a5)+,d0		; angle*16*4
		lea (a4,d0),a2		; a2 = lstptrcode[cercle+angle]
		
		move.l (a6)+,a0		; adresse ecran resultat fonction
		;lea 8(a0),a1
		move.l (a2),a3
		add.w (a6)+,a2		; decalage*8
		                          ;add d1,a2
		move.l (a2),a2		; adresse routine
		moveq #1,d0
		jsr (a2)

		addq.l #8,a0
		move.w (a2),d5
		move.w d6,(a2)		; d6=rts
		jsr (a3)
		move.w d5,(a2)
		;move.w d5,-4(a2)		; d5=add d0,d0
	
		; changement de cercle
		lea 4*16*ANGLEWRAP(a4),a4		*8
		
		dbf d7,.loooop2
		
		
		move.w curangle1,d0
		add #15,d0
		and #511,d0
		move.w d0,curangle1
		
		move.w curangle2,d0
		add #512-9,d0
		and #511,d0
		move.w d0,curangle2
		
		move.w curangle3,d0
		add #3,d0
		and #511,d0
		move.w d0,curangle3

		move.w curangle4,d0
		add #2,d0
		and #511,d0
		move.w d0,curangle4
		
		rts
		
prepareScaleTable
	*lea superScaleTable,a0			; buffer de 200 word *96
	move.l basebss,d7
	lea superScaleTable,a0
	add.l d7,a0
	moveq #0,d7
	move.w #NBCIRCLES-1,d7
.loop0

	move.w d7,d2
	add.w d7,d2			; ici 
	add d7,d2
	add #RAYONMIN,d2
	 ;move.w #96,d2
	 ;sub d7,d2	; taille du cercle correspondant
	 ;sub #1,d2
	add d2,d2
	move.w #200,d3
	sub d2,d3	; 199-taille du cercle = nb de pixel max
	
	; scale[100] doit placer le cercle au milieu
	; d2 = taille du cercle
	; en 100,   placer en 100-d2/2
	; en 0 placer en 0
	; en 200    placer en 200-d2
	; donc de 0 a 200 = 0 a 200-d2
	; il faut ajouter a chaque fois (200-d2)/200  = d3/200
	
	moveq #0,d4
	move.w d3,d4
	swap d4				d3*65536
	divu #200,d4		;/200
	swap d4
	clr.w d4
	swap d4
	
	
	move.w #199,d1
	moveq #0,d6
	moveq #0,d5
.oneTable:
	move.w d5,(a0)+
	add.l d4,d6
	swap d6
	move.w d6,d5
	swap d6
	add d5,d5
	
	dbf.w d1,.oneTable
	dbf.w d7,.loop0
	rts

initsomething
	move.l basebss,d0
	lea posSpot,a0
	add.l d0,a0
	move.w #100*2,d0
	move.w #100*2,d1
	move.w #NBCIRCLES-1,d7
.bcl
	move.w d0,(a0)+
	move.w d1,(a0)+
	dbf d7,.bcl
	 
	jsr prepareScaleTable
	jsr init_generatedCode
	
	move.l basebss,d0
	lea convX2,a0
	add.l d0,a0
	moveq #0,d0
	moveq #19,d7
	moveq #0,d1
.loop
	move.w d0,(a0)+			; decalage
	move.w d1,(a0)+			; offset
	add.w #4,d0				; decalage*8
	cmp.w #16*4,d0
	bne.s .loop
	moveq #0,d0
	add.w #8,d1
	dbf d7,.loop
	
	move.l basebss,d7
	lea convY,a0
	add.l d7,a0
	move.w #0,d0
	move.w #160,d1
	moveq #0,d7
	move.w #199,d7
.loop2
	move.w d0,(a0)+
	add d1,d0
	dbf d7,.loop2
	
	
	rts


calcSpot:
	bsr scroll_posSpot		; positione a2 a la fin du posSpot

	lea cosinusSpot,a0
	lea sinusSpot,a1

	move.w cspot,d0		; angle cosinus spot
	addq.w #1,d0
	and.w #511,d0
	move.w d0,cspot
	add d0,d0			; angle*2
	move.w (a0,d0),d1	; d1 = (100+100*cos(angle))*2
	
	move.w sspot,d0
	addq.w #3,d0
	and.w #511,d0
	move.w d0,sspot
	add d0,d0
	move.w (a1,d0),d2	; d2 = 100+100*sin(angle)

	lea cosinusSpot,a0
	move.w cspot+2,d0		; angle cosinus spot
	add.w #512-2,d0
	and.w #511,d0
	move.w d0,cspot+2
	add d0,d0			; angle*2
	add.w (a0,d0),d1	; d1 = (100+100*cos(angle))*2
	
	move.w sspot+2,d0
	addq.w #1,d0
	and.w #511,d0
	move.w d0,sspot+2
	add d0,d0
	add.w (a1,d0),d2	; d2 = 100+100*sin(angle)
	
	lsr #1,d1
	lsr #1,d2
	and.w #$FFFE,d1
	and.w #$FFFE,d2

	;lea posSpot,a0
	move.w d1,(a2)+
	move.w d2,(a2)+

; *********
; conversion de posSpot a realposition: 
; ********
	move.l basebss,d7
	lea superScaleTable,a0			; buffer de 200 word *96
	lea posSpot,a1
	lea realposition,a2			; buffer: offset,decalage
	lea convX2,a3
	lea convY,a4
	add.l d7,a4
	add.l d7,a3
	add.l d7,a2
	add.l d7,a1
	add.l d7,a0
	ifne standalone
	move.l ptrscr,a5			; ecran courant
	endc
	ifeq standalone
	move.l workscr,a5
	endc
	moveq #0,d7
	move.w #NBCIRCLES-1,d7		
.bcl
	move.w (a1)+,d0				; premiere coord , cercle de rayon 1
	;add d0,d0
	move.w (a0,d0),d2			; superScaleTable[d0]
	add d2,d2
	move.l (a3,d2),d3			; d3 = decalage,offsetX
	
	move.w (a1)+,d1				; y
	;add d1,d1
	move.w (a0,d1),d4			; superscaleTable[d1]
	add.w (a4,d4),d3			; d3= decalage,offsetX+offsetY
	lea (a5,d3.w),a6
	move.l a6,(a2)+				; adresse ecran+offset
	swap d3
	move.w d3,(a2)+
	
	lea 400(a0),a0			; passage au 'scaleur' suivant


	dbf d7,.bcl

	; now realposition = liste de 96 (adresse ecran, decalage)
	rts

scroll_posSpot:
;	lea posSpot+96*4,a0
;	lea -4(a0),a1
;	move.w #95,d7
;.;loop
;	move.l -(a1),d0
;	move.l d0,-(a0)
;	dbf d7,.loop

	ifeq (NBCIRCLES-96)
	
	move.l basebss,d0
	lea posSpot,a1
	add.l d0,a1
	lea 4(a1),a0
	
	rept 11						; 11*8=88
	movem.l (a0)+,d0-d7
	movem.l d0-d7,(a1)
	lea 32(a1),a1
	endr
	movem.l (a0)+,d0-d6			; 88+7= 95
	movem.l d0-d6,(a1)
	lea 32-4(a1),a2
	endc

	ifne (NBCIRCLES-96)
	
	move.l basebss,d7
	lea posSpot,a1
	add.l d7,a1
	lea 4(a1),a0
	moveq #0,d7
	move.w #NBCIRCLES-2,d7
.1
	move.l (a0)+,(a1)+
	dbf d7,.1
	move.l a1,a2

	
	endc
	rts
	
	ifne STANDALONE	
createSpecialSin
; a0 = table sinus de n element
; a1 = reftablesinus
; a2 = buffer resultat
; d0 = pas interne
; d1 = nombre de copie de valeur
; d2 = nombre n d'element de la table sinus
; retour = d1 : nombre de memoire occupé sur buffer resultat

	*move.w d2,d3
	move.l basebss,d3
	lea bufferFlag,a3
	add.l d3,a3
	move.w d2,d3
	subq #1,d3
.clrflag
	clr.b (a3)+
	dbra d3,.clrflag
	

	*move.w d2,d3	; 512 ou 1024
	*subq #1,d3		; 511  ou 1023 pour le and de l'angle

	move.l basebss,d3
	lea bufferFlag,a3
	add.l d3,a3
	move.w d2,d3
	subq #1,d3
	subq #1,d2		; 511 ou 1023 iteration
	moveq #0,d4		; angle
.loop
	tst.b (a3,d4)	; flag a 1 ?
	bne.s .flagA1
.flagA0
	move.w d4,d5
	add d5,d5
	move.w (a0,d5),(a2)
	add d5,d5
	move.l a2,(a1,d5)			; a2 referencer en reftable+angle*4
	addq.l #2,a2
	st (a3,d4)		positione flag(angle) a 1
	add d0,d4		; pas interne
	and d2,d4		; mod 512 ou 1022
	bra.s .loop
.flagA1	; copier d1 fois les valeurs suivante
	move.w d4,d5		; angle courant copier sur d5
	move.w d1,d7
	subq #1,d7
.cpy
	move.w d5,d6
	add d6,d6
	move.w (a0,d6),(a2)+
	add d0,d5	
	and d2,d5
	dbf d7,.cpy
	
	sub d0,d4
	addq #1,d4
	and d2,d4
	tst.b (a3,d4)
	bne.s .fin
	bra .flagA0
.fin
	rts
	endc
	
	ifne blitter_cls
gloky_blitter_clear_init:
;-----------------------------------------------------------------------------
    move.l      a0,-(sp)
    lea         $ff8a00,a0              ; blitter address
    move.w      #13,$36(a0)             ; (BLT_XCOUNT)
    move.w      #0,$20(a0)             ; (BLT_SRCXINC)
    move.w      #0,$22(a0)     ; (BLT_SRCYINC)
    move.w      #8,$2e(a0)             ; (BLT_DSTXINC)
    move.w      #160-((13*8)-8),$30(a0)     ; (BLT_DSTYINC)
    move.b      #$0,$3a(a0)             ; (BLT_HOP)
    move.w	#$ffff,$2a(a0)              ; mid mask
    move.w  	#$ffff,$28(a0)              ; Left end mask
    move.w  	#$ffff,$2c(a0)              ; Right end mask

    move.b  	#0,$3d(a0)         ; skew value
    move.b  	#0,$3b(a0)             ; (BLT_OP)


    move.l  	#_glk_eff,$24(a0)              ; source address

    move.l      (sp)+,a0
    rts	
_glk_eff	dc.l 0
	endc
	ifeq blitter_cls
clear_circle:
		; a0 = ecran+offset ou on doit effacer l'effet
	
	moveq #0,d0
	move.w #99,d7		; 64*2 ligne = 128 lignes
	
.loop
	move.w d0,(a0)
	move.w d0,8(a0)
	move.w d0,16(a0)
	move.w d0,24(a0)
	move.w d0,32(a0)
	move.w d0,40(a0)
	move.w d0,48(a0)
	move.w d0,56(a0)
	move.w d0,64(a0)
	move.w d0,72(a0)
	move.w d0,80(a0)
	move.w d0,88(a0)
	move.w d0,96(a0)

	move.w d0,160(a0)
	move.w d0,168(a0)
	move.w d0,176(a0)
	move.w d0,184(a0)
	move.w d0,192(a0)
	move.w d0,200(a0)
	move.w d0,208(a0)
	move.w d0,216(a0)
	move.w d0,224(a0)
	move.w d0,232(a0)
	move.w d0,240(a0)
	move.w d0,248(a0)
	move.w d0,256(a0)
	
	lea 320(a0),a0
	dbf d7,.loop
	rts

	endc
	ifne standalone
	include "MYMEM.S"	
	endc
	DATA
sinwave:	incbin 'C:\SRC\CIRCDOT\sinwave.dat'
circletable:
		ifeq CONFIG
		incbin 'cercle.dat'
		endc
		ifeq (CONFIG-1)
		incbin 'cerc512.dat'
		endc
curangle1	dc.w 0
curangle2	dc.w 2
curangle3	dc.w 10
curangle4	dc.w 100

cspot	dc.w 10
	dc.w 22
sspot	dc.w 60
	dc.w 40
cosinusSpot:	incbin 'cosinus'		; 100+100*cos(angle de 0 a 511)
sinusSpot:	incbin 'sinus'

	BSS
basebss	ds.l 1
ptrscr	ds.l 2
	ifne standalone
screen	ds.b 256
	ds.b 32000
	ds.b 32000
	endc
	;ds.w 32000
	;ds.w 32000



		rsreset
superScaleTable:	rs.w 200*NBCIRCLES		;200*96 un peu moins de 40 000 octet

******

realposition		rs.w 96*3
buffer1			rs.w 512		; 1.5k et on peut pas le metre dans memoire
	ifne standalone
bufferFlag		rs.b 512	; parce que c'est utilisé en meme temps
	endc
	ifeq standalone

			rs.b 512
	endc
				;realposition:
				;ds.l 96
				;ds.w 96
		
		*rsset realposition+NBCIRCLES*6
calcsinbuffer	equ realposition+NBCIRCLES*6		; ds.w 96

********



lstptrcode	rs.l ANGLEWRAP*NBCIRCLES*16		; 8*96*32
; 16 adresse d'appel
; puis 16 adresse ou il faut placer les rts
; format: (adresse appel, adresse retour)*16
;
refs1	rs.l 512
refs2	rs.l 512
refs3	rs.l 512
refs4	rs.l 512

convX2	rs.l 320
convY	rs.w 200
memoire	rs.w 0

convX	rs.l 320
lstor0	rs.w NBDOTPERCIRCLE			; max 32 point par cercle
lstor1	rs.w NBDOTPERCIRCLE			; max 32 point par cercle
lstor2	rs.w NBDOTPERCIRCLE			; max 32 point par cercle
lstor3	rs.w NBDOTPERCIRCLE			; max 32 point par cercle
lstor4	rs.w NBDOTPERCIRCLE			; max 32 point par cercle
lstor5	rs.w NBDOTPERCIRCLE			; max 32 point par cercle
lstor6	rs.w NBDOTPERCIRCLE			; max 32 point par cercle
lstor7	rs.w NBDOTPERCIRCLE			; max 32 point par cercle
lstor8	rs.w NBDOTPERCIRCLE			; max 32 point par cercle
lstor9	rs.w NBDOTPERCIRCLE			; max 32 point par cercle
lstorA	rs.w NBDOTPERCIRCLE			; max 32 point par cercle
lstorB	rs.w NBDOTPERCIRCLE			; max 32 point par cercle
lstorC	rs.w NBDOTPERCIRCLE			; max 32 point par cercle
lstorD	rs.w NBDOTPERCIRCLE			; max 32 point par cercle
lstorE	rs.w NBDOTPERCIRCLE			; max 32 point par cercle
lstorF	rs.w NBDOTPERCIRCLE			; max 32 point par cercle

lstorcount rs.w 16	; compteur lstorX
	rs.l 768*3-320-NBDOTPERCIRCLE*8		; a partir de memoire: 768*3 long reservé


bsscode	rs.l NBDOTPERCIRCLE*ANGLEWRAP*NBCIRCLES		; 96*32*8*2  256*96*2		; 96 cercle de 256 or.w *2, version dep(a0) et dep+8(a0)
		rs.w ANGLEWRAP*NBCIRCLES*16		; 8 'angle'*96 cercles * 32 add d0,d0
		rs.w ANGLEWRAP*NBCIRCLES		; 8*96	; rts
posSpot	rs.l NBCIRCLES		
truc	rs.l 0
