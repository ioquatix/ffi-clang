struct A {
  virtual int func_a() = 0;
};

struct B : public virtual A {
  int func_a() { return 0; }

  static int func_b() { return 11; }
};

struct C : public virtual A {
  int func_a() { return 1; }

  enum { EnumC = 100 };
};

struct D : public B, public C {
 private:
  void func_d();
};

void D::func_d() {};

void f_variadic(int a, ...);

typedef int const* const_int_ptr;
