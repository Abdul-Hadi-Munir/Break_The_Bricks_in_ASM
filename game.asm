org 0x0100
jmp start

; Enhanced Title and Welcome Screen
title1: db '**********************************',0
title2: db '*                                *',0
title3: db '*       BREAKOUT GAME 2025       *',0
title4: db '*                                *',0
title5: db '**********************************',0
welcome1: db 'Welcome to the Classic Arcade!',0
welcome2: db 'Destroy all bricks and win!',0

; Menu options
menuHeader: db '===== MAIN MENU =====',0
option1: db '1. Play Game',0
option2: db '2. Instructions',0
option3: db '3. Difficulty',0
option4: db '4. Exit',0
menuFooter: db 'Select your option (1-4)',0

; Difficulty menu
diffHeader: db '===== DIFFICULTY =====',0
diffOption1: db '1. Easy (Slow)',0
diffOption2: db '2. Normal (Medium)',0
diffOption3: db '3. Hard (Fast)',0
diffCurrent: db 'Current: ',0
diffEasy: db 'Easy',0
diffNormal: db 'Normal',0
diffHard: db 'Hard',0
diffFooter: db 'Press ESC to return',0

; Instructions text
instTitle: db '===== INSTRUCTIONS =====',0
instLine1: db 'Ball will move randomly',0
instLine2: db 'Hit the ball with the bar',0
instLine3: db 'Control using:',0
instLine4: db '  Left Arrow - Move Left',0
instLine5: db '  Right Arrow - Move Right',0
instLine6: db 'Destroy all tiles',0
instLine7: db 'You have 3 lives!',0
instLine8: db '',0
instBack: db 'Press ESC to return to menu',0

; Game variables
currentScreen: db 0
score: dw 0
lives: db 3
ballX: db 40
ballY: db 20
ballDX: db 1
ballDY: db -1
paddleX: db 33
paddleSize: db 14          ; INCREASED from 10 to 14
gameOver: db 0
difficulty: db 2           ; 1=Easy, 2=Normal, 3=Hard
speedDelay: db 15          ; Movement delay (higher = slower)

; CHANGED: 10 blocks per row * 4 rows = 40 bricks
bricks: times 40 db 1

delayCounter: db 0
oldBallX: db 40
oldBallY: db 20
oldPaddleX: db 33

; Score and Lives display
scoreText: db 'Score: ',0
livesText: db 'Lives: ',0
gameOverText: db 'GAME OVER! Final Score: ',0
winText: db 'YOU WIN! Final Score: ',0
pressEsc: db 'Press ESC to return to menu',0

; NEW: Color table for 40 bricks (10 per row, 4 rows)
; Same color per row: Yellow, Red, Green, Blue
brickColors: db 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E
             db 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C
             db 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A
             db 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09

clearScreen:
    mov ax, 0xB800
    mov es, ax
    mov di, 0
    mov cx, 2000
    mov ax, 0x0020
clearLoop:
    stosw
    loop clearLoop
    ret

; keep attribute across printString (fix cyan / blinking)
printString:
    push bx
    mov bl, ah
    mov ax, 0xB800
    mov es, ax
printLoop:
    lodsb
    cmp al, 0
    je endPrint
    mov ah, bl
    stosw
    jmp printLoop
endPrint:
    pop bx
    ret

drawMainMenu:
    call clearScreen

    ; Draw decorative border
    mov ax, 0xB800
    mov es, ax

    ; Top title section with stars
    mov si, title1
    mov di, 484     ; Row 3, centered
    mov ah, 0x0E    ; Yellow
    call printString

    mov si, title2
    mov di, 644     ; Row 4
    mov ah, 0x0E
    call printString

    mov si, title3
    mov di, 804     ; Row 5
    mov ah, 0x0F    ; Bright White
    call printString

    mov si, title4
    mov di, 964     ; Row 6
    mov ah, 0x0E
    call printString

    mov si, title5
    mov di, 1124    ; Row 7
    mov ah, 0x0E
    call printString

    ; Welcome messages
    mov si, welcome1
    mov di, 1444    ; Row 9
    mov ah, 0x0B    ; Cyan
    call printString

    mov si, welcome2
    mov di, 1604    ; Row 10
    mov ah, 0x0B
    call printString

    ; Menu section
    mov si, menuHeader
    mov di, 2148    ; Row 13
    mov ah, 0x0A    ; Green
    call printString

    mov si, option1
    mov di, 2468    ; Row 15
    mov ah, 0x0F    ; White
    call printString

    mov si, option2
    mov di, 2628    ; Row 16
    mov ah, 0x0F
    call printString

    mov si, option3
    mov di, 2788    ; Row 17
    mov ah, 0x0F
    call printString

    mov si, option4
    mov di, 2948    ; Row 18
    mov ah, 0x0F
    call printString

    mov si, menuFooter
    mov di, 3268    ; Row 20
    mov ah, 0x07    ; Gray
    call printString

    ret

