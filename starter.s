#Faraan Javaid 1008169401 javaidfa

#Enhancements
# The enhancements I chose to implement were the
#multi-player mode for Category A and an improved
#random number generator for Category B

#The multi-player mode is taken care of throughout the code
#but can be more specifically found in:
#lines 68-80 -> nubmer of players
#lines 211-213 -> initialize moves and update player number
#lines 665-792 -> next round and outputting leaderboard
#The random number generator can be found in the rand function
#starting on line 781

#The multi-player mode happens by first asking the players for 
#the number of competitors by outputting a prompt and using the readInt 
#function. Then, before the game is set, the number of the player and
#the number of moves is initialized. When the player completes their 
#round, the player's number and amount of moves is saved on the stack
#and outputted on the console. All the players moves are then re-organized
#using a bubble sort algorithm and then outputted on the stack from least 
#to greatest as a leaderboard.
#The random-number generator was improved using linear congruence. This 
#was implemented by using a sequence generator with the fomula
#n = a*x + c modulo m. The x value is a seed that is produced from the 
#time system call from the original rand function. Then a and c were
#two large prime numbers used to scale the product as a very large 
#number. Then, similar to the previous random function, the remainder
#is taken so only values between 1 and 5 are produced. The information
#researched about this random number generator method was taken from 
#this site: https://asecuritysite.com/random/linear

.data
character:  .byte 0,0
box:        .byte 0,0
target:     .byte 0,0
White:      .word 0xFFFFFF
Black:      .word 0x000000
Char_col:   .word 0xFF0000 #red
Box_col:   .word 0x00FF00 #green
Tar_col:   .word 0x0000FF #blue
promptEnd: .string "End of Round: You got it!"
promptStart: .string "How many players?"
outputA:    .string "Player "
outputB:    .string " completes in "
outputC:    .string " moves"
newline:    .string "\n"
stats:    .string "Leaderboard"

.globl main
.text

