#define STACK_TOP 0x20002000

void em__main();
extern "C" void __em_program_start();

void __em_program_start()
{
    em__main();
}
#if 0
void* memset(void *dst, int val, size_t len) {
    unsigned char *ptr = (unsigned char*) dst;
    while (len-- > 0) *ptr++ = val;
    return dst;
}

void* memcpy(void *dst, const void *src, size_t len) {
    char *d = (char*)dst;
    const char *s = (const char*)src;
    while (len--) *d++ = *s++;
    return dst;
}
#endif

const uint32_t  __attribute__((section(".ARM.__at_0x400"))) __attribute__((used)) __FlashConfig[4] = { 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFE }; 
