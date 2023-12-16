ori $2, $0, 0xBEEF
ori $1, $0, 0x64

jal something

sw $2, 0($1)
halt
sw $2, 4($1)

something:
    jr $31