drawDifficultyMenu:
    call clearScreen

    mov si, diffHeader
    mov di, 1028
    mov ah, 0x0E
    call printString

    mov si, diffOption1
    mov di, 1508
    mov ah, 0x0F
    call printString

    mov si, diffOption2
    mov di, 1668
    mov ah, 0x0F
    call printString

    mov si, diffOption3
    mov di, 1828
    mov ah, 0x0F
    call printString

    ; Show current difficulty
    mov si, diffCurrent
    mov di, 2308
    mov ah, 0x0B
    call printString

    ; Display current difficulty name
    mov al, [difficulty]
    cmp al, 1
    je showEasy
    cmp al, 2
    je showNormal
    cmp al, 3
    je showHard

showEasy:
    mov si, diffEasy
    mov ah, 0x0A
    call printString
    jmp diffFooterDraw

showNormal:
    mov si, diffNormal
    mov ah, 0x0E
    call printString
    jmp diffFooterDraw

showHard:
    mov si, diffHard
    mov ah, 0x0C
    call printString

diffFooterDraw:
    mov si, diffFooter
    mov di, 3028
    mov ah, 0x07
    call printString

    ret

drawInstructions:
    call clearScreen

    mov si, instTitle
    mov di, 868
    mov ah, 0x0E
    call printString

    mov si, instLine1
    mov di, 1348
    mov ah, 0x0F
    call printString

    mov si, instLine2
    mov di, 1508
    call printString

    mov si, instLine3
    mov di, 1668
    call printString

    mov si, instLine4
    mov di, 1828
    call printString

    mov si, instLine5
    mov di, 1988
    call printString

    mov si, instLine6
    mov di, 2148
    call printString

    mov si, instLine7
    mov di, 2308
    call printString

    mov si, instBack
    mov di, 3028
    mov ah, 0x0A
    call printString

    ret

initGame:
    mov word [score], 0
    mov byte [lives], 3
    mov byte [ballX], 40
    mov byte [ballY], 15
    mov byte [ballDX], 1
    mov byte [ballDY], -1
    mov byte [paddleX], 33
    mov byte [gameOver], 0
    mov byte [delayCounter], 0
    mov byte [oldBallX], 40
    mov byte [oldBallY], 15
    mov byte [oldPaddleX], 33

    ; Set speed based on difficulty
    mov al, [difficulty]
    cmp al, 1
    je setEasySpeed
    cmp al, 2
    je setNormalSpeed
    cmp al, 3
    je setHardSpeed

setEasySpeed:
    mov byte [speedDelay], 15
    jmp initBricksStart

setNormalSpeed:
    mov byte [speedDelay], 10
    jmp initBricksStart

setHardSpeed:
    mov byte [speedDelay], 5

initBricksStart:
    ; Initialize all bricks (40 total)
    mov di, bricks
    mov cx, 40
    mov al, 1
initBricksLoop:
    mov [di], al
    inc di
    loop initBricksLoop
    ret

; Draw white border
drawBorder:
    mov ax, 0xB800
    mov es, ax

    ; Top border (row 1)
    mov di, 160
    mov cx, 80
    mov ax, 0x7FDB
topBorder:
    stosw
    loop topBorder

    ; Bottom border (row 24)
    mov di, 3840
    mov cx, 80
bottomBorder:
    stosw
    loop bottomBorder

    ; Side borders (rows 2-23)
    mov cx, 22
    mov di, 320
sideBorders:
    mov word [es:di], 0x7FDB
    mov word [es:di+158], 0x7FDB
    add di, 160
    loop sideBorders
    ret

