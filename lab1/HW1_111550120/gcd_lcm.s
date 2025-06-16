.data
    input_msg1: .asciiz "Please enter the first number: "
    input_msg2: .asciiz "Please enter the second number: "
    output_msg: .asciiz " "  # space between gcd and lcm result
    newline:    .asciiz "\n"   # newline

.text
.globl main

#------------------------- main -----------------------------
main:
# print "Please enter the first number: "
    li      $v0, 4              # syscall for print string
    la      $a0, input_msg1     # load address of input msg1 to a0
    syscall

# read first integer from v0 to a0
    li      $v0, 5              # syscall for read int
    syscall
    move    $t0, $v0            # store a in $t0

# load second int to a1
    li      $v0, 4              # syscall for print_string
    la      $a0, input_msg2     # load address of input_msg2
    syscall

    li      $v0, 5              # syscall for read_int
    syscall
    move    $t1, $v0            # store b in $t1

# jump to gcd function
    move    $a0, $t0            # pass first number as argument
    move    $a1, $t1            # pass second number as argument
    jal     gcd
    move    $t2, $v0            # store gcd result in $t2

# jump to lcm function
    move    $a0, $a0            # restore first number
    move    $a1, $a1            # restore second number
    move    $a2, $t2            # pass gcd result to lcm
    jal     lcm
    move    $t3, $v0            # store lcm result in $t3

# print gcd result
    li      $v0, 1              # syscall for print int
    move    $a0, $t2            # move gcd result into $a0
    syscall

# print output_msg
    li      $v0, 4              # syscall for print string
    la      $a0, output_msg     # load address of output_msg into $a0
    syscall

# # print lcm result
    li      $v0, 1              # syscall for print int
    move    $a0, $t3            # move lcm result into $a0
    syscall

# print a newline at the end
    li      $v0, 4              # syscall for print string
    la      $a0, newline        # load address of newline string into $a0
    syscall

# exit the program
    li      $v0, 10             # syscall for exit
    syscall

#------------------------- GCD Function -----------------------------
gcd:
    addi    $sp, $sp, -12       # Allocate space on stack for 3? items
    sw      $ra, 8($sp)         # Save return address
    sw      $a0, 0($sp)         # Save a
    sw      $a1, 4($sp)         # Save b
    move    $t0, $a0            # t0 = a
    move    $t1, $a1            # t1 = b

gcd_loop:
    beqz    $t1, gcd_done       # If b == 0, return a as GCD

    move    $t2, $t1            # temp = b
    rem     $t1, $t0, $t1       # b = a % b
    move    $t0, $t2            # a = temp
    j       gcd_loop            # Repeat until b == 0

gcd_done:
    move    $v0, $t0            # Store final GCD in $v0

    lw      $a0, 0($sp)         # Restore original a
    lw      $a1, 4($sp)         # Restore original b
    lw      $ra, 8($sp)         # Restore return address
    addi    $sp, $sp, 12        # Restore stack
    jr      $ra                 # Return to caller

#------------------------- LCM Function -----------------------------
lcm:
    addi    $sp, $sp, -16       # Allocate space for return address and arguments
    sw      $ra, 12($sp)        # Save return address
    sw      $a0, 0($sp)         # Save a
    sw      $a1, 4($sp)         # Save b
    sw      $a2, 8($sp)         # Save gcd

    beqz    $a2, lcm_zero       # If GCD is 0, return 0 (error case)

    mult    $a0, $a1            # Multiply a and b
    mflo    $t0                 # product in $t0
    mfhi    $t1                 # upper 32 bits in $t1 (check overflow)

    bnez    $t1, lcm_overflow   # overflowed
    div     $t0, $a2            # Divide (a * b) by gcd
    mflo    $v0                 # Retrieve the quotient (LCM result) and store it in $v0
    j       lcm_done

lcm_zero:
    li      $v0, 0              # If GCD is zero, return zero (error case)
    j       lcm_done

lcm_overflow:
    li      $v0, -1             # Indicate overflow with -1 (adjust as needed)

lcm_done:
    lw      $a0, 0($sp)         # Restore a
    lw      $a1, 4($sp)         # Restore b
    lw      $a2, 8($sp)         # Restore gcd
    lw      $ra, 12($sp)        # Restore return address
    addi    $sp, $sp, 16        # Restore stack pointer
    jr      $ra                 # Return to caller
