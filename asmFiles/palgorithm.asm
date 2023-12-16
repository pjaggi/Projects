#----------------------------------------------------------
# First Processor
#----------------------------------------------------------
  org   0x0000              # first processor p0
  ori   $sp, $zero, 0x3ffc  # stack
  
#load seed value to a0
  ori   $t2, $0, seed
  lw    $a0, 0($t2)

#loop - if count_create dne 256
top_0:
  ori $5, $0, 256
  ori $4, $0, count_create
  lw  $4, 0($4)
  beq $4, $5, end_0
  jal program_0
  j top_0

end_0:
  halt

# pass in an address to lock function in argument register 0
# returns when lock is available
lock:
aquire:
  ll    $t0, 0($a0)         # load lock location
  bne   $t0, $0, aquire     # wait on lock to be open
  addiu $t0, $t0, 1
  sc    $t0, 0($a0)
  beq   $t0, $0, lock       # if sc failed retry
  jr    $ra


# pass in an address to unlock function in argument register 0
# returns when lock is free
unlock:
  sw    $0, 0($a0)
  jr    $ra

# main program - genCrc, incNumAvail
program_0:
  push  $ra

  jal   genCRC

  pop   $ra
  jr    $ra 


# main function - generate crc
genCRC:
  push  $ra                 # save return address

  #load seed value to a0
  ori   $t2, $0, seed
  lw    $a0, 0($t2)
  
  #genCRC
  jal crc32

  ori   $a0, $zero, lock1      # move lock to arguement register
  jal   lock                # try to aquire the lock
  # critical code segment

  jal pushToStack

  #increment counters
  jal   incNumAvail
    
  # critical code segment
  ori   $a0, $zero, lock1      # move lock to arguement register
  jal   unlock              # release the lock

  ori   $t4, $0, seed
  sw    $v0, 0($t4)

  pop   $ra                 # get return address
  jr    $ra                 # return to caller

pushToStack:
  push  $ra

  #load seed pointer to $t1, value $t5
  ori   $t1, $0, seedPointer
  lw    $t5, 0($t1)

  #store seedPointer + 4 to SP
  addi $t5, $t5, 4
  sw $t5, 0($t1)
  add $18, $0, $t5
    
  #store random[x] to new SP
  sw    $v0, 0($t5)

  #store random[x] to original seed for next crc gen
  ori   $t2, $0, seed
  sw    $v0, 0($t2)

  pop   $ra                 # get return address
  jr    $ra                 # return to caller

incNumAvail:
  push  $ra
    #get current numAvail addr
  ori   $t1, $zero, numAvail
    #load numAvail
  lw    $t2, 0($t1)
    #increment numAvail
  addi $t2, $t2, 1
    #store numAvail to numAvail addr
  sw    $t2, 0($t1)
  add   $21, $0, $t2

  jal inc_count_create

  pop   $ra                 # get return address
  jr    $ra                 # return to caller

inc_count_create:
  push  $ra
  
  ori   $t1, $0, count_create
  lw    $t2, 0($t1)
  addi  $t2, $t2, 1
  sw    $t2, 0($t1)
  
  pop   $ra
  jr    $ra 



#----------------------------------------------------------
# Second Processor
#----------------------------------------------------------
  
  org   0x200               # second processor p1
  ori   $sp, $zero, 0x7ffc  # stack

#loop until 256 requests filled - if count_destroy dne 256
top_1:
  ori $5, $0, 256
  ori $4, $0, count_destroy
  lw  $4, 0($4)
  
  beq $4, $5, end_processor_1
  jal program_1
  j top_1

end_processor_1:
  #load average
  ori $t2, $0, average
  lw $a0, 0($t2)
  #shift to correct average?
  ori $t7, $0, 8
  srlv $a0, $t7, $a0
  #store average
  ori $t2, $0, average
  sw $a0, 0($t2)
  add $27, $0, $a0

  halt

# main program - while numAvail is not 0: remcrc, decrement numAvail
program_1:
  push  $ra

  ori   $t0, $0, numAvail #load numAvail to t1
  lw    $t1, 0($t0)

  beq   $t1, $0, end_program_1 #if numAvail is 0, go to end_program_1
  jal   remCRC              # go to program

end_program_1:
  pop   $ra                 # get return address
  jr    $ra                 # return to caller

# main function - generate crc
remCRC:
  push  $ra                 # save return address

  #do calculations first, then pop off the stack -> P0 push on stack then increments, so:
  #P1 decrement then pop off stack

  #do min, max, avg -> v0 hold current CRC
  #need to do only on lower 16 -> is this my issue?
  jal min
  jal max
  jal avg
  
  ori   $a0, $zero, lock1      # move lock to arguement register
  jal   lock                # try to aquire the lock
  # critical code segment

  #load seed offset to $t1
  ori   $t1, $0, seedPointer
  lw    $t5, 0($t1)

  #store seedPointOffest - 4 to SPO
  addi $t3, $t5, -4
  sw $t3, 0($t1)
  add   $19, $0, $t5
  add   $20, $0, $t3

  jal   decNumAvail
    
  # critical code segment
  ori   $a0, $zero, lock1      # move lock to arguement register
  jal   unlock              # release the lock

  #debug
  ori $t2, $0, seed
  lw  $24, 0($t2)

  pop   $ra                 # get return address
  jr    $ra                 # return to caller

