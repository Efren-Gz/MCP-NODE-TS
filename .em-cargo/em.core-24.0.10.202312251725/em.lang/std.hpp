#ifndef em_lang_std_M
#define em_lang_std_M

#include <cstddef>
#include <cstring>

#define __EMLANG__

static const std::nullptr_t null = nullptr;

template <typename T> struct em$ArrC;
template <typename T> struct em$ArrD;
template <typename T, size_t n> struct em$ArrV;

template <typename T> struct em$ArrC {
    T* _elems;
    constexpr em$ArrC(std::nullptr_t) : _elems{null} {};
    constexpr em$ArrC(T* arr) : _elems{arr} {};
    constexpr em$ArrC(const T* arr) : _elems{(T*)arr} {};
    constexpr em$ArrC(void* ptr) : _elems{(T*)ptr} {};
    constexpr em$ArrC(int addr) : _elems{(T*)addr} {};
    em__inline_fxn T& operator[](int i) { return _elems[i]; }
    em__inline_fxn const T& operator[](int i) const { return _elems[i]; }
    em__inline_fxn volatile T& operator[](int i) volatile { return _elems[i]; }
    em__inline_fxn operator bool() const { return _elems != null; }
    em__inline_fxn operator T*() { return _elems; }
};

template <typename T> struct em$ArrD {
    T* _elems;
    size_t length;
    constexpr em$ArrD(const T* arr, size_t len) :  _elems{(T*)arr},  length{len} {};
    em__inline_fxn em$ArrD(const T* arr, size_t beg, size_t end) { _elems = (T*)(&arr[beg]); length = end - beg; }
    em__inline_fxn em$ArrD(std::nullptr_t) { _elems = null; length = 0; }
    em__inline_fxn T& operator[](int i) { return _elems[i]; }
    em__inline_fxn const T& operator[](int i) const { return _elems[i]; }
    em__inline_fxn volatile T& operator[](int i) volatile { return _elems[i]; }
    em__inline_fxn operator bool() const { return length != 0; }
    em__inline_fxn operator T*() { return _elems; }
    em__inline_fxn operator em$ArrC<T>() { return em$ArrC<T>(_elems); }
};

template <typename T, size_t n> struct em$ArrR {
    static const size_t length = n;
    T* _elems;
    em__inline_fxn em$ArrR(std::nullptr_t) { _elems = null; }
    em__inline_fxn em$ArrR(T* arr) { _elems = arr; }
    em__inline_fxn em$ArrR(void* ptr) { _elems = (T*)ptr; }
    em__inline_fxn em$ArrR(unsigned int a) { _elems = (T*)a; }
    em__inline_fxn T& operator[](int i) { return _elems[i]; }
    em__inline_fxn const T& operator[](int i) const { return _elems[i]; }
    em__inline_fxn operator bool() const { return _elems != null; }
    em__inline_fxn operator T*() { return _elems; }
    em__inline_fxn operator em$ArrC<T>() { return em$ArrC<T>(_elems); }
    em__inline_fxn operator em$ArrD<T>() { return em$ArrD<T>(_elems, length); }
    em__inline_fxn operator em$ArrV<T,n>() { return em$ArrV<T, n>(); }
    em__inline_fxn em$ArrR<T,n> $$asn(em$ArrR<T,n> a) { memcpy(_elems, a._elems, sizeof(T) * n); return this; }
    em__inline_fxn em$ArrR<T,n> $$asn(em$ArrV<T,n> a) { memcpy(_elems, a._elems, sizeof(T) * n); return this; }
};

template <typename T, size_t n> struct em$ArrV {
    static const size_t length = n;
    T _elems[n];
    em__inline_fxn T& operator[](int i) { return _elems[i]; }
    em__inline_fxn const T& operator[](int i) const { return _elems[i]; }
    em__inline_fxn operator T*() const { return _elems; }
    em__inline_fxn operator void*() const { return (void*)_elems; }
    em__inline_fxn operator int() const { return (int)_elems; }
    em__inline_fxn operator em$ArrC<T>() { return em$ArrC<T>(_elems); }
    em__inline_fxn operator em$ArrD<T>() { return em$ArrD<T>(_elems, length); }
    em__inline_fxn operator em$ArrR<T,n>() { return em$ArrR<T,n>(_elems); }
    em__inline_fxn em$ArrV<T,n> $$asn(em$ArrR<T,n> a) { memcpy(_elems, a._elems, sizeof(T) * n); return *this; }
    em__inline_fxn em$ArrV<T,n> $$asn(em$ArrV<T,n> a) { memcpy(_elems, a._elems, sizeof(T) * n); return *this; }
};

template <typename T> struct em$Ptr {
    T* _ptr;
    em__inline_fxn em$Ptr() { }
    em__inline_fxn em$Ptr(std::nullptr_t) { _ptr = null; }
    em__inline_fxn em$Ptr(void* p) { _ptr = (T*)p; }
    em__inline_fxn em$Ptr(unsigned int a) { _ptr = (T*)a; }
    em__inline_fxn T* operator=(std::nullptr_t) { return _ptr = null; }
    em__inline_fxn T operator*() { return *_ptr; }
    em__inline_fxn T* operator->() { return _ptr; }
    em__inline_fxn const T* operator->() const { return _ptr; }
    em__inline_fxn T* operator++() { return ++_ptr; }
    em__inline_fxn T* operator++(int) { return _ptr++; }
    em__inline_fxn T* operator--() { return --_ptr; }
    em__inline_fxn T* operator--(int) { return _ptr--; }
    em__inline_fxn bool operator==(em$Ptr<T> const& rhs) { return _ptr == rhs._ptr; }
    em__inline_fxn operator bool() { return _ptr != null; }
    em__inline_fxn operator T*() { return _ptr; }
    em__inline_fxn operator T volatile*() { return (T volatile*)_ptr; }
    em__inline_fxn operator void*() { return (void*)_ptr; }
};


volatile int em$out;

void em$pr(int val) {
    asm("    nop");
    asm("    nop");
    asm("    nop");
    em$out = val;
    asm("    nop");
    asm("    nop");
    asm("    nop");
}

static void em__done();
static void em__fail();
static void em__halt();
static void em__main();

typedef volatile uint32_t* io32_t;

#endif