main:
    # TODO: Before we deal with the LEDs, generate random locations for
    # the character, box, and target. static locations have been provided
    # for the (x,y) coordinates for each of these elements within the 8x8
    # grid. 
    # There is a rand function, but note that it isn't very good! You 
    # should at least make sure that none of the items are on top of each
    # other.
    
    INIT:
    # LOAD ADDRESSES FOR THE THREE ARRAYS
    la s0 character #load character array
    la s1 box #load box array
    la s2 target #load target array
    
    #ask for number of players
    li a7, 4
    la a0 promptStart
    ecall
    
    #new line for format
    li a7,4
    la a0 newline
    ecall
    
    #get the number of players
    call readInt
    mv a4 a0
    
    #SETUP BOX ARRAY
    Box: 
    li a0 6 #size of random numbers (0-5) as we work on 6*6 grid
    jal rand #call the rand function
        
    mv t2 a0 #move result of rand function 
    sb t2 0(s1) #store it into the first number of the box array
   
    li a0 6 #size of random numbers (0-5) as we work on 6*6 grid
    jal rand #call the rand function
        
    mv t2 a0 #move result of rand function 
    sb t2 1(s1) #store it into the first number of the box array  
    
    # load the values of the Box array
    lb a0 0(s1) #load x pos of Box
    lb a1 1(s1) #load y pos of Box
    li t1 0 #corner value of 0
    li t2 5 #corner value of 1
    
    #check if Box is in a corner and if it is choose different location
    first0:
    bne a0 t1 second0 #is the first number 0
    first0A:
        bne a1 t1 first0B #is the second number 0
        j Box
    first0B:
        bne a1 t2 second0 #is the second number 5
        j Box
    
    second0:
    bne a0 t2 Character #is the first number 5
    second0A:
        bne a1 t1 second0B #is the second number 0
        j Box
    second0B:
        bne a1 t2 Character #is the second number 
        j Box
    
    #SETUP THE CHARACTER ARRAY
    Character:
    li a0 6 #size of random numbers (0-5) as we work on 6*6 grid
    jal rand #call the rand function
        
    mv t2 a0 #move result of rand function 
    sb t2 0(s0) #store it into the first number of the character array
   
    li a0 6 #size of random numbers (0-5) as we work on 6*6 grid
    jal rand #call the rand function
        
    mv t2 a0 #move result of rand function 
    sb t2 1(s0) #store it into the first number of the character array
    
    # load the values of the Box and Character array
    lb a0 0(s1) #load x pos of Box
    lb a1 1(s1) #load y pos of Box
    lb t1 0(s0) #load x pos of Character
    lb t2 1(s0) #load y pos of Character
    li t6 0 #holds the flag of whether the values match
    
    #Check if Box and Character pos are unique
    jal Match # t6 is 1 if the same otherwise 0
    bne t6 zero Character #if t6 is not zero reset Character pos
    
    #SETUP TARGET ARRAY
    Target:    
    EgdeX:
    lb t2 0(s1) #load x pos of Box
    mv a2 t2
    sb a2 0(s2) #store the number as target x    
    li t1 0 #set the number to check
    beq a2 t1 EdgeY  
    li t1 5 #set the number to check   
    beq a2 t1 EdgeY  
    
    RandomizeX:
    li a0 6 #size of random numbers (0-5) as we work on 6*6 grid
    jal rand #call the rand function
        
    mv t2 a0 #move result of rand function 
    sb t2 0(s2) #store it into the first number of the target array
    
    EdgeY:
    lb t3 1(s1) #load y pos of Box
    mv a2 t3
    sb a2 1(s2) #store the number as target y
    li t2 0 #set the number to check   
    beq a2 t2 PrintTarget
    li t2 5 #set the number to check   
    beq a2 t2 PrintTarget
    
    RandomizeY:
    li a0 6 #size of random numbers (0-5) as we work on 6*6 grid
    jal rand #call the rand function
        
    mv t2 a0 #move result of rand function 
    sb t2 1(s2) #store it into the first number of the target array
       
    PrintTarget:   
    
    # load the values of the Box and target array
    lb a0 0(s1) #load x pos of Box
    lb a1 1(s1) #load y pos of Box
    lb t1 0(s2) #load x pos of target
    lb t2 1(s2) #load y pos of target
    li t6 0 #holds the flag of whether the values match
    
    #Check if Box and Target pos are unique
    jal Match # t6 is 1 if the same otherwise 0
    bne t6 zero Target #if t6 is not zero reset Target pos
    
    # load the values of the Character and target array
    lb a0 0(s0) #load x pos of Character
    lb a1 1(s0) #load y pos of Character
    lb t1 0(s2) #load x pos of target
    lb t2 1(s2) #load y pos of target
    li t6 0 #holds the flag of whether the values match
    
    #Check if Character and Target pos are unique
    jal Match # t6 is 1 if the same otherwise 0
    bne t6 zero Target #if t6 is not zero reset Target pos
    
    # TODO: Now, light up the playing field. Add walls around the edges
    # and light up the character, box, and target with the colors you have
    # chosen. (Yes, you choose, and you should document your choice.)
    # Hint: the LEDs are an array, so you should be able to calculate 
    # offsets from the (0, 0) LED.
    
    li s3 0 #player number
    nextPlay:
    li s4 0 #number of moves
    addi s3 s3 1
    
    #set walls to white
    Wall_set: #light up the array 
    jal setBlack #start with a black screen
    Wall_Front:
        
    li t2 8  #height of LED matrix
    la a0 White #load colour as White
    lw a0 0(a0)
    li a1 0 #start at x = 0
    li a2 0 #start at y = 0
    Left_wall:
        jal setLED #set the LED colour
        addi a2 a2 1 #move to next row
        blt a2 t2 Left_wall #until it reaches the last row
    
    li t2 8 # height of LED matrix
    la a0 White #load colour as white
    lw a0 0(a0) 
    li a1 7 #start at x = 7
    li a2 0 #start at y = 0
    Right_wall:
        jal setLED #set the LED color
        addi a2 a2 1 #move to next row
        blt a2 t2 Right_wall #until it reaches the last row
        
    li t2 8 #width of LED matrix
    la a0 White #load colour as white
    lw a0 0(a0)
    li a1 0 #start at x=0
    li a2 0 #start at y=0
    Top_wall:
        jal setLED #set the LED color
        addi a1 a1 1 #move to the next column
        blt a1 t2 Top_wall #until it reaches the last column
    
    li t2 8 # height of LED matrix
    la a0 White #load colour as white
    lw a0 0(a0) 
    li a1 0 #start at x = 0
    li a2 7 #start at y = 7
    Bottom_wall:
        jal setLED #set the LED color
        addi a1 a1 1 #move to the next column
        blt a1 t2 Bottom_wall #until it reaches the last column
    
    #set character color as red
    Character_color:
        lb a1 0(s0) #load in x pos for character
        addi a1 a1 1 #plus 1 for 1 more than wall
        lb a2 1(s0) #load in y pos for character
        addi a2 a2 1 #plus 1 for 1 more than wall
        la a0 Char_col #color of character is red
        lw a0 0(a0)
        jal setLED #set color
        
    #set box color as green     
    Box_color:
        lb a1 0(s1)
        addi a1 a1 1
        lb a2 1(s1)
        addi a2 a2 1
        la a0 Box_col
        lw a0 0(a0)
        jal setLED
    
    #set target color as blue
    Target_color:
        lb a1 0(s2)
        addi a1 a1 1
        lb a2 1(s2)
        addi a2 a2 1
        la a0 Tar_col
        lw a0 0(a0)
        jal setLED
        
    # TODO: Enter a loop and wait for user input. Whenever user input is 
    # received, update the grid with the new location of the player and
    # if applicable, box and target. You will also need to restart the
    # game if the user requests it and indicate when the box is located
    # in the same position as the target.
    li a0 0
    li s5 0 #number of times a wall is hit consecutively 
    
    lb s6 0(s0) #load x pos of Character
    lb s7 1(s0) #load y pos of Character
    lb s8 0(s1) #load x pos of Box
    lb s9 1(s1) #load y pos of Box
    lb s10 0(s2) #load x pos of target
    lb s11 1(s2) #load y pos of target
    
    GameLoop:  
        
    jal pollDpad
    li t0 0
    beq a0 t0 UpMove
    
    li t0 1
    beq a0 t0 DownMove
    
    li t0 2
    beq a0 t0 LeftMove
    
    li t0 3
    beq a0 t0 RightMove
    
    UpMove:
        #set x y position based on grid
        mv a1 s6 #move in x pos for character
        addi a1 a1 1 #plus 1 for 1 more than wall
        mv a2 s7 #move in y pos for character
        addi a2 a2 1 #plus 1 for 1 more than wall
        
        #check for wall
        li t4 0 #hold the y pos for the wall
        mv t5 a2 #put the current value of a2 in the wall
        addi t5 t5 -1 #put what the new y position would be
        beq t4 t5 Restart #if the new y position will be in wall Check for restart
        
        #check if it is a Box
        # load the values of the Box and Character array
        addi s7 s7 -1
        mv a0 s8 #load x pos of Box
        mv a1 s9 #load y pos of Box
        mv t1 s6 #load x pos of Character
        mv t2 s7 #load y pos of Character
        addi s7 s7 1
        li t6 0 #holds the flag of whether the values match
        jal Match
        bne t6 zero BoxUp
        j Char_Up
        
        BoxUp:
        #set x y position based on grid
        mv a1 s8 #move in x pos for box
        addi a1 a1 1 #plus 1 for 1 more than wall
        mv a2 s9 #move in y pos for box
        addi a2 a2 1 #plus 1 for 1 more than wall
        
        #check for box aginst wall
        li t4 0 #hold the y pos for the wall
        mv t5 a2 #put the current value of a2 in the wall
        addi t5 t5 -1 #put what the new y position would be
        beq t4 t5 Next #if the new y position will be in wall dont move
        
        addi a2 a2 -1 #move y pos up 
        la a0 Box_col #color of new box pos is blue
        lw a0 0(a0)
        jal setLED #set color to green
        addi s9 s9 -1    
        
        #set color to red for new LED
        Char_Up:
        #set x y position based on grid
        mv a1 s6 #move in x pos for character
        addi a1 a1 1 #plus 1 for 1 more than wall
        mv a2 s7 #move in y pos for character
        addi a2 a2 1 #plus 1 for 1 more than wall
        #set color to black for old LED
        la a0 Black #color of old character is black
        lw a0 0(a0)
        jal setLED #set color to black
        #new position color    
        addi a2 a2 -1 #move y pos up 
        la a0 Char_col #color of new character is red
        lw a0 0(a0)
        jal setLED #set color to red
        addi s7 s7 -1
        li s5 0 #set the number of walls hit to 0
        addi s4 s4 1 #number of player moves increments
        j Next
        
    DownMove:
        #set x y position based on grid
        mv a1 s6 #move in x pos for character
        addi a1 a1 1 #plus 1 for 1 more than wall
        mv a2 s7 #move in y pos for character
        addi a2 a2 1 #plus 1 for 1 more than wall
        
        #check for wall
        li t4 7 #hold the y pos for the wall
        mv t5 a2 #put the current value of a2 in the wall
        addi t5 t5 1 #put what the new y position would be
        beq t4 t5 Restart #if the new y position will be in wall Check for restart
        
        #check if it is a Box
        # load the values of the Box and Character array
        addi s7 s7 1
        mv a0 s8 #load x pos of Box
        mv a1 s9 #load y pos of Box
        mv t1 s6 #load x pos of Character
        mv t2 s7 #load y pos of Character
        addi s7 s7 -1
        li t6 0 #holds the flag of whether the values match
        jal Match
        bne t6 zero BoxDown
        j Char_Down
        
        BoxDown:
        #set x y position based on grid
        mv a1 s8 #move in x pos for box
        addi a1 a1 1 #plus 1 for 1 more than wall
        mv a2 s9 #move in y pos for box
        addi a2 a2 1 #plus 1 for 1 more than wall
        
        #check for box aginst wall
        li t4 7 #hold the y pos for the wall
        mv t5 a2 #put the current value of a2 in the wall
        addi t5 t5 1 #put what the new y position would be
        beq t4 t5 Next #if the new y position will be in wall dont move
        
        addi a2 a2 1 #move y pos down 
        la a0 Box_col #color of new box pos is green
        lw a0 0(a0)
        jal setLED #set color to green
        addi s9 s9 1    
        
        #set color to red for new LED
        Char_Down:
        #set x y position based on grid
        mv a1 s6 #move in x pos for character
        addi a1 a1 1 #plus 1 for 1 more than wall
        mv a2 s7 #move in y pos for character
        addi a2 a2 1 #plus 1 for 1 more than wall
        #set color to black for old LED
        la a0 Black #color of old character is black
        lw a0 0(a0)
        jal setLED #set color to black
        #new position color    
        addi a2 a2 1 #move y pos up 
        la a0 Char_col #color of new character is red
        lw a0 0(a0)
        jal setLED #set color to red
        addi s7 s7 1
        li s5 0 #set the number of walls hit to 0
        addi s4 s4 1 #number of player moves increments
        j Next
        
    LeftMove:
        #set x y position based on grid
        mv a1 s6 #move in x pos for character
        addi a1 a1 1 #plus 1 for 1 more than wall
        mv a2 s7 #move in y pos for character
        addi a2 a2 1 #plus 1 for 1 more than wall
        
        #check for wall
        li t4 0 #hold the x pos for the wall
        mv t5 a1 #put the current value of a1 in the wall
        addi t5 t5 -1 #put what the new x position would be
        beq t4 t5 Restart #if the new x position will be in wall Check for restart
        
        #check if it is a Box
        # load the values of the Box and Character array
        addi s6 s6 -1
        mv a0 s8 #load x pos of Box
        mv a1 s9 #load y pos of Box
        mv t1 s6 #load x pos of Character
        mv t2 s7 #load y pos of Character
        addi s6 s6 1
        li t6 0 #holds the flag of whether the values match
        jal Match
        bne t6 zero BoxLeft
        j Char_Left
        
        BoxLeft:
        #set x y position based on grid
        mv a1 s8 #move in x pos for box
        addi a1 a1 1 #plus 1 for 1 more than wall
        mv a2 s9 #move in y pos for box
        addi a2 a2 1 #plus 1 for 1 more than wall
        
        #check for box aginst wall
        li t4 0 #hold the x pos for the wall
        mv t5 a1 #put the current value of a1 in the wall
        addi t5 t5 -1 #put what the new x position would be
        beq t4 t5 Next #if the new x position will be in wall dont move
        
        addi a1 a1 -1 #move x pos left 
        la a0 Box_col #color of new box pos is green
        lw a0 0(a0)
        jal setLED #set color to green
        addi s8 s8 -1    
        
        #set color to red for new LED
        Char_Left:
        #set x y position based on grid
        mv a1 s6 #move in x pos for character
        addi a1 a1 1 #plus 1 for 1 more than wall
        mv a2 s7 #move in y pos for character
        addi a2 a2 1 #plus 1 for 1 more than wall
        #set color to black for old LED
        la a0 Black #color of old character is black
        lw a0 0(a0)
        jal setLED #set color to black
        #new position color    
        addi a1 a1 -1 #move x pos left 
        la a0 Char_col #color of new character is red
        lw a0 0(a0)
        jal setLED #set color to red
        addi s6 s6 -1
        li s5 0 #set the number of walls hit to 0
        addi s4 s4 1 #number of player moves increments
        j Next
        
    RightMove:
        #set x y position based on grid
        mv a1 s6 #move in x pos for character
        addi a1 a1 1 #plus 1 for 1 more than wall
        mv a2 s7 #move in y pos for character
        addi a2 a2 1 #plus 1 for 1 more than wall
        
        #check for wall
        li t4 7 #hold the x pos for the wall
        mv t5 a1 #put the current value of a1 in the wall
        addi t5 t5 1 #put what the new x position would be
        beq t4 t5 Restart #if the new x position will be in wall Check for restart
        
        #check if it is a Box
        # load the values of the Box and Character array
        addi s6 s6 1
        mv a0 s8 #load x pos of Box
        mv a1 s9 #load y pos of Box
        mv t1 s6 #load x pos of Character
        mv t2 s7 #load y pos of Character
        addi s6 s6 -1
        li t6 0 #holds the flag of whether the values match
        jal Match
        bne t6 zero BoxRight
        j Char_Right
        
        BoxRight:
        #set x y position based on grid
        mv a1 s8 #move in x pos for box
        addi a1 a1 1 #plus 1 for 1 more than wall
        mv a2 s9 #move in y pos for box
        addi a2 a2 1 #plus 1 for 1 more than wall
        
        #check for box aginst wall
        li t4 7 #hold the x pos for the wall
        mv t5 a1 #put the current value of a1 in the wall
        addi t5 t5 1 #put what the new x position would be
        beq t4 t5 Next #if the new x position will be in wall dont move
        
        addi a1 a1 1 #move x pos right 
        la a0 Box_col #color of new box pos is green
        lw a0 0(a0)
        jal setLED #set color to green
        addi s8 s8 1    
        
        #set color to red for new LED
        Char_Right:
        #set x y position based on grid
        mv a1 s6 #move in x pos for character
        addi a1 a1 1 #plus 1 for 1 more than wall
        mv a2 s7 #move in y pos for character
        addi a2 a2 1 #plus 1 for 1 more than wall
        #set color to black for old LED
        la a0 Black #color of old character is black
        lw a0 0(a0)
        jal setLED #set color to black
        #new position color    
        addi a1 a1 1 #move x pos right
        la a0 Char_col #color of new character is red
        lw a0 0(a0)
        jal setLED #set color to red
        addi s6 s6 1
        li s5 0 #set the number of walls hit to 0
        addi s4 s4 1 #number of player moves increments
        j Next
        
    Restart:
        addi s5 s5 1 #add one to restart counter
        li t5 4 #if counter is 4
        beq s5 t4 Wall_set #reset the led colours
    
    Next:
    
    #check if target is the same as box
    Target_Box:
    mv a0 s8 #load x pos of Box
    mv a1 s9 #load y pos of Box
    mv t1 s10 #load x pos of Target
    mv t2 s11 #load y pos of Target
    li t6 0 #holds the flag of whether the values match 
    jal Match
    bne t6 zero End_Game 
    
    #check if target is the same as character
    Target_Char:
    mv a0 s10 #load x pos of Target
    mv a1 s11 #load y pos of Target
    mv t1 s6 #load x pos of Character
    mv t2 s7 #load y pos of Character
    li t6 0 #holds the flag of whether the values match
    jal Match
    bne t6 zero Next_loop
     
    #if neither light up the target
    Update_target:
    #set x y position based on grid
    mv a1 s10 #move in x pos for target
    addi a1 a1 1 #plus 1 for 1 more than wall
    mv a2 s11 #move in y pos for target
    addi a2 a2 1 #plus 1 for 1 more than wall
    #set color to blue again
    la a0 Tar_col #color of old target is blue
    lw a0 0(a0)
    jal setLED #set color to blue    
        
    Next_loop:
    li t4 4
    blt s5 t4 GameLoop
    j Wall_set
    
    End_Game:
        
    #outputs "Player"    
    li a7, 4
    la a0 outputA
    ecall 
    
    #outputs which player    
    mv a0 s3
    li a7, 1
    ecall
    
    #outputs "completes in"    
    li a7, 4
    la a0 outputB
    ecall
    
    #outputs number of moves
    mv a0 s4
    li a7, 1
    ecall 
    
    #outputs "moves"    
    li a7, 4
    la a0 outputC
    ecall
    
    #outputs new line    
    li a7, 4
    la a0 newline
    ecall    
      
    addi sp sp -1
    sb s3 0(sp)
    addi sp sp -1
    sb s4 0(sp)
      
    bne s3 a4 nextPlay   
    # TODO: That's the base game! Now, pick a pair of enhancements and
    # consider how to implement them.
    
    #outputs "Leaderboard"
    li a7, 4
    la a0 stats
    ecall
    
    #outputs new line    
    li a7, 4
    la a0 newline
    ecall 
    
    mv t3 a4 #size of player number
    mv a3 t3
    LOOP:
    li t4 0 #number of stacks that have been checked
    li t2 0
    Sort_Init:
    addi t2 t2 1
    add t4 t2 t4
    li a5 0
     
    Bubble_Sort:
        bge t4, t3, ReLoop
        addi t4 t4 -1
        
        lb t6 0(sp) #moves
        addi sp sp 1
        addi a5 a5 1
        
        lb a1 0(sp) #player
        addi sp sp 1
        
        bne t4 zero Bubble_Sort
        lb t5 0(sp) #moves
        addi sp sp 1
        addi a5 a5 1
        
        lb a2 0(sp) #player
        addi sp sp 1
        
        blt t5 t6 Swap
        NoSwap:
            addi sp sp -1
            sb a2 0(sp)
            addi sp sp -1
            sb t5 0(sp)
            addi a5 a5 -1
            
            addi sp sp -1
            sb a1 0(sp)
            addi sp sp -1
            sb t6 0(sp)
            addi a5 a5 -1
            j Check_Stack
            
            
        Swap:
            addi sp sp -1
            sb a1 0(sp)
            addi sp sp -1
            sb t6 0(sp)
            addi a5 a5 -1
    
            addi sp sp -1
            sb a2 0(sp)
            addi sp sp -1
            sb t5 0(sp)
            addi a5 a5 -1
            j Check_Stack
            
        Check_Stack:
            bne a5 zero ReturnStack
            j Sort_Init
            
            ReturnStack:
            addi a5 a5 -1
            addi sp sp -1 
            addi sp sp -1
            j Check_Stack
 
        ReLoop:
            addi t3 t3 -1
            beqz t3 PRINT
            j LOOP    
        PRINT:
        beqz a3 exit    
        lb t2 0(sp) #moves
        addi sp sp 1
        
        lb t3 0(sp) #plyer
        addi sp sp 1
            
        #outputs "Player"    
        li a7, 4
        la a0 outputA
        ecall 
    
        #outputs which player    
        mv a0 t3
        li a7, 1
        ecall
        
        #outputs new line    
        li a7, 4
        la a0 newline
        ecall  
    
        #outputs number moves
        mv a0 t2
        li a7, 1
        ecall 
    
        #outputs "moves"    
        li a7, 4
        la a0 outputC
        ecall
    
        #outputs new line    
        li a7, 4
        la a0 newline
        ecall    
        
        addi a3 a3 -1
  
        j PRINT   
     
