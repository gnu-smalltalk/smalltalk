#! @AWK@ -f

#######################################################################
#
#   Gtk wrapper creation script (enumerations)
#
########################################################################


#######################################################################
#
# Copyright 2001, 2003 Free Software Foundation, Inc.
# Written by Paolo Bonzini and Dragomir Milivojevic
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

BEGIN {
  print "/* Automatically generated, do not edit! */"
  print "#define GDK_PIXBUF_ENABLE_BACKEND 1"
  print "#include <stdio.h>"
  print "#include <stdlib.h>"
  print "#include <glib.h>"
  print "#include <glib-object.h>"
  print "#include <atk/atk.h>"
  print "#include <pango/pango.h>"
  print "#include <gtk/gtk.h>"
  print "#include <gdk/gdk.h>"
}

FNR == 1 {
  enum_class = get_enum_class(FILENAME)
}

# store declaration in decl[filename]
/^(typedef )?enum/ {
  last_was_string = 0
  split("", declaration)

  do
    getline
  while (/^{/)

  while (! /^}/) {
    sub(/[,=].*/, "")
    if ($1 ~ /^[A-Z_][A-Z_0-9]*$/) declaration[$1] = ""
    getline
  }

  # On the last line, read the enum's name --------------
  if (NF != 2)
    enum_category = "enumerations"
  else {
    enum_category = $2
    sub(/;$/, "", enum_category)
    enum_class = get_enum_class(enum_category)
  }

  # And finally emit the code ---------------------------
  for (each in declaration) {
    decl[n++] = print_numeric_enum(each)
  }

  print_end_of_category()

  enums[m++] = enum_class " " enum_category " " n
}

