.data
    input_msg:  .asciiz "Enter five positive integers: "
    output_msg: .asciiz " "
    newline:    .asciiz "\n"

.text
.globl main
#------------------------- main -----------------------------
main:
    li $v0, 4
    la $a0, input_msg
    syscall

    li $v0, 5
    syscall
    move $t0, $v0

    li $v0, 5
    syscall
    move $t1, $v0

    li $v0, 5
    syscall
    move $t2, $v0

    li $v0, 5
    syscall
    move $t3, $v0

    li $v0, 5
    syscall
    move $t4, $v0

    move $a0, $t0 
    move $a1, $t1  
    move $a2, $t2 
    move $a3, $t3  
    move $t5, $t4  

    jal findMaxMin

    li $v0, 1
    move $a0, $s1
    syscall

    li $v0, 4
    la $a0, output_msg
    syscall

    li $v0, 1
    move $a0, $s0
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    # Exit program
    li $v0, 10
    syscall

findMaxMin:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s2, 0($sp)
    
    move $s0, $a0
    move $s1, $a0

    bge $a1, $s0, update_max1
    move $s0, $a1
update_max1:
    ble $a1, $s1, update_min1
    move $s1, $a1
update_min1:
    
    bge $a2, $s0, update_max2
    move $s0, $a2
update_max2:
    ble $a2, $s1, update_min2
    move $s1, $a2
update_min2:
    
    bge $a3, $s0, update_max3
    move $s0, $a3
update_max3:
    ble $a3, $s1, update_min3
    move $s1, $a3
update_min3:
    
    bge $t5, $s0, update_max4
    move $s0, $t5
update_max4:
    ble $t5, $s1, update_min4
    move $s1, $t5
update_min4:
    lw $ra, 4($sp)
    lw $s2, 0($sp)
    addi $sp, $sp, 8
    jr $ra