; ------------------------------------------------------------
; Draw bricks - 7 characters wide each (14 bytes)
; 10 bricks per row, 4 rows (rows 3..6)
; starting at column 5 (padding 5 chars)
; ------------------------------------------------------------
drawBricks:
    mov ax, 0xB800
    mov es, ax
    mov si, bricks
    mov bx, brickColors ; Load base address of color table

    ; Row 1
    mov di, 490       ; row 3 (3*80*2 = 480) + padding (5*2 = 10)
    mov cx, 10
    call drawBrickRow

    ; Row 2
    mov di, 650       ; row 4 (4*80*2 = 640) + padding (10)
    mov cx, 10
    call drawBrickRow

    ; Row 3
    mov di, 810       ; row 5 (5*80*2 = 800) + padding (10)
    mov cx, 10
    call drawBrickRow

    ; Row 4
    mov di, 970       ; row 6 (6*80*2 = 960) + padding (10)
    mov cx, 10
    call drawBrickRow
    ret

drawBrickRow:
    push cx
drawBrickLoop:
    lodsb             ; Get brick state from SI, inc SI
    mov ah, [bx]      ; Get color from BX
    inc bx            ; Inc BX
    cmp al, 0
    je skipBrick

    ; Draw 7-character wide brick (14 bytes)
    mov al, 0xDB
    mov [es:di], ax
    mov [es:di+2], ax
    mov [es:di+4], ax
    mov [es:di+6], ax
    mov [es:di+8], ax
    mov [es:di+10], ax
    mov [es:di+12], ax

skipBrick:
    add di, 14  ; 7 chars * 2 bytes each = 14 bytes
    loop drawBrickLoop
    pop cx
    ret

; ------------------------------------------------------------
; Erase FULL brick when broken (7 characters)
; input: BX = brick index (0..39)
; ------------------------------------------------------------
eraseBrick:
    ; save regs we'll use
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; compute row and col from index in BX
    mov ax, bx      ; AX = index
    mov bl, 10
    div bl          ; AX / 10 -> AL = row (0..3), AH = col (0..9)
    mov dl, al      ; DL = row
    mov dh, ah      ; DH = col

    ; compute starting char offset = (row+3)*80 + 5 + (col * 7)
    xor ah, ah
    mov al, dl      ; AL = row
    add al, 3       ; AL = row + 3
    xor ah, ah
    mov bl, 80
    mul bl          ; AX = (row+3) * 80
    add ax, 5       ; Add padding
    push ax         ; save base

    mov al, dh      ; AL = col
    xor ah, ah
    mov bl, 7
    mul bl          ; AX = col * 7
    pop bx          ; BX = base (row part + padding)
    add ax, bx      ; AX = char_index (characters)
    shl ax, 1       ; bytes offset
    mov di, ax

    ; set ES to video
    mov ax, 0xB800
    mov es, ax

    ; erase 7 characters (stosw * 7)
    mov ax, 0x0020
    mov cx, 7
eraseBrickLoop2:
    stosw
    loop eraseBrickLoop2

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

eraseOldPaddle:
    mov ax, 0xB800
    mov es, ax
    mov di, 3680
    xor ax, ax
    mov al, [oldPaddleX]
    shl ax, 1
    add di, ax

    mov ah, 0x00
    mov al, ' '
    mov cl, [paddleSize]
    xor ch, ch
eraseOldPaddleLoop:
    mov [es:di], ax
    add di, 2
    loop eraseOldPaddleLoop
    ret

drawPaddle:
    call eraseOldPaddle

    mov ax, 0xB800
    mov es, ax
    mov di, 3680
    xor ax, ax
    mov al, [paddleX]
    shl ax, 1
    add di, ax

    mov ah, 0x1F
    mov al, 0xDB
    mov cl, [paddleSize]
    xor ch, ch
drawPaddleLoop:
    mov [es:di], ax
    add di, 2
    loop drawPaddleLoop

    mov al, [paddleX]
    mov [oldPaddleX], al
    ret

eraseOldBall:
    mov ax, 0xB800
    mov es, ax
    xor ax, ax
    mov al, [oldBallY]
    mov bx, 160
    mul bx
    mov di, ax
    xor ax, ax
    mov al, [oldBallX]
    shl ax, 1
    add di, ax
    mov word [es:di], 0x0020
    ret

drawBall:
    call eraseOldBall

    mov ax, 0xB800
    mov es, ax
    xor ax, ax
    mov al, [ballY]
    mov bx, 160
    mul bx
    mov di, ax
    xor ax, ax
    mov al, [ballX]
    shl ax, 1
    add di, ax

    ; Draw ball as a single circle character
    mov ah, 0x0F    ; Bright white
    mov al, 0x07    ; Bullet/circle character (●)
    mov [es:di], ax

    mov al, [ballX]
    mov [oldBallX], al
    mov al, [ballY]
    mov [oldBallY], al
    ret

