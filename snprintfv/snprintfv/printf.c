/*  -*- Mode: C -*-  */

/* printf.c --- printf clone for argv arrays
 * Copyright (C) 1998, 1999, 2000, 2002, 2009 Gary V. Vaughan
 * Originally by Gary V. Vaughan, 1998
 * This file is part of Snprintfv
 *
 * Snprintfv is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * Snprintfv program is distributed in the hope that it will be useful,
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
#  include <config.h>
#endif

#include <unistd.h>		/* for the write(2) call */

#define COMPILING_PRINTF_C
#include "printf.h"

#ifdef WITH_DMALLOC
#include <dmalloc.h>
#endif

#include "filament.h"
#include "stream.h"
#include "mem.h"

#define EOS			'\0'
#define SNV_CHAR_SPEC		'%'
#define SNV_ESC_SPEC		'\\'

/* Functions to manage mapping of spec chars to handlers. */
SNV_INLINE unsigned spec_hash (unsigned spec);
SNV_INLINE void spec_init (void);
SNV_INLINE spec_entry *spec_lookup (unsigned spec);
static void spec_insert (spec_entry * pentry);
static int do_printfv (STREAM *stream, const char *format, union printf_arg const args[]);

/* FIXME:  We are assuming an ASCII character set where all the
           printable characters are between SPACE and DEL. */
#define ASCII_DEL	(int)'\177'
#define ASCII_SPACE	(int)' '

#define IS_MODIFIER(spec)  (!((spec)->fmt))

/* TODO:  This is not thread-safe.  Change the API to pass the spec_table
          in as the first parameter to the functions which use it? */
static spec_entry *spec_table[ASCII_DEL - ASCII_SPACE];

/* TODO:  This is not thread-safe as well. */
static char *printf_last_error;

SNV_INLINE unsigned
spec_hash (unsigned spec)
{
  return (spec & ASCII_DEL) - ASCII_SPACE;
}

/* Register all of the functions in INIT_SPEC_TABLE. */
static void
spec_init (void)
{
  static boolean is_init = FALSE;

  if (!is_init)
    {
      extern spec_entry snv_default_spec_table[];
      unsigned index = 0;

      memset (spec_table, 0, sizeof (spec_table));
      while (snv_default_spec_table[index].spec != EOS)
	{
	  unsigned hash = spec_hash (snv_default_spec_table[index].spec);
	  spec_table[hash] = snv_default_spec_table + index;
	  index++;
	}

      is_init = TRUE;
    }
}

/* Insert PENTRY, a new handler, into SPEC_TABLE. */
SNV_INLINE void
spec_insert (spec_entry *pentry)
{
  unsigned hash = spec_hash (pentry->spec);
  spec_init ();
  spec_table[hash] = pentry;
}

/* Lookup and return the SPEC_TABLE entry for SPEC. */
SNV_INLINE spec_entry *
spec_lookup (unsigned spec)
{
  unsigned hash = spec_hash (spec);
  spec_init ();
  return spec_table[hash];
}

/**
 * register_printf_function: printf.h
 * @spec: the character which will trigger @func, cast to an unsigned int.
 * @fmt: the handler function to actually print the arguments to the specifier
 * @arg: the handler function to tell %printf about the types of the arguments to the specifier
 * 
 * Register the pair made of @fmt and @arg, so that it is called
 * when @spec is encountered in a format string.
 * 
 * Return value:
 * Returns %NULL if @func was not successfully registered, a
 * %spec_entry with the information on the function if it was.
 **/
spec_entry *
register_printf_function (unsigned spec, printf_function *fmt, printf_arginfo_function *arg)
{
  spec_entry *new, *old;
  old = spec_lookup (spec);
  if (old && IS_MODIFIER (old))
    return NULL;

  if (!fmt || !spec)
    return NULL;

  new = snv_new (spec_entry, 1);
  new->spec = spec;
  new->fmt = fmt;
  new->arg = arg;
  new->user = NULL;

  spec_insert (new);

  return new;
}

