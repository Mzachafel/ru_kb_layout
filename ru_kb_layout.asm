.MODEL tiny
.CODE
.286
ORG 100h
	
start:
; PARSE ARGUMENTS
		mov ah,62h
		int 21h
		mov ds,bx
		mov bx,0080h
		mov ah,ds:[bx]
		cmp ah,0
		jz check_inst
		cmp ah,3
		jnz err_arg
		mov ah,ds:[bx+2]
		cmp ah,'/'
		jnz err_arg
		mov ah,ds:[bx+3]
		cmp ah,'u'
		jnz err_arg
		jmp check_uninst
; BAD ARGUMENT
err_arg:
		push cs
		pop ds
		lea dx,err_arg_msg
		mov ah,9
		int 21h
		mov ah,4ch
		mov al,0
		int 21h
; CHECK IF ALREADY INSTALLED
check_inst:
		push cs
		pop ds
		mov ax,0ff00h
		int 2Fh
		cmp al,0ffh
		jnz install
		lea dx,err_inst_msg
		mov ah,9
		int 21h
		mov ah,4ch
		mov al,0
		int 21h
install:
; LOAD USER-SPECIFIED PATTERNS
		mov ax,cs
		mov es,ax
		mov bp,offset table
		mov cx,67
		mov dx,128
		xor bl,bl
		mov bh,16
		mov ax,1100h
		int 10h
; SAVE OLD INT 8 VECTOR
		mov al,08h
		mov ah,35h
		int 21h
		mov word ptr oldint8,bx
		mov word ptr oldint8+2,es
; LOAD NEW INT 8 VECTOR
		mov dx,offset newint8
		mov al,08h
		mov ah,25h
		int 21h
; SAVE OLD INT 9 VECTOR
		mov al,09h
		mov ah,35h
		int 21h
		mov word ptr oldint9,bx
		mov word ptr oldint9+2,es
; LOAD NEW INT 9 VECTOR
		mov dx,offset newint9
		mov al,09h
		mov ah,25h
		int 21h
; SAVE OLD INT 16 VECTOR
		mov al,16h
		mov ah,35h
		int 21h
		mov word ptr oldint16,bx
		mov word ptr oldint16+2,es
; LOAD NEW INT 16 VECTOR
		mov dx,offset newint16
		mov al,16h
		mov ah,25h
		int 21h
; SAVE OLD INT 2F VECTOR
		mov al,2Fh
		mov ah,35h
		int 21h
		mov word ptr oldint2F,bx
		mov word ptr oldint2F+2,es
; LOAD NEW INT 2F VECTOR
		mov dx,offset newint2F
		mov al,2Fh
		mov ah,25h
		int 21h
; PRINT MESSAGE
		lea dx,inst_msg
		mov ah,09h
		int 21h
; MAKE PROGRAM RESIDENT
		mov dx,offset START
		mov ah,31h
		sti
		int 21h
; CHECK IF NOT IN MEMORY
check_uninst:
		push cs
		pop ds
		mov ax,0ff00h
		int 2Fh
		cmp al,0ffh
		jz uninstall
		lea dx,err_uninst_msg
		mov ah,9
		int 21h
		mov ah,4ch
		mov al,0
		int 21h
uninstall:
; LOAD ROM 8x16 CHARACTER SET
		mov ax,1104h
		xor bl,bl
		int 10h 
; LOAD PSP ADRESS TO ES
		mov al,09h
		mov ah,35h
		int 21h
		push ds
; LOAD OLD INT 8 VECTOR		
		mov dx,word ptr es:oldint8
		mov ds,word ptr es:oldint8+2
		mov al,08h
		mov ah,25h
		int 21h
; LOAD OLD INT 9 VECTOR		
		mov dx,word ptr es:oldint9
		mov ds,word ptr es:oldint9+2
		mov al,09h
		mov ah,25h
		int 21h
; LOAD OLD INT 16 VECTOR		
		mov dx,word ptr es:oldint16
		mov ds,word ptr es:oldint16+2
		mov al,16h
		mov ah,25h
		int 21h