exit:
    li a7, 10
    ecall
    
    
# --- HELPER FUNCTIONS ---
# Feel free to use (or modify) them however you see fit
     
# Takes in a number in a0, and returns a (sort of) (okay no really) random 
# number from 0 to this number (exclusive)
rand:
    mv t0, a0
    li a7, 30
    ecall
    #remu a0, a0, t0
    #use linear congruence for psuedo-randomization
    li a5, 1297993 #load in a a-value
    li a6, 1299827 #load in a c-value
    mul a0 a0 a5 # a*x
    add a0 a0 a6 # a*x + c
    remu a0, a0, t0 #a*x + c mod m
    jr ra
    
# Takes in an RGB color in a0, an x-coordinate in a1, and a y-coordinate
# in a2. Then it sets the led at (x, y) to the given color.
setLED:
    li t1, LED_MATRIX_0_WIDTH
    mul t0, a2, t1
    add t0, t0, a1
    li t1, 4
    mul t0, t0, t1
    li t1, LED_MATRIX_0_BASE
    add t0, t1, t0
    sw a0, (0)t0
    jr ra
    
# Polls the d-pad input until a button is pressed, then returns a number
# representing the button that was pressed in a0.
# The possible return values are:
# 0: UP
# 1: DOWN
# 2: LEFT
# 3: RIGHT
pollDpad:
    mv a0, zero
    li t1, 4