static int
call_argtype_function (struct printf_info *const pinfo, int **argtypes, spec_entry *spec)
{
  int n;
  int argindex = (pinfo->dollar && !IS_MODIFIER (spec))
         ? pinfo->dollar - 1
         : pinfo->argindex;

  int save_argindex = pinfo->argindex;
  int save_state = pinfo->state;
  char const *save_format = pinfo->format;

  if (!spec->arg)
    {
      n = 1;
      if (pinfo->argc <= argindex)
        {
	  /*
	   *  "argtypes" points to a pointer of an array of int values.
	   *  Here, we ensure that there are "argindex + 1" entries in
	   *  that array.
	   */
          *argtypes = snv_renew (int, *argtypes, argindex + 1);

	  /*
	   *  IF there are more entries that follow the current argument
	   *  index, then we will clobber all the entries that follow.
	   *  The size of these entries is the size of the array elements,
	   *  not the size of the pointer to the array elements.
	   */
          if (pinfo->argc < argindex)
            memset(*argtypes + pinfo->argc, PA_UNKNOWN,
                   (argindex - pinfo->argc) * sizeof(**argtypes));

          pinfo->argc = argindex + 1;
        }

      (*argtypes) [argindex] = spec->type;
    }

  else
    {
      pinfo->spec = *pinfo->format;
      pinfo->extra = spec->user;
      pinfo->type = spec->type;

      if (pinfo->argc > argindex)
        n = spec->arg(pinfo, (size_t) (pinfo->argc - argindex),
		      *argtypes + argindex);
      else
        n = spec->arg(pinfo, (size_t) 0, NULL);

      if (n < 0)
	return n;
      if (argindex + n > pinfo->argc)
        {
          int new_ct = argindex + n;
	  *argtypes = snv_renew (int, *argtypes, new_ct);
          memset(*argtypes + pinfo->argc, PA_UNKNOWN,
                 (new_ct - pinfo->argc) * sizeof(**argtypes));
	  pinfo->argc = argindex + n;
	  /* Call again... */
	  pinfo->argindex = save_argindex;
	  pinfo->format = save_format;
	  pinfo->state = save_state;
          pinfo->spec = *pinfo->format;
          pinfo->extra = spec->user;
          pinfo->type = spec->type;
          n = spec->arg(pinfo, (size_t)n, *argtypes + argindex);
	}
    }

  if (!pinfo->dollar && !IS_MODIFIER (spec))
    pinfo->argindex += n;

  return n;
}


/**
 * printf_strerror: printf.h
 *
 * Communicate information on the last error in a printf
 * format string.
 *
 * Return value:
 * A string describing the last error which occurred during the
 * parsing of a printf format string.  It is the responsibility
 * of the caller to free the string.
 */
char *
printf_strerror (void)
{
  return snv_strdup(printf_last_error);
}

/* (re)initialise the memory used by PPARSER. */
static inline void
parser_init (struct printf_info *pinfo, const char *format, const union printf_arg *args)
{
  memset (pinfo, 0, sizeof (struct printf_info));
  pinfo->format = format;
  pinfo->args = args;
}

static inline struct printf_info *
parser_reset (struct printf_info *pinfo)
{
  pinfo->is_long_double = pinfo->is_char = pinfo->is_short =
    pinfo->is_long = pinfo->alt = pinfo->space = pinfo->left =
    pinfo->showsign = pinfo->group = pinfo->wide = 
    pinfo->width = pinfo->spec = 0;

  pinfo->state = SNV_STATE_BEGIN;
  pinfo->prec = -1;
  pinfo->dollar = 0;
  pinfo->pad = ' ';

  return pinfo;
}


/**
 * printf_error: printf.h
 * @pinfo: pointer to the current parser state.
 * @file: file where error was detected.
 * @line: line where error was detected.
 * @func1: " (" if function is supplied by compiler.
 * @func2: function where error was detected, if supplied by compiler.
 * @func3: ")" if function is supplied by compiler.
 * @error_message: new error message to append to @pinfo.
 * 
 * The contents of @error_message are appended to the @pinfo internal
 * error string, so it is safe to pass static strings or recycle the
 * original when this function returns.
 * 
 * Return value:
 * The address of the full accumulated error message in @pinfo is
 * returned.
 **/
char *
printf_error (struct printf_info *pinfo, const char *file, int line, const char *func1, const char *func2, const char *func3, const char *error_message)
{
  int i;
  char *result;
  if (pinfo->error == NULL)
    pinfo->error = filnew (NULL, 0);
  else
    filccat (pinfo->error, '\n');

  /* Cannot use printf because a bug in it might trigger another
     printf_error! */
  result = filcat (pinfo->error, "file ");
  filcat (pinfo->error, file);
  filcat (pinfo->error, ": line ");
  for (i = 10; i <= line; i *= 10);
  for (i /= 10; i >= 1; i /= 10)
    filccat (pinfo->error, '0' + (line / i) % 10);

  filcat (pinfo->error, func1);
  filcat (pinfo->error, func2);
  filcat (pinfo->error, func3);
  filcat (pinfo->error, ": ");
  filcat (pinfo->error, error_message);
  return result;
}



/**
 * parse_printf_format: printf.h
 * @format: a % delimited format string.
 * @n: the size of the @argtypes vector
 * @argtypes: a vector of ints, to be filled with the argument types from @format
 * 
 * Returns information about the number and types of
 * arguments expected by the template string @format.
 * The argument @n specifies the number of elements in the array
 * @argtypes.  This is the maximum number of elements that
 * the function will try to write.
 *
 * Return value:
 * The total number of arguments required by @format.  If this
 * number is greater than @n, then the information returned
 * describes only the first @n arguments.  If you want information
 * about additional arguments, allocate a bigger array and call
 * this function again. If there is an error, then %SNV_ERROR
 * is returned instead.
 **/
