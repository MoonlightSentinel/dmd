// REQUIRED_ARGS: -de
// https://issues.dlang.org/show_bug.cgi?id=6519

void foo(T, alias f, U...)(T t = T.init, U[0] u = U[0].init)
{
    T var;
    f();
    U otherVars;
}

struct Struct(T, alias f, U...)
{
    T m;
    U[0] n;

    void foo()
    {
        f();
    }
}

class Class(T, alias f, U...)
{
    T m;
    U[0] n;

    void foo()
    {
        f();
    }
}

interface Interface(T, alias f, U...)
{
    T foo(U args);

    alias bar = f;
}

union Union(T, U...)
{
    T t;
    U u;
}

alias bar(T, alias f, U...) = f;

enum TypeSize(T, alias f, U...) = T.sizeof;

template Multi(T, alias f, U...)
{
    void foo(T t = T.init, U[0] u = U[0].init)
    {
        T var;
        f();
        U otherVars;
    }

    struct Struct
    {
        T m;
        U[0] n;

        void foo()
        {
            f();
        }
    }

    static if (true)
    class Class
    {
        T m;
        U[0] n;

        void foo()
        {
            f();
        }
    }

    static if (false) {} else
    interface Interface
    {
        T foo(U args);

        alias bar = f;
    }

    version (all)
    union Union
    {
        T t;
        U u;
    }

    alias bar = f;

    version (none) {} else
    enum TypeSize = T.sizeof;
}

mixin template MultiMixin(T, alias f, U...)
{
    void foo(T t = T.init, U u = U.init)
    {
        T var;
        f();
        U otherVars;
    }

    struct Struct
    {
        T m;
        U others;
    }

    static if (true)
    class Class
    {
        T m;
        U[0] n;

        void foo()
        {
            f();
        }
    }

    static if (false) {} else
    interface Interface
    {
        T foo(U args);

        alias bar = f;
    }

    version (all)
    union Union
    {
        T t;
        U u;
    }

    alias bar = f;

    version (none) {} else
    enum TypeSize = T.sizeof;
}

deprecated struct S {}

deprecated void old() {}

void normal() {}

deprecated void main()
{
    {
        foo!(S, normal, int)();
        foo!(int, old, int)();
        foo!(int, normal, S)();

        Struct!(S, normal, int) s1;
        Struct!(int, old, int) s2;
        Struct!(int, normal, S) s3;

        Class!(S, normal, int) c1;
        Class!(int, old, int) c2;
        Class!(int, normal, S) c3;

        Interface!(S, normal, int) i1;
        Interface!(int, old, int) i2;
        Interface!(int, normal, S) i3;

        Union!(S, int) u1;
        Union!(int, S) u2;
        Union!(int, int, S) u3;

        bar!(S, normal, int)();
        bar!(int, old, int)();
        bar!(int, normal, S)();

        auto ts1 = TypeSize!(S, normal, int);
        auto ts2 = TypeSize!(int, old, int);
        auto ts3 = TypeSize!(int, normal, S);
    }
    {
        alias M1 = Multi!(S, normal, int);
        M1.foo();
        M1.Struct s1;
        M1.Class c1;
        M1.Interface i1;
        M1.Union u1;
        M1.bar();
        auto ts1 = M1.TypeSize;

        alias M2 = Multi!(int, old, int);
        M2.foo();
        M2.Struct s2;
        M2.Class c2;
        M2.Interface i2;
        M2.Union u2;
        M2.bar();
        auto ts2 = M2.TypeSize;

        alias M3 = Multi!(int, normal, S);
        M3.foo();
        M3.Struct s3;
        M3.Class c3;
        M3.Interface i3;
        M3.Union u3;
        M3.bar();
        auto ts3 = M3.TypeSize;
    }
    {
        mixin MultiMixin!(S, normal, int);
        foo();
        Struct s;
        Class c;
        Interface i;
        Union u;
        bar();
        auto ts = TypeSize;
    }
    {
        mixin MultiMixin!(int, old, int);
        foo();
        Struct s;
        Class c;
        Interface i;
        Union u;
        bar();
        auto ts = TypeSize;
    }
    {
        mixin MultiMixin!(int, old, S);
        foo();
        Struct s;
        Class c;
        Interface i;
        Union u;
        bar();
        auto ts = TypeSize;
    }
}

