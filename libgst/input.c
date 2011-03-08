/******************************** -*- C -*- ****************************
 *
 *	Input module: stream interface and Readline completion handling
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2001, 2002, 2003, 2005, 2006, 2008, 2009
 * Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
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

#ifdef HAVE_READLINE
# include <readline/readline.h>
# include <readline/history.h>
#endif

typedef struct gst_file_segment
{
  OBJ_HEADER;
  OOP fileOOP;
  OOP startPos;
  OOP length;
}
 *gst_file_segment;

typedef struct string_stream
{
  char *strBase;		/* base of asciz string */
  const char *str;		/* pointer into asciz string */
}
string_stream;

typedef struct unix_file_stream
{
  int fd;
  char *buf;
  const char *ptr;
  const char *end;
}
unix_file_stream;

typedef struct oop_stream
{
  OOP  oop;
  char *buf;
  char *ptr;
  const char *end;
}
oop_stream;

typedef struct input_stream
{
  stream_type type;
  /* the 3 buffered characters */
  char pushedBackChars[3];

  /* number of chars pushed back */
  int pushedBackCount;

  int line;
  int column;
  const char *prompt;

  OOP fileOOP;			/* the object stored in FileSegments */
  const char *fileName;
  off_t fileOffset;

  union
  {
    unix_file_stream u_st_file;
    string_stream u_st_str;
    oop_stream u_st_oop;
  }
  st;
  struct input_stream *prevStream;
}
 *input_stream;

#define st_file		st.u_st_file
#define st_str		st.u_st_str
#define st_oop		st.u_st_oop

/* The internal interface used by _gst_next_char.  */
static int my_getc (input_stream stream);

/* Return the File object or a file name for the topmost stream in the stack
   if it is of type STREAM_FILE; nil otherwise.  */
static OOP get_cur_file (void);

/* Print a line indicator in front of an error message.  */
static void line_stamp (int line);

/* Allocate and push a new stream of type TYPE on the stack; the new
   stream is then available through IN_STREAM.  */
static input_stream push_new_stream (stream_type type);

/* The topmost stream in the stack, and the head of the linked list
   that implements the stack.  */
static input_stream in_stream = NULL;

/* Poll FD until it is available for input (or until it returns
   POLLHUP) and then perform a read system call.  */
static int poll_and_read (int fd, char *buf, int n);


/* If true, readline is disabled.  */
mst_Boolean _gst_no_tty = false;

/* >= 1 if completions are enabled, < 1 if they are not.  Available
   for completeness even if Readline is not used.  */
static int completions_enabled = 1;


#ifdef HAVE_READLINE
/* Storage for the possible completions */
static char **completions;

/* Number of completions available.  */
static int count;

/* Number of completions before the array must be resized.  */
static int free_items;

/* Number of sorted completions.  Completions are not sorted until
   we are requested to use them.  */
static int sorted_count;

/* Internal functions */
static void merge (char **a1,
		   int count1,
		   char **a2,
		   int count2,
		   mst_Boolean reallocate);

static void add_completion (const char *str,
			    int len);
static int compare_strings (const PTR a,
			    const PTR b);

/* Readline callbacks */
static int readline_getc (FILE * file);

static char *readline_quote_filename (const char *s,
				      int rtype,
				      const char *qcp);
static char *readline_dequote_filename (const char *s,
					char qc);
static char *symbol_generator (const char *text,
				 int state);
static char **readline_match_symbols (char *text,
				      int start,
				      int end);

#endif


/* Generic "stream" interface.  A stream is an abstraction for input
   and output.  It is most like common lisp streams.  Basically, these
   streams provide transparent reading from either a Smalltalk string,
   or a UNIX file.  They stack, and the previous stream can be
   restored by doing a "_gst_pop_stream" which optionally "closes" the
   current stream and goes back to using the previous stream.

   The `readline()' interface: The behavior is like the Smalltalk
   String interface.  The end-of-string or a NULL strBase-pointer
   decides to read in a new line.  The prompt is still shown by the
   readline() call.  */

void
_gst_pop_stream (mst_Boolean closeIt)
{
  input_stream stream;

  stream = in_stream;
  in_stream = in_stream->prevStream;
  _gst_unregister_oop (stream->fileOOP);

  switch (stream->type)
    {
    case STREAM_STRING:
      xfree (stream->st_str.strBase);
      break;

#ifdef HAVE_READLINE
    case STREAM_READLINE:
#endif /* HAVE_READLINE */
    case STREAM_OOP:
      xfree (stream->st_oop.buf);
      _gst_unregister_oop (stream->st_oop.oop);
      break;

    case STREAM_FILE:
      xfree (stream->st_file.buf);
      if (closeIt)
        close (stream->st_file.fd);
      break;
    }

  xfree (stream);
}