size_t
parse_printf_format (const char *format, int n, int *argtypes)
{
  struct printf_info info;

  return_val_if_fail (format != NULL, -1);

  parser_init (&info, format, NULL);

  while (*info.format != EOS)
    {
      int ch = (int) *info.format++;

      switch (ch)
	{
	case SNV_CHAR_SPEC:
	  if (*info.format != SNV_CHAR_SPEC)
	    {
	      /* We found the start of a format specifier! */
	      spec_entry *spec;
	      int status;
	      int argindex;

	      parser_reset (&info);
	      do
		{
		  /* Until we fill the stream (or get some other
		     exception) or one of the handlers tells us
		     we have reached the end of the specifier... */

		  /* ...lookup the handler associated with the char
		     we are looking at in the format string... */
		  spec = spec_lookup (*info.format);
		  if (spec == NULL)
		    {
		      PRINTF_ERROR (&info, "unregistered specifier");
		      goto error;
		    }

		  if (!IS_MODIFIER (spec) &&
		      !(info.state & (SNV_STATE_BEGIN | SNV_STATE_SPECIFIER)))
		    {
		      PRINTF_ERROR (&info, "invalid combination of flags");
		      goto error;
		    }

	          argindex = info.dollar && !IS_MODIFIER (spec)
			       ? info.dollar - 1 : info.argindex;

		  /* ...and call the relevant handler.  */
		  if (spec->arg)
		    {
		      info.spec = *info.format;
		      info.extra = spec->user;
		      info.type = spec->type;
		      status = (*spec->arg) (&info, (size_t) (n - argindex),
					     argtypes + argindex);
		    }
		  else
		    {
		      status = 1;
		      if (n > argindex)
			argtypes[argindex] = spec->type;
		    }

		  if (status < 0)
		    goto error;

		  info.argc = MAX (info.argc, argindex + status);
		  if (!info.dollar && !IS_MODIFIER (spec))
		    info.argindex += status;

		  info.format++;
		}
	      while (IS_MODIFIER (spec));
	      continue;
	    }

	  /* An escaped CHAR_SPEC: ignore it (by falling through). */
	  ++info.format;

	  /*NOBREAK*/

        default:	/* Just a character: ignore it. */
	  continue;
	}
     
    error: 
      /* Get here on error */ 
      info.argc = -1;
      break;
    }

  if (printf_last_error)
    snv_delete (printf_last_error);

  if (info.error)
    printf_last_error = fildelete (info.error);
  else
    printf_last_error = NULL;

  return info.argc;
}

int
do_printfv (STREAM *stream, const char *format, union printf_arg const args[])
{
  struct printf_info info;

  /* This is the parser driver.

     Here we scan through the format string and move bytes into the
     stream and call handlers based on the parser state. */

  parser_init (&info, format, args);

  /* Keep going until the format string runs out! */
  while (*info.format != EOS)
    {
      int ch = (int) *info.format++;

      switch (ch)
	{
	case SNV_CHAR_SPEC:
	  if (*info.format != SNV_CHAR_SPEC)
	    {
	      /* We found the start of a format specifier! */
	      spec_entry *spec;
	      int status, argindex;

	      parser_reset (&info);
	      do
		{
		  /* Until we fill the stream (or get some other
		     exception) or one of the handlers tells us
		     we have reached the end of the specifier... */

		  /* ...lookup the handler associated with the char
		     we are looking at in the format string... */
		  spec = spec_lookup (*info.format);
		  if (spec == NULL)
		    {
		      PRINTF_ERROR (&info, "unregistered specifier");
		      goto error;
		    }

		  if (!IS_MODIFIER (spec) &&
		      !(info.state & (SNV_STATE_BEGIN | SNV_STATE_SPECIFIER)))
		    {
		      PRINTF_ERROR (&info, "invalid combination of flags");
		      goto error;
		    }

		  /* ...and call the relevant handler. */
		  info.spec = *info.format;
		  info.extra = spec->user;
		  info.type = spec->type;

		  status = spec->arg ? (*spec->arg) (&info, (size_t)0, NULL) : 1;

		  if (status < 0)
		    goto error;

		  argindex = info.dollar && !IS_MODIFIER (spec)
		    ? info.dollar - 1 : info.argindex;

		  info.format++;
		  info.argc = MAX (info.argc, argindex + status);
		  if (!info.dollar && !IS_MODIFIER (spec))
		    info.argindex += status;
		}
	      while (info.count >= 0 && IS_MODIFIER (spec));

	      status = (*spec->fmt) (stream, &info, args + argindex);

	      if (status < 0)
	        goto error;

	      info.count += status;
	      continue;
	    }

	  /* An escaped CHAR_SPEC: ignore it (by falling through). */
	  ++info.format;

	  /*NOBREAK*/

        default:	/* Just a character: ignore it. */
          /* Just a character: copy it. */
	  SNV_EMIT (ch, stream, info.count);
	  continue;
        }
 
    error: 
      /* Get here on error */ 
      info.count = -1;
      break;
    }

  if (printf_last_error)
    snv_delete (printf_last_error);

  if (info.error)
    printf_last_error = fildelete (info.error);
  else
    printf_last_error = NULL;

  return info.count;
}

