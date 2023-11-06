section .data
    request_filename_end db "Nome do arquivo de saída: ", 0
    request_filename db "Nome do arquivo de entrada: ", 0
    request_x db "Coordenada X: ", 0
    request_y db "Coordenada Y: ", 0
    request_width db "Largura do retângulo: ", 0
    request_height db "Altura do retângulo: ", 0
    format_string db "%s",0
    format_num db "%d",0

section .bss
    fileHandleIn resd 1 ; Handle do arquivo de entrada
    fileHandleOut resd 1 ; Handle do arquivo de saída
    fileBuffer resb 54 ; Buffer para os primeiros 54 bytes do arquivo
    buffer resb 6480
    integer_x resd 1 
    integer_y resd 1
    integer_width resd 1
    integer_height resd 1
    filename_in resb 300
    filename_out resb 300

section .text
extern printf, scanf
global main

main:
    ; Passo 1: perguntar as informações
    push request_filename
    call printf
    add esp, 4

    push filename_in
    push format_string
    call scanf
    add esp, 8

    push request_x
    call printf
    add esp, 4

    push integer_x
    push format_num
    call scanf
    add esp, 8

    push request_y
    call printf
    add esp, 4

    push integer_y
    push format_num
    call scanf
    add esp, 8

    push request_width
    call printf
    add esp, 4

    push integer_width
    push format_num
    call scanf
    add esp, 8

    push request_height
    call printf
    add esp, 4

    push integer_height
    push format_num
    call scanf
    add esp, 8

    ; Passo 2: Abertura do Arquivo de Entrada
    mov eax, 5 ; Abrir arquivo de entrada
    mov ebx, filename_in
    mov ecx, 0 ; Modo de leitura
    int 0x80
    mov dword [fileHandleIn], eax

    ; Passo 3: Abertura do Arquivo de Saída
    push request_filename_end
    call printf
    add esp, 4

    push filename_out
    push format_string
    call scanf
    add esp, 8

    mov eax, 8 ; Abrir arquivo de saída
    mov ebx, filename_out
    mov ecx, 0o777 ; Modo de escrita
    int 0x80
    mov dword [fileHandleOut], eax

    ; Passo 4: Ler os primeiros 54 bytes do arquivo de entrada (cabeçalho)
    mov eax, 3 ; Ler arquivo de entrada
    mov ebx, dword [fileHandleIn]
    mov ecx, fileBuffer
    mov edx, 54
    int 0x80

    ; Passo 5: Escrever os primeiros 54 bytes no arquivo de saída
    mov eax, 4 ; Escrever no arquivo de saída
    mov ebx, dword [fileHandleOut]
    mov ecx, fileBuffer
    mov edx, 54
    int 0x80

    ; Passo 6: Ler o restante dos dados do arquivo de entrada e escrever no arquivo de saída
    copiar_dados:
    mov eax, 3 ; Ler arquivo de entrada
    mov ebx, dword [fileHandleIn]
    mov ecx, buffer
    mov edx, 6480
    int 0x80

    test eax, eax ; Verifique se chegamos ao final do arquivo
    jz fechar_arquivos ; Se sim, vá para o próximo passo

    mov eax, 4 ; Escrever no arquivo de saída
    mov ebx, dword [fileHandleOut]
    mov ecx, buffer
    int 0x80

    jmp copiar_dados ; Continue lendo e escrevendo

    ; Passo 7: Fechar os arquivos
    fechar_arquivos:
    mov eax, 6 ; Fechar o arquivo de entrada
    mov ebx, dword [fileHandleIn]
    int 0x80

    mov eax, 6 ; Fechar o arquivo de saída
    mov ebx, dword [fileHandleOut]
    int 0x80

    ; Passo 8: Sair do programa
    fim:
    mov eax, 1
    xor ebx, ebx
    int 0x80
