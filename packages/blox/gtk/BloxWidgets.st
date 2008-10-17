"======================================================================
|
|   Smalltalk Tk-based GUI building blocks (basic widget classes).
|
|
 ======================================================================"

"======================================================================
|
| Copyright 1999, 2000, 2001, 2002, 2008 Free Software Foundation, Inc.
| Written by Paolo Bonzini and Robert Collins.
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



BPrimitive subclass: BEdit [
    | callback |
    
    <comment: 'I am a widget showing one line of modifiable text.'>
    <category: 'Graphics-Windows'>

    Initialized := nil.

    BEdit class >> new: parent contents: aString [
	"Answer a new BEdit widget laid inside the given parent widget,
	 with a default content of aString"

	<category: 'instance creation'>
	^(self new: parent)
	    contents: aString;
	    yourself
    ]

    BEdit class >> initializeOnStartup [
	<category: 'private'>
	Initialized := false
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
	self tclEval: 'return ${var' , self connected , '}'.
	^self tclResult
    ]

    contents: newText [
	"Set the contents of the widget"

	<category: 'accessing'>
	self tclEval: 'set var' , self connected , ' ' , newText asTkString
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

    create [
	"Private - Set up the widget and Tcl hooks to get callbacks from
	 it."

	<category: 'private'>
	self create: ' -width 0'.
	Initialized ifFalse: [self defineCallbackProcedure].
	self 
	    tclEval: '
	set var%1 {}
	bind %1 <<Changed>> {callback %2 invokeCallback}
	trace variable var%1 w doEditCallback
	%1 configure -textvariable var%1 -highlightthickness 0 -takefocus 1'
	    with: self connected
	    with: self asOop printString
    ]

    defineCallbackProcedure [
	"Private - Set up a Tcl hook to generate Changed events for entry widgets"

	<category: 'private'>
	Initialized := true.
	self 
	    tclEval: '
      proc doEditCallback { name el op } {
	regsub ^var $name {} widgetName
	event generate $widgetName <<Changed>>
      }'
    ]

    setInitialSize [
	"Make the Tk placer's status, the receiver's properties and the
	 window status (as returned by winfo) consistent. Occupy the
	 height indicated by the widget itself and the whole of the
	 parent's width, at the top left corner"

	<category: 'private'>
	self
	    x: 0 y: 0;
	    width: self parent width
    ]

    widgetType [
	<category: 'private'>
	^'entry'
    ]

    destroyed [
	"Private - The receiver has been destroyed, clear the corresponding
	 Tcl variable to avoid memory leaks."

	<category: 'widget protocol'>
	self tclEval: 'unset var' , self connected.
	super destroyed
    ]

    hasSelection [
	"Answer whether there is selected text in the widget"

	<category: 'widget protocol'>
	self tclEval: self connected , ' selection present'.
	^self tclResult = '1'
    ]

    insertAtEnd: aString [
	"Clear the selection and append aString at the end of the
	 widget."

	<category: 'widget protocol'>
	self 
	    tclEval: '%1 selection clear
	%1 insert end %2
	%1 see end'
	    with: self connected
	    with: aString asTkString
    ]

    insertText: aString [
	"Insert aString in the widget at the current insertion point,
	 replacing the currently selected text (if any)."

	<category: 'widget protocol'>
	self 
	    tclEval: 'catch { %1 delete sel.first sel.last }
	%1 insert insert %2
	%1 see insert'
	    with: self connected
	    with: aString asTkString
    ]

    invokeCallback [
	"Generate a synthetic callback."

	<category: 'widget protocol'>
	self callback isNil ifFalse: [self callback send]
    ]

    nextPut: aCharacter [
	"Clear the selection and append aCharacter at the end of the
	 widget."

	<category: 'widget protocol'>
	self insertAtEnd: (String with: aCharacter)
    ]

    nextPutAll: aString [
	"Clear the selection and append aString at the end of the
	 widget."

	<category: 'widget protocol'>
	self insertAtEnd: aString
    ]

    nl [
	"Clear the selection and append a linefeed character at the
	 end of the widget."

	<category: 'widget protocol'>
	self insertAtEnd: Character nl asString
    ]

    replaceSelection: aString [
	"Insert aString in the widget at the current insertion point,
	 replacing the currently selected text (if any), and leaving
	 the text selected."

	<category: 'widget protocol'>
	self 
	    tclEval: 'catch {
	  %1 icursor sel.first
	  %1 delete sel.first sel.last
	}
	%1 insert insert %2
	%1 select insert [expr %3 + [%1 index insert]]
	%1 see insert'
	    with: self connected
	    with: aString asTkString
	    with: aString size printString
    ]

    selectAll [
	"Select the whole contents of the widget."

	<category: 'widget protocol'>
	self tclEval: self connected , ' selection range 0 end'
    ]

    selectFrom: first to: last [
	"Sets the selection to include the characters starting with the one
	 indexed by first (the very first character in the widget having
	 index 1) and ending with the one just before last.  If last
	 refers to the same character as first or an earlier one, then the
	 widget's selection is cleared."

	<category: 'widget protocol'>
	self 
	    tclEval: '%1 selection range %2 %3'
	    with: self connected
	    with: (first - 1) printString
	    with: (last - 1) printString
    ]

    selection [
	"Answer an empty string if the widget has no selection, else answer
	 the currently selected text"

	<category: 'widget protocol'>
	| stream first |
	self 
	    tclEval: 'if [%1 selection present] {
	   return [string range ${var%1} [%1 index sel.first] [%1 index sel.last]]"
	 }'
	    with: self connected.
	^self tclResult
    ]

    selectionRange [
	"Answer nil if the widget has no selection, else answer
	 an Interval object whose first item is the index of the
	 first character in the selection, and whose last item is the
	 index of the character just after the last one in the
	 selection."

	<category: 'widget protocol'>
	| stream first |
	self 
	    tclEval: 'if [%1 selection present] {
	   return "[%1 index sel.first] [%1 index sel.last]"
	 }'
	    with: self connected.
	stream := ReadStream on: self tclResult.
	stream atEnd ifTrue: [^nil].
	first := (stream upTo: $ ) asInteger + 1.
	^first to: stream upToEnd asInteger + 1
    ]

    space [
	"Clear the selection and append a space at the end of the
	 widget."

	<category: 'widget protocol'>
	self insertAtEnd: ' '
    ]
]



BPrimitive subclass: BLabel [
    
    <comment: 'I am a label showing static text.'>
    <category: 'Graphics-Windows'>

    AnchorPoints := nil.

    BLabel class >> initialize [
	"Private - Initialize the receiver's class variables."

	<category: 'initialization'>
	(AnchorPoints := IdentityDictionary new: 15)
	    at: #topLeft put: 'nw';
	    at: #topCenter put: 'n';
	    at: #topRight put: 'ne';
	    at: #leftCenter put: 'w';
	    at: #center put: 'center';
	    at: #rightCenter put: 'e';
	    at: #bottomLeft put: 'sw';
	    at: #bottomCenter put: 's';
	    at: #bottomRight put: 'se'
    ]

    BLabel class >> new: parent label: label [
	"Answer a new BLabel widget laid inside the given parent widget,
	 showing by default the `label' String."

	<category: 'instance creation'>
	^(self new: parent)
	    label: label;
	    yourself
    ]

    alignment [
	"Answer the value of the anchor option for the widget.
	 
	 Specifies how the information in a widget (e.g. text or a bitmap) is to be
	 displayed in the widget. Must be one of the symbols #topLeft, #topCenter,
	 #topRight, #leftCenter, #center, #rightCenter, #bottomLeft, #bottomCenter,
	 #bottomRight. For example, #topLeft means display the information such that
	 its top-left corner is at the top-left corner of the widget."

	<category: 'accessing'>
	^self properties at: #alignment ifAbsent: [#topLeft]
    ]

    alignment: aSymbol [
	"Set the value of the anchor option for the widget.
	 
	 Specifies how the information in a widget (e.g. text or a bitmap) is to be
	 displayed in the widget. Must be one of the symbols #topLeft, #topCenter,
	 #topRight, #leftCenter, #center, #rightCenter, #bottomLeft, #bottomCenter,
	 #bottomRight. For example, #topLeft means display the information such that
	 its top-left corner is at the top-left corner of the widget."

	<category: 'accessing'>
	self anchor: (AnchorPoints at: aSymbol).
	self properties at: #alignment put: aSymbol
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

    label [
	"Answer the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the window."

	<category: 'accessing'>
	self properties at: #text ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -text'
	    with: self connected
	    with: self container.
	^self properties at: #text put: self tclResult
    ]

    label: value [
	"Set the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the window."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -text %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #text put: value
    ]

    anchor: value [
	"Private - Set the value of the Tk anchor option for the widget."

	<category: 'private'>
	self 
	    tclEval: '%1 configure -anchor %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #anchor put: value
    ]

    create [
	<category: 'private'>
	self create: '-anchor nw -takefocus 0'.
	self tclEval: 'bind %1 <Configure> "+%1 configure -wraplength %%w"'
	    with: self connected
    ]

    initialize: parentWidget [
	<category: 'private'>
	super initialize: parentWidget.
	parentWidget isNil 
	    ifFalse: [self backgroundColor: parentWidget backgroundColor]
    ]

    setInitialSize [
	"Make the Tk placer's status, the receiver's properties and the
	 window status (as returned by winfo) consistent. Occupy the
	 area indicated by the widget itself, at the top left corner"

	<category: 'private'>
	self x: 0 y: 0
    ]

    widgetType [
	<category: 'private'>
	^'label'
    ]
]



BPrimitive subclass: BButton [
    | callback |
    
    <comment: 'I am a button that a user can click. In fact I am at the head
of a small hierarchy of objects which exhibit button-like look
and behavior'>
    <category: 'Graphics-Windows'>

    BButton class >> new: parent label: label [
	"Answer a new BButton widget laid inside the given parent widget,
	 showing by default the `label' String."

	<category: 'instance creation'>
	^(self new: parent)
	    label: label;
	    yourself
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
	"Answer a DirectedMessage that is sent when the receiver is clicked,
	 or nil if none has been set up."

	<category: 'accessing'>
	^callback
    ]

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a zero- or one-argument selector) when the receiver is clicked.
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

	"self tclEval: '%1 configure -font %3'
	 with: self connected
	 with: self container
	 with: (value  asTkString).
	 self properties at: #font put: value"

	<category: 'accessing'>
	
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

    invokeCallback [
	"Generate a synthetic callback"

	<category: 'accessing'>
	self callback isNil ifFalse: [self callback send]
    ]

    label [
	"Answer the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the window."

	<category: 'accessing'>
	^self connected getLabel
    ]

    label: value [
	"Set the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the window."

	<category: 'accessing'>
	self connected setLabel: value
    ]

    create [
	<category: 'private'>
	self connected: GTK.GtkButton new.
	self connected 
	    connectSignal: 'clicked'
	    to: self
	    selector: #onClicked:data:
	    userData: nil
    ]

    onClicked: aButton data: userData [
	<category: 'private'>
	self invokeCallback
    ]

    setInitialSize [
	"Make the Tk placer's status, the receiver's properties and the
	 window status (as returned by winfo) consistent. Occupy the
	 area indicated by the widget itself, at the top left corner"

	<category: 'private'>
	
    ]
]



