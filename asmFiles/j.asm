org 0x0000


# addi $1, $1, 0xFF
# addi $2, $1, 0x88

# beq $1,$1,mult 
# sw $1, 500($0)
# halt

# mult: 
# sw $2, 500($0)
# halt





ori $5, $0, mult

addi $1, $1, 0xFF
addi $2, $1, 0x88
addi $4, $0, end

beq $1, $1, mult 
    sw $1, 500($0)  
    halt

mult: 
    sw $2, 500($0)
    bne $1, $2, end 
    sw $1, 500($0)

end:
    sw $2, 1000($0)
    halt
    sw $2, 700($0)

