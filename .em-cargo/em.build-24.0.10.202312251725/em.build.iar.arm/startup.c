extern int main();
extern bool __is_warm();

#include __EM_IS_WARM_SRC

#pragma section=".bss"
#pragma section=".data"
#pragma section=".data_init"

extern "C" void __attribute__((section(".start"))) __em_program_start(void) {
    if (__is_warm() == 0) {
        uint8_t* src;
        uint8_t* dst;
        uint32_t sz;
        dst = (uint8_t*)__section_begin(".bss");
        sz = __section_size(".bss");
        while (sz--) {
            *dst++ = 0;
        }
///        memset(dst, 0, sz);
        src = (uint8_t*)__section_begin(".data_init");
        dst = (uint8_t*)__section_begin(".data");
        sz = __section_size(".data");
        while (sz--) {
            *dst++ = *src++;
        }
///        memcpy(dst, src, sz);
    }
    em__main();
}

