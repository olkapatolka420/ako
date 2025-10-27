.686
.model flat

public _main
Comment |
DO X-bajtowej tablicy bufor odczytano pewien plik o rozmiarze 48 bajt�w
zakodowany w formacie UTF-8, zawieraj�cy pewien tekst. 
Napisa� program w 32-bitowym asemblerze, 
kt�ry wy�wietli ten tekst na ekranie w postaci komunikatu typu MessageBoxW. 
W poni�szej tablicy wyst�puj� ci�gi UTF-8  1-, 2-, 3 i 4-bajtowe.
| 

;wskazanie na import funkcji z bibliotek zewn�trznych
extern _fopen: PROC, _fread : PROC, _fclose : PROC
extern  _ExitProcess@4 : PROC,  _MessageBoxA@16 : PROC, _MessageBoxW@16 : PROC

.code
;kod funkcji do odczytu z pliku - nie trzeba analizowa�
read2buf PROC
push offset mode
push offset fname
call _fopen
add esp,8

push eax
push eax        ; uchwyt do pliku
push 48            ; liczba item�w
push 1            ; rozmiar itema
push offset bufor
call _fread
add esp,16

call _fclose
add esp,4
ret
read2buf ENDP

_main PROC
call read2buf  ; odczyt pliku w formacie utf8 do obszaru pami�ci operacyjnej oznaczonego jako bufor
                ; plik o nazwie "plik.txt" musi znajdowa� si� w katalogu roboczym


mov esi , OFFSET bufor ; wskazanie na pocz�tek bufora
mov ecx,0;dlugosc tekstu w znakach

petla:
mov al,[esi] ;pobranie pierwszego bajtu
cmp al, ' '
je slowo
cmp al, 0
je ostatnie_slowo
cmp ecx,0
jne nastepny_znak
mov ebx,esi

nastepny_znak:
inc ecx
inc esi
jmp petla

slowo:
push ecx
push ebx
inc [liczba_slow]
mov ecx,0
inc esi
jmp petla

ostatnie_slowo:
push ecx
push ebx
inc [liczba_slow]
;teraz mamy w ebx poczatek ostatniego slowa a w ecx jego dlugosc
;teraz tworzymy napis wynikowy

mov edi, OFFSET wynik
tworzenie_napisu:
cmp [liczba_slow],0
je koniec_tw_napisu
pop ebx;pobranie poczatku ostatniego slowa
pop ecx;dlugosc ostatniego slowa
mov esi,0
tworzenie_slowa:
mov eax,[ebx+esi]
mov [edi],eax ;kopiowanie pierwszego znaku
inc esi
inc edi
loop tworzenie_slowa
;dodanie spacji

mov al, ' '
mov [edi],al
inc edi

dec [liczba_slow]
jmp tworzenie_napisu

koniec_tw_napisu:
;usuniecie ostatniej spacji
dec edi
mov al,0
mov [edi],al
;wyswietlenie napisu
push 5 ; options)
push OFFSET bufor ; caption
push OFFSET wynik ; teskst
push 0 ; hwnd
call _MessageBoxA@16

;zako�czenie programu
push 0  ; exitcode
call _ExitProcess@4

_main ENDP

.data
liczba_slow dw 0
tekstASCII db 'Czy lubisz AKO?',0
tekstUTF16 dw 'C','z','y',' ','A','K','0',0
;tekst dw 'Cz'
dw 0
a  dw 30h
 dw 31h
 dw 32h
 dW '0'
 dw '1'
 dw '2'
 dw 30h,'1',32h
 dw '1','2','3',0



bufor db 120 dup (?)
wynik dw 128 dup (0)
 

mode db "r",0
fname db "test.txt",0


end