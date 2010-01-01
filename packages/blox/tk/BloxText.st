"======================================================================
|
|   Smalltalk Tk-based GUI building blocks (text widget).
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999,2000,2001,2002,2004,2009 Free Software Foundation, Inc.
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
| along with the GNU Smalltalk class library; see the file COPYING.LESSER.
| If not, write to the Free Software Foundation, 59 Temple Place - Suite
| 330, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



BViewport subclass: BText [
    | callback tagInfo images |
    
    <comment: '
I represent a text viewer with pretty good formatting options.'>
    <category: 'Graphics-Windows'>

    BText class >> emacsLike [
	"Answer whether we are using Emacs or Motif key bindings."

	<category: 'accessing'>
	self tclEval: 'return $tk_strictMotif'.
	^self tclResult = '0'
    ]

    BText class >> emacsLike: aBoolean [
	"Set whether we are using Emacs or Motif key bindings."

	<category: 'accessing'>
	self 
	    tclEval: 'set tk_strictMotif ' , (aBoolean ifTrue: ['0'] ifFalse: ['1'])
    ]

    BText class >> newReadOnly: parent [
	"Answer a new read-only text widget (read-only is achieved simply
	 by setting its state to be disabled)"

	<category: 'instance creation'>
	| ctl |
	ctl := self new: parent.
	ctl tclEval: ctl connected , ' configure -state disabled'.
	^ctl
    ]

    backgroundColor [
	"Answer the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #background ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -background'
	    with: self connected
	    with: self container.
	^self properties at: #background put: self tclResult
    ]

    backgroundColor: value [
	"Set the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -background %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #background put: value
    ]

    callback [
	"Answer a DirectedMessage that is sent when the receiver is modified,
	 or nil if none has been set up."

	<category: 'accessing'>
	^callback
    ]

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a zero- or one-argument selector) when the receiver is modified.
	 If the method accepts an argument, the receiver is passed."

	<category: 'accessing'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	arguments := #().
	numArgs = 1 ifTrue: [arguments := Array with: self].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    contents [
	"Return the contents of the widget"

	<category: 'accessing'>
	self tclEval: self connected , ' get 1.0 end-1c'.
	^self tclResult
    ]

    contents: aString [
	"Set the contents of the widget"

	<category: 'accessing'>
	self 
	    tclEval: '%1 delete 1.0 end
	%1 insert 1.0 %2
	%1 see 1.0'
	    with: self connected
	    with: aString asTkString
    ]

    font [
	"Answer the value of the font option for the widget.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	self properties at: #font ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -font'
	    with: self connected
	    with: self container.
	^self properties at: #font put: self tclResult
    ]

    font: value [
	"Set the value of the font option for the widget.
	 
	 Specifies the font to use when drawing text inside the widget. The font
	 can be given as either an X font name or a Blox font description string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -font %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #font put: value
    ]

    foregroundColor [
	"Answer the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self properties at: #foreground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -foreground'
	    with: self connected
	    with: self container.
	^self properties at: #foreground put: self tclResult
    ]

    foregroundColor: value [
	"Set the value of the foregroundColor option for the widget.
	 
	 Specifies the normal foreground color to use when displaying the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -foreground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #foreground put: value
    ]

    getSelection [
	"Answer an empty string if the widget has no selection, else answer
	 the currently selected text"

	<category: 'accessing'>
	| result |
	self 
	    tclEval: '
	if { [%1 tag ranges sel] == {} } then { return {} }
	%1 get sel.first sel.last'
	    with: self connected.
	result := self tclResult.
	^result isEmpty ifTrue: [nil] ifFalse: [result]
    ]

    selectBackground [
	"Answer the value of the selectBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected parts
	 of the widget."

	<category: 'accessing'>
	self properties at: #selectbackground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -selectbackground'
	    with: self connected
	    with: self container.
	^self properties at: #selectbackground put: self tclResult
    ]

    selectBackground: value [
	"Set the value of the selectBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected parts
	 of the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -selectbackground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #selectbackground put: value
    ]

    selectForeground [
	"Answer the value of the selectForeground option for the widget.
	 
	 Specifies the foreground color to use when displaying selected parts
	 of the widget."

	<category: 'accessing'>
	self properties at: #selectforeground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -selectforeground'
	    with: self connected
	    with: self container.
	^self properties at: #selectforeground put: self tclResult
    ]

    selectForeground: value [
	"Set the value of the selectForeground option for the widget.
	 
	 Specifies the foreground color to use when displaying selected parts
	 of the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -selectforeground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #selectforeground put: value
    ]

    wrap [
	"Answer the value of the wrap option for the widget.
	 
	 Specifies how to handle lines in the text that are too long to be displayed
	 in a single line of the text's window. The value must be #none or #char or
	 #word. A wrap mode of none means that each line of text appears as exactly
	 one line on the screen; extra characters that do not fit on the screen are
	 not displayed. In the other modes each line of text will be broken up into
	 several screen lines if necessary to keep all the characters visible. In
	 char mode a screen line break may occur after any character; in word mode a
	 line break will only be made at word boundaries."

	<category: 'accessing'>
	self properties at: #wrap ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -wrap'
	    with: self connected
	    with: self container.
	^self properties at: #wrap put: self tclResult asSymbol
    ]

    wrap: value [
	"Set the value of the wrap option for the widget.
	 
	 Specifies how to handle lines in the text that are too long to be displayed
	 in a single line of the text's window. The value must be #none or #char or
	 #word. A wrap mode of none means that each line of text appears as exactly
	 one line on the screen; extra characters that do not fit on the screen are
	 not displayed. In the other modes each line of text will be broken up into
	 several screen lines if necessary to keep all the characters visible. In
	 char mode a screen line break may occur after any character; in word mode a
	 line break will only be made at word boundaries."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -wrap %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #wrap put: value
    ]

    insertAtEnd: aString attribute: attr [
	"Clear the selection and append aString at the end of the
	 widget.  Use the given attributes to format the text."

	<category: 'attributes'>
	attr isNil ifTrue: [^self insertAtEnd: aString].
	tagInfo isNil ifTrue: [tagInfo := BTextTags new: self].
	self 
	    tclEval: '%1 tag remove sel 1.0 end
	%1 insert end %2%3'
	    with: self connected
	    with: aString asTkString
	    with: (attr tags: tagInfo)
    ]

    insertText: aString attribute: attr [
	"Insert aString in the widget at the current insertion point,
	 replacing the currently selected text (if any).  Use the
	 given attributes to format the text."

	<category: 'attributes'>
	attr isNil ifTrue: [^self insertText: aString].
	tagInfo isNil ifTrue: [tagInfo := BTextTags new: self].
	self 
	    tclEval: '%1 delete sel.first sel.last
	%1 insert insert %2 %3
	%1 see insert'
	    with: self connected
	    with: aString asTkString
	    with: (attr tags: tagInfo)
    ]

    removeAttributes [
	"Remove any kind of formatting from the text in the widget"

	<category: 'attributes'>
	tagInfo isNil ifTrue: [^self].
	self removeAttributesInside: '1.0 end'.
	tagInfo initialize: self
    ]

    removeAttributesFrom: aPoint to: endPoint [
	"Remove any kind of formatting from the text in the widget
	 between the given endpoints.  The two endpoints are Point
	 objects in which both coordinates are 1-based: the first
	 line is line 1, and the first character in the first line
	 is character 1."

	<category: 'attributes'>
	tagInfo isNil ifTrue: [^self].
	self removeAttributesInside: (self from: aPoint to: endPoint)
    ]

    setAttributes: attr from: aPoint to: endPoint [
	"Add the formatting given by attr to the text in the widget
	 between the given endpoints.  The two endpoints are Point
	 objects in which both coordinates are 1-based: the first
	 line is line 1, and the first character in the first line
	 is character 1."

	<category: 'attributes'>
	attr isNil ifTrue: [^self].
	tagInfo isNil ifTrue: [tagInfo := BTextTags new: self].
	self 
	    tclEval: 'foreach tag %2 { %1 tag add $tag %3 }'
	    with: self connected
	    with: (attr tags: tagInfo)
	    with: (self from: aPoint to: endPoint)
    ]

    child: child height: value [
	"Set the height of the given child to be `value' pixels."

	<category: 'geometry management'>
	| width height |
	height := self at: #heightGeom put: value asInteger.
	width := self at: #widthGeom ifAbsentPut: [self widthAbsolute]
	"self
	 tclEval: 'wm geometry %1 =%2x%3'
	 with: child container
	 with: width printString
	 with: height printString"
    ]

    child: child heightOffset: value [
	"Adjust the height of the given child to be given by `value'
	 more pixels."

	<category: 'geometry management'>
	self child: child height: (self heightChild: child) + value
    ]

    child: child width: value [
	"Set the width of the given child to be `value' pixels."

	<category: 'geometry management'>
	| width height |
	width := self at: #widthGeom put: value asInteger.
	height := self at: #heightGeom ifAbsentPut: [child heightAbsolute]
	"self
	 tclEval: 'wm geometry %1 =%2x%3'
	 with: child container
	 with: width printString
	 with: height printString"
    ]

    child: child widthOffset: value [
	"Adjust the width of the given child to be given by `value'
	 more pixels."

	<category: 'geometry management'>
	self child: child width: (self widthChild: child) + value
    ]

    child: child x: value [
	"Never fail and do nothing, the children stay where
	 the text ended at the time each child was added in
	 the widget"

	<category: 'geometry management'>
	
    ]

    child: child xOffset: value [
	<category: 'geometry management'>
	self shouldNotImplement
    ]

    child: child y: value [
	"Never fail and do nothing, the children stay where
	 the text ended at the time each child was added in
	 the widget"

	<category: 'geometry management'>
	
    ]

    child: child yOffset: value [
	<category: 'geometry management'>
	self shouldNotImplement
    ]

    heightChild: child [
	"Answer the given child's height in pixels."

	<category: 'geometry management'>
	^child at: #heightGeom ifAbsentPut: [child heightAbsolute]
    ]

    widthChild: child [
	"Answer the given child's width in pixels."

	<category: 'geometry management'>
	^child at: #widthGeom ifAbsentPut: [child widthAbsolute]
    ]

    xChild: child [
	"Answer the given child's top-left border's x coordinate.
	 We always answer 0 since the children actually move when
	 the text widget scrolls"

	<category: 'geometry management'>
	^0
    ]

    yChild: child [
	"Answer the given child's top-left border's y coordinate.
	 We always answer 0 since the children actually move when
	 the text widget scrolls"

	<category: 'geometry management'>
	^0
    ]

    insertImage: anObject [
	"Insert an image where the insertion point currently lies in the widget.
	 anObject can be a String containing image data (either Base-64 encoded
	 GIF data, XPM data, or PPM data), or the result or registering an image
	 with #registerImage:"

	<category: 'images'>
	| key |
	key := self registerImage: anObject.
	self 
	    tclEval: '%1 image create insert -align baseline -image %2'
	    with: self connected
	    with: key value.
	^key
    ]

    insertImage: anObject at: position [
	"Insert an image at the given position in the widget.  The
	 position is a Point object in which both coordinates are 1-based:
	 the first line is line 1, and the first character in the first
	 line is character 1.
	 
	 anObject can be a String containing image data (either Base-64 encoded
	 GIF data, XPM data, or PPM data), or the result or registering an image
	 with #registerImage:"

	<category: 'images'>
	| key |
	key := self registerImage: anObject.
	self 
	    tclEval: '%1 image create %2.%3 -align baseline -image %4'
	    with: self connected
	    with: position y printString
	    with: (position x - 1) printString
	    with: key value.
	^key
    ]

    insertImageAtEnd: anObject [
	"Insert an image at the end of the widgets text.
	 anObject can be a String containing image data (either Base-64 encoded
	 GIF data, XPM data, or PPM data), or the result or registering an image
	 with #registerImage:"

	<category: 'images'>
	| key |
	key := self registerImage: anObject.
	self 
	    tclEval: '%1 image create end -align baseline -image %2'
	    with: self connected
	    with: key value.
	^key
    ]

    registerImage: anObject [
	"Register an image (whose data is in anObject, a String including
	 Base-64 encoded GIF data, XPM data, or PPM data) to be used
	 in the widget.  If the same image must be used a lot of times,
	 it is better to register it once and then pass the result of
	 #registerImage: to the image insertion methods.
	 
	 Registered image are private within each BText widget.  Registering
	 an image with a widget and using it with another could give
	 unpredictable results."

	<category: 'images'>
	| imageName |
	anObject class == ValueHolder ifTrue: [^anObject].
	self tclEval: 'image create photo -data ' , anObject asTkImageString.
	images isNil ifTrue: [images := OrderedCollection new].
	imageName := images add: self tclResult.
	^ValueHolder with: imageName
    ]

    insertAtEnd: aString [
	"Clear the selection and append aString at the end of the
	 widget."

	<category: 'inserting text'>
	self 
	    tclEval: '%1 tag remove sel 1.0 end
	%1 insert end %2'
	    with: self connected
	    with: aString asTkString
    ]

    insertSelectedText: aString [
	"Insert aString in the widget at the current insertion point,
	 leaving the currently selected text (if any) in place, and
	 selecting the text."

	<category: 'inserting text'>
	self 
	    tclEval: '%1 tag remove sel 1.0 end
	%1 insert insert %2 { sel }
	%1 see insert'
	    with: self connected
	    with: aString asTkString
    ]

    insertText: aString [
	"Insert aString in the widget at the current insertion point,
	 replacing the currently selected text (if any)."

	<category: 'inserting text'>
	self 
	    tclEval: 'catch { %1 delete sel.first sel.last }
	%1 insert insert %2
	%1 see insert'
	    with: self connected
	    with: aString asTkString
    ]

    insertText: aString at: position [
	"Insert aString in the widget at the given position,
	 replacing the currently selected text (if any).  The
	 position is a Point object in which both coordinates are 1-based:
	 the first line is line 1, and the first character in the first
	 line is character 1."

	<category: 'inserting text'>
	self 
	    tclEval: '%1 delete sel.first sel.last
	%1 insert %2.%3 %4
	%1 see insert'
	    with: self connected
	    with: position y printString
	    with: (position x - 1) printString
	    with: aString asTkString
    ]

    insertTextSelection: aString [
	"Insert aString in the widget after the current selection,
	 leaving the currently selected text (if any) intact."

	<category: 'inserting text'>
	self 
	    tclEval: 'catch { %1 mark set insert sel.last }
	%1 tag remove sel 1.0 end
	%1 insert insert %2 { sel }
	%1 see insert'
	    with: self connected
	    with: aString asTkString
    ]

    invokeCallback [
	"Generate a synthetic callback."

	<category: 'inserting text'>
	self callback isNil ifFalse: [self callback send]
    ]

    nextPut: aCharacter [
	"Clear the selection and append aCharacter at the end of the
	 widget."

	<category: 'inserting text'>
	self insertAtEnd: (String with: aCharacter)
    ]

    nextPutAll: aString [
	"Clear the selection and append aString at the end of the
	 widget."

	<category: 'inserting text'>
	self insertAtEnd: aString
    ]

    nl [
	"Clear the selection and append a linefeed character at the
	 end of the widget."

	<category: 'inserting text'>
	self insertAtEnd: Character nl asString
    ]

    refuseTabs [
	"Arrange so that Tab characters, instead of being inserted
	 in the widget, traverse the widgets in the parent window."

	<category: 'inserting text'>
	self 
	    tclEval: '
	bind %1 <Tab> {
	    focus [tk_focusNext %W]
	    break
	}
	bind %1 <Shift-Tab> {
	    focus [tk_focusPrev %W]
	    break
	}'
	    with: self connected
    ]

    replaceSelection: aString [
	"Insert aString in the widget at the current insertion point,
	 replacing the currently selected text (if any), and leaving
	 the text selected."

	<category: 'inserting text'>
	self 
	    tclEval: 'catch { %1 delete sel.first sel.last }
	%1 insert insert %2 { sel }
	%1 see insert'
	    with: self connected
	    with: aString asTkString
    ]

    searchString: aString [
	"Search aString in the widget.  If it is not found,
	 answer zero, else answer the 1-based line number
	 and move the insertion point to the place where
	 the string was found."

	<category: 'inserting text'>
	| result |
	self 
	    tclEval: self connected , ' search ' , aString asTkString , ' 1.0 end'.
	result := self tclResult.
	result isEmpty ifTrue: [^0].
	self 
	    tclEval: '
	%1 mark set insert %2
	%1 see insert'
	    with: self connected
	    with: result.

	"Sending asInteger removes the column"
	^result asInteger
    ]

    space [
	"Clear the selection and append a space at the end of the
	 widget."

	<category: 'inserting text'>
	self insertAtEnd: ' '
    ]

    charsInLine: number [
	"Answer how many characters are there in the number-th line"

	<category: 'position & lines'>
	| stream |
	self tclEval: self connected , ' index ' , number printString , '.end'.
	stream := ReadStream on: self tclResult.
	stream skipTo: $..
	^stream upToEnd asInteger + 1
    ]

    currentColumn [
	"Answer the 1-based column number where the insertion point
	 currently lies."

	<category: 'position & lines'>
	| stream |
	self tclEval: self connected , ' index insert'.
	stream := ReadStream on: self tclResult.
	stream skipTo: $..
	^stream upToEnd asInteger + 1
    ]

    currentLine [
	"Answer the 1-based line number where the insertion point
	 currently lies."

	<category: 'position & lines'>
	| stream |
	self tclEval: self connected , ' index insert'.
	stream := ReadStream on: self tclResult.
	^(stream upTo: $.) asInteger
    ]

    currentPosition [
	"Answer a Point representing where the insertion point
	 currently lies.  Both coordinates in the answer are 1-based:
	 the first line is line 1, and the first character in the first
	 line is character 1."

	<category: 'position & lines'>
	self tclEval: self connected , ' index insert'.
	^self parseResult
    ]

    currentPosition: aPoint [
	"Move the insertion point to the position given by aPoint.
	 Both coordinates in aPoint are interpreted as 1-based:
	 the first line is line 1, and the first character in the first
	 line is character 1."

	<category: 'position & lines'>
	self 
	    tclEval: '
      %1 mark set insert %2.%3
      %1 see insert'
	    with: self connected
	    with: aPoint y printString
	    with: (aPoint x - 1) printString
    ]

    gotoLine: line end: aBoolean [
	"If aBoolean is true, move the insertion point to the last
	 character of the line-th line (1 being the first line
	 in the widget); if aBoolean is false, move it to the start
	 of the line-th line."

	<category: 'position & lines'>
	| code |
	code := aBoolean 
		    ifTrue: ['%1 mark set insert "%2.0 -1l lineend"']
		    ifFalse: ['%1 mark set insert %2.0'].
	self 
	    tclEval: code
	    with: self connected
	    with: line printString.
	self tclEval: self connected , ' see insert'.
	^1
    ]

    indexAt: point [
	"Answer the position of the character that covers the
	 pixel whose coordinates within the text's window are
	 given by the supplied Point object."

	<category: 'position & lines'>
	self 
	    tclEval: self connected , ' index @%1,%2'
	    with: point x printString
	    with: point y printString.
	^self parseResult
    ]

    lineAt: number [
	"Answer the number-th line of text in the widget"

	<category: 'position & lines'>
	self tclEval: self connected , ' get %1.0 %1.end' with: number printString.
	^self tclResult
    ]

    numberOfLines [
	"Answer the number of lines in the widget"

	<category: 'position & lines'>
	| stream |
	self tclEval: self connected , ' index end-1c'.
	stream := ReadStream on: self tclResult.
	^(stream upTo: $.) asInteger
    ]

    selectFrom: first to: last [
	"Select the text between the given endpoints.  The two endpoints
	 are Point objects in which both coordinates are 1-based: the
	 first line is line 1, and the first character in the first line
	 is character 1."

	<category: 'position & lines'>
	self 
	    tclEval: '%1 tag remove sel 1.0 end
	%1 tag add sel %2'
	    with: self connected
	    with: (self from: first to: last)
    ]

    setToEnd [
	"Move the insertion point to the end of the widget"

	<category: 'position & lines'>
	self tclEval: '
	%1 mark set insert end-1c
	%1 see end'
	    with: self connected
    ]

    addChild: child [
	<category: 'private'>
	self 
	    tclEval: '%1 window create end -window %2'
	    with: self connected
	    with: child container.
	^self basicAddChild: child
    ]

    create [
	<category: 'private'>
	self
	    create: ' -wrap word -font {' , self class defaultFont , '} \
		  -state normal -highlightthickness 0 -takefocus 1';
	    horizontal: true;
	    vertical: true.

	"This hack gets the callback upon insert or delete; see Tk FAQ
	 by Jeffrey Hobbs (jeff.hobbs@acm.org)"
	self 
	    tclEval: '
      rename %1 .%1
      proc %1 args {
	if [regexp {^(ins|del).*} [lindex $args 0]] { callback %2 invokeCallback }
	uplevel .%1 $args
      }'
	    with: self connected
	    with: self asOop printString
    ]

    defineTag: name as: options [
	<category: 'private'>
	self 
	    tclEval: '%1 tag configure %2 %3
	%1 tag raise sel %2'
	    with: self connected
	    with: name
	    with: options
    ]

    destroyed [
	<category: 'private'>
	super destroyed.
	images isNil ifTrue: [^self].
	images do: [:name | self tclEval: 'image delete ' , name].
	images := nil
    ]

    from: aPoint to: endPoint [
	<category: 'private'>
	^'%1.%2 %3.%4' % 
		{aPoint y printString.
		(aPoint x - 1) printString.
		endPoint y printString.
		(endPoint x - 1) printString}
    ]

    parseResult [
	<category: 'private'>
	| stream y |
	stream := ReadStream on: self tclResult.
	y := (stream upTo: $.) asInteger.
	^(stream upToEnd asInteger + 1) @ y
    ]

    removeAttributesInside: range [
	<category: 'private'>
	self 
	    tclEval: 'foreach tag [ %1 tag names ] {
       if { $tag != "sel" } then { %1 tag remove $tag %2 }
    }'
	    with: self connected
	    with: range
    ]

    tag: name bind: event to: aSymbol of: anObject parameters: params [
	<category: 'private'>
	self 
	    bind: event
	    to: aSymbol
	    of: anObject
	    parameters: params
	    prefix: '%1 tag bind %2' % 
			{self connected.
			name}
    ]

    widgetType [
	<category: 'private'>
	^'text '
    ]
]



