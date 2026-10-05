        # TLBlur vTLB/shadow page table update, called by instrumentation
        # 
        # args: %rdi = accessed address
        # %rax used as a scratch register
        __tlblur_pam_size = 0x1000000
        .global tlblur_pam_update
tlblur_pam_update:
        # Compute index in PAM 
        # %rdi = ((%rdi - <enclave base>) >> 9) & (<size> - 1)
        lea     __ImageBase(%rip), %rax
        sub     %rax, %rdi
        # Byte offset from the enclave base. A host pointer wraps to a
        # value past g_enclave_size. Do not record that as a page.
        cmpq    g_enclave_size(%rip), %rdi
        jae     .Ltlblur_pam_outside
        shr     $12, %rdi
        shl     $3, %rdi
        and     $__tlblur_pam_size - 1, %rdi

        # Then update the PAM
        leaq    __tlblur_pam(%rip), %rax
        add     %rax, %rdi

        # Increment global counter, and store it in %rax
        movq    __tlblur_counter(%rip), %rax

        # Update PAM by storing counter
        movq    %rax, (%rdi)

        incq    __tlblur_counter(%rip)

        ret
.Ltlblur_pam_outside:
        ret

        .data

        .global __tlblur_counter
__tlblur_counter:
        .quad   10000000

        .align 0x1000   # 4KiB
        .global __tlblur_pam
__tlblur_pam:
        .zero   __tlblur_pam_size
__tlblur_pam_end:

.section .tlblur.endtext, "ax", @progbits
.global __tlblur_endtext
__tlblur_endtext:
        nop
