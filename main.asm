INCLUDE Irvine32.inc

.data
	;	Display Menu
	prompt_Str1 BYTE "****************************", 13, 10, \ 
					 "* Welcome to the ATM System *", 13, 10, \ 
					 "****************************", 13, 10, 0
	prompt_Str2 BYTE " 1. Customer ", 13, 10, \
					 " 2. Bank Employee ", 13, 10, 0 
	prompt_Str3 BYTE " Please choose your role: ", 0
	invalidInput BYTE "* Invalid input. Please enter 1 or 2. *", 13, 10, 0
	role BYTE 21 DUP(0)

.code
	main PROC
		call displayMenu

	INVOKE ExitProcess, 0
	main ENDP

	displayMenu PROC
		pushad

		; Display header and options
        mov edx, offset prompt_Str1
        call WriteString
        call crlf
        call crlf

        mov edx, offset prompt_Str2
        call WriteString
        call crlf
        call crlf

        ; Loop to keep asking for input until a valid option is selected
        input_loop:
            mov edx, offset prompt_Str3
            call WriteString

            mov ecx, 20                ; Maximum number of characters to read
            lea edx, role              ; Load the address of 'role' into edx
            call ReadString           

            ; Check the input for valid option
            mov al, role              
            cmp al, '1'                
            je valid_input             
            cmp al, '2'                
            je valid_input             

            ; If input is invalid, display error message
            mov edx, offset invalidInput
            call WriteString
            call crlf
            call crlf
        jmp input_loop             

        valid_input:
            call crlf
            call crlf

		popad
	ret
	displayMenu ENDP

	END main