#! /usr/bin/awk -f
# gendoc.awk --- extract and format API comments
# Copyright (C) 1999 Gary V. Vaughan
# Originally by Gary V. Vaughan <gvv@techie.com>, 1999
# This file is part of Snprintfv.
#
# Snprintfv is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# Snprintfv is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# As a special exception to the GNU General Public License, if you
# distribute this file as part of a program that also links with and
# uses the libopts library from AutoGen, you may include it under
# the same distribution terms used by the libopts library.

# Commentary:
#
# USAGE: awk -f gendoc.awk source.c > doc.texi
#        awk [-v OPTION] -f gendoc.awk source.c > output
#
# OPTIONS:
#    debug=1		execution trace on
#    debug=<function>	execution trace while parsing <function>
#    mode=texinfo       output texinfo documentation [default]
#    mode=<header.h>	output exported function prototypes with
#			<header.h> in their keyword list (or all
#			exported functions if none cite header.h).
#    global=GLOBAL_DATA	private global data scope macro name used in
#			.c file to be replaced by...
#    scope=SCOPE	public global data scope macro name to be used
#			int generated .h file.
#    format=PRINTF	gnu printf attribute macro name [default]
#                       This macro needs to handle ANSI and GNU C.
#                       e.g. int baz PRINTF((char *format, ...), 1, 2);
#
# See the accompanying README for details of how to format function headers
# for extraction by this script.

# Todo:
#
# Support %constant to @code{constant} transform in description
# Allow non-API documentation to be embedded in source file

# Code:

BEGIN {
    program_name = "gendoc.awk";
    status = 0;			# return status

    start = 0;			# waiting for function name in header
    retcomment = 0;		# reading the description of return values
    funcdecl = 0;		# reading the function declaration

    fname = "";			# name of function under consideration
    paramname = "";		# name of parameter under consideration
    funclist = "";		# list of functions discovered so far
    argc = 0;			# parameter index

    delete comment[fname];	# full comment text for FNAME
    delete desc[fname];		# general description of FNAME
    delete keywords[fname];	# keywords associated with FUNC
    delete returnval[fname];	# description of return values from FNAME
    delete paramlist[fname];	# list of PARAMNAMES in FNAME
    delete type[fname];		# return type of FNAME
    delete param[fname,argc];	# declaration of FNAME parameter ARGC
    delete paramdesc[fname,paramname];# description of PARAMNAME in FNAME

    if (!length(mode))   mode   = "texinfo";
    if (!length(format)) format = "PRINTF";
    if (!length(global)) global = "GLOBAL_DATA";
    if (!length(scope))  scope  = "SCOPE";

    # work around a bug in mawk
    match ("abcdef", "abc");
    workaround = length(substr ("abcdef", 0, RSTART));
}

