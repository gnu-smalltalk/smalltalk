/***********************************************************************
 *
 *  Blox
 *
 *  Standardized, Tk-based GUI widgets available for various window
 *  systems - Interface to Tcl
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 1992, 1994, 1995, 1999, 2000, 2001, 2002, 2006, 2009
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
 * Here is the copyright notice for the XPM code:
 * Copyright (C) 1989-94 GROUPE BULL
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * GROUPE BULL BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * Except as contained in this notice, the name of GROUPE BULL shall not be
 * used in advertising or otherwise to promote the sale, use or other dealings
 * in this Software without prior written authorization from GROUPE BULL.

 ***********************************************************************/

#include "config.h"
#include "gstpub.h"
#include <stdlib.h>

#ifndef HAVE_TCLTK
#error Tcl/Tk 8.0 needed to install the GNU Smalltalk GUI
#endif

#include <stdio.h>
#include <ctype.h>
#include <errno.h>
#include <tcl.h>
#define USE_COMPOSITELESS_PHOTO_PUT_BLOCK
#define USE_OLD_IMAGE
#include <tk.h>

/* Hack for API changes in Tcl 8.4.0 */
#ifndef CONST84
#define CONST84
#endif

#ifdef STDC_HEADERS
#include <stdlib.h>
#include <string.h>
#endif

/* Smalltalk call-ins */
static Tcl_Interp *tclInit (void);
static void bloxIdle (void);

/* TCL callbacks */
static int doCallback (ClientData clientData, Tcl_Interp * interp, int argc,
		       CONST84 char **argv);
static int xpmFileMatch (Tcl_Channel channel, char *fileName,
			 char *formatString, int *widthPtr, int *heightPtr);
static int xpmStringMatch (char *string, char *formatString, int *widthPtr,
			   int *heightPtr);
static int xpmFileRead (Tcl_Interp * interp, Tcl_Channel channel,
			char *fileName, char *formatString,
			Tk_PhotoHandle imageHandle, int destX, int destY,
			int width, int height, int srcX, int srcY);
static int xpmStringRead (Tcl_Interp * interp, char *string,
			  char *formatString, Tk_PhotoHandle imageHandle,
			  int destX, int destY, int width, int height,
			  int srcX, int srcY);

/* Globals */

static void xpmInit (void);
static VMProxy *vmProxy;

void
bloxIdle (void)
{
  while (Tcl_DoOneEvent (TCL_ALL_EVENTS | TCL_DONT_WAIT));
}


int
doCallback (ClientData clientData, Tcl_Interp * interp, int argc, CONST84 char **argv)
{
  OOP oop, *args;
  int i;
  char result[2] = "0";

  /* argv[0] is "callback", the command name */
  args = alloca (sizeof (OOP) * (argc - 2));
  oop = vmProxy->idToOOP (atoi (argv[1]));
  for (i = 0; i < argc - 3; i++)
    args[i] = vmProxy->stringToOOP (argv[i + 3]);

  args[argc - 3] = NULL;
  if (vmProxy->vmsgSend (oop, vmProxy->symbolToOOP (argv[2]), args)
      == vmProxy->trueOOP)
    result[0]++;

  Tcl_SetResult (interp, result, TCL_VOLATILE);
  return TCL_OK;
}


Tcl_Interp *
tclInit (void)
{
  static Tcl_Interp *interp;
  char *tclLibrary;
  if (interp)
    return (NULL);

  interp = Tcl_CreateInterp ();
  tclLibrary = getenv ("TCL_LIBRARY");
  if (tclLibrary)
    Tcl_SetVar (interp, "tcl_library", tclLibrary, TCL_GLOBAL_ONLY);

  if (Tcl_Init (interp) == TCL_ERROR)
    {
      fprintf (stderr, "Tcl_Init failed: %s\n", interp->result);
      exit (1);
    }
  if (Tk_Init (interp) == TCL_ERROR)
    {
      fprintf (stderr, "Tk_Init failed: %s\n", interp->result);
      exit (1);
    }
  Tcl_CreateCommand (interp, "callback", doCallback, NULL, NULL);
  xpmInit ();

  return (interp);
}