void
_gst_push_unix_file (int fd,
		     const char *fileName)
{
  input_stream newStream;

  newStream = push_new_stream (STREAM_FILE);
  newStream->st_file.fd = fd;
  newStream->st_file.buf = xmalloc (1024);
  newStream->st_file.ptr = newStream->st_file.buf;
  newStream->st_file.end = newStream->st_file.buf;
  newStream->fileName = fileName;
  newStream->fileOffset = lseek (fd, 0, SEEK_CUR);
}

void
_gst_push_stream_oop (OOP oop)
{
  input_stream newStream;

  newStream = push_new_stream (STREAM_OOP);
  newStream->st_oop.oop = oop;
  newStream->st_oop.buf = NULL;
  newStream->st_oop.ptr = NULL;
  newStream->st_oop.end = NULL;
  newStream->fileName = "a Smalltalk Stream";

  _gst_register_oop (oop);
}

void
_gst_push_smalltalk_string (OOP stringOOP)
{
  input_stream newStream;

  newStream = push_new_stream (STREAM_STRING);

  newStream->st_str.strBase = (char *) _gst_to_cstring (stringOOP);
  newStream->st_str.str = newStream->st_str.strBase;
  newStream->fileName = "a Smalltalk string";
}

void
_gst_push_cstring (const char *string)
{
  input_stream newStream;

  newStream = push_new_stream (STREAM_STRING);

  newStream->st_str.strBase = xstrdup (string);
  newStream->st_str.str = newStream->st_str.strBase;
  newStream->fileName = "a C string";
}

void
_gst_push_stdin_string (void)
{
#ifdef HAVE_READLINE
  input_stream newStream;

  if (_gst_no_tty)
    {
#endif
      _gst_push_unix_file (0, "stdin");
      return;
#ifdef HAVE_READLINE
    }

  if (count == 0)
    _gst_add_all_symbol_completions ();

  newStream = push_new_stream (STREAM_READLINE);
  newStream->fileOffset = 0;
  newStream->st_oop.buf = NULL;
  newStream->st_oop.ptr = NULL;
  newStream->st_oop.end = NULL;
  newStream->fileName = "stdin";	/* that's where we get input from */
#endif
}

input_stream
push_new_stream (stream_type type)
{
  input_stream newStream;

  newStream = (input_stream) xmalloc (sizeof (struct input_stream));

  newStream->pushedBackCount = 0;
  newStream->line = 1;
  newStream->column = 0;
  newStream->fileOffset = -1;
  newStream->type = type;
  newStream->fileName = NULL;
  newStream->prompt = NULL;
  newStream->fileOOP = _gst_nil_oop;
  newStream->prevStream = in_stream;
  in_stream = newStream;
  return (newStream);
}


void
_gst_set_stream_info (int line,
		      OOP fileOOP,
		      OOP fileNameOOP,
		      int fileOffset)
{
  in_stream->line = line;
  in_stream->column = 0;

  _gst_register_oop (fileOOP);
  in_stream->fileOOP = fileOOP;
  in_stream->fileOffset = fileOffset;

  if (!IS_NIL (fileNameOOP))
    in_stream->fileName = _gst_to_cstring (fileNameOOP);
}
 
void
refill_stream (input_stream stream, char *buf, int new_line)
{
  size_t old_size = stream->st_oop.ptr - stream->st_oop.buf;
  size_t size = old_size + strlen (buf);

  /* Leave space for the '\0' at the end.  */
  stream->st_oop.buf = xrealloc (stream->st_oop.buf, size + new_line + 1);
  stream->st_oop.ptr = stream->st_oop.buf + old_size;
  stream->st_oop.end = stream->st_oop.buf + size + new_line;

  memcpy (stream->st_oop.ptr, buf, size - old_size);
  if (new_line)
    {
      stream->st_oop.ptr[size - old_size] = '\n';
      stream->st_oop.ptr[size - old_size + 1] = '\0';
    }
  else
    stream->st_oop.ptr[size - old_size] = '\0';

  free (buf);
}

