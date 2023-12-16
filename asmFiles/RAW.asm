org 0x0000
ori $5, $0, 0x100
ori $6, $0, 0x200
sw $5, 0($6)#stores 100 in ram address 200
lw $4, 0($6)#tries to read ram address 200
nop
nop
nop
sw $4, 4($6)#stores register 4 to 204, should match address 200 if correct
halt

org   0x200
cfw   0xBEEF#should be 100100
