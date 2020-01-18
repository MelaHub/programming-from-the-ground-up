# PURPOSE - Given a number, this program computes the square of that number. 

.section .data

.section .text

.globl square

.type square,@function
square:
  pushl %ebp
  movl %esp, %ebp

  movl 8(%ebp), %eax
  movl %eax, %ebx
  imul %ebx, %eax

  movl %ebp, %esp
  popl %ebp
  ret