BPrimitive subclass: BForm [
    
    <comment: 'I am used to group many widgets together.'>
    <category: 'Graphics-Windows'>

    backgroundColor [
	"Answer the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	| style |
	style := self container getStyle.
	'FIXME ok, backGroundColor isn"t trivial to get' printNl
	"self properties at: #background ifPresent: [ :value | ^value ].
	 self tclEval: '%1 cget -background'
	 with: self connected
	 with: self container.
	 ^self properties at: #background put: (self tclResult )"
    ]

    backgroundColor: value [
	"Set the value of the backgroundColor option for the widget.
	 
	 Specifies the normal background color to use when displaying the widget."

	<category: 'accessing'>
	| color |
	value printNl.
	'fixme implement bg color, will need CStruct Color' printNl
	"color:=GTK.GdkColor new.
	 GTK.GdkColor parse: value color: color.
	 self container modifyBg: GTK.Gtk gtkStateNormal color: (nil)"
    ]

    defaultHeight [
	"Answer the value of the defaultHeight option for the widget.
	 
	 Specifies the desired height for the form in pixels. If this option
	 is less than or equal to zero then the window will not request any size at all."

	<category: 'accessing'>
	self properties at: #height ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -height'
	    with: self connected
	    with: self container.
	^self properties at: #height put: self tclResult asNumber
    ]

    defaultHeight: value [
	"Set the value of the defaultHeight option for the widget.
	 
	 Specifies the desired height for the form in pixels. If this option
	 is less than or equal to zero then the window will not request any size at all."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -height %3'
	    with: self connected
	    with: self container
	    with: value printString asTkString.
	self properties at: #height put: value
    ]

    defaultWidth [
	"Answer the value of the defaultWidth option for the widget.
	 
	 Specifies the desired width for the form in pixels. If this option
	 is less than or equal to zero then the window will not request any size at all."

	<category: 'accessing'>
	self properties at: #width ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -width'
	    with: self connected
	    with: self container.
	^self properties at: #width put: self tclResult asNumber
    ]

    defaultWidth: value [
	"Set the value of the defaultWidth option for the widget.
	 
	 Specifies the desired width for the form in pixels. If this option
	 is less than or equal to zero then the window will not request any size at all."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -width %3'
	    with: self connected
	    with: self container
	    with: value printString asTkString.
	self properties at: #width put: value
    ]

    create [
	<category: 'private'>
	self connected: GTK.GtkPlacer new
    ]

    addChild: child [
	<category: 'private'>
	(self connected)
	    add: child container;
	    moveRel: child container
		relX: 0
		relY: 0.
	^child
    ]

    child: child height: value [
	"Set the given child's height to value.  The default implementation of
	 this method uses `rubber-sheet' geometry management as explained in
	 the comment to BWidget's #height method.  You should not use this
	 method, which is automatically called by the child's #height: method,
	 but you might want to override it.  The child's property slots whose
	 name ends with `Geom' are reserved for this method. This method
	 should never fail -- if it doesn't apply to the kind of geometry
	 management that the receiver does, just do nothing."

	<category: 'geometry'>
	| relative heightParent |
	heightParent := self height.
	heightParent <= 0 ifTrue: [^self].
	relative := value * 32767 // heightParent.
	relative := relative min: 32767.
	relative := relative max: 0.
	self connected 
	    resizeRel: child container
	    relWidth: (child properties at: #widthGeom ifAbsent: [32767])
	    relHeight: (child properties at: #heightGeom put: relative)
    ]

    child: child heightOffset: value [
	"Adjust the given child's height by a fixed amount of value pixel.  This
	 is meaningful for the default implementation, using `rubber-sheet'
	 geometry management as explained in the comment to BWidget's #height and
	 #heightOffset: methods.  You should not use this method, which is
	 automatically called by the child's #heightOffset: method, but you
	 might want to override it.  if it doesn't apply to the kind of
	 geometry management that the receiver does, just add value to the
	 current height of the widget."

	<category: 'geometry'>
	self connected 
	    resize: child container
	    width: (child properties at: #widthGeomOfs ifAbsent: [0])
	    height: value
    ]

    child: child inset: pixels [
	<category: 'geometry'>
	^child
	    xOffset: self xOffset + pixels;
	    yOffset: self yOffset + pixels;
	    widthOffset: self widthOffset - (pixels * 2);
	    heightOffset: self heightOffset - (pixels * 2)
    ]

    child: child stretch: aBoolean [
	"This method is only used when on the path from the receiver
	 to its toplevel there is a BContainer.  It decides whether child is
	 among the widgets that are stretched to fill the entire width of
	 the BContainer; if this has not been set for this widget, it
	 is propagated along the widget hierarchy."

	<category: 'geometry'>
	self properties at: #stretch
	    ifAbsent: 
		[self parent isNil ifTrue: [^self].
		self parent child: self stretch: aBoolean]
    ]

    child: child width: value [
	"Set the given child's width to value.  The default implementation of
	 this method uses `rubber-sheet' geometry management as explained in
	 the comment to BWidget's #width method.  You should not use this
	 method, which is automatically called by the child's #width: method,
	 but you might want to override it.  The child's property slots whose
	 name ends with `Geom' are reserved for this method. This method
	 should never fail -- if it doesn't apply to the kind of geometry
	 management that the receiver does, just do nothing."

	<category: 'geometry'>
	| relative widthParent |
	widthParent := self width.
	widthParent <= 0 ifTrue: [^self].
	relative := value * 32767 // widthParent.
	relative := relative min: 32767.
	relative := relative max: 0.
	self connected 
	    resizeRel: child container
	    relWidth: (child properties at: #widthGeom put: relative)
	    relHeight: (child properties at: #widthGeom ifAbsent: [32767])
    ]

    child: child widthOffset: value [
	"Adjust the given child's width by a fixed amount of value pixel.  This
	 is meaningful for the default implementation, using `rubber-sheet'
	 geometry management as explained in the comment to BWidget's #width and
	 #widthOffset: methods.  You should not use this method, which is
	 automatically called by the child's #widthOffset: method, but you
	 might want to override it.  if it doesn't apply to the kind of
	 geometry management that the receiver does, just add value to the
	 current width of the widget."

	<category: 'geometry'>
	self connected 
	    resize: child container
	    width: value
	    height: (child properties at: #widthGeomOfs ifAbsent: [0])
    ]

    child: child x: value [
	"Set the given child's x to value.  The default implementation of
	 this method uses `rubber-sheet' geometry management as explained in
	 the comment to BWidget's #x method.  You should not use this
	 method, which is automatically called by the child's #x: method,
	 but you might want to override it.  The child's property slots whose
	 name ends with `Geom' are reserved for this method. This method
	 should never fail -- if it doesn't apply to the kind of geometry
	 management that the receiver does, just do nothing."

	<category: 'geometry'>
	| relative widthParent |
	widthParent := self width.
	widthParent <= 0 ifTrue: [^self].
	relative := value * 32767 // widthParent.
	relative := relative min: 32767.
	relative := relative max: 0.
	self connected 
	    moveRel: child container
	    relX: (child properties at: #xGeom put: relative)
	    relY: (child properties at: #yGeom ifAbsent: [0])
    ]

    child: child xOffset: value [
	"Adjust the given child's x by a fixed amount of value pixel.  This
	 is meaningful for the default implementation, using `rubber-sheet'
	 geometry management as explained in the comment to BWidget's #x and
	 #xOffset: methods.  You should not use this method, which is
	 automatically called by the child's #xOffset: method, but you
	 might want to override it.  if it doesn't apply to the kind of
	 geometry management that the receiver does, just add value to the
	 current x of the widget."

	<category: 'geometry'>
	self connected 
	    move: child container
	    x: value
	    y: (child properties at: #yGeomOfs ifAbsent: [0])
    ]

    child: child y: value [
	"Set the given child's y to value.  The default implementation of
	 this method uses `rubber-sheet' geometry management as explained in
	 the comment to BWidget's #y method.  You should not use this
	 method, which is automatically called by the child's #y: method,
	 but you might want to override it.  The child's property slots whose
	 name ends with `Geom' are reserved for this method. This method
	 should never fail -- if it doesn't apply to the kind of geometry
	 management that the receiver does, just do nothing."

	<category: 'geometry'>
	| relative heightParent |
	heightParent := self height.
	heightParent <= 0 ifTrue: [^self].
	relative := value * 32767 // heightParent.
	relative := relative min: 32767.
	relative := relative max: 0.
	self connected 
	    moveRel: child container
	    relX: (child properties at: #xGeom ifAbsent: [0])
	    relY: (child properties at: #yGeom put: relative)
    ]

    child: child yOffset: value [
	"Adjust the given child's y by a fixed amount of value pixel.  This
	 is meaningful for the default implementation, using `rubber-sheet'
	 geometry management as explained in the comment to BWidget's #y and
	 #yOffset: methods.  You should not use this method, which is
	 automatically called by the child's #yOffset: method, but you
	 might want to override it.  if it doesn't apply to the kind of
	 geometry management that the receiver does, just add value to the
	 current y of the widget."

	<category: 'geometry'>
	self connected 
	    move: child container
	    x: (child properties at: #xGeomOfs ifAbsent: [0])
	    y: value
    ]

    heightChild: child [
	"Answer the given child's height.  The default implementation of this
	 method uses `rubber-sheet' geometry management as explained in
	 the comment to BWidget's #height method.  You should not use this
	 method, which is automatically called by the child's #height method,
	 but you might want to override.  The child's property slots whose
	 name ends with `Geom' are reserved for this method.  This method
	 should never fail -- if it doesn't apply to the kind of geometry
	 management that the receiver does, just return 0."

	<category: 'geometry'>
	^(child properties at: #heightGeom ifAbsentPut: [32767]) * self height 
	    // 32767
    ]

    widthChild: child [
	"Answer the given child's width.  The default implementation of this
	 method uses `rubber-sheet' geometry management as explained in
	 the comment to BWidget's #width method.  You should not use this
	 method, which is automatically called by the child's #width method,
	 but you might want to override.  The child's property slots whose
	 name ends with `Geom' are reserved for this method.  This method
	 should never fail -- if it doesn't apply to the kind of geometry
	 management that the receiver does, just return 0."

	<category: 'geometry'>
	^(child properties at: #widthGeom ifAbsentPut: [32767]) * self width 
	    // 32767
    ]

    xChild: child [
	"Answer the given child's x.  The default implementation of this
	 method uses `rubber-sheet' geometry management as explained in
	 the comment to BWidget's #x method.  You should not use this
	 method, which is automatically called by the child's #x method,
	 but you might want to override.  The child's property slots whose
	 name ends with `Geom' are reserved for this method.  This method
	 should never fail -- if it doesn't apply to the kind of geometry
	 management that the receiver does, just return 0."

	<category: 'geometry'>
	^(child properties at: #xGeom ifAbsentPut: [0]) * self width // 32767
    ]

    yChild: child [
	"Answer the given child's y.  The default implementation of this
	 method uses `rubber-sheet' geometry management as explained in
	 the comment to BWidget's #y method.  You should not use this
	 method, which is automatically called by the child's #y method,
	 but you might want to override.  The child's property slots whose
	 name ends with `Geom' are reserved for this method.  This method
	 should never fail -- if it doesn't apply to the kind of geometry
	 management that the receiver does, just return 0."

	<category: 'geometry'>
	^(child properties at: #yGeom ifAbsentPut: [0]) * self height // 32767
    ]
]



BForm subclass: BContainer [
    | verticalLayout |
    
    <comment: 'I am used to group many widgets together. I can perform simple
management by putting widgets next to each other, from left to
right or from top to bottom.'>
    <category: 'Graphics-Windows'>

    addChild: child [
	"The widget identified by child has been added to the receiver.
	 This method is public not because you can call it, but because
	 it can be useful to override it to perform some initialization on
	 the children just added. Answer the new child."

	<category: 'accessing'>
	self connected 
	    packStart: child container
	    expand: false
	    fill: false
	    padding: 0.
	^child
    ]

    setVerticalLayout: aBoolean [
	"Answer whether the container will align the widgets vertically or
	 horizontally.  Horizontal alignment means that widgets are
	 packed from left to right, while vertical alignment means that
	 widgets are packed from the top to the bottom of the widget.
	 
	 Widgets that are set to be ``stretched'' will share all the
	 space that is not allocated to non-stretched widgets.
	 
	 The layout of the widget can only be set before the first child
	 is inserted in the widget."

	<category: 'accessing'>
	children isEmpty 
	    ifFalse: [^self error: 'cannot set layout after the first child is created'].
	verticalLayout := aBoolean
    ]

    create [
	<category: 'private'>
	self verticalLayout 
	    ifTrue: [self connected: (GTK.GtkVBox new: false spacing: 0)]
	    ifFalse: [self connected: (GTK.GtkHBox new: false spacing: 0)]
    ]

    verticalLayout [
	"answer true if objects should be laid out vertically"

	<category: 'private'>
	verticalLayout isNil ifTrue: [verticalLayout := true].
	^verticalLayout
    ]

    initialize: parentWidget [
	"This is called by #new: to initialize the widget (as the name
	 says...). The default implementation calls all the other
	 methods in the `customization' protocol and some private
	 ones that take care of making the receiver's status consistent,
	 so you should usually call it instead of doing everything by
	 hand. This method is public not because you can call it, but
	 because it might be useful to override it. Always answer the
	 receiver."

	<category: 'private'>
	parent := parentWidget.
	properties := IdentityDictionary new.
	children := OrderedCollection new
    ]

    child: child height: value [
	<category: 'private'>
	(child -> value -> (self heightChild: child)) printNl.
	^child container setSizeRequest: (self widthChild: child) height: value
    ]

    child: child heightOffset: value [
	<category: 'private'>
	
    ]

    child: child inset: value [
	<category: 'private'>
	| stretch |
	stretch := child properties at: #stretchGeom ifAbsent: [false].
	self connected 
	    setChildPacking: child container
	    expand: stretch
	    fill: stretch
	    padding: (child properties at: #paddingGeom put: value)
	    packType: GTK.Gtk gtkPackStart
    ]

    child: child stretch: aBoolean [
	<category: 'private'>
	child properties at: #stretchGeom put: aBoolean.
	self connected 
	    setChildPacking: child container
	    expand: aBoolean
	    fill: aBoolean
	    padding: (child properties at: #paddingGeom ifAbsent: [0])
	    packType: GTK.Gtk gtkPackStart
    ]

    child: child width: value [
	<category: 'private'>
	^child container setSizeRequest: value height: (self heightChild: child)
    ]

    child: child widthOffset: value [
	<category: 'private'>
	
    ]

    child: child x: value [
	<category: 'private'>
	
    ]

    child: child xOffset: value [
	<category: 'private'>
	
    ]

    child: child y: value [
	<category: 'private'>
	
    ]

    child: child yOffset: value [
	<category: 'private'>
	
    ]

    heightChild: child [
	<category: 'private'>
	^child container getSizeRequest at: 2
    ]

    widthChild: child [
	<category: 'private'>
	^child container getSizeRequest at: 1
    ]

    xChild: child [
	<category: 'private'>
	^child xAbsolute
    ]

    yChild: child [
	<category: 'private'>
	^child yAbsolute
    ]
]



BContainer subclass: BRadioGroup [
    | value |
    
    <comment: 'I am used to group many mutually-exclusive radio buttons together.
In addition, just like every BContainer I can perform simple management
by putting widgets next to each other, from left to right or (which is
more useful in this particular case...) from top to bottom.'>
    <category: 'Graphics-Windows'>

    value [
	"Answer the index of the button that is currently selected,
	 1 being the first button added to the radio button group.
	 0 means that no button is selected"

	<category: 'accessing'>
	^value
    ]

    value: anInteger [
	"Force the value-th button added to the radio button group
	 to be the selected one."

	<category: 'accessing'>
	value = anInteger ifTrue: [^self].
	self childrenCount = 0 ifTrue: [^self].
	value = 0 ifFalse: [(children at: value) connected setActive: false].
	value := anInteger.
	anInteger = 0 ifFalse: [(children at: value) connected setActive: true]
    ]

    addChild: child [
	<category: 'private'>
	super addChild: child.
	child assignedValue: self childrenCount.
	self childrenCount = 1 ifTrue: [self value: 1].
	child connected 
	    connectSignal: 'toggled'
	    to: self
	    selector: #onToggle:data:
	    userData: self childrenCount.
	^child
    ]

    onToggle: widget data: userData [
	<category: 'private'>
	value := userData.
	(children at: userData) invokeCallback
    ]

    group [
	"answer the radio group my children are in"

	<category: 'private'>
	| child |
	child := children at: 1.
	^child exists ifFalse: [nil] ifTrue: [child connected getGroup]
    ]

    initialize: parentWidget [
	<category: 'private'>
	super initialize: parentWidget.
	value := 0
    ]
]



BButton subclass: BRadioButton [
    | assignedValue |
    
    <comment: 'I am just one in a group of mutually exclusive buttons.'>
    <category: 'Graphics-Windows'>

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a selector accepting at most two arguments) when the receiver is
	 clicked.  If the method accepts two arguments, the receiver is
	 passed as the first parameter.  If the method accepts one or two
	 arguments, true is passed as the last parameter for interoperability
	 with BToggle widgets."

	<category: 'accessing'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	arguments := #().
	numArgs = 1 ifTrue: [arguments := #(true)].
	numArgs = 2 
	    ifTrue: 
		[arguments := 
			{self.
			true}].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    value [
	"Answer whether this widget is the selected one in its radio
	 button group."

	<category: 'accessing'>
	^self parent value = assignedValue
    ]

    value: aBoolean [
	"Answer whether this widget is the selected one in its radio
	 button group.  Setting this property to false for a group's
	 currently selected button unhighlights all the buttons in that
	 group."

	<category: 'accessing'>
	aBoolean 
	    ifTrue: 
		[self parent value: assignedValue.
		^self].

	"aBoolean is false - unhighlight everything if we're active"
	self value ifTrue: [self parent value: 0]
    ]

    assignedValue: anInteger [
	<category: 'private'>
	assignedValue := anInteger
    ]

    create [
	<category: 'private'>
	self 
	    connected: (GTK.GtkRadioButton newWithLabel: self parent group label: '')
    ]
]



BButton subclass: BToggle [
    | value |
    
    <comment: 'I represent a button whose choice can be included (by checking
me) or excluded (by leaving me unchecked).'>
    <category: 'Graphics-Windows'>

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a selector accepting at most two arguments) when the receiver is
	 clicked.  If the method accepts two arguments, the receiver is
	 passed as the first parameter.  If the method accepts one or two
	 arguments, the state of the widget (true if it is selected, false
	 if it is not) is passed as the last parameter."

	<category: 'accessing'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	arguments := #().
	numArgs = 1 ifTrue: [arguments := {nil}].
	numArgs = 2 
	    ifTrue: 
		[arguments := 
			{self.
			nil}].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    invokeCallback [
	"Generate a synthetic callback."

	<category: 'accessing'>
	self callback isNil ifTrue: [^self].
	self callback arguments size > 0 
	    ifTrue: 
		[self callback arguments at: self callback arguments size put: self value].
	super invokeCallback
    ]

    value [
	"Answer whether the button is in a selected (checked) state."

	<category: 'accessing'>
	self tclEval: 'return ${var' , self connected , '}'.
	^self tclResult = '1'
    ]

    value: aBoolean [
	"Set whether the button is in a selected (checked) state and
	 generates a callback accordingly."

	<category: 'accessing'>
	aBoolean 
	    ifTrue: [self tclEval: 'set var' , self connected , ' 1']
	    ifFalse: [self tclEval: 'set var' , self connected , ' 0']
    ]

    variable: value [
	"Set the value of Tk's variable option for the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -variable %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #variable put: value
    ]

    initialize: parentWidget [
	<category: 'private'>
	| variable |
	super initialize: parentWidget.
	self tclEval: self connected , ' configure -anchor nw'.
	self tclEval: 'variable var' , self connected.
	self variable: 'var' , self connected.
	self backgroundColor: parentWidget backgroundColor
    ]

    widgetType [
	<category: 'private'>
	^'checkbutton'
    ]
]



BPrimitive subclass: BImage [
    
    <comment: 'I can display colorful images.'>
    <category: 'Graphics-Windows'>

    BImage class >> downArrow [
	"Answer the XPM representation of a 12x12 arrow pointing downwards."

	<category: 'arrows'>
	^'/* XPM */
static char * downarrow_xpm[] = {
/* width height ncolors chars_per_pixel */
"12 12 2 1",
/* colors */
" 	c None    m None   s None",
"o	c black   m black",
/* pixels */
"            ",
"            ",
"            ",
"            ",
"  ooooooo   ",
"   ooooo    ",
"    ooo     ",
"     o      ",
"            ",
"            ",
"            ",
"            "};
'
    ]

    BImage class >> leftArrow [
	"Answer the XPM representation of a 12x12 arrow pointing leftwards."

	<category: 'arrows'>
	^'/* XPM */
static char * leftarrow_xpm[] = {
/* width height ncolors chars_per_pixel */
"12 12 2 1",
/* colors */
" 	c None    m None   s None",
"o	c black   m black",
/* pixels */
"            ",
"            ",
"       o    ",
"      oo    ",
"     ooo    ",
"    oooo    ",
"     ooo    ",
"      oo    ",
"       o    ",
"            ",
"            ",
"            "};
'
    ]

    BImage class >> upArrow [
	"Answer the XPM representation of a 12x12 arrow pointing upwards."

	<category: 'arrows'>
	^'/* XPM */
static char * uparrow_xpm[] = {
/* width height ncolors chars_per_pixel */
"12 12 2 1",
/* colors */
" 	c None    m None   s None",
"o	c black   m black",
/* pixels */
"            ",
"            ",
"            ",
"            ",
"     o      ",
"    ooo     ",
"   ooooo    ",
"  ooooooo   ",
"            ",
"            ",
"            ",
"            "};
'
    ]

    BImage class >> rightArrow [
	"Answer the XPM representation of a 12x12 arrow pointing rightwards."

	<category: 'arrows'>
	^'/* XPM */
static char * rightarrow_xpm[] = {
/* width height ncolors chars_per_pixel */
"12 12 2 1",
/* colors */
" 	c None    m None   s None",
"o	c black   m black",
/* pixels */
"            ",
"            ",
"    o       ",
"    oo      ",
"    ooo     ",
"    oooo    ",
"    ooo     ",
"    oo      ",
"    o       ",
"            ",
"            ",
"            "};
'
    ]

    BImage class >> gnu [
	"Answer the XPM representation of a 48x48 GNU."

	<category: 'GNU'>
	^'/* XPM */
/*****************************************************************************/
/* GNU Emacs bitmap conv. to pixmap by Przemek Klosowski (przemek@nist.gov)  */
/*****************************************************************************/
static char * image_name [] = {
/* width height ncolors chars_per_pixel */
"48 48 7 1",
/* colors */
" 	s mask	c none",
"B      c blue",
"x      c black",          	    
":      c SandyBrown",  	    
"+      c SaddleBrown",
"o      c grey",		       	    
".      c white",
/* pixels */
"                                                ",
"                                   x            ",
"                                    :x          ",
"                                    :::x        ",
"                                      ::x       ",
"          x                             ::x     ",
"         x:                xxx          :::x    ",
"        x:           xxx xxx:xxx         x::x   ",
"       x::       xxxx::xxx:::::xx        x::x   ",
"      x::       x:::::::xx::::::xx       x::x   ",
"      x::      xx::::::::x:::::::xx     xx::x   ",
"     x::      xx::::::::::::::::::x    xx::xx   ",
"    x::x     xx:::::xxx:::::::xxx:xxx xx:::xx   ",
"   x:::x    xx:::::xx...xxxxxxxxxxxxxxx:::xx    ",
"   x:::x   xx::::::xx..xxx...xxxx...xxxxxxxx    ",
"   x:::x   x::::::xx.xxx.......x.x.......xxxx   ",
"   x:::xx x:::x::xx.xx..........x.xx.........x  ",
"   x::::xx::xx:::x.xx....ooooxoxoxoo.xxx.....x  ",
"   xx::::xxxx::xx.xx.xxxx.ooooooo.xxx    xxxx   ",
"    xx::::::::xx..x.xxx..ooooooooo.xx           ",
"    xxx:::::xxx..xx.xx.xx.xxx.ooooo.xx          ",
"      xxx::xx...xx.xx.BBBB..xxooooooxx          ",
"       xxxx.....xx.xxBB:BB.xxoooooooxx          ",
"        xx.....xx...x.BBBx.xxxooooooxx          ",
"       x....xxxx..xx...xxxooooooooooxx          ",
"       x..xxxxxx..x.......x..ooooooooxx         ",
"       x.x xxx.x.x.x...xxxx.oooooooooxx         ",
"        x  xxx.x.x.xx...xx..oooooooooxx         ",
"          xx.x..x.x.xx........oooooooox         ",
"         xxo.xx.x.x.x.x.......ooooooooox        ",
"         xxo..xxxx..x...x.......ooooooox        ",
"         xxoo.xx.x..xx...x.......ooo.xxx        ",
"         xxoo..x.x.x.x.x.xx.xxxxx.o.xx+xx       ",
"         xxoo..x.xx..xx.x.x.x+++xxxxx+++x       ",
"         xxooo.x..xxx.x.x.x.x+++++xxx+xxx       ",
"          xxoo.xx..x..xx.xxxx++x+++x++xxx       ",
"          xxoo..xx.xxx.xxx.xxx++xx+x++xx        ",
"           xxooo.xx.xx..xx.xxxx++x+++xxx        ",
"           xxooo.xxx.xx.xxxxxxxxx++++xxx        ",
"            xxoo...xx.xx.xxxxxx++xxxxxxx        ",
"            xxoooo..x..xxx..xxxx+++++xx         ",
"             xxoooo..x..xx..xxxx++++xx          ",
"              xxxooooox.xx.xxxxxxxxxxx          ",
"               xxxooooo..xxx    xxxxx           ",
"                xxxxooooxxxx                    ",
"                  xxxoooxxx                     ",
"                    xxxxx                       ",
"                                                "
};'
    ]

    BImage class >> exclaim [
	"Answer the XPM representation of a 32x32 exclamation mark icon."

	<category: 'icons'>
	^'/* XPM */
static char * exclaim_xpm[] = {
/* width height ncolors chars_per_pixel */
"32 32 6 1",
/* colors */
" 	c None    m None   s None",
".	c yellow  m white",
"X	c black   m black",
"x	c gray50  m black",
"o	c gray    m white",
"b	c yellow4 m black",
/* pixels */
"             bbb                ",
"            b..oX               ",
"           b....oXx             ",
"           b.....Xxx            ",
"          b......oXxx           ",
"          b.......Xxx           ",
"         b........oXxx          ",
"         b.........Xxx          ",
"        b..........oXxx         ",
"        b...oXXXo...Xxx         ",
"       b....XXXXX...oXxx        ",
"       b....XXXXX....Xxx        ",
"      b.....XXXXX....oXxx       ",
"      b.....XXXXX.....Xxx       ",
"     b......XXXXX.....oXxx      ",
"     b......bXXXb......Xxx      ",
"    b.......oXXXo......oXxx     ",
"    b........XXX........Xxx     ",
"   b.........bXb........oXxx    ",
"   b.........oXo.........Xxx    ",
"  b...........X..........oXxx   ",
"  b.......................Xxx   ",
" b...........oXXo.........oXxx  ",
" b...........XXXX..........Xxx  ",
"b............XXXX..........oXxx ",
"b............oXXo...........Xxx ",
"b...........................Xxxx",
"b..........................oXxxx",
" b........................oXxxxx",
"  bXXXXXXXXXXXXXXXXXXXXXXXXxxxxx",
"    xxxxxxxxxxxxxxxxxxxxxxxxxxx ",
"     xxxxxxxxxxxxxxxxxxxxxxxxx  "};
'
    ]

    BImage class >> info [
	"Answer the XPM representation of a 32x32 `information' icon."

	<category: 'icons'>
	^'/* XPM */
static char * info_xpm[] = {
/* width height ncolors chars_per_pixel */
"32 32 6 1",
/* colors */
" 	c None    m None   s None",
".	c white   m white",
"X	c black   m black",
"x	c gray50  m black",
"o	c gray    m white",
"b	c blue    m black",
/* pixels */
"           xxxxxxxx             ",
"        xxxo......oxxx          ",
"      xxo............oxx        ",
"     xo................ox       ",
"    x.......obbbbo.......X      ",
"   x........bbbbbb........X     ",
"  x.........bbbbbb.........X    ",
" xo.........obbbbo.........oX   ",
" x..........................Xx  ",
"xo..........................oXx ",
"x..........bbbbbbb...........Xx ",
"x............bbbbb...........Xxx",
"x............bbbbb...........Xxx",
"x............bbbbb...........Xxx",
"x............bbbbb...........Xxx",
"xo...........bbbbb..........oXxx",
" x...........bbbbb..........Xxxx",
" xo..........bbbbb.........oXxxx",
"  x........bbbbbbbbb.......Xxxx ",
"   X......................Xxxxx ",
"    X....................Xxxxx  ",
"     Xo................oXxxxx   ",
"      XXo............oXXxxxx    ",
"       xXXXo......oXXXxxxxx     ",
"        xxxXXXo...Xxxxxxxx      ",
"          xxxxX...Xxxxxx        ",
"             xX...Xxx           ",
"               X..Xxx           ",
"                X.Xxx           ",
"                 XXxx           ",
"                  xxx           ",
"                   xx           "};
'
    ]

    BImage class >> question [
	"Answer the XPM representation of a 32x32 question mark icon."

	<category: 'icons'>
	^'/* XPM */
static char * question_xpm[] = {
/* width height ncolors chars_per_pixel */
"32 32 6 1",
/* colors */
" 	c None    m None   s None",
".	c white   m white",
"X	c black   m black",
"x	c gray50  m black",
"o	c gray    m white",
"b	c blue    m black",
/* pixels */
"           xxxxxxxx             ",
"        xxxo......oxxx          ",
"      xxo............oxx        ",
"     xo................ox       ",
"    x....................X      ",
"   x.......obbbbbbo.......X     ",
"  x.......obo..bbbbo.......X    ",
" xo.......bb....bbbb.......oX   ",
" x........bbbb..bbbb........Xx  ",
"xo........bbbb.obbbb........oXx ",
"x.........obbo.bbbb..........Xx ",
"x.............obbb...........Xxx",
"x.............bbb............Xxx",
"x.............bbo............Xxx",
"x.............bb.............Xxx",
"xo..........................oXxx",
" x...........obbo...........Xxxx",
" xo..........bbbb..........oXxxx",
"  x..........bbbb..........Xxxx ",
"   X.........obbo.........Xxxxx ",
"    X....................Xxxxx  ",
"     Xo................oXxxxx   ",
"      XXo............oXXxxxx    ",
"       xXXXo......oXXXxxxxx     ",
"        xxxXXXo...Xxxxxxxx      ",
"          xxxxX...Xxxxxx        ",
"             xX...Xxx           ",
"               X..Xxx           ",
"                X.Xxx           ",
"                 XXxx           ",
"                  xxx           ",
"                   xx           "};
'
    ]

    BImage class >> stop [
	"Answer the XPM representation of a 32x32 `critical stop' icon."

	<category: 'icons'>
	^'/* XPM */
static char * stop_xpm[] = {
/* width height ncolors chars_per_pixel */
"32 32 5 1",
/* colors */
" 	c None    m None   s None",
".	c red     m white",
"o	c DarkRed m black",
"X	c white   m black",
"x	c gray50  m black",
/* pixels */
"           oooooooo             ",
"        ooo........ooo          ",
"       o..............o         ",
"     oo................oo       ",
"    o....................o      ",
"   o......................o     ",
"   o......................ox    ",
"  o......X..........X......ox   ",
" o......XXX........XXX......o   ",
" o.....XXXXX......XXXXX.....ox  ",
" o......XXXXX....XXXXX......oxx ",
"o........XXXXX..XXXXX........ox ",
"o.........XXXXXXXXXX.........ox ",
"o..........XXXXXXXX..........oxx",
"o...........XXXXXX...........oxx",
"o...........XXXXXX...........oxx",
"o..........XXXXXXXX..........oxx",
"o.........XXXXXXXXXX.........oxx",
"o........XXXXX..XXXXX........oxx",
" o......XXXXX....XXXXX......oxxx",
" o.....XXXXX......XXXXX.....oxxx",
" o......XXX........XXX......oxx ",
"  o......X..........X......oxxx ",
"   o......................oxxxx ",
"   o......................oxxx  ",
"    o....................oxxx   ",
"     oo................ooxxxx   ",
"      xo..............oxxxxx    ",
"       xooo........oooxxxxx     ",
"         xxooooooooxxxxxx       ",
"          xxxxxxxxxxxxxx        ",
"             xxxxxxxx           "};
'
    ]

    BImage class >> new: parent data: aString [
	"Answer a new BImage widget laid inside the given parent widget,
	 loading data from the given string (Base-64 encoded GIF, XPM,
	 PPM are supported)."

	<category: 'instance creation'>
	^(self new: parent)
	    data: aString;
	    yourself
    ]

    BImage class >> new: parent image: aFileStream [
	"Answer a new BImage widget laid inside the given parent widget,
	 loading data from the given file (GIF, XPM, PPM are supported)."

	<category: 'instance creation'>
	^(self new: parent)
	    image: aFileStream;
	    yourself
    ]

    BImage class >> new: parent size: aPoint [
	"Answer a new BImage widget laid inside the given parent widget,
	 showing by default a transparent image of aPoint size."

	<category: 'instance creation'>
	^(self new: parent)
	    displayWidth: aPoint x;
	    displayHeight: aPoint y;
	    blank;
	    yourself
    ]

    BImage class >> directory [
	"Answer the Base-64 GIF representation of a `directory folder' icon."

	<category: 'small icons'>
	^'R0lGODdhEAAQAPIAAAAAAHh4eLi4uPj4+P///wAAAAAAAAAAACwAAAAAEAAQAAADPkixzPOD
yADrWE8qC8WN0+BZAmBq1GMOqwigXFXCrGk/cxjjr27fLtout6n9eMIYMTXsFZsogXRKJf6u
P0kCADv/'
    ]

    BImage class >> file [
	"Answer the Base-64 GIF representation of a `file' icon."

	<category: 'small icons'>
	^'R0lGODdhEAAQAPIAAAAAAHh4eLi4uPj4APj4+P///wAAAAAAACwAAAAAEAAQAAADPVi63P4w
LkKCtTTnUsXwQqBtAfh910UU4ugGAEucpgnLNY3Gop7folwNOBOeiEYQ0acDpp6pGAFArVqt
hQQAO///'
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

    displayHeight [
	"Answer the value of the displayHeight option for the widget.
	 
	 Specifies the height of the image in pixels. This is not the height of the
	 widget, but specifies the area of the widget that will be taken by the image."

	<category: 'accessing'>
	self properties at: #displayHeight ifPresent: [:value | ^value].
	self 
	    tclEval: 'img%1 cget -width'
	    with: self connected
	    with: self container.
	^self properties at: #displayHeight put: self tclResult asNumber
    ]

    displayHeight: value [
	"Set the value of the displayHeight option for the widget.
	 
	 Specifies the height of the image in pixels. This is not the height of the
	 widget, but specifies the area of the widget that will be taken by the image."

	<category: 'accessing'>
	self 
	    tclEval: 'img%1 configure -width %3'
	    with: self connected
	    with: self container
	    with: value asFloat printString asTkString.
	self properties at: #displayHeight put: value
    ]

    displayWidth [
	"Answer the value of the displayWidth option for the widget.
	 
	 Specifies the width of the image in pixels. This is not the width of the
	 widget, but specifies the area of the widget that will be taken by the image."

	<category: 'accessing'>
	self properties at: #displayWidth ifPresent: [:value | ^value].
	self 
	    tclEval: 'img%1 cget -width'
	    with: self connected
	    with: self container.
	^self properties at: #displayWidth put: self tclResult asNumber
    ]

    displayWidth: value [
	"Set the value of the displayWidth option for the widget.
	 
	 Specifies the width of the image in pixels. This is not the width of the
	 widget, but specifies the area of the widget that will be taken by the image."

	<category: 'accessing'>
	self 
	    tclEval: 'img%1 configure -width %3'
	    with: self connected
	    with: self container
	    with: value asFloat printString asTkString.
	self properties at: #displayWidth put: value
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

    gamma [
	"Answer the value of the gamma option for the widget.
	 
	 Specifies that the colors allocated for displaying the image widget
	 should be corrected for a non-linear display with the specified gamma exponent
	 value. (The intensity produced by most CRT displays is a power function
	 of the input value, to a good approximation; gamma is the exponent and
	 is typically around 2). The value specified must be greater than zero. The
	 default value is one (no correction). In general, values greater than one
	 will make the image lighter, and values less than one will make it darker."

	<category: 'accessing'>
	self properties at: #gamma ifPresent: [:value | ^value].
	self 
	    tclEval: 'img%1 cget -gamma'
	    with: self connected
	    with: self container.
	^self properties at: #gamma put: self tclResult asNumber
    ]

    gamma: value [
	"Set the value of the gamma option for the widget.
	 
	 Specifies that the colors allocated for displaying the image widget
	 should be corrected for a non-linear display with the specified gamma exponent
	 value. (The intensity produced by most CRT displays is a power function
	 of the input value, to a good approximation; gamma is the exponent and
	 is typically around 2). The value specified must be greater than zero. The
	 default value is one (no correction). In general, values greater than one
	 will make the image lighter, and values less than one will make it darker."

	<category: 'accessing'>
	self 
	    tclEval: 'img%1 configure -gamma %3'
	    with: self connected
	    with: self container
	    with: value asFloat printString asTkString.
	self properties at: #gamma put: value
    ]

    blank [
	"Blank the corresponding image"

	<category: 'image management'>
	self tclEval: 'img' , self connected , ' blank'
    ]

    data: aString [
	"Set the image to be drawn to aString, which can be a GIF
	 in Base-64 representation or an X pixelmap."

	<category: 'image management'>
	self tclEval: 'img' , self connected , ' configure -data ' 
		    , aString asTkImageString
    ]

    dither [
	"Recalculate the dithered image in the window where the
	 image is displayed.  The dithering algorithm used in
	 displaying images propagates quantization errors from
	 one pixel to its neighbors.  If the image data is supplied
	 in pieces, the dithered image may not be exactly correct.
	 Normally the difference is not noticeable, but if it is a
	 problem, this command can be used to fix it."

	<category: 'image management'>
	self tclEval: 'img' , self connected , ' redither'
    ]

    fillFrom: origin extent: extent color: color [
	"Fill a rectangle with the given origin and extent, using
	 the given color."

	<category: 'image management'>
	self 
	    fillFrom: origin
	    to: origin + extent
	    color: color
    ]

    fillFrom: origin to: corner color: color [
	"Fill a rectangle between the given corners, using
	 the given color."

	<category: 'image management'>
	self 
	    tclEval: 'img%1 put { %2 } -to %3 %4'
	    with: self connected
	    with: color
	    with: origin x printString , ' ' , origin y printString
	    with: corner x printString , ' ' , corner y printString
    ]

    fillRectangle: rectangle color: color [
	"Fill a rectangle having the given bounding box, using
	 the given color."

	<category: 'image management'>
	self 
	    fillFrom: rectangle origin
	    to: rectangle corner
	    color: color
    ]

    image: aFileStream [
	"Read a GIF or XPM image from aFileStream.  The whole contents
	 of the file are read, not only from the file position."

	<category: 'image management'>
	self 
	    tclEval: 'img' , self connected , ' read ' , aFileStream name asTkString
    ]

    imageHeight [
	"Specifies the height of the image, in pixels.  This option is useful
	 primarily in situations where you wish to build up the contents of
	 the image piece by piece.  A value of zero (the default) allows the
	 image to expand or shrink vertically to fit the data stored in it."

	<category: 'image management'>
	self tclEval: 'image height img' , self connected.
	^self tclResult asInteger
    ]

    imageWidth [
	"Specifies the width of the image, in pixels.  This option is useful
	 primarily in situations where you wish to build up the contents of
	 the image piece by piece.  A value of zero (the default) allows the
	 image to expand or shrink horizontally to fit the data stored in it."

	<category: 'image management'>
	self tclEval: 'image width img' , self connected.
	^self tclResult asInteger
    ]

    lineFrom: origin extent: extent color: color [
	"Draw a line with the given origin and extent, using
	 the given color."

	<category: 'image management'>
	self 
	    lineFrom: origin
	    to: origin + extent
	    color: color
    ]

    lineFrom: origin to: corner color: color [
	<category: 'image management'>
	self notYetImplemented
    ]

    lineFrom: origin toX: endX color: color [
	"Draw an horizontal line between the given corners, using
	 the given color."

	<category: 'image management'>
	self 
	    tclEval: 'img%1 put { %2 } -to %3 %4'
	    with: self connected
	    with: color
	    with: origin x printString , ' ' , origin y printString
	    with: endX printString , ' ' , origin y printString
    ]

    lineInside: rectangle color: color [
	"Draw a line having the given bounding box, using
	 the given color."

	<category: 'image management'>
	self 
	    lineFrom: rectangle origin
	    to: rectangle corner
	    color: color
    ]

    lineFrom: origin toY: endY color: color [
	"Draw a vertical line between the given corners, using
	 the given color."

	<category: 'image management'>
	self 
	    tclEval: 'img%1 put { %2 } -to %3 %4'
	    with: self connected
	    with: color
	    with: origin x printString , ' ' , origin y printString
	    with: origin x printString , ' ' , endY printString
    ]

    destroyed [
	"Private - The receiver has been destroyed, clear the corresponding
	 Tcl image to avoid memory leaks."

	<category: 'widget protocol'>
	'TODO' printNl.
	super destroyed
    ]

    create [
	<category: 'private'>
	self tclEval: 'image create photo img' , self connected.
	self create: '-anchor nw -image img' , self connected
    ]

    setInitialSize [
	"Make the Tk placer's status, the receiver's properties and the
	 window status (as returned by winfo) consistent. Occupy the
	 area indicated by the widget itself, at the top left corner"

	<category: 'private'>
	self x: 0 y: 0
    ]

    widgetType [
	<category: 'private'>
	^'label'
    ]
]



BViewport subclass: BList [
    | labels items callback gtkmodel connected gtkcolumn |
    
    <comment: 'I represent a list box from which you can choose one or more
elements.'>
    <category: 'Graphics-Windows'>

    add: anObject afterIndex: index [
	"Add an element with the given value after another element whose
	 index is contained in the index parameter.  The label displayed
	 in the widget is anObject's displayString.  Answer anObject."

	<category: 'accessing'>
	^self 
	    add: nil
	    element: anObject
	    afterIndex: index
    ]

    add: aString element: anObject afterIndex: index [
	"Add an element with the aString label after another element whose
	 index is contained in the index parameter.  This method allows
	 the client to decide autonomously the label that the widget will
	 display.
	 
	 If anObject is nil, then string is used as the element as well.
	 If aString is nil, then the element's displayString is used as
	 the label.
	 
	 Answer anObject or, if it is nil, aString."

	<category: 'accessing'>
	| elem label iter |
	label := aString isNil ifTrue: [anObject displayString] ifFalse: [aString].
	elem := anObject isNil ifTrue: [aString] ifFalse: [anObject].
	labels isNil 
	    ifTrue: 
		[index > 0 
		    ifTrue: [^SystemExceptions.IndexOutOfRange signalOn: self withIndex: index].
		labels := OrderedCollection with: label.
		items := OrderedCollection with: elem]
	    ifFalse: 
		[labels add: label afterIndex: index.
		items add: elem afterIndex: index].
	iter := self gtkmodel insert: index.
	self gtkmodel 
	    setOop: iter
	    column: 0
	    value: label.
	^elem
    ]

    addLast: anObject [
	"Add an element with the given value at the end of the listbox.
	 The label displayed in the widget is anObject's displayString.
	 Answer anObject."

	<category: 'accessing'>
	^self 
	    add: nil
	    element: anObject
	    afterIndex: items size
    ]

    addLast: aString element: anObject [
	"Add an element with the given value at the end of the listbox.
	 This method allows the client to decide autonomously the label
	 that the widget will display.
	 
	 If anObject is nil, then string is used as the element as well.
	 If aString is nil, then the element's displayString is used as
	 the label.
	 
	 Answer anObject or, if it is nil, aString."

	<category: 'accessing'>
	^self 
	    add: aString
	    element: anObject
	    afterIndex: items size
    ]

    associationAt: anIndex [
	"Answer an association whose key is the item at the given position
	 in the listbox and whose value is the label used to display that
	 item."

	<category: 'accessing'>
	^(items at: anIndex) -> (labels at: anIndex)
    ]

    at: anIndex [
	"Answer the element displayed at the given position in the list
	 box."

	<category: 'accessing'>
	^items at: anIndex
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

    contents: elementList [
	"Set the elements displayed in the listbox, and set the labels
	 to be their displayStrings."

	<category: 'accessing'>
	| newLabels |
	newLabels := elementList collect: [:each | each displayString].
	^self contents: newLabels elements: elementList
    ]

    contents: stringCollection elements: elementList [
	"Set the elements displayed in the listbox to be those in elementList,
	 and set the labels to be the corresponding elements in stringCollection.
	 The two collections must have the same size."

	<category: 'accessing'>
	| stream iter |
	(elementList notNil and: [elementList size ~= stringCollection size]) 
	    ifTrue: 
		[^self 
		    error: 'label collection must have the same size as element collection'].
	labels := stringCollection isNil 
		    ifTrue: 
			[elementList asOrderedCollection collect: [:each | each displayString]]
		    ifFalse: [stringCollection asOrderedCollection].
	items := elementList isNil 
		    ifTrue: [labels copy]
		    ifFalse: [elementList asOrderedCollection].
	self gtkmodel clear.
	iter := GTK.GtkTreeIter new.
	stringCollection do: 
		[:each | 
		self gtkmodel append: iter.
		self gtkmodel 
		    setOop: iter
		    column: 0
		    value: each]
    ]

    do: aBlock [
	"Iterate over each element of the listbox and pass it to aBlock."

	<category: 'accessing'>
	items do: aBlock
    ]

    elements [
	"Answer the collection of objects that represent the elements
	 displayed by the list box."

	<category: 'accessing'>
	^items copy
    ]

    elements: elementList [
	"Set the elements displayed in the listbox, and set the labels
	 to be their displayStrings."

	<category: 'accessing'>
	| newLabels |
	newLabels := elementList collect: [:each | each displayString].
	^self contents: newLabels elements: elementList
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

    highlightBackground [
	"Answer the value of the highlightBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected items
	 in the widget."

	<category: 'accessing'>
	self properties at: #selectbackground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -selectbackground'
	    with: self connected
	    with: self container.
	^self properties at: #selectbackground put: self tclResult
    ]

    highlightBackground: value [
	"Set the value of the highlightBackground option for the widget.
	 
	 Specifies the background color to use when displaying selected items
	 in the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -selectbackground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #selectbackground put: value
    ]

    highlightForeground [
	"Answer the value of the highlightForeground option for the widget.
	 
	 Specifies the foreground color to use when displaying selected items
	 in the widget."

	<category: 'accessing'>
	self properties at: #selectforeground ifPresent: [:value | ^value].
	self 
	    tclEval: '%1 cget -selectforeground'
	    with: self connected
	    with: self container.
	^self properties at: #selectforeground put: self tclResult
    ]

    highlightForeground: value [
	"Set the value of the highlightForeground option for the widget.
	 
	 Specifies the foreground color to use when displaying selected items
	 in the widget."

	<category: 'accessing'>
	self 
	    tclEval: '%1 configure -selectforeground %3'
	    with: self connected
	    with: self container
	    with: value asTkString.
	self properties at: #selectforeground put: value
    ]

    index [
	"Answer the value of the index option for the widget.
	 
	 Indicates the element that has the location cursor. This item will be
	 displayed in the highlightForeground color, and with the corresponding
	 background color."

	<category: 'accessing'>
	^self properties at: #index
	    ifAbsentPut: 
		[| iter |
		(iter := self connected getSelection getSelected) isNil 
		    ifTrue: [nil]
		    ifFalse: [(self gtkmodel getStringFromIter: iter) asInteger]]
    ]

    indexAt: point [
	"Answer the index of the element that covers the point in the
	 listbox window specified by x and y (in pixel coordinates).  If no
	 element covers that point, then the closest element to that point
	 is used."

	<category: 'accessing'>
	| pPath ok path index |
	pPath := GTK.GtkTreePath type ptrType gcNew.
	ok := self 
		    getPathAtPos: point x
		    y: point y
		    path: pPath
		    column: nil
		    cellX: nil
		    cellY: nil.
	path := pPath value.
	index := ok ifTrue: [path getIndices value] ifFalse: [self elements size].
	path free.
	^index
    ]

    isSelected: index [
	"Answer whether the element indicated by index is currently selected."

	<category: 'accessing'>
	| selected path |
	path := self pathAt: index.
	selected := self connected getSelection pathIsSelected: path.
	path free.
	^selected
    ]

    labelAt: anIndex [
	"Answer the label displayed at the given position in the list
	 box."

	<category: 'accessing'>
	^labels at: anIndex
    ]

    labels [
	"Answer the labels displayed by the list box."

	<category: 'accessing'>
	^labels copy
    ]

    labelsDo: aBlock [
	"Iterate over each listbox element's label and pass it to aBlock."

	<category: 'accessing'>
	labels do: aBlock
    ]

    mode [
	"Answer the value of the mode option for the widget.
	 
	 Specifies one of several styles for manipulating the selection. The value
	 of the option may be either single, browse, multiple, or extended.
	 
	 If the selection mode is single or browse, at most one element can be selected in
	 the listbox at once. Clicking button 1 on an unselected element selects it and
	 deselects any other selected item, while clicking on a selected element
	 has no effect. In browse mode it is also possible to drag the selection
	 with button 1. That is, moving the mouse while button 1 is pressed keeps
	 the item under the cursor selected.
	 
	 If the selection mode is multiple or extended, any number of elements may be
	 selected at once, including discontiguous ranges. In multiple mode, clicking button
	 1 on an element toggles its selection state without affecting any other elements.
	 In extended mode, pressing button 1 on an element selects it, deselects
	 everything else, and sets the anchor to the element under the mouse; dragging the
	 mouse with button 1 down extends the selection to include all the elements between
	 the anchor and the element under the mouse, inclusive.
	 
	 In extended mode, the selected range can be adjusted by pressing button 1
	 with the Shift key down: this modifies the selection to consist of the elements
	 between the anchor and the element under the mouse, inclusive. The
	 un-anchored end of this new selection can also be dragged with the button
	 down. Also in extended mode, pressing button 1 with the Control key down starts a
	 toggle operation: the anchor is set to the element under the mouse, and its
	 selection state is reversed. The selection state of other elements is not
	 changed. If the mouse is dragged with button 1 down, then the selection
	 state of all elements between the anchor and the element under the mouse is
	 set to match that of the anchor element; the selection state of all other
	 elements remains what it was before the toggle operation began.
	 
	 Most people will probably want to use browse mode for single selections and
	 extended mode for multiple selections; the other modes appear to be useful only in
	 special situations."

	<category: 'accessing'>
	| mode |
	^self properties at: #selectmode
	    ifAbsentPut: 
		[mode := self connected getSelection getMode.
		mode = GTK.Gtk gtkSelectionSingle 
		    ifTrue: [#single]
		    ifFalse: 
			[mode = GTK.Gtk gtkSelectionBrowse 
			    ifTrue: [#browse]
			    ifFalse: [mode = GTK.Gtk gtkSelectionExtended ifTrue: [#extended]]]]
    ]

    mode: value [
	"Set the value of the mode option for the widget.
	 
	 Specifies one of several styles for manipulating the selection. The value
	 of the option may be either single, browse, multiple, or extended.
	 
	 If the selection mode is single or browse, at most one element can be selected in
	 the listbox at once. Clicking button 1 on an unselected element selects it and
	 deselects any other selected item, while clicking on a selected element
	 has no effect. In browse mode it is also possible to drag the selection
	 with button 1. That is, moving the mouse while button 1 is pressed keeps
	 the item under the cursor selected.
	 
	 If the selection mode is multiple or extended, any number of elements may be
	 selected at once, including discontiguous ranges. In multiple mode, clicking button
	 1 on an element toggles its selection state without affecting any other elements.
	 In extended mode, pressing button 1 on an element selects it, deselects
	 everything else, and sets the anchor to the element under the mouse; dragging the
	 mouse with button 1 down extends the selection to include all the elements between
	 the anchor and the element under the mouse, inclusive.
	 
	 In extended mode, the selected range can be adjusted by pressing button 1
	 with the Shift key down: this modifies the selection to consist of the elements
	 between the anchor and the element under the mouse, inclusive. The
	 un-anchored end of this new selection can also be dragged with the button
	 down. Also in extended mode, pressing button 1 with the Control key down starts a
	 toggle operation: the anchor is set to the element under the mouse, and its
	 selection state is reversed. The selection state of other elements is not
	 changed. If the mouse is dragged with button 1 down, then the selection
	 state of all elements between the anchor and the element under the mouse is
	 set to match that of the anchor element; the selection state of all other
	 elements remains what it was before the toggle operation began.
	 
	 Most people will probably want to use browse mode for single selections and
	 extended mode for multiple selections; the other modes appear to be useful only in
	 special situations."

	<category: 'accessing'>
	| mode |
	value = #single 
	    ifTrue: [mode := GTK.Gtk gtkSelectionSingle]
	    ifFalse: 
		[value = #browse 
		    ifTrue: [mode := GTK.Gtk gtkSelectionBrowse]
		    ifFalse: 
			[value = #multiple 
			    ifTrue: [mode := GTK.Gtk gtkSelectionExtended]
			    ifFalse: 
				[value = #extended 
				    ifTrue: [mode := GTK.Gtk gtkSelectionExtended]
				    ifFalse: [^self error: 'invalid value for BList mode']]]].
	self connected getSelection setMode: mode.
	self properties at: #selectmode put: value
    ]

    numberOfStrings [
	"Answer the number of items in the list box"

	<category: 'accessing'>
	^labels size
    ]

    removeAtIndex: index [
	"Remove the item at the given index in the list box, answering
	 the object associated to the element (i.e. the value that #at:
	 would have returned for the given index)"

	<category: 'accessing'>
	| result |
	labels removeAtIndex: index.
	result := items removeAtIndex: index.
	self gtkmodel remove: (self iterAt: index).
	^result
    ]

    label [
	"assign a new label to the list"

	<category: 'accessing'>
	^self gtkcolumn getTitle
    ]

    label: aString [
	"assign a new label to the list"

	<category: 'accessing'>
	self gtkcolumn setTitle: aString
    ]

    size [
	"Answer the number of items in the list box"

	<category: 'accessing'>
	^labels size
    ]

    itemSelected: receiver at: index [
	<category: 'private - examples'>
	stdout
	    nextPutAll: 'List item ';
	    print: index;
	    nextPutAll: ' selected!';
	    nl.
	stdout
	    nextPutAll: 'Contents: ';
	    nextPutAll: (items at: index);
	    nl
    ]

    gtkcolumn [
	"answer the gtk column for the list"

	<category: 'private'>
	gtkcolumn isNil ifTrue: [self createWidget].
	^gtkcolumn
    ]

    gtkmodel [
	"answer the gtk list model"

	<category: 'private'>
	gtkmodel isNil ifTrue: [self createWidget].
	^gtkmodel
    ]

    onChanged: selection data: userData [
	<category: 'private'>
	| iter |
	(iter := selection getSelected) isNil 
	    ifFalse: [self invokeCallback: (self gtkmodel getStringFromIter: iter)]
    ]

    pathAt: anIndex [
	<category: 'private'>
	^GTK.GtkTreePath newFromIndices: anIndex - 1 varargs: #()
    ]

    iterAt: anIndex [
	<category: 'private'>
	^self gtkmodel iterNthChild: nil n: anIndex - 1
    ]

    create [
	<category: 'private'>
	| select renderer |
	renderer := GTK.GtkCellRendererText new.
	'phwoar... should not need the explicit calls, but something is bust in varargs passing' 
	    printNl.
	gtkcolumn := GTK.GtkTreeViewColumn new.
	gtkcolumn setTitle: 'List'.
	gtkcolumn packStart: renderer expand: true.
	gtkcolumn 
	    addAttribute: renderer
	    attribute: 'text'
	    column: 0.

	"gtkcolumn := GTK.GtkTreeViewColumn newWithAttributes: 'List' cell: renderer varargs: {'text'. 0. nil}."
	gtkmodel := GTK.GtkListStore new: 1 varargs: {GTK.GValue gTypeString}.
	self connected: (GTK.GtkTreeView newWithModel: self gtkmodel).
	(self connected)
	    appendColumn: self gtkcolumn;
	    setSearchColumn: 0.
	select := self connected getSelection.
	select setMode: GTK.Gtk gtkSelectionSingle.
	select 
	    connectSignal: 'changed'
	    to: self
	    selector: #onChanged:data:
	    userData: nil
    ]

    show [
	<category: 'private'>
	super show.
	self container setShadowType: GTK.Gtk gtkShadowIn
    ]

    needsViewport [
	<category: 'private'>
	^false
    ]

    initialize: parentWidget [
	<category: 'private'>
	super initialize: parentWidget.
	self properties at: #index put: nil.
	labels := OrderedCollection new
    ]

    invokeCallback: indexString [
	<category: 'private'>
	| index |
	items isNil ifTrue: [^self].
	index := indexString asInteger.
	self properties at: #index put: index + 1.
	self invokeCallback
    ]

    callback [
	"Answer a DirectedMessage that is sent when the active item in
	 the receiver changes, or nil if none has been set up."

	<category: 'widget protocol'>
	^callback
    ]

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a selector with at most two arguemtnts) when the active item in
	 the receiver changegs.  If the method accepts two arguments, the
	 receiver is  passed as the first parameter.  If the method accepts
	 one or two arguments, the selected index is passed as the last
	 parameter."

	<category: 'widget protocol'>
	| arguments selector numArgs |
	selector := aSymbol asSymbol.
	numArgs := selector numArgs.
	arguments := #().
	numArgs = 1 ifTrue: [arguments := {nil}].
	numArgs = 2 
	    ifTrue: 
		[arguments := 
			{self.
			nil}].
	callback := DirectedMessage 
		    selector: selector
		    arguments: arguments
		    receiver: aReceiver
    ]

    highlight: index [
	"Highlight the item at the given position in the listbox."

	<category: 'widget protocol'>
	index = self index ifTrue: [^self].
	(self mode = #single or: [self mode = #browse]) ifTrue: [self unhighlight].
	self select: index
    ]

    invokeCallback [
	"Generate a synthetic callback."

	<category: 'widget protocol'>
	self callback notNil 
	    ifTrue: 
		[self callback arguments isEmpty 
		    ifFalse: 
			[self callback arguments at: self callback arguments size
			    put: (self properties at: #index)].
		self callback send]
    ]

    select: index [
	"Highlight the item at the given position in the listbox,
	 without unhighlighting other items.  This is meant for
	 multiple- or extended-mode listboxes, but can be used
	 with other selection mode in particular cases."

	<category: 'widget protocol'>
	self properties at: #index put: index.
	self connected getSelection selectIter: (self iterAt: index)
    ]

    show: index [
	"Ensure that the item at the given position in the listbox is
	 visible."

	<category: 'widget protocol'>
	| path |
	path := self pathAt: index.
	self connected 
	    scrollToCell: path
	    column: self gtkcolumn
	    useAlign: false
	    rowAlign: 0.0e
	    colAlign: 0.0e.
	path free
    ]

    unhighlight [
	"Unhighlight all the items in the listbox."

	<category: 'widget protocol'>
	self connected getSelection unselectAll
    ]

    unselect: index [
	"Unhighlight the item at the given position in the listbox,
	 without affecting the state of the other items."

	<category: 'widget protocol'>
	self connected getSelection unselectIter: (self iterAt: index)
    ]
]



BForm subclass: BWindow [
    | isMapped callback x y width height container uiBox uiManager |
    
    <comment: 'I am the boss. Nothing else could be viewed or interacted with if
it wasn''t for me... )):->'>
    <category: 'Graphics-Windows'>

    TopLevel := nil.

    BWindow class >> initializeOnStartup [
	<category: 'private - initialization'>
	TopLevel := OrderedCollection new
    ]

    BWindow class >> new [
	"Answer a new top-level window."

	<category: 'instance creation'>
	^TopLevel add: (super new: nil)
    ]

    BWindow class >> new: label [
	"Answer a new top-level window with `label' as its title bar caption."

	<category: 'instance creation'>
	^self new label: label
    ]

    BWindow class >> popup: initializationBlock [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    callback [
	"Answer a DirectedMessage that is sent to verify whether the
	 receiver must be destroyed when the user asks to unmap it."

	<category: 'accessing'>
	^callback
    ]

    callback: aReceiver message: aSymbol [
	"Set up so that aReceiver is sent the aSymbol message (the name of
	 a zero- or one-argument selector) when the user asks to unmap the
	 receiver.  If the method accepts an argument, the receiver is passed.
	 
	 If the method returns true, the window and its children are
	 destroyed (which is the default action, taken if no callback is
	 set up).  If the method returns false, the window is left in
	 place."

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

    invokeCallback [
	"Generate a synthetic callback, destroying the window if no
	 callback was set up or if the callback method answers true."

	<category: 'accessing'>
	| result |
	result := self callback isNil or: [self callback send].
	result 
	    ifTrue: 
		[self destroy.
		isMapped := false].
	^result
    ]

    label [
	"Answer the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the
	 window."

	<category: 'accessing'>
	^self container getTitle
    ]

    label: value [
	"Set the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the
	 window."

	<category: 'accessing'>
	self container setTitle: value
    ]

    menu: aBMenuBar [
	"Set the value of the menu option for the widget.
	 
	 Specifies a menu widget to be used as a menubar."

	<category: 'accessing'>
	self uiBox 
	    packStart: aBMenuBar connected
	    expand: false
	    fill: false
	    padding: 0.
	self properties at: #menu put: aBMenuBar
    ]

    resizable [
	"Answer the value of the resizable option for the widget.
	 
	 Answer whether the user can be resize the window or not. If resizing is
	 disabled, then the window's size will be the size from the most recent
	 interactive resize or geometry-setting method. If there has been no such
	 operation then the window's natural size will be used."

	<category: 'accessing'>
	^self container getResizable
    ]

    resizable: value [
	"Set the value of the resizable option for the widget.
	 
	 Answer whether the user can be resize the window or not. If resizing is
	 disabled, then the window's size will be the size from the most recent
	 interactive resize or geometry-setting method. If there has been no such
	 operation then the window's natural size will be used."

	<category: 'accessing'>
	^self container setResizable: value
    ]

    uiBox [
	"answer the top level container for this window"

	<category: 'accessing'>
	^uiBox
    ]

    uiManager [
	<category: 'accessing'>
	uiManager isNil ifTrue: [uiManager := GTK.GtkUIManager new].
	^uiManager
    ]

    cacheWindowSize [
	"save the window position from gtk"

	<category: 'private'>
	| px py |
	px := CIntType gcNew.
	py := CIntType gcNew.
	self container getPosition: px rootY: py.
	x := px value.
	y := py value.
	self isMapped 
	    ifTrue: [self container getSize: px height: py]
	    ifFalse: [self container getDefaultSize: px height: py].
	width := px value.
	height := py value.
	self isMapped 
	    ifTrue: [self container setDefaultSize: width height: height]
    ]

    container [
	<category: 'private'>
	container isNil ifTrue: [self error: 'GTK object not created yet'].
	^container
    ]

    container: aWidget [
	<category: 'private'>
	container := aWidget
    ]

    initialize: parentWidget [
	<category: 'private'>
	super initialize: nil.
	self isMapped: false.
	self createWidget
    ]

    create [
	<category: 'private'>
	self container: (GTK.GtkWindow new: GTK.Gtk gtkWindowToplevel).
	self container 
	    connectSignal: 'delete-event'
	    to: self
	    selector: #onDelete:data:
	    userData: nil.
	self container 
	    connectSignal: 'configure-event'
	    to: self
	    selector: #onConfigure:data:
	    userData: nil.
	uiBox := GTK.GtkVBox new: false spacing: 0.
	self container add: uiBox.

	"Create the GtkPlacer"
	super create.
	uiBox 
	    packEnd: self connected
	    expand: true
	    fill: true
	    padding: 0
    ]

    show [
	"Do not show the GtkWindow until it is mapped!"

	<category: 'private'>
	super show.
	uiBox show
    ]

    onConfigure: object data: data [
	<category: 'private'>
	self cacheWindowSize
    ]

    onDelete: object data: data [
	<category: 'private'>
	^self callback notNil and: [self callback send not]
    ]

    destroyed [
	"Private - The receiver has been destroyed, remove it from the
	 list of toplevel windows to avoid memory leaks."

	<category: 'private'>
	super destroyed.
	TopLevel remove: self ifAbsent: [].
	(TopLevel isEmpty and: [DoDispatchEvents = 1]) 
	    ifTrue: [Blox terminateMainLoop]
    ]

    isMapped: aBoolean [
	<category: 'private'>
	isMapped := aBoolean
    ]

    resetGeometry: xPos y: yPos width: xSize height: ySize [
	<category: 'private'>
	(x = xPos and: [y = yPos and: [width = xSize and: [height = ySize]]]) 
	    ifTrue: [^self].
	self isMapped 
	    ifFalse: [self container setDefaultSize: xSize height: ySize]
	    ifTrue: [self container resize: xSize height: ySize].
	x := xPos.
	y := yPos.
	width := xSize.
	height := ySize
	"mapped ifTrue: [ self map ]."
    ]

    resized [
	<category: 'private'>
	self isMapped ifFalse: [^self].
	x := y := width := height := nil
    ]

    setInitialSize [
	<category: 'private'>
	self 
	    x: 0
	    y: 0
	    width: 300
	    height: 300
    ]

    center [
	"Center the window in the screen"

	<category: 'widget protocol'>
	| screenSize |
	screenSize := Blox screenSize.
	self x: screenSize x // 2 - (self width // 2)
	    y: screenSize y // 2 - (self height // 2)
    ]

    centerIn: view [
	"Center the window in the given widget"

	<category: 'widget protocol'>
	self x: view x + (view width // 2) - (self parent width // 2)
	    y: view x + (view height // 2) - (self parent height // 2)
    ]

    height [
	"Answer the height of the window, as deduced from the geometry
	 that the window manager imposed on the window."

	<category: 'widget protocol'>
	height isNil ifTrue: [self cacheWindowSize].
	^height
    ]

    height: anInteger [
	"Ask the window manager to give the given height to the window."

	<category: 'widget protocol'>
	width isNil ifTrue: [self cacheWindowSize].
	self 
	    resetGeometry: x
	    y: y
	    width: width
	    height: anInteger
    ]

    heightAbsolute [
	"Answer the height of the window, as deduced from the geometry
	 that the window manager imposed on the window."

	<category: 'widget protocol'>
	height isNil ifTrue: [self cacheWindowSize].
	^height
    ]

    heightOffset: value [
	<category: 'widget protocol'>
	self shouldNotImplement
    ]

    iconify [
	"Map a window and in iconified state.  If a window has not been
	 mapped yet, this is achieved by mapping the window in withdrawn
	 state first, and then iconifying it."

	<category: 'widget protocol'>
	self container iconify.
	self isMapped: false
    ]

    isMapped [
	"Answer whether the window is mapped"

	<category: 'widget protocol'>
	isMapped isNil ifTrue: [isMapped := false].
	^isMapped
    ]

    isWindow [
	<category: 'widget protocol'>
	^true
    ]

    map [
	"Map the window and bring it to the topmost position in the Z-order."

	<category: 'widget protocol'>
	self container present.
	self isMapped: true
    ]

    modalMap [
	"Map the window while establishing an application-local grab for it.
	 An event loop is started that ends only after the window has been
	 destroyed."

	<category: 'widget protocol'>
	self container setModal: true.
	self map.
	Blox dispatchEvents: self.
	self container setModal: false
    ]

    state [
	"Set the value of the state option for the window.
	 
	 Specifies one of four states for the window: either normal, iconic,
	 withdrawn, or (Windows only) zoomed."

	<category: 'widget protocol'>
	self tclEval: 'wm state ' , self connected.
	^self tclResult asSymbol
    ]

    state: aSymbol [
	"Raise an error. To set a BWindow's state, use #map and #unmap."

	<category: 'widget protocol'>
	self error: 'To set a BWindow''s state, use #map and #unmap.'
    ]

    unmap [
	"Unmap a window, causing it to be forgotten about by the window manager"

	<category: 'widget protocol'>
	self isMapped ifFalse: [^self].
	self hide.
	self isMapped: false
    ]

    width [
	"Answer the width of the window, as deduced from the geometry
	 that the window manager imposed on the window."

	<category: 'widget protocol'>
	width isNil ifTrue: [self cacheWindowSize].
	^width
    ]

    width: anInteger [
	"Ask the window manager to give the given width to the window."

	<category: 'widget protocol'>
	height isNil ifTrue: [self cacheWindowSize].
	self 
	    resetGeometry: x
	    y: y
	    width: anInteger
	    height: height
    ]

    width: xSize height: ySize [
	"Ask the window manager to give the given width and height to
	 the window."

	<category: 'widget protocol'>
	self 
	    resetGeometry: x
	    y: y
	    width: xSize
	    height: ySize
    ]

    widthAbsolute [
	"Answer the width of the window, as deduced from the geometry
	 that the window manager imposed on the window."

	<category: 'widget protocol'>
	width isNil ifTrue: [self cacheWindowSize].
	^width
    ]

    widthOffset: value [
	<category: 'widget protocol'>
	self shouldNotImplement
    ]

    window [
	<category: 'widget protocol'>
	^self
    ]

    x [
	"Answer the x coordinate of the window's top-left corner, as
	 deduced from the geometry that the window manager imposed on
	 the window."

	<category: 'widget protocol'>
	x isNil ifTrue: [self cacheWindowSize].
	^x
    ]

    x: anInteger [
	"Ask the window manager to move the window's left border
	 to the given x coordinate, keeping the size unchanged"

	<category: 'widget protocol'>
	y isNil ifTrue: [self cacheWindowSize].
	self 
	    resetGeometry: anInteger
	    y: y
	    width: width
	    height: height
    ]

    x: xPos y: yPos [
	"Ask the window manager to move the window's top-left corner
	 to the given coordinates, keeping the size unchanged"

	<category: 'widget protocol'>
	self 
	    resetGeometry: xPos
	    y: yPos
	    width: width
	    height: height
    ]

    x: xPos y: yPos width: xSize height: ySize [
	"Ask the window manager to give the requested geometry
	 to the window."

	"XXX gtk deprecates this sort of thing"

	

	<category: 'widget protocol'>
	self 
	    resetGeometry: xPos
	    y: yPos
	    width: xSize
	    height: ySize
    ]

    xAbsolute [
	"Answer the x coordinate of the window's top-left corner, as
	 deduced from the geometry that the window manager imposed on
	 the window."

	<category: 'widget protocol'>
	x isNil ifTrue: [self cacheWindowSize].
	^x
    ]

    xOffset: value [
	<category: 'widget protocol'>
	self shouldNotImplement
    ]

    y [
	"Answer the y coordinate of the window's top-left corner, as
	 deduced from the geometry that the window manager imposed on
	 the window."

	<category: 'widget protocol'>
	y isNil ifTrue: [self cacheWindowSize].
	^y
    ]

    y: anInteger [
	"Ask the window manager to move the window's left border
	 to the given y coordinate, keeping the size unchanged"

	<category: 'widget protocol'>
	x isNil ifTrue: [self cacheWindowSize].
	self 
	    resetGeometry: x
	    y: anInteger
	    width: width
	    height: height
    ]

    yAbsolute [
	"Answer the y coordinate of the window's top-left corner, as
	 deduced from the geometry that the window manager imposed on
	 the window."

	<category: 'widget protocol'>
	y isNil ifTrue: [self cacheWindowSize].
	^y
    ]

    yOffset: value [
	<category: 'widget protocol'>
	self shouldNotImplement
    ]
]



BWindow subclass: BTransientWindow [
    
    <comment: 'I am almost a boss. I represent a window which is logically linked
to another which sits higher in the widget hierarchy, e.g. a dialog
box'>
    <category: 'Graphics-Windows'>

    BTransientWindow class >> new [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    BTransientWindow class >> new: parentWindow [
	"Answer a new transient window attached to the given
	 parent window and with nothing in its title bar caption."

	<category: 'instance creation'>
	^(self basicNew)
	    initialize: parentWindow;
	    yourself
    ]

    BTransientWindow class >> new: label in: parentWindow [
	"Answer a new transient window attached to the given
	 parent window and with `label' as its title bar caption."

	<category: 'instance creation'>
	^(self basicNew)
	    initialize: parentWindow;
	    label: label;
	    yourself
    ]

    map [
	"Map the window and inform the windows manager that the
	 receiver is a transient window working on behalf of its
	 parent.  The window is also put in its parent window's
	 window group: the window manager might use this information,
	 for example, to unmap all of the windows in a group when the
	 group's leader is iconified."

	<category: 'widget protocol'>
	self parent isNil 
	    ifFalse: [self container setTransientFor: self parent container].
	super map
    ]
]



BWindow subclass: BPopupWindow [
    
    <comment: 'I am a pseudo-window that has no decorations and no ability to interact
with the user.  My main usage, as my name says, is to provide pop-up
functionality for other widgets.  Actually there should be no need to
directly use me - always rely on the #new and #popup: class methods.'>
    <category: 'Graphics-Windows'>

    addChild: w [
	"Private - The widget identified by child has been added to the
	 receiver.  This method is public not because you can call it,
	 but because it can be useful to override it to perform some
	 initialization on the children just added. Answer the new child."

	<category: 'geometry management'>
	self uiBox 
	    packEnd: w
	    expand: true
	    fill: true
	    padding: 1.
	w onDestroySend: #destroy to: self
    ]

    child: child height: value [
	"Set the given child's height.  This is done by setting
	 its parent window's (that is, our) height."

	"Only act after #addChild:"

	<category: 'geometry management'>
	self childrenCount = 0 ifTrue: [^self].
	self height: value
    ]

    child: child heightOffset: value [
	<category: 'geometry management'>
	self shouldNotImplement
    ]

    child: child width: value [
	"Set the given child's width.  This is done by setting
	 its parent window's (that is, our) width."

	"Only act after #addChild:"

	<category: 'geometry management'>
	self childrenCount = 0 ifTrue: [^self].
	self width: value
    ]

    child: child widthOffset: value [
	<category: 'geometry management'>
	self shouldNotImplement
    ]

    child: child x: value [
	"Set the x coordinate of the given child's top-left corner.
	 This is done by setting its parent window's (that is, our) x."

	<category: 'geometry management'>
	self x: value
    ]

    child: child xOffset: value [
	<category: 'geometry management'>
	self shouldNotImplement
    ]

    child: child y: value [
	"Set the y coordinate of the given child's top-left corner.
	 This is done by setting its parent window's (that is, our) y."

	<category: 'geometry management'>
	self y: value
    ]

    child: child yOffset: value [
	<category: 'geometry management'>
	self shouldNotImplement
    ]

    heightChild: child [
	"Answer the given child's height, which is the height that
	 was imposed on the popup window."

	<category: 'geometry management'>
	^self height
    ]

    widthChild: child [
	"Answer the given child's width in pixels, which is the width that
	 was imposed on the popup window."

	<category: 'geometry management'>
	^self width
    ]

    xChild: child [
	"Answer the x coordinate of the given child's top-left corner,
	 which is desumed by the position of the popup window."

	<category: 'geometry management'>
	^self x
    ]

    yChild: child [
	"Answer the y coordinate of the given child's top-left corner,
	 which is desumed by the position of the popup window."

	<category: 'geometry management'>
	^self y
    ]

    create [
	<category: 'private'>
	super create.
	self container setDecorated: false.
	self container setResizable: false
    ]

    setInitialSize [
	<category: 'private'>
	self cacheWindowSize
    ]
]



BForm subclass: BDialog [
    | callbacks initInfo buttonBox entry |
    
    <comment: 'I am a facility for implementing dialogs with many possible choices
and requests. In addition I provide support for a few platform native
common dialog boxes, such as choose-a-file and choose-a-color.'>
    <category: 'Graphics-Windows'>

    BDialog class >> new: parent [
	"Answer a new dialog handler (containing a label widget and
	 some button widgets) laid out within the given parent window.
	 The label widget, when it is created, is empty."

	<category: 'instance creation'>
	^(self basicNew)
	    initInfo: '' -> nil;
	    initialize: parent
    ]

    BDialog class >> new: parent label: aLabel [
	"Answer a new dialog handler (containing a label widget and
	 some button widgets) laid out within the given parent window.
	 The label widget, when it is created, contains aLabel."

	<category: 'instance creation'>
	^(self basicNew)
	    initInfo: aLabel -> nil;
	    initialize: parent
    ]

    BDialog class >> new: parent label: aLabel prompt: aString [
	"Answer a new dialog handler (containing a label widget, some
	 button widgets, and an edit window showing aString by default)
	 laid out within the given parent window.
	 The label widget, when it is created, contains aLabel."

	<category: 'instance creation'>
	^(self basicNew)
	    initInfo: aLabel -> aString;
	    initialize: parent
    ]

    BDialog class >> chooseFile: operation parent: parent label: aLabel default: name defaultExtension: ext types: typeList action: action button: button [
	<category: 'private'>
	| dialog result filename |
	'FIXME: implement the default, defaultExtension and typesList portions' 
	    printNl.
	parent map.
	dialog := GTK.GtkFileChooserDialog 
		    new: aLabel
		    parent: parent container
		    action: action
		    varargs: 
			{GTK.Gtk gtkStockCancel.
			GTK.Gtk gtkResponseCancel.
			button.
			GTK.Gtk gtkResponseAccept.
			nil}.
	result := dialog run.
	^result = GTK.Gtk gtkResponseAccept 
	    ifFalse: 
		[dialog destroy.
		nil]
	    ifTrue: 
		[filename := dialog getFilename.
		filename isEmpty ifTrue: [filename := nil].
		dialog destroy.
		filename]
    ]

    BDialog class >> chooseColor: parent label: aLabel default: color [
	"Prompt for a color.  The dialog box is created with the given
	 parent window and with aLabel as its title bar text, and initially
	 it selects the color given in the color parameter.
	 
	 If the dialog box is canceled, nil is answered, else the
	 selected color is returned as a String with its RGB value."

	<category: 'prompters'>
	| result |
	parent map.
	self 
	    tclEval: 'tk_chooseColor -parent %1 -title %2 -initialcolor %3'
	    with: parent container
	    with: aLabel asTkString
	    with: color asTkString.
	result := self tclResult.
	result isEmpty ifTrue: [result := nil].
	^result
    ]

    BDialog class >> chooseFileToOpen: parent label: aLabel default: name defaultExtension: ext types: typeList [
	"Pop up a dialog box for the user to select a file to open.
	 Its purpose is for the user to select an existing file only.
	 If the user enters an non-existent file, the dialog box gives
	 the user an error prompt and requires the user to give an
	 alternative selection or to cancel the selection. If an
	 application allows the user to create new files, it should
	 do so by providing a separate New menu command.
	 
	 If the dialog box is canceled, nil is answered, else the
	 selected file name is returned as a String.
	 
	 The dialog box is created with the given parent window
	 and with aLabel as its title bar text.  The name parameter
	 indicates which file is initially selected, and the default
	 extension specifies  a string that will be appended to the
	 filename if the user enters a filename without an extension.
	 
	 The typeList parameter is an array of arrays, like
	 #(('Text files' '.txt' '.diz') ('Smalltalk files' '.st')),
	 and is used to construct a listbox of file types.  When the user
	 chooses a file type in the listbox, only the files of that type
	 are listed.  Each item in the array contains a list of strings:
	 the first one is the name of the file type described by a particular
	 file pattern, and is the text string that appears in the File types
	 listbox, while the other ones are the possible extensions that
	 belong to this particular file type."

	"e.g.
	 fileName := BDialog
	 chooseFileToOpen: aWindow
	 label: 'Open file'
	 default: nil
	 defaultExtension: 'gif'
	 types: #(
	 ('Text files'       '.txt' '.diz')
	 ('Smalltalk files'  '.st')
	 ('C source files'   '.c')
	 ('GIF files'	'.gif'))"

	<category: 'prompters'>
	^self 
	    chooseFile: 'Open'
	    parent: parent
	    label: aLabel
	    default: name
	    defaultExtension: ext
	    types: typeList
	    action: GTK.Gtk gtkFileChooserActionOpen
	    button: GTK.Gtk gtkStockOpen
    ]

    BDialog class >> chooseFileToSave: parent label: aLabel default: name defaultExtension: ext types: typeList [
	"Pop up a dialog box for the user to select a file to save;
	 this differs from the file open dialog box in that non-existent
	 file names are accepted and existing file names trigger a
	 confirmation dialog box, asking the user whether the file
	 should be overwritten or not.
	 
	 If the dialog box is canceled, nil is answered, else the
	 selected file name is returned as a String.
	 
	 The dialog box is created with the given parent window
	 and with aLabel as its title bar text.  The name parameter
	 indicates which file is initially selected, and the default
	 extension specifies  a string that will be appended to the
	 filename if the user enters a filename without an extension.
	 
	 The typeList parameter is an array of arrays, like
	 #(('Text files' '.txt' '.diz') ('Smalltalk files' '.st')),
	 and is used to construct a listbox of file types.  When the user
	 chooses a file type in the listbox, only the files of that type
	 are listed.  Each item in the array contains a list of strings:
	 the first one is the name of the file type described by a particular
	 file pattern, and is the text string that appears in the File types
	 listbox, while the other ones are the possible extensions that
	 belong to this particular file type."

	<category: 'prompters'>
	^self 
	    chooseFile: 'Save'
	    parent: parent
	    label: aLabel
	    default: name
	    defaultExtension: ext
	    types: typeList
	    action: GTK.Gtk gtkFileChooserActionSave
	    button: GTK.Gtk gtkStockSave
    ]

    addButton: aLabel receiver: anObject index: anInt [
	"Add a button to the dialog box that, when clicked, will
	 cause the #dispatch: method to be triggered in anObject,
	 passing anInt as the argument of the callback.  The
	 caption of the button is set to aLabel."

	<category: 'accessing'>
	^self 
	    addButton: aLabel
	    receiver: anObject
	    message: #dispatch:
	    argument: anInt
    ]

    addButton: aLabel receiver: anObject message: aSymbol [
	"Add a button to the dialog box that, when clicked, will
	 cause the aSymbol unary selector to be sent to anObject.
	 The caption of the button is set to aLabel."

	<category: 'accessing'>
	callbacks addLast: (DirectedMessage 
		    selector: aSymbol
		    arguments: #()
		    receiver: anObject).
	self addButton: aLabel
    ]

    addButton: aLabel receiver: anObject message: aSymbol argument: arg [
	"Add a button to the dialog box that, when clicked, will
	 cause the aSymbol one-argument selector to be sent to anObject,
	 passing arg as the argument of the callback.  The
	 caption of the button is set to aLabel."

	<category: 'accessing'>
	callbacks addLast: (DirectedMessage 
		    selector: aSymbol
		    arguments: {arg}
		    receiver: anObject).
	self addButton: aLabel
    ]

    contents: newText [
	"Display newText in the entry widget associated to the dialog box."

	<category: 'accessing'>
	entry setText: newText
    ]

    contents [
	"Answer the text that is displayed in the entry widget associated
	 to the dialog box."

	<category: 'accessing'>
	^entry getText
    ]

    addButton: aLabel [
	<category: 'private'>
	| button |
	self buttonBox add: (button := GTK.GtkButton newWithLabel: aLabel).
	button show.
	button 
	    connectSignal: 'clicked'
	    to: self
	    selector: #clicked:data:
	    userData: callbacks size
    ]

    clicked: button data: data [
	<category: 'private'>
	self invokeCallback: data.
	self toplevel destroy
    ]

    buttonBox [
	<category: 'private'>
	buttonBox isNil ifTrue: [self create].
	^buttonBox
    ]

    create [
	"We do not use BDialog.  Instead, we work in the toplevel's
	 uiBox, because Blox makes the BDialog live into a BWindow
	 that provides space for other widgets."

	<category: 'private'>
	| uiBox label separator |
	super create.
	uiBox := self toplevel uiBox.
	buttonBox := GTK.GtkHButtonBox new.
	buttonBox setSpacing: 5.
	buttonBox setLayout: GTK.Gtk gtkButtonboxEnd.
	uiBox 
	    packEnd: buttonBox
	    expand: false
	    fill: false
	    padding: 5.
	buttonBox show.
	separator := GTK.GtkHSeparator new.
	uiBox 
	    packEnd: separator
	    expand: false
	    fill: false
	    padding: 0.
	separator show.

	"Put the GtkPlacer at the end of the list of the end-packed widgets,
	 which puts it above our GtkHSeparator and GtkHButtonBox."
	uiBox reorderChild: self toplevel connected position: -1.
	initInfo isNil ifTrue: [^self].
	label := GTK.GtkLabel new: initInfo key.
	label setAlignment: 0 yalign: 0.
	uiBox 
	    packStart: label
	    expand: false
	    fill: false
	    padding: 5.
	label show.
	initInfo value isNil ifTrue: [^self].
	entry := GTK.GtkEntry new.
	entry setText: initInfo value.
	uiBox 
	    packStart: entry
	    expand: false
	    fill: false
	    padding: 0.
	entry show
    ]

    initInfo: assoc [
	<category: 'private'>
	initInfo := assoc
    ]

    initialize: parentWidget [
	<category: 'private'>
	super initialize: parentWidget.
	callbacks := OrderedCollection new
    ]

    center [
	"Center the dialog box's parent window in the screen"

	<category: 'widget protocol'>
	self parent center
    ]

    centerIn: view [
	"Center the dialog box's parent window in the given widget"

	<category: 'widget protocol'>
	self parent centerIn: view
    ]

    invokeCallback: index [
	"Generate a synthetic callback corresponding to the index-th
	 button being pressed, and destroy the parent window (triggering
	 its callback if one was established)."

	<category: 'widget protocol'>
	(callbacks at: index asInteger) send
	"self parent destroy"
    ]

    loop [
	"Map the parent window modally.  In other words, an event loop
	 is started that ends only after the window has been destroyed.
	 For more information on the treatment of events for modal windows,
	 refer to BWindow>>#modalMap."

	<category: 'widget protocol'>
	self toplevel container showAll.
	self toplevel modalMap
    ]
]



BMenuObject subclass: BMenuBar [
    | actionGroup uiManager |
    
    <comment: 'I am the Menu Bar, the top widget in a full menu structure.'>
    <category: 'Graphics-Windows'>

    add: aMenu [
	"Add aMenu to the menu bar"

	<category: 'accessing'>
	aMenu create.
	^aMenu
    ]

    remove: aMenu [
	"Remove aMenu from the menu bar"

	<category: 'accessing'>
	self 
	    tclEval: 'catch { %1 delete %2 }'
	    with: self connected
	    with: aMenu connected
    ]

    uiManager [
	<category: 'private'>
	uiManager isNil ifTrue: [self create].
	^uiManager
    ]

    create [
	<category: 'private'>
	uiManager := self parent isNil 
		    ifTrue: [GTK.GtkUIManager new]
		    ifFalse: [self toplevel uiManager].
	self uiManager 
	    addUi: self uiManager newMergeId
	    path: '/'
	    name: self name
	    action: self name
	    type: GTK.Gtk gtkUiManagerMenubar
	    top: false.
	self parent isNil ifFalse: [self parent menu: self].
	actionGroup := GTK.GtkActionGroup new: 'MenuActions'.
	self uiManager insertActionGroup: actionGroup pos: 0
    ]

    exists [
	<category: 'private'>
	^uiManager notNil
    ]

    name [
	"answer the name"

	<category: 'private'>
	^'MainMenu'
    ]

    path [
	"answer the menu path"

	<category: 'private'>
	^'/MainMenu'
    ]

    actionGroup [
	"answer an actiongroup that menu entries should go in"

	<category: 'private'>
	actionGroup isNil ifTrue: [self create].
	^actionGroup
    ]
]



BMenuObject subclass: BMenu [
    | connected label |
    
    <comment: 'I am a Menu that is part of a menu bar.'>
    <category: 'Graphics-Windows'>

    BMenu class >> new: parent label: label [
	"Add a new menu to the parent window's menu bar, with `label' as
	 its caption (for popup menus, parent is the widget over which the
	 menu pops up as the right button is pressed)."

	<category: 'instance creation'>
	^(self basicNew)
	    initialize: parent;
	    label: label;
	    yourself
    ]

    label [
	"Answer the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the window."

	<category: 'accessing'>
	^label
    ]

    label: value [
	"Set the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the window."

	"TODO: save the merge id we used, remove the ui, and re-add the ui with the new label"

	<category: 'accessing'>
	label := value
    ]

    addLine [
	"Add a separator item at the end of the menu"

	<category: 'callback registration'>
	^self addMenuItemFor: #() notifying: self	"self is dummy"
    ]

    addMenuItemFor: anArray notifying: receiver [
	"Add a menu item described by anArray at the end of the menu.
	 If anArray is empty, insert a separator line.  If anArray
	 has a single item, a menu item is created without a callback.
	 If anArray has two or three items, the second one is used as
	 the selector sent to receiver, and the third one (if present)
	 is passed to the selector."

	"Receiver will be sent the callback messages.  anArray
	 is something that responds to at: and size.  Possible types are:
	 #()		insert a seperator line
	 #(name)	        create a menu item with name, but no callback
	 #(name symbol)     create a menu item with the given name and
	 no parameter callback.
	 #(name symbol arg) create a menu item with the given name and
	 one parameter callback."

	<category: 'callback registration'>
	| item |
	item := self newMenuItemFor: anArray notifying: receiver.
	self exists ifFalse: [self create].
	item create
    ]

    callback: receiver using: selectorPairs [
	"Add menu items described by anArray at the end of the menu.
	 Each element of selectorPairs must be in the format described
	 in BMenu>>#addMenuItemFor:notifying:.  All the callbacks will
	 be sent to receiver."

	<category: 'callback registration'>
	selectorPairs do: [:pair | self addMenuItemFor: pair notifying: receiver]
    ]

    empty [
	"Empty the menu widget; that is, remove all the children"

	<category: 'callback registration'>
	self tclEval: self connected , ' delete 0 end'.
	children := OrderedCollection new.
	childrensUnderline := nil
    ]

    destroy [
	"Destroy the menu widget; that is, simply remove ourselves from
	 the parent menu bar."

	<category: 'callback registration'>
	self parent remove: self
    ]

    addChild: menuItem [
	<category: 'private'>
	self exists ifFalse: [self create].
	menuItem create.
	^menuItem
    ]

    actionGroup [
	"answer the menu action group"

	<category: 'private'>
	^self parent actionGroup
    ]

    name [
	"answer the name the menu should get"

	<category: 'private'>
	^self label , 'Menu'
    ]

    menuLabel [
	"answer the label the menu should get"

	<category: 'private'>
	^'_' , self label
    ]

    path [
	"answer the path for the menu"

	<category: 'private'>
	^self parent path , '/' , self name
    ]

    uiManager [
	"answer the ui manager"

	<category: 'private'>
	^self parent uiManager
    ]

    connected [
	<category: 'private'>
	connected isNil ifTrue: [connected := self uiManager getWidget: self path].
	^connected
    ]

    create [
	<category: 'private'>
	| s menu u |
	self actionGroup addAction: (GTK.GtkAction 
		    new: self name
		    label: self menuLabel
		    tooltip: nil
		    stockId: nil).
	self uiManager 
	    addUi: self uiManager newMergeId
	    path: self parent path
	    name: self name
	    action: self name
	    type: GTK.Gtk gtkUiManagerMenu
	    top: false.
	self childrenDo: [:each | each create]
    ]

    onDestroy: object data: data [
	<category: 'private'>
	self destroyed
    ]

    exists [
	<category: 'private'>
	^self connected notNil
    ]

    initialize: parentWidget [
	<category: 'private'>
	super initialize: parentWidget.
	label := ''
    ]

    newMenuItemFor: pair notifying: receiver [
	<category: 'private'>
	| item size |
	size := pair size.
	pair size = 0 ifTrue: [^BMenuItem new: self].
	(size >= 2 and: [pair last isArray]) 
	    ifTrue: 
		[size := size - 1.
		item := BMenu new: self label: (pair at: 1).
		pair last 
		    do: [:each | item add: (item newMenuItemFor: each notifying: receiver)]]
	    ifFalse: [item := BMenuItem new: self label: (pair at: 1)].
	size = 1 ifTrue: [^item].
	size = 2 ifTrue: [^item callback: receiver message: (pair at: 2)].
	^item 
	    callback: receiver
	    message: (pair at: 2)
	    argument: (pair at: 3)
    ]
]



BMenu subclass: BPopupMenu [
    | attachedWidget |
    
    <comment: 'I am a class that provides the ability to show popup menus when the
right button (Button 3) is clicked on another window.'>
    <category: 'Graphics-Windows'>

    PopupMenuBar := nil.
    PopupMenus := nil.

    BPopupMenu class >> initializeOnStartup [
	<category: 'private - accessing'>
	PopupMenuBar := nil.
	PopupMenus := WeakKeyIdentityDictionary new
    ]

    BPopupMenu class >> popupMenuBar [
	"answer the menubar this menu conceptually exists in"

	<category: 'private - accessing'>
	PopupMenuBar isNil ifTrue: [PopupMenuBar := BMenuBar new: nil].
	^PopupMenuBar
    ]

    initialize: parentWindow [
	"TODO: refactor so that 'self parent' is parentWindow.  Start by
	 writing (and using!) a menuBar method in BMenu and overriding it here."

	<category: 'private'>
	self class popupMenuBar exists ifFalse: [self class popupMenuBar create].
	super initialize: self class popupMenuBar.
	attachedWidget := parentWindow.
	PopupMenus at: parentWindow ifPresent: [:menu | menu destroy].
	PopupMenus at: attachedWidget put: self
    ]

    create [
	<category: 'private'>
	super create.
	attachedWidget connected 
	    connectSignal: 'button-press-event'
	    to: self
	    selector: #onPopup:event:data:
	    userData: nil
    ]

    destroyed [
	<category: 'private'>
	super destroyed.
	attachedWidget := nil
    ]

    onPopup: widget event: event data: data [
	<category: 'private'>
	| buttonEv |
	buttonEv := event castTo: GTK.GdkEventButton type.
	buttonEv button value = 3 ifFalse: [^false].
	self connected getSubmenu 
	    popup: nil
	    parentMenuItem: nil
	    func: nil
	    data: nil
	    button: 3
	    activateTime: buttonEv time value.
	^true
    ]

    popup [
	"Generate a synthetic menu popup event"

	<category: 'widget protocol'>
	self connected getSubmenu 
	    popup: attachedWidget connected
	    parentMenuItem: nil
	    func: nil
	    data: nil
	    button: 0
	    activateTime: GTK.Gtk getCurrentEventTime
    ]
]



BMenuObject subclass: BMenuItem [
    | index |
    
    <comment: 'I am the tiny and humble Menu Item, a single command choice in the
menu structure. But if it wasn''t for me, nothing could be done...
eh eh eh!!'>
    <category: 'Graphics-Windows'>

    BMenuItem class >> new: parent [
	"Add a new separator item to the specified menu."

	<category: 'instance creation'>
	^self basicNew initialize: parent
    ]

    BMenuItem class >> new: parent label: label [
	"Add a new menu item to the specified menu (parent) , with `label'
	 as its caption."

	<category: 'instance creation'>
	^self basicNew initialize: parent label: label
    ]

    label [
	"Answer the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the window."

	<category: 'accessing'>
	^self properties at: #label
    ]

    label: value [
	"Set the value of the label option for the widget.
	 
	 Specifies a string to be displayed inside the widget. The way in which the
	 string is displayed depends on the particular widget and may be determined
	 by other options, such as anchor. For windows, this is the title of the window."

	<category: 'accessing'>
	(self properties at: #label) isNil 
	    ifTrue: [^self error: 'no label for separator lines'].
	self parent exists 
	    ifTrue: 
		[self 
		    tclEval: self container , ' entryconfigure ' , self connected , ' -label ' 
			    , value asTkString].
	self properties at: #label put: value
    ]

    actionGroup [
	"answer the menu action group"

	<category: 'private'>
	^self parent actionGroup
    ]

    uiManager [
	<category: 'private'>
	^self parent uiManager
    ]

    name [
	"answer the name of the item"

	<category: 'private'>
	^self label
    ]

    menuLabel [
	"answer the gtk label"

	<category: 'private'>
	^'_' , self name
    ]

    path [
	"answer the gtk uiManager path"

	<category: 'private'>
	^self parent path , '/' , self name
    ]

    create [
	<category: 'private'>
	| s u mergeid action |
	self name isNil 
	    ifTrue: 
		[mergeid := self uiManager newMergeId.
		self properties at: #label put: 'separator' , (mergeid printString: 10).
		self uiManager 
		    addUi: mergeid
		    path: self parent path
		    name: self name
		    action: nil
		    type: GTK.Gtk gtkUiManagerSeparator
		    top: false]
	    ifFalse: 
		[action := GTK.GtkAction 
			    new: self name
			    label: self menuLabel
			    tooltip: 'FIXME'
			    stockId: nil.

		"FIXME, when to use stock options?  GTK.Gtk gtkStockOpen."
		action 
		    connectSignal: 'activate'
		    to: self
		    selector: #activated:data:
		    userData: nil.

		"FIXME when to trigger accelerators"
		"self actionGroup addActionWithAccel: foo accelerator: '<control>O'."
		self actionGroup addAction: action.
		self uiManager 
		    addUi: self uiManager newMergeId
		    path: self parent path
		    name: self name
		    action: self name
		    type: GTK.Gtk gtkUiManagerMenuitem
		    top: false]
    ]

    activated: action data: userData [
	<category: 'private'>
	self invokeCallback
    ]

    initialize: parentWidget [
	"initialize a separator item"

	<category: 'private'>
	super initialize: parentWidget.
	self properties at: #label put: nil
    ]

    initialize: parentWidget label: label [
	<category: 'private'>
	| s |
	super initialize: parentWidget.
	self properties at: #label put: label.
	parent exists ifTrue: [self create]
    ]
]



BMenuItem subclass: BCheckMenuItem [
    | status |
    
    <comment: 'I am a menu item which can be toggled between two states, marked
and unmarked.'>
    <category: 'Graphics-Windows'>

    BCheckMenuItem class >> new: parent [
	<category: 'instance creation'>
	self shouldNotImplement
    ]

    invokeCallback [
	"Generate a synthetic callback"

	<category: 'accessing'>
	self properties removeKey: #value ifAbsent: [].
	self callback isNil ifFalse: [self callback send]
    ]

    value [
	"Answer whether the menu item is in a selected (checked) state."

	<category: 'accessing'>
	^self properties at: #value ifAbsentPut: [false]
    ]

    value: aBoolean [
	"Set whether the button is in a selected (checked) state and
	 generates a callback accordingly."

	<category: 'accessing'>
	self properties at: #value put: aBoolean.
	self tclEval: 'set ' , self variable , self valueString.
	self callback isNil ifFalse: [self callback send]
    ]

    create [
	<category: 'private'>
	super create.
	self 
	    tclEval: '%1 entryconfigure %2 -onvalue 1 -offvalue 0 -variable %3'
	    with: self container
	    with: self connected
	    with: self variable
    ]

    destroyed [
	"Private - The receiver has been destroyed, clear the corresponding
	 Tcl variable to avoid memory leaks."

	<category: 'private'>
	self tclEval: 'unset ' , self variable.
	super destroyed
    ]

    valueString [
	<category: 'private'>
	^self value ifTrue: [' 1'] ifFalse: [' 0']
    ]

    variable [
	<category: 'private'>
	^'var' , self connected , self container copyWithout: $.
    ]

    widgetType [
	<category: 'private'>
	^'checkbutton'
    ]
]



"-------------------------- BEdit class -----------------------------"



"-------------------------- BLabel class -----------------------------"



Eval [
    BLabel initialize
]



"-------------------------- BButton class -----------------------------"



"-------------------------- BForm class -----------------------------"



"-------------------------- BContainer class -----------------------------"



"-------------------------- BRadioGroup class -----------------------------"



"-------------------------- BRadioButton class -----------------------------"



"-------------------------- BToggle class -----------------------------"



"-------------------------- BImage class -----------------------------"



"-------------------------- BList class -----------------------------"



"-------------------------- BWindow class -----------------------------"



"-------------------------- BTransientWindow class -----------------------------"



"-------------------------- BPopupWindow class -----------------------------"



"-------------------------- BDialog class -----------------------------"



"-------------------------- BMenuBar class -----------------------------"



"-------------------------- BMenu class -----------------------------"



"-------------------------- BPopupMenu class -----------------------------"



"-------------------------- BMenuItem class -----------------------------"



"-------------------------- BCheckMenuItem class -----------------------------"

