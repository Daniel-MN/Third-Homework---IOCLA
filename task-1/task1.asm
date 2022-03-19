section .text
	global sort

; struct node {
;     	int val;
;    	struct node* next;
; };
struc node
    val:    resd 1
    next:	resd 1
endstruc

;; struct node* sort(int n, struct node* node);
; 	The function will link the nodes in the array
;	in ascending order and will return the address
;	of the new found head of the list
; @params:
;	n -> the number of nodes in the array
;	node -> a pointer to the beginning in the array
; @returns:
;	the address of the head of the sorted list
sort:
	enter 0, 0

	mov		esi, [ebp + 8] ; n
	mov		edi, [ebp + 12] ; vector de noduri

	mov 	ebx, esi ; ebx itereaza prin valorile posibile ale nodurilor,
					 ; de la n la 1

	;; Se cauta nodul cu valoarea n, apoi nodul cu valoare n-1, nodul cu
	; valoarea n-2, ...., nodul cu valoarea 1 si se pun pe stiva
gaseste_nod_valoare_ebx:
	mov 	ecx, esi
	xor 	edx, edx

	;; Se itereaza prin vectorul de noduri pana se gaseste nodul cu valoarea 
	; ebx
gaseste_nod: 
	lea 	eax, [edi + edx * node_size]
	cmp 	ebx, [eax + val]
	je 		nod_gasit
	inc 	edx
	loop 	gaseste_nod

nod_gasit:
	push 	eax ; pune nodurile pe stiva, de la nodul cu valoarea n la nodul
				; cu valoarea 1
	dec		ebx
	jnz 	gaseste_nod_valoare_ebx

	
	pop 	eax ; primul nod
	mov 	edi, eax ; nodul curent se retine in edi
	dec 	esi

	;; Pe stiva avem nodurile in ordinea corecta
	; Se va conecta nodul anterior la nodul curent
conecteaza_nodurile:
	pop 	ebx ; nodul urmator
	mov 	[edi + next], ebx ; se conecteaza nodul curent la nodul urmator
	mov 	edi, ebx ; nodul curent devine urmatorul nod
	dec 	esi
	jnz 	conecteaza_nodurile
	
	leave
	ret