BEventTarget subclass: BTextBindings [
    | list tagName |
    
    <comment: 'This object is used to assign event handlers to particular sections of
text in a BText widget.  To use it, you simply have to add event handlers
to it, and then create a BTextAttributes object that refers to it.'>
    <category: 'Graphics-Windows'>

    BTextBindings class >> new [
	"Create a new instance of the receiver."

	<category: 'instance creation'>
	^self basicNew initialize
    ]

    defineTagFor: aBText [
	<category: 'private - BTextTags protocol'>
	list do: [:each | each sendTo: aBText]
    ]

    tagName [
	<category: 'private - BTextTags protocol'>
	^tagName
    ]

    initialize [
	<category: 'private'>
	tagName := 'ev' , (Time millisecondClockValue printString: 36).
	list := OrderedCollection new
    ]

    primBind: event to: aSymbol of: anObject parameters: params [
	<category: 'private'>
	| args |
	(args := Array new: 5)
	    at: 1 put: tagName;
	    at: 2 put: event;
	    at: 3 put: aSymbol;
	    at: 4 put: anObject;
	    at: 5 put: params.
	list add: (Message selector: #tag:bind:to:of:parameters: arguments: args)
    ]
]



Object subclass: BTextAttributes [
    | bgColor fgColor font styles events |
    
    <category: 'Graphics-Windows'>
    <comment: '
I help you creating wonderful, colorful BTexts.'>

    BTextAttributes class >> backgroundColor: color [
	"Create a new BTextAttributes object resulting in text
	 with the given background color."

	<category: 'instance-creation shortcuts'>
	^self new backgroundColor: color
    ]

    BTextAttributes class >> black [
	"Create a new BTextAttributes object resulting in black text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'black'
    ]

    BTextAttributes class >> blue [
	"Create a new BTextAttributes object resulting in blue text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'blue'
    ]

    BTextAttributes class >> center [
	"Create a new BTextAttributes object resulting in centered
	 paragraphs."

	<category: 'instance-creation shortcuts'>
	^self new center
    ]

    BTextAttributes class >> cyan [
	"Create a new BTextAttributes object resulting in cyan text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'cyan'
    ]

    BTextAttributes class >> darkCyan [
	"Create a new BTextAttributes object resulting in dark cyan text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'PureDarkCyan'
    ]

    BTextAttributes class >> darkGreen [
	"Create a new BTextAttributes object resulting in dark green text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'PureDarkGreen'
    ]

    BTextAttributes class >> darkMagenta [
	"Create a new BTextAttributes object resulting in dark purple text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'PureDarkMagenta'
    ]

    BTextAttributes class >> events: aBTextBindings [
	"Create a new BTextAttributes object for text that responds to
	 events according to the callbacks established in aBTextBindings."

	<category: 'instance-creation shortcuts'>
	^self new events: aBTextBindings
    ]

    BTextAttributes class >> font: font [
	"Create a new BTextAttributes object resulting in text with the given font.
	 The font can be given as either an X font name or a Blox font description
	 string.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'instance-creation shortcuts'>
	^self new font: font
    ]

    BTextAttributes class >> foregroundColor: color [
	"Create a new BTextAttributes object resulting in text
	 with the given foreground color."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: color
    ]

    BTextAttributes class >> green [
	"Create a new BTextAttributes object resulting in green text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'green'
    ]

    BTextAttributes class >> magenta [
	"Create a new BTextAttributes object resulting in magenta text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'magenta'
    ]

    BTextAttributes class >> red [
	"Create a new BTextAttributes object resulting in red text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'red'
    ]

    BTextAttributes class >> strikeout [
	"Create a new BTextAttributes object resulting in struck-out text."

	<category: 'instance-creation shortcuts'>
	^self new strikeout
    ]

    BTextAttributes class >> underline [
	"Create a new BTextAttributes object resulting in underlined text."

	<category: 'instance-creation shortcuts'>
	^self new underline
    ]

    BTextAttributes class >> yellow [
	"Create a new BTextAttributes object resulting in yellow text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'yellow'
    ]

    BTextAttributes class >> white [
	"Create a new BTextAttributes object resulting in white text."

	<category: 'instance-creation shortcuts'>
	^self new foregroundColor: 'white'
    ]

    black [
	"Set the receiver so that applying it results in black text."

	<category: 'colors'>
	self foregroundColor: 'black'
    ]

    blue [
	"Set the receiver so that applying it results in blue text."

	<category: 'colors'>
	self foregroundColor: 'blue'
    ]

    cyan [
	"Set the receiver so that applying it results in cyan text."

	<category: 'colors'>
	self foregroundColor: 'cyan'
    ]

    darkCyan [
	"Set the receiver so that applying it results in dark cyan text."

	<category: 'colors'>
	self foregroundColor: 'PureDarkCyan'
    ]

    darkGreen [
	"Set the receiver so that applying it results in dark green text."

	<category: 'colors'>
	self foregroundColor: 'PureDarkGreen'
    ]

    darkMagenta [
	"Set the receiver so that applying it results in dark magenta text."

	<category: 'colors'>
	self foregroundColor: 'PureDarkMagenta'
    ]

    green [
	"Set the receiver so that applying it results in green text."

	<category: 'colors'>
	self foregroundColor: 'green'
    ]

    magenta [
	"Set the receiver so that applying it results in magenta text."

	<category: 'colors'>
	self foregroundColor: 'magenta'
    ]

    red [
	"Set the receiver so that applying it results in red text."

	<category: 'colors'>
	self foregroundColor: 'red'
    ]

    white [
	"Set the receiver so that applying it results in white text."

	<category: 'colors'>
	self foregroundColor: 'white'
    ]

    yellow [
	"Set the receiver so that applying it results in black text."

	<category: 'colors'>
	self foregroundColor: 'yellow'
    ]

    hasStyle: aSymbol [
	<category: 'private'>
	^styles notNil and: [styles includes: aSymbol]
    ]

    style: aSymbol [
	<category: 'private'>
	styles isNil ifTrue: [styles := Set new].
	styles add: aSymbol
    ]

    tags: aBTextTags [
	<category: 'private'>
	| s |
	s := WriteStream on: (String new: 20).
	s nextPutAll: ' {'.
	fgColor isNil ifFalse: [s nextPutAll: (aBTextTags fgColor: fgColor)].
	bgColor isNil ifFalse: [s nextPutAll: (aBTextTags bgColor: bgColor)].
	font isNil ifFalse: [s nextPutAll: (aBTextTags font: font)].
	events isNil ifFalse: [s nextPutAll: (aBTextTags events: events)].
	styles isNil 
	    ifFalse: 
		[styles do: 
			[:each | 
			s
			    nextPut: $ ;
			    nextPutAll: each]].
	s nextPut: $}.
	^s contents
    ]

    backgroundColor [
	"Answer the value of the backgroundColor option for the text.
	 
	 Specifies the background color to use when displaying text with
	 these attributes.  nil indicates that the default value is not
	 overridden."

	<category: 'setting attributes'>
	^bgColor
    ]

    backgroundColor: color [
	"Set the value of the backgroundColor option for the text.
	 
	 Specifies the background color to use when displaying text with
	 these attributes.  nil indicates that the default value is not
	 overridden."

	<category: 'setting attributes'>
	bgColor := color
    ]

    center [
	"Center the text to which these attributes are applied"

	<category: 'setting attributes'>
	self style: #STYLEcenter
    ]

    events [
	"Answer the event bindings which apply to text subject to these
	 attributes"

	<category: 'setting attributes'>
	^events
    ]

    events: aBTextBindings [
	"Set the event bindings which apply to text subject to these
	 attributes"

	<category: 'setting attributes'>
	events := aBTextBindings
    ]

    font [
	"Answer the value of the font option for the text.
	 The font can be given as either an X font name or a Blox font description
	 string, or nil if you want the widget's default font to apply.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'setting attributes'>
	^font
    ]

    font: fontName [
	"Set the value of the font option for the text.
	 The font can be given as either an X font name or a Blox font description
	 string, or nil if you want the widget's default font to apply.
	 
	 X font names are given as many fields, each led by a minus, and each of
	 which can be replaced by an * to indicate a default value is ok:
	 foundry, family, weight, slant, setwidth, addstyle, pixel size, point size
	 (the same as pixel size for historical reasons), horizontal resolution,
	 vertical resolution, spacing, width, charset and character encoding.
	 
	 Blox font description strings have three fields, which must be separated by
	 a space and of which only the first is mandatory: the font family, the font
	 size in points (or in pixels if a negative value is supplied), and a number
	 of styles separated by a space (valid styles are normal, bold, italic,
	 underline and overstrike). Examples of valid fonts are ``Helvetica 10 Bold'',
	 ``Times -14'', ``Futura Bold Underline''.  You must enclose the font family
	 in braces if it is made of two or more words."

	<category: 'setting attributes'>
	font := fontName
    ]

    foregroundColor [
	"Answer the value of the foregroundColor option for the text.
	 
	 Specifies the foreground color to use when displaying text with
	 these attributes.  nil indicates that the default value is not
	 overridden."

	<category: 'setting attributes'>
	^fgColor
    ]

    foregroundColor: color [
	"Set the value of the foregroundColor option for the text.
	 
	 Specifies the foreground color to use when displaying text with
	 these attributes.  nil indicates that the default value is not
	 overridden."

	<category: 'setting attributes'>
	fgColor := color
    ]

    isCentered [
	"Answer whether the text to which these attributes are applied
	 is centered"

	<category: 'setting attributes'>
	^self hasStyle: #STYLEcenter
    ]

    isStruckout [
	"Answer whether the text to which these attributes are applied
	 is struckout"

	<category: 'setting attributes'>
	^self hasStyle: #STYLEstrikeout
    ]

    isUnderlined [
	"Answer whether the text to which these attributes are applied
	 is underlined"

	<category: 'setting attributes'>
	^self hasStyle: #STYLEunderline
    ]

    strikeout [
	"Strike out the text to which these attributes are applied"

	<category: 'setting attributes'>
	self style: #STYLEstrikeout
    ]

    underline [
	"Underline the text to which these attributes are applied"

	<category: 'setting attributes'>
	self style: #STYLEunderline
    ]
]



