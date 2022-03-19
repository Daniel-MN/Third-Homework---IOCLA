global get_words
global compare_func
global sort

extern strtok

extern strlen

extern strcmp

extern qsort

section .data
    delimit db " ,.", 10, 0

section .text


;; compare_func()
compare_func:
    enter 0, 0

    push    ebx
    push    esi
    push    edi

    mov     eax, [ebp + 8] ; adresa catre primul cuvant
    mov     ebx, [ebp + 12] ; adresa catre al doilea cuvant

    mov     esi, [eax]
    mov     edi, [ebx]

    push    esi
    push    edi

    push    edi
    call    strlen
    add     esp, 4

    pop     edi
    pop     esi
    push    eax ; adaugarea numarului de caractere ale celui de-al doilea 
                ; cuvant pe stiva


    push    esi
    push    edi

    push    esi
    call    strlen
    add     esp, 4

    pop     edi
    pop     esi

    pop     ebx ; numarul de caractere - al doilea cuvant
    sub     eax, ebx
    jnz     sfarsit_compare_func ; se va returna diferenta dintre numarul de caractere
                            ; ale primului cuvant si numarul de caractere ale
                            ; celui de-al doilea cuvant

    ; Daca diferenta dintre cele doua este 0
    push    edi
    push    esi
    call    strcmp
    add     esp, 8

sfarsit_compare_func: 
    pop     edi
    pop     esi
    pop     ebx

    leave
    ret



;; sort(char **words, int number_of_words, int size)
;  functia va trebui sa apeleze qsort pentru soratrea cuvintelor 
;  dupa lungime si apoi lexicografix
sort:
    enter 0, 0

    mov		edi, [ebp + 8] ; words
	mov		ecx, [ebp + 12] ; number_of_words
    mov     ebx, [ebp + 16] ; size

    push    compare_func
    push    ebx
    push    ecx
    push    edi
    call    qsort
    add     esp, 16


    leave
    ret

;; get_words(char *s, char **words, int number_of_words)
;  separa stringul s in cuvinte si salveaza cuvintele in words
;  number_of_words reprezinta numarul de cuvinte
get_words:
    enter 0, 0

    ;; Se parcurge sirul de caractere si cu ajutorul functiei strtok,
    ; obtinem cate un cuvant pe care il punem in ordinea obtinerii
    ; in words

    mov		esi, [ebp + 8] ; s
	mov		edi, [ebp + 12] ; words
    mov     ecx, [ebp + 16] ; number_of_words


    push    ecx
    push    edi

    ;; Obtinerea primului cuvant:
    push    dword delimit
    push    dword esi
    call    strtok
    add     esp, 8

    pop     edi
    pop     ecx

    xor     ebx, ebx; iterator prin sir
    
    mov     [edi + ebx * 4], eax ; Se pune in words cuvantul obtinut
    inc     ebx

parcurgere_s:
    push    ecx
    push    edi
    push    ebx

    ;; Obtinerea unui cuvant
    push    dword delimit
    push    dword 0
    call    strtok
    add     esp, 8

    pop     ebx
    pop     edi
    pop     ecx

    mov     [edi + ebx * 4], eax ; Se pune in words cuvantul obtinut
    inc     ebx
    loop    parcurgere_s

    leave
    ret
