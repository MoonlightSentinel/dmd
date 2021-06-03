// https://issues.dlang.org/show_bug.cgi?id=21989
// Permutations only need to check optimizations
// REQUIRED_ARGS: -g
/*
RUN_OUTPUT:
---
---
*/

// import core.stdc.stdio;

@safe pure:

struct S
{
    pure:

    int x = 42;
    int y;

    this(int y)
    {
        this.y = y;
    }

    this(this)
    {
        if (x != 42)
            assert(false);
    }

    ~this()
    {
        if (x != 42)
        {
            // puts("OH NO!");
            // *(cast(int*) 1234) = 1;
            assert(false);
        }
        x = 0; // omitting this makes "OH NO!" go away
    }
}

class CustomException : Exception
{
    this() pure
    {
        super("Custom");
    }
}

class TestClass
{
    S s;

    this() pure
    {
        throw new CustomException();
    }
}

struct TestStruct
{
    S s;

    this(int) pure
    {
        throw new CustomException();
    }
}

void main()
{
    try
        new TestClass();
    catch (CustomException e) {}

    try
        scope t = new TestClass();
    catch (CustomException e) {}

    try
        new TestStruct(1);
    catch (CustomException e) {}

    try
        scope t = TestStruct(1);
    catch (CustomException e) {}

    /* Temporaries never reach the array memory...
    try
        TestStruct[] arr = [TestStruct(1), TestStruct(2)];
    catch (CustomException e) {}
    */
    // puts("END main");
}
