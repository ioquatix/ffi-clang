// Test fixture for extern "C" linkage specification

extern "C" {
    typedef unsigned short ushort;
    typedef int myint;
}

namespace ns {
    extern "C" {
        typedef float myfloat;
    }
}