void
gst_initModule (VMProxy * proxy)
{
  Tcl_FindExecutable ("");

  vmProxy = proxy;
  vmProxy->defineCFunc ("Tcl_Eval", Tcl_Eval);
  vmProxy->defineCFunc ("Tcl_GetStringResult", Tcl_GetStringResult);
  vmProxy->defineCFunc ("tclInit", tclInit);
  vmProxy->defineCFunc ("bloxIdle", bloxIdle);
}

/******************* BEGINNING OF XPM CODE ***********************/

typedef struct
{
  const char *cptr;
  const char *Bcmt;
  const char *Ecmt;
  char Bos, Eos;
  mst_Boolean xpm1;		/* 1 if XPM1, 0 otherwise */
}
XpmData;

#include "rgbtab.h"

/* number of xpmColorKeys */
#define NKEYS 5

const char *xpmColorKeys[] = {
  "s",				/* key #1: symbol */
  "m",				/* key #2: mono visual */
  "g4",				/* key #3: 4 grays visual */
  "g",				/* key #4: gray visual */
  "c",				/* key #5: color visual */
};

typedef struct
{
  const char *type;			/* key word */
  const char *Bcmt;			/* string beginning comments */
  const char *Ecmt;			/* string ending comments */
  char Bos;			/* character beginning strings */
  char Eos;			/* character ending strings */
}
XpmDataType;

typedef struct
{
  char *string;			/* characters string */
  char *symbolic;		/* symbolic name */
  char *m_color;		/* monochrom default */
  char *g4_color;		/* 4 level grayscale default */
  char *g_color;		/* other level grayscale default */
  char *c_color;		/* color default */
  int rgb;
}
XpmColor;

typedef struct
{
  unsigned int width;		/* image width */
  unsigned int height;		/* image height */
  unsigned int *data;		/* image data */
}
XpmImage;


static XpmDataType xpmDataTypes[] = {
  {"", "!", "\n", '\0', '\n'},	/* Natural type */
  {"C", "/*", "*/", '"', '"'},
  {"Lisp", ";", "\n", '"', '"'},
  {NULL, NULL, NULL, 0, 0,}
};

static int xpmParseHeader (XpmData * mdata);
static int xpmParseValues (XpmData * data,
			   unsigned int *width,
			   unsigned int *height,
			   unsigned int *ncolors,
			   unsigned int *cpp);
static int xpmParseColors (XpmData * data,
			   unsigned int ncolors,
			   unsigned int cpp,
			   XpmColor ** colorTablePtr);
static int xpmParsePixels (XpmData * data,
			   unsigned int width,
			   unsigned int height,
			   unsigned int ncolors,
			   unsigned int cpp,
			   XpmColor *colorTable,
			   unsigned int **pixels);
static int xpmParseData (char *buffer, 
			 XpmImage * image, 
			 mst_Boolean readPixels);

static mst_Boolean xpmNextUI (XpmData * mdata, 
			      unsigned int *ui_return);

static mst_Boolean atoui (char *buf, 
			  int l, 
			  unsigned int *ui_return);

static void xpmNextString (XpmData * mdata);

static void xpmParseComment (XpmData * mdata);

static void xpmFreeColorTable (XpmColor * colorTable,
			       int ncolors);

static unsigned int xpmNextWord (XpmData * mdata, char *buf,
				 unsigned int buflen);

static void ParseNumericColor (char *str,
			       int *prgb);

static void ParseXColor (Tk_Uid uid,
			 int *prgb);

void
ParseNumericColor (char *str, int *prgb)
{
#define HEX(ch, shift)	\
	( ((unsigned int) (((ch) - ((ch) < 'A' ? 48 : 55)) & 15)) << (shift))

  switch (strlen (str))
    {
    case 4:
      *prgb = HEX (str[1], 20) | HEX (str[2], 12) | HEX (str[1], 4);
      return;

    case 7:
      *prgb = HEX (str[1], 20) | HEX (str[3], 12) | HEX (str[5], 4)
	| HEX (str[2], 16) | HEX (str[4], 8) | HEX (str[6], 0);
      return;

    case 10:
      *prgb = HEX (str[1], 20) | HEX (str[4], 12) | HEX (str[7], 4)
	| HEX (str[2], 16) | HEX (str[5], 8) | HEX (str[8], 0);
      return;

    case 13:
      *prgb = HEX (str[1], 20) | HEX (str[5], 12) | HEX (str[9], 4)
	| HEX (str[2], 16) | HEX (str[6], 8) | HEX (str[10], 0);
      return;
    }
}

