#ifndef _ANSIDECL_H
#define _ANSIDECL_H

#ifndef PTR
#ifndef __STDC__
#define PTR char *
#else
#define PTR void *
#endif
#endif

#ifndef PARAMS
#if !defined(__STDC__)
#define PARAMS(ARGS)  ARGS
#else
#define PARAMS(ARGS)  ()
#endif
#endif

#ifndef __attribute__
# if !defined __GNUC__ || !defined __GNUC_MINOR__
#  define __attribute__(x)
# elif  (__GNUC__ * 1000 + __GNUC_MINOR__) < 2007
#  define __attribute__(x)
# endif
#endif

/* Attribute __malloc__ on functions was valid as of gcc 2.96. */
#ifndef ATTRIBUTE_MALLOC
# if (__GNUC__ * 1000 + __GNUC_MINOR__) >= 2096
#  define ATTRIBUTE_MALLOC __attribute__ ((__malloc__))
# else
#  define ATTRIBUTE_MALLOC
# endif /* GNUC >= 2.96 */
#endif /* ATTRIBUTE_MALLOC */

/* Attribute __const__ on functions was valid as of gcc 2.96. */
#ifndef ATTRIBUTE_CONST
# if (__GNUC__ * 1000 + __GNUC_MINOR__) >= 2096
#  define ATTRIBUTE_CONST __attribute__ ((__const__))
# else
#  define ATTRIBUTE_CONST
# endif /* GNUC >= 2.96 */
#endif /* ATTRIBUTE_CONST */

/* Attribute __pure__ on functions was valid as of gcc 2.96. */
#ifndef ATTRIBUTE_PURE
# if (__GNUC__ * 1000 + __GNUC_MINOR__) >= 2096
#  define ATTRIBUTE_PURE __attribute__ ((__pure__))
# else
#  define ATTRIBUTE_PURE
# endif /* GNUC >= 2.96 */
#endif /* ATTRIBUTE_PURE */

#ifndef ATTRIBUTE_UNUSED
# define ATTRIBUTE_UNUSED __attribute__ ((__unused__))
#endif /* ATTRIBUTE_UNUSED */

#ifndef ATTRIBUTE_NORETURN
# define ATTRIBUTE_NORETURN __attribute__ ((__noreturn__))
#endif /* ATTRIBUTE_NORETURN */

#ifndef ATTRIBUTE_PRINTF
# define ATTRIBUTE_PRINTF(m, n) __attribute__ ((__format__ (__printf__, m, n)))
#endif /* ATTRIBUTE_PRINTF */

#define ATTRIBUTE_PRINTF_1 ATTRIBUTE_PRINTF(1, 2)
#define ATTRIBUTE_PRINTF_2 ATTRIBUTE_PRINTF(2, 3)
#define ATTRIBUTE_PRINTF_3 ATTRIBUTE_PRINTF(3, 4)
#define ATTRIBUTE_PRINTF_4 ATTRIBUTE_PRINTF(4, 5)
#define ATTRIBUTE_PRINTF_5 ATTRIBUTE_PRINTF(5, 6)

#endif
