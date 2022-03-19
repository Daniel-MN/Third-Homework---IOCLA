section .text

global expression
global term
global factor

extern strlen

extern atoi



; `factor(char *p, int *i)`
;       Evaluates "(expression)" or "number" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression
factor:
        push    ebp
        mov     ebp, esp

        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi

        mov     esi, [ebp + 8] ; p
        mov     ebx, [ebp + 12] ; int *i

        ;; Verific daca p este de forma "(expression)""
        push    esi
        push    ebx

        push    esi
        call    strlen
        add     esp, 4

        pop     ebx
        pop     esi

        mov     ecx, eax
        xor     eax, eax ; Eliberez eax

        cmp     byte [esi], "("
        jne     avem_numar

avem_expresie:
        ;; Daca primul caracter este paranteza '(', atunci:
        ; Verific daca ultimul caracter este ')'
        ; Aceasta verificare este inutila deoarece factor
        ; poate primi doar stringuri de forma 
        ; "(expression)"" sau "numar"

        cmp     byte [esi + ecx - 1], ")"
        jne     avem_numar ; stiam asta deja :))))

        ;; p este de forma "(expression)" 
        ; Sterg ')' de la final si apoi se apeleaza expression:
        mov     byte [esi + ecx - 1], 0
        ; Sterg '(' de la inceput
        mov     byte [esi], 0

        lea     edx, [esi + 1] ; Se retine stringul de dupa '('

        push    ebx
        push    edx
        call    expression
        add     esp, 8

        jmp     end_factor

        ;; In ecx avem numarul de caractere din numar
avem_numar:
        xor     eax, eax ; Numarul il vom stoca in eax
transform_numar:
        push    esi
        call    atoi
        add     esp, 4

        ;; Numarul va ramane in eax 

end_factor:
        pop     edi
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx

        leave
        ret

; `term(char *p, int *i)`
;       Evaluates "factor" * "factor" or "factor" / "factor" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression
term:
        push    ebp
        mov     ebp, esp

        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi

        mov     esi, [ebp + 8] ; p
        mov     ebx, [ebp + 12] ; int *i

        push    esi
        push    ebx
        ;; Voi parcurge p in ordine inversa
        push    esi
        call    strlen
        add     esp, 4

        pop     ebx
        pop     esi

        mov     edx, eax ; Cu edx iterez prin p
        xor     eax, eax ; Eliberez eax

        xor     edi, edi ; in edi retin numarul de semne '*' sau '/' dintre
                         ; termeni

        xor     ecx, ecx ; in ecx retin numarul de paranteze

cauta_factor:
        cmp     edx, 0
        je      calculeaza_primul_factor
        dec     edx

        cmp     byte [esi + edx], ')'
        jne     verifica_paranteza_factor
        
        ;; Daca caracterul curent este paranteza ')'
        inc     ecx
        jmp     cauta_factor


verifica_paranteza_factor:
        cmp     byte [esi + edx], '('
        jne     verifica_inmultire

        ;; Daca caracterul curent este paranteza '('
        dec     ecx
        jmp     cauta_factor
        
verifica_inmultire:
        cmp     byte [esi + edx], '*'
        jne     verifica_impartire

        ;; Daca caracterul curent este *:
        cmp     ecx, 0
        jne     cauta_factor ; inseamna ca ne aflam intr-o paranteza deschisa

        ;; Daca nu ne aflam intr-o paranteza deschisa, inseamna ca avem un
        ; factor:
        inc     edi
        lea     eax, [esi + edx + 1] ; acest factor incepe de dupa *

        push    ebx
        push    eax
        call    factor
        add     esp, 8

        push    eax ; Salvez pe stiva valoarea acestui factor
        push    dword 42 ; Salvez pe stiva faptul ca inainte de acest factor 
                         ; avem inmultire

        ; Se va cauta un alt factor:
        mov     byte [esi + edx], 0 ; actualizez stringul avand deja valoarea 
                                ; factorului de dupa
        jmp     cauta_factor ; se va cauta un alt factor