#
# Extract details from docu-comments
#
/^\/\*\*$/, /\*\/$/ {
    #
    # ignore preprocessor directives
    #
    if ($0 ~ /^[ \t]*\#/) next;

    #
    # function name in comment header
    #
    if ($0 ~ /^\/\*\*$/) {
	start = 1;		# wait for fname
	next;
    }
    if (start) {
	start = 0;		# fname found
	fname = $2;		# key for various arrays
	sub(/:$/, "", fname);	# strip trailing colon
	if (index(" " funclist " ", " " fname " ") != 0) {
	    # function has already been declared
	    printf("%s: Error: %s comment header appears twice.\n",
		   program_name, fname) | "cat >&2";
	    status = 1;
	}
	funclist = funclist " " fname;

	if (debug != 0) {
	    printf("%s: DEBUG: Function header, \"%s\" found.\n",
		   program_name, fname) | "cat >&2";
	}

	# what remains is the keyword list
	sub(fname, "");
	sub(/^[ \t]*\*+[ \t]*:?[ \t]*/, "");
	keywords[fname] = keywords[fname] " " $0;

	# start a new comment entry
	comment[fname] = "/**\n * " fname ": " keywords[fname] " \n";
	if (match(mode, /\.h$/) && index(comment[fname], " " mode " ")) {
	    # strip the .h modenames from the comment
	    sub(mode " ", "", comment[fname]);
	}
	next;
    }

    #
    # All C comment lines for this function are saved verbatim
    #
    if ($0 ~ /^[ \t]*\*/) {
	comment[fname] = comment[fname] $0 "\n";
    }
	
    #
    # parameter description
    #
    if ($0 ~ /^[ \t]*\*[ \t]*@[_a-zA-Z][_a-zA-Z0-9]*[ \t]*:/) {
	sub(/^[ \t]*\*[ \t]*@/, "");	# strip leading garbage
        sub(/[ \t]*:/, "");		# strip trailing garbage

	paramname = $1;		# extract parameter name
	sub(paramname, "");	# remove it from the description
	sub(/^[ \t]*/, "");	# strip leading whitespace
	
	if ((fname,paramname) in paramdesc) {
	    # this parameter is described twice for this function
	    printf("%s: Error: parameter \"%s\" in %s has two descriptions.\n",
		   program_name, $1, fname) | "cat >&2";
	    status = 1;
	}

	# Save the description by function name and parameter name &&
	# add this parameter name to the list of names for this function
	paramdesc[fname,paramname] = $0;
	paramlist[fname] = paramlist[fname] " " paramname;

	if (debug == 1 || index(debug, fname) != 0) {
	    printf("%s: DEBUG(%s): Description for parameter \"%s\" found:\n" \
		   "\t>%s<\n", program_name, fname, paramname,
		   paramdesc[fname, paramname]) | "cat >&2";
	}

	next;
    }

    #
    # function declaration to follow comment end.
    #
    if ($0 ~ /^[ \t]*\*+\//) {
	if (debug == 1 || index(debug, fname) != 0) {
	    printf("%s: DEBUG(%s): end of comment header reached.\n",
		   program_name, fname) | "cat >&2";
	}

	retcomment = 0;		# no longer reading return values comment
	funcdecl = 1;		# wait for function declaration

	next;
    }

    #
    # return value description
    # Note that we are careful to leave leading tab characters, which
    # indicate that what follows is formatted code.
    #
    if ($0 ~ /^[ \t]*\*[ \t]*[Re]eturn [Vv]alues?[ \t]*:/) {
	retcomment = 1;
	if (debug == 1 || index(debug, fname) != 0) {
	    printf("%s: DEBUG(%s): start of returnval description reached\n",
		   program_name, fname) | "cat >&2";
	}
    }
    if (retcomment == 1) {
	sub(/^[ \t]*\* */, "");
	sub(/^[ \t]*[Rr]eturn [Vv]alues?[ \t]*:[ \t]*/, "");

	if (debug == 1 || index(debug, fname) != 0) {
	    printf("%s: DEBUG(%s): return value description section found:\n" \
		   "\t>%s<\n", program_name, fname, $0) | "cat >&2";
	}

	if (length() > 0 || length(returnval[fname]) > 0) {
	    returnval[fname] = returnval[fname] $0 "\n";

	    if (debug == 1 || index(debug, fname) != 0) {
		printf("%s: DEBUG(%s): ...and added!\n",
		       program_name, fname) | "cat >&2";
	    }
	}
	next;
    }

    #
    # Other commented lines must be part of the description
    # Note that we are careful to leave leading tab characters, which
    # indicate that what follows is formatted code.
    #
    if ($0 ~ /^[ \t]*\*([^\/]|$)/) {
	sub(/^[ \t]*\* */, "");

	if (debug == 1 || index(debug, fname) != 0) {
	    printf("%s: DEBUG(%s): function description found:\n\t>%s<\n",
		   program_name, fname, $0) | "cat >&2";
	}

        if (length() > 0 || length(desc[fname]) > 0) {
	    desc[fname] = desc[fname] $0 "\n";

	    if (debug == 1 || index(debug, fname) != 0) {
		printf("%s: DEBUG(%s): ...and added!\n",
		       program_name, fname) | "cat >&2";
	    }
	}

	next;
    }
}


#
# Extract details from declaration/prototype
#
funcdecl>0 {
    if (debug == 1 || index(debug, fname) != 0) {
	printf("%s: DEBUG(%s): attempting declaration extraction:\n" \
	       "\t>%s<\n",
	       program_name, fname, $0) | "cat >&2";
    }

    #
    # first following line is return type in a c file, or a prototype
    # or a variable or macro in a generated header.
    #
    if (funcdecl == 1) {

	# strip private global data macro
	global_re = "[ \t]*(extern[ \t]+)?" global "[ \t]+";
	if ($0 ~ global_re) {
	    sub(global_re, "");
	    keywords[fname] = keywords[fname] " global";

	    if (debug == 1 || index(debug, fname) != 0) {
		printf("%s: DEBUG(%s): global data declaration found:\n" \
		       "\t>%s<\n",
		       program_name, fname, $0) | "cat >&2";
	    }

	    type[fname] = $0;
	    sub(/[ \t]+[a-zA-Z_][a-zA-Z_0-9]*;$/, "", type[fname]);
	    
	    decl[fname] = $0;
	}
	# Function pointer typedef
	else if ($0 ~ /^[ \t]*typedef[ \t]+.*\);[ \t]*$/) {
	    keywords[fname] = keywords[fname] " functionpointer typedef";

	    if (debug == 1 || index(debug, fname) != 0) {
		printf("%s: DEBUG(%s): function pointer typedef found:\n" \
		       "\t>%s<\n",
		       program_name, fname, $0) | "cat >&2";
	    }

	    # remove parentheses and asterisk for function pointer
	    pointer = match($0, /\(\*[A-Za-z0-9_]*\)/)
	    if (pointer) {
	        $0 = substr($0, 1, RSTART - 1) \
	             substr($0, RSTART + 2, RLENGTH - 3) \
	             substr($0, RSTART + RLENGTH);
	    }

	    # Extract return type
	    type[fname] = $0;
	    sub(/^[ \t]*typedef[ \t]+/, "", type[fname]); # strip "typedef"
	    sub(/[ \t]+[A-Z_]*P[A-Z]* *\(\(/, " (", type[fname]); # and __P/PARAMS macro
	    sub(/[ \t]*[(].*$/, "", type[fname]); # strip arguments
	    sub(/[ \t]*[_A-Za-z][_A-Za-z0-9]*[ \t]*$/, "", type[fname]);

	    # Extract parameter declarations
	    sub(/^[^(]*\(+/, "");	# strip leading garbage
	    sub(/\).*$/, "");		# strip trailing garbage

	    # populate the function's param array
	    argc = split($0, params, /,[ \t]*/);
	    if (pointer) {
	       decl[fname] = type[fname] " (*" fname ") (";
	    } 
	    else {
	       decl[fname] = type[fname] " " fname " (";
	    }

	    for (i = 1; i <= argc; i++) {
		if (debug == 1 || index(debug, fname) != 0) {
		    printf("\tparam%d: >%s<\n", i, params[i]) | "cat >&2";
		}
		param[fname,i -1] = params[i];
		decl[fname] = decl[fname] param[fname, i -1];
		if (i < argc) {
		    decl[fname] = decl[fname] ", ";
		}
		delete params[i];
	    }
	    decl[fname] = decl[fname] ")";

	    param[fname, argc] = "NULL";
	    if (debug == 1 || index(debug, fname) != 0) {
		printf("\tparam%d: >%s<\n",
		       argc +1, param[fname, argc]) | "cat >&2";
	    }

	}
	# Typedef declaration
	else if ($0 ~ /^[ \t]*typedef[ \t]+/) {
	    keywords[fname] = keywords[fname] " typedef";

	    if (debug == 1 || index(debug, fname) != 0) {
		printf("%s: DEBUG(%s): type definition found:\n" \
		       "\t>%s<\n",
		       program_name, fname, $0) | "cat >&2";
	    }
	    decl[fname] = fname;
	}
	# Macro function
	else if ($0 ~ /^\#[ \t]*define[ \t]+[_A-Za-z0-9]+\(/) {
	    keywords[fname] = keywords[fname] " macro";

	    if (debug == 1 || index(debug, fname) != 0) {
		printf("%s: DEBUG(%s): macro function definition found:\n" \
		       "\t>%s<\n",
		       program_name, fname, $0) | "cat >&2";
	    }
	    sub(/^[^(]*\(+/, "");	# strip leading garbage
	    sub(/\).*$/, "");		# strip trailing garbage

	    # populate the macro's param array
	    argc = split($0, params, /,[ \t]*/);
	    decl[fname] = fname "(";
	    for (i = 1; i <= argc; i++) {
		if (debug == 1 || index(debug, fname) != 0) {
		    printf("\tparam%d: >%s<\n", i, params[i]) | "cat >&2";
		}
		param[fname,i -1] = params[i];
		decl[fname] = decl[fname] param[fname, i -1];
		if (i < argc) {
		    decl[fname] = decl[fname] ", ";
		}
		delete params[i];
	    }
	    decl[fname] = decl[fname] ")";

	    param[fname, argc] = "NULL";
	    if (debug == 1 || index(debug, fname) != 0) {
		printf("\tparam%d: >%s<\n",
		       argc +1, param[fname, argc]) | "cat >&2";
	    }

	}
	# Macro alias
	else if ($0 ~ /^\#[ \t]*define[ \t]+[_A-Za-z0-9]+[ \t]+/) {
	    keywords[fname] = keywords[fname] " alias";

	    if (debug == 1 || index(debug, fname) != 0) {
		printf("%s: DEBUG(%s): macro alias definition found:\n" \
		       "\t>%s<\n",
		       program_name, fname, $0) | "cat >&2";
	    }
	    decl[fname] = fname;
	}
	# Function prototype
	else if ($0 ~ /^[ \t]*(extern)?[ \t]*.*\);?[ \t]*$/) {
	    sub(/^[ \t]*extern[ \t]*/, "");	# strip leading extern keyword
	    sub(/[ \t]+[A-Z_]*P[A-Z]*\(\(/, " ("); # and __P/PARAMS macro
	    sub(/[ \t]*\)\)[ \t]*;?[ \t]*$/, ")"); # and trailing garbage

	    if (debug == 1 || index(debug, fname) != 0) {
		printf("%s: DEBUG(%s): ANSI prototype found:\n" \
		       "\t>%s<\n",
		       program_name, fname, $0) | "cat >&2";
	    }

	    type[fname] = $0;
	    sub(/^[ \t]*inline[ \t]*/, "", type[fname]);
	    type[fname] = substr(type[fname], 1,
				 match(type[fname], /[ \t]*\(/) -1);
	    sub(/[ \t][a-zA-Z0-9_]+$/, "", type[fname]);
	    if (debug == 1 || index(debug, fname) != 0) {
		printf("\ttype: >%s<\n", type[fname]) | "cat >&2";
	    }
	    
	    decl[fname] = $0;

	    sub(/^.*\(+/, "");	   # strip leading garbage
	    sub(/(\)[0-9, \t]*)?\);*[ \t]*$/, ""); # strip trailing garbage

	    # populate the functions param array
	    argc = split($0, params, /,[ \t]*/);
	    for (i = 1; i <= argc; i++) {
		if (debug == 1 || index(debug, fname) != 0) {
		    printf("\tparam%d: >%s<\n", i, params[i]) | "cat >&2";
		}
		param[fname,i -1] = params[i];
		delete params[i];
	    }
	    param[fname, argc] = "NULL";
	    if (debug == 1 || index(debug, fname) != 0) {
		printf("\tparam%d: >%s<\n",
		       argc +1, param[fname, argc]) | "cat >&2";
	    }
	}
	# ignore other preprocessor directives
	else if ($0 ~ /^[ \t]*\#/)
	{
	    next;
	}
	# assume return type line from a function definition
	else
	{
	    if (debug == 1 || index(debug, fname) != 0) {
		printf("%s: DEBUG(%s): return type declaration found:\n" \
		       "\t>%s<\n",
		       program_name, fname, $0) | "cat >&2";
	    }
	    
	    funcdecl = 2;		# wait for function prototype
	    argc = 0;

	    type[fname] = $0;
	    decl[fname] = "extern " $0 " " fname;

	    if (debug == 1 || index(debug, fname) != 0) {
		printf("%s: DEBUG(%s): ...and added, \"%s\"!\n",
		       program_name, fname, $0) | "cat >&2";
	    }
	    next;
	}

	if (debug == 1 || index(debug, fname) != 0) {
	    printf("%s: DEBUG(%s): full declaration generated:\n" \
		   "\t>%s<\n",
		   program_name, fname, decl[fname]) | "cat >&2";
	}

	funcdecl = 0;
	next;
    }
    if ($0 ~ /^[ \t]*\#/)	# skip any preprocessor when funcdecl > 1
    {
	next;
    }
    if (funcdecl == 2) {	# second line contains function name @ $1
	if ($0 ~ /\(.*[A-Za-z_]+[* \t]+[_A-Za-z]+/ || $0 ~ /\([ \t]*void/) {
	    # We have just seen two consecutive keywords or "void", both of
	    # which mark an ANSI declaration, and need to reset for the next
	    # header
	    funcdecl = 0;

	    # Is this a printf attributable prototype?  Look for
	    # ``format,'' in the penultimate argument:
	    use_format=0;
	    if ($0 ~ /[^a-zA-Z_]format,[ \t]*\.\.\.\)$/) {
	        use_format=1;
	    }

	    sub(/^.*\(+/, "");	  # strip leading garbage
	    sub(/\)+[ \t]*$/, ""); # strip trailing garbage
	    argc = split($0, params, /,[ \t]*/);

	    if (index(debug, fname) != 0) {
		printf("%s: DEBUG(%s): checking param %d, \"%s\".\n",
		       program_name, fname, argc, params[argc -1]) | "cat >&2";
	    }

	    if (use_format == 1  && (debug == 1 || index(debug, fname) != 0)) {
		printf("%s: DEBUG(%s): printf function declaration found:\n" \
			   "\t>%s<\n",
			   program_name, fname, $0) | "cat >&2";
	    }
	    
	    if (use_format == 0  && (debug == 1 || index(debug, fname) != 0)) {
		printf("%s: DEBUG(%s): ANSI function declaration found:\n" \
		       "\t>%s<\n",
		       program_name, fname, $0) | "cat >&2";
	    }

	    # populate the function's param array and decl entry
	    if (use_format) {
	        decl[fname] = decl[fname] " " format "((";
	    } else {
	        decl[fname] = decl[fname] " (";
	    }
	    for (i = 1; i <= argc; i++) {
		if (debug == 1 || index(debug, fname) != 0) {
		    printf("\tparam%d: >%s<\n", i, params[i]) | "cat >&2";
		}
		decl[fname] = decl[fname] params[i];
		if (i < argc) {
		    decl[fname] = decl[fname] ", ";
		}
		param[fname,i -1] = params[i];
		delete params[i];
	    }
	    param[fname, argc] = "NULL";
	    if (argc == 0)
		decl[fname] = decl[fname] "void";

	    if (use_format) {
	        decl[fname] = decl[fname] "), " (argc -1) ", " argc ");\n";
	    } else {
	        decl[fname] = decl[fname] ");\n";
	    }

	    if (debug == 1 || index(debug, fname) != 0) {
		printf("\tparam%d: >%s<\n",
		       argc +1, param[fname, argc]) | "cat >&2";
	    }
	    funcdecl = 0;
	}
	else
	{
	    if (debug == 1 || index(debug, fname) != 0) {
		printf("%s: DEBUG(%s): K&R function declaration found:\n" \
		       "\t>%s<\n",
		       program_name, fname, $0) | "cat >&2";
	    }
	    funcdecl = 3;
	    argc = 0;
	}
	
	next;
    }
    if (funcdecl == 3) {	# the rest are K&R parameter declarations
        if ($0 ~ /^[ \t]*[{]/) {
	    # We have just seen the "{" which marks the start of the
	    # function body, and need to reset for the next header
	    funcdecl = 0;
	    decl[fname] = decl[fname] " (";
	    for (i = 0; i < argc; i++) {
		decl[fname] = decl[fname] param[fname,i];
		if (param[fname,i +1] != "NULL") {
		    decl[fname] = decl[fname] ", ";
		}
	    }
	    if (argc == 0)
		decl[fname] = decl[fname] "void";

	    decl[fname] = decl[fname] ");";

	    if (debug == 1 || index(debug, fname) != 0) {
		printf("%s: DEBUG(%s): full declaration generated:\n" \
		       "\t>%s<\n",
		       program_name, fname, decl[fname]) | "cat >&2";
	    }

	    next;
	}
	    
	# We did not see the "{" yet, so this must be another parameter
	# declaration.
	sub(/^[ \t]*/, "");	# strip leading garbage
        sub(/[ \t]*;.*$/,"");	# strip trailing garbage
	param[fname,argc] = $0;
	argc++;
	param[fname,argc] = "NULL"; # used as an end marker

	if (debug == 1 || index(debug, fname) != 0) {
	    printf("%s: DEBUG(%s): parameter declaration found:\n" \
		   "\t>%s<\n",
		   program_name, fname, $0) | "cat >&2";
	}

	next;
    }
}

END {
    # TODO: optionally output html or nroff instead of texi

    #
    # Print formatted C header code for each function described
    #
    if ((status == 0) && (match(mode, /\.h$/))) {
	# split out the function names we found during parsing
	func_count = split(funclist, funcs);

	# select the functions with the destination in their keywords
	# (or else all functions if none name the destination).
	newlist = "";
	for (count = 1; count <= func_count; count++) {
	    if (index(" " keywords[funcs[count]] " ", " " mode " ")) {
		newlist = newlist funcs[count] " ";
	    }
	}
	if (length(newlist)) {
	    funclist = newlist;
	    func_count = split(funclist, funcs); 
	}

	for (count = 1; count <= func_count; count++) {
	    fname = funcs[count];

	    print comment[fname] decl[fname] "\n";
	}
    }
	
    #
    # Print texinfo formatted blocks for each element described
    #
    if ((status == 0) && (mode == "texinfo")) {
	# split out the function names we found during parsing
	func_count = split(funclist, funcs);

	# reorder the funclist to put typedefs first, constructors next,
	# destructors after that and the rest following on
	funclist = "";
	for (count = 1; count <= func_count; count++) {
	    if (index(" " keywords[funcs[count]] " ", " typedef "))
	    {
		funclist = funclist funcs[count] " ";
	    }
	}
	for (count = 1; count <= func_count; count++) {
	    if ((index(" " keywords[funcs[count]] " ", " constructor ")) &&
		(index(" " keywords[funcs[count]] " ", " typedef ")    == 0))
	    {
		funclist = funclist funcs[count] " ";
	    }
	}
	for (count = 1; count <= func_count; count++) {
	    if ((index(" " keywords[funcs[count]] " ", " destructor ")) &&
		(index(" " keywords[funcs[count]] " ", " typedef ")    == 0))
	    {
		funclist = funclist funcs[count] " ";
	    }
	}
	for (count = 1; count <= func_count; count++) {
	    if ((index(" " keywords[funcs[count]] " ", " constructor ")== 0)&&
		(index(" " keywords[funcs[count]] " ", " destructor ") == 0)&&
		(index(" " keywords[funcs[count]] " ", " typedef ")    == 0))
	    {
		funclist = funclist funcs[count] " ";
	    }
	}
	func_count = split(funclist, funcs);

	for (count = 1; count <= func_count; count++) {
	    fname = funcs[count];

	    # split out the parameter names for this function
	    argc = split(paramlist[fname], funcparam);

	    # replace {, } and @ with @{, @} and @@ repectively
	    for (i = 1; i <= argc; i++) {
		paramname = funcparam[i];
		gsub(/@/, "@@", paramdesc[fname, paramname]);
		gsub(/[{]/, "@{", paramdesc[fname, paramname]);
		gsub(/[}]/, "@}", paramdesc[fname, paramname]);
		gsub(/[a-zA-Z_][a-zA-Z0-9_]*\(\)/, "@code{&}",
		     paramdesc[fname, paramname]);
	    }
	    gsub(/@/, "@@", desc[fname]);
	    gsub(/[{]/, "@{", desc[fname]);
	    gsub(/[}]/, "@}", desc[fname]);
	    gsub(/[a-zA-Z_][a-zA-Z0-9_]*\(\)/, "@code{&}", desc[fname]);

	    gsub(/@/, "@@", returnval[fname]);
	    gsub(/[{]/, "@{", returnval[fname]);
	    gsub(/[}]/, "@}", returnval[fname]);
	    gsub(/[a-zA-Z_][a-zA-Z0-9_]*\(\)/, "@code{&}", returnval[fname]);

	    # rewrite decl[fname] in a format suitable for texinfo
	    if (index(" " keywords[funcs[count]] " ", " alias ") ||
		(index(" " keywords[funcs[count]] " ", " typedef ") &&
		 index(" " keywords[funcs[count]] " ", " funcpointer ") == 0))
	    {
		# decl[fname] is already correct!
	    }
	    else
	    {
		decl[fname] = type[fname] " " fname " (";
		sub(/^[ \t]*inline[ \t]*/, "", decl[fname]);
		for (i = 0; i < argc; i++) {
		    decl[fname] = decl[fname] param[fname,i];
		    if (param[fname,i +1] != "NULL") {
			decl[fname] = decl[fname] ", ";
		    }
		}
		decl[fname] = decl[fname] ")";
	    }

	    # replace all references to named params with @var{param}
	    for (i = 1; i <= argc; i++) {
		paramname = funcparam[i];

		# Oh god!  gensub is a GNU extension =(O|
		# Here is a hacky reimplementation using match
    		source = decl[fname];
		dest = "";
		while (match(source, paramname)) {
		    prechar="<"; # dummy so that start of string will work
		    postchar=">"; # dummy for end of string
		    if (RSTART > 1) {
			prechar = substr(source, RSTART -1, 1);
		    }
		    if (RSTART + RLENGTH < length (source)) {
			postchar = substr(source, RSTART + RLENGTH, 1);
		    }
		    dest = dest substr(source, 0, RSTART - workaround);
		    source = substr(source, RSTART + RLENGTH); 
		    if (match(prechar, /[^A-Za-z0-9_]/) \
			&& match(postchar, /[^A-Za-z0-9_]/)) {
			dest = dest "@var{" paramname "}";
		    } else {
			dest = dest paramname;
		    }
		}
		decl[fname] = dest source;

		for (j = 1; j <= argc; j++) {
		    descname = funcparam[j];
		    gsub("@@" paramname, "@var{" paramname "}",
			 paramdesc[fname, descname]);
		}
		gsub("@@" paramname, "@var{" paramname "}", desc[fname]);
		gsub("@@" paramname, "@var{" paramname "}", returnval[fname]);
	    }
	   
	    # @deftypefn Category
	    if (index(" " keywords[funcs[count]] " ", " alias ") ||
		index(" " keywords[funcs[count]] " ", " macro ")) {
		printf "@deffn Macro " decl[fname] "\n";
	    }
	    else if (index(" " keywords[funcs[count]] " ", " functionpointer "))
	    {
		printf "@deftypefn Typedef " decl[fname] "\n";
	    }
	    else if (index(" " keywords[funcs[count]] " ", " typedef "))
	    {
		printf "@deffn Typedef " decl[fname] "\n";
	    }
	    else
	    {
		printf "@deftypefn Function " decl[fname] "\n";
	    }
	    print "@fnindex " fname "\n";
	    
	    # param descriptions
	    if (argc) {
	        print index (decl[fname], "(") ? "Parameters:" : "Fields:";
	        print "@table @code";
	        for (i = 1; i <= argc; i++) {
		    paramname = funcparam[i];
		    if ((fname, paramname) in paramdesc) {
		        print "@item " paramname;
		        print paramdesc[fname,paramname];
		    } else {
		        # No description was given for this parameter
		        printf("%s: Warning: No description for \"%s\" in %s.\n",
			       program_name, paramname, fname) | "cat >&2";
		    }
	        }
	        print "@end table\n";
	    }

	    # function description
	    # lines starting with a tab represent preformatted code.
	    argc = split(desc[fname], lines, "\n");
	    code = 0;		# are we in a code section?
	    blanks = 0;		# how many blank lines (of undetermined type)
	    for (i = 1; i <= argc; i++) {
	        # %word becoming @code{}
    	        source = lines[i];
	        dest = "";
	        while (match(source, /%[-+*\/%<>!=()A-Za-z0-9_\\\'\"]+/)) {
		    postchar="$"; # dummy for end of string
		    if (RSTART + RLENGTH < length (source)) {
		        postchar = substr(source, RSTART + RLENGTH, 1);
		    }
		    dest = dest substr(source, 0, RSTART - workaround);
		    matched = substr(source, RSTART + 1, RLENGTH - 1); 
		    source = substr(source, RSTART + RLENGTH); 
		    if (match(postchar, /[^A-Za-z0-9_]/)) {
		        dest = dest "@code{" matched "}";
		    } else {
		        dest = dest "%" matched;
		    }
	        }
		dest = dest source;

		if (code == 0) {
		    if (dest ~ /^\t[ \t]*[^ \t]/) {
			code = 1;
			print "@smallexample"
			sub(/^\t/, "", dest);
		    }
		    print dest;
		} else {
		    if (dest ~ /^[^\t]/ && dest !~ /^[\t ]*$/) {
			code = 0;
			print "@end smallexample";
			print  dest;
		    } else {
			sub(/^\t/, "", dest);
			if (dest ~ /^[ \t]*$/) {
			    blanks++;
			} else {
			    while (blanks > 0) {
				print;
				blanks--;
			    }
			    print dest;
			}
		    }
		}
	    }
	    if (code == 1) {
		print "@end smallexample\n";
	    }

	    # return value description
	    if (!fname in returnval && type[fname] !~ /[ \t]*void[ \t]*/) {
		# No return value section was found for non-void function
		printf("%s: Warning: No return value for \"%s\".\n",
		       program_name, fname) | "cat >&2";
	    }

	    # lines starting with a tab represent preformatted code.
	    argc = split(returnval[fname], lines, "\n");
	    code = 0;		# are we in a code section?
	    blanks = 0;		# how many blank lines (of undetermined type)
	    for (i = 1; i <= argc; i++) {
	        # %word becoming @code{}
    	        source = lines[i];
	        dest = "";
	        while (match(source, /%[-+*\/%<>!=()A-Za-z0-9_\\\"\']+/)) {
		    postchar="$"; # dummy for end of string
		    if (RSTART + RLENGTH < length (source)) {
		        postchar = substr(source, RSTART + RLENGTH, 1);
		    }
		    dest = dest substr(source, 0, RSTART - workaround);
		    matched = substr(source, RSTART + 1, RLENGTH - 1); 
		    source = substr(source, RSTART + RLENGTH); 
		    if (match(postchar, /[^A-Za-z0-9_]/)) {
		        dest = dest "@code{" matched "}";
		    } else {
		        dest = dest "%" matched;
		    }
	        }
		dest = dest source;

		if (code == 0) {
		    if (dest ~ /^\t[ \t]*[^ \t]/) {
			code = 1;
			print "@smallexample"
			sub(/^\t/, "", dest);
		    }
		    print dest;
		} else {
		    if (dest ~ /^[^\t]/ && dest !~ /^[\t ]*$/) {
			code = 0;
			print "@end smallexample\n";
			print dest;
		    } else {
			sub(/^\t/, "", dest);
			if (dest ~ /^[ \t]*$/) {
			    blanks++;
			} else {
			    while (blanks > 0) {
				print;
				blanks--;
			    }
			    print dest;
			}
		    }
		}
	    }
	    if (code == 1) {
		print "@end smallexample";
	    }

	    if (index(" " keywords[funcs[count]] " ", " functionpointer "))
	    {
		print "@end deftypefn\n";
	    }
	    else if (index(" " keywords[funcs[count]] " ", " alias ") ||
		index(" " keywords[funcs[count]] " ", " macro ") ||
		index(" " keywords[funcs[count]] " ", " typedef ")) {
		print "@end deffn\n";
	    }
	    else
	    {
		print "@end deftypefn\n";
	    }
	}
    }

    # Keep lint happy:
    close("cat >&2");
    
    exit status;
}

# gendoc.awk ends here
