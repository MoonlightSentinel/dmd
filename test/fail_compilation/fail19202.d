// REQUIRED_ARGS: -de
/*
TEST_OUTPUT:
---
fail_compilation/fail19202.d(11): Deprecation: template `fail19202.X()` is deprecated
---
*/

void main()
{
    auto b = X!();
}

template X()
{
    deprecated enum X = true;
}