drawStatus:
    mov ax, 0xB800
    mov es, ax

    mov di, 164
    mov si, scoreText
    mov ah, 0x0F
    call printString

    mov ax, [score]
    call printNumber

    mov di, 280
    mov si, livesText
    mov ah, 0x0F
    call printString

    xor ax, ax
    mov al, [lives]
    call printNumber
    ret

printNumber:
    push ax
    push bx
    push cx
    push dx

    mov bx, 10
    xor cx, cx

convertLoop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz convertLoop

    mov ax, 0xB800
    mov es, ax

printDigits:
    pop ax
    add al, '0'
    mov ah, 0x0F
    stosw
    loop printDigits

    pop dx
    pop cx
    pop bx
    pop ax
    ret

; check if all bricks are destroyed (now 40)
checkWin:
    mov si, bricks
    mov cx, 40
checkWinLoop:
    lodsb
    cmp al, 1
    je notWinYet
    loop checkWinLoop

    mov byte [gameOver], 2
    ret

notWinYet:
    ret

; Move ball & collisions with 7-wide bricks
moveBall:
    mov al, [ballDX]
    add [ballX], al
    mov al, [ballDY]
    add [ballY], al

    ; Left/right walls
    cmp byte [ballX], 2
    jle reverseDX
    cmp byte [ballX], 77
    jge reverseDX
    jmp checkY

reverseDX:
    neg byte [ballDX]

checkY:
    ; Top wall
    cmp byte [ballY], 2
    jle reverseDY

    ; Check if at paddle level
    cmp byte [ballY], 23
    je checkPaddle

    ; Check if ball fell BELOW paddle (LOSE LIFE)
    cmp byte [ballY], 24
    jge lostLife

    jmp checkBricks

reverseDY:
    neg byte [ballDY]
    jmp checkBricks

checkPaddle:
    mov al, [ballX]
    mov bl, [paddleX]
    cmp al, bl
    jl checkBricks      ; Missed to the left

    mov cl, bl
    add cl, [paddleSize] ; cl = paddleX + paddleSize
    cmp al, cl
    jge checkBricks     ; Missed to the right

    ; Hit paddle - bounce up
    mov byte [ballDY], -1

    ; NEW PADDLE PHYSICS
    ; Check which section of the paddle was hit
    ; bl still holds paddleX

    add bl, 4           ; bl = paddleX + 4 (end of left section)
    cmp al, bl
    jl paddleHitLeft    ; Hit left section

    add bl, 6           ; bl = paddleX + 10 (end of middle section)
    cmp al, bl
    jl paddleHitCenter  ; Hit middle section

    ; Hit right section
    mov byte [ballDX], 1
    jmp checkBricks

paddleHitLeft:
    mov byte [ballDX], -1
    jmp checkBricks

paddleHitCenter:
    ; ballDX is unchanged
    jmp checkBricks

lostLife:
    ; LOSE A LIFE - ball fell below paddle
    dec byte [lives]

    ; Reset ball
    mov byte [ballX], 40
    mov byte [ballY], 15
    mov byte [ballDX], 1
    mov byte [ballDY], -1
    mov byte [oldBallX], 40
    mov byte [oldBallY], 15

    ; Check game over
    cmp byte [lives], 0
    jne checkBricks
    mov byte [gameOver], 1

checkBricks:
    ; only consider rows 3..6 inclusive (row indices 3,4,5,6)
    mov al, [ballY]
    cmp al, 3
    jl doneBricks
    cmp al, 7
    jge doneBricks

    ; compute brick row index: row = ballY - 3  (0..3)
    mov al, [ballY]
    sub al, 3
    mov bl, al    ; bl = row

    ; compute column index: col = (ballX - 5) / 7
    mov al, [ballX]
    sub al, 5       ; Adjust for 5-char padding
    js doneBricks   ; if ballX < 5, can't hit a brick

    xor ah, ah
    mov cl, 7
    div cl          ; AX / CL: AL = quotient (col), AH = remainder
    mov bh, al    ; bh = col

    cmp bh, 10      ; Check 0..9
    jae doneBricks

    ; compute brick index = row * 10 + col
    mov al, bl
    xor ah, ah
    mov cl, 10
    mul cl          ; AX = row*10
    xor ah, ah
    add al, bh
    xor ah, ah
    mov bx, ax    ; BX = brick index (0..39)

    ; check brick alive
    mov si, bricks
    add si, bx
    cmp byte [si], 0
    je doneBricks

    ; Break the brick
    mov byte [si], 0
    push bx
    call eraseBrick
    pop bx

    add word [score], 10
    neg byte [ballDY]

