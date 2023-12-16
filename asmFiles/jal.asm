org 0x0000

ori $4, $0, 0x0001
ori $5, $0, 0x0002
jal place
ori $10, $0, 0x00F0
sw $10, 0($10) 
ori $6, $0, 0x0003
sw $6, 0($6) 
halt

place:
ori $9, $0, 0x0006
ori $10, $0, 0x0007

halt