void
ParseXColor (Tk_Uid uid, int *prgb)
{
  xpmColorEntry *ce;

  for (ce = xColors; ce->color; ce++)
    {
      if ((char *) ce->color == uid)
	{
	  *prgb = ce->rgb;
	  return;
	}
    }
}

void
xpmParseComment (XpmData * mdata)
{
  register char c;
  register unsigned int n = 0;
  const char *s2;

  /* skip the string beginning comment */
  s2 = mdata->Bcmt;
  do
    {
      c = *mdata->cptr++;
      n++;
      s2++;
    }
  while (c == *s2 && *s2 != '\0' && c && c != mdata->Bos);

  if (*s2 != '\0')
    {
      /* this wasn't the beginning of a comment */
      mdata->cptr -= n;
      return;
    }
  /* skip comment */
  do
    {
      s2 = mdata->Ecmt;
      while (c && c != *s2 && c != mdata->Bos)
	{
	  c = *mdata->cptr++;
	}
      do
	{
	  c = *mdata->cptr++;
	  s2++;
	}
      while (c == *s2 && *s2 != '\0' && c && c != mdata->Bos);
    }
  while (*s2 != '\0');

  /* this is the end of the comment */
  mdata->cptr--;
  return;
}

/*
 * skip to the end of the current string and the beginning of the next one
 */
void
xpmNextString (XpmData * mdata)
{
  register char c;

  /* get to the end of the current string */
  if (mdata->Eos)
    while ((c = *mdata->cptr++) && c != mdata->Eos);

  /*
   * then get to the beginning of the next string looking for possible
   * comment
   */
  if (mdata->Bos)
    {
      while ((c = *mdata->cptr++) && c != mdata->Bos)
	if (mdata->Bcmt && c == mdata->Bcmt[0])
	  xpmParseComment (mdata);
    }
  else if (mdata->Bcmt)
    {				/* XPM2 natural */
      while ((c = *mdata->cptr++) == mdata->Bcmt[0])
	xpmParseComment (mdata);
      mdata->cptr--;
    }
  return;
}


/*
 * skip whitespace and return the following word
 */
unsigned int
xpmNextWord (XpmData * mdata, char *buf, unsigned int buflen)
{
  register unsigned int n = 0;
  int c;

  while (isspace (c = *mdata->cptr) && c != mdata->Eos)
    mdata->cptr++;
  do
    {
      c = *mdata->cptr++;
      *buf++ = c;
      n++;
    }
  while (!isspace (c) && c != mdata->Eos && n < buflen);
  n--;
  mdata->cptr--;

  return (n);
}

/*
 * skip whitespace and compute the following unsigned int,
 * returns true if one is found and false if not
 */
mst_Boolean
atoui (char *buf, int l, unsigned int *ui_return)
{
  unsigned long int result;

  buf[l] = 0;
  errno = 0;
  *ui_return = strtoul (buf, NULL, 0);
  result = !errno;
  errno = 0;
  return (unsigned int) result;
}

mst_Boolean
xpmNextUI (XpmData * mdata, unsigned int *ui_return)
{
  long int l;
  char buf[BUFSIZ + 1];

  l = xpmNextWord (mdata, buf, BUFSIZ);
  return atoui (buf, l, ui_return);
}

/*
 * parse xpm header
 */
