"======================================================================
|
|   Smalltalk Gtk+ bindings examples
|
 ======================================================================"

"======================================================================
|
| Copyright 2001, 2003, 2009 Free Software Foundation, Inc.
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


PackageLoader fileInPackage: 'GTK'.


Namespace current: GTK [

Object subclass: TicTacToe [
    | table buttons window turn state count |
    
    <category: nil>
    <comment: nil>

    button: i setLabel: aString [
	"Note that we get a GtkLabel automagically.  That's because
	 GNU Smalltalk calls #narrow on the GtkWidget returned by
	 gtk_bin_get_child before returning it to us."

	<category: 'data'>
	(buttons at: i) getChild setLabel: aString
    ]

    reset [
	<category: 'data'>
	table := Array new: 9.
	count := 0.
	turn := 'X'.
	state := #neutral.
	1 to: 9 do: [:i | self button: i setLabel: i printString]
    ]

    play: which [
	<category: 'data'>
	state == #neutral ifFalse: [^self].
	(table at: which) isNil 
	    ifTrue: 
		[table at: which put: turn.
		self button: which setLabel: turn.
		count := count + 1.
		count = 9 ifTrue: [state := #draw].
		self win ifTrue: [state := #win].
		state == #win ifTrue: [self message: turn , ' wins!'].
		state == #draw ifTrue: [self message: 'It''s a draw!'].
		turn := turn = 'X' ifTrue: ['O'] ifFalse: ['X']]
    ]

    win [
	"Functional programming frenzy :-)"

	<category: 'data'>
	^#(#(1 2 3) #(4 5 6) #(7 8 9) #(1 4 7) #(2 5 8) #(3 6 9) #(1 5 9) #(3 5 7)) 
	    anySatisfy: 
		[:combo | 
		((combo collect: [:i | table at: i]) 
		    fold: [:a :b | a = b ifTrue: [a] ifFalse: [nil]]) notNil]
    ]

    resetClicked: object data: data [
	<category: 'event handling'>
	self reset
    ]

    clicked: object data: data [
	<category: 'event handling'>
	self play: data
    ]

    destroy: object data: data [
	<category: 'event handling'>
	Gtk mainQuit
    ]

    message: aString [
	<category: 'window layout'>
	| dialog |
	dialog := GtkMessageDialog 
		    new: window
		    flags: Gtk gtkDialogDestroyWithParent
		    type: Gtk gtkMessageInfo
		    buttons: Gtk gtkButtonsClose
		    message: aString.
	dialog
	    run;
	    destroy
    ]

    open [
	<category: 'window layout'>
	| button vbox hbox |
	window := GtkWindow new: Gtk gtkWindowToplevel.
	window setTitle: 'Tic-tac-toe'.
	window 
	    connectSignal: 'destroy'
	    to: self
	    selector: #destroy:data:
	    userData: nil.
	window setBorderWidth: 10.
	vbox := GtkVBox new: false spacing: 0.
	vbox setBorderWidth: 2.
	window add: vbox.
	buttons := Array new: 9.
	1 to: 7
	    by: 3
	    do: 
		[:i | 
		hbox := GtkHBox new: true spacing: 0.
		vbox 
		    packStart: hbox
		    expand: true
		    fill: true
		    padding: 0.
		i to: i + 2
		    do: 
			[:j | 
			buttons at: j put: (button := GtkButton newWithLabel: '').
			button 
			    connectSignal: 'clicked'
			    to: self
			    selector: #clicked:data:
			    userData: j.
			hbox 
			    packStart: button
			    expand: true
			    fill: true
			    padding: 0]].
	button := GtkButton newWithLabel: 'Reset'.
	button 
	    connectSignal: 'clicked'
	    to: self
	    selector: #resetClicked:data:
	    userData: nil.
	vbox 
	    packEnd: button
	    expand: false
	    fill: false
	    padding: 0.
	vbox 
	    packEnd: GtkHSeparator new
	    expand: false
	    fill: false
	    padding: 5.
	self reset.
	window setDefaultSize: 100 height: 130.
	window showAll
    ]
]

]



Namespace current: GTK [
    TicTacToe new open.
    Gtk main
]