; LOAD OLD INT 2F VECTOR	
		mov dx,word ptr es:oldint2F
		mov ds,word ptr es:oldint2F+2
		mov al,2Fh
		mov ah,25h
		int 21h
; PRINT MESSAGE
		pop ds
		lea dx,uninst_msg
		mov ah,09h
		int 21h
; FREE MEMORY
		mov ah,49h
		int 21h
		mov al,0
		mov ah,4ch
		int 21h

help_msg db 0dh,0ah,'LOCALE_RU COM 2.3'
		 db 0dh,0ah,'F1 - this message'
		 db 0dh,0ah,'Ctrl+LShift - switch to english'
		 db 0dh,0ah,'Ctrl+RShift - switch to russian'
		 db 0dh,0ah,'Press enter to continue...'
		 db 0dh,0ah,'$'
inst_msg db 'Driver successfully installed$'
uninst_msg db 'Driver successfully uninstalled$'
err_arg_msg db 'Incorrect argument$'
err_inst_msg db 'Driver is already in memory$'
err_uninst_msg db 'Driver is not in memory yet$'
	
oldint8 dd ?
oldint9 dd ?
oldint16 dd ?
oldint2F dd ?

switch db 0
lang db 'EN'

ascii_nums db 34,194,59,37,58,63
ascii_alpha db 138,151,148,139,133,142,131,153,154,136,150,155,0,0
            db 149,156,130,128,144,145,143,140,132,135,158,134,0,0
			db 160,152,146,141,137,147,157,129,159
			db 171,184,181,172,166,175,164,186,187,169,183,188,0,0
			db 182,189,163,161,177,178,176,173,165,168,191,167,0,0
			db 193,185,179,174,170,180,190,162,192