/**
 * stream_printfv: printf.h
 * @stream: an initialised stream structure.
 * @format: a % delimited format string.
 * @args: a vector of argument addresses to match @format.
 * 
 * Format the elements of @args according to @format, and write
 * the results to @stream.  If @stream is %NULL, only count the
 * number of characters needed to output the format.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
stream_printfv (STREAM *stream, const char *format, snv_constpointer const *ap)
{
  union printf_arg *args;
  struct printf_info info;
  int count_or_errorcode;
  int *argtypes = NULL;

  return_val_if_fail (format != NULL, SNV_ERROR);

  parser_init (&info, format, NULL);
  while (*info.format != EOS)
    {
      int ch = (int) *info.format++;

      switch (ch)
       {
       case SNV_CHAR_SPEC:
         if (*info.format != SNV_CHAR_SPEC)
           {
             /* We found the start of a format specifier! */
             spec_entry *spec;

             parser_reset (&info);
             do
               {
                 /* Until we fill the stream (or get some other
                    exception) or one of the handlers tells us
                    we have reached the end of the specifier... */
                 /* ...lookup the handler associated with the char
                    we are looking at in the format string... */
                 spec = spec_lookup (*info.format);
                 if (spec == NULL)
                   {
                     PRINTF_ERROR (&info, "unregistered specifier");
                     goto error;
                   }

                 if (!IS_MODIFIER (spec) &&
                     !(info.state & (SNV_STATE_BEGIN | SNV_STATE_SPECIFIER)))
                   {
                     PRINTF_ERROR (&info, "invalid combination of flags");
                     goto error;
                   }

                 /* ...and call the relevant handler.  */
                 if (call_argtype_function (&info, &argtypes, spec) < 0)
                   goto error;

                 info.format++;
               }
             while (info.count >= 0 && IS_MODIFIER (spec));
             continue;
           }
         /* An escaped CHAR_SPEC: ignore it (by falling through). */
         ++info.format;

         /*NOBREAK*/

        default:       /* Just a character: ignore it. */
         continue;
       }

    error:
      /* Get here on error */
      info.argc = -1;
      break;
    }

  if (info.argc > 0)
    {
      int index;

      args = snv_new (union printf_arg, info.argc);

      /* We scanned the format string to find the type of the arguments,
         so we can now cast it and store it correctly.  */
      for (index = 0; index < info.argc; index++)
        {
          int tp = argtypes[index];
          if ((tp & PA_TYPE_MASK) == PA_TYPE_MASK)
            {
              if (index + 1 == info.argc)
                info.argc--;
              else
                continue;
            }

          switch (tp & ~PA_FLAG_UNSIGNED)
         {
          case PA_CHAR:
           args[index].pa_char = (char) *(const long int *)(ap + index);
            break;

          case PA_WCHAR:
              args[index].pa_wchar =
                (snv_wchar_t) *(const long int *)(ap + index);
            break;

          case PA_INT|PA_FLAG_SHORT:
              args[index].pa_short_int =
                (short int) *(const long int *)(ap + index);
            break;

          case PA_INT:
           args[index].pa_int = (int) *(const long int *)(ap + index);
            break;

          case PA_INT|PA_FLAG_LONG:
           args[index].pa_long_int = *(const long int *)(ap + index);
            break;

          case PA_INT|PA_FLAG_LONG_LONG:
           args[index].pa_long_long_int = **(const intmax_t **)(ap + index);
            break;

          case PA_FLOAT:
           args[index].pa_float = **(const float **)(ap + index);
            break;

          case PA_DOUBLE|PA_FLAG_LONG_DOUBLE:
#ifdef HAVE_LONG_DOUBLE
           args[index].pa_long_double = **(const long double **)(ap + index);
            break;
#endif
           /* else fall through */

          case PA_DOUBLE:
           args[index].pa_double = **(const double **)(ap + index);
            break;

         /* Note that pointer types are dereferenced just once! */
          case PA_STRING:
           args[index].pa_string = *(const char **)(ap + index);
            break;

          case PA_WSTRING:
           args[index].pa_wstring = *(const snv_wchar_t **)(ap + index);
            break;

          case PA_POINTER:
           args[index].pa_pointer = *(snv_constpointer *)(ap + index);
            break;

         default:
            if (argtypes[index] & PA_FLAG_PTR)
              args[index].pa_pointer = *(snv_constpointer *)(ap + index);
            else
              args[index].pa_long_double = 0.0;
            break;
         }
    }
    }

  if (printf_last_error)
    snv_delete (printf_last_error);

  if (info.error)
    printf_last_error = fildelete (info.error);
  else
    printf_last_error = NULL;

  count_or_errorcode = do_printfv (stream, format, args);

  snv_delete (argtypes);
  if (info.argc > 0)
    snv_delete (args);

  return count_or_errorcode;
}


