org 0x0000
ori $5, $0, 0x100
ori $6, $0, 0x200
lw $5, 0($6)#tries to read ram address 200
sw $5, 4($6)#stores 100 in ram address 204
halt

org   0x200
cfw   0xBEEF#should be BEEFBEEF