doneBricks:
    ret

playGame:
    call initGame

    ; Draw static elements once
    call clearScreen
    call drawBorder

gameLoop:
    ; Redraw only changing elements
    call drawBricks
    call drawStatus
    call drawPaddle
    call drawBall

    ; Check win/lose
    cmp byte [gameOver], 0
    jne endGameCheck
    call checkWin

endGameCheck:
    cmp byte [gameOver], 0
    jne showEndScreen

    ; Ball movement with variable speed
    inc byte [delayCounter]
    mov al, [speedDelay]
    cmp [delayCounter], al
    jl skipBallMove
    mov byte [delayCounter], 0
    call moveBall

skipBallMove:
    mov cx, 0x6000
delayLoop:
    loop delayLoop

    ; Check keyboard
    mov ah, 0x01
    int 0x16
    jz gameLoop

    mov ah, 0x00
    int 0x16

    cmp ah, 0x01  ; ESC
    je exitGame

    cmp ah, 0x4B  ; Left
    je moveLeft

    cmp ah, 0x4D  ; Right
    je moveRight

    jmp gameLoop

moveLeft:
    cmp byte [paddleX], 2
    jle gameLoop
    dec byte [paddleX]
    jmp gameLoop

moveRight:
    mov al, [paddleX]
    add al, [paddleSize]
    cmp al, 77
    jge gameLoop
    inc byte [paddleX]
    jmp gameLoop

showEndScreen:
    call clearScreen

    mov di, 1600

    cmp byte [gameOver], 1
    je showGameOverMsg

    mov si, winText
    mov ah, 0x0E
    call printString
    jmp showFinalScore

showGameOverMsg:
    mov si, gameOverText
    mov ah, 0x0C
    call printString

showFinalScore:
    mov ax, [score]
    call printNumber

    mov di, 1920
    mov si, pressEsc
    mov ah, 0x0F
    call printString

waitEndKey:
    mov ah, 0x00
    int 0x16
    cmp ah, 0x01
    jne waitEndKey

exitGame:
    ret

start:
    ; Disable cursor
    mov ah, 0x01
    mov ch, 0x20
    mov cl, 0x00
    int 0x10

    mov byte [currentScreen], 0

mainLoop:
    cmp byte [currentScreen], 0
    je showMenu
    cmp byte [currentScreen], 1
    je showInst
    cmp byte [currentScreen], 2
    je startGame
    cmp byte [currentScreen], 3
    je showDiff

showMenu:
    call drawMainMenu

    mov ah, 0x00
    int 0x16

    cmp al, '1'
    je selectGame
    cmp al, '2'
    je selectInst
    cmp al, '3'
    je selectDiff
    cmp al, '4'
    je exitProgram
    jmp mainLoop

selectGame:
    mov byte [currentScreen], 2
    jmp mainLoop

selectInst:
    mov byte [currentScreen], 1
    jmp mainLoop

selectDiff:
    mov byte [currentScreen], 3
    jmp mainLoop

showInst:
    call drawInstructions

waitInstKey:
    mov ah, 0x00
    int 0x16
    cmp ah, 0x01
    je backToMenu
    jmp waitInstKey

showDiff:
    call drawDifficultyMenu

waitDiffKey:
    mov ah, 0x00
    int 0x16

    cmp ah, 0x01        ; ESC
    je backToMenu

    cmp al, '1'
    je setDiffEasy
    cmp al, '2'
    je setDiffNormal
    cmp al, '3'
    je setDiffHard
    jmp waitDiffKey

setDiffEasy:
    mov byte [difficulty], 1
    jmp showDiff

setDiffNormal:
    mov byte [difficulty], 2
    jmp showDiff

setDiffHard:
    mov byte [difficulty], 3
    jmp showDiff

backToMenu:
    mov byte [currentScreen], 0
    jmp mainLoop

startGame:
    call playGame
    mov byte [currentScreen], 0
    jmp mainLoop

exitProgram:
    mov ax, 0x4C00
    int 0x21