/**
 * stream_vprintf: printf.h
 * @stream: an initialised stream structure.
 * @format: a % delimited format string.
 * @ap: a varargs/stdargs va_list.
 * 
 * Format the elements of @ap according to @format, and write
 * the results to @stream.  If @stream is %NULL, only count the
 * number of characters needed to output the format.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
stream_vprintf (STREAM *stream, const char *format, va_list ap)
{
  union printf_arg *args = NULL;
  struct printf_info info;
  int count_or_errorcode;
  int *argtypes = NULL;

  return_val_if_fail (format != NULL, SNV_ERROR);

  parser_init (&info, format, NULL);
  while (*info.format != EOS)
    {
      int ch = (int) *info.format++;

      switch (ch)
	{
	case SNV_CHAR_SPEC:
	  if (*info.format != SNV_CHAR_SPEC)
	    {
	      /* We found the start of a format specifier! */
	      spec_entry *spec;

	      parser_reset (&info);
	      do
		{
		  /* Until we fill the stream (or get some other
		     exception) or one of the handlers tells us
		     we have reached the end of the specifier... */
		  /* ...lookup the handler associated with the char
		     we are looking at in the format string... */
		  spec = spec_lookup (*info.format);
		  if (spec == NULL)
		    {
		      PRINTF_ERROR (&info, "unregistered specifier");
		      goto error;
		    }

		  if (!IS_MODIFIER (spec) &&
		      !(info.state & (SNV_STATE_BEGIN | SNV_STATE_SPECIFIER)))
		    {
		      PRINTF_ERROR (&info, "invalid combination of flags");
		      goto error;
		    }

		  /* ...and call the relevant handler.  */
		  if (call_argtype_function (&info, &argtypes, spec) < 0)
		    goto error;

		  info.format++;
		}
	      while (info.count >= 0 && IS_MODIFIER (spec));
	      continue;
	    }
	  /* An escaped CHAR_SPEC: ignore it (by falling through). */
	  ++info.format;

	  /*NOBREAK*/

        default:	/* Just a character: ignore it. */
	  continue;
	}
     
    error: 
      /* Get here on error */ 
      info.argc = -1;
      break;
    }

  if (info.argc > 0)
    {
      int index;

      args = snv_new (union printf_arg, info.argc);

      /* Scan the format string to find the type of the argument
         so we can cast it and store it correctly.

         Note that according to the ISO C standards, standard
         type promotion takes place on any variadic arguments as
         they are aligned on the call stack, and so it is these
         promoted types that we must extract with the va_arg()
         macro, or the alignment gets all messed up.

         Thanks to Robert Lipe <robertlipe@usa.net> for explaining all
         this to me. */
      for (index = 0; index < info.argc; index++)
	switch (argtypes[index] & ~PA_FLAG_UNSIGNED)
	  {
          case PA_CHAR:
	    args[index].pa_char = va_arg (ap, int); /* Promoted.  */
            break;

          case PA_WCHAR:
	    args[index].pa_wchar = va_arg (ap, snv_wint_t); /* Promoted.  */
            break;

          case PA_INT|PA_FLAG_SHORT:
	    args[index].pa_short_int = va_arg (ap, int); /* Promoted.  */
            break;

          case PA_INT:
	    args[index].pa_int = va_arg (ap, int);
            break;
  
          case PA_INT|PA_FLAG_LONG:
	    args[index].pa_long_int = va_arg (ap, long int);
            break;

          case PA_INT|PA_FLAG_LONG_LONG:
	    args[index].pa_long_long_int = va_arg (ap, intmax_t);
            break;

          case PA_FLOAT:
	    args[index].pa_float = va_arg (ap, double); /* Promoted.  */
            break;

          case PA_DOUBLE|PA_FLAG_LONG_DOUBLE:
	    args[index].pa_long_double = va_arg (ap, long double);
            break;

          case PA_DOUBLE:
	    args[index].pa_double = va_arg (ap, double);
            break;

          case PA_STRING:
	    args[index].pa_string = va_arg (ap, const char *);
            break;

          case PA_WSTRING:
	    args[index].pa_wstring = va_arg (ap, const snv_wchar_t *);
            break;

          case PA_POINTER:
	    args[index].pa_pointer = va_arg (ap, void *);
            break;

	  default:
            if (argtypes[index] & PA_FLAG_PTR)
              args[index].pa_pointer = va_arg (ap, void *);
            else
              args[index].pa_long_double = 0.0;
            break;
	  }
    }

  if (printf_last_error)
    snv_delete (printf_last_error);

  if (info.error)
    printf_last_error = fildelete (info.error);
  else
    printf_last_error = NULL;

  count_or_errorcode = do_printfv (stream, format, args);

  snv_delete (argtypes);
  snv_delete (args);
  return count_or_errorcode;
}