inc_count_destroy:
  push   $ra
  
  ori   $t1, $0, count_destroy
  lw    $t2, 0($t1)
  addi  $t2, $t2, 1
  sw    $t2, 0($t1)
  
  pop   $ra
  jr    $ra

#edited min to compare stored min to current CRC (v0)
min:
    push $ra
    
    #load current min
    ori $t1, $0, minimum
    lw  $v1, 0($t1)
    add  $23, $0, $v1

    #load current value at SPO
    ori $t2, $0, seedPointer
    lw  $v0, 0($t2)
    lw  $v0, 0($v0)
    add $21, $0, $t2
    add $22, $0, $v0

    #take lower 16 bits of value
    ori $t7, $0, 16
    #SLXV   $rd,$rs,$rt   R[rd] <= R[rt] << [0:4] R[rs]
    sllv $v0, $t7, $v0
    srlv $v0, $t7, $v0
    add  $24, $0, $v0

    #if v0 < min store v0
    slt $5, $v0, $v1
    beq $5, $0, min_end
    sw  $v0, 0($t1)
    add $26, $0, $v0

min_end:
    pop   $ra
    jr    $ra

#edited max to compare stored max to current CRC (v0)
max:
    push $ra
    #load current max
    ori $t1, $0, maximum
    lw  $v1, 0($t1)

    #load current value at SPO
    ori $t2, $0, seedPointer
    lw  $v0, 0($t2)
    lw  $v0, 0($v0)

    #take lower 16 bits of value
    ori $t7, $0, 16
    #SLXV   $rd,$rs,$rt   R[rd] <= R[rt] << [0:4] R[rs]
    sllv $v0, $t7, $v0
    srlv $v0, $t7, $v0

    #if v0 > max:
    slt $5, $v1, $v0
    beq $5, $0, max_end #else end

    #store v0
    sw    $v0, 0($t1)
    add  $25, $0, $v0

max_end:
    pop   $ra
    jr    $ra

avg: #running average
    push $ra

    #load current seedPointer value (a0)
    ori $t1, $0, seedPointer
    lw  $a0, 0($t1)
    lw  $a0, 0($a0)

    #take lower 16 bits of value at seedPointer
    ori $t7, $0, 16
    #SLXV   $rd,$rs,$rt   R[rd] <= R[rt] << [0:4] R[rs]
    sllv $a0, $t7, $a0
    srlv $a0, $t7, $a0
    
    #load sum (a1)
    ori $t2, $0, sum
    lw  $a1, 0($t2)
    
    #add to sum
    add $a0, $a1, $a0
    
    #store sum
    ori $t2, $0, sum
    sw $a0, 0($t2)
    add $30, $0, $a0

    #store average
    ori $t2, $0, average
    sw $a0, 0($t2)
    add $27, $0, $a0

    pop   $ra
    jr    $ra 

decNumAvail:
  push  $ra                 # save return address

    #get current numAvail addr
  ori   $t1, $zero, numAvail
    #load numAvail
  lw    $t2, 0($t1)
    #decrement numAvail
  addi $t2, $t2, -1
  sw    $t2, 0($t1)
  
  #debug
  #addi   $30, $0, 10
  #add   $18, $0, $t2

  jal inc_count_destroy

  pop   $ra                 # get return address
  jr    $ra                 # return to caller

crc32:
  push $ra

  lui $t1, 0x04C1
  ori $t1, $t1, 0x1DB7
  or $t2, $0, $0
  ori $t3, $0, 32

l1:
  slt $t4, $t2, $t3
  beq $t4, $zero, l2

  ori $t5, $0, 31
  srlv $t4, $t5, $a0
  ori $t5, $0, 1
  sllv $a0, $t5, $a0
  beq $t4, $0, l3
  xor $a0, $a0, $t1
l3:
  addiu $t2, $t2, 1
  j l1
l2:
  or $v0, $a0, $0

  pop $ra
  jr $ra


org 0x500
numAvail: #counts how large the stack is
    cfw 0
org 0x504
count_create: #counts total genCRC transactions, stops generation at 256
    cfw 0
org 0x508
count_destroy: #counts total remCRC transactions, stops delete at 256
    cfw 0
org 0x50C
average: #sum / count_destroy
    cfw 0
org 0x510
sum: #running sum of all lower 16 values
    cfw 0
org 0x514
minimum: #min of genCRC tokens
    cfw 0xFFFFFFF
org 0x518
maximum: #max of genCRC tokens
    cfw 0
org 0x524
seedPointer: #pointer to current position in stack
    cfw 0xB00

org 0x528
lock1: #lock 1 -> genCRC and remCRC
    cfw 0

org 0xB00
seed: #original seed, can be modified to change CRC tokens
    cfw 0x7F52