END {
  print "int"
  print "main() {"
  print "  printf (\"\\\"Automatically generated, do not edit!\\\"\\n\");"
  n = 0
  for (i = 0; i < m; i++)
    {
      $0 = enums[i]
      print print_methodsFor($1, $2)
      while(n < $3)
        print decl[n++]
      print print_end_of_category()
    }

  print print_methodsFor("GValue", "fundamental types")
  print print_numeric_enum("G_TYPE_INVALID")
  print print_numeric_enum("G_TYPE_NONE")
  print print_numeric_enum("G_TYPE_INTERFACE")
  print print_numeric_enum("G_TYPE_CHAR")
  print print_numeric_enum("G_TYPE_UCHAR")
  print print_numeric_enum("G_TYPE_BOOLEAN")
  print print_numeric_enum("G_TYPE_INT")
  print print_numeric_enum("G_TYPE_UINT")
  print print_numeric_enum("G_TYPE_LONG")
  print print_numeric_enum("G_TYPE_ULONG")
  print print_numeric_enum("G_TYPE_INT64")
  print print_numeric_enum("G_TYPE_UINT64")
  print print_numeric_enum("G_TYPE_ENUM")
  print print_numeric_enum("G_TYPE_FLAGS")
  print print_numeric_enum("G_TYPE_FLOAT")
  print print_numeric_enum("G_TYPE_DOUBLE")
  print print_numeric_enum("G_TYPE_STRING")
  print print_numeric_enum("G_TYPE_POINTER")
  print print_numeric_enum("G_TYPE_BOXED")
  print print_numeric_enum("G_TYPE_PARAM")
  print print_numeric_enum("G_TYPE_OBJECT")
  print print_end_of_category()

  print print_methodsFor("Gtk", "stock objects")
  print print_string_enum("GTK_STOCK_DIALOG_INFO")
  print print_string_enum("GTK_STOCK_DIALOG_WARNING")
  print print_string_enum("GTK_STOCK_DIALOG_ERROR")
  print print_string_enum("GTK_STOCK_DIALOG_QUESTION")
  print print_string_enum("GTK_STOCK_DND")
  print print_string_enum("GTK_STOCK_DND_MULTIPLE")
  print print_string_enum("GTK_STOCK_ADD  ")
  print print_string_enum("GTK_STOCK_APPLY")
  print print_string_enum("GTK_STOCK_BOLD ")
  print print_string_enum("GTK_STOCK_CANCEL")
  print print_string_enum("GTK_STOCK_CDROM")
  print print_string_enum("GTK_STOCK_CLEAR")
  print print_string_enum("GTK_STOCK_CLOSE")
  print print_string_enum("GTK_STOCK_COLOR_PICKER")
  print print_string_enum("GTK_STOCK_CONVERT")
  print print_string_enum("GTK_STOCK_COPY")
  print print_string_enum("GTK_STOCK_CUT")
  print print_string_enum("GTK_STOCK_DELETE")
  print print_string_enum("GTK_STOCK_EXECUTE")
  print print_string_enum("GTK_STOCK_FIND")
  print print_string_enum("GTK_STOCK_FIND_AND_REPLACE")
  print print_string_enum("GTK_STOCK_FLOPPY")
  print print_string_enum("GTK_STOCK_GOTO_BOTTOM")
  print print_string_enum("GTK_STOCK_GOTO_FIRST")
  print print_string_enum("GTK_STOCK_GOTO_LAST")
  print print_string_enum("GTK_STOCK_GOTO_TOP")
  print print_string_enum("GTK_STOCK_GO_BACK")
  print print_string_enum("GTK_STOCK_GO_DOWN")
  print print_string_enum("GTK_STOCK_GO_FORWARD")
  print print_string_enum("GTK_STOCK_GO_UP")
  print print_string_enum("GTK_STOCK_HELP")
  print print_string_enum("GTK_STOCK_HOME")
  print print_string_enum("GTK_STOCK_INDEX")
  print print_string_enum("GTK_STOCK_ITALIC")
  print print_string_enum("GTK_STOCK_JUMP_TO")
  print print_string_enum("GTK_STOCK_JUSTIFY_CENTER")
  print print_string_enum("GTK_STOCK_JUSTIFY_FILL")
  print print_string_enum("GTK_STOCK_JUSTIFY_LEFT")
  print print_string_enum("GTK_STOCK_JUSTIFY_RIGHT")
  print print_string_enum("GTK_STOCK_MISSING_IMAGE")
  print print_string_enum("GTK_STOCK_NEW")
  print print_string_enum("GTK_STOCK_NO")
  print print_string_enum("GTK_STOCK_OK")
  print print_string_enum("GTK_STOCK_OPEN")
  print print_string_enum("GTK_STOCK_PASTE")
  print print_string_enum("GTK_STOCK_PREFERENCES")
  print print_string_enum("GTK_STOCK_PRINT")
  print print_string_enum("GTK_STOCK_PRINT_PREVIEW")
  print print_string_enum("GTK_STOCK_PROPERTIES")
  print print_string_enum("GTK_STOCK_QUIT")
  print print_string_enum("GTK_STOCK_REDO")
  print print_string_enum("GTK_STOCK_REFRESH")
  print print_string_enum("GTK_STOCK_REMOVE")
  print print_string_enum("GTK_STOCK_REVERT_TO_SAVED")
  print print_string_enum("GTK_STOCK_SAVE")
  print print_string_enum("GTK_STOCK_SAVE_AS")
  print print_string_enum("GTK_STOCK_SELECT_COLOR")
  print print_string_enum("GTK_STOCK_SELECT_FONT")
  print print_string_enum("GTK_STOCK_SORT_ASCENDING")
  print print_string_enum("GTK_STOCK_SORT_DESCENDING")
  print print_string_enum("GTK_STOCK_SPELL_CHECK")
  print print_string_enum("GTK_STOCK_STOP")
  print print_string_enum("GTK_STOCK_STRIKETHROUGH")
  print print_string_enum("GTK_STOCK_UNDELETE")
  print print_string_enum("GTK_STOCK_UNDERLINE")
  print print_string_enum("GTK_STOCK_UNDO")
  print print_string_enum("GTK_STOCK_YES")
  print print_string_enum("GTK_STOCK_ZOOM_100")
  print print_string_enum("GTK_STOCK_ZOOM_FIT")
  print print_string_enum("GTK_STOCK_ZOOM_IN")
  print print_string_enum("GTK_STOCK_ZOOM_OUT")
  print print_end_of_category()
  print "  exit(0);"
  print "}"
}

function print_end_of_category()
{
  return "  printf(\" !\\n\\n\");"
}

function print_numeric_enum(c_name)
{
  selector = smalltalkize(tolower(c_name))
  return "  printf(\"\\n" selector " ^%d!\", (int) " c_name ");"
}

function print_string_enum(c_name)
{
  selector = smalltalkize(tolower(c_name))
  return "  printf(\"\\n" selector " ^'%s'!\", " c_name ");"
}

function print_methodsFor( class, category )
{
  return "  printf(\"!" class " class methodsFor: '" category "'!\\n\");"
}
function get_enum_class( res )
{
  if (tolower (res) ~ /pango/) return "Pango"
  if (tolower (res) ~ /gdk/) return "Gdk"
  if (tolower (res) ~ /gtk/) return "Gtk"
  if (tolower (res) ~ /atk/) return "Atk"
  if (tolower (res) ~ /g/) return "GLib"
  return ""
}

function smalltalkize( res )
{
  first = substr (res, 1, 1)
  res = tolower( substr (res, 2) )

  while (i = index (res, "_")) {
    first = first substr(res, 1, i - 1) toupper( substr (res, i + 1, 1))
    res = substr (res, i + 2)
  }

  return first res
}
