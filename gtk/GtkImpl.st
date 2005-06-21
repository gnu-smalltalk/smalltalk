"======================================================================
|
|   Smalltalk Gtk+ bindings (hand-written methods).
|
 ======================================================================"


"======================================================================
|
| Copyright 2001, 2003 Free Software Foundation, Inc.
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

!GtkWidget methodsFor: 'accessing'!

getSizeRequest
    "Answer the size the widget has requisitioned."
    | requisition |
    requisition := GTK.GtkRequisition new.
    self sizeRequest: requisition.
    ^requisition asPoint! !
  
!GtkMessageDialog class methodsFor: 'instance creation'!

new: parent flags: flags type: type buttons: buttons message: message
    ^self
        new: parent
        flags: flags
        type: type
        buttons: buttons
        messageFormat: '%s'
        varargs: { message }! !

!GtkRequisition class methodsFor: 'instance creation'!

fromPoint: point
    | ba |
    ba := (CShortType arrayType: 2) new.
    ba at: 0 put: point x.
    ba at: 1 put: point y.
    ^(ba castTo: self type) addToBeFinalized; yourself! !

!GtkRequisition methodsFor: 'accessing'!

x
    | ba |
    ba := self castTo: (CShortType arrayType: 4).
    ^ba at: 0!

y
    | ba |
    ba := self castTo: (CShortType arrayType: 4).
    ^ba at: 1! !

!GtkRequisition methodsFor: 'conversion'!

asPoint
    ^{self width value. self height value}!

!GdkRectangle class methodsFor: 'instance creation'!

fromRectangle: rect
    | ba |
    ba := (CShortType arrayType: 4) new.
    ba at: 0 put: rect left.
    ba at: 1 put: rect top.
    ba at: 2 put: rect width.
    ba at: 3 put: rect height.
    ^(ba castTo: self type) addToBeFinalized; yourself! !

!GdkRectangle methodsFor: 'accessing'!

left
    | ba |
    ba := self castTo: (CShortType arrayType: 4).
    ^ba at: 0!

top
    | ba |
    ba := self castTo: (CShortType arrayType: 4).
    ^ba at: 1!

right
    | ba |
    ba := self castTo: (CShortType arrayType: 4).
    ^(ba at: 0) + (ba at: 2)!

bottom
    | ba |
    ba := self castTo: (CShortType arrayType: 4).
    ^(ba at: 1) + (ba at: 3)!

width
    | ba |
    ba := self castTo: (CShortType arrayType: 4).
    ^ba at: 2!

height
    | ba |
    ba := self castTo: (CShortType arrayType: 4).
    ^ba at: 3!

origin
    | ba |
    ba := self castTo: (CShortType arrayType: 4).
    ^(ba at: 0) @ (ba at: 1)!

extent
    | ba |
    ba := self castTo: (CShortType arrayType: 4).
    ^(ba at: 2) @ (ba at: 3)!

corner
    | ba |
    ba := self castTo: (CShortType arrayType: 4).
    ^((ba at: 0) + (ba at: 2)) @ ((ba at: 1) + (ba at: 3))! !

!GdkRectangle methodsFor: 'conversion'!

asRectangle
    | ba |
    ba := self castTo: (CShortType arrayType: 4).
    ^(ba at: 0) @ (ba at: 1) extent:
        (ba at: 2) @ (ba at: 3)! !

!GtkTreeIter class methodsFor: 'instance creation' !

new
    ^self type new
	addToBeFinalized;
	yourself
! !

!GtkTextIter class methodsFor: 'instance creation' !

new
    ^self type new
	addToBeFinalized;
	yourself
! !

!GtkTreeModel methodsFor: 'accessing' !

getIter: path
    | iter |
    iter := GTK.GtkTreeIter new.
    self getIter: iter path: path.
    ^iter!

getIterFirst
    | iter |
    iter := GTK.GtkTreeIter new.
    self getIterFirst: iter.
    ^iter!

