#ifndef __ANSIDECL_H_SEEN
#define __ANSIDECL_H_SEEN

#ifdef __STDC__
#define PARAMS(x) x
#ifndef PTR
typedef void *PTR;
#endif
#else
#define CONST const
#define PARAMS(x) ()
#ifndef PTR
typedef char *PTR;
#endif
#endif

#endif
