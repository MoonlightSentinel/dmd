module dmd.graphviz;

import std.stdio;

void toGraph(T)(ref const T node, const char[] filename)
{
    auto file = File(filename, "w");
    toGraph!T(node, file);
}

void toGraph(T)(ref const T node, ref File file)
{
    GraphvizDumper gd;
    gd.printKind = TypeKindOf!T;
    gd.dump(node, file);
}

private:

struct GraphvizDumper
{
    import dmd.identifier : Identifier;
    import dmd.globals : Loc;
    import dmd.root.outbuffer : OutBuffer;

    OutBuffer* nodes;
    OutBuffer* edges;
    bool[void*] matched;
    bool hasModule;
    TypeKind printKind;

    void dump(T)(ref const T s, scope ref File file)
    {
        OutBuffer nodes;
        OutBuffer edges;
        nodes.doindent  = edges.doindent    = true;
        nodes.spaces    = edges.spaces      = false;
        nodes.level     = edges.level       = 1;

        this.nodes = &nodes;
        this.edges = &edges;

        print(s);
        finalize(file);
    }

private:

    void finalize(scope ref File file)
    {
        file.writeln(`
digraph {
    node [shape=record];
`);
        file.writeln((*nodes)[]);
        file.writeln((*edges)[]);
        file.writeln(`}`);
    }

    bool print(T)(ref const T s)
    {
        if ((TypeKindOf!T & printKind) == 0)
            return false;

        import dmd.ast_node : ASTNode;
        import dmd.dmodule : Module;
        static if (is(immutable T == immutable Module))
        {
            if (hasModule)
                return false;
            else
                hasModule = true;
        }

        static if (is(immutable T : immutable ASTNode))
        {
            if (!s)
                return false;

            // Route through visitor to get the correct type
            scope visitor = new GraphvizVisitor(this);
            (cast(T) s).accept(visitor);
        }
        else
        {
            printImpl(s);
        }

        return true;
    }

    void printImpl(T)(ref const T s)
    {
        const ptr = asPointer(s);
        if (!ptr)
            return;

        if (ptr in matched)
            return;
        matched[ptr] = true;

        nodes.printf(`%zu [ label = "{`, cast(size_t) ptr);
        nodes.writenl();
        nodes.level++;
        nodes.writestring(`<object_header> `);

        // Prevent assert(false) in ASTNode.toString()
        static if (__traits(compiles, (cast(T) s).toString()) && (!is(T == class) || __traits(isOverrideFunction, __traits(getMember, s, "toString"))))
            nodes.writestring(s.toString());
        else
            nodes.printf(`%p`, ptr);

        nodes.writestring(" : " ~ T.stringof);

        foreach (const recurse; [ false, true ])
        {
            static if (is(T == class))
            {
                import std.traits : BaseClassesTuple;

                static foreach (alias Base ; BaseClassesTuple!T)
                {{
                    const Base b = s;
                    printAllMembers(b, ptr, recurse);
                }}
            }

            printAllMembers(s, ptr, recurse);

            if (!recurse)
            {
                // Finish current node
                nodes.level--;
                nodes.writenl();
                nodes.writestringln(`}" ];`);
                nodes.writenl();
            }
        }
    }

    void printAllMembers(T)(ref const T s, const void* ptr, const bool recurse)
    {
        static foreach(const idx; 0 .. s.tupleof.length)
        {
            printMember(
                ptr,
                s.tupleof[idx].stringof[2..$],
                s.tupleof[idx],
                recurse
            );
        }
    }

