# PURPOSE - Given a number, this program computes the factorial. For example, the factorial of 3 is 3 * 2 * 1, or 6.
#           The factorial of 4 is 4 * 3 * 2 * 1, or 24, and so on.

.section .data

.section .text

.globl _start
.globl factorial # this is unneeded unless we want to share this function among other programs

_start:
  pushl $4
  call factorial
  addl $4, %esp
  movl %eax, %ebx
  movl $1, %eax
  int $0x80

.type factorial,@function
factorial:
  pushl %ebp
  movl %esp, %ebp
  movl 8(%ebp), %eax  # This moves the first argument to %eax; 4(%ebp) holds the return address

  cmpl $1, %eax
  je end_factorial
  decl %eax
  pushl %eax
  call factorial
  movl 8(%ebp), %ebx  # eax has the return value, so we reload out parameter into ebx
  imul %ebx, %eax

end_factorial:
  movl %ebp, %esp
  popl %ebp
  ret
