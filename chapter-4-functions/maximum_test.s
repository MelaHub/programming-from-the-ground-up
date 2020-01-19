# PURPOSE: this program finds the maximum number of a set of data items.
# VARIABLES: The registers have the following uses:
#
# %edi - Holds the index of the data item being examined
# %ebx - Largest data item found
# %eax - Current data item
#
# The following memory locations are used:
#
# data_items - contains the item data. A 255 is used to terminate the data
.section .data

data_items_1:
  .long 3,67,34,222,45,75,54,34,44,33,22,11,66

data_items_2:
  .long 76,34,12,72

data_items_3:
  .long 9,6,4,2

.section .text

.globl _start

_start:
  pushl data_items_1
  pushl $13

  call maximum

  addl $4, %esp
  movl %eax, %ebx
  movl $1, %eax
  int $0x80
