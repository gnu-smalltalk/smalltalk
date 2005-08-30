/******************************** -*- C -*- ****************************
 *
 *	C - Smalltalk Interface module
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,2005
 * Free Software Foundation, Inc.
 * Written by Steve Byrne.
 *
 * This file is part of GNU Smalltalk.
 *
 * GNU Smalltalk is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later 
 * version.
 * 
 * GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
 *
 ***********************************************************************/


#include "gstpriv.h"

#include <ltdl.h>

#define ARG_VEC_SIZE		20	/* 20 ints, 10 dbls */

typedef enum
{
  CPARAM_INT,
  CPARAM_LONG,
  CPARAM_PTR,
  CPARAM_FLOAT,
  CPARAM_DOUBLE
}
cparam_type;

typedef enum
{				/* types for C parameters */
  CDATA_UNKNOWN,		/* when there is no type a priori */
  CDATA_CHAR,
  CDATA_STRING,
  CDATA_STRINGOUT,		/* for things that modify string params */
  CDATA_SYMBOL,
  CDATA_BYTEARRAY,
  CDATA_BYTEARRAYOUT,
  CDATA_BOOLEAN,
  CDATA_INT,
  CDATA_UINT,
  CDATA_LONG,
  CDATA_ULONG,
  CDATA_FLOAT,
  CDATA_DOUBLE,
  CDATA_VOID,			/* valid only as a return type */
  CDATA_VARIADIC,		/* for parameters, this param is an
				   array to be interpreted as
				   arguments.  Note that only simple
				   conversions are performed in this
				   case. */
  CDATA_VARIADIC_OOP,		/* for parameters, this param is an
				   array whose elements are OOPs to be
				   passed. */
  CDATA_COBJECT,		/* a C object is being passed */
  CDATA_COBJECT_PTR,		/* a C object pointer is being passed */
  CDATA_OOP,			/* no conversion to-from C (OOP) */
  CDATA_SELF,			/* pass self as the corresponding
				   argument */
  CDATA_SELF_OOP		/* pass self as an OOP */
}
cdata_type;

typedef struct gst_cfunc_descriptor
{
  OBJ_HEADER;
  OOP cFunction;		/* gst_cobject whose C value is func
				   addr */
  OOP cFunctionName;		/* Name of C function in mapping table */
  OOP returnType;		/* Smalltalk return type */
  OOP numFixedArgs;		/* number of real arguments passed from
				   smalltalk (excluding "self" parameters
  				   which are synthetically added when
				   calling the C function). */
  OOP argTypes[1];		/* variable length, really numFixedArgs 
				   long */
}
 *gst_cfunc_descriptor;

typedef struct symbol_type_map
{
  OOP *symbol;
  cdata_type type;
}
symbol_type_map;

/* Holds onto allocated C strings and Smalltalk strings for the duration of
 * a call to a C function.  Used in _gst_invoke_croutine and push_smalltalk_obj. */
typedef struct string_info
{
  gst_uchar *cString;
  OOP stringOOP;
  cdata_type returnedType;
}
string_info;

typedef union cparam_union
{
  int intVal;
  long longVal;
  PTR ptrVal;
  float floatVal;
  double doubleVal;
  int valueVec[sizeof (double) / sizeof (int)];
}
cparam_union;

typedef struct cfunc_info
{
  avl_node_t avl;
  const char *funcName;
  p_void_func funcAddr;
}
cfunc_info;

typedef struct gst_stat
{
  unsigned short st_mode;	/* protection */
  long st_size;			/* total size, in bytes */
  long st_aTime;		/* time of last access */
  long st_mTime;		/* time of last modification */
  long st_cTime;		/* time of last change */
}
gst_stat;



/* Test/example C function and tribute to the original author :-) */
static void marli (int n);

/* Puts the parameter UP with the size and alignment given by TYP */
static void push_obj (cparam_union * up,
		      cparam_type typ);

/* Calls the function represented by DESC (of which the return type
   and pointer to the function are looked up). */
static OOP call_cfunction (gst_cfunc_descriptor desc);

/* Prints an error message... this should really make the primitive
   fail so that a WrongClass exception is generated (FIXME) */
static void bad_type (OOP class_oop,
		      cdata_type cType);

/* Determines the appropriate C mapping for OOP and calls push_obj
   for it. */
static void push_smalltalk_obj (OOP oop,
				cdata_type cType);

/* Initializes libltdl and defines the functions to access it. */
static void init_dld (void);

/* Callout to tests callins. */
static void test_callin (OOP oop);

/* Callout to test the CString class */
static void test_cstring (char **string);