/*
TODO: Alias declarations (=> bar) are not flagged as deprecated ...

TEST_OUTPUT:
---
fail_compilation\deprecation7619.d(302): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(302): Deprecation: function `deprecation7619.foo!(S, normal, int).foo` is deprecated
fail_compilation\deprecation7619.d(303): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(303): Deprecation: function `deprecation7619.foo!(int, old, int).foo` is deprecated
fail_compilation\deprecation7619.d(304): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(304): Deprecation: function `deprecation7619.foo!(int, normal, S).foo` is deprecated
fail_compilation\deprecation7619.d(306): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(306): Deprecation: struct `deprecation7619.Struct!(S, normal, int).Struct` is deprecated
fail_compilation\deprecation7619.d(307): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(307): Deprecation: struct `deprecation7619.Struct!(int, old, int).Struct` is deprecated
fail_compilation\deprecation7619.d(308): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(308): Deprecation: struct `deprecation7619.Struct!(int, normal, S).Struct` is deprecated
fail_compilation\deprecation7619.d(310): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(310): Deprecation: class `deprecation7619.Class!(S, normal, int).Class` is deprecated
fail_compilation\deprecation7619.d(311): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(311): Deprecation: class `deprecation7619.Class!(int, old, int).Class` is deprecated
fail_compilation\deprecation7619.d(312): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(312): Deprecation: class `deprecation7619.Class!(int, normal, S).Class` is deprecated
fail_compilation\deprecation7619.d(314): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(314): Deprecation: interface `deprecation7619.Interface!(S, normal, int).Interface` is deprecated
fail_compilation\deprecation7619.d(315): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(315): Deprecation: interface `deprecation7619.Interface!(int, old, int).Interface` is deprecated
fail_compilation\deprecation7619.d(316): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(316): Deprecation: interface `deprecation7619.Interface!(int, normal, S).Interface` is deprecated
fail_compilation\deprecation7619.d(318): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(318): Deprecation: union `deprecation7619.Union!(S, int).Union` is deprecated
fail_compilation\deprecation7619.d(319): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(319): Deprecation: union `deprecation7619.Union!(int, S).Union` is deprecated
fail_compilation\deprecation7619.d(320): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(320): Deprecation: union `deprecation7619.Union!(int, int, S).Union` is deprecated
fail_compilation\deprecation7619.d(322): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(323): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(323): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(324): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(326): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(326): Deprecation: variable `deprecation7619.TypeSize!(S, normal, int).TypeSize` is deprecated
fail_compilation\deprecation7619.d(327): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(327): Deprecation: variable `deprecation7619.TypeSize!(int, old, int).TypeSize` is deprecated
fail_compilation\deprecation7619.d(328): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(328): Deprecation: variable `deprecation7619.TypeSize!(int, normal, S).TypeSize` is deprecated
---
*/
#line 300
void normalMain1()
{
    foo!(S, normal, int)();
    foo!(int, old, int)();
    foo!(int, normal, S)();

    Struct!(S, normal, int) s1;
    Struct!(int, old, int) s2;
    Struct!(int, normal, S) s3;

    Class!(S, normal, int) c1;
    Class!(int, old, int) c2;
    Class!(int, normal, S) c3;

    Interface!(S, normal, int) i1;
    Interface!(int, old, int) i2;
    Interface!(int, normal, S) i3;

    Union!(S, int) u1;
    Union!(int, S) u2;
    Union!(int, int, S) u3;

    bar!(S, normal, int)();
    bar!(int, old, int)();
    bar!(int, normal, S)();

    auto ts1 = TypeSize!(S, normal, int);
    auto ts2 = TypeSize!(int, old, int);
    auto ts3 = TypeSize!(int, normal, S);
}

