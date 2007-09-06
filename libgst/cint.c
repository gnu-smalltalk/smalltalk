/******************************** -*- C -*- ****************************
 *
 *	C - Smalltalk Interface module
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,2005,2006,2007
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
 * Linking GNU Smalltalk statically or dynamically with other modules is
 * making a combined work based on GNU Smalltalk.  Thus, the terms and
 * conditions of the GNU General Public License cover the whole
 * combination.
 *
 * In addition, as a special exception, the Free Software Foundation
 * give you permission to combine GNU Smalltalk with free software
 * programs or libraries that are released under the GNU LGPL and with
 * independent programs running under the GNU Smalltalk virtual machine.
 *
 * You may copy and distribute such a system following the terms of the
 * GNU GPL for GNU Smalltalk and the licenses of the other code
 * concerned, provided that you include the source code of that other
 * code when and as the GNU GPL requires distribution of source code.
 *
 * Note that people who make modified versions of GNU Smalltalk are not
 * obligated to grant this special exception for their modified
 * versions; it is their choice whether to do so.  The GNU General
 * Public License gives permission to release a modified version without
 * this exception; this exception also makes it possible to release a
 * modified version which carries forward this exception.
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
#include "re.h"

#include "../libffi/include/ffi.h"
#include <ltdl.h>

typedef enum
{				/* types for C parameters */
  CDATA_UNKNOWN,		/* when there is no type a priori */
  CDATA_CHAR,
  CDATA_STRING,
  CDATA_STRING_OUT,		/* for things that modify string params */
  CDATA_SYMBOL,
  CDATA_BYTEARRAY,
  CDATA_BYTEARRAY_OUT,
  CDATA_BOOLEAN,
  CDATA_INT,
  CDATA_UINT,
  CDATA_LONG,
  CDATA_ULONG,
  CDATA_FLOAT,
  CDATA_DOUBLE,
  CDATA_LONG_DOUBLE,
  CDATA_VOID,			/* valid only as a return type */
  CDATA_VARIADIC,		/* for parameters, this param is an
				   array to be interpreted as
				   arguments.  Note that only simple
				   conversions are performed in this
				   case.  */
  CDATA_VARIADIC_OOP,		/* for parameters, this param is an
				   array whose elements are OOPs to be
				   passed.  */
  CDATA_COBJECT,		/* a C object is being passed */
  CDATA_COBJECT_PTR,		/* a C object pointer is being passed */
  CDATA_OOP,			/* no conversion to-from C (OOP) */
  CDATA_SELF,			/* pass self as the corresponding
				   argument */
  CDATA_SELF_OOP,		/* pass self as an OOP */
  CDATA_WCHAR,
  CDATA_WSTRING,
  CDATA_WSTRING_OUT,
  CDATA_SYMBOL_OUT
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
				   calling the C function).  */
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

typedef struct cparam
{
  union {
    int intVal;
    long longVal;
    PTR ptrVal;
    float floatVal;
    double doubleVal;
    long double longDoubleVal;
    struct {
      PTR pPtrVal;
      PTR ptrVal;
    } cObjectPtrVal;
  } u;
  OOP oop;
  cdata_type cType;
}
cparam;

/* Holds onto the pointer to a C function and caches data about its calling
   interface.  Used in _gst_invoke_croutine and push_smalltalk_obj.  */

