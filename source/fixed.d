module fixed;


struct 
Fixed (byte FRACBITS=16) {
    int a;

    enum FRAC_UNIT       = ( 1 <<  FRACBITS );     // 0b1_0000_0000_0000_0000 = 0x10000 = 65536
    enum HALF_FRAC_UNIT  = ( 1 << (FRACBITS/2) );  // 0b__0000_0001_0000_0000 = 0x__100 = 256
    enum ROUND_MASK      = ( 1 << (FRACBITS-1) );  // 0b__1000_0000_0000_0000 = 0x_8000 = 32768
    alias T = typeof(this);


    this (int _int, int _fraq) {
        a = _int * FRAC_UNIT + _fraq;
    }

    this (int _fixed) {
        a = _fixed;
    }

    void
    opOpAssign (string op : "+")( T b ) {
        a += b.a;
    }

    void
    opOpAssign (string op : "-")( T b ) {
        a -= b.a;
    }

    T
    opBinary (string op : "+")( T b ) {
        return T (a + b.a);
    }

    T
    opBinary (string op : "-")( T b ) {
        return T (a - b.a);
    }

    int 
    opCmp (T b) {
        if (a == b.a)
            return 0;

        if (a > b.a)
            return 1;

        return -1;
    }

    T 
    opBinary (string op : "/") (T b) if (FRACBITS%2 == 0) {
        return T ((a/HALF_FRAC_UNIT) / (b.a/HALF_FRAC_UNIT));
    }

    T 
    opBinary (string op : "/") (T b) if (FRACBITS%2 == 1) {
        import std.conv;

        double c = (cast(double)a) / (cast(double)b.a) * FRAC_UNIT;

        return T (c.to!int);
    }

    T 
    opBinary (string op : "*") (T b) {
        import std.conv;

        long c = (cast(long)a) * (cast(long)b.a) / FRAC_UNIT;

        return T (c.to!int);
    }

    T 
    opBinary (string op : "/") (int b) {
        return T (a/b);
    }

    T 
    opBinary (string op : "*") (int b) {
        return T (a*b);
    }

    int
    to_int () {
        return (a + ROUND_MASK) / FRAC_UNIT;
    }

    short
    to_short () {
        return cast(short)((a + ROUND_MASK) / FRAC_UNIT);
    }

    string 
    toString () {
        import std.format : format;
        return format!"%s(%d)"( typeof(this).stringof, a / 2^^16 );
    }
}

