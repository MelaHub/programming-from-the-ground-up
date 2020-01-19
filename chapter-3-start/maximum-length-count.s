# PURPOSE: this program finds the maximum number of a set of data items.
# VARIABLES: The registers have the following uses:
#
# %edi - Holds the index of the data item being examined
# %ebx - Largest data item found
# %eax - Current data item
# %ecx - Length of array
#
# The following memory locations are used:
#
# data_items - contains the item data. A 255 is used to terminate the data
.section .data

data_items:
  .long 3,67,34,222,45,75,54,34,44,33,22,11,66

data_length:
  .int 13

.section .text

.globl _start

_start:
  movl data_length, %ecx
  movl $0, %edi
  movl data_items(,%edi,4), %eax
  movl %eax, %ebx
  
  start_loop:
    incl %edi
    cmpl %ecx, %edi
    je loop_exit
    movl data_items(,%edi,4), %eax

    cmpl %ebx,%eax
    jle start_loop
  
    movl %eax, %ebx
    jmp start_loop
  
  loop_exit:
    movl $1, %eax
    int $0x80
