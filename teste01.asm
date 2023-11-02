;include 'bibliotecaE.inc' // USEI MAIS COMO REFERENCIA DO QUE COLOCAR NOS REGISTRADORES

extern printf, scanf
global main

section .data
request_filename_end db "nome do arquivo de saída:  ", 0AH, 0H
request_filename db "nome do arquivo de entrada:  ", 0AH,0H
request_x db "coordenada x:  ", 0AH,0H
request_y db "coordenada y:  ", 0AH,0H
request_width db "largura do retângulo:  ", 0AH,0H
request_height db "altura do retângulo:  ", 0AH,0H
format_string db "%s",0H
format_num db "%d",0H

section .bss
fileHandle resd 1 ; Handle do arquivo
fileBuffer resb 54 ; Buffer para os primeiros 54 bytes do arquivo
buffer resb 6480
integer_x resd 1 
integer_y resd 1
integer_width resd 1
integer_height resd 1
filename_in resb 300
filename_out resb 300 

section .text 
main:
    ; Passo 1: perguntar as coisas
    pergunta1:
    push request_filename
    call printf
    add esp, 4

    push filename_in
    push format_string
    call scanf
    add esp, 8

    perguntaX:
    push request_x
    call printf
    add esp, 4

    push integer_x
    push format_num
    call scanf
    add esp, 8

    perguntaY:
    push request_y
    call printf
    add esp, 4

    push integer_y
    push format_num
    call scanf
    add esp, 8

    perguntaWidth:
    push request_width
    call printf
    add esp, 4

    push integer_width
    push format_num
    call scanf
    add esp, 8
 
    perguntaHeight:
    push request_height
    call printf
    add esp, 4

    push integer_height
    push format_num
    call scanf
    add esp, 8

    PerguntaNovoArquivo:
    push request_filename_end
    call printf
    add esp, 4

    push filename_out
    push format_string
    call scanf
    add esp, 8


    ; Passo 2: Abertura do Arquivo 1 e 2
    abrir_1:
    mov eax, 5 ; Abrir arquivo
    mov ebx, filename_in
    mov ecx, 0 ; Modo de leitura
    mov edx, 0o777
    int 80h
    mov [fileHandle], eax

    ; Ler os primeiros 54 bytes do arquivo
    mov eax, 3 ; Ler arquivo
    mov ebx, [fileHandle]
    mov ecx, fileBuffer
    mov edx, 54
    int 80h

    ; Ler e escrever os primeiros 18 bytes (14 + 4) do arquivo
    mov eax, 3
    mov ebx, [file_handle]
    mov ecx, buffer
    mov edx, 18
    int 80h
    mov eax, 4
    mov ebx, [file_handle]
    mov ecx, buffer
    mov edx, 18
    int 80h

    ; Ler 4 bytes referentes à largura da imagem
    mov eax, 3
    mov ebx, [file_handle]
    mov ecx, [width]
    mov edx, 4
    int 80h

    ; Escrever os 4 bytes no arquivo de saída
    mov eax, 4
    mov ebx, [file_handle]
    mov ecx, [output_file]
    mov edx, 4
    int 80h

    ; Ler os 32 bytes restantes do cabeçalho da imagem
    mov eax, 3
    mov ebx, [file_handle]
    mov ecx, buffer
    mov edx, 32
    int 80h

    ; Escrever os 32 bytes no arquivo de saída
    mov eax, 4
    mov ebx, [file_handle]
    mov ecx, buffer
    mov edx, 32
    int 80h

    abrir_2: ;arquivo 2
    ; Escrever os primeiros 54 bytes no arquivo de saída
    mov eax, 5 ; Abrir arquivo de saída
    mov ebx, filename_out
    mov ecx, 1 ; Modo de escrita
    mov edx, 0o777
    int 80h
    mov [fileHandle], eax

    mov eax, 4 ; Escrever no arquivo de saída
    mov ebx, [fileHandle]
    mov ecx, fileBuffer
    mov edx, 54
    int 80h

    ; Ler os 32 bytes restantes do cabeçalho da imagem
    mov eax, 3
    mov ebx, [file_handle]
    mov ecx, buffer
    mov edx, 32
    int 80h

    censura:
    mov eax, 3 ; Ler arquivo de entrada
    mov ebx, [fileHandle]
    mov ecx, fileBuffer
    mov edx, 3  ; Largura de 3 bytes por pixel
    int 80h

    ; Escrever os 32 bytes no arquivo de saída
    mov eax, 4
    mov ebx, [file_handle]
    mov ecx, buffer
    mov edx, 32
    int 80h
 
    mov ebx, fileBuffer  ; ebx aponta para os bytes da imagem
    mov edx, [integer_x]  ; Coordenada X inicial
    mov esi, [integer_y]  ; Coordenada Y inicial
    mov edi, [integer_width]  ; Largura da censura
    mov ebp, [integer_height] ; Altura da censura
 
            
    ;censurando linha por linha
    linha_loop:
    mov eax, 3
    mov ebx, [fileHandle]
    mov ecx, fileBuffer 

    mov edx, [integer_width]
    mov esi, 3
    mov edi, 0 
     
    censurar_linha:
    mov byte [ecx], 0  ; Censura o componente azul
    mov byte [ecx + 1], 0  ; Censura o componente verde
    mov byte [ecx + 2], 0  ; Censura o componente vermelho
    add ecx, 3  ; Avança para o próximo pixel
    sub edx, 1  ; Decrementa a largura da censura
    cmp edx, 0
    je linha_loop
    jmp censurar_linha

add esi, 1  ; Avança para a próxima linha
sub ebp, 1  ; Decrementa a altura da censura
cmp ebp, 0
je fim
jmp linha_loop



fechar_arquivo:
mov eax, 6
mov ebx, [fileHandle]
int 80h


fim: 
mov eax, 1
xor ebx, ebx
int 80h