table db 00h,00h,010h,038h,06ch,0c6h,0c6h,0feh,0c6h,0c6h,0c6h,0c6h,00h,00h,00h,00h;А 128
      db 00h,00h,0feh,066h,062h,060h,07ch,066h,066h,066h,066h,0fch,00h,00h,00h,00h;Б 129
      db 00h,00h,0fch,066h,066h,066h,07ch,066h,066h,066h,066h,0fch,00h,00h,00h,00h;В 130
      db 00h,00h,0feh,066h,062h,060h,060h,060h,060h,060h,060h,0f0h,00h,00h,00h,00h;Г 131
      db 00h,00h,01eh,036h,066h,066h,066h,066h,066h,066h,066h,0ffh,0c3h,081h,00h,00h;Д 132
      db 00h,00h,0feh,066h,062h,068h,078h,068h,060h,062h,066h,0feh,00h,00h,00h,00h;Е 133
      db 00h,0c6h,00h,0feh,066h,062h,068h,078h,068h,062h,066h,0feh,00h,00h,00h,00h;Ё 134
      db 00h,00h,0d6h,0d6h,0d6h,07ch,038h,07ch,0d6h,0d6h,0d6h,0d6h,00h,00h,00h,00h;Ж 135
      db 00h,00h,07ch,0c6h,086h,06h,03ch,06h,06h,086h,0c6h,07ch,00h,00h,00h,00h;З 136
      db 00h,00h,0c6h,0c6h,0c6h,0ceh,0deh,0feh,0f6h,0e6h,0c6h,0c6h,00h,00h,00h,00h;И 137
      db 06ch,038h,00h,0c6h,0c6h,0c6h,0ceh,0deh,0feh,0f6h,0e6h,0c6h,00h,00h,00h,00h;Й 138
      db 00h,00h,0e6h,066h,066h,06ch,078h,078h,06ch,066h,066h,0e6h,00h,00h,00h,00h;К 139
      db 00h,00h,01eh,036h,066h,066h,066h,066h,066h,066h,066h,0c6h,00h,00h,00h,00h;Л 140
      db 00h,00h,0c6h,0eeh,0feh,0feh,0d6h,0c6h,0c6h,0c6h,0c6h,0c6h,00h,00h,00h,00h;М 141
      db 00h,00h,0c6h,0c6h,0c6h,0c6h,0c6h,0feh,0c6h,0c6h,0c6h,0c6h,00h,00h,00h,00h;Н 142
      db 00h,00h,07ch,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,07ch,00h,00h,00h,00h;О 143
      db 00h,00h,0feh,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,00h,00h,00h,00h;П 144
      db 00h,00h,0fch,066h,066h,066h,07ch,060h,060h,060h,060h,0f0h,00h,00h,00h,00h;Р 145
      db 00h,00h,03ch,066h,0c2h,0c0h,0c0h,0c0h,0c0h,0c2h,066h,03ch,00h,00h,00h,00h;С 146
      db 00h,00h,07eh,07eh,05ah,018h,018h,018h,018h,018h,018h,03ch,00h,00h,00h,00h;Т 147
      db 00h,00h,0c6h,0c6h,0c6h,0c6h,0c6h,07eh,06h,06h,0c6h,07ch,00h,00h,00h,00h;У 148
      db 00h,00h,038h,010h,07ch,0d6h,0d6h,0d6h,0d6h,07ch,010h,038h,00h,00h,00h,00h;Ф 149
      db 00h,00h,0c6h,0c6h,06ch,07ch,038h,038h,07ch,06ch,0c6h,0c6h,00h,00h,00h,00h;Х 150
      db 00h,00h,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0feh,06h,02h,00h,00h;Ц 151
      db 00h,00h,0c6h,0c6h,0c6h,0c6h,0c6h,07eh,06h,06h,06h,06h,00h,00h,00h,00h;Ч 152
      db 00h,00h,0d6h,0d6h,0d6h,0d6h,0d6h,0d6h,0d6h,0d6h,0d6h,0feh,00h,00h,00h,00h;Ш 153
      db 00h,00h,0d6h,0d6h,0d6h,0d6h,0d6h,0d6h,0d6h,0d6h,0d6h,0ffh,03h,01h,00h,00h;Щ 154
      db 00h,00h,0f0h,0b0h,0b0h,030h,03ch,036h,036h,036h,036h,07ch,00h,00h,00h,00h;Ъ 155
      db 00h,00h,0c6h,0c6h,0c6h,0c6h,0e6h,0d6h,0d6h,0d6h,0d6h,0e6h,00h,00h,00h,00h;Ы 156
      db 00h,00h,0f0h,060h,060h,060h,07ch,066h,066h,066h,066h,0fch,00h,00h,00h,00h;Ь 157
	  db 00h,00h,078h,0cch,086h,026h,03eh,026h,06h,086h,0cch,078h,00h,00h,00h,00h;Э 158
      db 00h,00h,0cch,0d6h,0d6h,0d6h,0f6h,0d6h,0d6h,0d6h,0d6h,0cch,00h,00h,00h,00h;Ю 159
      db 00h,00h,07eh,0cch,0cch,0cch,07ch,06ch,0cch,0cch,0cch,0ceh,00h,00h,00h,00h;Я 160
      db 00h,00h,00h,00h,00h,078h,0ch,07ch,0cch,0cch,0cch,076h,00h,00h,00h,00h;а 161
      db 00h,00h,00h,0ch,078h,0c0h,0c0h,0fch,0c6h,0c6h,0c6h,07ch,00h,00h,00h,00h;б 162
      db 00h,00h,00h,00h,00h,0fch,066h,066h,07ch,066h,066h,0fch,00h,00h,00h,00h;в 163
      db 00h,00h,00h,00h,00h,0feh,066h,062h,060h,060h,060h,0f0h,00h,00h,00h,00h;г 164
      db 00h,00h,00h,00h,00h,03ch,03ch,06ch,0cch,0cch,0cch,0feh,0c6h,082h,00h,00h;д 165
      db 00h,00h,00h,00h,00h,07ch,0c6h,0feh,0c0h,0c0h,0c6h,07ch,00h,00h,00h,00h;е 166
      db 00h,00h,0c6h,00h,00h,07ch,0c6h,0feh,0c0h,0c0h,0c6h,07ch,00h,00h,00h,00h;ё 167
      db 00h,00h,00h,00h,00h,0d6h,0d6h,0d6h,07ch,0d6h,0d6h,0d6h,00h,00h,00h,00h;ж 168
      db 00h,00h,00h,00h,00h,07ch,0c6h,06h,01ch,06h,0c6h,07ch,00h,00h,00h,00h;з 169
      db 00h,00h,00h,00h,00h,0c6h,0c6h,0ceh,0deh,0f6h,0e6h,0c6h,00h,00h,00h,00h;и 170
      db 00h,00h,06ch,038h,00h,0c6h,0c6h,0ceh,0deh,0f6h,0e6h,0c6h,00h,00h,00h,00h;й 171
      db 00h,00h,00h,00h,00h,0e6h,066h,06ch,078h,06ch,066h,0e6h,00h,00h,00h,00h;к 172
      db 00h,00h,00h,00h,00h,01eh,036h,066h,066h,066h,066h,0c6h,00h,00h,00h,00h;л 173
      db 00h,00h,00h,00h,00h,0c6h,0eeh,0feh,0d6h,0d6h,0c6h,0c6h,00h,00h,00h,00h;м 174
      db 00h,00h,00h,00h,00h,0c6h,0c6h,0c6h,0feh,0c6h,0c6h,0c6h,00h,00h,00h,00h;н 175
      db 00h,00h,00h,00h,00h,07ch,0c6h,0c6h,0c6h,0c6h,0c6h,07ch,00h,00h,00h,00h;о 176
      db 00h,00h,00h,00h,00h,0feh,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,00h,00h,00h,00h;п 177
      db 00h,00h,00h,00h,00h,0dch,066h,066h,066h,066h,066h,07ch,060h,060h,0f0h,00h;р 178
      db 00h,00h,00h,00h,00h,07ch,0c6h,0c0h,0c0h,0c0h,0c6h,07ch,00h,00h,00h,00h;с 179
      db 00h,00h,00h,00h,00h,07eh,05ah,018h,018h,018h,018h,03ch,00h,00h,00h,00h;т 180
      db 00h,00h,00h,00h,00h,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,07eh,06h,0ch,0f8h,00h;у 181
      db 00h,00h,010h,010h,010h,07ch,0d6h,0d6h,0d6h,0d6h,0d6h,07ch,010h,010h,010h,00h;ф 182
      db 00h,00h,00h,00h,00h,0c6h,06ch,038h,038h,038h,06ch,0c6h,00h,00h,00h,00h;х 183
      db 00h,00h,00h,00h,00h,0cch,0cch,0cch,0cch,0cch,0cch,0feh,06h,02h,00h,00h;ц 184
      db 00h,00h,00h,00h,00h,0c6h,0c6h,0c6h,07eh,06h,06h,06h,00h,00h,00h,00h;ч 185
      db 00h,00h,00h,00h,00h,0d6h,0d6h,0d6h,0d6h,0d6h,0d6h,0feh,00h,00h,00h,00h;ш 186
      db 00h,00h,00h,00h,00h,0d6h,0d6h,0d6h,0d6h,0d6h,0d6h,0ffh,03h,01h,00h,00h;щ 187
      db 00h,00h,00h,00h,00h,0f0h,0b0h,030h,03ch,036h,036h,07ch,00h,00h,00h,00h;ъ 188
      db 00h,00h,00h,00h,00h,0c6h,0c6h,0c6h,0e6h,0d6h,0d6h,0e6h,00h,00h,00h,00h;ы 189
      db 00h,00h,00h,00h,00h,078h,030h,030h,03ch,036h,036h,07ch,00h,00h,00h,00h;ь 190
      db 00h,00h,00h,00h,00h,07ch,0c6h,01eh,06h,06h,0c6h,07ch,00h,00h,00h,00h;э 191
      db 00h,00h,00h,00h,00h,0cch,0d6h,0d6h,0f6h,0d6h,0d6h,0cch,00h,00h,00h,00h;ю 192
      db 00h,00h,00h,00h,00h,03eh,06ch,06ch,03ch,06ch,06ch,0eeh,00h,00h,00h,00h;я 193
      db 00h,00h,08fh,0cdh,0edh,0ffh,0fch,0dfh,0cch,0cch,0cch,0cch,00h,00h,00h,00h;№ 194
		
