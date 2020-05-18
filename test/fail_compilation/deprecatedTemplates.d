/*
REQUIRED_ARGS: -de

TEST_OUTPUT:
----
fail_compilation/deprecatedTemplates.d(17): Deprecation: template `deprecatedTemplates.AliasSeq(V...)` is deprecated
fail_compilation/deprecatedTemplates.d(24): Deprecation: template `deprecatedTemplates.AliasSeq2(V...)` is deprecated
fail_compilation/deprecatedTemplates.d(28): Deprecation: struct `deprecatedTemplates.S1(V...)` is deprecated
fail_compilation/deprecatedTemplates.d(35): Deprecation: struct `deprecatedTemplates.S2(V...)` is deprecated
fail_compilation/deprecatedTemplates.d(43): Deprecation: template `deprecatedTemplates.C(V...)` is deprecated
----
*/


deprecated alias AliasSeq(V...) = V;

alias x = AliasSeq!(1, 2, 3);

template AliasSeq2(V...)
{
    deprecated alias AliasSeq2 = V;
}

alias y = AliasSeq2!(1, 2, 3);

deprecated struct S1(V...) {}

alias T1 = S1!();

template S2(V...)
{
    deprecated struct S2 {}
}

alias T2 = S2!();

deprecated template C(V...)
{
    int i;
    int j;
}

alias D = C!();

/*
FIXME: Some errors get lost???

TEST_OUTPUT:
----
fail_compilation/deprecatedTemplates.d(102): Deprecation: template `deprecatedTemplates.AliasSeqMsg(V...)` is deprecated - Reason
fail_compilation/deprecatedTemplates.d(109): Deprecation: template `deprecatedTemplates.AliasSeq2Msg(V...)` is deprecated
----
*/
#line 100
deprecated("Reason") alias AliasSeqMsg(V...) = V;

alias xMsg = AliasSeqMsg!(1, 2, 3);

template AliasSeq2Msg(V...)
{
    deprecated("Reason") alias AliasSeq2Msg = V;
}

alias yMsg = AliasSeq2Msg!(1, 2, 3);

/*
TEST_OUTPUT:
----
fail_compilation/deprecatedTemplates.d(307): Deprecation: template `deprecatedTemplates.multiply()()` is deprecated
----
*/
#line 300
template multiply()
{
    void foo() {}
    deprecated void multiply() { foo(); bar(); }
    void bar();
}

alias mult = multiply!();


#line 400
deprecated void foo()
{
    S1!() sa;
    S2!() sb;
}