    void printMember(T)(const void* parent, const string name, const ref T member, const bool recurse)
    {
        import dmd.ctorflow : CtorFlow;
        import dmd.dsymbol;
        import dmd.dmacro : MacroTable;
        import dmd.doc : Escape;
        import dmd.root.bitarray : BitArray;
        import dmd.root.filename : FileName;

        static if (is(immutable T == immutable U*, U))
        {
            // BUG: Cannot declare ref variables of opaque types...
            static if (__traits(compiles, { const U u; }))
            {
                if (member && ((cast(size_t) member) >= 100))
                    printMember(parent, name, *member, recurse);
            }
            else
            {
                if (recurse)
                    return;

                printPrefix(name);
                nodes.printf("%p (opaque)", member);
            }
        }
        else static if (is(typeof(member[]) : const E[], E))
        {
            if (member.length)
                printSliceMember(parent, name, member[], recurse);
        }
        else static if (
            is(immutable T : immutable CtorFlow) ||
            is(immutable T : immutable DsymbolTable) ||
            is(immutable T : immutable Escape) ||
            is(immutable T : immutable MacroTable)
        )
        {
            // Ignore clutter
        }
        else static if (is(immutable T : immutable Loc))
        {
            if (recurse)
                return;

            printPrefix(name);

            if (member != Loc.initial)
                nodes.printf("%s:%u:%u", member.filename, member.linnum, member.charnum);
            else
                nodes.writestring("???");
        }
        else static if (is(immutable T : immutable BitArray))
        {
            if (recurse)
                return;

            printPrefix(name);

            bool brokeLine;
            nodes.writestring("[");
            foreach (const idx; 0 .. member.length)
            {
                if (idx)
                    nodes.writestring(", ");
                printValue(member[idx]);

                if (idx && (idx % 10 == 0))
                {
                    if (!brokeLine)
                    {
                        nodes.level++;
                        brokeLine = true;
                    }
                    nodes.writestringln(`\n`);
                }
            }
            nodes.writestring("]");
        }
        else static if (is(immutable T : immutable Visibility))
        {
            if (recurse)
                return;

            printPrefix(name);
            printValue(member.kind);
        }
        else static if (is(immutable T : immutable FileName)
        )
        {
            if (recurse)
                return;

            printPrefix(name);
            nodes.writestring(member.toString());
        }
        else static if (
            is(immutable T : immutable Identifier)
        )
        {
            if (recurse)
                return;

            printPrefix(name);

            if (member && ((cast(void*) member) >= (cast(void*) 100)))
                nodes.writestring(member.toString());
        }
        else static if (is(T == struct) || is(T == class))
        {
            if (!recurse)
                return;

            print(member);
            printEdge(parent, name, member);
        }
        else
        {
            if (recurse)
                return;

            printPrefix(name);

            static if (is(T == union))
                nodes.writestring("???");
            else
                printValue(member);
        }
    }

    void printSliceMember(E)(const void* parent, const string name, const E[] member, const bool recurse)
    {
        static if (is(typeof(&asPointer!E)))
        {
            if (!recurse)
                return;

            foreach (const idx, const ref entry; member[])
            {
                printEdge(parent, name, idx, entry);
            }
        }
        else
        {
            if (recurse)
                return;

            printPrefix(name);
            printValue(member);
        }
    }

    void printPrefix(string name)
    {
        nodes.writenl();
        nodes.writestring("|<");
        nodes.writestring(name);
        nodes.writestring("> ");
        nodes.writestring(name);
        nodes.writestring(" = ");
    }

    void printValue(T)(const T value)
    {
        static if (__traits(isIntegral, T))
        {
            static if (is(T == bool))
                nodes.writestring(value ? "true" : "false");
            else static if (__traits(isUnsigned, T))
                nodes.printf("%llu", cast(ulong) value);
            else
                nodes.printf("%lld", cast(long) value);
        }
        else static if (__traits(isFloating, T))
        {
            nodes.printf("%f", cast(double) value);
        }
        else static if (is(immutable T == immutable U*, U))
        {
            nodes.printf("%p", value);
        }
        else static if (is(immutable T : immutable U[], U))
        {
            bool brokeLine;
            foreach (const idx, const ref entry; value)
            {
                if (idx)
                    nodes.writestring(", ");
                printValue(entry);

                if (idx && (idx % 10 == 0))
                {
                    if (!brokeLine)
                    {
                        nodes.level++;
                        brokeLine = true;
                    }
                    nodes.writestringln(`\n`);
                }
            }

            if (brokeLine)
                nodes.level--;
        }
        else static if (is(immutable T == immutable V[K], K, V))
        {
            bool first = true;

            foreach (const ref k, const ref v; value)
            {
                if (first)
                    first = false;
                else
                    nodes.writestring(", ");
                printValue(k);
                nodes.writestring(" = ");
                printValue(v);
            }

        }
        else
        {
            // static assert(false, "Not implemented: " ~ T.stringof);
            nodes.writestring('(' ~ T.stringof ~ ')');
        }
    }