int
my_getc (input_stream stream)
{
  int ic = 0;

  switch (stream->type)
    {
    case STREAM_STRING:
      ic = (unsigned char) *stream->st_str.str;
      if (!ic)
	return EOF;
      else
	stream->st_str.str++;

      return ic;

    case STREAM_OOP:
      /* Refill the buffer...  */
      if (stream->st_oop.ptr == stream->st_oop.end)
	{
	  char *buf;
	  _gst_msg_sendf(&buf, "%s %o nextAvailable: %i", stream->st_oop.oop, 1024);
	  if (!buf || !*buf)
	    return EOF;

	  refill_stream (stream, buf, false);
	}

      return (unsigned char) *stream->st_oop.ptr++;

    case STREAM_FILE:
      if (in_stream->column == 0 && in_stream->prompt)
	{
	  printf ("%s", in_stream->prompt);
	  fflush(stdout);
	}

      /* Refill the buffer...  */
      if (stream->st_file.ptr == stream->st_file.end)
	{
	  int n = poll_and_read (stream->st_file.fd, stream->st_file.buf, 1024);
	  if (n < 0)
	    n = 0;

	  stream->fileOffset += stream->st_file.ptr - stream->st_file.buf;
	  stream->st_file.end = stream->st_file.buf + n;
	  stream->st_file.ptr = stream->st_file.buf;
	}

      return (stream->st_file.ptr == stream->st_file.end)
	? EOF : (unsigned char) *stream->st_file.ptr++;

#ifdef HAVE_READLINE
    case STREAM_READLINE:
      /* Refill the buffer...  */
      if (stream->st_oop.ptr == stream->st_oop.end)
	{
	  char *buf = readline (in_stream->prompt
				? (char *) in_stream->prompt
				: (char *) "");
	  if (!buf)
	    return EOF;

	  add_history (buf);
	  refill_stream (stream, buf, true);
	}

      return (unsigned char) *stream->st_oop.ptr++;
#endif /* HAVE_READLINE */

    default:
      _gst_errorf ("Bad stream type passed to my_getc");
      _gst_had_error = true;
    }
  return (ic);
}


mst_Boolean
_gst_get_cur_stream_prompt (void)
{
  return in_stream && in_stream->prompt;
}

stream_type
_gst_get_cur_stream_type (void)
{
  if (in_stream)
    return (in_stream->type);

  else
    return (STREAM_UNKNOWN);
}

OOP
_gst_get_source_string (off_t startPos, off_t endPos)
{
  char *p;
  OOP result;
  int size;

  if (!in_stream)
    return (_gst_nil_oop);

  /* FIXME: check isPipe too? */
  if (startPos != -1 && !_gst_get_cur_stream_prompt ())
    {
      OOP fileOOP;
      gst_file_segment fileSegment;
      inc_ptr incPtr;

      incPtr = INC_SAVE_POINTER ();
      fileOOP = get_cur_file ();

      if (!IS_NIL (fileOOP))
	{
          INC_ADD_OOP (fileOOP);
          fileSegment = (gst_file_segment) new_instance (_gst_file_segment_class,
                                                         &result);

          fileSegment->fileOOP = fileOOP;
          fileSegment->startPos = from_c_int_64 (startPos);
          fileSegment->length = from_c_int_64 (endPos - startPos);

          assert (to_c_int_64 (fileSegment->length) >= 0);
          INC_RESTORE_POINTER (incPtr);
          return (result);
	}

      INC_RESTORE_POINTER (incPtr);
    }

  switch (in_stream->type)
    {
    case STREAM_STRING:
      p = in_stream->st_str.strBase;
      break;

#ifdef HAVE_READLINE
    case STREAM_READLINE:
#endif /* HAVE_READLINE */
    case STREAM_OOP:
    case STREAM_FILE:
      p = in_stream->st_oop.buf;
      break;

    default:
      return (_gst_nil_oop);
    }

   if (startPos == -1) 
    result = _gst_string_new (p);
  else
    result = _gst_counted_string_new (p + (startPos - in_stream->fileOffset),
				      endPos - startPos);

  if (in_stream->type != STREAM_STRING)
    {
      /* Copy back to the beginning of the buffer to save memory.  */
      size = in_stream->st_oop.end - in_stream->st_oop.ptr;
      if (size)
	memmove (in_stream->st_oop.buf, in_stream->st_oop.ptr, size);
      in_stream->st_oop.buf[size] = 0;
      in_stream->fileOffset += in_stream->st_oop.ptr - in_stream->st_oop.buf;
      in_stream->st_oop.ptr = in_stream->st_oop.buf;
      in_stream->st_oop.end = in_stream->st_oop.buf + size;
    }

  return result;
}

