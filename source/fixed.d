module fixed;

// 1.0 = INT.FRAC = 16-bit . 16-bit
//
// Example:
//   auto fixed_one  = Fixed(1,0);
//   auto fixed_zero = Fixed(0,0);
//   writeln (fixed_one);          // Fixed!16(0)
//   writeln (fixed_zero);         // Fixed!16(1)
//   writeln (fixed_zero.to_int);  // 1
struct 
Fixed (int FRAC_BITS=16)  if (FRAC_BITS>0 && FRAC_BITS<(int.sizeof*8)) {
    int a;

    enum FRAC_UNIT       = ( 1 <<  FRAC_BITS );     // 0b1_0000_0000_0000_0000 = 0x10000 = 65536
    enum HALF_FRAC_UNIT  = ( 1 << (FRAC_BITS/2) );  // 0b__0000_0001_0000_0000 = 0x__100 = 256
    enum ROUND_MASK      = ( 1 << (FRAC_BITS-1) );  // 0b__1000_0000_0000_0000 = 0x_8000 = 32768
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
    opBinary (string op : "/") (T b) if (FRAC_BITS%2 == 0) {
        return T ((a/HALF_FRAC_UNIT) / (b.a/HALF_FRAC_UNIT));
    }

    T 
    opBinary (string op : "/") (T b) if (FRAC_BITS%2 == 1) {
        import std.conv;

        double c = (cast(double)a) / (cast(double)b.a) * FRAC_UNIT;

        return T (c.to!int);
    }

    T 
    opBinary (string op : "*") (T b) if (FRAC_BITS%2 == 0) {
        return T ((a/HALF_FRAC_UNIT) * (b.a/HALF_FRAC_UNIT));
    }

    T 
    opBinary (string op : "*") (T b) if (FRAC_BITS%2 == 1) {
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
        return format!"%s(%d)"( T.stringof, to_int );
    }
}

