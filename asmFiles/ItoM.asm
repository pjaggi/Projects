#I TO M
org 0x0000
ori $10, $0, 8
sw $1, 0($10)
halt

org 0x0200
ori $11, $0, 8
sw $2, 0($10)
halt

org 0x00F0
cfw 0xF000