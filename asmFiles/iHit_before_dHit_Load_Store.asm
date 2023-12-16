main:
ori $10, $0, 8

loop:
ori   $1, $zero, 0xF0
lw $2, 0($10)
addi $10, $10, -4
bne $10, $0, loop
halt

 org   0x00F0
 cfw   0xF000
