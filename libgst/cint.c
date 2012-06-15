/******************************** -*- C -*- ****************************
 *
 *	C - Smalltalk Interface module
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1988,89,90,91,92,94,95,99,2000,2001,2002,2003,2005,2006,2007,2008,2009,2011
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
#include "pointer-set.h"

#include "ffi.h"
#include <ltdl.h>

#ifdef HAVE_GETGRNAM
#include <grp.h>
#endif
#ifdef HAVE_GETPWNAM
#include <pwd.h>
#endif

typedef struct cparam
{
  union {
    long longVal;
    PTR ptrVal;
    float floatVal;
    double doubleVal;
    long double longDoubleVal;
    long long longLongVal;
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
  void (*funcAddr) ();
} cfunc_info;

typedef struct cfunc_cif_cache
{
  unsigned cacheGeneration;	/* Is the function called with variadic parms? */
  ffi_cif cacheCif;		/* cached ffi_cif representation */

  int types_size;
  int arg_idx;
  cparam *args;
  ffi_type **types;
}
cfunc_cif_cache;

typedef struct gst_ffi_closure
{
  // This field must come first, since the address of this field will
  // be the same as the address of the overall structure.  This is due
  // to disabling interior pointers in the GC.
  ffi_closure closure;
  void *address;
  OOP callbackOOP;
  ffi_cif cif;
  ffi_type *return_type;
  ffi_type *arg_types[1];
}
gst_ffi_closure;

struct gst_stat_struct
{
  unsigned short st_mode;	/* protection */
  long st_size;			/* total size, in bytes */
  long st_aTime;		/* time of last access */
  long st_mTime;		/* time of last modification */
  long st_cTime;		/* time of last change */
};

typedef struct gst_stat
{
  OBJ_HEADER;
  OOP st_mode;		/* protection */
  OOP st_size;		/* total size, in bytes */
  OOP st_aTime;		/* time of last access */
  OOP st_mTime;		/* time of last modification */
  OOP st_cTime;		/* time of last change */
}
*gst_stat;



/* Test/example C function and tribute to the original author :-) */
static void marli (int n);

/* Prints an error message... this should really make the primitive
   fail so that a WrongClass exception is generated (FIXME) */
static void bad_type (OOP class_oop,
		      cdata_type cType);

/* Determines the appropriate C mapping for OOP and stores it. This
   returns 1 in case the type could not be converted. */
static mst_Boolean push_smalltalk_obj (OOP oop,
				       cdata_type cType);

/* Converts the return type as stored in RESULT to an OOP, based
   on the RETURNTYPEOOP that is stored in the descriptor.  #void is
   converted to RECEIVEROOP.  */
static OOP c_to_smalltalk (cparam *result, OOP receiverOOP, OOP returnTypeOOP);

/* Converts the return type CTYPE, stored in a descriptor to a
   libffi type.  */
static ffi_type *get_ffi_type (OOP returnTypeOOP);

/* Initializes libltdl and defines the functions to access it.  */
static void init_dld (void);

/* Wrapper around lt_dlopenext that invokes gst_initModule if it is found
   in the library.  */
static PTR dld_open (const char *filename);

/* Callout to tests callins and callbacks.  */
static void test_callin (OOP oop, int(*callback)(const char *));

/* Callout to test the CString class */
static void test_cstring (char **string);

/* Callout to test #cObjectPtr parameters */
static void test_cobject_ptr (const void **string);

/* Return the errno on output from the last callout.  */
static int get_errno (void);

/* Encapsulate binary incompatibilities between various C libraries.  */
static int my_stat_old (const char *name,
		        struct gst_stat_struct * out);
static int my_stat (const char *name,
		    OOP out);
#ifdef HAVE_LSTAT
static int my_lstat_old (const char *name,
		         struct gst_stat_struct * out);
static int my_lstat (const char *name,
		     OOP out);
#endif
static int my_putenv (const char *str);
static char **get_environ (void);
static int my_chdir (const char *str);
static int my_chown (const char *file, const char *owner, const char *group);
static int my_symlink (const char* oldpath, const char* newpath);
static char *my_mkdtemp (char* template);
static int my_mkdir (const char* name, int mode);
static DIR *my_opendir (const char *str);
static char *extract_dirent_name (struct dirent *dir);

/* Provide access to the arguments passed via -a.  */
static int get_argc (void);
static const char *get_argv (int n);

/* The binary tree of function names vs. function addresses.  */
static cfunc_info *c_func_root = NULL;

/* The binary tree of function names vs. function addresses.  */
static struct pointer_map_t *cif_cache = NULL;

/* Used to invalidate the cache upon GC.  */
static unsigned cif_cache_generation = 1;

