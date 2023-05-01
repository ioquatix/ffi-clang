class MyClass1 {
	void create();
};

void MyClass1::create()
{
  this->create();
}

class MyClass2 {
public:
	MyClass2();
	~MyClass2();

	MyClass2(int value);
	explicit MyClass2(double value);

	MyClass2(const MyClass2& other) = default;
	MyClass2(MyClass2&& other);
};

class MyClass3 {
public:
	virtual void iAmAbstract() = 0;
	mutable int changeMe;
};

