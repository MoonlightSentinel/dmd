/**
https://issues.dlang.org/show_bug.cgi?id=21218

REQUIRED_ARGS: -HC -o-
TEST_OUTPUT:
---
// Automatically generated by Digital Mars D Compiler

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

struct S1 final
{
    int32_t a;
protected:
    int32_t b;
    int32_t c;
    int32_t d;
private:
    int32_t e;
};

class S2 final
{
public:
    int32_t af();
protected:
    int32_t bf();
    int32_t cf();
    int32_t df();
};

class C1
{
public:
    int32_t a;
protected:
    int32_t b;
    int32_t c;
    int32_t d;
private:
    int32_t e;
};

struct C2
{
    virtual int32_t af();
protected:
    virtual int32_t bf();
    int32_t cf();
    int32_t df();
};

struct Outer final
{
private:
    int32_t privateOuter;
public:
    struct PublicInnerStruct final
    {
    private:
        int32_t privateInner;
    public:
        int32_t publicInner;
    };

private:
    struct PrivateInnerClass final
    {
    private:
        int32_t privateInner;
    public:
        int32_t publicInner;
    };

public:
    class PublicInnerInterface
    {
    public:
        virtual void foo() = 0;
    };

private:
    enum class PrivateInnerEnum
    {
        A = 0,
        B = 1,
    };

public:
    typedef PrivateInnerEnum PublicAlias;
};
---
*/

module compilable.dtoh_protection;

extern(C++) struct S1
{
    public int a;
    protected int b;
    package int c;
    package(compilable) int d;
    private int e;
}

extern(C++, class) struct S2
{
    public int af();
    protected int bf();
    package int cf();
    package(compilable) int df();
    private int ef();
}

extern(C++) class C1
{
    public int a;
    protected int b;
    package int c;
    package(compilable) int d;
    private int e;
}

extern(C++, struct) class C2
{
    public int af();
    protected int bf();
    package int cf();
    package(compilable) int df();
    private int ef();
}

extern(C++) struct Outer
{
    private int privateOuter;

    static struct PublicInnerStruct
    {
        private int privateInner;
        int publicInner;
    }

    private static struct PrivateInnerClass
    {
        private int privateInner;
        int publicInner;
    }

    static interface PublicInnerInterface
    {
        void foo();
    }

    private static enum PrivateInnerEnum
    {
        A,
        B
    }

    public alias PublicAlias = PrivateInnerEnum;
}
