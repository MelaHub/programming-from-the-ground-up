# PURPOSE: This program converts everything written to stdin to uppercase to stdout

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
.equ NUMBER_ARGUMENTS, 0

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

.globl _start
_start:
###INITIALIZE PROGRAM###
# save the stack pointer
movl %esp, %ebp

# Allocate space for out file descriptors on the stack
subl $ST_SIZE_RESERVE, %esp

open_files:

store_fd_in:
    movl $STDIN, ST_FD_IN(%ebp)

store_fd_out:
    movl $STDOUT, ST_FD_OUT(%ebp)

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

