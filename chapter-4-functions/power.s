# PURPOSE: Program to illustrate how function work
#          This program will compute the value of 2 ^ 3 + 5 ^ 2

# Everything in the main program is stored in registers, so the data section doesn't have anything

.section .data

.section .text

.globl _start

_start:
  push $3
  push $2
  call power
  addl $8, %esp        # move the stack pointer back

  pushl %eax           # save the first answer before calling the next function
  pushl $2
  pushl $5
  call power
  addl $8, %esp        # move the stack pointer back

  popl %ebx            # the second answer is already in %eax. We saved the first answer onto the stack, so now we can
                       # just pop it out into %ebx

  addl %eax, %ebx      # add them together
                       # the result is in %ebx

  movl $1, %eax
  int $0x80

# PURPOSE: This function is sed to compute the value of a number raised to a power.

# INPUT:   First argument - the base number
#          Second argument - the power to raise it to

# OUTPUT:  Will give the result as a return value

# NOTES:   The power must be 1 or greater

# VARIABLES:
#          %ebx - holds the base number
#          %ecx - holds the power

#          -a(%ebp) - holds the current result
#          %eax is used for temporary storage
.type power, @function
power:
  pushl %ebp           # save old base pointer
  movl %esp, %ebp      # make stack pointer to the base pointer
  subl $4, %esp        # get room for out local storage

  movl 8(%ebp), %ebx   # put first argument in %ebx
  movl 12(%ebp), %ecx  # put second argument in %ecx

  movl %ebx, -4(%ebp)  # store current result

power_loop_start:
  cmpl $0, %ecx        # if the power is 0, just return 1
  je zero_power

  cmpl $1, %ecx        # if the power is 1, we are done
  je end_power

  movl -4(%ebp), %eax
  imull %ebx, %eax     
  movl %eax, -4(%ebp)
  decl %ecx            # decrease the power
  jmp power_loop_start

zero_power:
  movl $1, -4(%ebp)    # if the power is 0, just return 1

end_power:
  movl -4(%ebp), %eax
  movl %ebp, %esp
  popl %ebp
  ret