/**
 * stream_printf: printf.h
 * @stream: an initialised stream structure.
 * @format: a % delimited format string.
 * @va_alist: a varargs/stdargs va_list.
 * 
 * Format the elements of @va_alist according to @format, and write
 * the results to @stream.  If @stream is %NULL, only count the
 * number of characters needed to output the format.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
stream_printf (STREAM * stream, const char *format, ...)
{
  int count_or_errorcode;
  va_list ap;

  va_start (ap, format);
  count_or_errorcode = stream_vprintf (stream, format, ap);
  va_end (ap);

  return count_or_errorcode;
}


/*  Finally... the main API implementation: */

/**
 * snv_fdputc: printf.h
 * @ch: A single character to be added to @stream.
 * @stream: The stream in which to write @ch.
 * 
 * A StreamPut function for use in putting characters
 * into STREAMs holding a file descriptor.
 * 
 * Return value:
 * The value of @ch that has been put in @stream, or -1 in case of
 * an error (errno will be set to indicate the type of error).
 **/
int
snv_fdputc (int ch, STREAM *stream)
{
  static char buf[1] = { 0 };
  buf[0] = (char) ch;
  return write ((int) SNV_POINTER_TO_INT (stream_details (stream)), buf, 1)
	 ? ch : -1;
}

/**
 * snv_dprintf: printf.h
 * @fd: an open file descriptor.
 * @format: a % delimited format string.
 * @va_alist: a varargs/stdargs va_list.
 * 
 * Format the elements of @va_alist according to @format, and write
 * the results to the file descriptor @fd.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
snv_dprintf (int fd, const char *format, ...)
{
  int count_or_errorcode;
  va_list ap;

  va_start (ap, format);
  count_or_errorcode = snv_vdprintf (fd, format, ap);
  va_end (ap);

  return count_or_errorcode;
}

/**
 * snv_vdprintf: printf.h
 * @fd: an open file descriptor.
 * @format: a % delimited format string.
 * @ap: a varargs/stdargs va_list.
 * 
 * Format the elements of @ap according to @format, and write
 * the results to the file descriptor @fd.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
snv_vdprintf (int fd, const char *format, va_list ap)
{
  int result;
  STREAM *out = stream_new (SNV_INT_TO_POINTER (fd),
	       		    SNV_UNLIMITED, NULL, snv_fdputc);

  result = stream_vprintf (out, format, ap);
  stream_delete (out);
  return result;
}

/**
 * snv_dprintfv: printf.h
 * @fd: an open file descriptor.
 * @format: a % delimited format string.
 * @args: a vector of argument addresses to match @format.
 * 
 * Format the elements of @args according to @format, and write
 * the results to file descriptor @fd.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
snv_dprintfv (int fd, const char *format, snv_constpointer const args[])
{
  int result;
  STREAM *out = stream_new (SNV_INT_TO_POINTER (fd),
	       		    SNV_UNLIMITED, NULL, snv_fdputc);

  result = stream_printfv (out, format, args);
  stream_delete (out);
  return result;
}


/**
 * snv_fileputc: printf.h
 * @ch: A single character to be added to @stream.
 * @stream: The stream in which to write @ch.
 * 
 * A StreamPut function for use in putting characters
 * into STREAMs holding a FILE*.
 * 
 * Return value: 
 * The value of @ch that has been put in @stream.
 **/
int
snv_fileputc (int ch, STREAM *stream)
{
  FILE *fp = (FILE *) stream_details (stream);
  return putc (ch, fp);
}

static int
snv_fileputc_unlocked (int ch, STREAM *stream)
{
  FILE *fp = (FILE *) stream_details (stream);
  return SNV_PUTC_UNLOCKED (ch, fp);
}

