INCLUDE Irvine32.inc

.code
    ; Procedure to Remove Trailing Newline Characters
    stripNewline PROC
        pushad
        
        mov ecx, edx                    ; Load the address of the string into ecx

        strip_loop:
            cmp BYTE PTR [ecx], 0       ; Check if end of string
            je strip_end                ; If null terminator, end loop
            cmp BYTE PTR [ecx], 13      ; Check for carriage return
            je strip_char               ; If carriage return, proceed to strip_char
            cmp BYTE PTR [ecx], 10      ; Check for newline
            je strip_char               ; If newline, proceed to strip_char
            inc ecx                     
            jmp strip_loop              

        strip_char:
            mov BYTE PTR [ecx], 0       ; Replace character with null terminator
            jmp strip_end

        strip_end:
        popad
    ret
    stripNewline ENDP


.data
    ;======================================================================================================================
	; Display Menu
	msg_Welcome BYTE "*****************************", 13, 10, \ 
					 "* Welcome to the ATM System *", 13, 10, \ 
					 "*****************************", 13, 10, 0
	msg_MenuOptions BYTE " 1. Customer ", 13, 10, \
					     " 2. Bank Employee ", 13, 10, 0 
	msg_PromptRole BYTE " Please choose your role: ", 0
	invalidInput BYTE "* Invalid input. Please enter 1 or 2. *", 13, 10, 0
	user_Role BYTE ?                                                             ;   Variable to store the role of the user
    ;======================================================================================================================

    ;======================================================================================================================
    ; Customer Operations

    ; User Login
    user_CardID BYTE 21 DUP(0)                                                   ; Variable to store the user's card ID
    user_AccountPIN BYTE 21 DUP(0)                                               ; Variable to store the user's PIN
    msg_UserHeader BYTE "====================================", 13, 10, \
                        "             User Login             ", 13, 10, \
                        "====================================", 13, 10, 0

    prompt_ID BYTE " Please enter your card ID: ", 0
    prompt_PIN BYTE " Please enter your PIN: ", 0
    msg_Error BYTE " Incorrect PIN. ", 13, 10, \
                   " Please try again. ", 13, 10, 0
    msg_Success BYTE " Login Successful! ", 13, 10, \
                     "====================================", 13, 10, 0

    ; User Login Verification
    predefined_CardID BYTE "12345678", 0                                        ; Predefined card ID
    predefined_PIN BYTE "1234", 0                                               ; Predefined PIN

    ; User Operations
    msg_UserOptionsPart1 BYTE   "===============================", 13, 10, \
                                "* Please choose an option:     *", 13, 10, \
                                "===============================", 13, 10, 0
    msg_UserOptionsPart2 BYTE   "* 1. Withdraw Amount           *", 13, 10, \
                                "* 2. Deposit Money             *", 13, 10, \
                                "* 3. Check Balance             *", 13, 10, 0
    msg_UserOptionsPart3 BYTE   "* 4. Transfer Funds            *", 13, 10, \
                                "* 5. Exit                      *", 13, 10, \
                                "===============================", 13, 10, 0
    user_Option BYTE ?                                                          ; Variable to store the user's option
    msg_PromptOption BYTE "Enter your choice: ", 0
    msg_InvalidInput BYTE "Invalid input. Please try again.", 0
    ;======================================================================================================================

    ;======================================================================================================================
    ; Employee Operations

    ; Employee Login
    employee_CardID BYTE 21 DUP(0)                                              ; Variable to store the employee's card ID
    employee_AccountPIN BYTE 21 DUP(0)                                          ; Variable to store the user's PIN
    msg_EmpHeader BYTE "====================================", 13, 10, \
                       "           Employee Login           ", 13, 10, \
                       "====================================", 13, 10, 0

    ; Employee Login Verification
    predefined_CardIDs BYTE "12345678", 0, "87654321", 0, "43218765", 0, 0
    predefined_PINs BYTE "1234", 0, "5678", 0, "4321", 0, 0
    ;======================================================================================================================

