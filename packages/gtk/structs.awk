#! @AWK@ -f

#######################################################################
#
#   Gtk wrapper creation script (struct declarations)
#
########################################################################


#######################################################################
#
# Copyright 2001, 2003, 2009 Free Software Foundation, Inc.
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
  print "\"Automatically generated, do not edit!\""

  # These are implemented strangely...
  classNames["GValue"] = ""
  classNames["GdkAtom"] = ""
  classNames["GtkObject"] = ""
  classNames["GtkEditable"] = ""

  # GtkEditable is a dummy class, so we must set inheritance manually
  known_parent["GtkEntry"] = "GtkEditable"
  known_parent["GtkEditable"] = "GtkWidget"
  known_parent["GtkObject"] = "GLib.GObject"
  known_parent["GdkWindowObject"] = "GdkDrawable"

  # A couple of things that we need from GLib
  known_parent["GOptionGroup"] = "CObject"
  known_parent["GDate"] = "CObject"

  # Here starts the class hierarchy
  emitted["CObject"] = ""
  emitted["GLib.GObject"] = ""
}

{
  gsub(/[_;]/, "", $0)
  is_typedef = ($1 == "typedef")
  # is_struct = $(1+is_typedef) ~ /^(struct|union)$/
  is_struct = $(1+is_typedef) == "struct"
  if (is_typedef)
    {
      src = $(1+is_typedef+is_struct)
      dest = $(3+is_struct)

      is_vtable_decl = src ~ /(Class|Iface)$/
      is_g_name = src ~ /^(G|Pango|Atk)/
      is_pointer = dest ~ /\*/
      if (src ~ /Iface$/ && is_g_name && !is_pointer)
        known_parent[substr (dest, 1, length (dest) - 5)] = "GLib.GObject"
    }
  else if (is_struct)
    name = $2
}

is_typedef && is_struct && is_g_name && (src == dest || "_" src == dest) {
  if (!is_vtable_decl)
    classNames[src] = ""
  next
}

is_typedef && is_g_name && !is_pointer {
  # Take into account typedefs from a struct named differently.
  # We emit all these at the end, because they're often forward
  # references.
  found_synonym(src, dest)
  next
}

is_struct && (name in classNames) {
  while ($0 !~ /{/)
    read_next_line()

  read_next_line()

  if (name in known_parent)
    parent = known_parent[name]
  else {
    parent = ($1 ~ /^(G|Pango|Atk)/) && ($2 !~ /^\*/) && ($1 in emitted) ? $1 : "CObject" 
    if (parent == "GObject")
      parent = "GLib.GObject"
  }
  parse_struct(parent, name)
}

END {
  for (i in classNames)
    savedClassNames[i] = classNames[i]
  for (className in savedClassNames)
    if (className in known_parent)
      emit_struct(known_parent[className], className)
    else
      emit_struct("CObject", className)
}

# strips garbage from string
function strip( var )
{
  gsub( /[()\\,;*]/, "", var )
  return var
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

function read_next_line ()
{
  for (;;) {
    getline
    if (NF > 0)
      break
  }
}

# save and i are local variables
function emit_struct (parent, name, save, i)
{
  if (name in emitted)
    return

  delete classNames[name]

  # To fix up the big mess that is GtkEditable ensure here that we emit
  # parent classes before the children
  if (!(parent in emitted))
    {
      if (parent in known_parent)
        emit_struct(known_parent[parent], parent)
      else
	emit_struct("CObject", parent)
    }

  if (name ~ /^\*/)
    return

  emitted[name] = ""
  printf "%s variableWordSubclass: #%s\n", parent, name
  print "\tinstanceVariableNames: ''"
  print "\tclassVariableNames: ''"
  print "\tpoolDictionaries: ''"
  print "\tcategory: 'Gtk'!\n"

  save = $0
  $0 = synonyms[name]
  delete synonyms[name]
  for (i = 1; i <= NF; i++)
    emit_struct(name, $i)
  $0 = save
}

function parse_struct (parent, name)
{
  emit_struct(parent, name)

  while ($1 != "};")
    read_next_line()
}


function found_synonym(src, dest)
{
  if (src in emitted)
    emit_struct(src, dest)
  else
    synonyms[src] = synonyms[src] " " dest
}
