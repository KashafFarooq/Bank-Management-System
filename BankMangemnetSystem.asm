; ==========================================
; SafeBank - FINAL
; MASM + Irvine32
; Features:
; - Create, Print, Withdraw, Deposit, Reset
; - Welcome message after account creation
; - Confirmation before reset
; ==========================================

.386
.MODEL flat, stdcall
.STACK 4096

INCLUDE Irvine32.inc

.DATA
    ; --- Title and Menu ---
    titleMsg    BYTE "SafeBank",0
    menuMsg     BYTE "Choose option (1-5, 0 to exit): ",0
    op1Msg      BYTE "1. Create Account",0
    op2Msg      BYTE "2. Print Account Details",0
    op3Msg      BYTE "3. Withdraw Money",0
    op4Msg      BYTE "4. Deposit Money",0
    op5Msg      BYTE "5. Reset Account",0
    exitMsg     BYTE "Exiting Program...",0

    ; --- Account Type ---
    accTypeTitle BYTE "Select Account Type:",0
    savingOpt    BYTE "1. Saving",0
    currentOpt   BYTE "2. Current",0
    choicePrompt BYTE "Enter choice: ",0

    ; --- Account Info ---
    namePrompt  BYTE "Enter Account Holder Name: ",0
    pinPrompt   BYTE "Enter Account PIN: ",0
    balPrompt   BYTE "Enter Initial Balance: ",0
    welcomeMsg  BYTE "Welcome, ",0

    depPrompt   BYTE "Deposit Amount (0 = Back): ",0
    witPrompt   BYTE "Withdraw Amount (0 = Back): ",0

    successMsg  BYTE "Operation Successful!",0
    noAccMsg    BYTE "Account not created!",0
    noMoneyMsg  BYTE "Insufficient funds!",0
    invalidMsg  BYTE "Invalid choice!",0

    accTypeLine BYTE "Account Type: ",0
    savingMsg   BYTE "Saving",0
    currentMsg  BYTE "Current",0
    nameLine    BYTE "Account Name: ",0
    balLine     BYTE "Balance: $",0

    confirmMsg  BYTE "Are you sure you want to reset? (1=Yes, 0=No): ",0
    cancelMsg   BYTE "Reset cancelled.",0

    ; --- Variables ---
    accountName     BYTE 100 DUP(0)
    accountPIN      BYTE 20 DUP(0)
    accType         BYTE 0
    accCreated      BYTE 0
    balance         DWORD 0
    choice          DWORD ?

.CODE

; ---------------- MENU ----------------
showMenu PROC
    call Clrscr
    mov edx, OFFSET titleMsg
    call WriteString
    call CrLf
    call CrLf

    mov edx, OFFSET op1Msg
    call WriteString
    call CrLf
    mov edx, OFFSET op2Msg
    call WriteString
    call CrLf
    mov edx, OFFSET op3Msg
    call WriteString
    call CrLf
    mov edx, OFFSET op4Msg
    call WriteString
    call CrLf
    mov edx, OFFSET op5Msg
    call WriteString
    call CrLf
    call CrLf

    mov edx, OFFSET menuMsg
    call WriteString
    ret
showMenu ENDP

; ---------------- CREATE ACCOUNT ----------------
createAccount PROC
    call Clrscr

askType:
    mov edx, OFFSET accTypeTitle
    call WriteString
    call CrLf

    mov edx, OFFSET savingOpt
    call WriteString
    call CrLf
    mov edx, OFFSET currentOpt
    call WriteString
    call CrLf
    call CrLf

    mov edx, OFFSET choicePrompt
    call WriteString
    call ReadDec

    cmp eax,1
    je setSaving
    cmp eax,2
    je setCurrent

    mov edx, OFFSET invalidMsg
    call WriteString
    call CrLf
    jmp askType

setSaving:
    mov accType,1
    jmp askName

setCurrent:
    mov accType,2

askName:
    mov edx, OFFSET namePrompt
    call WriteString
    mov edx, OFFSET accountName
    mov ecx,99
    call ReadString

