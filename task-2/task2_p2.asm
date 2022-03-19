section .text
	global par

;; int par(int str_length, char* str)
;
; check for balanced brackets in an expression
par:
	push    ebp
	push 	esp
	pop 	ebp

	push 	dword [ebp + 8] ; str_length
	pop 	ecx
	push 	dword [ebp + 12] ; str
	pop 	esi

	push 	1
	pop 	eax ; presupun ca parantezele sunt corecte in expresie

	xor 	ebx, ebx ; itereator prin str
parcurgere_sir:
	cmp 	byte [esi + ebx], '('
	je		push_paranteza
	cmp 	byte [esi + ebx], ')'
	je 		pop_paranteza

urmatorul_caracter:
	inc 	ebx
	loop 	parcurgere_sir
	jmp 	verifica

push_paranteza:
	push 	1 ; avem o paranteza '('
	jmp 	urmatorul_caracter

pop_paranteza:
	cmp 	esp, ebp
	je		return_0 ; nu mai pot sterge din stiva
	pop 	edi ; stergem din stiva o '(', care a fost inchisa
	jmp 	urmatorul_caracter

	;; Se verifica daca stiva este goala. In cazul in care
	; stiva nu este goala
verifica: 
	cmp 	esp, ebp
	je		sfarsit_task	

return_0:
	xor 	eax, eax ; presupunerea este falsa

sfarsit_task:	
	push 	ebp
	pop		esp
	pop 	ebp
	
	ret