iterChildren: parent
    | iter |
    iter := GTK.GtkTreeIter new.
    self iterChildren: iter parent: parent.
    ^iter!

iterNthChild: parent n: n
    | iter |
    iter := GTK.GtkTreeIter new.
    self iterNthChild: iter parent: parent n: n.
    ^iter!

iterParent: child
    | iter |
    iter := GTK.GtkTreeIter new.
    self iterParent: iter child: child.
    ^iter! !

!GtkTreeSelection methodsFor: 'accessing' !

getSelected
    | has iter |
    iter := GTK.GtkTreeIter new.
    has := self getSelected: nil iter: iter.
    ^has ifTrue: [ iter ] ifFalse: [ nil ]! !

!GtkListStore methodsFor: 'accessing' !

insert: anInteger
    | iter |
    iter := GTK.GtkTreeIter new.
    self insert: iter position: anInteger.
    ^iter!

insertBefore: sibling
    | iter |
    iter := GTK.GtkTreeIter new.
    self insertBefore: iter sibling: sibling.
    ^iter!

insertAfter: sibling
    | iter |
    iter := GTK.GtkTreeIter new.
    self insertAfter: iter sibling: sibling.
    ^iter!

prepend
    | iter |
    iter := GTK.GtkTreeIter new.
    self prepend: iter.
    ^iter!

append
    | iter |
    iter := GTK.GtkTreeIter new.
    self append: iter.
    ^iter! !

!GtkTextBuffer methodsFor: 'accessing' !

setText: aString
    "Set my contents"
    self setText: aString len: aString size
!

insertAtCursor: aString
    "Insert aString at the curser."
    self insertAtCursor: aString len: aString size!

getBounds
    "Answer my entire contents."
    | start end |
    start := GTK.GtkTextIter new.
    end := GTK.GtkTextIter new.
    self getBounds: start end: end.
    ^{start. end}
!

getIterAtMark: mark
    "Answer an iterator for mark"
    | iter |
    iter := GTK.GtkTextIter new.
    self getIterAtMark: iter mark: mark.
    ^iter
!

getSelectionBounds
    "Answer my selection bounds"
    | start end |
    start := GTK.GtkTextIter new.
    end := GTK.GtkTextIter new.
    self getSelectionBounds: start end: end.
    ^{start. end}
!

getIterAtLine: line
    "Answer an iterator at the beginning of line."
    | result |
    result := GTK.GtkTextIter new.
    self getIterAtLine: result lineNumber: line.
    ^result!

getIterAtLineOffset: lineNumber charOffset: charOffset
    "Answer an iterator at offset in me."
    | result |
    result := GTK.GtkTextIter new.
    self getIterAtLineOffset: result lineNumber: lineNumber charOffset: charOffset.
    ^result
!

getStartIter
  "Answer a start iterator."
    | result |
    result := GTK.GtkTextIter new.
    self getStartIter: result.
    ^result
!

getEndIter
    "Answer an end iterator"
    | result |
    result := GTK.GtkTextIter new.
    self getEndIter: result.
    ^result
!

insert: iter text: aString
    "Insert aString at the insertion point."
    self insert: iter text: aString len: aString size.
! !

!Gtk class methodsFor: 'event loop'!

main
    "Main loop implementation.  Same as gtk_main, but it lets Smalltalk
     processes run.  Like gtk_main, it is ended with Gtk>>#mainQuit."
    | sem |
    sem := Semaphore new.
    "This call is asynchronous, so it leaves us waiting on the #wait call just
     below.  Our loop starts as soon as the next bytecode is executed,
     because sem is asynchronously signalled by my_gtk_main."
    GTK.Gtk main: sem.
    sem wait.
    [
        GTK.Gtk mainIterationDo: false.
        GTK.Gtk shouldQuit
    ] whileFalse: [
        Processor yield.
    ]
! !
