# PURPOSE: This program converts an input file to an output file with all letters converted to uppercase.

# PROCESSING: 1) Open the input file
#             2) Open the output file
#             3) While we're not at the end of the input file
#                a) read part of file into our memory buffer
#                b) go through each byte of memory
#                      if the byte is a lower-case letter convert it to uppercase
#                c) write the memory buffer to output file

.section .data

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
# Buffer: this is where the data is loaded into from the data file and written from into the output file. This should
# never exceed 16000
.equ BUFFER_SIZE, 500
.lcomm BUFFER_DATA, BUFFER_SIZE

.section .text

#STACK POSITIONS
.equ ST_SIZE_RESERVE, 8
.equ ST_FD_IN, -4
.equ ST_FD_OUT, -8
.equ ST_ARGC, 0 # number of arguments
.equ ST_ARGV_0, 4 # name of program
.equ ST_ARGV_1, 8 # input file name
.equ ST_ARGV_2, 12 # output file name

miao: .ascii "ciao\0"
miao_end: .equ miao_len, miao_end - miao
.globl _start
_start:
###INITIALIZE PROGRAM###
# save the stack pointer
movl %esp, %ebp

# Allocate space for our file descriptors on the stack
subl $ST_SIZE_RESERVE, %esp

movl $SYS_WRITE, %eax
movl $STDOUT, %ebx
movl ST_ARGC(%ebp), %ecx
movl $4, %edx
int $LINUX_SYSCALL
# movl $SYS_WRITE, %eax
# movl $STDOUT, %ebx
# movl $miao, %ecx
# movl $miao_len, %edx
# int $LINUX_SYSCALL

# If no arguments then use STDIN STDOUT
cmpl $NUMBER_ARGUMENTS, ST_ARGC(%ebp)
je open_files

store_fd_in_stdin:
    movl $STDIN, ST_FD_IN(%ebp)

store_fd_out_stdout:
    movl $STDOUT, ST_FD_OUT(%ebp)

jmp read_loop_begin

open_files:
open_fd_in:
    ###OPEN INPUT FILE###
    movl $SYS_OPEN, %eax
    movl ST_ARGV_1(%ebp), %ebx
    movl $O_RDONLY, %ecx
    movl $0666, %edx # This doesn't really matter for reading
    int $LINUX_SYSCALL

store_fd_in:
    movl %eax, ST_FD_IN(%ebp)

open_fd_out:
    ###OPEN OUTPUT FILE###
    movl $SYS_OPEN, %eax
    movl ST_ARGV_2(%ebp), %ebx
    movl $O_CREAT_WRONLY_TRUNC, %ecx
    movl $0666, %edx # Permission set for the new file if it's created
    int $LINUX_SYSCALL

store_fd_out:
    movl %eax, ST_FD_OUT(%ebp)

###BEGIN MAIN LOOP###
read_loop_begin:
    
    ###READ IN A BLOCK FROM THE INPUT FILE###
    movl $SYS_READ, %eax
    movl ST_FD_IN(%ebp), %ebx
    movl $BUFFER_DATA, %ecx
    movl $BUFFER_SIZE, %edx
    int $LINUX_SYSCALL

    ###EXIT IF WE'VE REACHED THE END###
    # check for end of file market
    cmpl $END_OF_FILE, %eax # eax has the size of buffer read
    jle end_loop

continue_read_loop:
    ###CONVERT THE BLOCK TO UPPER CASE###
    pushl $BUFFER_DATA
    pushl %eax
    call convert_to_upper
    popl %eax
    addl $4, %esp # restore %esp

    ###WRITE THE BLOCK OUT TO THE OUTPUT FILE###
    movl %eax, %edx
    movl $SYS_WRITE, %eax
    movl ST_FD_OUT(%ebp), %ebx
    movl $BUFFER_DATA, %ecx
    int $LINUX_SYSCALL

    ###CONTINUE THE LOOP###
    jmp read_loop_begin

end_loop:
    ###CLOSE THE FILES###
    movl $SYS_CLOSE, %eax
    movl ST_FD_OUT(%ebp), %ebx
    int $LINUX_SYSCALL

    movl $SYS_CLOSE, %eax
    movl ST_FD_IN(%ebp), %ebx
    int $LINUX_SYSCALL

##EXIT@@@
movl $SYS_EXIT, %eax
movl $0, %ebx
int $LINUX_SYSCALL

#PURPOSE: This function actually does the conversion to upper case for a block
#INPUT: The first parameter is the length of the block of memory to convert
#       The second parameter is the starting address of that block of memory
#OUTPUT: This function overwrites the current buffer with the upper casified version
#VARIABLES: %eax beginning of buffer
#           %ebx length of buffer
#           %edi current buffer offset
#           %cl current byte being examined

###CONSTANTS###
# The lower boundary of our search
.equ LOWERCASE_A, 'a'
# The upper boundary of our search
.equ LOWERCASE_Z, 'z'
# Conversion between upper and lower case
.equ UPPER_CONVERSION, 'A' - 'a'

###STACK STUFF###
.equ ST_BUFFER_LEN, 8 
.equ ST_BUFFER, 12

convert_to_upper:
    pushl %ebp
    movl %esp, %ebp

    ###SET UP VARIABLES###
    movl ST_BUFFER(%ebp), %eax
    movl ST_BUFFER_LEN(%ebp), %ebx
    movl $0, %edi

    # if a buffer with zero length was given to us, just leave
    cmpl $0, %ebx
    je end_convert_loop

    convert_loop:
        movb (%eax, %edi, 1), %cl   # get the current byte

        # go to the next byte unless it is between 'a' and 'z'
        cmpb $LOWERCASE_A, %cl
        jl next_byte
        cmpb $LOWERCASE_Z, %cl
        jg next_byte

        # otherwise convert the byte to uppercase
        addb $UPPER_CONVERSION, %cl
        movb %cl, (%eax, %edi, 1)

    next_byte:
        incl %edi
        cmpl %edi, %ebx
        jne convert_loop

    end_convert_loop:
      movl %ebp, %esp
      popl %ebp
      ret

