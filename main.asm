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
    userRole DWORD ?                                                            ;   Variable to store the role of the user
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
    user_DefaultBalance DWORD ?

    ; Withdrawal Operation
    msg_WithdrawalHeader BYTE "====================================", 13, 10, \
                              "           Withdraw Amount          ", 13, 10, \
                              "====================================", 13, 10, 0
    prompt_WithdrawAmount BYTE "Enter the amount to withdraw: ", 0
    msg_SuccessfulWithdraw BYTE "Your amount has been withdrawn.", 13, 10, \
                                 "Collect it from the cash dispenser.", 13, 10, 0
    msg_UnsuccessfulWithdraw BYTE "Sorry, you do not have enough balance.", 13, 10, \
                                  "Please try again.", 13, 10, 0
    prompt_Exit BYTE "Press any key to go back...", 13, 10, 0

    ; Deposit
    msg_DepositHeader BYTE "====================================", 13, 10, \
                           "            Deposit Money           ", 13, 10, \
                           "====================================", 13, 10, 0
    prompt_DepositAmount BYTE "Enter the amount to deposit: ", 0
    msg_SuccessfulDeposit BYTE "The amount has been successfully added to your account.", 0
    msg_UnsuccessfulDeposit BYTE "Invalid amount. Please enter a value between 1 and 50,000 Rupees.", 0

    ; Check Balance
    msg_BalanceHeader BYTE "====================================", 13, 10, \
                           "          Current Balance           ", 13, 10, \
                           "====================================", 13, 10, 0
    msg_Balance BYTE "Your current account balance is: ", 0
    currencySuffix BYTE ".00 Rs", 0
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

    ; Error Handling
    errorMessage BYTE 101 DUP(0)                                            ; Buffer to store the current error message
    lastErrorMsg BYTE 101 DUP(0)                                            ; Buffer to store the last occurred error message
    msg_LastError BYTE "Last occurred error: ", 0
    msg_NoError BYTE "No errors have occurred.", 0
    prompt_Error BYTE "Enter the new error message: ", 0

    ; Software Update
    msg_UpdatePrompt BYTE "Enter the update version number: ", 0
    msg_UpdateComplete BYTE "Software update to version ", 0
    msg_UpdateSuccess BYTE " completed successfully!", 0
    updateVersion BYTE 21 DUP(0)                                            ; Buffer to store the update version number
    ;======================================================================================================================