int
xpmParseHeader (XpmData * mdata)
{
  char buf[BUFSIZ + 1];
  int l, n = 0;

  mdata->Bos = '\0';
  mdata->Eos = '\n';
  mdata->Bcmt = mdata->Ecmt = NULL;
  l = xpmNextWord (mdata, buf, BUFSIZ);
  if (l == 7 && !strncmp ("#define", buf, 7))
    {
      /* this maybe an XPM 1 file */
      char *ptr;

      l = xpmNextWord (mdata, buf, BUFSIZ);
      if (!l)
	return (TCL_ERROR);	/* File Invalid */
      ptr = strchr (buf, '_');
      if (!ptr || strncmp ("_format", ptr, l - (ptr - buf)))
	return (TCL_ERROR);	/* File Invalid */
      /* this is definitely an XPM 1 file */
      mdata->xpm1 = true;
      n = 1;			/* handle XPM1 as mainly XPM2 C */
    }
  else
    {

      /*
       * skip the first word, get the second one, and see if this is
       * XPM 2 or 3
       */
      l = xpmNextWord (mdata, buf, BUFSIZ);
      if ((l == 3 && !strncmp ("XPM", buf, 3)) ||
	  (l == 4 && !strncmp ("XPM2", buf, 4)))
	{
	  if (l == 3)
	    n = 1;		/* handle XPM as XPM2 C */
	  else
	    {
	      /* get the type key word */
	      l = xpmNextWord (mdata, buf, BUFSIZ);

	      /*
	       * get infos about this type
	       */
	      while (xpmDataTypes[n].type
		     && strncmp (xpmDataTypes[n].type, buf, l))
		n++;
	    }
	  mdata->xpm1 = false;
	}
      else
	/* nope this is not an XPM file */
	return (TCL_ERROR);	/* File Invalid */
    }
  if (xpmDataTypes[n].type)
    {
      if (n == 0)
	{			/* natural type */
	  mdata->Bcmt = xpmDataTypes[n].Bcmt;
	  mdata->Ecmt = xpmDataTypes[n].Ecmt;
	  xpmNextString (mdata);	/* skip the end of the headerline */
	  mdata->Bos = xpmDataTypes[n].Bos;
	  mdata->Eos = xpmDataTypes[n].Eos;
	}
      else
	{
	  mdata->Bcmt = xpmDataTypes[n].Bcmt;
	  mdata->Ecmt = xpmDataTypes[n].Ecmt;
	  if (!mdata->xpm1)
	    {			/* XPM 2 or 3 */
	      mdata->Bos = xpmDataTypes[n].Bos;
	      mdata->Eos = '\0';
	      /* get to the beginning of the first string */
	      xpmNextString (mdata);
	      mdata->Eos = xpmDataTypes[n].Eos;
	    }
	  else			/* XPM 1 skip end of line */
	    xpmNextString (mdata);
	}
    }
  else
    /* we don't know about that type of XPM file... */
    return (TCL_ERROR);		/* File Invalid */

  return (TCL_OK);
}

int
xpmParseValues (XpmData * data, unsigned int *width, unsigned int *height,
		unsigned int *ncolors, unsigned int *cpp)
{
  unsigned int l;
  unsigned int x_hotspot, y_hotspot, hotspot;
  unsigned int extensions;
  char buf[BUFSIZ + 1];

  if (!data->xpm1)
    {				/* XPM 2 or 3 */

      /*
       * read values: width, height, ncolors, chars_per_pixel
       */
      if (!(xpmNextUI (data, width) && xpmNextUI (data, height)
	    && xpmNextUI (data, ncolors) && xpmNextUI (data, cpp)))
	return (TCL_ERROR);	/* File invalid */

      /*
       * read optional information (hotspot and/or XPMEXT) if any
       */
      l = xpmNextWord (data, buf, BUFSIZ);
      if (l)
	{
	  extensions = (l == 6 && !strncmp ("XPMEXT", buf, 6));
	  if (extensions)
	    hotspot = (xpmNextUI (data, &x_hotspot)
		       && xpmNextUI (data, &y_hotspot));
	  else
	    {
	      hotspot = (atoui (buf, l, &x_hotspot)
			 && xpmNextUI (data, &y_hotspot));
 	      l = xpmNextWord (data, buf, BUFSIZ);
	    }
	}
    }
  else
    {

      /*
       * XPM 1 file read values: width, height, ncolors, chars_per_pixel
       */
      int i;
      char *ptr;

      for (i = 0; i < 4; i++)
	{
	  l = xpmNextWord (data, buf, BUFSIZ);
	  if (l != 7 || strncmp ("#define", buf, 7))
	    return (TCL_ERROR);	/* File invalid */
	  l = xpmNextWord (data, buf, BUFSIZ);
	  if (!l)
	    return (TCL_ERROR);	/* File invalid */
	  ptr = strchr (buf, '_');
	  if (!ptr)
	    return (TCL_ERROR);	/* File invalid */
	  switch (l - (ptr - buf))
	    {
	    case 6:
	      if (!strncmp ("_width", ptr, 6) && !xpmNextUI (data, width))
		return (TCL_ERROR);	/* File invalid */
	      break;
	    case 7:
	      if (!strncmp ("_height", ptr, 7) && !xpmNextUI (data, height))
		return (TCL_ERROR);	/* File invalid */
	      break;
	    case 8:
	      if (!strncmp ("_ncolors", ptr, 8) && !xpmNextUI (data, ncolors))
		return (TCL_ERROR);	/* File invalid */
	      break;
	    case 16:
	      if (!strncmp ("_chars_per_pixel", ptr, 16)
		  && !xpmNextUI (data, cpp))
		return (TCL_ERROR);	/* File invalid */
	      break;
	    default:
	      return (TCL_ERROR);	/* File invalid */
	    }
	  /* skip the end of line */
	  xpmNextString (data);
	}
    }
  return (TCL_OK);
}

