#ifdef __EM_COMPILER_gcc__
#include <em.build.gcc2/startup.c>
#endif

#ifdef __EM_COMPILER_iar__
#include <em.build.iar.arm/startup.c>
#endif

#ifdef __EM_COMPILER_segger__
#include <em.build.segger2/startup.c>
#endif

#ifdef __EM_COMPILER_ticc__
#include <em.build.ticc.arm/startup.c>
#endif

extern int main() {
    em__main();
    return 0;
}
