/*
REQUIRED_ARGS: -HC=verbose -o- -Icompilable/extra-files
PERMUTE_ARGS:
EXTRA_FILES: extra-files/dtoh_imports.d extra-files/dtoh_imports2.d

TEST_OUTPUT:
---
// Automatically generated by Digital Mars D Compiler v$n$

#pragma once

#include <assert.h>
#include <stddef.h>
#include <stdint.h>
#include <math.h>

#ifdef CUSTOM_D_ARRAY_TYPE
#define _d_dynamicArray CUSTOM_D_ARRAY_TYPE
#else
/// Represents a D [] array
template<typename T>
struct _d_dynamicArray final
{
    size_t length;
    T *ptr;

    _d_dynamicArray() : length(0), ptr(NULL) { }

    _d_dynamicArray(size_t length_in, T *ptr_in)
        : length(length_in), ptr(ptr_in) { }

    T& operator[](const size_t idx) {
        assert(idx < length);
        return ptr[idx];
    }

    const T& operator[](const size_t idx) const {
        assert(idx < length);
        return ptr[idx];
    }
};
#endif

extern void importFunc();

// Ignored function dtoh_verbose.foo because of linkage
// Ignored variable dtoh_verbose.i because of linkage
// Ignored function dtoh_verbose.bar because of linkage
// Ignored struct dtoh_verbose.S because of linkage
// Ignored class dtoh_verbose.C because of linkage
// Ignored function dtoh_verbose.bar because it is extern
// Ignored variable dtoh_verbose.i1 because of linkage
// Ignored template dtoh_verbose.templ(T)(T t) because of linkage
// Ignored alias dtoh_verbose.inst because of linkage
// Ignored enum dtoh_verbose.arrayOpaque because of its base type
// Ignored renamed import `myFunc = importFunc` because `using` only supports types
struct A final
{
    // Ignored renamed import `myFunc = importFunc` because `using` only supports types
};

struct Hidden final
{
    // Ignored function dtoh_verbose.Hidden.hidden because it is private
};

// Ignored alias dtoh_verbose.D because of linkage
class Visitor
{
public:
    virtual void stat();
    // Ignored dtoh_verbose.Visitor.bar because `using` cannot rename functions in aggregates
    // Ignored dtoh_verbose.Visitor.unused because free functions cannot be aliased in C++
};

extern void unused();

// Ignored variable dtoh_verbose.and because its name is a special operator in C++
template <typename T>
struct FullImportTmpl final
{
    // Ignored `dtoh_imports` because it's inside of a template declaration
};

template <typename T>
struct SelectiveImportsTmpl final
{
    // Ignored `__anonymous` because it's inside of a template declaration
};
---
*/

void foo() {}

extern (D) {
    int i;
}

void bar();

struct S {}

class C {}

extern(C++) void bar();

int i1;

void templ(T)(T t) {}

alias inst = templ!int;

extern(C++)
enum arrayOpaque : int[4];

public import dtoh_imports : myFunc = importFunc;

extern(C++) struct A
{
    public import dtoh_imports : myFunc = importFunc;
}

extern(C++) struct Hidden
{
    private void hidden() {}
}

private {
    enum PI = 4;
}

alias D = size_t delegate (size_t x);

extern(C++) T foo(T) = T.init;

extern(C++) class Visitor
{
    void stat() {}

    // Ignored because those cannot be represented in C++
    alias bar = stat;
    alias unused = .unused;
}

extern(C++) void unused() {}

extern(C++) __gshared bool and;

extern(C++) struct FullImportTmpl(T)
{
    public import dtoh_imports;

}

extern(C++) struct SelectiveImportsTmpl(T)
{
    public import dtoh_imports :
        importFunc,
        aliasName = ImportsC;
}