.code
	main PROC
        ; Display the menu and get the role from the user
		call displayMenu
        call clrscr

        ; Check the role and call the appropriate parent function
        mov al, [user_Role]
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
            mov al, [user_Role]              
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
        call clrscr
        call displayUserOptions

        popad
    ret
    customerOperations ENDP

    collectUserInfo PROC
        pushad

        ; Display header for user login
        mov edx, offset msg_UserHeader
        call WriteString
        call crlf

        id_loop: 
            ; Display prompt for card ID
            mov edx, offset prompt_ID
            call WriteString
            mov ecx, 20                     
            lea edx, user_CardID            ; Load the address of 'user_CardID' into edx
            call ReadString   
        
            ; Remove trailing newline characters from user input 
            lea edx, user_CardID 
            call stripNewline

            ; Check the card ID 
            call checkCardID 
            cmp eax, 0 
            je invalid_card                 ; If card ID is invalid, jump to invalid_card

            ; Card ID is valid, now prompt for PIN
            pin_loop: 
                ; Display prompt for PIN
                mov edx, offset prompt_PIN
                call WriteString
                mov ecx, 20                      
                lea edx, user_AccountPIN        ; Load the address of 'user_AccountPIN' into edx
                call ReadString                  
                call crlf              
            
                ; Remove trailing newline characters from user input 
                lea edx, user_AccountPIN 
                call stripNewline

                ; Check the PIN 
                call checkPIN 
                cmp eax, 0 
                je invalid_pin                  ; If PIN is invalid, jump to invalid_pin

                ; If both ID and PIN are valid, display success message
                mov edx, offset msg_Success
                call WriteString
                call crlf        
                jmp end_collect

            invalid_pin: 
                mov edx, offset msg_Error  
                call WriteString 
                call crlf

            jmp pin_loop                       ; Prompt for PIN again

            invalid_card: 
                mov edx, offset msg_Error 
                call WriteString 
                call crlf 

            jmp id_loop                        ; Prompt for card ID again

        end_collect:
            popad
    ret
    collectUserInfo ENDP

    checkCardID PROC
        ; Compare user_CardID with predefined_CardID
        lea edx, user_CardID                            ; Load the address of 'user_CardID'
        lea ecx, predefined_CardID                      ; Load the address of 'predefined_CardID' 

        compare_loop:
            mov al, [edx]                               ; Load a byte from user_CardID
            mov bl, [ecx]                               ; Load a byte from predefined_CardID
            cmp al, bl
            jne not_equal

            ; Check if end of string (null terminator)
            cmp al, 0
            je equal                                    ; If null terminator, strings are equal

            ; Increment pointers 
            inc edx 
            inc ecx 
            jmp compare_loop

        equal:
            ; IDs are equal 
            mov eax, 1                                  ; Return 1 for equal 
            jmp end_check

        not_equal:
            ; IDs are not equal 
            mov eax, 0                                  ; Return 0 for not equal

        end_check:
    ret
    checkCardID ENDP

    checkPIN PROC
        ; Compare user_AccountPIN with predefined_PIN
        lea edx, user_AccountPIN                        ; Load the address of 'user_AccountPIN'
        lea ecx, predefined_PIN                         ; Load the address of 'predefined_PIN'

        compare_loop:
            mov al, [edx]                               ; Load a byte from user_AccountPIN
            mov bl, [ecx]                               ; Load a byte from predefined_PIN
            cmp al, bl                                  
            jne not_equal                               

            ; Check if end of string (null terminator)
            cmp al, 0 
            je equal                                    ; If null terminator, strings are equal

            ; Increment pointers 
            inc edx 
            inc ecx 
            jmp compare_loop

        equal:
            ; PINs are equal 
            mov eax, 1                                  ; Return 1 for equal 
            jmp end_check

        not_equal: 
            ; PINs are not equal 
            mov eax, 0                                  ; Return 0 for not equal

        end_check:
    ret
    checkPIN ENDP

    displayUserOptions PROC
        pushad

        ; Display the options to the user
        mov edx, offset msg_UserOptionsPart1
        call WriteString
        mov edx, offset msg_UserOptionsPart2
        call WriteString
        mov edx, offset msg_UserOptionsPart3
        call WriteString
        call crlf

        ; Loop to keep asking for input until a valid option is selected
        option_loop:
            mov edx, offset msg_PromptOption
            call WriteString
            mov ecx, 2                       
            lea edx, user_Option             
            call ReadString                  
            call crlf                       

            ; Remove trailing newline characters from user input
            lea edx, user_Option
            call stripNewline

            ; Check if the input is valid
            mov al, user_Option
            cmp al, '1'
            je valid_option
            cmp al, '2'
            je valid_option
            cmp al, '3'
            je valid_option
            cmp al, '4'
            je valid_option
            cmp al, '5'
            je valid_option

            ; If the input is invalid, display error message and prompt again
            mov edx, offset msg_InvalidInput
            call WriteString
            call crlf
        jmp option_loop                 

        valid_option:
            call crlf

        popad
    ret
    displayUserOptions ENDP

    employeeOperations PROC
        pushad

        call collectEmployeeInfo
        call clrscr

        popad
    ret
    employeeOperations ENDP

    collectEmployeeInfo PROC
        pushad

        ; Display header for employee login
        mov edx, offset msg_EmpHeader
        call WriteString
        call crlf

        id_loop: 
            ; Display prompt for card ID
            mov edx, offset prompt_ID
            call WriteString
            mov ecx, 20                     
            lea edx, employee_CardID           
            call ReadString   
        
            lea edx, employee_CardID 
            call stripNewline

            ; Check the card ID 
            call check_EmpCardID 
            cmp eax, 0 
            je invalid_card                 

            ; Card ID is valid, now prompt for PIN
            pin_loop: 
                ; Display prompt for PIN
                mov edx, offset prompt_PIN
                call WriteString
                mov ecx, 20                      
                lea edx, employee_AccountPIN        
                call ReadString                  
                call crlf              
            
                ; Remove trailing newline characters from employee input
                lea edx, employee_AccountPIN 
                call stripNewline

                ; Check the PIN 
                call check_EmpPIN 
                cmp eax, 0 
                je invalid_pin                  

                ; If both ID and PIN are valid, display success message
                mov edx, offset msg_Success
                call WriteString
                call crlf        
                jmp end_collect

            invalid_pin: 
                mov edx, offset msg_Error  
                call WriteString 
                call crlf

            jmp pin_loop                      

            invalid_card: 
                mov edx, offset msg_Error 
                call WriteString 
                call crlf 

            jmp id_loop                        

        end_collect:
            popad
    ret
    collectEmployeeInfo ENDP

    check_EmpCardID PROC
        lea edx, employee_CardID                        ; Load the address of 'employee_CardID'
        lea ecx, predefined_CardIDs                     ; Load the address of 'predefined_CardIDs'
        mov esi, 0                                      ; Index for predefined Card IDs
            
        _checkCardID:
            mov edi, esi                                ; Store the current index
            mov al, [edx]                               ; Load a byte from user_CardID
            mov bl, [ecx + edi]                         ; Load a byte from predefined_CardIDs
            cmp al, bl
            jne _next                                   ; If not equal, check next ID

            ; Check if end of string (null terminator)
            cmp al, 0
            je _equal                                   ; If null terminator, IDs are equal

            ; Increment pointers 
            inc edx
            inc ecx
        jmp _checkCardID

            _equal:
                mov eax, 1                              ; Return 1 for equal 
                ret
            _next:
                ; Move to the next Card ID (8 bytes for each ID)
                add esi, 9                              ; Move to the next ID (8 characters + 1 for null terminator)
                cmp BYTE PTR [ecx + esi], 0             ; Check if we reached the end of predefined Card IDs
        jne _checkCardID                                ; If not, continue checking

            ; If we reach here, no match was found
            mov eax, 0                                  ; Return 0 for not equal
    ret
    check_EmpCardID ENDP

    check_EmpPIN PROC
        lea edx, employee_AccountPIN                    ; Load the address of 'employee_AccountPIN'
        lea ecx, predefined_PINs                        ; Load the address of 'predefined_PINs'
        mov esi, 0                                      ; Index for predefined PINs

        _checkPIN:
            mov edi, esi                                ; Store the current index
            mov al, [edx]                               ; Load a byte from employee_AccountPIN
            mov bl, [ecx + edi]                         ; Load a byte from predefined_PINs
            cmp al, bl
            jne _next                                   ; If not equal, check next PIN

            cmp al, 0
            je _equal                                   ; If null terminator, PINs are equal

            inc edx
            inc ecx
        jmp _checkPIN
            
            _equal:
                mov eax, 1                              ; Return 1 for equal
                ret
            _next:
                ; Move to the next PIN (4 bytes for each PIN)
                add esi, 5                              ; Move to the next PIN (4 characters + 1 for null terminator)
                cmp BYTE PTR [ecx + esi], 0             ; Check if we reached the end of predefined PINs
        jne _checkPIN                                   ; If not, continue checking

        mov eax, 0                                      ; Return 0 for not equal
    ret
    check_EmpPIN ENDP

	END main
