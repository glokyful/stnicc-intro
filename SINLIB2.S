
;
; sinus
;
;
;
;
	TEXT
initSinus
	rts
*	lea sintabDATA,a0
*	lea sintabBSS,a1
*	moveq #127,d1
*	move.w d1,d0
*.loop0
*	move (a0)+,(a1)+
*	dbra.w d0,.loop0
*	move.w d1,d0
*.loop1
*	move.w -(a0),d2
*	move.w d2,(a1)+
*	dbra.w d0,.loop1
*	
*	move.w #255,d0
*	lea sintabBSS,a2
*.loop2
*	move.w (a2)+,d2
*	neg.w d2
*	move.w d2,(a1)+
*	dbra d0,.loop2
*	rts
	
	
createSinTab
; d0 = constante = rayon
; a0 = buffer qui contiendra rayon/2*sin(angle)+rayon/2
	lea sintabBSS,a1
	move.w #511,d1
	;move.w #32768,d3
.loop
	clr.l d2
	move.w (a1)+,d2
					; nombre entre 0 et 65535 positif
	mulu d0,d2
	swap d2
	add.w d2,d2
	move.w d2,(a0)+
	dbra.w d1,.loop
	rts
createsinTab1024
; d0 = constante = rayon
; a0 = buffer qui contiendra rayon/2*sin(angle)+rayon/2
	lea sintabBSS,a1
	move.w #511,d1
	move.w #32768,d3
.loop
	clr.l d2
	move.w (a1)+,d2
	add d3,d2				; nombre entre 0 et 65535 positif
	mulu d0,d2
	swap d2
	move.w d2,(a0)+
	move.w d2,(a0)+		; doubler les valeurs
	dbra.w d1,.loop
	rts


mulby4buffer
; a0 = table de sinus de 512 element
; d0 = nombre d'element-1: ici 511 ou 1023 
;	move.w #511,d0

	moveq #2,d2
	bra.s toto
mulby2buffer
	moveq #1,d2
toto
	move.w #511,d0
	move.l a0,a1
.loop
	move (a1),d1
	lsl.w d2,d1
	move d1,(a1)+
	dbra.w d0,.loop
	rts
	
	
createSpecialSin
; a0 = table sinus de n element
; a1 = reftablesinus
; a2 = buffer resultat
; d0 = pas interne
; d1 = nombre de copie de valeur
; d2 = nombre n d'element de la table sinus
; retour = d1 : nombre de memoire occupé sur buffer resultat



	move.w d2,d3
	lea bufferFlag,a3
	subq #1,d3
.clrflag
	clr.b (a3)+
	dbra d3,.clrflag
	

	move.w d2,d3	; 512 ou 1024
	subq #1,d3		; 511  ou 1023 pour le and de l'angle

	lea bufferFlag,a3
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
	beq.s .flagA0
.fin
	rts

	
	
	
memorystructure
	
preparesintab
	; d0 = rayon
	; d1 = pas interne
	; d2 = nb d'element virtuel
	; a0 = buffer memoire
	; a1 adresse fonction
	
	 
	
	rts
	
createsinstructure
; 	
; d0: coefmultiplicateur nombre de valeur de sin	
; d1: nombre de table de sinus et de sinref	

	move.w #512,d6
	lsl d0,d6		lsl #3,d6 = 512*8
	add d6,d6			; 4096*2 octet
	add d6,d6			; 4096*4 = taille sinref
	move.w d1,d5
	mulu d6,d5 
	move.w d5,d4		; d4 = amount of memory used by
						; d5 = amount of memory in total
	
	
getsinstructure
	rts
	
withsinstructuredo

withsinstructureINCt


	
	
createSpecialSin2
; a0 = table sinus de n element
; a1 = reftablesinus
; a2 = buffer resultat
; d0 = pas interne
; d1 = nombre de copie de valeur
; d2 = nombre n d'element de la table sinus
; retour = d1 : nombre de memoire occupé sur buffer resultat

; a0: table reference de 512 element 
; a1 reftable sinus
; a2 buffer resultat
; d3: coeficient taille virtuelle de la table de reference  2 --> table virtuelle de 512*4=2048 element <--- 2=nombre de decalage a gauche
; d0: pas interne
; d1: nombre de copie de valeur:    le cas echeant ajouter test si plus de la taille de reference
; d2: deprecated = 512*d3




	move.w #512,d2
	lsl d3,d2			d2 = 4096 elements virtuel
	

	move.w d2,d4
	subq #1,d4
	lea bufferFlag,a3
.clrflag
	clr.b (a3)+
	dbra d4,.clrflag
	

	move.w d2,d4	; 4096
	subq #1,d4		; 4095 and and de l'angle

	lea bufferFlag,a3
	subq #1,d2		; 4095
	moveq #0,d5		; angle
.loop
	tst.b (a3,d5)	; flag a 1 ?
	bne.s .flagA1
.flagA0
	move.w d5,d6
	lsr d3,d6
	; ici nombre entre 0 et 511					; 					; 
	add d6,d6
	move.w (a0,d6),(a2)
	move.w d5,d6
	add d6,d6
	add d6,d6
	move.l a2,(a1,d6)			; a2 referencer en reftable+angle*4
	addq.l #2,a2
	st (a3,d5)		positione flag(angle) a 1
	add d0,d5		; pas interne
	and d2,d5		; mod 4096
	bra.s .loop
.flagA1	; copier d1 fois les valeurs suivante
	move.w d5,d4		; angle courant copier sur d4
	move.w d1,d7
	subq #1,d7
.cpy
	move.w d4,d6
	lsr d3,d6
	add d6,d6
	move.w (a0,d6),(a2)+
	add d0,d4	
	and d2,d4
	dbf d7,.cpy
	
	sub d0,d5
	addq #1,d5
	and d2,d5
	tst.b (a3,d5)
	beq.s .flagA0
.fin
	rts
		
	
	DATA

sintabBSS	incbin "C:\SRC\2PIX\sin16b.dat'	
	

	BSS

bufferFlag	ds.b 512*8
		*ds.b 512
	
	****************** deprecated ******************


