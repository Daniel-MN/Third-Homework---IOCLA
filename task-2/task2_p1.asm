section .text
	global cmmmc

;; int cmmmc(int a, int b)
;
;; calculate least common multiple fow 2 numbers, a and b
cmmmc:
	push    ebp
	push 	esp
	pop 	ebp

	;; Rezolvarea taskului consta in aplicarea: 
	; cmmmc(a, b) = a * b / cmmdc(a, b)
    
	push 	dword [ebp + 8] ; a
	pop 	eax ; a
	push 	dword [ebp + 12] ; b
	pop 	ebx ; b

	push 	eax ; eax = a

	imul 	ebx ; a * b
	push 	eax ; produsul
	pop 	esi ; esi = a * b

	pop 	eax ; a 



	; cmmdc intre a si b:
cmmdc:
	;; Cat timp a diferit de 0
	cmp 	eax, 0
	je 	    calculate_cmmmc
	;; Interschimbarea valorilor din a si b:
	push 	eax
	push 	ebx
	pop 	eax
	pop 	ebx

	;; Se va face a = a%b
	xor 	edx, edx
	div 	ebx 
	push 	edx
	pop 	eax
	jmp 	cmmdc

	;; Cmmdc intre a si b va ramane in ebx


calculate_cmmmc:
	push 	esi ; esi = a * b (a si b valorile initiale) 
	pop 	eax ; eax = a * b (a si b valorile initiale)
	xor 	edx, edx
	div 	ebx ; eax = eax / ebx, adica eax = a*b/cmmdc(a,b)

	push 	ebp
	pop		esp
	pop 	ebp
	
	ret
