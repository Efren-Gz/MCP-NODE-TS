extern uint32_t __bss_addr__;
extern uint32_t __bss_size__;
extern uint32_t __code_addr__;
extern uint32_t __code_load__;
extern uint32_t __data_addr__;
extern uint32_t __data_load__;
extern uint32_t __data_size__;
extern uint32_t __global_pointer__;
extern uint32_t __stack_top__;

extern int main();
extern bool __is_warm();

typedef struct {
    unsigned int* codeLoad;
    unsigned int* codeAddr;
    unsigned int* bssAddr;
    unsigned int bssSize;
} __em_desc_t;

#include __EM_IS_WARM_SRC

#if __EM_BOOT__ == 1
extern "C" __em_desc_t __attribute__((section(".desc"))) __em_desc = {
    .codeLoad = &__code_load__,
    .codeAddr = &__code_addr__,
    .bssAddr = &__bss_addr__,
    .bssSize = (unsigned int)&__bss_size__,
};
#endif

extern "C" void __attribute__((section(".start"))) __em_program_start() {

#ifdef __EM_ARCH_riscv32__
    asm(".option norelax");
    asm("lui     gp,     %hi(__global_pointer__)");
    asm("addi    gp, gp, %lo(__global_pointer__)");
    asm("lui     tp,     %hi(__bss_addr__)");
    asm("addi    tp, tp, %lo(__bss_addr__)");
    asm("lui     t0,     %hi(__stack_top__)");
    asm("addi    sp, t0, %lo(__stack_top__)");
    asm(".option relax");
#endif

#if __EM_BOOT__ == 0
    if (!__is_warm()) {
        uint32_t *src;
        uint32_t *dst;
        uint32_t sz;
        sz = (uint32_t)&__bss_size__;
        dst = &__bss_addr__;
        asm("nop");
        asm("nop");
        asm("nop");
        for (uint32_t i = 0; i < sz; i++) {     // TODO -- while (sz--) not working
            dst[i] = 0;
        }
        sz = (uint32_t)&__data_size__;
        src = &__data_load__;
        dst = &__data_addr__;
        for (uint32_t i = 0; i < sz; i++) {
            dst[i] = src[i];
        }
    }
#endif

    main();
}