/* Callout to test the CArray class */
static void test_cstring_array (int numElements,
				char **string);

/* Returns the C type (the internal enumeration value of argument
   "index") in descriptor "desc".  If index is outside the range,
   returns CDATA_UNKNOWN (presumably for dealing with variadic parameter
   lists). */
static cdata_type get_ctype (gst_cfunc_descriptor desc,
			     int index);

/* Converts a Symbol to a SmallInteger so that it is stored in the
   CFunctionDescriptor.  For the return type isReturn is passed as
   true and a CType is alwso considered valid. */
static OOP classify_type_symbol (OOP symbolOOP,
				 mst_Boolean isReturn);

/* Return the errno on output from the last callout. */
static int get_errno (void);

/* Encapsulate binary incompatibilities between various C libraries. */
static int my_stat (const char *name,
		    gst_stat * out);
static int my_putenv (const char *str);
static int my_chdir (const char *str);
static DIR *my_opendir (const char *str);
static char *extract_dirent_name (struct dirent *dir);

/* Provide access to the arguments passed via -a. */
static int get_argc (void);
static char *get_argv (int n);

/* The binary tree of function names vs. function addresses. */
static cfunc_info *c_func_root = NULL;

/* The arguments as they are passed to push_obj. The first
   free argument is pointed to by c_arg. */
static int c_arg_vec[ARG_VEC_SIZE];
static int *c_arg;

/* The information on the char * parameters to be filled back on
   output from a callOut.  Again, sip is the first free item.
   string_info_base points into the stack (in the frame of
   invoke_c_routine because we need this information to be available
   in a reentrant manner. */
static string_info *string_info_base, *sip;

/* printable names for corresponding C types */
static const char *c_type_name[] = {
  "void?",			/* CDATA_UNKNOWN */
  "char",			/* CDATA_CHAR */
  "char *",			/* CDATA_STRING */
  "char *",			/* CDATA_STRINGOUT */
  "char *",			/* CDATA_SYMBOL */
  "char *",			/* CDATA_BYTEARRAY */
  "char *",			/* CDATA_BYTEARRAYOUT */
  "int",			/* CDATA_BOOLEAN */
  "int",			/* CDATA_INT */
  "unsigned int",		/* CDATA_UINT */
  "long",			/* CDATA_LONG */
  "unsigned long",		/* CDATA_ULONG */
  "float",			/* CDATA_FLOAT */
  "double",			/* CDATA_DOUBLE */
  "void?",			/* CDATA_VOID */
  "...",			/* CDATA_VARIADIC */
  "...",			/* CDATA_VARIADIC_OOP */
  "void *",			/* CDATA_COBJECT -- this is misleading */
  "void *",			/* CDATA_COBJECT_PTR */
  "OOP",			/* CDATA_OOP */
  "void?",			/* CDATA_SELF */
  "OOP",			/* CDATA_SELF_OOP */
};

/* A map between symbols and the cdata_type enum. */
static const symbol_type_map type_map[] = {
  {&_gst_unknown_symbol, CDATA_UNKNOWN},
  {&_gst_char_symbol, CDATA_CHAR},
  {&_gst_string_symbol, CDATA_STRING},
  {&_gst_string_out_symbol, CDATA_STRINGOUT},
  {&_gst_symbol_symbol, CDATA_SYMBOL},
  {&_gst_byte_array_symbol, CDATA_BYTEARRAY},
  {&_gst_byte_array_out_symbol, CDATA_BYTEARRAYOUT},
  {&_gst_boolean_symbol, CDATA_BOOLEAN},
  {&_gst_int_symbol, CDATA_INT},
  {&_gst_uint_symbol, CDATA_UINT},
  {&_gst_long_symbol, CDATA_LONG},
  {&_gst_ulong_symbol, CDATA_ULONG},
  {&_gst_float_symbol, CDATA_FLOAT},
  {&_gst_double_symbol, CDATA_DOUBLE},
  {&_gst_void_symbol, CDATA_VOID},
  {&_gst_variadic_symbol, CDATA_VARIADIC},
  {&_gst_variadic_smalltalk_symbol, CDATA_VARIADIC_OOP},
  {&_gst_c_object_symbol, CDATA_COBJECT},
  {&_gst_c_object_ptr_symbol, CDATA_COBJECT_PTR},
  {&_gst_smalltalk_symbol, CDATA_OOP},
  {&_gst_self_symbol, CDATA_SELF},
  {&_gst_self_smalltalk_symbol, CDATA_SELF_OOP},
  {NULL, CDATA_UNKNOWN}
};