Object subclass: BTextTags [
    | client tags |
    
    <category: 'Graphics-Windows'>
    <comment: 'I am a private class. I sit between a BText and BTextAttributes, helping
the latter in telling the former which attributes to use.'>

    BTextTags class >> new [
	<category: 'private - instance creation'>
	self shouldNotImplement
    ]

    BTextTags class >> new: client [
	<category: 'private - instance creation'>
	^super new initialize: client
    ]

    bgColor: color [
	<category: 'private - BTextAttributes protocol'>
	^' b_' , (self color: color)
    ]

    events: aBTextBindings [
	<category: 'private - BTextAttributes protocol'>
	| tagName |
	tagName := aBTextBindings tagName.
	(tags includes: tagName) 
	    ifFalse: 
		[tags add: tagName.
		aBTextBindings defineTagFor: client].
	^' ' , tagName
    ]

    fgColor: color [
	<category: 'private - BTextAttributes protocol'>
	^' f_' , (self color: color)
    ]

    font: font [
	<category: 'private - BTextAttributes protocol'>
	| tagName |
	tagName := WriteStream on: (String new: 20).
	font substrings do: 
		[:each | 
		tagName
		    nextPutAll: each;
		    nextPut: $_].
	tagName := tagName contents.
	(tags includes: tagName) 
	    ifFalse: 
		[tags add: tagName.
		client defineTag: tagName as: ' -font {' , font , '}'].
	^' ' , tagName
    ]

    color: color [
	<category: 'private'>
	| tagName |
	tagName := (color at: 1) = $# 
		    ifTrue: 
			[(color copy)
			    at: 1 put: $_;
			    yourself]
		    ifFalse: [color asLowercase].
	(tags includes: tagName) 
	    ifFalse: 
		[tags add: tagName.
		client defineTag: 'f_' , tagName as: ' -foreground ' , color.
		client defineTag: 'b_' , tagName as: ' -background ' , color].
	^tagName
    ]

    initialize: clientBText [
	<category: 'private'>
	client := clientBText.
	tags := Set new.
	client defineTag: 'STYLEstrikeout' as: ' -overstrike 1'.
	client defineTag: 'STYLEunderline' as: ' -underline 1'.
	client defineTag: 'STYLEcenter' as: ' -justify center'
    ]
]



"-------------------------- BText class -----------------------------"



"-------------------------- BTextBindings class -----------------------------"



"-------------------------- BTextAttributes class -----------------------------"



"-------------------------- BTextTags class -----------------------------"