/*
TEST_OUTPUT:
---
fail_compilation\deprecation7619.d(402): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(402): Deprecation: function `deprecation7619.foo!(S, normal, int).foo` is deprecated
fail_compilation\deprecation7619.d(403): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(403): Deprecation: function `deprecation7619.foo!(int, old, int).foo` is deprecated
fail_compilation\deprecation7619.d(404): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(404): Deprecation: function `deprecation7619.foo!(int, normal, S).foo` is deprecated
fail_compilation\deprecation7619.d(406): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(406): Deprecation: struct `deprecation7619.Struct!(S, normal, int).Struct` is deprecated
fail_compilation\deprecation7619.d(407): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(407): Deprecation: struct `deprecation7619.Struct!(int, old, int).Struct` is deprecated
fail_compilation\deprecation7619.d(408): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(408): Deprecation: struct `deprecation7619.Struct!(int, normal, S).Struct` is deprecated
fail_compilation\deprecation7619.d(410): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(410): Deprecation: class `deprecation7619.Class!(S, normal, int).Class` is deprecated
fail_compilation\deprecation7619.d(411): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(411): Deprecation: class `deprecation7619.Class!(int, old, int).Class` is deprecated
fail_compilation\deprecation7619.d(412): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(412): Deprecation: class `deprecation7619.Class!(int, normal, S).Class` is deprecated
fail_compilation\deprecation7619.d(414): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(414): Deprecation: interface `deprecation7619.Interface!(S, normal, int).Interface` is deprecated
fail_compilation\deprecation7619.d(415): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(415): Deprecation: interface `deprecation7619.Interface!(int, old, int).Interface` is deprecated
fail_compilation\deprecation7619.d(416): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(416): Deprecation: interface `deprecation7619.Interface!(int, normal, S).Interface` is deprecated
fail_compilation\deprecation7619.d(418): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(418): Deprecation: union `deprecation7619.Union!(S, int).Union` is deprecated
fail_compilation\deprecation7619.d(419): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(419): Deprecation: union `deprecation7619.Union!(int, S).Union` is deprecated
fail_compilation\deprecation7619.d(420): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(420): Deprecation: union `deprecation7619.Union!(int, int, S).Union` is deprecated
fail_compilation\deprecation7619.d(422): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(423): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(423): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(424): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(426): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(426): Deprecation: variable `deprecation7619.TypeSize!(S, normal, int).TypeSize` is deprecated
fail_compilation\deprecation7619.d(427): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(427): Deprecation: variable `deprecation7619.TypeSize!(int, old, int).TypeSize` is deprecated
fail_compilation\deprecation7619.d(428): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(428): Deprecation: variable `deprecation7619.TypeSize!(int, normal, S).TypeSize` is deprecated
---
*/
#line 400
void normalMain2()
{
    alias M1 = Multi!(S, normal, int);
    M1.foo();
    M1.Struct s1;
    M1.Class c1;
    M1.Interface i1;
    M1.Union u1;
    M1.bar();
    auto ts1 = M1.TypeSize;

    alias M2 = Multi!(int, old, int);
    M2.foo();
    M2.Struct s2;
    M2.Class c2;
    M2.Interface i2;
    M2.Union u2;
    M2.bar();
    auto ts2 = M2.TypeSize;

    alias M3 = Multi!(int, normal, S);
    M3.foo();
    M3.Struct s3;
    M3.Class c3;
    M3.Interface i3;
    M3.Union u3;
    M3.bar();
    auto ts3 = M3.TypeSize;
}