/* This is quite likely to be machine dependent.  Currently it is set
   up to work correctly on most platforms, only doubles need not have
   type size == alignment.

   The order of the array elements for alignments and type_sizes must
   equal the enum value order in cparam_type */

/* the arg vec pointer must be = 0 mod alignments[align] */
static const int alignments[] = {
  sizeof (int),			/* CPARAM_INT */
  sizeof (long),		/* CPARAM_LONG */
  sizeof (PTR),			/* CPARAM_PTR */
  sizeof (float),		/* CDATA_FLOAT */
  DOUBLE_ALIGNMENT		/* CDATA_DOUBLE */
};

static const int type_sizes[] = {
  sizeof (int),			/* CPARAM_INT */
  sizeof (long),		/* CPARAM_LONG */
  sizeof (PTR),			/* CPARAM_PTR */
  sizeof (float),		/* CDATA_FLOAT */
  sizeof (double)		/* CDATA_DOUBLE */
};

/* The errno on output from a callout */
int _gst_errno;




void
marli (int n)
{
  int i;

  for (i = 0; i < n; i++)
    printf ("Marli loves Steve!!!\n");
}

int
get_errno (void)
{
  int old;
  old = _gst_errno;
  _gst_errno = 0;
  return (old);
}

int
my_stat (const char *name,
	 gst_stat * out)
{
  int result;
  struct stat statOut;

  result = stat (name, &statOut);
  if (errno == EFAULT)
    abort ();

  if (!result)
    {
      errno = 0;
      out->st_mode = statOut.st_mode;
      out->st_size = statOut.st_size;
      out->st_aTime = _gst_adjust_time_zone (statOut.st_atime) - 86400 * 10957;
      out->st_mTime = _gst_adjust_time_zone (statOut.st_mtime) - 86400 * 10957;
      out->st_cTime = _gst_adjust_time_zone (statOut.st_ctime) - 86400 * 10957;
    }
  return (result);
}

int
my_putenv (const char *str)
{
  char *clone;
  int len;

  len = strlen (str) + 1;	/* hold the null */
  clone = (char *) xmalloc (len);
  strcpy (clone, str);
  return (putenv (clone));
}


int
my_chdir (const char *dir)
{
  int status;

  status = chdir (dir);

  if (status == 0)
    errno = 0;
  return (status);
}

DIR *
my_opendir (const char *dir)
{
  DIR *result;

  result = opendir (dir);

  if (result != 0)
    errno = 0;
  return (result);
}

void
test_callin (OOP oop)
{
  OOP o, sel;
  double f;
  _gst_str_msg_send (oop, "inspect", NULL);

  o = _gst_string_to_oop ("abc");
  sel = _gst_symbol_to_oop ("printNl");
  _gst_str_msg_send (_gst_str_msg_send (o, ",", o, NULL), "printNl",
		     NULL);
  _gst_msg_sendf (NULL, "%s %s printNl", "this is a test");
  _gst_msg_sendf (&f, "%f %i + %f", 3, 4.7);
  printf ("result = %f\n", f);
}

void
test_cstring (char **string)
{
  printf ("The string is %s\n", *string);
}

void
test_cstring_array (int numElements,
		    char **string)
{
  int i;
  for (i = 0; i < numElements; i++)
    printf ("Str[%d] = %s\n", i, string[i]);
}

char *
extract_dirent_name (struct dirent *dir)
{
  return (dir->d_name);
}

int
get_argc (void)
{
  return (_gst_smalltalk_passed_argc);
}

char *
get_argv (int n)
{
  return (n <= _gst_smalltalk_passed_argc
	  ? _gst_smalltalk_passed_argv[n - 1]
	  : NULL);
}

PTR
_gst_dld_open (const char *filename)
{
#ifdef ENABLE_DLD
  lt_dlhandle handle;
  void (*initModule) ();

  handle = lt_dlopenext (filename);
  if (handle)
    {
      initModule = lt_dlsym (handle, "gst_initModule");
      if (initModule)
	initModule (&gst_interpreter_proxy);
    }

  return (handle);
#else
  return (NULL);
#endif
}



void
init_dld (void)
{
  char *modules;
  lt_dlinit ();
  lt_dladdsearchdir (MODULE_PATH);
  if ((modules = getenv ("SMALLTALK_MODULES")))
    lt_dladdsearchdir (modules);

  /* Too hard to support dlpreopen... LTDL_SET_PRELOADED_SYMBOLS(); */

  _gst_define_cfunc ("defineCFunc", _gst_define_cfunc);
  _gst_define_cfunc ("dldLink", _gst_dld_open);
  _gst_define_cfunc ("dldGetFunc", lt_dlsym);
  _gst_define_cfunc ("dldError", lt_dlerror);
}