/* The cfunc_cif_cache that's being filled in.  */
static cfunc_cif_cache *c_func_cur = NULL;

/* printable names for corresponding C types */
static const char *c_type_name[] = {
  "char",			/* CDATA_CHAR */
  "unsigned char",		/* CDATA_UCHAR */
  "short",			/* CDATA_SHORT */
  "unsigned short",		/* CDATA_USHORT */
  "long",			/* CDATA_LONG */
  "unsigned long",		/* CDATA_ULONG */
  "float",			/* CDATA_FLOAT */
  "double",			/* CDATA_DOUBLE */
  "char *",			/* CDATA_STRING */
  "OOP",			/* CDATA_OOP */
  "int",			/* CDATA_INT */
  "unsigned int",		/* CDATA_UINT */
  "long double",		/* CDATA_LONG_DOUBLE */

  "void?",			/* CDATA_UNKNOWN */
  "char *",			/* CDATA_STRING_OUT */
  "char *",			/* CDATA_SYMBOL */
  "char *",			/* CDATA_BYTEARRAY */
  "char *",			/* CDATA_BYTEARRAY_OUT */
  "int",			/* CDATA_BOOLEAN */
  "void?",			/* CDATA_VOID */
  "...",			/* CDATA_VARIADIC */
  "...",			/* CDATA_VARIADIC_OOP */
  "void *",			/* CDATA_COBJECT -- this is misleading */
  "void **",			/* CDATA_COBJECT_PTR */
  "void?",			/* CDATA_SELF */
  "OOP",			/* CDATA_SELF_OOP */
  "wchar_t",			/* CDATA_WCHAR */
  "wchar_t *",			/* CDATA_WSTRING */
  "wchar_t *",			/* CDATA_WSTRING_OUT */
  "char *",			/* CDATA_SYMBOL_OUT */
  "long long",			/* CDATA_LONGLONG */
  "unsigned long long", 	/* CDATA_ULONGLONG */
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

  /* When we get one of these, we don't return an error.  However,
     the primitive still fails and the file/socket is closed by the
     Smalltalk code.  */
  if (old == ESHUTDOWN || old == ECONNRESET
      || old == ECONNABORTED || old == ENETRESET
      || old == EPIPE)
    return 0;
  else
    return (old);
}

static inline int
adjust_time (time_t t)
{
  return _gst_adjust_time_zone (t) - 86400 * 10957;
}

static inline int
my_stat_old (const char *name,
	     struct gst_stat_struct * out)
{
  int result;
  struct stat statOut;

  result = stat (name, &statOut);
  if (!result)
    {
      errno = 0;
      out->st_mode = statOut.st_mode;
      out->st_size = statOut.st_size;
      out->st_aTime = adjust_time (statOut.st_atime);
      out->st_mTime = adjust_time (statOut.st_mtime);
      out->st_cTime = adjust_time (statOut.st_ctime);
    }
  return (result);
}

int
my_stat (const char *name,
	 OOP out)
{
  int result;
  struct stat statOut;

  result = stat (name, &statOut);
  if (!result)
    {
      gst_stat obj = (gst_stat) OOP_TO_OBJ (out);
      errno = 0;
      obj->st_mode = FROM_INT (statOut.st_mode);
      obj->st_aTime = FROM_INT (adjust_time (statOut.st_atime));
      obj->st_mTime = FROM_INT (adjust_time (statOut.st_mtime));
      obj->st_cTime = FROM_INT (adjust_time (statOut.st_ctime));
      obj->st_size = FROM_OFF_T (statOut.st_size);
    }
  return (result);
}

#ifdef HAVE_LSTAT
static inline int
my_lstat_old (const char *name,
	      struct gst_stat_struct * out)
{
  int result;
  struct stat statOut;

  result = lstat (name, &statOut);
  if (!result)
    {
      errno = 0;
      out->st_mode = statOut.st_mode;
      out->st_size = statOut.st_size;
      out->st_aTime = adjust_time (statOut.st_atime);
      out->st_mTime = adjust_time (statOut.st_mtime);
      out->st_cTime = adjust_time (statOut.st_ctime);
    }
  return (result);
}

int
my_lstat (const char *name,
	 OOP out)
{
  int result;
  struct stat statOut;

  result = lstat (name, &statOut);
  if (!result)
    {
      gst_stat obj = (gst_stat) OOP_TO_OBJ (out);
      errno = 0;
      obj->st_mode = FROM_INT (statOut.st_mode);
      obj->st_aTime = FROM_INT (adjust_time (statOut.st_atime));
      obj->st_mTime = FROM_INT (adjust_time (statOut.st_mtime));
      obj->st_cTime = FROM_INT (adjust_time (statOut.st_ctime));
      obj->st_size = FROM_OFF_T (statOut.st_size);
    }
  return (result);
}
#else
#define my_lstat my_stat
#define my_lstat_old my_stat_old
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