/*
TODO: Remove duplicate lines when the redundant deprecation check is removed

TEST_OUTPUT:
---
fail_compilation\deprecation7619.d(503): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(504): Deprecation: function `deprecation7619.normalMain3.MultiMixin!(S, normal, int).foo` is deprecated
fail_compilation\deprecation7619.d(505): Deprecation: struct `deprecation7619.normalMain3.MultiMixin!(S, normal, int).Struct` is deprecated
fail_compilation\deprecation7619.d(505): Deprecation: struct `deprecation7619.normalMain3.MultiMixin!(S, normal, int).Struct` is deprecated
fail_compilation\deprecation7619.d(506): Deprecation: class `deprecation7619.normalMain3.MultiMixin!(S, normal, int).Class` is deprecated
fail_compilation\deprecation7619.d(506): Deprecation: class `deprecation7619.normalMain3.MultiMixin!(S, normal, int).Class` is deprecated
fail_compilation\deprecation7619.d(507): Deprecation: interface `deprecation7619.normalMain3.MultiMixin!(S, normal, int).Interface` is deprecated
fail_compilation\deprecation7619.d(507): Deprecation: interface `deprecation7619.normalMain3.MultiMixin!(S, normal, int).Interface` is deprecated
fail_compilation\deprecation7619.d(508): Deprecation: union `deprecation7619.normalMain3.MultiMixin!(S, normal, int).Union` is deprecated
fail_compilation\deprecation7619.d(508): Deprecation: union `deprecation7619.normalMain3.MultiMixin!(S, normal, int).Union` is deprecated
fail_compilation\deprecation7619.d(509): Deprecation: alias `deprecation7619.normalMain3.MultiMixin!(S, normal, int).bar` is deprecated
fail_compilation\deprecation7619.d(510): Deprecation: variable `deprecation7619.normalMain3.MultiMixin!(S, normal, int).TypeSize` is deprecated
fail_compilation\deprecation7619.d(513): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(514): Deprecation: function `deprecation7619.normalMain3.MultiMixin!(int, old, int).foo` is deprecated
fail_compilation\deprecation7619.d(515): Deprecation: struct `deprecation7619.normalMain3.MultiMixin!(int, old, int).Struct` is deprecated
fail_compilation\deprecation7619.d(515): Deprecation: struct `deprecation7619.normalMain3.MultiMixin!(int, old, int).Struct` is deprecated
fail_compilation\deprecation7619.d(516): Deprecation: class `deprecation7619.normalMain3.MultiMixin!(int, old, int).Class` is deprecated
fail_compilation\deprecation7619.d(516): Deprecation: class `deprecation7619.normalMain3.MultiMixin!(int, old, int).Class` is deprecated
fail_compilation\deprecation7619.d(517): Deprecation: interface `deprecation7619.normalMain3.MultiMixin!(int, old, int).Interface` is deprecated
fail_compilation\deprecation7619.d(517): Deprecation: interface `deprecation7619.normalMain3.MultiMixin!(int, old, int).Interface` is deprecated
fail_compilation\deprecation7619.d(518): Deprecation: union `deprecation7619.normalMain3.MultiMixin!(int, old, int).Union` is deprecated
fail_compilation\deprecation7619.d(518): Deprecation: union `deprecation7619.normalMain3.MultiMixin!(int, old, int).Union` is deprecated
fail_compilation\deprecation7619.d(519): Deprecation: alias `deprecation7619.normalMain3.MultiMixin!(int, old, int).bar` is deprecated
fail_compilation\deprecation7619.d(519): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(520): Deprecation: variable `deprecation7619.normalMain3.MultiMixin!(int, old, int).TypeSize` is deprecated
fail_compilation\deprecation7619.d(523): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(523): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(524): Deprecation: function `deprecation7619.normalMain3.MultiMixin!(int, old, S).foo` is deprecated
fail_compilation\deprecation7619.d(525): Deprecation: struct `deprecation7619.normalMain3.MultiMixin!(int, old, S).Struct` is deprecated
fail_compilation\deprecation7619.d(525): Deprecation: struct `deprecation7619.normalMain3.MultiMixin!(int, old, S).Struct` is deprecated
fail_compilation\deprecation7619.d(526): Deprecation: class `deprecation7619.normalMain3.MultiMixin!(int, old, S).Class` is deprecated
fail_compilation\deprecation7619.d(526): Deprecation: class `deprecation7619.normalMain3.MultiMixin!(int, old, S).Class` is deprecated
fail_compilation\deprecation7619.d(527): Deprecation: interface `deprecation7619.normalMain3.MultiMixin!(int, old, S).Interface` is deprecated
fail_compilation\deprecation7619.d(527): Deprecation: interface `deprecation7619.normalMain3.MultiMixin!(int, old, S).Interface` is deprecated
fail_compilation\deprecation7619.d(528): Deprecation: union `deprecation7619.normalMain3.MultiMixin!(int, old, S).Union` is deprecated
fail_compilation\deprecation7619.d(528): Deprecation: union `deprecation7619.normalMain3.MultiMixin!(int, old, S).Union` is deprecated
fail_compilation\deprecation7619.d(529): Deprecation: alias `deprecation7619.normalMain3.MultiMixin!(int, old, S).bar` is deprecated
fail_compilation\deprecation7619.d(529): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(530): Deprecation: variable `deprecation7619.normalMain3.MultiMixin!(int, old, S).TypeSize` is deprecated
---
*/
#line 500
void normalMain3()
{
    {
        mixin MultiMixin!(S, normal, int);
        foo();
        Struct s;
        Class c;
        Interface i;
        Union u;
        bar();
        auto ts = TypeSize;
    }
    {
        mixin MultiMixin!(int, old, int);
        foo();
        Struct s;
        Class c;
        Interface i;
        Union u;
        bar();
        auto ts = TypeSize;
    }
    {
        mixin MultiMixin!(int, old, S);
        foo();
        Struct s;
        Class c;
        Interface i;
        Union u;
        bar();
        auto ts = TypeSize;
    }
}