int
xpmParseColors (XpmData * data, unsigned int ncolors, unsigned int cpp,
		XpmColor ** colorTablePtr)
{
  unsigned int key, l, a, b;
  unsigned int curkey;		/* current color key */
  unsigned int lastwaskey;	/* key read */
  char buf[BUFSIZ + 1];
  char curbuf[BUFSIZ + 1];	/* current buffer */
  const char **sptr;
  char *s;
  XpmColor *color;
  XpmColor *colorTable;
  char **defaults;

  colorTable = (XpmColor *) malloc (ncolors * sizeof (XpmColor));
  if (!colorTable)
    return (TCL_ERROR);		/* No memory */

  memset (colorTable, 0, ncolors * sizeof (XpmColor));
  if (!data->xpm1)
    {				/* XPM 2 or 3 */
      for (a = 0, color = colorTable; a < ncolors; a++, color++)
	{
	  xpmNextString (data);	/* skip the line */

	  /*
	   * read pixel value
	   */
	  color->string = (char *) malloc (cpp + 1);
	  if (!color->string)
	    {
	      xpmFreeColorTable (colorTable, ncolors);
	      return (TCL_ERROR);	/* No memory */
	    }
	  for (b = 0, s = color->string; b < cpp; b++, s++)
	    *s = *data->cptr++;
	  *s = '\0';

	  /*
	   * read color keys and values
	   */
	  defaults = (char **) color;
	  key = NKEYS;
	  curkey = 0;
	  lastwaskey = 0;
	  *curbuf = '\0';	/* init curbuf */
	  while ((l = xpmNextWord (data, buf, BUFSIZ)) != 0)
	    {
	      if (!lastwaskey)
		{
		  for (key = 0, sptr = xpmColorKeys; key < NKEYS;
		       key++, sptr++)
		    if ((strlen (*sptr) == l) && (!strncmp (*sptr, buf, l)))
		      break;
		}
	      if (!lastwaskey && key < NKEYS)
		{		/* open new key */
		  if (curkey)
		    {		/* flush string */
		      s = (char *) malloc (strlen (curbuf) + 1);
		      if (!s)
			{
			  xpmFreeColorTable (colorTable, ncolors);
			  return (TCL_ERROR);	/* No memory */
			}
		      defaults[curkey] = s;
		      strcpy (s, curbuf);
		    }
		  curkey = key + 1;	/* set new key  */
		  *curbuf = '\0';	/* reset curbuf */
		  lastwaskey = 1;
		}
	      else
		{
		  if (!curkey)
		    {		/* key without value */
		      xpmFreeColorTable (colorTable, ncolors);
		      return (TCL_ERROR);	/* File invalid */
		    }
		  if (!lastwaskey)
		    strcat (curbuf, " ");	/* append space */
		  buf[l] = '\0';
		  strcat (curbuf, buf);	/* append buf */
		  lastwaskey = 0;
		}
	    }
	  if (!curkey)
	    {			/* key without value */
	      xpmFreeColorTable (colorTable, ncolors);
	      return (TCL_ERROR);	/* File invalid */
	    }
	  s = defaults[curkey] = (char *) malloc (strlen (curbuf) + 1);
	  if (!s)
	    {
	      xpmFreeColorTable (colorTable, ncolors);
	      return (TCL_ERROR);	/* No memory */
	    }
	  strcpy (s, curbuf);
	}
    }
  else
    {				/* XPM 1 */
      /* get to the beginning of the first string */
      data->Bos = '"';
      data->Eos = '\0';
      xpmNextString (data);
      data->Eos = '"';
      for (a = 0, color = colorTable; a < ncolors; a++, color++)
	{

	  /*
	   * read pixel value
	   */
	  color->string = (char *) malloc (cpp + 1);
	  if (!color->string)
	    {
	      xpmFreeColorTable (colorTable, ncolors);
	      return (TCL_ERROR);	/* No memory */
	    }
	  for (b = 0, s = color->string; b < cpp; b++, s++)
	    *s = *data->cptr++;
	  *s = '\0';

	  /*
	   * read color values
	   */
	  xpmNextString (data);	/* get to the next string */
	  *curbuf = '\0';	/* init curbuf */
	  while ((l = xpmNextWord (data, buf, BUFSIZ)) != 0)
	    {
	      if (*curbuf != '\0')
		strcat (curbuf, " ");	/* append space */
	      buf[l] = '\0';
	      strcat (curbuf, buf);	/* append buf */
	    }
	  s = (char *) malloc (strlen (curbuf) + 1);
	  if (!s)
	    {
	      xpmFreeColorTable (colorTable, ncolors);
	      return (TCL_ERROR);	/* No memory */
	    }
	  strcpy (s, curbuf);
	  color->c_color = s;
	  *curbuf = '\0';	/* reset curbuf */
	  if (a < ncolors - 1)
	    xpmNextString (data);	/* get to the next string */
	}
    }

  for (a = 0, color = colorTable; a < ncolors; a++, color++)
    {
      Tk_Uid noneUid = Tk_GetUid ("None");

      for (curkey = NKEYS, color->rgb = -2, defaults = (char **) color;
	   color->rgb == -2 && curkey; curkey--)
	{

	  Tk_Uid colorUid;
	  if (!defaults[curkey])
	    continue;

	  if (defaults[curkey][0] == '#')
	    {
	      ParseNumericColor (defaults[curkey], &color->rgb);
	      continue;
	    }
	  if (!strncmp (defaults[curkey], "grey", 4))
	    {
	      /* Recognize `greys' too, not just `grays'... */
	      defaults[curkey][2] = 'a';
	    }

	  /* Make black the transparent color -- black becomes a very dark gray */
	  colorUid = Tk_GetUid (defaults[curkey]);
	  if (colorUid == noneUid)
	    {
	      color->rgb = 0;
	      continue;
	    }
	  ParseXColor (colorUid, &color->rgb);
	  if (!color->rgb)
	    color->rgb = 0x30303;	/* This is gray1 */
	}
    }

  *colorTablePtr = colorTable;
  return (TCL_OK);
}