typedef struct cfunc_info
{
  avl_node_t avl;
  const char *funcName;
  p_void_func funcAddr;

  OOP cacheCFuncDesc;		/* used to test cache validity */
  int cacheVariadic;		/* Is the function called with variadic parms? */
  int needPostprocessing;	/* Is the function called with string/bytearray parms? */
  ffi_cif cacheCif;		/* cached ffi_cif representation */

  int types_size;
  int arg_idx;
  cparam *args;
  ffi_type **types;
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

/* Prints an error message... this should really make the primitive
   fail so that a WrongClass exception is generated (FIXME) */
static void bad_type (OOP class_oop,
		      cdata_type cType);

/* Determines the appropriate C mapping for OOP and stores it.  */
static void push_smalltalk_obj (OOP oop,
				cdata_type cType);

/* Returns a descriptor for the latest C function which has been
   registered using _gst_define_cfunc with the name FUNCNAME.  Returns
   NULL if there is no such function.  */
extern cfunc_info *lookup_function (const char *funcName);

/* Converts the return type as stored in RESULT to an OOP, based
   on the RETURNTYPEOOP that is stored in the descriptor.  */
static OOP c_to_smalltalk (cparam *result, OOP returnTypeOOP);

/* Converts the return type CTYPE, stored in a descriptor to a
   libffi type.  */
static ffi_type *get_ffi_type (OOP returnTypeOOP);

/* Initializes libltdl and defines the functions to access it.  */
static void init_dld (void);

/* Wrapper around lt_dlopenext that invokes gst_initModule if it is found
   in the library.  */
PTR dld_open (const char *filename);

/* Callout to tests callins.  */
static void test_callin (OOP oop);

/* Callout to test the CString class */
static void test_cstring (char **string);

/* Callout to test #cObjectPtr parameters */
static void test_cobject_ptr (const void **string);

/* Converts a Symbol to a SmallInteger so that it is stored in the
   CFunctionDescriptor.  For the return type isReturn is passed as
   true and a CType is alwso considered valid.  */
static OOP classify_type_symbol (OOP symbolOOP,
				 mst_Boolean isReturn);

/* Return the errno on output from the last callout.  */
static int get_errno (void);

/* Encapsulate binary incompatibilities between various C libraries.  */
static int my_utime (const char *name,
		     long new_atime,
		     long new_mtime);
static int my_stat (const char *name,
		    gst_stat * out);
static int my_lstat (const char *name,
		     gst_stat * out);
static int my_putenv (const char *str);
static int my_chdir (const char *str);
static DIR *my_opendir (const char *str);
static char *extract_dirent_name (struct dirent *dir);

/* Provide access to the arguments passed via -a.  */
static int get_argc (void);
static const char *get_argv (int n);

/* The binary tree of function names vs. function addresses.  */
static cfunc_info *c_func_root = NULL;

/* The cfunc_info that's being called.  */
static cfunc_info *c_func_cur = NULL;

/* printable names for corresponding C types */
static const char *c_type_name[] = {
  "void?",			/* CDATA_UNKNOWN */
  "char",			/* CDATA_CHAR */
  "char *",			/* CDATA_STRING */
  "char *",			/* CDATA_STRING_OUT */
  "char *",			/* CDATA_SYMBOL */
  "char *",			/* CDATA_BYTEARRAY */
  "char *",			/* CDATA_BYTEARRAY_OUT */
  "int",			/* CDATA_BOOLEAN */
  "int",			/* CDATA_INT */
  "unsigned int",		/* CDATA_UINT */
  "long",			/* CDATA_LONG */
  "unsigned long",		/* CDATA_ULONG */
  "float",			/* CDATA_FLOAT */
  "double",			/* CDATA_DOUBLE */
  "long double",		/* CDATA_LONG_DOUBLE */
  "void?",			/* CDATA_VOID */
  "...",			/* CDATA_VARIADIC */
  "...",			/* CDATA_VARIADIC_OOP */
  "void *",			/* CDATA_COBJECT -- this is misleading */
  "void **",			/* CDATA_COBJECT_PTR */
  "OOP",			/* CDATA_OOP */
  "void?",			/* CDATA_SELF */
  "OOP",			/* CDATA_SELF_OOP */
  "wchar_t",			/* CDATA_WCHAR */
  "wchar_t *",			/* CDATA_WSTRING */
  "wchar_t *",			/* CDATA_WSTRING_OUT */
};

/* A map between symbols and the cdata_type enum.  */
static const symbol_type_map type_map[] = {
  {&_gst_unknown_symbol, CDATA_UNKNOWN},
  {&_gst_char_symbol, CDATA_CHAR},
  {&_gst_string_symbol, CDATA_STRING},
  {&_gst_string_out_symbol, CDATA_STRING_OUT},
  {&_gst_symbol_symbol, CDATA_SYMBOL},
  {&_gst_symbol_out_symbol, CDATA_SYMBOL_OUT},
  {&_gst_byte_array_symbol, CDATA_BYTEARRAY},
  {&_gst_byte_array_out_symbol, CDATA_BYTEARRAY_OUT},
  {&_gst_boolean_symbol, CDATA_BOOLEAN},
  {&_gst_int_symbol, CDATA_INT},
  {&_gst_uint_symbol, CDATA_UINT},
  {&_gst_long_symbol, CDATA_LONG},
  {&_gst_ulong_symbol, CDATA_ULONG},
  {&_gst_float_symbol, CDATA_FLOAT},
  {&_gst_double_symbol, CDATA_DOUBLE},
  {&_gst_long_double_symbol, CDATA_LONG_DOUBLE},
  {&_gst_void_symbol, CDATA_VOID},
  {&_gst_variadic_symbol, CDATA_VARIADIC},
  {&_gst_variadic_smalltalk_symbol, CDATA_VARIADIC_OOP},
  {&_gst_c_object_symbol, CDATA_COBJECT},
  {&_gst_c_object_ptr_symbol, CDATA_COBJECT_PTR},
  {&_gst_smalltalk_symbol, CDATA_OOP},
  {&_gst_self_symbol, CDATA_SELF},
  {&_gst_self_smalltalk_symbol, CDATA_SELF_OOP},
  {&_gst_wchar_symbol, CDATA_WCHAR},
  {&_gst_wstring_symbol, CDATA_WSTRING},
  {&_gst_wstring_out_symbol, CDATA_WSTRING_OUT},
  {NULL, CDATA_UNKNOWN}
};

/* The errno on output from a callout */
int _gst_errno = 0;




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
  static struct stat statOut;

  result = stat (name, &statOut);
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

#ifdef HAVE_LSTAT
int
my_lstat (const char *name,
	 gst_stat * out)
{
  int result;
  static struct stat statOut;

  result = lstat (name, &statOut);
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
#else
#define my_lstat my_stat
#endif

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
  _gst_str_msg_send (oop, "printNl", NULL);

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
test_cobject_ptr (const void **string)
{
  *string = "this is a test";
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

const char *
get_argv (int n)
{
  return (n <= _gst_smalltalk_passed_argc
	  ? _gst_smalltalk_passed_argv[n - 1]
	  : NULL);
}

PTR
dld_open (const char *filename)
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
  _gst_define_cfunc ("dldLink", dld_open);
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
  _gst_define_cfunc ("testCObjectPtr", test_cobject_ptr);

  /* Access to C library */
  _gst_define_cfunc ("system", system);
  _gst_define_cfunc ("getenv", getenv);
  _gst_define_cfunc ("putenv", my_putenv);

  _gst_define_cfunc ("errno", get_errno);
  _gst_define_cfunc ("strerror", strerror);
  _gst_define_cfunc ("stat", my_stat);
  _gst_define_cfunc ("lstat", my_lstat);
  _gst_define_cfunc ("utime", _gst_set_file_access_times);

  _gst_define_cfunc ("opendir", my_opendir);
  _gst_define_cfunc ("closedir", closedir);
  _gst_define_cfunc ("readdir", readdir);
  _gst_define_cfunc ("rewinddir", rewinddir);
  _gst_define_cfunc ("extractDirentName", extract_dirent_name);

  _gst_define_cfunc ("symlink", symlink);
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

  /* regex routines */
  _gst_define_cfunc ("reh_search", _gst_re_search);
  _gst_define_cfunc ("reh_match", _gst_re_match);
  _gst_define_cfunc ("reh_make_cacheable", _gst_re_make_cacheable);

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

  node = (cfunc_info *) xcalloc(sizeof(cfunc_info), 1);
  node->avl.avl_parent = (avl_node_t *) cfi;
  node->avl.avl_left = node->avl.avl_right = NULL;
  node->funcName = strdup (funcName);
  node->funcAddr = funcAddr;
  *p = &(node->avl);

  avl_rebalance(&node->avl, (avl_node_t **) &c_func_root);
}



cfunc_info *
lookup_function (const char *funcName)
{
  cfunc_info *cfi = c_func_root;

  while (cfi)
    {
      int cmp;

      cmp = strcmp(funcName, cfi->funcName);
      if (cmp == 0)
	return cfi;
      
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
  cparam result, *local_arg_vec, *arg;
  void **ffi_arg_vec;
  OOP oop;
  int i, si, fixedArgs, totalArgs;
  inc_ptr incPtr;

  incPtr = INC_SAVE_POINTER ();

  desc = (gst_cfunc_descriptor) OOP_TO_OBJ (cFuncOOP);
  c_func_cur = (cfunc_info *) COBJECT_VALUE (desc->cFunction);
  if (!c_func_cur)
    return (NULL);

  fixedArgs = TO_INT (desc->numFixedArgs);
  totalArgs = 0;
  for (si = i = 0; i < fixedArgs; i++)
    {
      cType = TO_INT (desc->argTypes[i]);
      if (cType == CDATA_VARIADIC || cType == CDATA_VARIADIC_OOP)
	{
	  oop = args[si++];
	  totalArgs += NUM_WORDS (OOP_TO_OBJ (oop));
	}
      else if (cType == CDATA_SELF || cType == CDATA_SELF_OOP)
	totalArgs++;
      else if (cType != CDATA_VOID)
	totalArgs++, si++;
    }

  ffi_arg_vec = (void **) alloca (totalArgs * sizeof (void *));
  c_func_cur->args = local_arg_vec = (cparam *)
    alloca (totalArgs * sizeof (cparam));

  /* The ffi_cif holds a pointer to this, so we must malloc it.  */
  if (c_func_cur->types_size < totalArgs)
    {
      c_func_cur->types = (ffi_type **) realloc (c_func_cur->types,
					         totalArgs * sizeof (ffi_type *));
      c_func_cur->types_size = totalArgs;
    }

  c_func_cur->arg_idx = 0;
  c_func_cur->cacheVariadic = false;

  for (i = 0; i < totalArgs; i++)
    ffi_arg_vec[i] = &local_arg_vec[i].u;

  /* Push the arguments */
  for (si = i = 0; i < fixedArgs; i++)
    {
      cType = TO_INT (desc->argTypes[i]);
      if (cType == CDATA_SELF || cType == CDATA_SELF_OOP)
	push_smalltalk_obj (receiver,
			    cType == CDATA_SELF ? CDATA_UNKNOWN : CDATA_OOP);
      else if (cType != CDATA_VOID)
	/* Do nothing if it is a void */
	push_smalltalk_obj (args[si++], cType);
    }

  /* If the previous call was done through the same function descriptor,
     the ffi_cif is already ok.  */
  if (c_func_cur->cacheCFuncDesc != cFuncOOP)
    {
      ffi_prep_cif (&c_func_cur->cacheCif, FFI_DEFAULT_ABI, totalArgs,
                    get_ffi_type (desc->returnType),
		    c_func_cur->types);

      /* For variadic functions, we cannot cache the ffi_cif because
	 the argument types change every time.  */
      if (!c_func_cur->cacheVariadic)
        c_func_cur->cacheCFuncDesc = cFuncOOP;
    }

  errno = 0;
  ffi_call (&c_func_cur->cacheCif, FFI_FN (c_func_cur->funcAddr),
	    &result.u, ffi_arg_vec);

  _gst_set_errno (errno);
  oop = c_to_smalltalk (&result, desc->returnType);

  /* Fixup all returned string variables */
  if (c_func_cur->needPostprocessing)
    for (i = 0, arg = local_arg_vec; i < totalArgs; i++, arg++)
      {
        if (!arg->oop)
	  continue;

        switch (arg->cType)
          {
          case CDATA_COBJECT_PTR:
	    SET_COBJECT_VALUE (arg->oop, arg->u.cObjectPtrVal.ptrVal);
	    continue;

          case CDATA_WSTRING_OUT:
	    _gst_set_oop_unicode_string (arg->oop, arg->u.ptrVal);
	    break;

          case CDATA_STRING_OUT:
	    _gst_set_oopstring (arg->oop, arg->u.ptrVal);
	    break;

          case CDATA_BYTEARRAY_OUT:
	    _gst_set_oop_bytes (arg->oop, arg->u.ptrVal);
	    break;

          default:
	    break;
          }

        xfree (arg->u.ptrVal);
      }

  INC_RESTORE_POINTER (incPtr);
  return (oop);
}

ffi_type *
get_ffi_type (OOP returnTypeOOP)
{
  if (!IS_INT (returnTypeOOP))
    return &ffi_type_pointer;

  switch (TO_INT (returnTypeOOP))
    {
    case CDATA_OOP:
    case CDATA_COBJECT:
    case CDATA_COBJECT_PTR:
    case CDATA_SYMBOL:
    case CDATA_SYMBOL_OUT:
    case CDATA_WSTRING:
    case CDATA_WSTRING_OUT:
    case CDATA_STRING:
    case CDATA_STRING_OUT:
    case CDATA_BYTEARRAY:
    case CDATA_BYTEARRAY_OUT:
    default:
      return &ffi_type_pointer;

    case CDATA_LONG:
    case CDATA_ULONG:
#if LONG_MAX == 2147483647
      return &ffi_type_sint32;
#else
      return &ffi_type_sint64;
#endif

    case CDATA_VOID:
    case CDATA_INT:
    case CDATA_UINT:
    case CDATA_CHAR:
    case CDATA_WCHAR:
    case CDATA_BOOLEAN:
      return &ffi_type_sint;

   case CDATA_FLOAT:
     return &ffi_type_float;

   case CDATA_DOUBLE:
     return &ffi_type_double;

   case CDATA_LONG_DOUBLE:
     return &ffi_type_longdouble;

   case CDATA_VARIADIC:
   case CDATA_VARIADIC_OOP:
   case CDATA_SELF:
   case CDATA_SELF_OOP:
   case CDATA_UNKNOWN:
     /* TODO: less brutal */
     abort ();
   }
}

#define SET_TYPE(t)  c_func_cur->types[c_func_cur->arg_idx++] = (t);

void
push_smalltalk_obj (OOP oop,
		    cdata_type cType)
{
  OOP class;
  int i;
  cparam *cp = &c_func_cur->args[c_func_cur->arg_idx];

  class = OOP_INT_CLASS (oop);

  switch (cType)
    {
    case CDATA_UNKNOWN:
      cType =
	(oop == _gst_true_oop || oop == _gst_false_oop) ? CDATA_BOOLEAN :
	oop == _gst_nil_oop ? CDATA_COBJECT :
	class == _gst_char_class ? CDATA_CHAR :
	class == _gst_unicode_character_class ? CDATA_WCHAR :
	class == _gst_byte_array_class ? CDATA_BYTEARRAY : 
	is_a_kind_of (class, _gst_integer_class) ? CDATA_LONG :
	is_a_kind_of (class, _gst_string_class) ? CDATA_STRING :
	is_a_kind_of (class, _gst_unicode_string_class) ? CDATA_WSTRING :
	is_a_kind_of (class, _gst_c_object_class) ? CDATA_COBJECT :
	is_a_kind_of (class, _gst_float_class) ? CDATA_DOUBLE :
	CDATA_OOP;
      break;

    case CDATA_VARIADIC:
      if (class == _gst_array_class)
	{
	  c_func_cur->cacheVariadic = true;
	  for (i = 1; i <= NUM_WORDS (OOP_TO_OBJ (oop)); i++)
	    push_smalltalk_obj (ARRAY_AT (oop, i), CDATA_UNKNOWN);
	}
      else
        bad_type (class, cType);

      return;

    case CDATA_VARIADIC_OOP:
      if (class == _gst_array_class)
	{
	  c_func_cur->cacheVariadic = true;
	  for (i = 1; i <= NUM_WORDS (OOP_TO_OBJ (oop)); i++)
	    push_smalltalk_obj (ARRAY_AT (oop, i), CDATA_OOP);
	}
      else
        bad_type (class, cType);

      return;
    }

  cp->oop = NULL;
  cp->cType = cType;

  if (cType == CDATA_OOP)
    {
      cp->u.ptrVal = (PTR) oop;
      INC_ADD_OOP (oop);	/* make sure it doesn't get gc'd */
      SET_TYPE (&ffi_type_pointer);
      return;
    }

  else if (is_a_kind_of (class, _gst_integer_class))
    {
      switch (cType)
        {
        case CDATA_LONG:
	case CDATA_ULONG:
	  cp->u.longVal = TO_C_LONG (oop);
#if LONG_MAX == 2147483647
          SET_TYPE (&ffi_type_sint32);
#else
          SET_TYPE (&ffi_type_sint64);
#endif
	  return;

        case CDATA_INT:
	case CDATA_UINT:
	case CDATA_CHAR:
	  cp->u.intVal = TO_C_INT (oop);
	  SET_TYPE (&ffi_type_sint);
	  return;

	case CDATA_DOUBLE:
          cp->u.doubleVal = (double) TO_C_LONG (oop);
	  SET_TYPE (&ffi_type_double);
	  return;

	case CDATA_FLOAT:
          cp->u.floatVal = (float) TO_C_LONG (oop);
	  SET_TYPE (&ffi_type_float);
	  return;
	}
    }

  else if (oop == _gst_true_oop || oop == _gst_false_oop)
    {
      switch (cType)
        {
        case CDATA_LONG:
	case CDATA_ULONG:
	  cp->u.longVal = (oop == _gst_true_oop);
#if LONG_MAX == 2147483647
          SET_TYPE (&ffi_type_sint32);
#else
          SET_TYPE (&ffi_type_sint64);
#endif
	  return;

        case CDATA_INT:
	case CDATA_UINT:
	case CDATA_CHAR:
	case CDATA_BOOLEAN:
	  cp->u.intVal = (oop == _gst_true_oop);
	  SET_TYPE (&ffi_type_sint);
	  return;
	}
    }

  else if ((class == _gst_char_class
	    && (cType == CDATA_CHAR || cType == CDATA_WCHAR))
           || (class == _gst_unicode_character_class && cType == CDATA_WCHAR))
    {
      cp->u.intVal = CHAR_OOP_VALUE (oop);
      SET_TYPE (&ffi_type_sint);
      return;
    }

  else if (((class == _gst_string_class || class == _gst_byte_array_class)
            && (cType == CDATA_STRING || cType == CDATA_STRING_OUT
	        || cType == CDATA_BYTEARRAY || cType == CDATA_BYTEARRAY_OUT))
           || (class == _gst_symbol_class
               && (cType == CDATA_SYMBOL || cType == CDATA_STRING)))
    {
      cp->oop = oop;

      if (cp->cType == CDATA_BYTEARRAY || cp->cType == CDATA_BYTEARRAY_OUT)
	cp->u.ptrVal = _gst_to_byte_array (oop);
      else
        cp->u.ptrVal = (gst_uchar *) _gst_to_cstring (oop);

      c_func_cur->needPostprocessing = true;
      SET_TYPE (&ffi_type_pointer);
      return;
    }

  else if (class == _gst_unicode_string_class
           && (cType == CDATA_WSTRING || cType == CDATA_WSTRING_OUT))
    {
      cp->oop = oop;
      cp->u.ptrVal = (gst_uchar *) _gst_to_wide_cstring (oop);

      c_func_cur->needPostprocessing = true;
      SET_TYPE (&ffi_type_pointer);
      return;
    }

  else if (is_a_kind_of (class, _gst_float_class))
    {
      switch (cType)
	{
	case CDATA_LONG_DOUBLE:
	  cp->u.longDoubleVal = _gst_oop_to_float (oop);
	  SET_TYPE (&ffi_type_longdouble);
	  return;

	case CDATA_DOUBLE:
	  cp->u.doubleVal = _gst_oop_to_float (oop);
	  SET_TYPE (&ffi_type_double);
	  return;

	case CDATA_FLOAT:
	  cp->u.floatVal = (float) _gst_oop_to_float (oop);
	  SET_TYPE (&ffi_type_float);
	  return;
	}
    }

  else if (is_a_kind_of (class, _gst_c_object_class))
    {
      switch (cType)
	{
	case CDATA_COBJECT_PTR:
          c_func_cur->needPostprocessing = true;

	  /* Set up an indirect pointer to protect against the OOP
	     moving during the call-out.  */
	  cp->u.cObjectPtrVal.pPtrVal = &cp->u.cObjectPtrVal.ptrVal;
	  cp->u.cObjectPtrVal.ptrVal = COBJECT_VALUE (oop);
	  cp->oop = oop;
	  SET_TYPE (&ffi_type_pointer);
	  return;

	case CDATA_COBJECT:
	  cp->u.ptrVal = COBJECT_VALUE (oop);
	  SET_TYPE (&ffi_type_pointer);
	  return;
	}
    }

  else if (class == _gst_undefined_object_class)
    {				/* how to encode nil */
      switch (cType)
	{
	case CDATA_COBJECT:
	case CDATA_BYTEARRAY:
	case CDATA_BYTEARRAY_OUT:
	case CDATA_STRING:
	case CDATA_STRING_OUT:
	case CDATA_SYMBOL:
	  cp->u.ptrVal = NULL;
	  SET_TYPE (&ffi_type_pointer);
	  return;
	}
    }


  bad_type (class, cType);
}

OOP
c_to_smalltalk (cparam *result, OOP returnTypeOOP)
{
  cdata_type returnType;
  OOP resultOOP;

  if (IS_INT (returnTypeOOP))
    returnType = (cdata_type) TO_INT (returnTypeOOP);
  else
    returnType = CDATA_COBJECT;

  switch (returnType)
    {
    case CDATA_VOID:
      resultOOP = _gst_nil_oop;
      break;

    case CDATA_CHAR:
      resultOOP = CHAR_OOP_AT ((gst_uchar) result->u.intVal);
      break;

    case CDATA_WCHAR:
      resultOOP = char_new ((wchar_t) result->u.intVal);
      break;

    case CDATA_BOOLEAN:
      resultOOP = result->u.intVal ? _gst_true_oop : _gst_false_oop;
      break;

    case CDATA_INT:
      resultOOP = FROM_C_INT ((long) result->u.intVal);
      break;

    case CDATA_UINT:
      resultOOP = FROM_C_INT ((long) result->u.intVal);
      break;

    case CDATA_LONG:
      resultOOP = FROM_C_LONG (result->u.longVal);
      break;

    case CDATA_ULONG:
      resultOOP = FROM_C_ULONG (result->u.longVal);
      break;

    case CDATA_STRING:
    case CDATA_STRING_OUT:
    case CDATA_WSTRING:
    case CDATA_WSTRING_OUT:
    case CDATA_SYMBOL:
    case CDATA_SYMBOL_OUT:
    case CDATA_COBJECT:
    case CDATA_OOP:
      if (!result->u.ptrVal)
	resultOOP = _gst_nil_oop;
      else if (returnType == CDATA_OOP)
	resultOOP = (OOP) result->u.ptrVal;

      else if (returnType == CDATA_SYMBOL || returnType == CDATA_SYMBOL_OUT)
	{
	  resultOOP = _gst_intern_string ((char *) result->u.ptrVal);
	  if (returnType == CDATA_SYMBOL_OUT)
	    xfree (result->u.ptrVal);
	}
      else if (returnType == CDATA_COBJECT)
	{
	  if (IS_INT (returnTypeOOP))
	    resultOOP = COBJECT_NEW (result->u.ptrVal);
	  else
	    resultOOP = _gst_c_object_new_typed (result->u.ptrVal, returnTypeOOP);
	}
      else if (returnType == CDATA_STRING || returnType == CDATA_STRING_OUT)
	{
	  resultOOP = _gst_string_new ((char *) result->u.ptrVal);
	  if (returnType == CDATA_STRING_OUT)
	    xfree (result->u.ptrVal);
	}
      else if (returnType == CDATA_WSTRING || returnType == CDATA_WSTRING_OUT)
	{
	  resultOOP = _gst_unicode_string_new ((wchar_t *) result->u.ptrVal);
	  if (returnType == CDATA_WSTRING_OUT)
	    xfree (result->u.ptrVal);
	}
      else
	abort ();
      break;

    case CDATA_DOUBLE:
      resultOOP = floatd_new (result->u.doubleVal);
      break;

    case CDATA_FLOAT:
      resultOOP = floate_new (result->u.doubleVal);
      break;

    default:
      _gst_errorf
	("Invalid C function return type specified, index %d\n",
	 returnType);

      resultOOP = _gst_nil_oop;
      break;
    }

  return resultOOP;
}

void
bad_type (OOP class_oop,
	  cdata_type cType)
{
  if (IS_A_METACLASS (class_oop))
    _gst_errorf ("Attempt to pass the %O object as a %s", class_oop,
	         c_type_name[cType]);
  else
    _gst_errorf ("Attempt to pass an instance of %O as a %s", class_oop,
	         c_type_name[cType]);

  _gst_show_backtrace ();
}



OOP
_gst_make_descriptor (OOP funcNameOOP,
		      OOP returnTypeOOP,
		      OOP argsOOP)
{
  char *funcName;
  cfunc_info *cfi;
  p_void_func funcAddr;
  int numArgs, i;
  gst_cfunc_descriptor desc;
  inc_ptr incPtr;
  OOP cFunction, cFunctionName, descOOP;

  funcName = (char *) _gst_to_cstring (funcNameOOP);
  cfi = lookup_function (funcName);
  funcAddr = cfi ? cfi->funcAddr : NULL;

  if (argsOOP == _gst_nil_oop)
    numArgs = 0;
  else
    numArgs = NUM_OOPS (OOP_TO_OBJ (argsOOP));

  /* since these are all either ints or new objects, I'm not moving the
     OOPs */
  incPtr = INC_SAVE_POINTER ();

  cFunction = COBJECT_NEW (cfi);
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
     systems.  */

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
  cfunc_info *cfi;
  char *funcName;

  desc = (gst_cfunc_descriptor) OOP_TO_OBJ (cFuncDescOOP);
  funcName = (char *) _gst_to_cstring (desc->cFunctionName);
  cfi = lookup_function (funcName);
  xfree (funcName);
  SET_COBJECT_VALUE (desc->cFunction, cfi);
}