/**
 * snv_printf: printf.h
 * @format: a % delimited format string.
 * @va_alist: a varargs/stdargs va_list.
 * 
 * Format the elements of @va_alist according to @format, and write
 * the results to the standard output stream.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
snv_printf (const char *format, ...)
{
  int count_or_errorcode;
  va_list ap;

  va_start (ap, format);
  count_or_errorcode = snv_vprintf (format, ap);
  va_end (ap);

  return count_or_errorcode;
}

/**
 * snv_vprintf: printf.h
 * @format: a % delimited format string.
 * @ap: a varargs/stdargs va_list.
 * 
 * Format the elements of @ap according to @format, and write
 * the results to the standard output stream.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
snv_vprintf (const char *format, va_list ap)
{
  int result;
  STREAM *out = stream_new (stdout, SNV_UNLIMITED, NULL, snv_fileputc_unlocked);
  int tmp;

  SNV_WITH_LOCKED_FP (stdout, tmp)
    result = stream_vprintf (out, format, ap);

  stream_delete (out);
  return result;
}

/**
 * snv_printfv: printf.h
 * @format: a % delimited format string.
 * @args: a vector of argument addresses to match @format.
 * 
 * Format the elements of @args according to the string @format,
 * and write the result to the standard output stream.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
snv_printfv (const char *format, snv_constpointer const args[])
{
  int result;
  STREAM *out = stream_new (stdout, SNV_UNLIMITED, NULL, snv_fileputc_unlocked);
  int tmp;

  SNV_WITH_LOCKED_FP (stdout, tmp)
    result = stream_printfv (out, format, args);
  stream_delete (out);
  return result;
}

/**
 * snv_fprintf: printf.h
 * @file: a stdio.h FILE* stream.
 * @format: a % delimited format string.
 * @va_alist: a varargs/stdargs va_list.
 * 
 * Format the elements of @va_alist according to @format, and write
 * the results to the @file stream.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
snv_fprintf (FILE * file, const char *format, ...)
{
  int count_or_errorcode;
  va_list ap;

  va_start (ap, format);
  count_or_errorcode = snv_vfprintf (file, format, ap);
  va_end (ap);

  return count_or_errorcode;
}

/**
 * snv_vfprintf: printf.h
 * @file: a stdio.h FILE* stream.
 * @format: a % delimited format string.
 * @ap: a varargs/stdargs va_list.
 * 
 * Format the elements of @ap according to @format, and write
 * the results to the @file stream.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
snv_vfprintf (FILE *file, const char *format, va_list ap)
{
  int result;
  STREAM *out = stream_new (file, SNV_UNLIMITED, NULL, snv_fileputc_unlocked);
  int tmp;

  SNV_WITH_LOCKED_FP (file, tmp)
    result = stream_vprintf (out, format, ap);
  stream_delete (out);
  return result;
}

/**
 * snv_fprintfv: printf.h
 * @file: a stdio.h FILE* stream.
 * @format: a % delimited format string.
 * @args: a vector of argument addresses to match @format.
 * 
 * Format the elements of @args according to @format, and write
 * the results to @file.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
snv_fprintfv (FILE *file, const char *format, snv_constpointer const args[])
{
  int result;
  STREAM *out = stream_new (file, SNV_UNLIMITED, NULL, snv_fileputc_unlocked);
  int tmp;

  SNV_WITH_LOCKED_FP (file, tmp)
    result = stream_printfv (out, format, args);

  stream_delete (out);
  return result;
}


/**
 * snv_bufputc: printf.h
 * @ch: A single character to be added to @stream.
 * @stream: The stream in which to write @ch.
 * 
 * A StreamPut function for use in putting characters
 * into STREAMs holding a char buffer.
 * 
 * Return value:
 * The value of @ch that has been put in @stream.
 **/
int
snv_bufputc (ch, stream)
     int ch;
     STREAM *stream;
{
  char **ppbuffer = (char **) stream_details (stream);
  **ppbuffer = (char) ch;
  (*ppbuffer)++;
  return ch;
}

/**
 * snv_sprintf: printf.h
 * @buffer: a preallocated char* buffer.
 * @format: a % delimited format string.
 * @va_alist: a varargs/stdargs va_list.
 * 
 * Format the elements of @va_alist according to @format, and write
 * the results to the string @buffer.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
snv_sprintf (char buffer[], const char *format, ...)
{
  int count_or_errorcode;
  va_list ap;

  va_start (ap, format);
  count_or_errorcode = snv_vsprintf (buffer, format, ap);
  va_end (ap);

  return count_or_errorcode;
}

/**
 * snv_vsprintf: printf.h
 * @buffer: a preallocated char* buffer.
 * @format: a % delimited format string.
 * @ap: a varargs/stdargs va_list.
 * 
 * Format the elements of @ap according to @format, and write
 * the results to the string @buffer.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
snv_vsprintf (char buffer[], const char *format, va_list ap)
{
  int count_or_errorcode;
  STREAM *out = stream_new (&buffer, SNV_UNLIMITED, NULL, snv_bufputc);
  count_or_errorcode = stream_vprintf (out, format, ap);

  /* Terminate with an EOS without incrementing the counter. */
  stream_put (EOS, out);

  stream_delete (out);
  return count_or_errorcode;
}

/**
 * snv_sprintfv: printf.h
 * @buffer: a preallocated char* buffer.
 * @format: a % delimited format string.
 * @args: a vector of argument addresses to match @format.
 * 
 * Format the elements of @args according to @format, and write
 * the results to the string @buffer.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
snv_sprintfv (char buffer[], const char *format, snv_constpointer const args[])
{
  int count_or_errorcode;
  STREAM *out = stream_new (&buffer, SNV_UNLIMITED, NULL, snv_bufputc);
  count_or_errorcode = stream_printfv (out, format, args);

  /* Terminate with an EOS without incrementing the counter. */
  stream_put (EOS, out);

  stream_delete (out);
  return count_or_errorcode;
}