int
xpmParsePixels (XpmData * data, unsigned int width, unsigned int height,
		unsigned int ncolors, unsigned int cpp, XpmColor * colorTable,
		unsigned int **pixels)
{
  unsigned int *iptr, *iptr2;
  unsigned int a, x, y;

  iptr2 = (unsigned int *) malloc (sizeof (unsigned int) * width * height);
  if (!iptr2)
    return (TCL_ERROR);		/* No memory */

  iptr = iptr2;

  switch (cpp)
    {

    case (1):			/* Optimize for single character colors */
      {
	unsigned int colrgb[256];

	memset (colrgb, 0, 256 * sizeof (int));
	for (a = 0; a < 256; a++)
	  colrgb[a] = -1;
	for (a = 0; a < ncolors; a++)
	  colrgb[(unsigned int) colorTable[a].string[0]] = colorTable[a].rgb;

	for (y = 0; y < height; y++)
	  {
	    xpmNextString (data);
	    for (x = 0; x < width; x++, iptr++)
	      {
		int rgb = colrgb[(unsigned int) *data->cptr++];

		if (rgb != -1)
		  *iptr = rgb;
		else
		  {
		    free (iptr2);
		    return (TCL_ERROR);	/* File invalid */
		  }
	      }
	  }
      }
      break;

    case (2):			/* Optimize for double character scolors */
      {

/* free all allocated pointers at all exits */
#define FREE_CRGB {int f; for (f = 0; f < 256; f++) \
if (crgb[f]) free(crgb[f]);}

	/* array of pointers malloced by need */
	unsigned int *crgb[256];
	int char1, a2;

	memset (crgb, 0, 256 * sizeof (unsigned int *));	/* init */
	for (a = 0; a < ncolors; a++)
	  {
	    char1 = colorTable[a].string[0];
	    if (crgb[char1] == NULL)
	      {			/* get new memory */
		crgb[char1] = (unsigned int *)
		  malloc (256 * sizeof (unsigned int));
		if (crgb[char1] == NULL)
		  {		/* new block failed */
		    FREE_CRGB;
		    free (iptr2);
		    return (TCL_ERROR);	/* No memory */
		  }
		for (a2 = 0; a2 < 256; a2++)
		  crgb[char1][a2] = -1;
	      }
	    crgb[char1][(unsigned int) colorTable[a].string[1]] =
	      colorTable[a].rgb;
	  }

	for (y = 0; y < height; y++)
	  {
	    xpmNextString (data);
	    for (x = 0; x < width; x++, iptr++)
	      {
		int cc1 = *data->cptr++;
		int rgb = crgb[cc1][(unsigned int) *data->cptr++];

		if (rgb != -1)
		  *iptr = rgb - 1;
		else
		  {
		    FREE_CRGB;
		    free (iptr2);
		    return (TCL_ERROR);	/* File invalid */
		  }
	      }
	  }
	FREE_CRGB;
      }
      break;

    default:			/* Long color names */
      return (TCL_ERROR);	/* Not supported */
    }
  *pixels = iptr2;
  return (TCL_OK);
}