void
_gst_init_cfuncs (void)
{
  extern char *getenv (const char *);

  /* Access to command line args */
  _gst_define_cfunc ("getArgc", get_argc);
  _gst_define_cfunc ("getArgv", get_argv);

  /* Test functions */
  _gst_define_cfunc ("testCallin", test_callin);
  _gst_define_cfunc ("testCString", test_cstring);
  _gst_define_cfunc ("testCSstringArray", test_cstring_array);

  /* Access to C library */
  _gst_define_cfunc ("system", system);
  _gst_define_cfunc ("getenv", getenv);
  _gst_define_cfunc ("putenv", my_putenv);

  _gst_define_cfunc ("errno", get_errno);
  _gst_define_cfunc ("strerror", strerror);
  _gst_define_cfunc ("stat", my_stat);
#if 0
  _gst_define_cfunc ("lstat", my_lstat);
#endif

  _gst_define_cfunc ("opendir", my_opendir);
  _gst_define_cfunc ("closedir", closedir);
  _gst_define_cfunc ("readdir", readdir);
  _gst_define_cfunc ("rewinddir", rewinddir);
  _gst_define_cfunc ("extractDirentName", extract_dirent_name);

  _gst_define_cfunc ("unlink", unlink);
  _gst_define_cfunc ("rename", rename);
  _gst_define_cfunc ("rmdir", rmdir);
  _gst_define_cfunc ("chdir", my_chdir);
  _gst_define_cfunc ("mkdir", mkdir);
  _gst_define_cfunc ("getCurDirName", _gst_get_cur_dir_name);

  _gst_define_cfunc ("fileIsReadable", _gst_file_is_readable);
  _gst_define_cfunc ("fileIsWriteable", _gst_file_is_writeable);
  _gst_define_cfunc ("fileIsExecutable", _gst_file_is_executable);

  init_dld ();

  /* Non standard routines */
  _gst_define_cfunc ("marli", marli);
}



void
_gst_define_cfunc (const char *funcName,
		   PTR funcAddr)
{
  avl_node_t **p = (avl_node_t **) &c_func_root;
  cfunc_info *node;
  cfunc_info *cfi = NULL;

  while (*p)
    {
      int cmp;
      cfi = (cfunc_info *) *p;

      cmp = strcmp(funcName, cfi->funcName);
      if (cmp < 0)
	p = &(*p)->avl_left;
      else if (cmp > 0)
	p = &(*p)->avl_right;
      else
	{
	  cfi->funcAddr = funcAddr;
	  return;
	}
    }

  node = (cfunc_info *) xmalloc(sizeof(cfunc_info));
  node->avl.avl_parent = (avl_node_t *) cfi;
  node->avl.avl_left = node->avl.avl_right = NULL;
  node->funcName = strdup (funcName);
  node->funcAddr = funcAddr;
  *p = &(node->avl);

  avl_rebalance(&node->avl, (avl_node_t **) &c_func_root);
}



p_void_func
_gst_lookup_function (const char *funcName)
{
  cfunc_info *cfi = c_func_root;

  while (cfi)
    {
      int cmp;

      cmp = strcmp(funcName, cfi->funcName);
      if (cmp == 0)
	return cfi->funcAddr;
      
      cfi = (cfunc_info *) (cmp < 0 ? cfi->avl.avl_left : cfi->avl.avl_right);
    }

  return NULL;
}


OOP
_gst_invoke_croutine (OOP cFuncOOP,
		      OOP receiver,
		      OOP *args)
{
  gst_cfunc_descriptor desc;
  cdata_type cType;
  OOP oop;
  int i, si, fixedArgs;
  string_info stringInfo[ARG_VEC_SIZE], *localSip;
  p_void_func cFunction;
  inc_ptr incPtr;

  incPtr = INC_SAVE_POINTER ();

  desc = (gst_cfunc_descriptor) OOP_TO_OBJ (cFuncOOP);
  cFunction = (p_void_func) COBJECT_VALUE (desc->cFunction);
  if (!cFunction)
    return (NULL);

  c_arg = c_arg_vec;
  string_info_base = stringInfo;
  sip = stringInfo;

  /* from the top, the receiver is pushed */
  /* first before the other arguments */
  fixedArgs = TO_INT (desc->numFixedArgs);

  for (si = i = 0; i < fixedArgs; i++)
    {
      cType = get_ctype (desc, i);
      if (cType >= CDATA_SELF)
	push_smalltalk_obj (receiver,
			    cType == CDATA_SELF ? CDATA_UNKNOWN : CDATA_OOP);
      else if (cType != CDATA_VOID)
	/* Do nothing if it is a void */
	push_smalltalk_obj (args[si++], cType);
    }

  localSip = sip;
  oop = call_cfunction (desc);

  /* Fixup all returned string variables */
  for (; localSip-- != stringInfo;)
    {
      if (localSip->returnedType == CDATA_STRINGOUT)
	_gst_set_oopstring (localSip->stringOOP, localSip->cString);

      else if (localSip->returnedType == CDATA_BYTEARRAYOUT)
	_gst_set_oop_bytes (localSip->stringOOP, localSip->cString);

      xfree (localSip->cString);
    }

  INC_RESTORE_POINTER (incPtr);
  return (oop);
}