/*
TEST_OUTPUT:
---
fail_compilation\deprecation7619.d(602): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(602): Deprecation: function `deprecation7619.foo!(S, normal, int).foo` is deprecated
fail_compilation\deprecation7619.d(603): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(603): Deprecation: function `deprecation7619.foo!(int, old, int).foo` is deprecated
fail_compilation\deprecation7619.d(604): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(604): Deprecation: function `deprecation7619.foo!(int, normal, S).foo` is deprecated
fail_compilation\deprecation7619.d(606): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(606): Deprecation: struct `deprecation7619.Struct!(S, normal, int).Struct` is deprecated
fail_compilation\deprecation7619.d(607): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(607): Deprecation: struct `deprecation7619.Struct!(int, old, int).Struct` is deprecated
fail_compilation\deprecation7619.d(608): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(608): Deprecation: struct `deprecation7619.Struct!(int, normal, S).Struct` is deprecated
fail_compilation\deprecation7619.d(610): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(610): Deprecation: class `deprecation7619.Class!(S, normal, int).Class` is deprecated
fail_compilation\deprecation7619.d(611): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(611): Deprecation: class `deprecation7619.Class!(int, old, int).Class` is deprecated
fail_compilation\deprecation7619.d(612): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(612): Deprecation: class `deprecation7619.Class!(int, normal, S).Class` is deprecated
fail_compilation\deprecation7619.d(614): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(614): Deprecation: interface `deprecation7619.Interface!(S, normal, int).Interface` is deprecated
fail_compilation\deprecation7619.d(615): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(615): Deprecation: interface `deprecation7619.Interface!(int, old, int).Interface` is deprecated
fail_compilation\deprecation7619.d(616): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(616): Deprecation: interface `deprecation7619.Interface!(int, normal, S).Interface` is deprecated
fail_compilation\deprecation7619.d(618): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(618): Deprecation: union `deprecation7619.Union!(S, int).Union` is deprecated
fail_compilation\deprecation7619.d(619): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(619): Deprecation: union `deprecation7619.Union!(int, S).Union` is deprecated
fail_compilation\deprecation7619.d(620): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(620): Deprecation: union `deprecation7619.Union!(int, int, S).Union` is deprecated
fail_compilation\deprecation7619.d(622): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(623): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(623): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(624): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(626): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(626): Deprecation: variable `deprecation7619.TypeSize!(S, normal, int).TypeSize` is deprecated
fail_compilation\deprecation7619.d(627): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(627): Deprecation: variable `deprecation7619.TypeSize!(int, old, int).TypeSize` is deprecated
fail_compilation\deprecation7619.d(628): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(628): Deprecation: variable `deprecation7619.TypeSize!(int, normal, S).TypeSize` is deprecated
fail_compilation\deprecation7619.d(836): Error: template instance `deprecation7619.templMain1!()` error instantiating
---
*/
#line 600
void templMain1()()
{
    foo!(S, normal, int)();
    foo!(int, old, int)();
    foo!(int, normal, S)();

    Struct!(S, normal, int) s1;
    Struct!(int, old, int) s2;
    Struct!(int, normal, S) s3;

    Class!(S, normal, int) c1;
    Class!(int, old, int) c2;
    Class!(int, normal, S) c3;

    Interface!(S, normal, int) i1;
    Interface!(int, old, int) i2;
    Interface!(int, normal, S) i3;

    Union!(S, int) u1;
    Union!(int, S) u2;
    Union!(int, int, S) u3;

    bar!(S, normal, int)();
    bar!(int, old, int)();
    bar!(int, normal, S)();

    auto ts1 = TypeSize!(S, normal, int);
    auto ts2 = TypeSize!(int, old, int);
    auto ts3 = TypeSize!(int, normal, S);
}