/*
 * This function parses an xpm file or data and store the found informations
 * in an an XpmImage structure which is returned.
 */
int
xpmParseData (char *buffer, XpmImage * image, mst_Boolean readPixels)
{
  /* variables to return */
  unsigned int width, height, ncolors, cpp;
  XpmColor *colorTable = NULL;
  unsigned int *pixelindex = NULL;

  int ErrorStatus;
  XpmData data;

  /*
   * parse the header
   */
  memset (image, 0, sizeof (XpmImage));
  data.cptr = buffer;
  ErrorStatus = xpmParseHeader (&data);
  if (ErrorStatus != TCL_OK)
    return (ErrorStatus);

  /*
   * read values
   */
  ErrorStatus = xpmParseValues (&data, &width, &height, &ncolors, &cpp);
  if (ErrorStatus != TCL_OK)
    return (ErrorStatus);

  /*
   * store found informations in the XpmImage structure
   */
  image->width = width;
  image->height = height;
  if (!readPixels)
    return (TCL_OK);

  /*
   * read colors
   */
  ErrorStatus = xpmParseColors (&data, ncolors, cpp, &colorTable);
  if (ErrorStatus != TCL_OK)
    return (ErrorStatus);

  /*
   * read pixels and index them on color number
   */
  ErrorStatus =
    xpmParsePixels (&data, width, height, ncolors, cpp, colorTable,
		    &pixelindex);

  xpmFreeColorTable (colorTable, ncolors);
  if (ErrorStatus != TCL_OK)
    return (ErrorStatus);

  image->data = pixelindex;
  return (TCL_OK);
}

/*
 * Free the computed color table
 */
void
xpmFreeColorTable (XpmColor * colorTable, int ncolors)
{
  int a, b;
  XpmColor *color;
  char **sptr;

  for (a = 0, color = colorTable; a < ncolors; a++, color++)
    {
      for (b = 0, sptr = (char **) color; b <= NKEYS; b++, sptr++)
	if (*sptr)
	  free (*sptr);
    }
  free (colorTable);
}


/******************************* TCL INTERFACE FOR XPM **************/