; INTERRUPT FOR PRINTING CURRENTLY USED LANGUAGE ON SCREEN
newint8 proc far
		pushf
		call cs:oldint8
		push ax
		push bx
		push es
		mov ax,0b800h
		mov es,ax
		mov bx,009ch
		mov ah,07fh
		mov al,byte ptr cs:lang
		mov es:[bx],ax
		inc bx
		inc bx
		mov al,byte ptr cs:lang+1
		mov es:[bx],ax
		pop es
		pop bx
		pop ax
		iret
newint8 endp

; INTERRUPT FOR HANDLING LANGUAGE SWITCH
newint9 proc far
		pushf
		call cs:oldint9
		push ax
		push es
		xor ax,ax
		mov es,ax
		test byte ptr es:[417h],00000100b
		jnz ctrl
exit9:
		pop es
		pop ax
		iret
ctrl:
		test byte ptr es:[417h],00000010b
		jnz lshift
		test byte ptr es:[417h],00000001b
		jnz rshift
		jmp exit9
lshift:
; SWITCH TO ENGLISH
		mov byte ptr cs:switch,0
		mov byte ptr cs:lang,'E'
		mov byte ptr cs:lang+1,'N'
		jmp exit9
rshift:
; SWITCH TO RUSSIAN
		mov byte ptr cs:switch,1
		mov byte ptr cs:lang,'R'
		mov byte ptr cs:lang+1,'U'
		jmp exit9
