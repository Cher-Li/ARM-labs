        .text
        .global max
max:
        cmp r0, r1
        bxge    lr
        mov r0, r1
        bx  lr
        .end