static char **
get_environ (void)
{
  return environ;
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

static int 
my_mkdir (const char* name,
	  int mode)
{
  int retstat;
#ifdef __MSVCRT__
  retstat = mkdir (name);
  if (retstat == 0)
    retstat = chmod (name, mode);
#else
  retstat = mkdir (name, mode);
#endif
  return retstat;
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

long long
test_longlong (long long aVerylongInt)
{
  printf ("Getting a long long 0x%llx\n", aVerylongInt);
  return aVerylongInt;
}

void
test_callin (OOP oop, int(*callback)(const char *))
{
  OOP o;
  double f;
  int i;
  _gst_str_msg_send (oop, "printNl", NULL);

  o = _gst_string_to_oop ("abc");
  _gst_str_msg_send (_gst_str_msg_send (o, ",", o, NULL), "printNl",
		     NULL);
  i = callback ("this is a test");
  _gst_msg_sendf (&f, "%f %i + %f", i, 4.7);
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
  return (n >= 1 && n <= _gst_smalltalk_passed_argc
	  ? _gst_smalltalk_passed_argv[n - 1]
	  : NULL);
}

PTR
dld_open (const char *filename)
{
#ifdef ENABLE_DLD
  lt_dlhandle handle;
  void (*initModule) (struct VMProxy *);

  /* Not all shared libraries have .xyz extensions! */
  handle = lt_dlopen (filename);
  if (!handle)
    handle = lt_dlopenext (filename);
#ifdef __APPLE__
  if (!handle)
    {
      /* For some reason, lt_dlopenext on OS X doesn't try ".dylib" as
         a possible extension, so we're left with trying it here. */
      char *full_filename;
      asprintf(&full_filename, "%s.dylib", filename);
      handle = lt_dlopen (full_filename);
      free (full_filename);
    }
#endif
  if (handle)
    {
      initModule = lt_dlsym (handle, "gst_initModule");
      if (initModule)
	initModule (_gst_get_vmproxy ());
    }

  return (handle);
#else
  return (NULL);
#endif
}

struct search_path_stack {
  char *saved_search_path;
  struct search_path_stack *next;
};

struct search_path_stack *search_paths;

mst_Boolean
_gst_dlopen (const char *path, mst_Boolean module)
{
  PTR h = dld_open (path);
  if (h && !module)
    _gst_msg_sendf (NULL, "%v %o addLibraryHandle: %C",
		    _gst_class_name_to_oop ("DLD"), h);
  return !!h;
}

void
_gst_dladdsearchdir (const char *dir)
{
  lt_dlinsertsearchdir (lt_dlgetsearchpath (), dir);
}

void
_gst_dlpushsearchpath (void)
{
  struct search_path_stack *entry = xmalloc (sizeof (struct search_path_stack));
  const char *path = lt_dlgetsearchpath ();
  entry->saved_search_path = path ? strdup (path) : NULL;
  entry->next = search_paths;
  search_paths = entry;
}

void
_gst_dlpopsearchpath (void)
{
  struct search_path_stack *path = search_paths;
  if (!path)
    return;

  lt_dlsetsearchpath (path->saved_search_path);
  search_paths = path->next;
  free (path->saved_search_path);
  free (path);
}



void
init_dld (void)
{
  char *modules;
  lt_dlinit ();

  modules = _gst_relocate_path (MODULE_PATH);
  lt_dladdsearchdir (modules);
  free (modules);

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

  cif_cache = pointer_map_create ();

  /* Access to command line args */
  _gst_define_cfunc ("getArgc", get_argc);
  _gst_define_cfunc ("getArgv", get_argv);

  /* Test functions */
  _gst_define_cfunc ("testLongLong", test_longlong);
  _gst_define_cfunc ("testCallin", test_callin);
  _gst_define_cfunc ("testCString", test_cstring);
  _gst_define_cfunc ("testCObjectPtr", test_cobject_ptr);

  /* Access to C library */
  _gst_define_cfunc ("system", system);
  _gst_define_cfunc ("getenv", getenv);
  _gst_define_cfunc ("environ", get_environ);
  _gst_define_cfunc ("putenv", my_putenv);
  _gst_define_cfunc ("printf", printf);

  _gst_define_cfunc ("errno", get_errno);
  _gst_define_cfunc ("strerror", strerror);
  _gst_define_cfunc ("stat", my_stat_old);
  _gst_define_cfunc ("lstat", my_lstat_old);
  _gst_define_cfunc ("stat_obj", my_stat);
  _gst_define_cfunc ("lstat_obj", my_lstat);
  _gst_define_cfunc ("utime", _gst_set_file_access_times);
  _gst_define_cfunc ("chmod", chmod);
  _gst_define_cfunc ("chown", my_chown);

  _gst_define_cfunc ("opendir", my_opendir);
  _gst_define_cfunc ("closedir", closedir);
  _gst_define_cfunc ("readdir", readdir);
  _gst_define_cfunc ("rewinddir", rewinddir);
  _gst_define_cfunc ("extractDirentName", extract_dirent_name);

  _gst_define_cfunc ("symlink", my_symlink);
  _gst_define_cfunc ("unlink", unlink);
  _gst_define_cfunc ("rename", rename);
  _gst_define_cfunc ("rmdir", rmdir);
  _gst_define_cfunc ("chdir", my_chdir);
  _gst_define_cfunc ("mkdir", my_mkdir);
  _gst_define_cfunc ("mkdtemp", my_mkdtemp);
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



PTR
_gst_lookup_function (const char *funcName)
{
  cfunc_info *cfi = c_func_root;

  while (cfi)
    {
      int cmp;

      cmp = strcmp(funcName, cfi->funcName);
      if (cmp == 0)
	return (PTR) cfi->funcAddr;
      
      cfi = (cfunc_info *) (cmp < 0 ? cfi->avl.avl_left : cfi->avl.avl_right);
    }

  return NULL;
}


int
_gst_c_type_size (int type)
{
  switch (type)
    {
    case CDATA_CHAR:
      return sizeof (char);
    case CDATA_UCHAR:
      return sizeof (unsigned char);

    case CDATA_SHORT:
      return sizeof (short);
    case CDATA_USHORT:
      return sizeof (unsigned short);

    case CDATA_INT:
      return sizeof (int);
    case CDATA_UINT:
      return sizeof (unsigned int);

    case CDATA_LONG:
      return sizeof (long);
    case CDATA_ULONG:
      return sizeof (unsigned long);

    case CDATA_LONGLONG:
      return sizeof (long long);
    case CDATA_ULONGLONG:
      return sizeof (unsigned long long);

    case CDATA_FLOAT:
      return sizeof (float);
    case CDATA_DOUBLE:
      return sizeof (double);
    case CDATA_LONG_DOUBLE:
      return sizeof (long double);

    case CDATA_OOP:
      return sizeof (OOP);

    case CDATA_WCHAR:
      return sizeof (wchar_t);

    case CDATA_WSTRING:
      return sizeof (wchar_t *);

    case CDATA_STRING:
    case CDATA_STRING_OUT:
    case CDATA_SYMBOL:
    case CDATA_BYTEARRAY:
    case CDATA_BYTEARRAY_OUT:
    case CDATA_SYMBOL_OUT:
      return sizeof (char *);

    case CDATA_COBJECT:
      return sizeof (void *);

    case CDATA_COBJECT_PTR:
      return sizeof (void **);

    default:
      return 0;
    }
}

void
_gst_invalidate_croutine_cache (void)
{
  /* May want to delete and recreate completely upon global GC,
     and do the cheap invalidation only for scavenging?  For now,
     we do the simplest thing.  Incrementing by 2 makes sure that
     the generation number is never 0.  */
  cif_cache_generation += 2;
}

OOP
_gst_invoke_croutine (OOP cFuncOOP,
		      OOP receiver,
		      OOP *args)
{
  gst_c_callable desc;
  cdata_type cType;
  cparam result, *local_arg_vec, *arg;
  void *funcAddr, **p_slot, **ffi_arg_vec;
  OOP *argTypes, oop;
  int i, si, fixedArgs, totalArgs, filledArgs;
  mst_Boolean haveVariadic, needPostprocessing;
  inc_ptr incPtr;

  incPtr = INC_SAVE_POINTER ();

  /* Make sure the parameters do not die.  */
  INC_ADD_OOP (cFuncOOP);
  INC_ADD_OOP (receiver);

  funcAddr = cobject_value (cFuncOOP);
  if (!funcAddr)
    return (NULL);

  p_slot = pointer_map_insert (cif_cache, cFuncOOP);
  if (!*p_slot)
    *p_slot = xcalloc (1, sizeof (cfunc_cif_cache));

  desc = (gst_c_callable) OOP_TO_OBJ (cFuncOOP);
  argTypes = OOP_TO_OBJ (desc->argTypesOOP)->data;

  c_func_cur = *p_slot;
  fixedArgs = NUM_INDEXABLE_FIELDS (desc->argTypesOOP);
  totalArgs = 0;
  haveVariadic = needPostprocessing = false;
  for (si = i = 0; i < fixedArgs; i++)
    {
      cType = IS_OOP (argTypes[i]) ? CDATA_COBJECT : TO_INT (argTypes[i]);
      switch (cType)
	{
	case CDATA_VOID:
	  break;

	case CDATA_VARIADIC:
	case CDATA_VARIADIC_OOP:
	  oop = args[si++];
	  totalArgs += NUM_WORDS (OOP_TO_OBJ (oop));
	  haveVariadic = true;
	  break;

        case CDATA_SELF:
	case CDATA_SELF_OOP:
	  totalArgs++;
	  break;

        case CDATA_COBJECT_PTR:
        case CDATA_WSTRING_OUT:
        case CDATA_STRING_OUT:
        case CDATA_BYTEARRAY_OUT:
        case CDATA_SYMBOL_OUT:
        case CDATA_STRING:
        case CDATA_BYTEARRAY:
        case CDATA_SYMBOL:
        case CDATA_WSTRING:
	  needPostprocessing = true;
	  /* fall through */

	default:
	  totalArgs++;
	  si++;
	  break;
	}
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

  for (i = 0; i < totalArgs; i++)
    ffi_arg_vec[i] = &local_arg_vec[i].u;

  /* Push the arguments */
  for (si = i = 0; i < fixedArgs; i++)
    {
      mst_Boolean res;

      cType = IS_OOP (argTypes[i]) ? CDATA_COBJECT : TO_INT (argTypes[i]);
      if (cType == CDATA_VOID)
        continue;

      else if (cType == CDATA_SELF || cType == CDATA_SELF_OOP)
	res = push_smalltalk_obj (receiver,
				  cType == CDATA_SELF ? CDATA_UNKNOWN : CDATA_OOP);
      else
	/* Do nothing if it is a void */
	res = push_smalltalk_obj (args[si++], cType);

      if (!res)
        {
          oop = NULL;
	  filledArgs = c_func_cur->arg_idx;
          goto out;
        }
    }

  /* If the previous call was done through the same function descriptor,
     the ffi_cif is already ok.  */
  if (c_func_cur->cacheGeneration != cif_cache_generation)
    {
      ffi_prep_cif (&c_func_cur->cacheCif, FFI_DEFAULT_ABI, totalArgs,
                    get_ffi_type (desc->returnTypeOOP),
		    c_func_cur->types);

      /* For variadic functions, we cannot cache the ffi_cif because
	 the argument types change every time.  */
      if (!haveVariadic)
	c_func_cur->cacheGeneration = cif_cache_generation;
    }

  errno = 0;
  filledArgs = c_func_cur->arg_idx;
  assert (filledArgs == totalArgs);
  ffi_call (&c_func_cur->cacheCif, FFI_FN (funcAddr), &result.u, ffi_arg_vec);

  _gst_set_errno (errno);
  desc = (gst_c_callable) OOP_TO_OBJ (cFuncOOP);
  oop = c_to_smalltalk (&result, receiver, desc->returnTypeOOP);
  INC_ADD_OOP (oop);

 out:
  /* Fixup all returned string variables */
  if (needPostprocessing)
    for (i = 0, arg = local_arg_vec; i < filledArgs; i++, arg++)
      {
        if (!arg->oop)
	  continue;

	switch (arg->cType)
          {
          case CDATA_COBJECT_PTR:
            if (oop)
              set_cobject_value (arg->oop, arg->u.cObjectPtrVal.ptrVal);
            continue;

          case CDATA_WSTRING_OUT:
            if (oop)
              _gst_set_oop_unicode_string (arg->oop, arg->u.ptrVal);
            break;

          case CDATA_STRING_OUT:
            if (oop)
              _gst_set_oopstring (arg->oop, arg->u.ptrVal);
            break;

          case CDATA_BYTEARRAY_OUT:
            if (oop)
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
    case CDATA_LONGLONG:
    case CDATA_ULONGLONG:
      return &ffi_type_sint64;

    case CDATA_VOID:
    case CDATA_INT:
    case CDATA_CHAR:
    case CDATA_SHORT:
    case CDATA_WCHAR:
    case CDATA_BOOLEAN:
      return &ffi_type_sint;

    case CDATA_UINT:
    case CDATA_UCHAR:
    case CDATA_USHORT:
      return &ffi_type_uint;

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

ffi_type *
smalltalk_to_c (OOP oop,
		cparam *cp,
		cdata_type cType)
{
  OOP class = OOP_INT_CLASS (oop);

  if (cType == CDATA_UNKNOWN)
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

  memset (cp, 0, sizeof (cparam));
  cp->cType = cType;

  if (cType == CDATA_OOP)
    {
      cp->u.ptrVal = (PTR) oop;
      INC_ADD_OOP (oop);	/* make sure it doesn't get gc'd */
      return &ffi_type_pointer;
    }

  else if (is_a_kind_of (class, _gst_integer_class))
    {
      switch (cType)
        {
       case CDATA_LONGLONG:
       case CDATA_ULONGLONG:
         cp->u.longLongVal = to_c_int_64 (oop);
         return &ffi_type_sint64;
        case CDATA_LONG:
       case CDATA_ULONG:
         cp->u.longVal = TO_C_LONG (oop);
#if LONG_MAX == 2147483647
          return &ffi_type_sint32;
#else
          return &ffi_type_sint64;
#endif

        case CDATA_INT:
	  cp->u.longVal = (int) TO_C_INT (oop);
	  return &ffi_type_sint;

	case CDATA_UINT:
	  cp->u.longVal = (unsigned int) TO_C_INT (oop);
	  return &ffi_type_sint;

	case CDATA_CHAR:
	  cp->u.longVal = (char) TO_C_INT (oop);
	  return &ffi_type_sint;

	case CDATA_UCHAR:
	  cp->u.longVal = (unsigned char) TO_C_INT (oop);
	  return &ffi_type_sint;

	case CDATA_SHORT:
	  cp->u.longVal = (short) TO_C_INT (oop);
	  return &ffi_type_sint;

	case CDATA_USHORT:
	  cp->u.longVal = (unsigned short) TO_C_INT (oop);
	  return &ffi_type_sint;

	case CDATA_DOUBLE:
          cp->u.doubleVal = (double) TO_C_LONG (oop);
	  return &ffi_type_double;

	case CDATA_FLOAT:
          cp->u.floatVal = (float) TO_C_LONG (oop);
	  return &ffi_type_float;
	}
    }

  else if (oop == _gst_true_oop || oop == _gst_false_oop)
    {
      switch (cType)
        {
       case CDATA_LONGLONG:
       case CDATA_ULONGLONG:
         cp->u.longLongVal = (long long)(oop == _gst_true_oop);
         return &ffi_type_sint64;
        case CDATA_LONG:
       case CDATA_ULONG:
         cp->u.longVal = (oop == _gst_true_oop);
#if LONG_MAX == 2147483647
          return &ffi_type_sint32;
#else
          return &ffi_type_sint64;
#endif

        case CDATA_INT:
	case CDATA_UINT:
	case CDATA_CHAR:
	case CDATA_UCHAR:
	case CDATA_SHORT:
	case CDATA_USHORT:
	case CDATA_BOOLEAN:
	  cp->u.longVal = (oop == _gst_true_oop);
	  return &ffi_type_sint;
	}
    }

  else if ((class == _gst_char_class
	    && (cType == CDATA_CHAR || cType == CDATA_UCHAR || cType == CDATA_WCHAR))
           || (class == _gst_unicode_character_class && cType == CDATA_WCHAR))
    {
      cp->u.longVal = CHAR_OOP_VALUE (oop);
      return &ffi_type_sint;
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

      return &ffi_type_pointer;
    }

  else if (class == _gst_unicode_string_class
           && (cType == CDATA_WSTRING || cType == CDATA_WSTRING_OUT))
    {
      cp->oop = oop;
      cp->u.ptrVal = (gst_uchar *) _gst_to_wide_cstring (oop);

      return &ffi_type_pointer;
    }

  else if (is_a_kind_of (class, _gst_float_class))
    {
      switch (cType)
	{
	case CDATA_LONG_DOUBLE:
	  cp->u.longDoubleVal = _gst_oop_to_float (oop);
	  return &ffi_type_longdouble;

	case CDATA_DOUBLE:
	  cp->u.doubleVal = _gst_oop_to_float (oop);
	  return &ffi_type_double;

	case CDATA_FLOAT:
	  cp->u.floatVal = (float) _gst_oop_to_float (oop);
	  return &ffi_type_float;
	}
    }

  else if (is_a_kind_of (class, _gst_c_object_class))
    {
      switch (cType)
	{
	case CDATA_COBJECT_PTR:

	  /* Set up an indirect pointer to protect against the OOP
	     moving during the call-out.  */
	  cp->u.cObjectPtrVal.pPtrVal = &cp->u.cObjectPtrVal.ptrVal;
	  cp->u.cObjectPtrVal.ptrVal = cobject_value (oop);
	  cp->oop = oop;
	  return &ffi_type_pointer;

	case CDATA_COBJECT:
	  cp->u.ptrVal = cobject_value (oop);
	  return &ffi_type_pointer;
	}
    }

  else if (class == _gst_undefined_object_class)
    {				/* how to encode nil */
      switch (cType)
	{
	case CDATA_COBJECT_PTR:
	case CDATA_COBJECT:
	case CDATA_BYTEARRAY:
	case CDATA_BYTEARRAY_OUT:
	case CDATA_STRING:
	case CDATA_STRING_OUT:
	case CDATA_SYMBOL:
	  cp->u.ptrVal = NULL;
	  return &ffi_type_pointer;
	}
    }

  /* #cObject can pass every object with non-pointer indexed instance
     variables.  */
  if (cType == CDATA_COBJECT)
    {
      switch (CLASS_INSTANCE_SPEC (class) & ISP_INDEXEDVARS)
	{
	case GST_ISP_FIXED:
	case GST_ISP_POINTER:
	  break;

	default:
	  /* Byte indexed variables, pass the pointer through.  */
	  cp->u.ptrVal = OOP_TO_OBJ (oop)->data + CLASS_FIXED_FIELDS (class);
	  return &ffi_type_pointer;
	}
    }

  bad_type (class, cType);
  return NULL;
}

mst_Boolean
push_smalltalk_obj (OOP oop,
		    cdata_type cType)
{
  if (cType == CDATA_VARIADIC || cType == CDATA_VARIADIC_OOP)
    {
      int i;
      if (OOP_INT_CLASS (oop) != _gst_array_class)
	{
          bad_type (OOP_INT_CLASS (oop), cType);
          return false;
	}

      cType = (cType == CDATA_VARIADIC) ? CDATA_UNKNOWN : CDATA_OOP;
      for (i = 1; i <= NUM_WORDS (OOP_TO_OBJ (oop)); i++)
	if (!push_smalltalk_obj (ARRAY_AT (oop, i), cType))
	  return false;
    }
  else
    {
      cparam *cp = &c_func_cur->args[c_func_cur->arg_idx];
      ffi_type *type = smalltalk_to_c (oop, cp, cType);
      if (cp->oop && !IS_NIL (cp->oop))
	INC_ADD_OOP (cp->oop);
      if (type)
	c_func_cur->types[c_func_cur->arg_idx++] = type;
      else
	return false;
    }

  return true;
}

OOP
c_to_smalltalk (cparam *result, OOP receiverOOP, OOP returnTypeOOP)
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
      resultOOP = receiverOOP;
      break;

    case CDATA_CHAR:
    case CDATA_UCHAR:
      resultOOP = CHAR_OOP_AT ((gst_uchar) result->u.longVal);
      break;

    case CDATA_WCHAR:
      resultOOP = char_new ((wchar_t) result->u.longVal);
      break;

    case CDATA_BOOLEAN:
      resultOOP = result->u.longVal ? _gst_true_oop : _gst_false_oop;
      break;

    case CDATA_INT:
      resultOOP = FROM_C_INT ((int) result->u.longVal);
      break;

    case CDATA_UINT:
      resultOOP = FROM_C_UINT ((unsigned int) result->u.longVal);
      break;

    case CDATA_SHORT:
      resultOOP = FROM_INT ((short) result->u.longVal);
      break;

    case CDATA_USHORT:
      resultOOP = FROM_INT ((unsigned short) result->u.longVal);
      break;

    case CDATA_LONG:
      resultOOP = FROM_C_LONG (result->u.longVal);
      break;

    case CDATA_ULONG:
      resultOOP = FROM_C_ULONG (result->u.longVal);
      break;

    case CDATA_LONGLONG:
      resultOOP = FROM_C_LONGLONG (result->u.longLongVal);
      break;

    case CDATA_ULONGLONG:
      resultOOP = FROM_C_ULONGLONG (result->u.longLongVal);
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
	    returnTypeOOP = _gst_nil_oop;
	  resultOOP = COBJECT_NEW (result->u.ptrVal, returnTypeOOP,
				   _gst_c_object_class);
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
}


/* This function does the unmarshaling of the libffi arguments to Smalltalk,
   and calls the block that is stored in the CCallbackDescriptor.  */

static void
closure_msg_send (ffi_cif* cif, void* result, void** args, void* userdata)
{
  gst_ffi_closure *closure = userdata;
  OOP callbackOOP = closure->callbackOOP;
  gst_c_callable desc;
  int numArgs, i;
  OOP *argsOOP, *argTypes, resultOOP;
  cdata_type cType;
  cparam cp;

  desc = (gst_c_callable) OOP_TO_OBJ (callbackOOP);
  numArgs = NUM_INDEXABLE_FIELDS (desc->argTypesOOP);
  argsOOP = alloca (sizeof (OOP) * numArgs);

  for (i = 0; i < numArgs; i++)
    {
      memcpy (&cp.u, args[i], sizeof (ffi_arg));
      desc = (gst_c_callable) OOP_TO_OBJ (callbackOOP);
      argTypes = OOP_TO_OBJ (desc->argTypesOOP)->data;
      argsOOP[i] = c_to_smalltalk (&cp, _gst_nil_oop, argTypes[i]);
    }

  desc = (gst_c_callable) OOP_TO_OBJ (callbackOOP);
  resultOOP = _gst_nvmsg_send (desc->blockOOP, NULL, argsOOP, numArgs);

  desc = (gst_c_callable) OOP_TO_OBJ (callbackOOP);
  cType = IS_OOP (desc->returnTypeOOP) ? CDATA_COBJECT : TO_INT (desc->returnTypeOOP);
  if (cType != CDATA_VOID && smalltalk_to_c (resultOOP, &cp, cType))
    memcpy (result, &cp.u, sizeof (ffi_arg));
  else
    memset (result, 0, sizeof (ffi_arg));
}

void
_gst_make_closure (OOP callbackOOP)
{
  gst_c_callable desc;
  OOP *argTypes;
  void *code;
  gst_ffi_closure *closure;
  int numArgs, i;

  if (cobject_value (callbackOOP))
    return;

  desc = (gst_c_callable) OOP_TO_OBJ (callbackOOP);
  numArgs = NUM_INDEXABLE_FIELDS (desc->argTypesOOP);
  argTypes = OOP_TO_OBJ (desc->argTypesOOP)->data;
  closure = (gst_ffi_closure *) ffi_closure_alloc (
    sizeof (gst_ffi_closure) + sizeof(ffi_type *) * (numArgs - 1), &code);

  closure->address = closure;
  closure->callbackOOP = callbackOOP;
  closure->return_type = get_ffi_type (desc->returnTypeOOP);
  for (i = 0; i < numArgs; i++)
    closure->arg_types[i] = get_ffi_type (argTypes[i]);

  ffi_prep_cif (&closure->cif, FFI_DEFAULT_ABI,
		numArgs, closure->return_type, closure->arg_types);

  ffi_prep_closure_loc (&closure->closure, &closure->cif, closure_msg_send,
			closure, code);
  set_cobject_value (callbackOOP, code);
}

void
_gst_free_closure (OOP callbackOOP)
{
  gst_ffi_closure *exec_closure = cobject_value (callbackOOP);
  ffi_closure_free (exec_closure->address); 
  set_cobject_value (callbackOOP, NULL);
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


int
my_chown (const char *file, const char *user, const char *group)
{
#if defined HAVE_CHOWN && defined HAVE_GETGRNAM && defined HAVE_GETPWNAM
  static char *save_user, *save_group;
  static uid_t save_uid;
  static gid_t save_gid;
  static int recursive_depth;

  uid_t uid, gid;
  if (!file && !user && !group)
    {
      recursive_depth--;
      if (recursive_depth == 0)
	{
#if defined HAVE_SETGROUPENT && defined HAVE_ENDGRENT
	  endgrent ();
#endif
#if defined HAVE_SETPASSENT && defined HAVE_ENDPWENT
	  endpwent ();
#endif
	}

      free (save_user);
      free (save_group);
      save_user = save_group = NULL;
      return 0;
    }

  if (!file)
    {
      recursive_depth++;
      if (recursive_depth == 1)
	{
#if defined HAVE_SETGROUPENT && defined HAVE_ENDGRENT
	  setgroupent (1);
#endif
#if defined HAVE_SETPASSENT && defined HAVE_ENDPWENT
	  setpassent (1);
#endif
	}
    }

  if (!user)
    uid = -1;
  else if (save_user && !strcmp (save_user, user))
    uid = save_uid;
  else
    {
      struct passwd *pw;
      pw = getpwnam (user);
      if (!pw)
	{
	  errno = EINVAL;
	  return -1;
	}

      uid = pw->pw_uid;
      if (recursive_depth)
	{
	  if (save_user)
	    free (save_user);
          save_user = strdup (user);
	  save_uid = uid;
	}
    }

  if (!group)
    gid = -1;
  else if (save_group && !strcmp (save_group, group))
    gid = save_gid;
  else
    {
      struct group *gr;
      gr = getgrnam (group);
      if (!gr)
	{
	  errno = EINVAL;
	  return -1;
	}

      gid = gr->gr_gid;
      if (recursive_depth)
	{
	  if (save_group)
	    free (save_group);
          save_group = strdup (group);
	  save_gid = gid;
	}
    }

  if (!file)
    return 0;
  else
    return chown (file, uid, gid);
#else
  return 0;
#endif
}

/* TODO: check if this can be changed to an extern declaration and/or
   an AC_CHECK_DECLS test.  */

int
my_symlink (const char* oldpath, const char* newpath)
{
  return symlink (oldpath,  newpath);
}
 
char*
my_mkdtemp(char* template)
{
  return mkdtemp(template);
}
