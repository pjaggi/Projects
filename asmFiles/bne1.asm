org 0x0000
ori $2, $0, 0x0001
ori $3, $0, 0x0001
bne $2, $3, loop
ori $4, $0, 0x0002
halt
loop: ori $4, $0, 0x0001
halt
