/+
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

enum : int32_t { Anon = 10 };

enum : bool { Anon2 = true };

static const char* const Anon3 = "wow";

enum class Enum
{
    One = 0,
    Two = 1,
};

extern const Enum constEnum;

enum class EnumDefaultType
{
    One = 1,
    Two = 2,
};

enum class EnumWithType : int8_t
{
    One = 1,
    Two = 2,
};

enum
{
    AnonOne = 1,
    AnonTwo = 2,
};

enum : int64_t
{
    AnonWithTypeOne = 1LL,
    AnonWithTypeTwo = 2LL,
};

namespace EnumWithStringType
{
    static const char* const One = "1";
    static const char* const Two = "2";
};

namespace EnumWStringType
{
    static const char16_t* const One = u"1";
};

namespace EnumDStringType
{
    static const char32_t* const One = U"1";
};

namespace EnumWithImplicitType
{
    static const char* const One = "1";
    static const char* const Two = "2";
};

namespace
{
    static const char* const AnonWithStringOne = "1";
    static const char* const AnonWithStringTwo = "2";
};

enum : int32_t { AnonMixedOne = 1 };
enum : int64_t { AnonMixedTwo = 2LL };
static const char* const AnonMixedA = "a";


enum class STC
{
    a = 1,
    b = 2,
};

static STC const STC_D = (STC)3;

struct Foo final
{
    int32_t i;
};

namespace MyEnum
{
    static Foo const A = Foo(42);
    static Foo const B = Foo(84);
};

static /* MyEnum */ Foo const test = Foo(42);

struct FooCpp final
{
    int32_t i;
};

namespace MyEnumCpp
{
    static FooCpp const A = FooCpp(42);
    static FooCpp const B = FooCpp(84);
};

static /* MyEnum */ Foo const testCpp = Foo(42);

extern const bool e_b;

enum class opaque;
enum class typedOpaque : int64_t;
---
+/

extern(C++):

enum Anon = 10;
extern(C++) enum Anon2 = true;
extern(C++) enum Anon3 = "wow";

enum Enum
{
    One,
    Two
}

extern(C++) __gshared const(Enum) constEnum;

enum EnumDefaultType : int
{
    One = 1,
    Two = 2
}

enum EnumWithType : byte
{
    One = 1,
    Two = 2
}

enum
{
    AnonOne = 1,
    AnonTwo = 2
}

enum : long
{
    AnonWithTypeOne = 1,
    AnonWithTypeTwo = 2
}

enum EnumWithStringType : string
{
    One = "1",
    Two = "2"
}

enum EnumWStringType : wstring
{
    One = "1"
}

enum EnumDStringType : dstring
{
    One = "1"
}

enum EnumWithImplicitType
{
    One = "1",
    Two = "2"
}

enum : string
{
    AnonWithStringOne = "1",
    AnonWithStringTwo = "2"
}

enum
{
    AnonMixedOne = 1,
    long AnonMixedTwo = 2,
    string AnonMixedA = "a"
}

enum STC
{
    a = 1,
    b = 2,
}

extern(C++) enum STC_D = STC.a | STC.b;

struct Foo { int i; }
enum MyEnum { A = Foo(42), B = Foo(84) }
extern(C++) enum test = MyEnum.A;

extern(C++) struct FooCpp { int i; }
enum MyEnumCpp { A = FooCpp(42), B = FooCpp(84) }
extern(C++) enum testCpp = MyEnum.A;

// currently unsupported enums
extern(C++) enum b = [1, 2, 3];
extern(C++) enum c = [2: 3];

extern(C) void foo();
extern(C++) enum d = &foo;

__gshared immutable bool e_b;
extern(C++) enum e = &e_b;

enum opaque;
enum typedOpaque : long;
enum arrayOpaque : int[4]; // Cannot be exported to C++

extern(D) enum hidden_d = 42; // Linkage prevents being exported to C++
