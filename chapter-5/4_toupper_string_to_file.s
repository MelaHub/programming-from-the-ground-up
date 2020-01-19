# PURPOSE: This program writes the string "Hey, diddle diddle!" to a file names "heynow.txt"

.section .data

file_name:
  .ascii "heynow.txt\0"

write_string:
  .ascii "Hey, diddle diddle!\0"

len_write_string: 
  .int 20

#######CONSTANTS#######

# system call numbers
.equ SYS_OPEN, 5
.equ SYS_WRITE, 4
.equ SYS_READ, 3
.equ SYS_CLOSE, 6
.equ SYS_EXIT, 1

# options for file open
.equ O_RDONLY, 0
.equ O_CREAT_WRONLY_TRUNC, 03101

# standard file descriptors
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

# system call interrupt
.equ LINUX_SYSCALL, 0x80
.equ END_OF_FILE, 0
.equ NUMBER_ARGUMENTS, 2

.section .bss

.section .text

#STACK POSITIONS
.equ ST_SIZE_RESERVE, 4
.equ ST_FD_OUT, -4

.globl _start
_start:
###INITIALIZE PROGRAM###
# save the stack pointer
movl %esp, %ebp

# Allocate space for our file descriptors on the stack
subl $ST_SIZE_RESERVE, %esp

open_files:

open_fd_out:
    ###OPEN OUTPUT FILE###
    movl $SYS_OPEN, %eax
    movl $file_name, %ebx
    movl $O_CREAT_WRONLY_TRUNC, %ecx
    movl $0666, %edx # Permission set for the new file if it's created
    int $LINUX_SYSCALL

store_fd_out:
    movl %eax, ST_FD_OUT(%ebp)

###WRITE THE BLOCK OUT TO THE OUTPUT FILE###
movl len_write_string, %edx
movl $SYS_WRITE, %eax
movl ST_FD_OUT(%ebp), %ebx
movl $write_string, %ecx
int $LINUX_SYSCALL

###CLOSE THE FILES###
movl $SYS_CLOSE, %eax
movl ST_FD_OUT(%ebp), %ebx
int $LINUX_SYSCALL

##EXIT@@@
movl $SYS_EXIT, %eax
movl $0, %ebx
int $LINUX_SYSCALL