pollLoop:
    bge a0, t1, pollLoopEnd
    li t2, D_PAD_0_BASE
    slli t3, a0, 2
    add t2, t2, t3
    lw t3, (0)t2
    bnez t3, pollRelease
    addi a0, a0, 1
    j pollLoop
pollLoopEnd:
    j pollDpad
pollRelease:
    lw t3, (0)t2
    bnez t3, pollRelease
pollExit:
    jr ra

Match:
    #check if (a0, a1) is the same as (t1, t2)
    li t6 1 #flag is set to one for true match
    Xcheck:
        beq a0 t1 Ycheck #if a0 and t1 are the same jump to Ycheck as x pos are true match
        li t6 0 #set flag to 0 for false match
        j End_match
    Ycheck:
        beq a1 t2 End_match #if a1 and t2 are the same jump to End_match as y pos true match
        li t6 0 #set flag to 0 for false match
    End_match:
        jr ra
        
setBlack:
    li a3 8 #set the max LED matrix height
    la a0 Black
    lw a0 0(a0)
    li a1 0 #x 0
    li a2 0 #y 0
    setWall:
        jal setLED #change color to Black
        addi a1 a1 1 # add 1 to x
        blt a1 a3 setWall #loop through entire row
        addi a2 a2 1 #add 1 to y
        li a1 0 #move back to first col
        blt a2 a3 setWall #set black for the next row
    j Wall_Front    


# Use this to read an integer from the console into a0. You're free
# to use this however you see fit.
readInt:
    addi sp, sp, -12
    li a0, 0
    mv a1, sp
    li a2, 12
    li a7, 63
    ecall
    li a1, 1
    add a2, sp, a0
    addi a2, a2, -2
    mv a0, zero
parse:
    blt a2, sp, parseEnd
    lb a7, 0(a2)
    addi a7, a7, -48
    li a3, 9
    bltu a3, a7, error
    mul a7, a7, a1
    add a0, a0, a7
    li a3, 10
    mul a1, a1, a3
    addi a2, a2, -1
    j parse
parseEnd:
    addi sp, sp, 12
    ret

error:
    li a7, 93
    li a0, 1
    ecall