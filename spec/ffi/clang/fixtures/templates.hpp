// Test fixture for template argument methods

template<typename T>
class Ptr {
public:
	T* ptr;
};

class Impl;  // Forward declaration (incomplete)

class FileStorage {
public:
	Ptr<Impl> p;  // template with incomplete type argument
};

class Container {
public:
	Ptr<int> data;  // template with complete type argument
};
