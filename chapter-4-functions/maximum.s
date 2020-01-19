# PURPOSE: this function finds the maximum number of a sequence of data items.
# PARAMETERS:
#    first parameter is the number of elements in the sequence
#    second parameter is the pointer to the first element of the sequence
.section .data

.section .text

.globl maximum

.type maximum,@function
maximum:
  pushl %ebp
  movl %esp, %ebp

  movl 8(%ebp), %ecx  # Number of elements in sequence
  movl 12(%ebp), %eax
  movl $0, %edi
  movl %eax, %ebx
  
  start_loop:
    incl %edi
    cmpl %ecx, %edi
    je loop_exit
    movl 12(%ebp,%edi,4), %eax
    cmpl %ebx,%eax
    jge start_loop
  
    movl %eax, %ebx
    jmp start_loop
  
  loop_exit:
    movl %ebx, %eax
    movl %ebp, %esp
    popl %ebp
    ret