verifica_impartire:
        cmp     byte [esi + edx], '/'
        jne     cauta_factor ; Nu avem niciun semn *,/,),(

        ;; Daca caracterul curent este factor:
        cmp     ecx, 0
        jne     cauta_factor ; inseamna ca ne aflam intr-o paranteza deschisa

        ;; Daca nu ne aflam intr-o paranteza deschisa, inseamna ca avem un
        ; factor:
        inc     edi
        lea     eax, [esi + edx + 1] ; acest factor incepe de dupa /

        push    ebx
        push    eax
        call    term
        add     esp, 8
        
        push    eax ; Salvez pe stiva valoarea acestui factor
        push    dword 47 ; Salvez pe stiva faptul ca inainte de acest factor 
                         ; avem /

        ; Se va cauta un alt factor:
        mov     byte [esi + edx], 0 ; actualizez stringul avand deja valoarea 
                                ; factorului de dupa
        jmp     cauta_factor ; se va cauta un alt term

calculeaza_primul_factor:
        push    ebx
        push    esi
        call    factor
        add     esp, 8
        ;; A ramas in eax valoarea primului term


        ;; Parcurgem valorile fiecarui term pe rand si calculam
        ; valoarea expresiei
calculeaza_term:
        cmp     edi, 0
        je      end_term
        pop     ebx ; inmultire sau impartire
        cmp     ebx, 42 ; avem inmultire
        jne     avem_impartire
        ;; Daca avem inmultire:

avem_inmultire:
        pop     ecx ; Valoarea urmatorului factor
        imul    ecx
        jmp     urmatorul_factor

avem_impartire:
        xor     edx, edx
        pop     ecx ; Valoarea urmatorului factor
        cdq
        idiv    ecx

urmatorul_factor:
        dec     edi ; A fost folosit un term pentru calcularea 
                    ; expresiei
        jmp     calculeaza_term

end_term:
        pop     edi
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx

        leave
        ret

; `expression(char *p, int *i)`
;       Evaluates "term" + "term" or "term" - "term" expressions 
; @params:
;	p -> the string to be parsed
;	i -> current position in the string
; @returns:
;	the result of the parsed expression
expression:
        push    ebp
        mov     ebp, esp

        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi

        mov     esi, [ebp + 8] ; p
        mov     ebx, [ebp + 12] ; int *i

        push    esi
        push    ebx
        ;; Voi parcurge p in ordine inversa
        push    esi
        call    strlen
        add     esp, 4

        pop     ebx
        pop     esi

        mov     edx, eax ; Cu edx iterez prin p
        xor     eax, eax ; Eliberez eax

        xor     edi, edi ; in edi retin numarul de semne '+' sau '-' dintre
                         ; termeni

        xor     ecx, ecx ; in ecx retin numarul de paranteze

cauta_term:
        cmp     edx, 0
        je      calculeaza_primul_term
        dec     edx

        cmp     byte [esi + edx], ')'
        jne     verifica_paranteza
        
        ;; Daca caracterul curent este paranteza ')'
        inc     ecx
        jmp     cauta_term

verifica_paranteza:
        cmp     byte [esi + edx], '('
        jne     verifica_plus

        ;; Daca caracterul curent este paranteza '('
        dec     ecx
        jmp     cauta_term

verifica_plus:
        cmp     byte [esi + edx], '+'
        jne     verifica_minus

        ;; Daca caracterul curent este plus:
        cmp     ecx, 0
        jne     cauta_term ; inseamna ca ne aflam intr-o paranteza deschisa

        ;; Daca nu ne aflam intr-o paranteza deschisa, inseamna ca avem un
        ; term:
        inc     edi
        lea     eax, [esi + edx + 1] ; acest term incepe de dupa plus

        push    ebx
        push    eax
        call    term
        add     esp, 8

        push    eax ; Salvez pe stiva valoarea acestui term
        push    dword 43 ; Salvez pe stiva faptul ca inainte de acest term 
                         ; avem plus

        ; Se va cauta un alt term:
        mov     byte [esi + edx], 0 ; actualizez stringul avand deja valoarea 
                                ; termului de dupa
        jmp     cauta_term ; se va cauta un alt term

verifica_minus:
        cmp     byte [esi + edx], '-'
        jne     cauta_term ; Nu avem niciun semn +,-,),(

        ;; Daca caracterul curent este minus:
        cmp     ecx, 0
        jne     cauta_term ; inseamna ca ne aflam intr-o paranteza deschisa

        ;; Daca nu ne aflam intr-o paranteza deschisa, inseamna ca avem un
        ; term:
        inc     edi
        lea     eax, [esi + edx + 1] ; acest term incepe de dupa minus

        push    ebx
        push    eax
        call    term
        add     esp, 8
        
        push    eax ; Salvez pe stiva valoarea acestui term
        push    dword 45 ; Salvez pe stiva faptul ca inainte de acest term 
                         ; avem minus

        ; Se va cauta un alt term:
        mov     byte [esi + edx], 0 ; actualizez stringul avand deja valoarea 
                                ; termului de dupa
        jmp     cauta_term ; se va cauta un alt term

calculeaza_primul_term:
        push    ebx
        push    esi
        call    term
        add     esp, 8
        ;; A ramas in eax valoarea primului term


        ;; Parcurgem valorile fiecarui term pe rand si calculam
        ; valoarea expresiei
calculeaza_expresie:
        cmp     edi, 0
        je      end_expression
        pop     ebx ; plus sau minus
        cmp     ebx, 43 ; Verficam daca avem plus
        jne     avem_minus
        ;; Daca avem plus:
avem_plus:
        pop     ecx ; Valoarea urmatorului term
        add     eax, ecx
        jmp     urmatorul_term

avem_minus:
        pop     ecx ; Valoarea urmatorului term
        sub     eax, ecx

urmatorul_term:
        dec     edi ; A fost folosit un term pentru calcularea 
                    ; expresiei
        jmp     calculeaza_expresie

end_expression:
        pop     edi
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx

        leave
        ret

;; Functiile term si expression fac acelasi lucru, doar ca term lucreaza cu 
; *, / si expression lucreaza cu +, -, term apeleaza factor, iar expression
; apeleaza term
