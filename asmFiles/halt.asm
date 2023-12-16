org 0x0000
ori $10, $0, 0x0FF4
sw $10, 0($10)
ori $2, $0, 0x0001 #put store here, put to memory
ori $3, $0, 0x0001
add $4, $2, $3
halt
ori $11, $0, 0x00F8
sw $11, 0($11) #store year - 2000
ori $9, $0, 0x0002 #put store here
ori $10, $0, 0x0002
add $11, $2, $3
loop: j loop
