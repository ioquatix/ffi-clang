#ifndef DOCS_H
#define DOCS_H

/**
 * Short explanation
 *
 * This is a longer explanation
 * that spans multiple lines
 *
 * @param[in] input some input
 * @param[out] flags some flags
 * @param[in,out] buf some input and output buffer
 * @param option some option
 * @return a random value
 */
int a_function(char *input, int *flags, char *buf, int option);

int no_comment_function(void);

/**
 * <br />
 * <a href="http://example.org/">
 * </a>
 */
void b_function(void);

/**
 * @tparam T1 some type of foo
 * @tparam T2 some type of bar
 * @tparam T3 some type of baz
 */
template<typename T1, template<typename T2> class T3>
void c_function(T3<int> xxx);

/**
 * abc \em foo \b bar
 */
void d_function(void);

#endif
