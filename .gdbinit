#######################################################################
#
#   gdb user-defined commands to debug GNU Smalltalk.
#
########################################################################


#######################################################################
#
# Copyright 2004, 2006, 2007, 2009 Free Software Foundation, Inc.
# Written by Paolo Bonzini
#
# This file is part of GNU Smalltalk.
#
# GNU Smalltalk is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
# 
# GNU Smalltalk is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with GNU Smalltalk; see the file COPYING.  If not, write to the
# Free Software Foundation, 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301, USA.  
#
########################################################################


# Commands to invoke debugging routines
# ------------------------------------------------------

define ststack
set unwindonsignal on
call _gst_show_stack_contents ()
call (void)fflush(stdout)
set unwindonsignal off
end
document ststack
Print the contents of the stack of the currently executing method.
end

define stprocs
set unwindonsignal on
call _gst_print_process_state ()
call (void)fflush(stdout)
set unwindonsignal off
end
document stprocs
Print the state of the Smalltalk processes.
end

define stbt
set unwindonsignal on
call _gst_show_backtrace (stdout)
call (void)fflush(stdout)
set unwindonsignal off
end
document stbt
Print the backtrace of the currently running Smalltalk process.
end


# Commands to print the contents of Smalltalk objects
# ------------------------------------------------------

define po
set unwindonsignal on
call _gst_print_object($arg0)
call (void)fflush(stdout)
set unwindonsignal off
printf "\n"
end
document po
Print a representation of a Smalltalk object.

Syntax: po EXPR
end


define pfield
p (($arg0)((OOP)$arg1)->object)->$arg2
end
document pfield
Access a field of a Smalltalk object and print its OOP.
The printed value is a C pointer and is put in the history.
CLASS is a C pointer type which has a member named FIELD.

Syntax: pfield CLASS OBJECT FIELD
end


define ofield
po (($arg0)((OOP)$arg1)->object)->$arg2
end
document ofield
Access a field of a Smalltalk object and print its contents.
The printed value is a user-readable representation and, as such,
cannot be put in the history.  CLASS is a C pointer type which
has a member named FIELD.

Syntax: ofield CLASS OBJECT FIELD
end


define pofield
call _gst_print_object((($arg0)((OOP)$arg1)->object)->$arg2)
printf "  "
p (($arg0)((OOP)$arg1)->object)->$arg2
end
document pofield
Access a field of a Smalltalk object and print its contents.
The first printed value is a user-readable representation, while
the second is a C pointer which is put in the history.  CLASS is
a C pointer type which has a member named FIELD.

Syntax: pofield CLASS OBJECT FIELD
end


# Commands to print several common Smalltalk objects
# ------------------------------------------------------

define passoc
printf "Key: "
pofield gst_association $arg0 key
printf "Value: "
pofield gst_association $arg0 value
end
document passoc
Print the key and value of an Association object.
The two items are printed with pofield, hence storing two values in
the history.

Syntax: passoc OBJECT
end


define pmeth
printf "Selector: "
pofield gst_method_info ((gst_compiled_method)$arg0->object)->descriptor selector
printf "Class: "
pofield gst_method_info ((gst_compiled_method)$arg0->object)->descriptor class
end
document pmeth
Print the selector and class of a CompiledMethod object.
The values are printed with pofield, hence storing two values in
the history.

Syntax: pmeth OBJECT
end


define pblock
printf "Method: "
pofield gst_compiled_block $arg0 method
printf "Selector: "
pofield gst_method_info ((gst_compiled_method)$->object)->descriptor selector
printf "Class: "
pofield gst_method_info ((gst_compiled_method)$$->object)->descriptor class
end
document pblock
Print the home method, selector and class of a CompiledBlock object.
The values are printed with pofield, hence storing three values in
the history.

Syntax: pblock OBJECT
end


define pbctx
printf "Parent: "
pofield gst_block_context $arg0 parentContext
printf "Block: "
pofield gst_block_context $arg0 method
pblock $
printf "IP: "
ofield gst_block_context $arg0 ipOffset
end
document pbctx
Print the block, method, selector and class of a BlockContext object.
The values are printed with pofield, hence storing four values in
the history.  The instruction pointer is also printed but not stored
in the history.

Syntax: pbctx OBJECT
end


define pmctx
printf "Parent: "
pofield gst_method_context $arg0 parentContext
printf "Method: "
pofield gst_method_context $arg0 method
pmeth ((gst_method_context)$arg0->object)->method
printf "IP: "
ofield gst_method_context $arg0 ipOffset
end
document pmctx
Print the method, selector and class of a MethodContext object.
The values are printed with pofield, hence storing three values in
the history.  The instruction pointer is also printed but not stored
in the history.

Syntax: pmctx OBJECT
end



# Initializing gdb
# ------------------------------------------------------

handle SIGSEGV noprint
handle SIGUSR2 noprint

# Don't let abort actually run, as it will make stdio
# stop working and therefore the commands above as well.
b abort
