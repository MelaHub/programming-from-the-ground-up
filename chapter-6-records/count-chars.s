# PURPOSE: count the characters until a null byte is reached.
# INPUT: the address of the character string
# OUTPUT: returns the count in %eax

# PROCESS:
#   Registers used:
#     %ecx - character count
#     %al - current characters
#     %adx - current character address

.type count_chars, @function
.globl count_chars

# This is where our one parameter is on the stack
.equ ST_STRING_START_ADDRESS, 8
count_chars:
  pushl %ebp
  movl %esp, %ebp

  # counter starts at zero
  movl $0, %ecx

  # starting address of data
  movl ST_STRING_START_ADDRESS(%ebp), %edx

count_loop_begin:
  # grab the current character
  movb (%edx), %al
  # is it null?
  cmpb $0, %al
  # if yes, we're done
  je count_loop_end
  # otherwise, increment the counter and the pointer
  incl %ecx
  incl %edx
  # go back to the beginning of the loop
  jmp count_loop_begin

count_loop_end:
  # we're done. move the count into %eax and return
  movl %ecx, %eax

  popl %ebp
  ret
