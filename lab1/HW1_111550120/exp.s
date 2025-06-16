.data
    input_msg1: .asciiz "Enter base (positive integers): "
    input_msg2: .asciiz "Enter exponent (positive integers): "
    newline:    .asciiz "\n"
    debug_enter: .asciiz "Entering power function: base = "
    debug_exp: .asciiz ", exponent = "
    debug_recurse: .asciiz "Calling power with exp-1 = "
    debug_after: .asciiz "After recursion: result = "
    debug_multiply: .asciiz "Multiplying result by base = "
    debug_base_case: .asciiz "Base case reached, returning 1\n"

.text
.globl main

#------------------------- main -----------------------------
main:
    # Input base
    li      $v0, 4
    la      $a0, input_msg1
    syscall

    li      $v0, 5
    syscall
    move    $t0, $v0  # Store base in $a0

    # Input exponent
    li      $v0, 4
    la      $a0, input_msg2
    syscall

    li      $v0, 5
    syscall
    move    $t1, $v0  # Store exponent in $a1


    move    $a0, $t0
    move    $a1, $t1 
    jal     power
    move    $t2, $v0  # Store result in $t0

    # Print result
    li      $v0, 1
    move    $a0, $t2
    syscall

    # Print newline
    li      $v0, 4
    la      $a0, newline
    syscall

    # Exit
    li      $v0, 10
    syscall

#------------------------- power (Recursive) -----------------------------
power:
    beq     $a1, $zero, power_base_case

    addi    $sp, $sp, -16       # Allocate space for 4 items
    sw      $ra, 12($sp)        # Save return address
    sw      $a0, 8($sp)         # Save base
    sw      $a1, 4($sp)         # Save exponent
    sw      $v0, 0($sp)         # Save previous return value

    addi    $a1, $a1, -1        # exp--
    jal     power               

    lw      $a1, 4($sp)         # Restore exponent
    lw      $a0, 8($sp)         # Restore base
    lw      $ra, 12($sp)        # Restore return address
    lw      $t0, 0($sp)         # Load previous return value

    addi    $sp, $sp, 16        # Pop stack
    mul     $v0, $v0, $a0       # v0 = power(base, exp-1) * base
    jr      $ra

power_base_case:
    li      $v0, 1             
    jr      $ra
