.include "linux.s"
.include "record-def.s"

# PURPOSE: This function writes a record to the given file descriptor
# INPUT: The file descriptor and a buffer
# OUTPUT: This function produces a status code

# STACK LOCAL VARIALES
.equ ST_WRITE_BUFFER, 8
.equ ST_FILEDES, 12
.section .text
.globl write_record
.type write_record, @function

write_record:
  pushl %ebp
  movl %esp, %ebp

  pushl %ebx
  movl $SYS_WRITE, %eax
  movl ST_FILEDEX(%ebp), %ebx
  movl ST_WRITE_BUFFER(%ebp), %ecx
  movl $RECORD_SIZE, %edx
  int $LINUT_SYSCALL

  # NOTE: %eax has the return value, which we will give back to our calling program
  popl %ebx

  movl %ebp, %esp
  popl $ebp
  ret
