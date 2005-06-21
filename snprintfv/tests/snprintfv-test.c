/*  -*- Mode: C -*-  */

/* snprintfv-test.c --- test driver for snprintfv
 * Copyright (C) 1998, 1999, 2002 Gary V. Vaughan
 * Originally by Gary V. Vaughan, 1998
 * This file is part of Snprintfv.
 *
 * Snprintfv is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * Snprintfv is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 * As a special exception to the GNU General Public License, if you
 * distribute this file as part of a program that also links with and
 * uses the libopts library from AutoGen, you may include it under
 * the same distribution terms used by the libopts library.
 */

/* Code: */

#ifdef HAVE_CONFIG_H
#  include "config.h"
#endif

/* Usually, this is taken care of by AC_SNPRINTFV_INSTALLABLE.  */
#define LIBSNPRINTFV_DLL_IMPORT 1

#include <unistd.h>		/* for STDOUT_FILENO */
#ifndef STDOUT_FILENO
#  define STDOUT_FILENO 1
#endif

#include "printf.h"
#include "mem.h"
#include "stream.h"
#include "filament.h"

#ifndef AUTHOR
#define AUTHOR		"Gary V. Vaughan <gary@gnu.org>"
#endif

#ifndef EOS
# define EOS		'\0'
#endif

#undef ISSET
#define ISSET(field, flag)	((field)&(flag))


/* --- Type Definitions --- */

/* We can't be more specific, because the signatures vary... */
typedef int API_func ();

typedef enum
{
  STREAM_NONE,
  STREAM_FD,
  STREAM_STDOUT,
  STREAM_FILE,
  STREAM_UNLIMITED_BUFFER,
  STREAM_BUFFER,
  STREAM_ALLOC,
  STREAM_FILAMENT,
  STREAM_NATIVE,
  STREAM_COUNT
}
stream_type;

typedef struct
{
  char *name;
  API_func *func;
  stream_type stream;
}
API_map_element;


/* --- Forward Declarations -- */

static union printf_arg *argv_dup (unsigned argc, char *const argv[]);
static snv_constpointer *vector_canonicalize (const char *format, unsigned num_elements, union printf_arg vector[]);
static int filprintfv (Filament * fil, const char *format, snv_constpointer args[]);
static void check_failure (char *function_name, int count_or_errorcode);


/* --- Static Data --- */

/* A mapping from function names (-f flag) to API function pointers */

API_map_element map_name_to_func[] = {
  /*  name              function      stream  */
  {"filprintfv", filprintfv, STREAM_FILAMENT},
  {"stream_printfv", stream_printfv, STREAM_NATIVE},
  {"dprintfv", dprintfv, STREAM_FD},
  {"printfv", printfv, STREAM_STDOUT},
  {"fprintfv", fprintfv, STREAM_FILE},
  {"asprintfv", asprintfv, STREAM_ALLOC},
  {"sprintfv", sprintfv, STREAM_UNLIMITED_BUFFER},
  {"snprintfv", snprintfv, STREAM_BUFFER},
  {"count", stream_printfv, STREAM_COUNT},
  {NULL, NULL, STREAM_NONE}
};

static char *program_name = NULL;



/* --- The Code --- */

static union printf_arg *
argv_dup (unsigned argc, char *const argv[])
{
  unsigned index;
  union printf_arg *result;

  result = snv_new (union printf_arg, argc);

  for (index = 0; index < argc; index++)
    {
      int len = strlen (argv[index]);
      char *dup = snv_new (char, len + 1);
      memcpy (dup, argv[index], len + 1);
      result[index].pa_string = dup;
    }

  return result;
}


