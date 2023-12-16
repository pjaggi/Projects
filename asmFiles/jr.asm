org 0x0000

ori $4, $0, 0x0001
ori $5, $0, 0x00F4
ori $15, $0, place
jr $15
ori $10, $0, 0x00F0
sw $10, 0($10) 
halt
place:
ori $6, $0, 0x00F8
sw $6, 0($6)
halt