.code
    main PROC
        ; Display the menu and get the role from the user
		    call displayMenu
        call clrscr

        ; Check the role and call the appropriate parent function
        mov eax, userRole
        cmp eax, 1
        je callCustomerOperations
        cmp eax, 2
        je callEmployeeOperations

        callCustomerOperations:
            call customerOperations
            jmp _exit
        callEmployeeOperations:
            call employeeOperations

        _exit:

    invoke ExitProcess, 0
    main ENDP

    displayMenu PROC
        mov edx, offset msg_Welcome
        call WriteString
        call crlf
        call crlf

        mov edx, offset msg_MenuOptions
        call WriteString
        call crlf
        call crlf

        input_loop:
            mov edx, offset msg_PromptRole
            call WriteString

            call ReadDec            

            cmp eax, 1              
            je valid_input          
            cmp eax, 2              
            je valid_input          

            mov edx, offset invalidInput
            call WriteString
            call crlf
            call crlf
        jmp input_loop          

        valid_input:
            mov userRole, eax
            call crlf
            call crlf

    ret
    displayMenu ENDP

    customerOperations PROC
        pushad
        
        call collectUserInfo
        call clrscr
        call displayUserOptions
        call clrscr

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

    userWithdraw PROC
        pushad

        ; Display Header
        mov edx, offset msg_WithdrawalHeader
        call WriteString

        _withDrawal:
            xor eax, eax                                ; Clear the Register
            mov edx, offset prompt_WithdrawAmount       ; Prompt User to Input Amount
            call writeString
            call readDec 

            ; Now we check that the entered amount is less than the user's balance
            cmp eax, user_DefaultBalance
            ja invalid_amountInput

            ; If the withdrawal amount is less than the user's balance
            sub user_DefaultBalance, eax
            mov edx, offset msg_SuccessfulWithdraw
            call writeString
            call crlf

            ; Prompt the user to press any key to go back to UserOperations
            mov edx, offset prompt_Exit
            call writeString
            call readChar
            call displayUserOptions

            ; If the input is invalid, display the error message and ask the user to enter an amount again.
            invalid_amountInput:
                 mov edx, offset msg_UnsuccessfulWithdraw
                 call writeString
                 call crlf
        jmp _withDrawal

        popad
    ret
    userWithdraw ENDP

    userDeposit PROC
        pushad

        ; Display Header
        mov edx, offset msg_DepositHeader
        call writeString
        call crlf

        ; First we prompt user how much amount of money he wants to deposit
        _deposit:
            xor eax,eax                                           ; Clear the register
            mov edx, offset prompt_DepositAmount                  ; Prompt the user to input amount
            call WriteString
            call ReadDec

            ; Check if the input amount is not greater than 50,000 (Conventional)
            cmp eax, 50000
            ja invalid_depositInput

            ; Success, add the user inputted amount to his balance.
            add user_DefaultBalance, eax
            mov edx, offset msg_SuccessfulDeposit
            call WriteString
            call crlf

            ; Prompt the user to press any key to go back to UserOperations
            mov edx, offset prompt_Exit
            call WriteString
            call ReadChar
            call displayUserOptions

            ; If the input is invalid, display the error message and ask the user to enter an amount again
            invalid_depositInput:
                mov edx,offset msg_UnsuccessfulDeposit
                call WriteString
                call crlf
        jmp _deposit

        popad
    ret
    userDeposit ENDP

    userCheckBalance PROC
        pushad

        ; Display header
        mov edx, offset msg_BalanceHeader
        call WriteString

        ; Display the actual balance
        mov edx, offset msg_Balance
        call WriteString
        mov eax, user_DefaultBalance
        call WriteDec
        mov edx, offset currencySuffix
        call WriteString

        ; Prompt the user to press any key to go back to UserOperations
        mov edx, offset prompt_Exit
        call WriteString
        call ReadChar
        call displayUserOptions

        popad
    ret
    userCheckBalance ENDP

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

    handleError PROC
        pushad

        ; First display the last occurred error
        call displayLastError

        ; Then update the error variable with the new error message
        call updateError

        popad
    ret
    handleError ENDP

    displayLastError PROC
        pushad

        ; Display the error prompt
        mov edx, offset msg_LastError
        call WriteString

        ; Check if there is an error message
        cmp BYTE PTR [lastErrorMsg], 0
        je noError                       ; If no error message, display no error message

        ; Display the last occurred error message
        lea edx, lastErrorMsg
        call WriteString
        call crlf                        ; New line for better formatting
        jmp end_display

        noError:
            ; Display the no error message
            mov edx, offset msg_NoError
            call WriteString
            call crlf                        ; New line for better formatting

        end_display:
            popad
    ret
    displayLastError ENDP

    updateError PROC
        pushad

        ; Get the new error message
        mov edx, offset prompt_Error
        call WriteString
        mov ecx, 100                      ; Maximum number of characters to read
        lea edx, errorMessage             ; Load the address of 'errorMessage'
        call ReadString                   ; Read the input error message
        call stripNewline                 ; Remove any trailing newline characters

        ; Copy the new error message to 'lastErrorMsg'
        lea esi, errorMessage             ; Load the address of 'errorMessage' into esi
        lea edi, lastErrorMsg             ; Load the address of 'lastErrorMsg'
        mov ecx, 100                      ; Maximum number of bytes to copy
        rep movsb                         ; Copy the current error to the last error

        popad
    ret
    updateError ENDP

    updateSoftware PROC
        pushad

        ; Prompt the user to enter the update version number
        mov edx, offset msg_UpdatePrompt
        call WriteString
        mov ecx, 20                      ; Maximum number of characters to read
        lea edx, updateVersion           ; Load the address of 'updateVersion' into edx
        call ReadString                  ; Call ReadString to take input
        call stripNewline                ; Remove any trailing newline characters
        call crlf                        ; New line for better formatting

        ; Display the update complete message
        mov edx, offset msg_UpdateComplete
        call WriteString
        lea edx, updateVersion
        call WriteString
        mov edx, offset msg_UpdateSuccess
        call WriteString
        call crlf                        ; New line for better formatting

        popad
    ret
    updateSoftware ENDP

    END main