static snv_constpointer *
vector_canonicalize (const char *format, unsigned num_elements, union printf_arg vector[])
{
  snv_constpointer *ap;
  int *argtypes;
  unsigned index;

  ap = snv_new (snv_constpointer, num_elements);
  argtypes = snv_new (int, num_elements);
  memset (argtypes, -1, sizeof(int) * num_elements);
  num_elements = parse_printf_format (format, num_elements, argtypes);
  check_failure ("parse_printf_format", num_elements);

  for (index = 0; index < num_elements; index++)
    {
      char *string = (char *) vector[index].pa_string;
      char *p = string;

      ap[index] = string;
      switch (argtypes[index])
	{
	case -1:
	  /* Unused argument */
	  continue;

	case PA_STRING:
	  /* Is it an explicit string? */
	  if ((p != NULL) && (p[0] == '\"'))
	    {
	      char *ptr;

	      for (ptr = p + 1; *ptr != EOS && *ptr != '\"'; ptr++)
		if (*ptr == '\\')
		  *p++ = *++ptr;
		else
		  *p++ = *ptr;

	      *p = EOS;
	      continue;
	    }

	  break;

        case PA_POINTER:
	case PA_INT:
	case PA_INT | PA_FLAG_CHAR:
	case PA_INT | PA_FLAG_SHORT:
	case PA_INT | PA_FLAG_UNSIGNED:
	case PA_INT | PA_FLAG_LONG:
	case PA_INT | PA_FLAG_LONG_LONG:
	  {
	    /* Does it look like a whole number? */
	    char *endptr;
	    boolean is_negative = FALSE;
	    unsigned long value;

	    /* Find the sign. */
	    if (strchr ("+-", *p))
	      {
		if (*p++ == '-')
		  is_negative = TRUE;
	      }

	    /* Extract the absolute value. */
	    value = strtoul (p, &endptr, 0);
	    if (is_negative)
	      value = -value;

	    /* Accept trailing u and l as flags. */
	    while (*endptr != EOS && strchr ("ulUL", *endptr) != NULL)
	      {
		switch (*endptr)
		  {
		  case 'u':
		  case 'U':
		    snv_assert (is_negative == FALSE);
		    break;

		  case 'l':
		  case 'L':
		    if (endptr[1] == *endptr)
		      {
			++endptr;
			snv_assert (ISSET(argtypes[index], PA_FLAG_LONG_LONG));
		      }
		    else
		      snv_assert (ISSET(argtypes[index], PA_FLAG_LONG));
		
		    break;
		  }
		++endptr;
	      }

	    if (*endptr == EOS && *p != EOS)
	      {
		snv_delete (string);
		if (argtypes[index] == PA_POINTER
		    || ISSET (argtypes[index], PA_FLAG_LONG_LONG))
	          ap[index] = (snv_pointer) (long int) value;

		else if (ISSET (argtypes[index], PA_FLAG_LONG_LONG))
	          ap[index] = &vector[index],
		  vector[index].pa_long_long_int = value;

		else if (ISSET (argtypes[index], PA_FLAG_SHORT))
	          ap[index] = (snv_pointer) (long int) (short int) value;

		else
	          ap[index] = (snv_pointer) (long int) (int) value;

		continue;
	      }
	  }

	  break;


	case PA_CHAR:
	  if (p[0] != '\0' && p[1] == '\0')
	    {
	      char c = *p;
	      snv_delete (string);
	      ap[index] = (snv_pointer) (long int) c;
	      continue;
	    }
	  break;

	case PA_DOUBLE:
	case PA_DOUBLE | PA_FLAG_LONG_DOUBLE:
	  /* Does it look like a floating point number? */
	  {
	    double value;
	    char *endptr;

	    value = strtod (p, &endptr);

	    if (*endptr == EOS && *p != EOS)
	      {
		snv_delete (string);

	        ap[index] = &vector[index];
		if (ISSET (argtypes[index], PA_FLAG_LONG_DOUBLE))
		  vector[index].pa_long_double = value;
		else
		  vector[index].pa_double = value;

		continue;
	      }
	  }
	  break;

	}

      if (argtypes[index] != PA_POINTER && argtypes[index] != PA_STRING)
        {
	  fprintf (stderr, "%s: `%s', invalid parameter.\n", string);
          exit (EXIT_FAILURE);
	}
    }

  return ap;
}

/* Just to show how easy it is to write your own:
   here is format function which writes to a Filament based STREAM. */
static int
filprintfv (Filament *fil, const char *format, snv_constpointer *args)
{
  STREAM *out = stream_new (fil, SNV_UNLIMITED, NULL, snv_filputc);
  int result = stream_printfv (out, format, args);
  stream_delete (out);
  return result;
}


void
check_failure (char *function_name, int count_or_errorcode)
{
  if (count_or_errorcode < 0)
    {
      char *errbase = printf_strerror (), *err, *p;

      /* Remove the debugging information from the error (line number,
         file name, and function name) */
      for (p = err = errbase; *p; p++)
	if (*p == ':')
	  err = p + 2;

      printf ("*** %s returned ERROR (%s).\n", function_name, err);
      snv_delete (errbase);
      exit (EXIT_FAILURE);
    }
}

