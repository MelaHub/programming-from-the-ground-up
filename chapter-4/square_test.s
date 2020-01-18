# PURPOSE - Given a number, this program tests the square function

.section .data

.section .text

.globl _start

_start:
  pushl $5
  call square
  addl $4, %esp
  movl %eax, %ebx
  movl $1, %eax
  int $0x80