/**
 * snv_snprintf: printf.h
 * @buffer: a preallocated char* buffer.
 * @limit: the maximum number of characters to write into @buffer.
 * @format: a % delimited format string.
 * @va_alist: a varargs/stdargs va_list.
 * 
 * Format the elements of @va_alist according to @format, and write
 * the results to the string @buffer, truncating the formatted string
 * if it reaches @limit characters in length.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
snv_snprintf (char buffer[], unsigned long limit, const char *format, ...)
{
  int count_or_errorcode;
  va_list ap;

  va_start (ap, format);
  count_or_errorcode = snv_vsnprintf (buffer, limit, format, ap);
  va_end (ap);

  return count_or_errorcode;
}

/**
 * snv_vsnprintf: printf.h
 * @buffer: a preallocated char* buffer.
 * @limit: the maximum number of characters to write into @buffer.
 * @format: a % delimited format string.
 * @ap: a varargs/stdargs va_list.
 * 
 * Format the elements of @ap according to @format, and write
 * the results to the string @buffer, truncating the formatted string
 * if it reaches @limit characters in length.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
snv_vsnprintf (char buffer[], unsigned long limit, const char *format, va_list ap)
{
  int count_or_errorcode;
  STREAM *out = stream_new (&buffer, limit - 1, NULL, snv_bufputc);
  count_or_errorcode = stream_vprintf (out, format, ap);
  *buffer = EOS;

  stream_delete (out);
  return count_or_errorcode;
}

/**
 * snv_snprintfv: printf.h
 * @buffer: a preallocated char* buffer.
 * @limit: the maximum number of characters to write into @buffer.
 * @format: a % delimited format string.
 * @args: a vector of argument addresses to match @format.
 * 
 * Format the elements of @args according to @format, and write
 * the results to the string @buffer, truncating the formatted string
 * if it reaches @limit characters in length.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
snv_snprintfv (char buffer[], unsigned long limit, const char *format, snv_constpointer const args[])
{
  int count_or_errorcode;
  STREAM *out = stream_new (&buffer, limit - 1, NULL, snv_bufputc);
  count_or_errorcode = stream_printfv (out, format, args);
  *buffer = EOS;

  stream_delete (out);
  return count_or_errorcode;
}


/**
 * snv_filputc: printf.h
 * @ch: A single character to be added to @stream.
 * @stream: The stream in which to write @ch.
 * 
 * A StreamPut function for use in putting characters
 * into STREAMs holding a Filament*.
 * 
 * Return value: 
 * The value of @ch that has been put in @stream.
 **/
int
snv_filputc (ch, stream)
     int ch;
     STREAM *stream;
{
  return filccat ((Filament *) stream_details (stream), ch), ch;
}

/**
 * snv_asprintf: printf.h
 * @result: the address of a char * variable.
 * @format: a % delimited format string.
 * @va_alist: a varargs/stdargs va_list.
 * 
 * Format the elements of @va_alist according to @format, and write
 * the results to an internally allocated buffer whose address is
 * stored in @result (and should be freed by the caller) unless
 * there is an error.
 *
 * Yes, this interface is cumbersome and totally useless.  It would
 * have been better to simply return the allocated address, but
 * it turns out that somebody wasn't thinking much when adding 
 * asprintf to libiberty a few years ago.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
snv_asprintf (char **result, const char *format, ...)
{
  int count;
  va_list ap;

  va_start (ap, format);
  count = snv_vasprintf (result, format, ap);
  va_end (ap);

  return count;
}

/**
 * snv_vasprintf: printf.h
 * @result: the address of a char * variable.
 * @format: a % delimited format string.
 * @ap: a varargs/stdargs va_list.
 * 
 * Format the elements of @ap according to @format, and write
 * the results to an internally allocated buffer whose address is
 * stored in @result (and should be freed by the caller) unless
 * there is an error.
 * 
 * Above moaning for asprintf applies here too.
 *
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
snv_vasprintf (char **result, const char *format, va_list ap)
{
  int count_or_errorcode;
  char *base;
  Filament *fil = filnew (NULL, 0);
  STREAM *out = stream_new (fil, SNV_UNLIMITED, NULL, snv_filputc);
  count_or_errorcode = stream_vprintf (out, format, ap);

  base = fildelete (fil);
  stream_delete (out);

  *result = (count_or_errorcode < 0) ? NULL : base;
  return count_or_errorcode;
}

/**
 * snv_asprintfv: printf.h
 * @result: the address of a char * variable.
 * @format: a % delimited format string.
 * @args: a vector of argument addresses to match @format.
 * 
 * Format the elements of @args according to @format, and write
 * the results to an internally allocated buffer whose address is
 * stored in @result (and should be freed by the caller) unless
 * there is an error.
 * 
 * Above moaning for asprintf applies here too.
 * 
 * Return value:
 * The number of characters written is returned, unless there is
 * an error, when %SNV_ERROR is returned.
 **/
int
snv_asprintfv (char **result, const char *format, snv_constpointer const args[])
{
  int count_or_errorcode;
  char *base;
  Filament *fil = filnew (NULL, 0);
  STREAM *out = stream_new (fil, SNV_UNLIMITED, NULL, snv_filputc);
  count_or_errorcode = stream_printfv (out, format, args);

  base = fildelete (fil);
  stream_delete (out);

  *result = (count_or_errorcode < 0) ? NULL : base;
  return count_or_errorcode;
}

/* snprintfv.c ends here */
