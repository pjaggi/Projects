main:
    #Init Stack
    ori $29, $0, 0xFFFC #0xFFFC	#init stack to 0xFFFC

    #push vars on the stack

    #Push A
    addi    $3, $0, 100
    push $3

    #Push B
    addi    $4, $0, 30
    push $4

    #call mult
    jal mult

    #pop result to $2
    pop $2

    halt

#mult algorithm
mult:

    # Initialize result to 0
    addi $2, $0, 0

    #jump to the loop
    j mult_loop

mult_loop:
    # Load stack values
    pop $8
    pop $7

    #if B is 0, return 
    beq		$8, $0, mult_end

    #else add A to Result and decrement B
    add		$2, $2, $7
    push $7
    addi	$8, $8, -1
    push $8
    
    j	mult_loop	# jump to mult_loop
    
    
mult_end:

    #Push Result
    push $2
    
    #return to jal call
    jr $31					# jump to $ra(31), (return to calling func)