OOP
get_cur_file (void)
{
  const char *fullFileName;

  if (!in_stream)
    return _gst_nil_oop;

  if (!IS_NIL (in_stream->fileOOP))
    return in_stream->fileOOP;

  if (in_stream->type != STREAM_FILE)
    return (_gst_nil_oop);

  if (strcmp (in_stream->fileName, "stdin") == 0)
    fullFileName = strdup (in_stream->fileName);
  else
    fullFileName =
      _gst_get_full_file_name (in_stream->fileName);

  in_stream->fileOOP = _gst_string_new (fullFileName);
  _gst_register_oop (in_stream->fileOOP);
  return (in_stream->fileOOP);
}



void
_gst_warningf_at (int line,
		const char *str,
	        ...)
{
  va_list ap;

  va_start (ap, str);

  if (!_gst_report_errors)
    return;

  fflush (stdout);
  line_stamp (line);
  vfprintf (stderr, str, ap);
  fprintf (stderr, "\n");
  fflush (stderr);
  va_end (ap);
}

void
_gst_warningf (const char *str,
	       ...)
{
  va_list ap;

  va_start (ap, str);

  if (!_gst_report_errors)
    return;

  fflush (stdout);
  line_stamp (0);
  vfprintf (stderr, str, ap);
  fprintf (stderr, "\n");
  fflush (stderr);
  va_end (ap);
}

void
_gst_errorf_at (int line,
		const char *str,
	        ...)
{
  va_list ap;

  va_start (ap, str);

  if (_gst_report_errors)
    fflush (stdout);

  line_stamp (line);
  if (_gst_report_errors)
    {
      vfprintf (stderr, str, ap);
      fprintf (stderr, "\n");
      fflush (stderr);
    }
  else
    {
      if (_gst_first_error_str == NULL)
	vasprintf (&_gst_first_error_str, str, ap);
    }

  va_end (ap);
}

void
_gst_errorf (const char *str,
	     ...)
{
  va_list ap;

  va_start (ap, str);

  if (_gst_report_errors)
    fflush (stdout);

  line_stamp (0);
  if (_gst_report_errors)
    {
      vfprintf (stderr, str, ap);
      fprintf (stderr, "\n");
      fflush (stderr);
    }
  else
    {
      if (_gst_first_error_str == NULL)
	vasprintf (&_gst_first_error_str, str, ap);
    }

  va_end (ap);
}

void
_gst_yyerror (const char *s)
{
  _gst_errorf ("%s", s);
}

YYLTYPE
_gst_get_location (void)
{
  YYLTYPE loc;
  loc.first_line = in_stream->line;
  loc.first_column = in_stream->column;

  if (!in_stream || in_stream->fileOffset == -1)
    loc.file_offset = -1;
  else
    /* Subtract 1 to mark the position of the last character we read.  */
    loc.file_offset = (in_stream->st_file.ptr - in_stream->st_file.buf
		       + in_stream->fileOffset - 1);

  return loc;
}

void
line_stamp (int line)
{
  if (line <= 0 && in_stream)
    line = in_stream->line;

  if (_gst_report_errors)
    {
      if (in_stream)
	fprintf (stderr, "%s:%d: ", in_stream->fileName, line);
      else
	fprintf (stderr, "gst: ");
    }
  else
    {				/* called internally with error
				   handling */
      if (in_stream)
	{
	  if (in_stream->fileName)
	    {
	      if (_gst_first_error_str == NULL)
		_gst_first_error_file = strdup (in_stream->fileName);
	    }
	  if (_gst_first_error_str == NULL)
	    _gst_first_error_line = line;
	}
      else
	{
	  if (_gst_first_error_str == NULL)
	    _gst_first_error_line = -1;
	}
    }
}


int
_gst_next_char (void)
{
  int ic;

  if (in_stream->pushedBackCount > 0)
    {
      ic = (unsigned char)
	      in_stream->pushedBackChars[--in_stream->pushedBackCount];
      return (ic);
    }
  else
    {
      ic = my_getc (in_stream);
      if (ic == '\n')
	{			/* a new line that was not pushed back */
	  in_stream->line++;
	  in_stream->column = 0;
	}
      else
	in_stream->column++;

      return (ic);
    }
}

