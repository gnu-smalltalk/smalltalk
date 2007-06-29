#! @AWK@ -f

#######################################################################
#
#   Gtk wrapper creation script (sizeof methods)
#
########################################################################


#######################################################################
#
# Copyright 2004 Free Software Foundation, Inc.
# Written by Mike Anderson and Paolo Bonzini
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

#! @AWK@ -f

BEGIN {
    print "/* Automatically generated, do not edit! */"
    print "#define GDK_PIXBUF_ENABLE_BACKEND 1"
    print "#include <stdio.h>"
    print "#include <stdlib.h>"
    print "#include <glib.h>"
    print "#include <glib-object.h>"
    print "#include <atk/atk.h>"
    print "#include <pango/pango.h>"
    print "#include <gdk/gdk.h>"
    print "#include <gtk/gtk.h>"
    print "#include \"placer.h\""
    print "\nint main () {"
}

{
  gsub(/[_;]/, "", $0)
  is_typedef = ($1 == "typedef")
  is_struct = $(1+is_typedef) == "struct" && (is_typedef || NF == 2 || $3 == "{")
  if (is_struct)
    {
      src = $(2+is_typedef)
      dest = $(3+is_typedef)
      is_vtable_decl = src ~ /(Class|Iface)$/
      is_g_name = src ~ /^(G|Pango|Atk)/
      is_pointer = dest ~ /\*/
    }
}

is_typedef && is_struct && is_g_name && !is_vtable_decl && !is_pointer {
  typedef_names[dest] = src
}

!is_typedef && is_struct && !is_pointer && dest !~ /^[a-z_]/ {
  struct_name[src] = ""
}

END {
  for (i in typedef_names)
    {
      # Only do complete types
      if (typedef_names[i] in struct_name)
        print "printf(\"!%s class methodsFor: 'accessing'!" \
	      "\\n\\nsizeof\\n    ^%u\\n! !\\n\\n\", " \
	      "\"" i "\", sizeof(" i "));"
    }

  print "  exit (0);"
  print "}"
}

