// REQUIRED_ARGS: -de
// https://issues.dlang.org/show_bug.cgi?id=6519

void fooTypes(T, alias f, U...)(T t = T.init, U[0] u = U[0].init)
{
    T var;
    f();
    U otherVars;
}

T foo(T)(T t = T.init)
{
    return T.init;
}

struct Struct(T)
{
    T m;

    void foo()
    {
        T t;
    }
}

class Class(alias f)
{
    typeof(f()) m;

    void foo()
    {
        f();
    }
}

interface Interface(T)
{
    void foo(T args);
}

union Union(U...)
{
    U u;
}

alias Alias(T) = T;

enum TypeSize(T) = T.sizeof;

template Multi(T)
{
    void bar(T t = T.init)
    {
        T var;
    }
}

mixin template MultiMixin(T)
{
    T bar(T t = T.init)
    {
        T var;
        return var;
    }
}

deprecated struct S {}

deprecated int old() { return 0; }

int normal() { return 1; }

/*
Most importantly, not deprecation messages when instantiated from a deprecated scope
*/
#line 100
deprecated void deprecatedMain()
{
    { fooTypes!(S, normal, int)(); }
    { fooTypes!(int, old, int)(); }
    { fooTypes!(int, normal, S)(); }

    { foo!(S)(); }
    { Struct!(S) s; }
    { Class!(old) c; }
    { Interface!(S) i; }
    { Union!(S, int) u; }
    { alias A = Alias!(S); }
    { enum ts = TypeSize!(S); }
    {
        alias M1 = Multi!(S);
        M1.bar();
    }
    {
        mixin MultiMixin!(S);
        bar();
    }
}

/*
Only issue deprecations for the deprecated parameter(s)

TEST_OUTPUT:
---
fail_compilation/deprecation7619.d(202): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation/deprecation7619.d(203): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation/deprecation7619.d(204): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation/deprecation7619.d(205): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation/deprecation7619.d(206): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation/deprecation7619.d(207): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation/deprecation7619.d(208): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation/deprecation7619.d(210): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation/deprecation7619.d(214): Deprecation: struct `deprecation7619.S` is deprecated
---
*/
#line 200
void normalMain1()
{
    { foo!(S)(); }
    { Struct!(S) s; }
    { Class!(old) c; }
    { Interface!(S) i; }
    { Union!(S, int) u; }
    { alias A = Alias!(S); }
    { enum ts = TypeSize!(S); }
    {
        alias M1 = Multi!(S);
        M1.bar();
    }
    {
        mixin MultiMixin!(S);
        bar();
    }
}

/*
TEST_OUTPUT:
---
fail_compilation/deprecation7619.d(302): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation/deprecation7619.d(303): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation/deprecation7619.d(304): Deprecation: struct `deprecation7619.S` is deprecated
---
*/
#line 300
void normalMain2()
{
    { fooTypes!(S, normal, int)(); }
    { fooTypes!(int, old, int)(); }
    { fooTypes!(int, normal, S)(); }
}

/*
Inference doesn't apply if the symbol is not a template parameter

TEST_OUTPUT:
---
fail_compilation/deprecation7619.d(402): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation/deprecation7619.d(403): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation/deprecation7619.d(404): Deprecation: function `deprecation7619.old` is deprecated
fail_compilation/deprecation7619.d(405): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation/deprecation7619.d(406): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation/deprecation7619.d(407): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation/deprecation7619.d(408): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation/deprecation7619.d(425): Error: template instance `deprecation7619.templMain1!()` error instantiating
fail_compilation/deprecation7619.d(413): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation/deprecation7619.d(426): Error: template instance `deprecation7619.templMain2!()` error instantiating
fail_compilation/deprecation7619.d(419): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation/deprecation7619.d(427): Error: template instance `deprecation7619.templMain3!()` error instantiating
---
*/
#line 400
void templMain1()()
{
    { foo!(S)(); }
    { Struct!(S) s; }
    { Class!(old) c; }
    { Interface!(S) i; }
    { Union!(S, int) u; }
    { alias A = Alias!(S); }
    { enum ts = TypeSize!(S); }
}

void templMain2()()
{
    alias M1 = Multi!(S);
    M1.bar();
}

void templMain3()()
{
    mixin MultiMixin!(S);
    bar();
}

void forceCompile()
{
    templMain1();
    templMain2();
    templMain3();
}

/*
Inference resolves the correct overload.

TODO: Overload deprecation depends on the declaration order, hence the wrong diagnostics for overload* below.
      (This is already in master, hence ignoring it for now)

TEST_OUTPUT:
---
fail_compilation/deprecation7619.d(503): Deprecation: function `deprecation7619.call!(overload1)` is deprecated
fail_compilation/deprecation7619.d(504): Deprecation: function `deprecation7619.overload2` is deprecated
fail_compilation/deprecation7619.d(505): Deprecation: function `deprecation7619.overload2` is deprecated
fail_compilation/deprecation7619.d(505): Deprecation: function `deprecation7619.call!(overload2)` is deprecated
---
*/
#line 500
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
Inference works across transitive template instances.

TEST_OUTPUT:
---
fail_compilation\deprecation7619.d(602): Deprecation: struct `deprecation7619.S` is deprecated
fail_compilation\deprecation7619.d(602): Deprecation: function `deprecation7619.chain1!(const(S)).chain1` is deprecated
---
*/
#line 600
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