/*
TEST_OUTPUT:
---
fail_compilation\deprecation7619.d(702): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(711): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(712): Deprecation: function `deprecation7619.Multi!(int, old, int).foo` is deprecated
fail_compilation\deprecation7619.d(712): Deprecation: function `deprecation7619.Multi!(int, old, int).foo` is deprecated
fail_compilation\deprecation7619.d(713): Deprecation: struct `deprecation7619.Multi!(int, old, int).Struct` is deprecated
fail_compilation\deprecation7619.d(714): Deprecation: class `deprecation7619.Multi!(int, old, int).Class` is deprecated
fail_compilation\deprecation7619.d(715): Deprecation: interface `deprecation7619.Multi!(int, old, int).Interface` is deprecated
fail_compilation\deprecation7619.d(716): Deprecation: union `deprecation7619.Multi!(int, old, int).Union` is deprecated
fail_compilation\deprecation7619.d(717): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(717): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(718): Deprecation: variable `deprecation7619.Multi!(int, old, int).TypeSize` is deprecated
fail_compilation\deprecation7619.d(720): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(721): Deprecation: function `deprecation7619.Multi!(int, normal, S).foo` is deprecated
fail_compilation\deprecation7619.d(721): Deprecation: function `deprecation7619.Multi!(int, normal, S).foo` is deprecated
fail_compilation\deprecation7619.d(722): Deprecation: struct `deprecation7619.Multi!(int, normal, S).Struct` is deprecated
fail_compilation\deprecation7619.d(723): Deprecation: class `deprecation7619.Multi!(int, normal, S).Class` is deprecated
fail_compilation\deprecation7619.d(724): Deprecation: interface `deprecation7619.Multi!(int, normal, S).Interface` is deprecated
fail_compilation\deprecation7619.d(725): Deprecation: union `deprecation7619.Multi!(int, normal, S).Union` is deprecated
fail_compilation\deprecation7619.d(727): Deprecation: variable `deprecation7619.Multi!(int, normal, S).TypeSize` is deprecated
fail_compilation\deprecation7619.d(837): Error: template instance `deprecation7619.templMain2!()` error instantiating
---
*/
#line 700
void templMain2()()
{
    alias M1 = Multi!(S, normal, int);
    M1.foo();
    M1.Struct s1;
    M1.Class c1;
    M1.Interface i1;
    M1.Union u1;
    M1.bar();
    auto ts1 = M1.TypeSize;

    alias M2 = Multi!(int, old, int);
    M2.foo();
    M2.Struct s2;
    M2.Class c2;
    M2.Interface i2;
    M2.Union u2;
    M2.bar();
    auto ts2 = M2.TypeSize;

    alias M3 = Multi!(int, normal, S);
    M3.foo();
    M3.Struct s3;
    M3.Class c3;
    M3.Interface i3;
    M3.Union u3;
    M3.bar();
    auto ts3 = M3.TypeSize;
}