cdata_type
get_ctype (gst_cfunc_descriptor desc,
	   int index)
{
  if (index < TO_INT (desc->numFixedArgs))
    return ((cdata_type) TO_INT (desc->argTypes[index]));
  else
    return (CDATA_UNKNOWN);
}

void
push_smalltalk_obj (OOP oop,
		    cdata_type cType)
{
  OOP class;
  int i;
  cparam_union u;

  if (c_arg - c_arg_vec >= ARG_VEC_SIZE)
    {
      _gst_errorf
	("Attempt to push more than %d ints; extra parameters ignored",
	 ARG_VEC_SIZE);
      return;
    }

  class = IS_INT (oop) ? _gst_small_integer_class : OOP_CLASS (oop);

  if (cType == CDATA_OOP)
    {
      u.ptrVal = (PTR) oop;
      INC_ADD_OOP (oop);	/* make sure it doesn't get gc'd */
      push_obj (&u, CPARAM_PTR);
    }
  else if (cType == CDATA_COBJECT_PTR)
    {
      if (is_a_kind_of (class, _gst_c_object_class))
	{
	  u.ptrVal = COBJECT_VALUE (oop);
	  push_obj (&u, CPARAM_PTR);
	}
      else
	_gst_errorf
	  ("Attempted to pass a non-CObject as a cObjectPtr");
    }
  else if (is_a_kind_of (class, _gst_integer_class))
    {
      if (cType == CDATA_LONG || cType == CDATA_ULONG
	  || cType == CDATA_UNKNOWN)
	{
	  u.longVal = TO_C_LONG (oop);
	  push_obj (&u, CPARAM_LONG);
	}
      else if (cType == CDATA_INT || cType == CDATA_UINT
	       || cType == CDATA_CHAR)
	{
	  u.intVal = TO_C_INT (oop);
	  push_obj (&u, CPARAM_INT);
	}
      else if (cType == CDATA_DOUBLE || cType == CDATA_UNKNOWN)
	{
	  u.doubleVal = (double) TO_C_LONG (oop);
	  push_obj (&u, CPARAM_DOUBLE);
	}
      else if (cType == CDATA_FLOAT)
	{
	  u.floatVal = (float) TO_C_LONG (oop);
	  push_obj (&u, CPARAM_FLOAT);
	}
      else
	bad_type (class, cType);
    }
  else if (oop == _gst_true_oop || oop == _gst_false_oop)
    {
      if (cType == CDATA_INT || cType == CDATA_UINT || cType == CDATA_BOOLEAN
	  || cType == CDATA_CHAR || cType == CDATA_UNKNOWN)
	{
	  u.intVal = (oop == _gst_true_oop);
	  push_obj (&u, CPARAM_INT);
	}
      else if (cType == CDATA_LONG || cType == CDATA_ULONG)
	{
	  u.longVal = (oop == _gst_true_oop);
	  push_obj (&u, CPARAM_LONG);
	}
      else
	bad_type (class, cType);
    }
  else if (class == _gst_char_class)
    {
      if (cType == CDATA_CHAR || cType == CDATA_UNKNOWN)
	{
	  u.intVal = CHAR_OOP_VALUE (oop);
	  push_obj (&u, CPARAM_INT);
	}
      else
	bad_type (class, cType);
    }
  else if (class == _gst_string_class)
    {
      if (cType == CDATA_STRING || cType == CDATA_STRINGOUT
	  || cType == CDATA_BYTEARRAY || cType == CDATA_BYTEARRAYOUT
	  || cType == CDATA_UNKNOWN)
	{
	  if (sip - string_info_base >= ARG_VEC_SIZE)
	    {
	      _gst_errorf
		("Too many string arguments, max is %d.  Extras ignored.",
		 ARG_VEC_SIZE);
	      return;
	    }
	  if (cType == CDATA_BYTEARRAY || cType == CDATA_BYTEARRAYOUT)
	    sip->cString = _gst_to_byte_array (oop);
	  else
	    sip->cString = (gst_uchar *) _gst_to_cstring (oop);

	  u.ptrVal = (PTR) sip->cString;
	  sip->stringOOP = oop;
	  sip->returnedType = cType;
	  sip++;
	  push_obj (&u, CPARAM_PTR);
	}
      else
	bad_type (class, cType);
    }
  else if (class == _gst_symbol_class)
    {
      if (cType == CDATA_SYMBOL || cType == CDATA_STRING
	  || cType == CDATA_UNKNOWN)
	{
	  if (sip - string_info_base >= ARG_VEC_SIZE)
	    {
	      _gst_errorf
		("Too many string arguments, max is %d.  Extras ignored.",
		 ARG_VEC_SIZE);
	      return;
	    }
	  sip->cString = (gst_uchar *) _gst_to_cstring (oop);
	  u.ptrVal = (PTR) sip->cString;
	  sip->stringOOP = oop;
	  sip->returnedType = cType;
	  sip++;
	  push_obj (&u, CPARAM_PTR);
	}
      else
	bad_type (class, cType);
    }
  else if (class == _gst_byte_array_class)
    {
      if (cType == CDATA_STRING || cType == CDATA_STRINGOUT
	  || cType == CDATA_BYTEARRAY || cType == CDATA_BYTEARRAYOUT
	  || cType == CDATA_UNKNOWN)
	{
	  if (sip - string_info_base >= ARG_VEC_SIZE)
	    {
	      _gst_errorf
		("Too many string arguments, max is %d.  Extras ignored.",
		 ARG_VEC_SIZE);
	      return;
	    }
	  if (cType == CDATA_STRING || cType == CDATA_STRINGOUT)
	    sip->cString = (gst_uchar *) _gst_to_cstring (oop);
	  else
	    sip->cString = _gst_to_byte_array (oop);

	  u.ptrVal = (PTR) sip->cString;
	  sip->stringOOP = oop;
	  sip->returnedType = cType;
	  sip++;
	  push_obj (&u, CPARAM_PTR);
	}
      else
	bad_type (class, cType);
    }
  else if (is_a_kind_of (class, _gst_float_class))
    {
      if (cType == CDATA_DOUBLE || cType == CDATA_UNKNOWN)
	{
	  u.doubleVal = _gst_oop_to_float (oop);
	  push_obj (&u, CPARAM_DOUBLE);
	}
      else if (cType == CDATA_FLOAT)
	{
	  u.floatVal = (float) _gst_oop_to_float (oop);
	  push_obj (&u, CPARAM_FLOAT);
	}
      else
	bad_type (class, cType);
    }
  else if (class == _gst_c_object_class)
    {
      if (cType == CDATA_COBJECT || cType == CDATA_UNKNOWN)
	{
	  u.ptrVal = COBJECT_VALUE (oop);
	  push_obj (&u, CPARAM_PTR);
	}
      else
	bad_type (class, cType);
    }
  else if ((cType == CDATA_COBJECT || cType == CDATA_UNKNOWN)
	   && is_a_kind_of (class, _gst_c_object_class))
    {
      u.ptrVal = COBJECT_VALUE (oop);
      push_obj (&u, CPARAM_PTR);
    }
  else if (class == _gst_undefined_object_class)
    {				/* how to encode nil */
      switch (cType)
	{
	case CDATA_COBJECT:
	case CDATA_BYTEARRAY:
	case CDATA_BYTEARRAYOUT:
	case CDATA_STRING:
	case CDATA_STRINGOUT:
	case CDATA_SYMBOL:
	case CDATA_UNKNOWN:
	  u.ptrVal = NULL;
	  push_obj (&u, CPARAM_PTR);
	  break;

	default:
	  bad_type (class, cType);
	}
    }
  else if (cType == CDATA_UNKNOWN)
    {
      u.ptrVal = (PTR) oop;
      INC_ADD_OOP (oop);	/* make sure it doesn't get gc'd */
      push_obj (&u, CPARAM_PTR);
    }
  else if (class == _gst_array_class)
    {
      if (cType == CDATA_VARIADIC)
	{
	  for (i = 1; i <= NUM_WORDS (OOP_TO_OBJ (oop)); i++)
	    push_smalltalk_obj (ARRAY_AT (oop, i), CDATA_UNKNOWN);
	}
      else if (cType == CDATA_VARIADIC_OOP)
	{
	  for (i = 1; i <= NUM_WORDS (OOP_TO_OBJ (oop)); i++)
	    push_smalltalk_obj (ARRAY_AT (oop, i), CDATA_OOP);
	}
      else
	bad_type (class, cType);
    }
  else
    bad_type (class, cType);
}

