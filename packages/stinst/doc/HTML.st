"======================================================================
|
|   File out a HTML reference.
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2009 Free Software Foundation, Inc.
| Written by Paolo Bonzini.
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


DocPublisher subclass: HTMLDocPublisher [
    
    <category: 'Examples-File out'>
    <comment: nil>

    HTMLDocPublisher class >> publishNamespaces: aCollection [
	<category: 'multiple classes'>
	| subclasses |
	subclasses := Set new.
	aCollection do: 
		[:ns | 
		ns 
		    allClassesDo: [:each | (each inheritsFrom: CStruct) ifFalse: [subclasses add: each]]].
	self publishAll: subclasses withIndexOnFile: 'classes.html'
    ]

    HTMLDocPublisher class >> publishAll: classArray withIndexOn: aFileStream [
	<category: 'multiple classes'>
	| sorted |
	sorted := self sortClasses: classArray.
	aFileStream 
	    nextPutAll: '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN"> <!--
Automatically yours from GNU Smalltalk''s HTMLDocPublisher! -->

<HTML>
<HEAD>
    <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">
    <META NAME="GENERATOR" CONTENT="GNU Smalltalk HTMLDocPublisher">
    <TITLE>Smalltalk class reference</TITLE>
</HEAD>
<BODY>
<H1>Smalltalk class reference</H1><HR><P>
<PRE>
'.
	self printHierarchyOf: sorted on: aFileStream.
	aFileStream nextPutAll: '
    
Alphabetic list of classes:'; nl.
	sorted do: 
		[:each | 
		| fileName |
		fileName := each nameIn: Namespace current.
		('writing documentation into ' , fileName , '.html') displayNl.
		self publish: each onFile: fileName , '.html'.
		aFileStream
		    nextPutAll: '<A HREF="%1.html">%1</A>' % {fileName};
		    nl].
	aFileStream nextPutAll: '</PRE></BODY></HTML>'
    ]

    HTMLDocPublisher class >> publishAll: classArray withIndexOnFile: aFileName [
	<category: 'multiple classes'>
	| stream |
	stream := FileStream open: aFileName mode: FileStream write.
	[self publishAll: classArray withIndexOn: stream] ensure: [stream close]
    ]

    HTMLDocPublisher class >> publishAll: classArray toLocation: dirName [
	| currentDir |
	currentDir := Directory working.
	dirName = '.'
            ifFalse: [
		(File isAccessible: dirName) ifFalse: [ Directory create: dirName ].
		Directory working: dirName ].
	self publishAll: classArray withIndexOnFile: 'classes.html'.
	dirName = '.' ifFalse: [ Directory working: currentDir ]
    ]

    HTMLDocPublisher class >> publishAll: classArray [
	self publishAll: classArray toLocation: '.'
    ]

    HTMLDocPublisher class >> printTreeClass: class shouldLink: aBoolean on: aFileStream indent: indent [
	<category: 'writing the class tree'>
	| fileName |
	aFileStream
	    nextPutAll: indent;
	    nextPutAll: indent.
	fileName := class nameIn: Namespace current.
	aBoolean 
	    ifTrue: [aFileStream nextPutAll: '<A HREF="' , fileName , '.html">']
	    ifFalse: [aFileStream nextPut: $(].
	aFileStream nextPutAll: (class nameIn: Namespace current).
	aBoolean 
	    ifTrue: [aFileStream nextPutAll: '</A>']
	    ifFalse: [aFileStream nextPut: $)].
	aFileStream nl
    ]

    emitMethod: source [
	"I emit valid HTML for a comment contained in source - which is a method's
	 source code."

	<category: 'emitting comments'>
	| selAndBody comment |
	selAndBody := self selectorAndBody: source.
	comment := self extractComment: (selAndBody at: 2).
	self
	    nextPutAll: '<B>';
	    nextPutAllText: (selAndBody at: 1);
	    nextPutAll: '</B><BLOCKQUOTE>';
	    nextPutAllText: comment;
	    nextPutAll: '</BLOCKQUOTE><P>';
	    nl;
	    nl
    ]

    emitLink: category kind: kind [
	<category: 'subclassed'>
	self
	    nextPutAll: '<A HREF="#';
	    print: categories size;
	    nextPutAll: '">';
	    nextPutAllText: category;
	    nextPutAll: '</A>';
	    nextPutAll: kind;
	    nextPutAll: '<BR>';
	    nl
    ]

    emitFooter [
	<category: 'subclassed'>
	super emitFooter.
	self nextPutAll: '</BODY></HTML>'
    ]

    emitAfterNode [
	<category: 'subclassed'>
	self
	    nextPutAll: '<A HREF="#top">top</A><BR>';
	    nl
    ]

    emitNode: index category: category [
	<category: 'subclassed'>
	self
	    nl;
	    nl;
	    nextPutAll: '<HR><P><H3><A NAME="';
	    print: index;
	    nextPutAll: '">';
	    nextPutAllText: category;
	    nextPutAll: '</A></H3></P>';
	    nl
    ]

    emitHeader: now [
	"I emit a valid HTML header for the file-out."

	<category: 'subclassed'>
	categories := OrderedCollection new.
	self 
	    nextPutAll: '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN"> <!--
Automatically yours from GNU Smalltalk''s HTMLDocPublisher!
Filed out from %1 on %2	 %3 -->

<HTML>
<HEAD>
    <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">
    <META NAME="GENERATOR" CONTENT="GNU Smalltalk HTMLDocPublisher">
    <TITLE>%4</TITLE>
</HEAD>
<BODY>
' 
		    % 
			{Smalltalk version.
			now at: 1.
			now at: 2.
			self className}.
	self
	    nextPutAll: '<DL><DT><B>Category: ';
	    nextPutAllText: self classCategory;
	    nl;
	    nextPutAll: '<BR>Superclass: ';
	    nextPutAllText: self superclassName;
	    nextPutAll: '</B><DD>';
	    nl;
	    nextPutAllText: self classComment;
	    nl;
	    nextPutAll: '</DL><P><A NAME="top"><H2>Method category index</H2></A>';
	    nl
    ]

    escaped [
	"Answer a set of characters that must be passed through #printEscaped: -
	 i.e. <, >, & and double quote"

	<category: 'subclassed'>
	^'<>&"'
    ]

    printEscaped: ch [
	"Print ch as a SGML entity."

	<category: 'subclassed'>
	ch = $< ifTrue: [^self nextPutAll: '&lt;'].
	ch = $> ifTrue: [^self nextPutAll: '&gt;'].
	ch = $& ifTrue: [^self nextPutAll: '&amp;'].
	ch = $" ifTrue: [^self nextPutAll: '&quot;'].
	self nextPut: ch
    ]
]