/*
TEST_OUTPUT:
---
fail_compilation\deprecation7619.d(803): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(804): Deprecation: function `deprecation7619.templMain3!().templMain3.MultiMixin!(S, normal, int).foo` is deprecated
fail_compilation\deprecation7619.d(805): Deprecation: struct `deprecation7619.templMain3!().templMain3.MultiMixin!(S, normal, int).Struct` is deprecated
fail_compilation\deprecation7619.d(805): Deprecation: struct `deprecation7619.templMain3!().templMain3.MultiMixin!(S, normal, int).Struct` is deprecated
fail_compilation\deprecation7619.d(806): Deprecation: class `deprecation7619.templMain3!().templMain3.MultiMixin!(S, normal, int).Class` is deprecated
fail_compilation\deprecation7619.d(806): Deprecation: class `deprecation7619.templMain3!().templMain3.MultiMixin!(S, normal, int).Class` is deprecated
fail_compilation\deprecation7619.d(807): Deprecation: interface `deprecation7619.templMain3!().templMain3.MultiMixin!(S, normal, int).Interface` is deprecated
fail_compilation\deprecation7619.d(807): Deprecation: interface `deprecation7619.templMain3!().templMain3.MultiMixin!(S, normal, int).Interface` is deprecated
fail_compilation\deprecation7619.d(808): Deprecation: union `deprecation7619.templMain3!().templMain3.MultiMixin!(S, normal, int).Union` is deprecated
fail_compilation\deprecation7619.d(808): Deprecation: union `deprecation7619.templMain3!().templMain3.MultiMixin!(S, normal, int).Union` is deprecated
fail_compilation\deprecation7619.d(809): Deprecation: alias `deprecation7619.templMain3!().templMain3.MultiMixin!(S, normal, int).bar` is deprecated
fail_compilation\deprecation7619.d(810): Deprecation: variable `deprecation7619.templMain3!().templMain3.MultiMixin!(S, normal, int).TypeSize` is deprecated
fail_compilation\deprecation7619.d(813): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(814): Deprecation: function `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, int).foo` is deprecated
fail_compilation\deprecation7619.d(815): Deprecation: struct `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, int).Struct` is deprecated
fail_compilation\deprecation7619.d(815): Deprecation: struct `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, int).Struct` is deprecated
fail_compilation\deprecation7619.d(816): Deprecation: class `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, int).Class` is deprecated
fail_compilation\deprecation7619.d(816): Deprecation: class `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, int).Class` is deprecated
fail_compilation\deprecation7619.d(817): Deprecation: interface `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, int).Interface` is deprecated
fail_compilation\deprecation7619.d(817): Deprecation: interface `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, int).Interface` is deprecated
fail_compilation\deprecation7619.d(818): Deprecation: union `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, int).Union` is deprecated
fail_compilation\deprecation7619.d(818): Deprecation: union `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, int).Union` is deprecated
fail_compilation\deprecation7619.d(819): Deprecation: alias `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, int).bar` is deprecated
fail_compilation\deprecation7619.d(819): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(820): Deprecation: variable `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, int).TypeSize` is deprecated
fail_compilation\deprecation7619.d(823): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(823): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(824): Deprecation: function `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, S).foo` is deprecated
fail_compilation\deprecation7619.d(825): Deprecation: struct `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, S).Struct` is deprecated
fail_compilation\deprecation7619.d(825): Deprecation: struct `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, S).Struct` is deprecated
fail_compilation\deprecation7619.d(826): Deprecation: class `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, S).Class` is deprecated
fail_compilation\deprecation7619.d(826): Deprecation: class `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, S).Class` is deprecated
fail_compilation\deprecation7619.d(827): Deprecation: interface `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, S).Interface` is deprecated
fail_compilation\deprecation7619.d(827): Deprecation: interface `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, S).Interface` is deprecated
fail_compilation\deprecation7619.d(828): Deprecation: union `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, S).Union` is deprecated
fail_compilation\deprecation7619.d(828): Deprecation: union `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, S).Union` is deprecated
fail_compilation\deprecation7619.d(829): Deprecation: alias `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, S).bar` is deprecated
fail_compilation\deprecation7619.d(829): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation\deprecation7619.d(830): Deprecation: variable `deprecation7619.templMain3!().templMain3.MultiMixin!(int, old, S).TypeSize` is deprecated
fail_compilation\deprecation7619.d(838): Error: template instance `deprecation7619.templMain3!()` error instantiating
---
*/
#line 800
void templMain3()()
{
    {
        mixin MultiMixin!(S, normal, int);
        foo();
        Struct s;
        Class c;
        Interface i;
        Union u;
        bar();
        auto ts = TypeSize;
    }
    {
        mixin MultiMixin!(int, old, int);
        foo();
        Struct s;
        Class c;
        Interface i;
        Union u;
        bar();
        auto ts = TypeSize;
    }
    {
        mixin MultiMixin!(int, old, S);
        foo();
        Struct s;
        Class c;
        Interface i;
        Union u;
        bar();
        auto ts = TypeSize;
    }
}

void forceCompile()
{
    templMain1();
    templMain2();
    templMain3();
}

/*
TEST_OUTPUT:
---
fail_compilation\deprecation7619.d(903): Deprecation: function `deprecation7619.call!(overload1).call` is deprecated
fail_compilation\deprecation7619.d(905): Deprecation: function `deprecation7619.call!(overload2).call` is deprecated
---
*/
#line 900
void other()
{
    call!overload1(1);
    call!overload1();
    call!overload2(true);
    call!overload2();
}

void overload1(int) {}

deprecated void overload1() {}

deprecated void overload2() {}

void overload2(bool) {}

auto call(alias f, T...)(T params)
{
    return f(params);
}

/*
TEST_OUTPUT:
---
fail_compilation\deprecation7619.d(1002): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(1002): Deprecation: function `deprecation7619.chain1!(const(S)).chain1` is deprecated
---
*/
#line 1000
void caller()
{
    chain1!(const S)();
}

deprecated void deprCaller()
{
    chain1!(immutable S)();
}

void chain1(T)()
{
    T t;
    chain2(t);
}

void chain2(T)(T par)
{
    static if (is(T == const U, U))
        chain1!U();
    else
        T var;
}