void
push_obj (cparam_union * up,
	  cparam_type typ)
{
  unsigned i;
  int alignInts;

  alignInts = alignments[typ] / sizeof (int);

  /* Align the stack properly */
  if ((c_arg - c_arg_vec) % alignInts)
    c_arg += alignInts - ((c_arg - c_arg_vec) % alignInts);

  for (i = 0; i < type_sizes[typ] / sizeof (int); i++)
    {
      if (c_arg - c_arg_vec >= ARG_VEC_SIZE)
	{
	  _gst_errorf
	    ("Too many parameters, max = %d.  Extra parameters ignored",
	     ARG_VEC_SIZE);
	  return;
	}
      *c_arg++ = up->valueVec[i];
    }
}

OOP
call_cfunction (gst_cfunc_descriptor desc)
{
  int intResult;
  unsigned int uIntResult;
  PTR ptrResult;
  long longResult;
  unsigned long uLongResult;
  double doubleResult;
  p_void_func cFunction;
  cdata_type returnType;
  OOP returnTypeOOP, resultOOP;

  errno = 0;
  cFunction = (p_void_func) COBJECT_VALUE (desc->cFunction);

#define DO_THE_CALL(type)						  \
	(* (type (*)()) cFunction)(					  \
	      c_arg_vec[0],  c_arg_vec[1],  c_arg_vec[2],  c_arg_vec[3],  \
	      c_arg_vec[4],  c_arg_vec[5],  c_arg_vec[6],  c_arg_vec[7],  \
	      c_arg_vec[8],  c_arg_vec[9],  c_arg_vec[10], c_arg_vec[11], \
	      c_arg_vec[12], c_arg_vec[13], c_arg_vec[14], c_arg_vec[15], \
	      c_arg_vec[16], c_arg_vec[17], c_arg_vec[18], c_arg_vec[19]);

  if (IS_INT (desc->returnType))
    {
      returnType = (cdata_type) TO_INT (desc->returnType);
      returnTypeOOP = NULL;
    }
  else
    {
      returnTypeOOP = desc->returnType;
      returnType = CDATA_COBJECT;
    }

  switch (returnType)
    {
    case CDATA_VOID:
      DO_THE_CALL (void);
      resultOOP = _gst_nil_oop;
      break;

    case CDATA_CHAR:
      intResult = DO_THE_CALL (int);
      resultOOP = CHAR_OOP_AT ((gst_uchar) intResult);
      break;

    case CDATA_BOOLEAN:
      intResult = DO_THE_CALL (int);
      resultOOP = intResult ? _gst_true_oop : _gst_false_oop;
      break;

    case CDATA_INT:
      intResult = DO_THE_CALL (int);
      resultOOP = FROM_INT ((long) intResult);
      break;

    case CDATA_UINT:
      uIntResult = DO_THE_CALL (unsigned int);
      resultOOP = FROM_INT ((long) uIntResult);
      break;

    case CDATA_LONG:
      longResult = DO_THE_CALL (long);
      resultOOP = FROM_C_LONG (longResult);
      break;

    case CDATA_ULONG:
      uLongResult = DO_THE_CALL (unsigned long);
      resultOOP = FROM_C_ULONG (uLongResult);
      break;

    case CDATA_STRING:
    case CDATA_STRINGOUT:
    case CDATA_SYMBOL:
    case CDATA_COBJECT:
    case CDATA_OOP:
      ptrResult = DO_THE_CALL (PTR);
      if (!ptrResult)
	{
	  resultOOP = _gst_nil_oop;
	  break;
	}
      if (returnType == CDATA_SYMBOL)
	{
	  resultOOP = _gst_intern_string ((char *) ptrResult);
	  break;
	}
      if (returnType == CDATA_COBJECT)
	{
	  if (returnTypeOOP)
	    resultOOP = _gst_c_object_new_typed (ptrResult, returnTypeOOP);
	  else
	    resultOOP = COBJECT_NEW (ptrResult);
	  break;
	}
      if (returnType == CDATA_OOP)
	{
	  resultOOP = (OOP) ptrResult;
	  break;
	}
      resultOOP = _gst_string_new ((char *) ptrResult);
      if (returnType == CDATA_STRINGOUT)
	xfree (ptrResult);
      break;

    case CDATA_DOUBLE:
      doubleResult = DO_THE_CALL (double);
      resultOOP = floatd_new (doubleResult);
      break;

    case CDATA_FLOAT:
      doubleResult = (double) DO_THE_CALL (float);
      resultOOP = floate_new (doubleResult);
      break;

    default:
      _gst_errorf
	("Invalid C function return type specified, index %d\n",
	 returnType);

      resultOOP = _gst_nil_oop;
      break;
    }

  _gst_set_errno (errno);
  return resultOOP;
}

