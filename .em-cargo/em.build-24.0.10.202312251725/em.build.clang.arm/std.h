#include <stdbool.h>
#include <stdint.h>

typedef uintptr_t       em_addr_t;
typedef uint16_t        em_atom_t;

typedef bool            em_bool;
typedef char            em_char;

typedef int8_t          em_int8;
typedef int16_t         em_int16;
typedef int32_t         em_int32;

typedef uint8_t         em_uint8;
typedef uint16_t        em_uint16;
typedef uint32_t        em_uint32;

typedef intptr_t        em_iarg_t;
typedef uintptr_t       em_uarg_t;

typedef void            (*em_fxn_t)();
typedef void            *em_ptr_t;
typedef void            *em_ref_t;

typedef double          em_num_t;
typedef const char*     em_string;

typedef void            em_void;

//#define __attribute(x)
//#define __attribute__(x)
#define em__export_fxn __root
#define em__inline_fxn __attribute__((always_inline))
#define __builtin_constant_p(v)  (0)
#define __reentrant
#define __reentrantb
#define __USED

#include <em.lang/std.hpp>
#include <MKW38A4.h>