newint9 endp

; INTERRUPT FOR HANDLING RIGHT ASCII CODE OUTPUT AND HELP MESSAGE
newint16 proc far
		pushf
		test ah,0EFh
		jz getkey
		call cs:oldint16
		iret
getkey:
; 00H AND 10H HANDLER
		call cs:oldint16
		cmp ah,3bh
		jz help
		test byte ptr cs:switch,01h
		jnz rus
		iret
help:
; PRINT HELP MESSAGE
		push dx
		push ds
		push ax
		push cs
		pop ds
		lea dx,help_msg
		mov ah,9
		int 21h
		pop ax
		pop ds
		pop dx
		iret
rus:
		cmp ah,10h
		jb num
		cmp ah,1bh
		ja cmp2
		jmp alpha
cmp2:
		cmp ah,1eh
		jb num
		cmp ah,29h
		ja cmp3
		jmp alpha
cmp3:
		cmp ah,2ch
		jb num
		cmp ah,34h
		ja num
		jmp alpha
num:
		push ax
		mov ah,02h
		int 16h
		test al,00000011b
		jz noshnum
		pop ax
		cmp ah,2bh
		jnz n2
		mov al,47
		jmp exit16
n2:
		cmp ah,35h
		jnz n3
		mov al,44
		jmp exit16
n3:
		cmp ah,03h
		jb exit16
		cmp ah,08h
		ja exit16
		mov al,ah
		sub al,03h
		push bx
		push ds
		push cs
		pop ds
		mov bx,offset ascii_nums
		xlatb
		pop ds
		pop bx
		jmp exit16
noshnum:
		pop ax
		cmp ah,35h
		jnz short exit16
		mov al,46
		jmp exit16
alpha:
		push ax
		mov ah,02h
		int 16h
		test al,01000000b
		jnz capson
capsoff:
		test al,00000011b
		jnz uprcase
		jmp lwrcase
capson:
		test al,00000011b
		jnz lwrcase
		jmp uprcase
lwrcase:
		pop ax
		mov al,ah
		add al,37
		jmp findchar
uprcase:
		pop ax
		mov al,ah
findchar:
		sub al,10h
		push bx
		push ds
		push cs
		pop ds
		mov bx,offset ascii_alpha
		xlatb
		pop ds
		pop bx
		jmp exit16
exit16:
		iret
newint16 endp

; INTERRUPT FOR CHECKING IF PROGRAM IS IN MEMORY
newint2F proc far
		cmp ax,0ff00h
		jz installed
		jmp dword ptr oldint2F
installed:
		mov ax,0ffh
		iret
newint2F endp

END start