void
bad_type (OOP class_oop,
	  cdata_type cType)
{
  char smalltalkTypeName[256], *className;
  gst_class classObject;

  if (IS_A_METACLASS (class_oop))
    {
      class_oop = _gst_find_an_instance (class_oop);
      classObject = (gst_class) OOP_TO_OBJ (class_oop);
      if (IS_NIL (class_oop))
	strcpy (smalltalkTypeName, "an unnamed class object");	/* we're 
								   a
								   nameless 
								   class 
								 */
      else
	{
	  className = _gst_to_cstring (classObject->name);
	  sprintf (smalltalkTypeName, "the %s class object", className);
	  xfree (className);
	}
    }
  else
    {
      classObject = (gst_class) OOP_TO_OBJ (class_oop);
      className = _gst_to_cstring (classObject->name);
      sprintf (smalltalkTypeName, "an instance of %s", className);
      xfree (className);
    }

  _gst_errorf ("Attempt to pass %s as a %s", smalltalkTypeName,
	       c_type_name[cType]);
  _gst_show_backtrace ();
}



OOP
_gst_make_descriptor (OOP funcNameOOP,
		      OOP returnTypeOOP,
		      OOP argsOOP)
{
  char *funcName;
  p_void_func funcAddr;
  int numArgs, i;
  gst_cfunc_descriptor desc;
  inc_ptr incPtr;
  OOP cFunction, cFunctionName, descOOP;

  funcName = (char *) _gst_to_cstring (funcNameOOP);
  funcAddr = _gst_lookup_function (funcName);

  if (argsOOP == _gst_nil_oop)
    numArgs = 0;
  else
    numArgs = NUM_OOPS (OOP_TO_OBJ (argsOOP));

  /* since these are all either ints or new objects, I'm not moving the
     OOPs */
  incPtr = INC_SAVE_POINTER ();

  cFunction = COBJECT_NEW (funcAddr);
  INC_ADD_OOP (cFunction);

  cFunctionName = _gst_string_new (funcName);
  INC_ADD_OOP (cFunctionName);

  desc = (gst_cfunc_descriptor)
    new_instance_with (_gst_c_func_descriptor_class, numArgs,
		       &descOOP);

  desc->cFunction = cFunction;
  desc->cFunctionName = cFunctionName;
  desc->numFixedArgs = FROM_INT (numArgs);
  desc->returnType = classify_type_symbol (returnTypeOOP, true);
  for (i = 1; i <= numArgs; i++)
    desc->argTypes[i - 1] =
      classify_type_symbol (ARRAY_AT (argsOOP, i), false);

  xfree (funcName);
  INC_RESTORE_POINTER (incPtr);
  return (descOOP);
}

