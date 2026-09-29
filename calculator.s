# A terminal calculator
#
# Reads a line of input, interprets it as a simple arithmetic expression,
# and prints the result. The input format is
# <long_integer> <operation> <long_integer>

# Make `main` accessible outside of this module
.global main

# Start of the code section
.text

main:
  # Function prologue
  enter $0, $0

  # Use scanf to retrieve and process a line of input
  # This block implements the following line of C code:
  #   scanf("%ld %c %ld", &a, &op, &b);
  # Take a look at the man page for scanf and ask questions. You can also look
  # at scanf_example.c

  movq $scanf_fmt, %rdi
  movq $a, %rsi
  movq $op, %rdx
  movq $b, %rcx
  xorb %al, %al
  call scanf

  movb op, %r10b              # loading operation for comparisons
  movq a, %rax                # LHS
  mov b, %r8                  # RHS

  cmpb $'+', %r10b            # checks if operator is +
  je do_add                   # does addition if true

  cmpb $'-', %r10b            # checks if operator is -
  je do_sub                   # does subtraction if true

  cmpb $'*', %r10b            # checks if operator is *
  je do_mul                   # does multiplication if true

  cmpb $'/', %r10b            # checks if operator is /
  je do_div                   # does division if true

  jmp unknown_op              # if operator is unknown, it reports as unknown operator

do_add:
  addq b, %rax                # %rax = a + b
  jmp print_result            # print statement

do_sub:
  subq b, %rax                # %rax = a - b
  jmp print_result            # print statement

do_mul:
  imulq b, %rax               # %rax = a * b
  jmp print_result            # print statement

do_div:
  cmpq $0, b                  # checks if divisor is zero
  je div_zero                 # reports as error if above is true

  cqto                        # sign-extend %rax into %rdx:%rax
  idivq b                     # divide
  jmp print_result            # print statement

print_result:
  movq $output_fmt, %rdi      # address of format string
  movq %rax, %rsi             # computed result
  xorb %al, %al               # %al = 0; no vector args for variadic printf
  call printf                 # prints result

  movl $0, %eax               # return value 0 = success
  leave                       # leave
  ret                         # return from main

unknown_op:
  movq $unknown_msg, %rdi     # "unknown operation"
  call puts                   # print statement

  movl $1, %eax               # return error
  leave
  ret

div_zero:
  movq $div_zero_msg, %rdi    # division by zero
  call puts                   # print statement

  movl $1, %eax
  leave
  ret

# Start of the data section
.data

output_fmt:
  .asciz "%ld\n"
scanf_fmt:
  .asciz "%ld %c %ld"

unknown_msg:
  .asciz "Unknown operation"  # error message for unknown operators

div_zero_msg:
  .asciz "Division by zero"   # error message for division by zero

# "Slots" for scanf
a:  .quad 0
b:  .quad 0
op: .byte 0