void
_gst_unread_char (int ic)
{
  if (ic != EOF)
    in_stream->pushedBackChars[in_stream->pushedBackCount++] = ic;
}



/* These two are not used, but are provided for additional flexibility.  */
void
_gst_enable_completion (void)
{
  completions_enabled++;
}

void
_gst_disable_completion (void)
{
  completions_enabled--;
}

int
poll_and_read (int fd, char *buf, int n)
{
  int result;

  _gst_wait_for_input (fd);
  if (_gst_sync_file_polling (fd, 0))
    {
      do
	{
	  errno = 0;
	  result = _gst_read (fd, buf, n);
	}
      while ((result == -1) && (errno == EINTR));
      return result;
    }
  else
    return -1;
}

void
_gst_process_stdin (const char *prompt)
{
  if (_gst_verbosity == 3 || isatty (0))
    {
      printf ("GNU Smalltalk ready\n\n");
      fflush (stdout);
    }

  _gst_non_interactive = false;
  _gst_push_stdin_string ();
  if (isatty (0))
    in_stream->prompt = prompt;
  _gst_parse_stream (NULL);
  _gst_pop_stream (true);
  _gst_non_interactive = true;
}

mst_Boolean
_gst_process_file (const char *fileName, enum gst_file_dir dir)
{
  int fd;
  char *f;

  f = _gst_find_file (fileName, dir);
  if (!f)
    {
      errno = ENOENT;
      return false;
    }

  errno = 0;
  fd = _gst_open_file (f, "r");
  if (fd != -1)
    {
      if (_gst_verbosity == 3)
	printf ("Processing %s\n", f);

      _gst_push_unix_file (fd, f);
      _gst_parse_stream (NULL);
      _gst_pop_stream (true);
      errno = 0;
    }

  xfree (f);
  return (fd != -1);
}


#ifdef HAVE_READLINE
/* Find apostrophes and double them */
char *
readline_quote_filename (const char *s,
			 int rtype,
			 const char *qcp)
{
  char *r, *base = alloca (strlen (s) * 2 + 2);
  const char *p;

  int quote;

  r = base;
  quote = *qcp;
  if (!quote)
    quote = *rl_completer_quote_characters;

  *r++ = quote;
  for (p = s; *p;)
    {
      if (*p == quote)
	*r++ = quote;

      *r++ = *p++;
    }
  *r++ = 0;
  return (strdup (base));
}

/* Find double apostrophes and turn them to single ones */
char *
readline_dequote_filename (const char *s,
			   char qc)
{
  char *r, *base = alloca (strlen (s) + 2);
  const char *p;

  if (!qc)
    return strdup (s);

  r = base;
  for (p = s; *p;)
    {
      if (*p == qc)
	p++;

      *r++ = *p++;
    }
  *r++ = 0;
  return (strdup (base));
}

/* Enter an item in the list */
void
add_completion (const char *str,
		int len)
{
  char *s = xmalloc (len + 1);
  memcpy (s, str, len);
  s[len] = 0;

  if (!free_items)
    {
      free_items += 50;
      completions =
	(char **) xrealloc (completions, sizeof (char *) * (count + 50));
    }

  free_items--;
  completions[count++] = s;
}

void
_gst_add_symbol_completion (const char *str,
			    int len)
{
  const char *base = str;
  const char *p = str;

  if (completions_enabled < 1)
    return;

  while (len-- && *p)
    {
      if (*p++ == ':' && (base != p - 1))
	{
	  add_completion (base, p - base);
	  base = p;
	}
    }

  /* We enter all unary and binary symbols in the table, too */
  if (base == str)
    add_completion (base, p - base);
}

/* Merge the contents of a1 with the contents of a2,
 * storing the result in a2.  If a1 and a2 overlap,
 * reallocate must be true.
 */
