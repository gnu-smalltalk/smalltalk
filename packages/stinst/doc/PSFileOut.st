"======================================================================
|
|   File out PostScript method definitions.
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2009 Free Software Foundation, Inc.
| Written by Steve Byrne.
|
| This file is part of GNU Smalltalk.
|
| GNU Smalltalk is free software; you can redistribute it and/or modify it
| under the terms of the GNU General Public License as published by the Free
| Software Foundation; either version 2, or (at your option) any later version.
|
| GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
| ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
| FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
| details.
|
| You should have received a copy of the GNU General Public License along with
| GNU Smalltalk; see the file COPYING.	If not, write to the Free Software
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
|
 ======================================================================"


ClassPublisher subclass: PSFileOutPublisher [
    
    <category: 'Examples-File out'>
    <comment: nil>

    emitCategory: category [
	"I write Postscript for legal Smalltalk load syntax definitions of all of my methods
	 are in the 'category' category"

	<category: 'subclassed'>
	self
	    nextPutAll: 'italic setfont';
	    nl;
	    nextPutAll: '(!';
	    print: self class;
	    nextPutAll: ' methodsFor: ';
	    store: category;
	    nextPutAll: '!)';
	    nextPutAll: ' show ';
	    nl.
	self methodDictionary 
	    do: [:method | method methodCategory = category ifTrue: [self emitMethod: method]].
	self nextPutAll: '(!) show newline
newline newline
'
    ]

    emitMethod: method [
	"I emit valid PostScript for method's source code."

	<category: 'subclassed'>
	| data |
	method methodSourceString isNil ifTrue: [^self].
	data := self selectorAndBody: method methodSourceString.
	self
	    nextPutAll: 'newline newline';
	    nl;
	    nextPutAll: 'bold setfont';
	    nl;
	    emitLines: (data at: 1);
	    nextPutAll: 'normal setfont';
	    nl;
	    emitLines: (data at: 2);
	    nextPutAll: '(! ) show ';
	    nl
    ]

    escaped [
	"Answer a set of characters that must be passed through #printEscaped: -
	 i.e. ( and )"

	<category: 'subclassed'>
	^'()'
    ]

    printEscaped: ch [
	"Put a \ before ( and ) characters."

	<category: 'subclassed'>
	self
	    nextPut: $\;
	    nextPut: ch
    ]

    emitLines: string [
	"Print string, a line at a time"

	<category: 'subclassed'>
	string linesDo: 
		[:line | 
		self
		    nextPut: $(;
		    nextPutAllText: line;
		    nextPutAll: ') show newline';
		    nl]
    ]

    emitFooter [
	"I emit a valid Postscript footer."

	<category: 'subclassed'>
	self
	    nextPutAll: 'finish';
	    nl
    ]

    emitHeader: now [
	"I emit a valid Postscript header for the file-out."

	<category: 'subclassed'>
	| stream |
	stream := WriteStream on: (String new: 200).
	self currentClass fileOutDeclarationOn: stream.
	self
	    nextPutAll: self header;
	    nextPutAll: 'normal setfont';
	    nl;
	    nextPutAll: '(''Filed out from ';
	    nextPutAll: Smalltalk version;
	    nextPutAll: ' on ';
	    print: (now at: 1);
	    nextPutAll: '	';
	    print: (now at: 2);
	    nextPutAll: ' ''!)';
	    nextPutAll: ' show newline newline';
	    nl;
	    nl;
	    emitLines: stream contents;
	    nextPutAll: '() show newline newline';
	    nl;
	    nl
    ]

    header [
	<category: 'PostScript'>
	^'%!

%%%
%%% User settable parameters
%%%

/fontSize 10 def
/leading 2 def
/indent 10 def


%%%
%%% End of user settable parameters
%%%

clippath pathbbox
  /uy exch def
  /ux exch def
  /ly exch def
  /lx exch def


/lineHeight fontSize leading add def

/ystart uy lineHeight sub def
/ypos ystart def

/linecounter 0 def
/maxline
    uy ly sub		    % height
    lineHeight		    % line_height height
    div floor		    % max_whole_lines_per_page
def

/Helvetica findfont fontSize scalefont /normal exch def
/Helvetica-Bold findfont fontSize scalefont /bold exch def
/Helvetica-Oblique findfont fontSize scalefont /italic exch def

/newline { % - => -
    /ypos ypos lineHeight sub def
    /linecounter linecounter 1 add def
    linecounter maxline 1 sub ge
    {
	showpage
	/ypos ystart def
	/linecounter 0 def
    } if
    indent ypos moveto
} def

/finish { % - => -
    linecounter 0 gt
    { showpage }
    if
} def

indent ypos moveto

'
    ]
]
