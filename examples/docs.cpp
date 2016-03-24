
/** A test class which does nothing.

	This is used by `main`.
*/
template<typename T>
class Test {};

/// This is a specialization for integers.
template<>
class Test<int> {
public:
	/// The number of times it has been incremented.
	int count;
	
};

/// This always fails.
/// @param argc The number of items in `argv`. At least 1.
/// @param argv The command line arguments, with argv[0] being the command used to execute this program.
int main(int argc, char ** argv) {
	Test<int> test;
	
	return 1;
}
