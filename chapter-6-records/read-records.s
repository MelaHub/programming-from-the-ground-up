.include "linux.s"
.include "record-def.s"

.section .data
file_name:
  .ascii "test.dat\0"

.section .bss
.lcomm record_buffer, RECORD_SIZE

.section .text
.globl _start

_start:
  # these are the locations on the stack where we will store the input and output descriptors (we could have used memory
  # addresses in a .data section instead)
  .equ ST_INPUT_DESCRIPTOR, -4
  .equ ST_OUTPUT_DESCRIPTOR, -8

  # copy the stack pointer to %ebp
  movl %esp, %ebp
  # allocate space to hold the file descriptor
  subl $8, %esp

  # open the file
  movl $SYS_OPEN, %eax
  movl $file_name, %ebx
  movl $0, %ecx # read only
  movl $0666, %edx
  int $LINUX_SYSCALL
  movl %eax, ST_INPUT_DESCRIPTOR(%ebp)

  movl $STDOUT, ST_OUTPUT_DESCRIPTOR(%ebp)

record_read_loop:
  pushl ST_INPUT_DESCRIPTOR(%ebp)
  pushl $record_buffer
  call read_record
  addl $8, %esp

  # returns the number of bytes read. If it isn't the same number we requested, then it's either an end of file or an
  # error
  cmpl $RECORD_SIZE, %eax
  jne finished_reading

  # otherwise, print out the first name but first, we must know it's size
  pushl $RECORD_FIRSTNAME + record_buffer
  call count_chars
  addl $4, %esp

  movl %eax, %edx
  movl ST_OUTPUT_DESCRIPTOR(%ebp), %ebx
  movl $SYS_WRITE, %eax
  movl RECORD_FIRSTNAME + record_buffer, %ecx
  int $LINUX_SYSCALL

  pushl ST_OUTPUT_DESCRIPTOR(%ebp)
  call write_newline
  addl $4, %esp

  jmp record_read_loop

finished_reading:
  movl $SYS_EXIT, %eax
  movl $0, %ebx
  int $LINUX_SYSCALL
