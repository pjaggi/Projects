main:

ori   $1, $zero, 0xF100
ori   $2, $zero, 0xF000
lw $2, 0($1)
lw $3, 0($2)
halt

#same index different tags
 org   0x00F0
 cfw   0xF000
 cfw   0xF100
