INCLUDE Irvine32.inc

.data
	;	Display Menu
	msg_Welcome BYTE "*****************************", 13, 10, \ 
					 "* Welcome to the ATM System *", 13, 10, \ 
					 "*****************************", 13, 10, 0
	msg_MenuOptions BYTE " 1. Customer ", 13, 10, \
					 " 2. Bank Employee ", 13, 10, 0 
	msg_PromptRole BYTE " Please choose your role: ", 0
	invalidInput BYTE "* Invalid input. Please enter 1 or 2. *", 13, 10, 0
	user_Role BYTE ?                                                             ;   Variable to store the role of the user

    ;   Customer Operations
    user_CardID BYTE 21 DUP(0)                                                   ; Variable to store the user's card ID
    user_AccountPIN BYTE 21 DUP(0)                                               ; Variable to store the user's PIN
    prompt_ID BYTE "Enter card ID: ", 0
    prompt_PIN BYTE "Enter PIN: ", 0
    msg_Error BYTE "Incorrect PIN.", 13, 10, \
                      "Please try again.", 13, 10, 0
    msg_Success BYTE "Login Successful", 0

.code
	main PROC
        ; Display the menu and get the role from the user
		call displayMenu
        call Clrscr

        ; Check the role and call the appropriate parent function
        mov al, user_Role
        cmp al, '1'
        je callCustomerOperations
        cmp al, '2'
        je callEmployeeOperations

        callCustomerOperations:
            call customerOperations

        callEmployeeOperations:
            call employeeOperations

	invoke ExitProcess, 0
	main ENDP

	displayMenu PROC
		pushad

		; Display header and options
        mov edx, offset msg_Welcome
        call WriteString
        call crlf
        call crlf

        mov edx, offset msg_MenuOptions
        call WriteString
        call crlf
        call crlf

        ; Loop to keep asking for input until a valid option is selected
        input_loop:
            mov edx, offset msg_PromptRole
            call WriteString

            mov ecx, 20                     ; Maximum number of characters to read
            lea edx, user_Role              ; Load the address of 'role' into edx
            call ReadString           

            ; Check the input for valid option
            mov al, user_Role              
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

    customerOperations PROC
        pushad
        
        call collectUserInfo

        popad
    ret
    customerOperations ENDP

    collectUserInfo PROC
        pushad

        ; Display prompt for card ID
        mov edx, offset prompt_ID
        call WriteString
        mov ecx, 20                     
        lea edx, user_CardID             ; Load the address of 'user_CardID' into edx
        call ReadString                  

        ; Display prompt for PIN
        mov edx, offset prompt_PIN
        call WriteString
        mov ecx, 20                      
        lea edx, user_AccountPIN         ; Load the address of 'user_AccountPIN' into edx
        call ReadString                  
        call crlf                       

        ; For demonstration, display a success message
        mov edx, offset msg_Success
        call WriteString
        call crlf                       

        popad
    ret
    collectUserInfo ENDP

    employeeOperations PROC
        pushad
        popad
    ret
    employeeOperations ENDP

	END main