int
main (int argc, char *const argv[])
{
  char *function_name = "printfv";
  API_func *function_handle;
  snv_constpointer *args;
  char *buf = NULL;
  char *format;
  int count_or_errorcode;
  unsigned buflen = 1024;
  stream_type stream = STREAM_NONE;

  program_name = argv[0];
  while (*program_name != '\0')
    program_name++;
  while (program_name > argv[0] && *(program_name - 1) != '/')
    program_name--;

  while (argc > 2)
    {
      char *p = argv[1];
      char *optarg = argv[2];

      if (*p == '-')
	{
	  switch (*(++p))
	    {
	    case 'f':
	      function_name = optarg;
	      break;

	    case 'n':
	      {
		char *endptr;
		buflen = (unsigned) strtoul (optarg, &endptr, 10);
		if (endptr <= optarg)
		  {
		    fprintf (stderr,
			     "%s: `%s', invalid argument to `-%c'.\n",
			     program_name, optarg, *p);
		    exit (EXIT_FAILURE);
		  }
		break;
	      }

	    default:
	      fprintf (stderr, "%s: `-%s', unknown flag.\n", program_name, p);
	      exit (EXIT_FAILURE);
	    }
	}
      else
	{
	  /* start of arguments proper... */
	  break;
	}

      argc -= 2;
      argv += 2;
    }

  /* We need at least a format string... */
  if (argc < 2)
    {
      fprintf (stderr, "%s: format string required.\n", program_name);
      exit (EXIT_FAILURE);
    }

  {
    /* Make sure the function name we have can be mapped to
     * a pointer by the map table...
     */
    API_map_element *element;

    for (element = map_name_to_func; element && element->name; element++)
      if (strcmp (element->name, function_name) == 0)
	break;

    /* ...and complain if it can't. */
    if (element->name == NULL)
      {
	fprintf (stderr, "%s: `%s' is not a valid function name.\n",
		 program_name, function_name);
	exit (EXIT_FAILURE);
      }

    /* ...save the matching function handle if we can. */
    function_handle = element->func;
    stream = element->stream;
  }

  ++argv, --argc, format = argv[0];
  args = (++argv, --argc < 1) ? NULL
    : vector_canonicalize (format, argc, argv_dup (argc, argv));

  /* Call the appropriate function, with the correct args based on
     the cli parameter settings. */
  switch (stream)
    {
    case STREAM_FD:		/* file descriptor */
      count_or_errorcode = (*function_handle) (STDOUT_FILENO, format, args);
      break;
    case STREAM_STDOUT:	/* FILE stream */
      count_or_errorcode = (*function_handle) (format, args);
      break;
    case STREAM_FILE:		/* FILE stream */
      count_or_errorcode = (*function_handle) (stdout, format, args);
      break;
    case STREAM_UNLIMITED_BUFFER:	/* don't use this, use one of the next two */
      buf = snv_new (char, buflen);
      count_or_errorcode = (*function_handle) (buf, format, args);
      break;
    case STREAM_BUFFER:	/* this one prevents buffer overruns */
      buf = snv_new (char, buflen);
      count_or_errorcode = (*function_handle) (buf, buflen, format, args);
      break;
    case STREAM_ALLOC:		/* this one allocates memory for you */
      count_or_errorcode = (*function_handle) (&buf, format, args);
      break;
    case STREAM_NATIVE:	/* STREAM stream */
      {
	char *pbuf;
	STREAM *out;
	pbuf = buf = snv_new (char, buflen);
	out = stream_new (&pbuf, buflen, NULL, snv_bufputc);
	count_or_errorcode = (*function_handle) (out, format, args);
	stream_delete (out);
	break;
      }
    case STREAM_FILAMENT:	/* homebrew */
      {
	Filament *fil = filnew (NULL, 0);
	count_or_errorcode = (*function_handle) (fil, format, args);
	buf = fildelete (fil);	/* recycle and convert to char* all-in-one */
	break;
      }
    case STREAM_COUNT:		/* this one simply counts the output size */
      count_or_errorcode = (*function_handle) (NULL, format, args);
      break;
    default:
      fprintf (stderr, "Internal error!\n");
      abort ();
      break;
    }

  /* Pretty print the results. */
  if (buf)
    {
      int count = 0;
      while (count < MIN (buflen, count_or_errorcode) && buf[count] != '\0')
	putchar ((int) buf[count++]);

      /* snv_delete(buf); SEGVs HPsUX =(O| */
    }

  check_failure (function_name, count_or_errorcode);

  printf ("\n*** %s returned %d chars.\n", function_name, count_or_errorcode);

  return EXIT_SUCCESS;
}

/* snprintfv-test.c ends here */
