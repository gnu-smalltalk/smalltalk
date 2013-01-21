"======================================================================
|
|   Smalltalk command-line parser
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2006 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
|
| This file is part of the GNU Smalltalk class library.
|
| The GNU Smalltalk class library is free software; you can redistribute it
| and/or modify it under the terms of the GNU Lesser General Public License
| as published by the Free Software Foundation; either version 2.1, or (at
| your option) any later version.
| 
| The GNU Smalltalk class library is distributed in the hope that it will be
| useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
| MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
| General Public License for more details.
| 
| You should have received a copy of the GNU Lesser General Public License
| along with the GNU Smalltalk class library; see the file COPYING.LIB.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



SystemDictionary extend [

    arguments: pattern do: actionBlock [
	"Parse the command-line arguments according to the syntax specified in
	 pattern.  For every command-line option found, the two-argument block
	 actionBlock is evaluated passing the option name and the argument.  For
	 file names (or in general, other command-line arguments than options) the
	 block's first argument will be nil.  For options without arguments, or with
	 unspecified optional arguments, the block's second argument will be nil.
	 The option name will be passed as a character object for short options,
	 and as a string for long options.
	 
	 If an error is found, nil is returned.  For more information on the syntax
	 of pattern, see #arguments:do:ifError:."

	<category: 'command-line'>
	Getopt 
	    parse: self arguments
	    with: pattern
	    do: actionBlock
	    ifError: [^nil]
    ]

    arguments: pattern do: actionBlock ifError: errorBlock [
	"Parse the command-line arguments according to the syntax specified in
	 pattern.  For every command-line option found, the two-argument block
	 actionBlock is evaluated passing the option name and the argument.  For
	 file names (or in general, other command-line arguments than options) the
	 block's first argument will be nil.  For options without arguments, or with
	 unspecified optional arguments, the block's second argument will be nil.
	 The option name will be passed as a character object for short options,
	 and as a string for long options.
	 
	 If an error is found, the parsing is interrupted, errorBlock is evaluated,
	 and the returned value is answered.
	 
	 Every whitespace-separated part (`word') of pattern specifies a command-line
	 option.  If a word ends with a colon, the option will have a mandatory argument.
	 If a word ends with two colons, the option will have an optional argument.
	 Before the colons, multiple option names (either short names like `-l' or
	 long names like `--long') can be specified.  Before passing the option to
	 actionBlock, the name will be canonicalized to the last one.
	 
	 Prefixes of long options are accepted as long as they're unique, and they are
	 canonicalized to the full name before passing it to actionBlock.  Additionally,
	 the full name of an option is accepted even if it is the prefix of a longer
	 option.
	 
	 Mandatory arguments can appear in the next argument, or in the same argument
	 (separated by an = for arguments to long options).  Optional arguments must
	 appear in the same argument."

	<category: 'command-line'>
	Getopt 
	    parse: self arguments
	    with: pattern
	    do: actionBlock
	    ifError: [^errorBlock value]
    ]

]