int
xpmStringMatch (char *string, char *formatString, int *widthPtr,
		int *heightPtr)
{
  XpmImage img;
  int result;

  result = xpmParseData (string, &img, false);
  if (result != TCL_OK)
    {
      return (0);
    }
  *widthPtr = img.width;
  *heightPtr = img.height;
  return (1);
}

int
xpmStringRead (Tcl_Interp * interp, char *string, char *formatString,
	       Tk_PhotoHandle imageHandle, int destX, int destY, int width,
	       int height, int srcX, int srcY)
{
  XpmImage img;
  int result;
  unsigned int *block;

#ifdef WORDS_BIG_ENDIAN
#define BYTEOFS(i) (sizeof(int)-i)
#else
#define BYTEOFS(i) (i)
#endif

  static Tk_PhotoImageBlock blk = {
    NULL,			/* unsigned char *pixelPtr; */
    0,				/* int width; */
    1,				/* int height; */
    0,				/* int pitch; */
    sizeof (int),		/* int pixelSize; */
    {BYTEOFS (2), BYTEOFS (1), BYTEOFS (0)},	/* int offset[3]; */
  };

#undef BYTEOFS

  result = xpmParseData (string, &img, true);
  if (result != TCL_OK)
    return (result);

  for (block = img.data + img.width * srcY + srcX; img.height;
       img.height--, destY++)
    {
      int todo;
      unsigned int last;

      for (blk.pixelPtr = (PTR) block, blk.width = 0, last = *block,
	   destX = 0, todo = img.width; todo--; last = *block, block++)
	{

	  if ((*block == 0) ^ (last == 0))
	    {
	      if (last)
		Tk_PhotoPutBlock (imageHandle, &blk, destX, destY,
				  blk.width, 1);
	      destX += blk.width;
	      blk.width = 1;
	      blk.pixelPtr = (PTR) block;
	    }
	  else
	    blk.width++;
	}

      if (last)
	Tk_PhotoPutBlock (imageHandle, &blk, destX, destY, blk.width, 1);
    }

  free (img.data);
  return (result);
}

int
xpmFileMatch (Tcl_Channel channel, char *fileName, char *formatString,
	      int *widthPtr, int *heightPtr)
{
  int fileSize, bytesRead, result;
  char *buf;
  fileSize = Tcl_Seek (channel, 0, SEEK_END);
  if (fileSize < 0 || Tcl_Seek (channel, 0, SEEK_SET) < 0)
    return (0);

  buf = malloc (fileSize + 1);
  if (!buf)
    return (0);

  bytesRead = Tcl_Read (channel, buf, fileSize);
  if (bytesRead < 0)
    {
      free (buf);
      return (0);
    }

  buf[bytesRead] = '\0';
  result = xpmStringMatch (buf, formatString, widthPtr, heightPtr);
  free (buf);
  return (result);
}

int
xpmFileRead (Tcl_Interp * interp, Tcl_Channel channel, char *fileName,
	     char *formatString, Tk_PhotoHandle imageHandle, int destX,
	     int destY, int width, int height, int srcX, int srcY)
{
  int fileSize, bytesRead, result;
  char *buf;
  fileSize = Tcl_Seek (channel, 0, SEEK_END);
  if (fileSize < 0 || Tcl_Seek (channel, 0, SEEK_SET) < 0)
    return (TCL_ERROR);

  buf = malloc (fileSize + 1);
  if (!buf)
    return (TCL_ERROR);
      
  bytesRead = Tcl_Read (channel, buf, fileSize);
  if (bytesRead < 0)
    {
      free (buf);
      return (TCL_ERROR);
    }

  buf[bytesRead] = '\0';
  result = xpmStringRead (interp, fileName, formatString, imageHandle,
			  destX, destY, width, height, srcX, srcY);
  free (buf);
  return (result);
}

void
xpmInit (void)
{
  static Tk_PhotoImageFormat xpmFormat = {
    (char *) "XPM",
    xpmFileMatch,
    xpmStringMatch,
    xpmFileRead,
    xpmStringRead,
    NULL,
    NULL,
    NULL
  };
  xpmColorEntry *ce;

  Tk_CreatePhotoImageFormat (&xpmFormat);

  for (ce = xColors; ce->color; ce++)
    ce->color = (char *) Tk_GetUid (ce->color);
}