void
merge (char **a1,
       int count1,
       char **a2,
       int count2,
       mst_Boolean reallocate)
{
  char *source, *dest;

  /* Check if an array is empty */
  if (!count1)
    return;

  if (!count2)
    {
      memmove (a1, a2, count1 * sizeof (char *));
      return;
    }

  if (reallocate)
    {
      char **new = (char **) alloca (count1 * sizeof (char *));
      memcpy (new, a1, count1 * sizeof (char *));
      a1 = new;
    }

  source = a1[count1 - 1];
  dest = a2[count2 - 1];
  for (;;)
    {
      if (strcmp (source, dest) < 0)
	{
	  /* Take it from the destination array */
	  a2[count2 + count1 - 1] = dest;
	  if (--count2 == 0)
	    {
	      /* Any leftovers from the source array? */
	      memcpy (a1, a2, count1 * sizeof (char *));
	      return;
	    }

	  dest = a2[count2 - 1];
	}
      else
	{
	  /* Take it from the source array */
	  a2[count2 + count1 - 1] = source;
	  if (--count1 == 0)
	    return;

	  source = a1[count1 - 1];
	}
    }

}

/* Comparison function for qsort */
int
compare_strings (const PTR a,
		 const PTR b)
{
  const char **s1 = (const char **) a;
  const char **s2 = (const char **) b;

  return strcmp (*s1, *s2);
}

/* Communication between symbol_generator and readline_match_symbols */
static int matches_left, current_index;

char *
symbol_generator (const char *text,
		  int state)
{
  if (matches_left == 0)
    return (NULL);

  /* Since we have to sort the array to perform the binary search, we
     remove duplicates and avoid that readline resorts the result.  */
  while (matches_left > 1 &&
	 strcmp (completions[current_index],
		 completions[current_index + 1]) == 0)
    {
      current_index++;
      matches_left--;
    }

  matches_left--;
  return strdup (completions[current_index++]);
}


char **
readline_match_symbols (char *text,
			int start,
			int end)
{
  int low, high, middle, len;

  /* Check for strings (not matched) and for symbols (matched) */
  if (start != 0 && rl_line_buffer[start - 1] == '\'')
    {
      if (start == 1 || rl_line_buffer[start - 2] != '#')
	{
	  return NULL;
	}
    }

  /* Prepare for binary searching.  We use qsort when necessary, and
     merge the result, instead of doing expensive (quadratic) insertion
     sorts.  */
  if (sorted_count < count)
    {
      qsort (&completions[sorted_count], count - sorted_count,
	     sizeof (char *), compare_strings);

      merge (&completions[sorted_count], count - sorted_count,
	     completions, sorted_count, true);

      sorted_count = count;
    }

  /* Initialize current_index and matches_left with two binary
     searches.  */
  len = strlen (text);

  /* The first binary search gives the first matching item.  */
  low = -1;
  high = count;
  while (low + 1 != high)
    {
      middle = (low + high) / 2;
      if (strncmp (completions[middle], text, len) < 0)
	low = middle;
      else
	high = middle;
    }
  current_index = high;

  /* This binary search gives the first non-matching item instead */
  low = -1;
  high = count;
  while (low + 1 != high)
    {
      middle = (low + high) / 2;
      if (strncmp (completions[middle], text, len) <= 0)
	low = middle;
      else
	high = middle;
    }

  matches_left = high - current_index;
  return matches_left ? rl_completion_matches (text,
					       symbol_generator) : NULL;
}

int
readline_getc (FILE * file)
{
  int result;
  unsigned char ch;
  result = poll_and_read (fileno (file), &ch, 1);

  return (result < 1) ? EOF : (int) ch;
}

void
_gst_initialize_readline (void)
{
  static char everything[255];
  int i;

  /* Allow conditional parsing of the ~/.inputrc file.  */
  rl_readline_name = (char *) "Smalltalk";

  /* Always put filenames in quotes */
  for (i = 0; i < 255; i++)
    everything[i] = i + 1;

  rl_filename_quote_characters = everything;
  rl_completer_quote_characters = (char *) "'\"";
  rl_basic_word_break_characters = (char *) "() []{};+-=*<>~'?%/@|&#^\"\\.";

  /* Consider binary selectors both word-breaking characters and
     candidates for completion */
  rl_special_prefixes = (char *) "+-=*<>~?%/@|&\\";

  /* Our rules for quoting are a bit different from the default */
  rl_filename_quoting_function = (CPFunction *) readline_quote_filename;
  rl_filename_dequoting_function =
    (CPFunction *) readline_dequote_filename;

  /* Try to match a symbol before a filename */
  rl_attempted_completion_function =
    (CPPFunction *) readline_match_symbols;

  /* Since we have to sort the array to perform the binary search,
     remove duplicates and avoid that readline resorts the result.  */
  rl_ignore_completion_duplicates = 0;

  /* Set up to use read to read from stdin */
  rl_getc_function = readline_getc;
}

#endif /* HAVE_READLINE */
