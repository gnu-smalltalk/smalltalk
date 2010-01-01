#######################################################################
#
#   Smalltalk Gtk+ bindings (ordering header files).
#
########################################################################

#######################################################################
#
# Copyright 2004, 2006, 2008, 2009 Free Software Foundation, Inc.
# Written by Mike Anderson and Paolo Bonzini.
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
    paths[1] = "."
    n_paths = 1
    n_prefixes = split(_prefixes, prefixes)
    split(_libs, libs)
    split(_files, files)
    for (i = 1; (i in libs); i++)
	process_lib(libs[i])
    for (i = 1; (i in files); i++)
	process_file(files[i])
    exit
}

function process_lib(lib, prog, i) {
    prog = PKG_CONFIG " --cflags " lib
    while (prog | getline)
	for (i = 1; i <= NF; i++)
	    if ($i ~ /^-I/)
	        paths[++n_paths] = substr($i, 3)
    close(prog)
}

function has_prefix(path, i) {
    for (i = 1; (i in prefixes); i++)
	if (prefixes[i] == substr(path, 0, length(prefixes[i])))
	    return 1
    return 0
}

function process_file(name, file) {
    file = find_file(name)
    if (file in processed)
	return
    processed[file] = 1
    if (file == "")
	print "error: cannot find " name
    else {
	scan(file)
        print file
    }
}

function check_file(name, ok) {
    ok = (getline < name) != -1
    close(name)
    return ok
}

function find_file(name, i) {
    if (name ~ /^\//)
	return check_file(name) ? name : ""

    for (i = 1; (i in paths); i++)
	if (check_file(paths[i] "/" name))
	    return paths[i] "/" name

    return ""
}

function scan(file, dir, incfile) {
    dir = file
    sub(/\/[^\/]*$/, "", dir)

    while (getline < file) {
	if ($1 != "#include")
	    continue
	if ($2 ~ /^</)
	    match ($0, /<[^>]*>/)
	else if ($2 ~ /^"/)
	    match ($0, /"[^>]*"/)
	incfile = substr($0, RSTART + 1, RLENGTH - 2)
	if (!has_prefix(incfile))
	    continue
	if ($2 ~ /^"/ && check_file(dir "/" incfile))
	    process_file(dir "/" incfile)
	else
	    process_file(incfile)
    }
    close(file)
}