OOP
classify_type_symbol (OOP symbolOOP,
		      mst_Boolean isReturn)
{
  const symbol_type_map *sp;
  char *symbolName;

  for (sp = type_map; sp->symbol != NULL; sp++)
    {
      if (*sp->symbol == symbolOOP)
	return (FROM_INT (sp->type));
    }

  if (isReturn)
    {
      if (is_a_kind_of (OOP_CLASS (symbolOOP), _gst_c_type_class))
	return (symbolOOP);	/* this is the type we want! */
    }

  symbolName = _gst_to_cstring (symbolOOP);	/* yeah, yeah...but
						   they have the same
						   representation! */
  _gst_errorf ("Unknown data type symbol: %s", symbolName);

  xfree (symbolName);

  return (FROM_INT (CDATA_UNKNOWN));
}

void
_gst_set_errno(int errnum)
{
  /* ENOTEMPTY and EEXIST are synonymous; some systems use one, and
     some use the other. We always uses EEXIST which is provided by all 
     systems. */

#ifdef ENOTEMPTY
  _gst_errno = (errnum == ENOTEMPTY) ? EEXIST : errnum;
#else
  _gst_errno = errnum;
#endif
}

void
_gst_restore_cfunc_descriptor (OOP cFuncDescOOP)
{
  gst_cfunc_descriptor desc;
  p_void_func funcAddr;
  char *funcName;

  desc = (gst_cfunc_descriptor) OOP_TO_OBJ (cFuncDescOOP);
  funcName = (char *) _gst_to_cstring (desc->cFunctionName);
  funcAddr = _gst_lookup_function (funcName);
  xfree (funcName);
  SET_COBJECT_VALUE (desc->cFunction, funcAddr);
}
