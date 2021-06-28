/*
REQUIRED_ARGS: -HC -c -o-
PERMUTE_ARGS:
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

struct Child;
class Struct;
enum class Enum;
struct OuterStruct;
class ExternDClass;
struct ExternDStruct;
template <typename T>
class TemplClass;
template <typename T>
class TemplStruct;
template <typename T>
class ExternDTemplClass;

struct Parent
{
    virtual void bar();
};

struct ExternDStructRequired final
{
    int32_t member;
};

template <typename T>
struct ExternDTemplStruct final
{
    // Ignoring var member alignment 0
    T member;
};

extern Child* child;

struct Child : public Parent
{
};

extern Struct* strPtr;

class Struct final
{
};

extern Enum* enumPtr;

enum class Enum
{
    foo = 0,
};

extern OuterStruct::NestedStruct* nestedStrPtr;

struct OuterStruct final
{
    struct NestedStruct final
    {
    };

};

extern ExternDClass* externDClassPtr;

extern ExternDStruct* externDStrPtr;

extern ExternDStructRequired externDStr2;

extern TemplClass<int32_t >* templClass;

template <typename T>
class TemplClass
{
    // Ignoring var member alignment 0
public:
    T member;
};

extern TemplStruct<int32_t >* templStruct;

template <typename T>
class TemplStruct
{
    // Ignoring var member alignment 0
public:
    T member;
};

extern ExternDTemplClass<int32_t >* externTemplClass;

extern ExternDTemplStruct<int32_t > externTemplStruct;

---
*/

extern (C++):

__gshared Child child;

extern (C++, struct)
class Child : Parent {}

extern (C++, struct)
class Parent {
    void bar() {}
}

//******************************************************

__gshared Struct* strPtr;

extern (C++, class)
struct Struct {}

//******************************************************

__gshared Enum* enumPtr;

enum Enum
{
    foo
}

//******************************************************

__gshared OuterStruct.NestedStruct* nestedStrPtr;

struct OuterStruct
{
    static struct NestedStruct {}
}

//******************************************************

__gshared ExternDClass externDClassPtr;

// Not emitted because the forward declaration suffices
extern(D) class ExternDClass
{
    int member;
}

//******************************************************

__gshared ExternDStruct* externDStrPtr;

// Not emitted because the forward declaration suffices
extern(D) struct ExternDStruct
{
    int member;
}

//******************************************************

__gshared ExternDStructRequired externDStr2;

// Emitted because the forward declaration is not sufficient when declaring an instance
extern(D) struct ExternDStructRequired
{
    int member;
}

//******************************************************

__gshared TemplClass!int templClass;

class TemplClass(T)
{
    T member;
}

//******************************************************

__gshared TemplStruct!int templStruct;

class TemplStruct(T)
{
    T member;
}

//******************************************************

__gshared ExternDTemplClass!int externTemplClass;

// Not emitted because the forward declaration suffices
extern(D) class ExternDTemplClass(T)
{
    T member;
}

//******************************************************

__gshared ExternDTemplStruct!int externTemplStruct;

// Required
extern(D) struct ExternDTemplStruct(T)
{
    T member;
}
