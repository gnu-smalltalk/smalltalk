#! @AWK@ -f

#######################################################################
#
#   Gtk wrapper creation scripts (poor man's preprocessor)
#
########################################################################


#######################################################################
#
# Copyright 2003, 2004, 2006 Free Software Foundation, Inc.
# Written by Paolo Bonzini
#
# This file is part of the GNU Smalltalk class library.
#
# The GNU Smalltalk class library is free software; you can redistribute it
# and/or modify it under the terms of the GNU Lesser General Public License
# as published by the Free Software Foundation; either version 2.1, or (at
# your option) any later version.
# 
# The GNU Smalltalk class library is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
# General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with the GNU Smalltalk class library; see the file COPYING.LESSER.
# If not, write to the Free Software Foundation, 59 Temple Place - Suite
# 330, Boston, MA 02110-1301, USA.  
#
########################################################################

in_comment {
  if (!match ($0, /\*\//))
    next
  else
    {
      # Remove end of multiline comment
      $0 = substr ($0, RSTART + 2)
      in_comment = 0
    }
}

/\/\*/ {
   # Remove sequences of asterisks in the middle of a single-line comment
   while (sub (/\/\*[^*]*\*+[^\/*]/, "/* "))
     0;
   gsub (/\/\*[^*]*\*+\//, "")

   # Detect multiline comments, removing their first line
   if (sub (/\/\*.*/, ""))
     in_comment = 1
}
 
/^#ifn?def/ {
  if ($2 in ifdef)
    $2 = "<none>"

  preproc_stack[++preproc_n] = $2
  ifdef[$2] = /^#ifdef/;
  next
}

/^#else/ {
  ifdef[preproc_stack[preproc_n]] = !ifdef[preproc_stack[preproc_n]]
  next
}

/^#endif/ {
  delete ifdef[preproc_stack[preproc_n]]
  delete preproc_stack[preproc_n]
  preproc_n--
  next
}

/^#define/ {
  while ($0 ~ /\\$/)
    getline

  next
}

in_ifndef("G_DISABLE_DEPRECATED") {
  next
}

in_ifndef("GDK_DISABLE_DEPRECATED") {
  next
}

in_ifndef("GTK_DISABLE_DEPRECATED") {
  next
}

in_ifndef("GDK_PIXBUF_ENABLE_BACKEND") {
  next
}

in_ifdef("__cplusplus") {
  next
}

in_ifdef("GTK_ENABLE_BROKEN") {
  next
}

in_ifdef("G_PLATFORM_WIN32") {
  next
}

in_ifdef("PANGO_ENABLE_BACKEND") {
  next
}

in_ifdef("PANGO_ENABLE_ENGINE") {
  next
}

{
  print
}

function in_ifdef (x)
{
  return x in ifdef && ifdef[x]
}

function in_ifndef (x)
{
  return x in ifdef && !ifdef[x]
}