askPIN:
    mov edx, OFFSET pinPrompt
    call WriteString
    mov edx, OFFSET accountPIN
    mov ecx,19
    call ReadString

getBalance:
    mov edx, OFFSET balPrompt
    call WriteString
    call ReadInt
    cmp eax,0
    jl getBalance
    mov balance,eax

    mov accCreated,1
    mov edx, OFFSET successMsg
    call WriteString
    call CrLf

    ; --- Welcome message ---
    mov edx, OFFSET welcomeMsg
    call WriteString
    mov edx, OFFSET accountName
    call WriteString
    call CrLf

    call WaitMsg
    ret
createAccount ENDP

; ---------------- PRINT ACCOUNT ----------------
printAccount PROC
    call Clrscr
    cmp accCreated,1
    jne noAccount

    mov edx, OFFSET accTypeLine
    call WriteString

    cmp accType,1
    je printSaving
    mov edx, OFFSET currentMsg
    jmp showType

printSaving:
    mov edx, OFFSET savingMsg

showType:
    call WriteString
    call CrLf

    mov edx, OFFSET nameLine
    call WriteString
    mov edx, OFFSET accountName
    call WriteString
    call CrLf

    mov edx, OFFSET balLine
    call WriteString
    mov eax, balance
    call WriteDec
    call CrLf

    call WaitMsg
    ret

noAccount:
    mov edx, OFFSET noAccMsg
    call WriteString
    call CrLf
    call WaitMsg
    ret
printAccount ENDP

; ---------------- WITHDRAW ----------------
withdraw PROC
    call Clrscr
    cmp accCreated,1
    jne noAccW

wMenu:
    mov edx, OFFSET witPrompt
    call WriteString
    call ReadDec
    cmp eax,0
    je doneW

    cmp eax,balance
    jg noMoney
    sub balance,eax
    mov edx, OFFSET successMsg
    call WriteString
    call CrLf

    jmp wMenu

noMoney:
    mov edx, OFFSET noMoneyMsg
    call WriteString
    call CrLf
    jmp wMenu

doneW:
    ret

noAccW:
    mov edx, OFFSET noAccMsg
    call WriteString
    call CrLf
    call WaitMsg
    ret
withdraw ENDP

; ---------------- DEPOSIT ----------------
deposit PROC
    call Clrscr
    cmp accCreated,1
    jne noAccD

dMenu:
    mov edx, OFFSET depPrompt
    call WriteString
    call ReadDec
    cmp eax,0
    je doneD

    add balance,eax
    mov edx, OFFSET successMsg
    call WriteString
    call CrLf

    jmp dMenu

doneD:
    ret

noAccD:
    mov edx, OFFSET noAccMsg
    call WriteString
    call CrLf
    call WaitMsg
    ret
deposit ENDP

; ---------------- RESET ----------------
resetAccount PROC
    call Clrscr
    mov edx, OFFSET confirmMsg
    call WriteString
    call ReadDec
    cmp eax,1
    jne resetCancel

    mov accCreated,0
    mov accType,0
    mov balance,0
    mov edx, OFFSET successMsg
    call WriteString
    call CrLf
    call WaitMsg
    ret

resetCancel:
    mov edx, OFFSET cancelMsg
    call WriteString
    call CrLf
    call WaitMsg
    ret
resetAccount ENDP

; ---------------- MAIN ----------------
main PROC
mainLoop:
    call showMenu
    call ReadDec
    mov choice,eax

    cmp choice,0
    je quit
    cmp choice,1
    je c1
    cmp choice,2
    je c2
    cmp choice,3
    je c3
    cmp choice,4
    je c4
    cmp choice,5
    je c5
    jmp mainLoop

c1: call createAccount
    jmp mainLoop
c2: call printAccount
    jmp mainLoop
c3: call withdraw
    jmp mainLoop
c4: call deposit
    jmp mainLoop
c5: call resetAccount
    jmp mainLoop

quit:
    call Clrscr
    mov edx, OFFSET exitMsg
    call WriteString
    exit
main ENDP

END main

