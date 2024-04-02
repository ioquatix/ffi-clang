#ifndef FORWARD_H
#define FORWARD_H

// This is an opaque declaration, one would assume it is defined in a c file someplace
typedef struct Opaque Opaque;

// This is a forward declaration, the definition is below
struct Forward;

// This is the definition
struct Forward
{
	int field1;
}

#endif