    void printValue(const char[] value)
    {
        nodes.writestring(`\"`);
        nodes.writestring(value);
        nodes.writestring(`\"`);
    }

    void printValue(const char* value)
    {
        nodes.writestring(`\"`);
        nodes.writestring(value);
        nodes.writestring(`\"`);
    }

    void printEdge(T)(const void* from, const string name, const ref T t)
    {
        if (print(t))
            printEdge(from, name, asPointer(t));
    }

    void printEdge(const void* from, const string name, const void* to)
    {
        if (!from || !to)
            return;

        edges.printf(`%zu -> %zu [ label = "%.*s" ]`, cast(size_t) from, cast(size_t) to, cast(int) name.length, name.ptr);
        edges.writenl();
    }

    void printEdge(T)(const void* from, const string name, const size_t idx, const ref T t)
    {
        if (print(t))
            printEdge(from, name, idx, asPointer(t));
    }

    void printEdge(const void* from, const string name, const size_t idx, const void* to)
    {
        if (!from || !to)
            return;

        edges.printf(`%zu -> %zu [ label = "%.*s[%zu]" ]`, cast(size_t) from, cast(size_t) to, cast(int) name.length, name.ptr, idx);
        edges.writenl();
    }

    void printSTC(const long member)
    {
        import dmd.declaration : STC;

        bool first = true;
        static foreach (stc; __traits(allMembers, STC))
        {
            if (member & __traits(getMember, STC, stc))
            {
                if (first)
                    first = false;
                else
                    nodes.writestring(", ");
                nodes.writestring(stc);
            }
        }
    }

    static const(void*) asPointer(T)(ref const T val)
    {
        static if (is(T == class))
        {
            return cast(void*) val;
        }
        else static if (is(immutable T == immutable U*, U))
        {
            static assert(is(U == class) || is(U == struct));
            return val;
        }
        else
        {
            static assert (is(T == struct));
            return &val;
        }
    }
}

import dmd.visitor : Visitor;

extern(C++) final class GraphvizVisitor : Visitor
{
    GraphvizDumper* gd;

    this(ref GraphvizDumper gd)
    {
        this.gd = &gd;
    }

    static foreach (alias member; __traits(getOverloads, Visitor, "visit"))
    {
        override void visit(ParameterType!member node)
        {
            this.gd.printImpl(node);
        }
    }
}

template ParameterType(alias fun)
{
    static if (is(typeof(fun) P == __parameters))
        alias ParameterType = P;
    else
        static assert(false);
}

enum TypeKind : ubyte
{
    symbol      = 1 << 0,
    statement   = 1 << 1,
    expression  = 1 << 2,
    other       = 1 << 7,

    anyAST = symbol | statement | expression,
    any = anyAST | other
}

template TypeKindOf(T)
{
    import dmd.dsymbol : Dsymbol;
    import dmd.expression : Expression;
    import dmd.statement : Statement;

    static if (is(immutable T : immutable Dsymbol))
    {
        enum TypeKindOf = TypeKind.symbol;
    }
    else static if (is(immutable T : immutable Statement))
    {
        enum TypeKindOf = TypeKind.statement;
    }
    else static if (is(immutable T : immutable Expression))
    {
        enum TypeKindOf = TypeKind.expression;
    }
    else
    {
        enum TypeKindOf = TypeKind.other;
    }
}

unittest
{
    import dmd.dsymbol : ScopeDsymbol;
    import dmd.expression : AssignExp;
    import dmd.statement : CompileStatement;

    assert(TypeKindOf!ScopeDsymbol == TypeKind.symbol);
    assert(TypeKindOf!AssignExp == TypeKind.expression);
    assert(TypeKindOf!CompileStatement == TypeKind.statement);
    assert(TypeKindOf!int == TypeKind.other);
}
