"======================================================================
|
|   File out a TexInfo reference.
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


DocPublisher subclass: TexinfoDocPublisher [
    
    <category: 'Examples-File out'>
    <comment: nil>

    TexinfoDocPublisher class [
	| current |
	
    ]

    TexinfoDocPublisher class >> nextClass [
	<category: 'multiple classes'>
	| result |
	^(result := current peek) isNil 
	    ifTrue: ['']
	    ifFalse: [result nameIn: Namespace current]
    ]

    TexinfoDocPublisher class >> prevClass [
	<category: 'multiple classes'>
	| result |
	current position = 2 ifTrue: [^'Tree'].
	current skip: -2.
	result := current next.
	current atEnd ifFalse: [current next].
	^result nameIn: Namespace current
    ]

    TexinfoDocPublisher class >> publishAll: classArray onFile: aFileName [
	<category: 'multiple classes'>
	| stream |
	stream := FileStream open: aFileName mode: FileStream write.
	[self publishAll: classArray on: stream] ensure: [stream close]
    ]

    TexinfoDocPublisher class >> publishAll: classArray on: aFileStream [
	<category: 'multiple classes'>
	| sorted |
	sorted := self sortClasses: classArray.
	current := ReadStream on: sorted.
	aFileStream nextPutAll: self header.
	sorted do: 
		[:each | 
		aFileStream
		    nextPutAll: '* ';
		    nextPutAll: (each nameIn: Namespace current);
		    nextPutAll: '::';
		    nl].
	aFileStream nextPutAll: self beforeTree.
	self printHierarchyOf: sorted on: aFileStream.
	aFileStream nextPutAll: self afterTree.
	sorted do: 
		[:each | 
		current atEnd ifFalse: [current next].
		'writing documentation for ' display.
		(each nameIn: Namespace current) displayNl.
		self basicPublish: each on: aFileStream].
	aFileStream nextPutAll: self footer
    ]

    TexinfoDocPublisher class >> publishAll: classArray [
	self publishAll: classArray on: stdout
    ]

    TexinfoDocPublisher class >> publishAll: classArray toLocation: aFileName [
	self publishAll: classArray onFile: aFileName
    ]

    TexinfoDocPublisher class >> publish: aClass on: aFileStream [
	"Publish aClass, in the format supported by the receiver, on aFileStream"

	<category: 'multiple classes'>
	self publishAll: (Array with: aClass) on: aFileStream
    ]

    TexinfoDocPublisher class >> header [
	<category: 'texinfo source'>
	^'@c Define the class index, method index, and selector cross-reference
@ifclear CLASS-INDICES
@set CLASS-INDICES
@defindex cl
@defcodeindex me
@defcodeindex sl 
@end ifclear

@c These are used for both TeX and HTML
@set BEFORE1
@set  AFTER1
@set BEFORE2
@set  AFTER2

@ifinfo
@c Use asis so that leading and trailing spaces are meaningful.
@c Remember we''re inside a @menu command, hence the blanks are
@c kept in the output.
@set BEFORE1 @asis{* }
@set  AFTER1 @asis{::}
@set BEFORE2 @asis{  (}
@set  AFTER2 @asis{)}
@end ifinfo

@macro class {a,b}
@value{BEFORE1}\a\\a\@b{\b\}@value{AFTER1}
@end macro
@macro superclass {a,b}
\a\\a\@value{BEFORE2}@i{\b\}@value{AFTER2}
@end macro

@ifnotinfo
@macro begindetailmenu
@display
@end macro
@macro enddetailmenu
@end display
@end macro
@end ifnotinfo

@ifinfo
@macro begindetailmenu
@detailmenu
@end macro
@macro enddetailmenu
@end detailmenu
@end macro
@end ifinfo

@iftex
@macro beginmenu
@end macro
@macro endmenu
@end macro
@end iftex

@ifnottex
@macro beginmenu
@menu
@end macro
@macro endmenu
@end menu
@end macro
@end ifnottex

@beginmenu
@ifnottex
Alphabetic list:
'
    ]

    TexinfoDocPublisher class >> beforeTree [
	<category: 'texinfo source'>
	^'@end ifnottex

@ifinfo
Class tree:
@end ifinfo
@iftex
@section Tree
@end iftex
@ifnotinfo

Classes documented in this manual are @b{boldfaced}.

@end ifnotinfo
@begindetailmenu
'
    ]

    TexinfoDocPublisher class >> afterTree [
	<category: 'texinfo source'>
	^'@enddetailmenu
@endmenu
@unmacro class
@unmacro superclass
@unmacro endmenu
@unmacro beginmenu
@unmacro enddetailmenu
@unmacro begindetailmenu
'
    ]

    TexinfoDocPublisher class >> footer [
	<category: 'texinfo source'>
	^''
    ]

    TexinfoDocPublisher class >> printTreeClass: class shouldLink: aBoolean on: aFileStream indent: indent [
	"The @t{} is needed because otherwise makeinfo discards the leading spaces
	 in indent -- i.e. the whole string, since indent is only made of spaces."

	<category: 'creating the class tree'>
	aBoolean
	    ifTrue: [aFileStream nextPutAll: '@class{@t{'];
	    ifFalse: [aFileStream nextPutAll: '@superclass{@t{'].
	aFileStream
	    nextPutAll: indent;
	    nextPutAll: '}, ';
	    nextPutAll: (class nameIn: Namespace current);
	    nextPut: $};
	    nl
    ]

    TexinfoDocPublisher class >> publishNamespaces: aCollection [
	<category: 'creating GST''s manual'>
	| subclasses |
	subclasses := Set new.
	aCollection do: 
		[:ns | 
		ns 
		    allClassesDo: [:each | (each inheritsFrom: CStruct) ifFalse: [subclasses add: each]]].
	^self publishAll: subclasses onFile: 'classes.texi'
    ]

    emitMethodSelector: aSymbol [
	"I emit a Texinfo indexing command for the selector in aSymbol."

	<category: 'emitting comments'>
	self
	    nextPutAll: '@meindex ';
	    nextPutAllText: aSymbol;
	    nl
    ]

    emitCrossReferences: comment [
	"Emit the cross-references to other selectors that are included
	 in the method comment."

	<category: 'emitting comments'>
	| i j ch |
	i := 1.
	
	[(i := comment 
		    indexOf: $#
		    startingAt: i
		    ifAbsent: [nil]) isNil] 
		whileFalse: 
		    [j := i.
		    
		    [j := j + 1.
		    j > comment size or: [#(${ $} $[ $] $, $' $. $( $) $ $; $<10>) includes: (comment at: j)]]
			    whileFalse.
		    i + 1 < j 
			ifTrue: 
			    [self
				nextPutAll: '@slindex ';
				nextPutAllText: (comment copyFrom: i + 1 to: j - 1);
				nl].
		    i := j]
    ]

    emitSelectorAndMethod: association [
	"I emit valid Texinfo markup for a comment contained in source - which is
	 a method's source code."

	<category: 'subclassed'>
	| selAndBody comment |
	selAndBody := self selectorAndBody: association value.
	comment := self extractComment: (selAndBody at: 2).

	"Uncomment to avoid documenting private methods"
	"(comment size > 7 and: [ (comment copyFrom: 1 to: 7) = 'Private' ])
	 ifTrue: [ ^self ]."
	self
	    emitMethodSelector: association key;
	    emitCrossReferences: comment;
	    nextPutAll: '@item ';
	    nextPutAllText: ((selAndBody at: 1) copyWithout: Character nl);
	    nl;
	    nextPutAllText: comment;
	    nl;
	    nl
    ]

    emitLink: category kind: kind [
	<category: 'subclassed'>
	self
	    nextPutAll: '* ';
	    nextPutAllText: (self nodeName: category , kind);
	    nextPutAll: ':: ';
	    nextPutAllText: kind;
	    nl
    ]

    emitIndexFooter [
	<category: 'subclassed'>
	self
	    nextPutAll: '@end menu';
	    nl;
	    nl
    ]

    emitAfterNode [
	<category: 'subclassed'>
	self
	    nextPutAll: '@end table';
	    nl;
	    nl
    ]

    prevCategory: index [
	<category: 'subclassed'>
	index = 1 ifTrue: [^self className].
	^self nodeName: (self categoryAt: index - 1)
    ]

    nextCategory: index [
	<category: 'subclassed'>
	index = self categoriesSize ifTrue: [^''].
	^self nodeName: (self categoryAt: index + 1)
    ]

    className: category [
	<category: 'subclassed'>
	| size className |
	size := category size.
	className := self className.
	^(category copyFrom: size - 6 to: size) = '(class)' 
	    ifTrue: [className , ' class']
	    ifFalse: [className]
    ]

    nodeName: category [
	<category: 'subclassed'>
	| last className |
	last := category findLast: [:each | each == Character space].
	className := self className: category.
	^className , '-' , (category copyFrom: 1 to: last - 1)
    ]

    sectionName: category [
	<category: 'subclassed'>
	| last className |
	last := category findLast: [:each | each == Character space].
	className := self className: category.
	^className , ': ' , (category copyFrom: 1 to: last - 1)
    ]

    emitNode: index category: category [
	<category: 'subclassed'>
	self
	    nl;
	    nl;
	    nextPutAll: '@node ';
	    nextPutAll: (self nodeName: category);
	    nl;
	    nextPutAll: '@subsection ';
	    nextPutAllText: (self sectionName: category);
	    nl;
	    nl;
	    nextPutAll: '@table @b';
	    nl
    ]

    emitHeader: now [
	"I emit a valid TexInfo header for the file-out."

	<category: 'subclassed'>
	categories := OrderedCollection new.
	self nextPutAll: '@node %1
@section %1
@clindex %1

' % {self className}.
	self
	    nextPutAll: '@table @b';
	    nl;
	    nextPutAll: '@item Defined in namespace ';
	    nextPutAllText: self currentClass environment storeString;
	    nl;
	    nextPutAll: '@itemx Superclass: ';
	    nextPutAllText: self superclassName;
	    nl;
	    nextPutAll: '@itemx Category: ';
	    nextPutAllText: self classCategory;
	    nl;
	    nextPutAllText: self classComment;
	    nl;
	    nextPutAll: '@end table';
	    nl;
	    nl;
	    nextPutAll: '@menu';
	    nl
    ]

    escaped [
	"Answer a set of characters that must be passed through #printEscaped: -
	 i.e. @, {, }."

	<category: 'subclassed'>
	^'@{}'
    ]

    printEscaped: ch [
	"Print ch with a @ in front of it."

	<category: 'subclassed'>
	self nextPut: $@.
	self nextPut: ch
    ]

    nextPutAllChar: ch after: prev [
        "Treat # and : specially so that we can insert hyphenation signs
	 and avoid overfull hboxes long ABC>>#def signatures are encountered."

	<category: 'subclassed'>
        (prev isNil or: [ prev isSeparator ]) ifFalse: [
	    ch = $# ifTrue: [^self nextPutAll: '@-#'].
	    ch = $: ifTrue: [^self nextPutAll: ':@-']].
	^super nextPutAllChar: ch after: prev
    ]
]

