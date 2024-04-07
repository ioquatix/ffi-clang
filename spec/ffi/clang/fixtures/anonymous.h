#ifndef ANONYMOUS_H
#define ANONYMOUS_H

// This variable has an anonymous structure type
struct
{
	int field1;
} someVariable;

struct A
{
	struct
	{
		int field2;
	} anonymousField;
}