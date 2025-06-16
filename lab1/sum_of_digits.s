.data
input_msg:    .asciiz "Enter an integer: "
output_msg:   .asciiz " "
newline:      .asciiz "\n"

.text
.globl main

main:
    li $v0, 4
    la $a0, input_msg
    syscall

    li $v0, 5
    syscall
    move $a0, $v0 

    jal sumOfDigits
    move $t0, $v0  

    li $v0, 1
    move $a0, $t0
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    li $v0, 10
    syscall

sumOfDigits:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $t1, 0($sp)

    move $t1, $a0  
    li $v0, 0     

sum_loop:
    beq $t1, $zero, sum_done 
    div $t1, $t1, 10       
    mfhi $t2                
    add $v0, $v0, $t2  
    mflo $t1           
    j sum_loop

sum_done:
    lw $ra, 4($sp)
    lw $t1, 0($sp)
    addi $sp, $sp, 8
    jr $ra
