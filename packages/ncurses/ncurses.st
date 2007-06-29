"======================================================================
|
|   ncurses declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006 Free Software Foundation, Inc.
| Written by Brad Watson
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


"======================================================================
|
|   Notes: implemented without callbacks.  See the ncurses man pages 
|   for a description of the wrapped ncurses library functions.
|
 ======================================================================"

CStruct subclass: #NCWindow
    declaration: #(
	(#curY #short)
	(#curX #short)
	(#maxY #short)
	(#maxX #short)
	(#begY #short)
	(#begX #short)
	(#flags #short)
	(#attrs #uInt)
	(#bkGd #uInt)
	(#noTimeout #uChar)
	(#clear #uChar)
	(#leaveOk #uChar)
	(#scroll #uChar)
	(#idlOk #uChar)
	(#immed #uChar)
	(#sync #uChar)
	(#useKeypad #uChar)
	(#delay #uChar) 
	(#line (#ptr #CObject))
	(#regTop #short)
	(#regBottom #short)
	(#parX #int)
	(#parY #int)
	(#parent (#ptr #CObject))
	(#padY #short)
	(#padX #short)
	(#padTop #short)
	(#padLeft #short)
	(#padBottom #short)
	(#padRight #short)
	(#yOffset #short)
	(#attr #short)
	(#chars (#array #char 5)))        
    classVariableNames: 'StdScreen' 
    poolDictionaries: ''
    category: 'NCurses Wrapper'!
        

!NCWindow class methodsFor: 'Constants'!


colorBlack
    ^0!

colorBlue
    ^4!

colorCyan
    ^6!

colorGreen
    ^2!

colorMagenta
    ^5!

colorRed
    ^1!

colorWhite
    ^7!

colorYellow
    ^3!

endLine
    ^16r2!

err
    ^-1!

false
    ^0!

fullWin
    ^16r4!

hasMoved
    ^1620!

isPad
    ^1610!

keyA1
    ^534!

keyA3
    ^535!

keyBackspace
    ^407!

keyBreak
    ^401!

keyB2
    ^536!

keyBeg
    ^542!

keyBtab
    ^541!

keyC1
    ^537!

keyC3
    ^540!

keyCancel
    ^543!

keyCatab
    ^526!

keyClose
    ^544!

keyCommand
    ^545!

keyCopy
    ^546!

keyCreate
    ^547!

keyClear
    ^515!

keyCodeYes
    ^400!

keyCtab
    ^525!

keyDl
    ^510!

keyDc
    ^512!

keyDown
    ^402!

keyEic
    ^514!

keyEnd
    ^550!

keyEnter
    ^527!

keyEol
    ^517!

keyEos
    ^516!

keyEvent
    ^633!

keyExit
    ^551!

keyFind
    ^552!

keyHelp
    ^553!

keyHome
    ^406!

keyIl
    ^511!

keyIc
    ^513!

keyLeft
    ^404!

keyLl
    ^533!

keyMax
    ^777!

keyMark
    ^554!

keyMessage
    ^555!

keyMin
    ^401!

keyMouse
    ^631!

keyMove
    ^556!

keyNext
    ^557!

keyNpage
    ^522!

keyOpen
    ^560!

keyOptions
    ^561!

keyPrevious
    ^562!

keyPrint
    ^532!

keyPpage
    ^523!

keyRedo
    ^563!

keyReference
    ^564!

keyRefresh
    ^565!

keyReplace
    ^566!

keyReset
    ^531!

keyResize
    ^632!

keyRestart
    ^567!

keyResume
    ^570!

keyRight
    ^405!

keySave
    ^571!

keySbeg
    ^572!

keyScancel
    ^573!

keyScommand
    ^574!

keyScopy
    ^575!

keyScreate
    ^576!

keySdc
    ^577!

keySdel
    ^600!

keySelect
    ^601!

keySend
    ^602!

keySeol
    ^603!

keySexit
    ^604!

keySf
    ^520!

keySfind
    ^605!

keyShelp
    ^606!

keyShome
    ^607!

keySic
    ^610!

keySleft
    ^611!

keySmessage
    ^612!

keySmove
    ^613!

keySnext
    ^614!

keySoptions
    ^615!

keySprevious
    ^616!

keySprint
    ^617!

keySr
    ^521!

keySredo
    ^620!

keySreplace
    ^621!

keySReset
    ^530!

keySright
    ^622!

keySrsume
    ^623!

keySsave
    ^624!

keySsuspend
    ^625!

keyStab
    ^524!

keySundo
    ^626!

keySuspend
    ^627!

keyUndo
    ^630!

keyUp
    ^403!

noChange
    ^-1!

newIndex
    ^-1!

ok
    ^0!

subWin
    ^16r0!

scrollWin
    ^16r8!

true
    ^1!

wrapped
    ^16r40!


!NCWindow methodsFor: 'C call-outs'!


box: aChar1 withHorizontalChar: aChar2
    "I draw a box using the characters sent as arguments.  See the
     man(3) box entry for a description of my c function call."

    "int box (WINDOW *, chtype, chtype);"
    <cCall: 'box' returning: #int
	args: #(#self #char #char )>!

clearok: aBoolean
    "I cause the screen to be cleared and re-drawn from scratch the
     next time the refresh message is sent when I receive the boolean
     value 'true' as an argument.  See the man(3) clearok entry for a
     description of my c function call."

    "int clearok (WINDOW *, bool);"
    <cCall: 'clearok' returning: #int
	args: #(#self #boolean )>!

copywin: cObject 
          sourceMinimumRow: anInt1 sourceMinimumColumn: anInt2
          destinationMinimumRow: anInt3 destinationMinimumColumn: anInt4
          destinationMaximumRow: anInt5 destinationMaximumColumn: anInt6
          overlay: anInt7
    "I overlay or overwrite a destination window with my window. See
     the man(3) copywin entry for a description of my c function
     call."

    "int copywin (const WINDOW*, WINDOW*, int, int, int, int, int, int, int);"
    <cCall: 'copywin' returning: #int
	args: #(#self #cObject #int #int #int #int #int #int #int )>!

delscreen: cObject
    "I release the storage associated with a screen structure. See the
     man(3) delscreen entry for a description of my c function call."

    "void delscreen (SCREEN *);"
    <cCall: 'delscreen' returning: #void
	args: #(#cObject )>!

delwin
    "I release the storage associated with my window structure. See
    the man(3) delwin entry for a description of my c function call."

    "int delwin (WINDOW *);"
    <cCall: 'delwin' returning: #int
	args: #(#self )>!

derwin: anInt1 forColumns: anInt2 atY: anInt3 atX: anInt4
    "I return a new window with the given number lines and columns
     with the top left corner at the location given as coorindates.
     See the man(3) derwin entry for a description of my c function
     call."

    "WINDOW *derwin (WINDOW *, int, int, int, int);" 
    <cCall: 'derwin' returning: NCWindow type 
	args: #(#self #int #int #int #int )>!
dupwin
    "I return a duplicate of my window. See the man(3) dupwin entry
     for a description of my c function call."

    "WINDOW *dupwin (WINDOW *);" 
    <cCall: 'dupwin' returning: NCWindow type
	args: #(#self )>!

getbkgd
    "I return my windows' attribute/character pair.  See the man(3)
     getbkgd entry for a description of my c function call."

    "chtype getbkgd (WINDOW *);" 
    <cCall: 'getbkgd' returning: #char
	args: #(#self )>!

"Not implemented:"
"getwin: cObject"
    "WINDOW *getwin (FILE *);"
"    <cCall: 'getwin' returning: #cObject args: #(#cObject )>!"

idcok: aBoolean
    "I enable or disable the use of the hardware character
     insert/delete terminal feature if it's available. See the man(3)
     idcok entry for a description of my c function call."

    "void idcok (WINDOW *, bool);" 
    <cCall: 'idcok' returning: #void
        args: #(#self #boolean )>!

idlok: aBoolean
    "I enable or disable the use of the hardware line insert/delete
     terminal feature if it's available. See the man(3) idlok entry
     for a description of my c function call."

    "int idlok (WINDOW *, bool);" 
    <cCall: 'idlok' returning: #int
	args: #(#self #boolean )>!

immedok: aBoolean
    "I enable or disable the automatic refresh of my window whenever
     it's updated. See the man(3) immedok entry for a description of
     my c function call."

    "void immedok (WINDOW *, bool);" 
    <cCall: 'immedok' returning: #void 
	args: #(#self #boolean )>!

intrflush: aBoolean
    "I enable or disable flushing the tty driver queue whenever an
     interrupt key is pressed. See then man(3) intrflush entry for
     a description of my c call function."

    "int intrflush (WINDOW *, bool);" 
    <cCall: 'intrflush' returning: #int 
	args: #(#self #boolean )>!

isLinetouched: anInt
    "I return true if the line number sent to me as a parameter is
     within my window otherwise I return false.  See the man(3)
     is_linetouched entry for a description of my c function call."

    "bool is_linetouched (WINDOW *, int);" 
    <cCall: 'is_linetouched' returning: #boolean 
	args: #(#self #int )>!

isWintouched
    "I return true if my window has been updated since the last
    refresh message was sent. See the man(3) is_wintouched entry
    for a description of my c function call."

    "bool is_wintouched (WINDOW *);"
    <cCall: 'is_wintouched' returning: #boolean
	args: #(#self )>!

keypad: aBoolean
    "I enable or disable the use of the keyboard keypad. See the
     man(3) keypad entry for a description of my c function call."

    "int keypad (WINDOW *, bool);"
    <cCall: 'keypad' returning: #int
	args: #(#self #boolean )>!

leaveok: aBoolean
    "I enable or disable leaving the cursor at the location an update
    places it. See the man(3) leaveok entry for a description of my c
    function call."

    "int leaveok (WINDOW *, bool);"
    <cCall: 'leaveok' returning: #int
	args: #(#self #boolean )>!

meta: aBoolean
    "I ask the tty driver to return 8-bits if I'm passed the boolean
     value true, and 7-bits if I'm passed the boolean value false.
     See the man(3) meta entry for a description of my c function
     call."

    "int meta (WINDOW *, bool);"
    <cCall: 'meta' returning: #int
	args: #(#self #boolean )>!

mvderwin: anInt1 parX: anInt2
    "I move a subwindow within my window to new location and put
     it's top left corner at the location given to me as a
     coordinates. See the man(3) mvderwin entry for a description of
     my c function call."

    "int mvderwin (WINDOW *, int, int);"
    <cCall: 'mvderwin' returning: #int
	args: #(#self #int #int )>!
    
mvwaddch: anInt1 x: anInt2 ch: aChar
    "I add a character to my window at the current cursor location after
     advancing the cursor to the coordinates given to me. See the
     man(3) mvwaddch entry for a description of my c function call."

    "int mvwaddch (WINDOW *, int, int, const chtype);"
    <cCall: 'mvwaddch' returning: #int
	args: #(#self #int #int #char )>!
 
mvwaddchnstr: anInt1 x: anInt2 str: aString n: anInt3
    "I copy up to n characters of the string and attributes given to
     me into my window starting at the location specified by the
     coordinates given to me. See the man(3) mvwaddchnstr entry for a
     description of my c function call."

    "int mvwaddchnstr (WINDOW *, int, int, const chtype *, int);"
    <cCall: 'mvwaddchnstr' returning: #int
	args: #(#self #int #int #string #int )>!

mvwaddchstr: anInt1 x: anInt2 str: aString
    "I copy the string and attributes given to me into my window
     starting at the location specified by the point given to me. See
     the man(3) mvwaddchnstr entry for a description of my c function
     call."

    "int mvwaddchstr (WINDOW *, int, int, const chtype *);"
    <cCall: 'mvwaddchstr' returning: #int
	args: #(#self #int #int #string )>!

mvwaddnstr: anInt1 x: anInt2 str: aString n: anInt3
    "I copy up to n characters of the string given to me in my window
     starting at the location specified by the coordinates given to
     me.  See the man(3) mvwaddnstr entry for a description of my c
     function call."

    "int mvwaddnstr (WINDOW *, int, int, const char *, int);"
    <cCall: 'mvwaddnstr' returning: #int
	args: #(#self #int #int #string #int )>!

mvwaddstr: anInt1 x: anInt2 str: aString
    "I copy the string given to me into my window starting at the
     location given to me as a point. See the man(3) mvwaddstr entry
     for a description of my c function call."

    "int mvwaddstr (WINDOW *, int, int, const char *);"
    <cCall: 'mvwaddstr' returning: #int
	args: #(#self #int #int #string )>!
 
mvwchgat: anInt1 x: anInt2 n: anInt3 attr: anInt4 color: anInt5 opts: cObject
    "I change the color and attribute of next n characters in my
     window starting at the location specified by the point given to
     me. See the man(3) mvwchgat entry for a description of my c
     function call."

    "int mvwchgat (WINDOW *, int, int, int, attr_t, short, const void *);"
    <cCall: 'mvwchgat' returning: #int 
        args: #(#self #int #int #int #int #int #cObject )>!

mvwdelch: anInt1 x: anInt2
    "I move the cursor to the coordinates given to me in my window,
     delete the character under the cursor, and then shift the
     remaining characters in the line one position to the left. See
     the man(3) mvwdelch entry for description of my c function call."

    "int mvwdelch (WINDOW *, int, int);"
    <cCall: 'mvwdelch' returning: #int
	args: #(#self #int #int )>!

mvwgetch: anInt1 x: anInt2
    "I position the cursor to the location in my window specified by
     the point given to me, I read a character. See the man(3)
     mvwgetch entry for a description of my c function call."

    "int mvwgetch (WINDOW *, int, int);"
    <cCall: 'mvwgetch' returning: #int
	args: #(#self #int #int )>!

mvwgetnstr: anInt1 x: anInt2 str: aString n: anInt3
    "I position the cursor to the location in my window specified by
     the coordinates given to me, and then I read at most n characters
     until a carriage return or newline is pressed. See the man(3)
     mvwgetnstr entry for a description of my c function call."

    "int mvwgetnstr (WINDOW *, int, int, char *, int);"
    <cCall: 'mvwgetnstr' returning: #int
	args: #(#self #int #int #string #int )>!

mvwgetstr: anInt1 x: anInt2 str: aString
    "I position the cursor to the location in my window specified by
     the coordinates given to me, and thenI read characters until a
     carriage return or a newline is pressed. See man(3) mvwgetstr
     entry for a description of my c function call."

    "int mvwgetstr (WINDOW *, int, int, char *);"
    <cCall: 'mvwgetstr' returning: #int
	args: #(#self #int #int #string )>!

mvwhline: anInt1 x: anInt2 ch: aChar n: anInt3
    "I position the cursor to the location in my window specified by
     the coordinates given to me, and then I write a horizontal line
     of at most n characters comprised of the character given to me.
     See the man(3) mvwhline entry for a description of my c function
     call."

    "int mvwhline (WINDOW *, int, int, chtype, int);"
    <cCall: 'mvwhline' returning: #int
	args: #(#self #int #int #char #int )>!

mvwin: anInt1 x: anInt2
    "I move the top-left-corner of my window to the location given to
     me as coordinates. See the man(3) mvwin entry for a description
     of my c function call."

    "int mvwin (WINDOW *, int, int);"
    <cCall: 'mvwin' returning: #int
	args: #(#self #int #int )>!

mvwinch: anInt1 x: anInt2
    "I return the character or attribute at the cursor location
     specifed by the coordinates given to me. See the man(3) mvwinch
     entry for a description of my c call function."

    "chtype mvwinch (WINDOW *, int, int);"
    <cCall: 'mvwinch' returning: #char
	args: #(#self #int #int )>!

mvwinchnstr: anInt1 x: anInt2 str: aString n: anInt3
    "I return a null terminated array of characters or attributes from
     my window of at most n characters starting at the cursor location
     specified by the coordinates given to me. See the man(3)
     mvwinchnstr entry for a description of my c function call."

    "int mvwinchnstr (WINDOW *, int, int, chtype *, int);"
    <cCall: 'mvwinchnstr' returning: #int
	args: #(#self #int #int #string #int )>!

mvwinchstr: anInt1 x: anInt2 str: aString
    "I return a null terminated array of characters or attributes from
     within my window starting at the cursor location given by the
     coordinates given to me. See the man(3) mvwinchstr entry for a
     description of my c call function."

    "int mvwinchstr (WINDOW *, int, int, chtype *);"
    <cCall: 'mvwinchstr' returning: #int
	args: #(#self #int #int #string )>!

mvwinnstr: anInt1 x: anInt2 str: aString n: anInt3
    "I return a string of characters from my window stripped of
     attributes starting at the location given to me as
     coordinates. See the man(3) mvwinnstr entry for a description of
     my c function call."

    "int mvwinnstr (WINDOW *, int, int, char *, int);"
    <cCall: 'mvwinnstr' returning: #int
	args: #(#self #int #int #string #int )>!

mvwinsch: anInt1 x: anInt2 ch: aChar
    "I insert a character in my window before the location given to me
     as coordinates. The remaining characters in the line are shifted
     one position to the right. See the man(3) mvwinsch entry for a
     description of my c function call."

    "int mvwinsch (WINDOW *, int, int, chtype);"
    <cCall: 'mvwinsch' returning: #int
	args: #(#self #int #int #char )>!

mvwinsnstr: anInt1 x: anInt2 str: aString n: anInt3
    "I insert a string of at most n characters in my window before the
     location given to me as coordinates. The remaining characters in
     the line are shifted one position to the right. See the man(3)
     mvwinsnstr entry for a description of my c function call."

    "int mvwinsnstr (WINDOW *, int, int, const char *, int);"
    <cCall: 'mvwinsnstr' returning: #int
	args: #(#self #int #int #string #int )>!

mvwinsstr: anInt1 x: anInt2 str: aString
    "I insert a string before the location in my window given to me as
     coordinates.  The remaining characters in the line are shifted
     one position to the right. See the man(3) mvwinsstr entry for a
     description of my c function call."

    "int mvwinsstr (WINDOW *, int, int, const char *);"
    <cCall: 'mvwinsstr' returning: #int
	args: #(#self #int #int #string )>!

mvwinstr: anInt1 x: anInt2 str: aString
    "I return a string of characters from my window starting from the
     location given to me as coordinates. See the man(3) mvwinstr for a
     description of my c function call."

    "int mvwinstr (WINDOW *, int, int, char *);"
    <cCall: 'mvwinstr' returning: #int
	args: #(#self #int #int #string )>!

mvwprintw: anInt1 x: anInt2 str: aString
    "I print a string in my window at the location given to me as
     coordinates.  See the man(3) mvwprintw entry for a description of
     my c function call."

    "int mvwprintw (WINDOW*, int, int, const char *)"
    <cCall: 'mvwprintw' returning: #int
	args: #(#self #int #int #string )>!

mvwprintw: anInt1 x: anInt2 str: aString args: anArray
    "I print a formated string and arguments in my window at the
     location given to me as coordinates.  See the man(3) mvwprintw
     entry for a description of my c function call."

    "int mvwprintw (WINDOW*, int, int, const char *, ...)"
    <cCall: 'mvwprintw' returning: #int
	args: #(#self #int #int #string #variadic )>!

mvwscanw: anInt1 x: anInt2 str: aString args: anArray
    "I scan a string from within my window at the location given to me
     a point. See the man(3) mvwscanw entry for a description of my c
     function call."

    "int mvwscanw (WINDOW *, int, int, const char *, ...)"
    <cCall: 'mvwscanw' returning: #int
	args: #(#self #int #int #string #variadic )>!

mvwvline: anInt1 x: anInt2 ch: aChar n: anInt3
    "I position the cursor to the location in my window specified by
     the coordinates given to me, then I write a vertical line of at
     most n characters comprised of the character given to me.  See
     the man(3) mvwvline entry for a description of my c function
     call."

    "int mvwvline (WINDOW *, int, int, chtype, int);"
    <cCall: 'mvwvline' returning: #int
	args: #(#self #int #int #char #int )>!

nodelay: aBoolean
    "I set getch to be non-blocking in my window if I'm given a value
     of true. Otherwise I set getch be blocking. See the man(3)
     nodelay entry for a description of my c function call."

    "int nodelay (WINDOW *, bool);"
    <cCall: 'nodelay' returning: #int
	args: #(#self #boolean )>!

notimeout: aBoolean
    "I turn off the timer for reading an escape sequence by wgetch for
     my window if I am given the boolean value true.  Otherwise, I
     turn the timer on. See the man(3) notimeout entry for a
     description of my c functtion call."

    "int notimeout (WINDOW *, bool);"
    <cCall: 'notimeout' returning: #int
	args: #(#self #boolean )>!

overlay: cObject
    "I overlay the window given to me with my window. See the man(3)
     overlay entry for a description of my c function call."

    "int overlay (const WINDOW*, WINDOW *);"
    <cCall: 'overlay' returning: #int
	args: #(#self #cObject )>!

overwrite: cObject 
    "I overwrite the window given to me with my window. See the man(3)
    overwrite entry for a description of my c function call."

    "int overwrite (const WINDOW*, WINDOW *);"
    <cCall: 'overwrite' returning: #int
	args: #(#self #cObject )>!

pechochar: aChar
    "I output a character to the pad in my window. See the man(3)
     pechochar entry for a description of my c function call."

    "int pechochar (WINDOW *, const chtype);"
    <cCall: 'pechochar' returning: #int
	args: #(#self #char )>!

pnoutrefresh: anInt1 pmincol: anInt2
          sminrow: anInt3 smincol: anInt4 
          smaxrow: anInt5 smaxcol: anInt6
    "I copy my windows pad to the virtual screen. See the man(3)
     pnoutrefresh entry for a description of my c function call."

    "int pnoutrefresh (WINDOW*, int, int, int, int, int, int);"
    <cCall: 'pnoutrefresh' returning: #int
	args: #(#self #int #int #int #int #int #int )>!

prefresh: anInt1 pmincol: anInt2
          sminrow: anInt3 smincol: anInt4 
          smaxrow: anInt5 smaxcol: anInt6
    "I copy the pad in my window to the physical screen. See the
     man(3) entry for a description of my c function call."

    "int prefresh (WINDOW *, int, int, int, int, int, int);"
    <cCall: 'prefresh' returning: #int
	args: #(#self #int #int #int #int #int #int )>!

redrawwin
    "I tag all the lines in my window to be output during the next
     refresh.  See the man(3) redrawwin entry for a description of my
     c function call."

    "int redrawwin (WINDOW *);"
    <cCall: 'redrawwin' returning: #int
	args: #(#self )>!

scroll
    "I scroll up my window up one line. See the man(3) scroll entry
     for a description of my c function call."

    "int scroll (WINDOW *);"
    <cCall: 'scroll' returning: #int
	args: #(#self )>!

scrollok: aBoolean
    "I enable scrolling the window when the cursor is within a scroll
     region if I am given the boolean value true. Otherwise, I disable
     scrolling the window when the cursor is in the scroll region."

    "int scrollok (WINDOW *, bool);"
    <cCall: 'scrollok' returning: #int
	args: #(#self #boolean )>!

subpad: anInt1 ncols: anInt2 beginY: anInt3 beginX: anInt4
    "I create a sub-window within a pad in my window of the given size
    and location. See the man(3) subpad entry for a description of my
    c function call."

    "WINDOW *subpad (WINDOW *, int, int, int, int);"
    <cCall: 'subpad' returning: NCWindow type 
	args: #(#self #int #int #int #int )>!

subwin: anInt1 ncols: anInt2 beginY: anInt3 beginX: anInt4
    "I create a new sub-window with m y window of the given size and
    location.  See the man(3) subwin entry for a description of my c
    function call."

    "WINDOW *subwin (WINDOW *, int, int, int, int);"
    <cCall: 'subwin' returning: NCWindow type 
	args: #(#self #int #int #int #int )>!

syncok: aBoolean
    "I enable the automatic updating of ancestor windows when a change
    occurs if my window if given the boolean true value. See the
    man(3) syncok entry for a description of my c function call."

    "int syncok (WINDOW *, bool);"
    <cCall: 'syncok' returning: #int 
	args: #(#self #boolean )>!

touchline: anInt1 count: anInt2
    "I configure the lines in my window given to me to be redrawn
    during the next refresh.  See the man(3) touchline entry for a
    description of my c function call."

    "int touchline (WINDOW *, int, int);"
    <cCall: 'touchline' returning: #int 
	args: #(#self #int #int )>!

touchwin
    "I configure my window to be to be redraw during the next refresh.
     See the man(3) touchwin entry for a description of my c function
     call."

    "int touchwin (WINDOW *);" 
    <cCall: 'touchwin' returning: #int
	args: #(#self )>!

untouchwin
    "I mark all the lines in my windows as untouched since the last
    refresh. See the man(3) untouchwin entry for a description of my c
    function call."

    "int untouchwin (WINDOW *);"
    <cCall: 'untouchwin' returning: #int 
	args: #(#self )>!

waddch: aChar
    "I add a character given to me to my window at the current cursor
    location and then advance the cursor. See the man(3) waddch entry
    for a description of my c function call."

    "int waddch (WINDOW *, const chtype);"
    <cCall: 'waddch' returning: #int 
	args: #(#self #char )>!

waddchnstr: aString n: anInt
    "I copy up to n characters of the string and attributes given to
    me into my window starting at the location specified by the
    coordinates given to me. See the man(3) mvwaddchnstr entry for a
    description of my c function call."

    "int waddchnstr (WINDOW *, const chtype *, int);"
    <cCall: 'waddchnstr' returning: #int
	args: #(#self #string #int )>!

waddchstr: aString
    "I copy the string and attributes given to me into my window. See
    the man(3) waddchstr entry for a description of my c function
    call."

    "int waddchstr (WINDOW *, const chtype *);"
    <cCall: 'waddchstr' returning: #int 
	args: #(#self #string )>!

waddnstr: aString n: anInt
    "I copy up to n characters of the string given to me in my window.
    See the man(3) waddnstr entry for a description of my c function
    call."

    "int waddnstr (WINDOW *, const char *, int);"
    <cCall: 'waddnstr' returning: #int 
	args: #(#self #string #int )>!

waddstr: aString
    "I copy the string given to me into my window. See the man(3)
    waddstr entry for a description of my c function call."

    "int waddstr (WINDOW *, const char *);"
    <cCall: 'waddstr' returning: #int 
	args: #(#self #string )>!

wattrGet: cObject2 opts: cObject3
    "I return the attribute and color pair for my window. See the
    man(3) wattr_get entry for a description of my c function call."

    "int wattr_get (WINDOW *, attr_t *, short *, void *);"
    <cCall: 'wattr_get' returning: #int 
	args: #(#self #cObject #cObject #cObject )>!

wattrOff: anInt opts: cObject
    "I turn off the attributes given to me for my window. See the
    man(3) wattr_off entry for a description of my c function call."

    "int wattr_off (WINDOW *, attr_t, void *);"
    <cCall: 'wattr_off' returning: #int 
	args: #(#self #int #cObject )>!

wattrOn: anInt opts: cObject
    "I turn on the named attribute given to me in my window.  See the
    man(3) wattr_on for a description of my c function call."

    "int wattr_on (WINDOW *, attr_t, void *);"
    <cCall: 'wattr_on' returning: #int 
	args: #(#self #int #cObject )>!

wattrSet: anInt1 pair: anInt2 opts: cObject
    "I set the attribute color-pair in my window to the value given to
    me. See the man(3) attr_set entry for a description of my c
    function call."

    "int wattr_set (WINDOW *, attr_t, short, void *);"
    <cCall: 'wattr_set' returning: #int 
	args: #(#self #int #int #cObject )>!

wattroff: anInt
    "I turn off the named attribute given to me in my window.  See the
    man(3) wattroff for a description of my c function call."

    "int wattroff (WINDOW *, int);"
    <cCall: 'wattroff' returning: #int 
	args: #(#self #int )>!

wattron: anInt
    "I turn on the named attribute given to me in my window.  See the
    man(3) wattron for a description of my c function call."

    "int wattron (WINDOW *, int);"
    <cCall: 'wattron' returning: #int 
	args: #(#self #int )>!

wattrset: anInt
    "I set the attribute color-pair in my window to the value given to
    me. See the man(3) wattrset entry for a description of my c
    function call."

    "int wattrset (WINDOW *, int);"
    <cCall: 'wattrset' returning: #int 
	args: #(#self #int )>!

wbkgd: aChar
    "I set the background attribute given to me to every character in
    the window.  See the man(3) wbkgd entry for a description of my c
    function call."


    "int wbkgd (WINDOW *, chtype);"
    <cCall: 'wbkgd' returning: #int 
	args: #(#self #char )>!

wbkgdset: aChar
    "I set the background to to the value given to me to every
    position in the window.  See the man(3) wbkgdset entry for a
    description of my c function call."

    "void wbkgdset (WINDOW *, chtype);"
    <cCall: 'wbkgdset' returning: #void 
	args: #(#self #char )>!

wborder: aChar1 rs: aChar2 ts: aChar3 bs: aChar4
    tl: aChar5 tr: aChar6 bl: aChar7 br: aChar9
    "I draw a box around the edge of my window using the character
    attributes given to me. See the man(3) wborder entry for a
    description of my c function call."

    "int wborder (WINDOW *, chtype, chtype, chtype, chtype,
        chtype, chtype, chtype, chtype);"
    <cCall: 'wborder' returning: #int 
	args: #(#self #char #char #char #char #char #char #char #char )>!

wchgat: anInt1 attr: anInt2 color: anInt3 opts: cObject
    "I change the color and attribute in my window. See the man(3)
    wchgat entry for a description of my c function call."

    "int wchgat (WINDOW *, int, attr_t, short, const void *);"
    <cCall: 'wchgat' returning: #int 
	args: #(#self #int #int #int #cObject )>!

wclear
    "I put a blank in every character position in my window and set up
    the window to be re-painted the next time that it is
    refreshed. See the man(3) wclear entry for a description of my c
    function calls."

    "int wclear (WINDOW *);"
    <cCall: 'wclear' returning: #int 
	args: #(#self )>!

wclrtobot
    "I erase my window from the right of the current cursor position
    all the way to the bottom right of the screen. See the man(3)
    wclrtobot entry for a description of my c function call."

    "int wclrtobot (WINDOW *);"
    <cCall: 'wclrtobot' returning: #int 
	args: #(#self )>!

wclrtoeol
    "I erase the current line in my window to the right of the current
    cursor location. See the man(3) wclrtoeol entry for a description
    of my c function calls."

    "int wclrtoeol (WINDOW *);"
    <cCall: 'wclrtoeol' returning: #int 
	args: #(#self )>!

wcolorSet: anInt opts: cObject
    "I set the current color of my window to the color pair attribute
    given to me. See the man(3) wcolor_set entry for a description of
    my c function call."
    
    "int wcolor_set (WINDOW*, short, void*);"
    <cCall: 'wcolor_set' returning: #int 
	args: #(#self #int #cObject )>!

wcursyncup
    "I set the cursor position in all of my ancestor windows to the
    current location in my window. See the man(3) wcursyncup entry for
    a description of my c function call."

    "void wcursyncup (WINDOW *);"
    <cCall: 'wcursyncup' returning: #void 
	args: #(#self )>!

wdelch
    "I delete the character under the cursor, and then shift the
    remaining characters in the line one position to the left. See the
    man(3) wdelch entry for description of my c function call."

    "int wdelch (WINDOW *);"
    <cCall: 'wdelch' returning: #int 
	args: #(#self )>!

wdeleteln
    "I delete the line under the current cursor position, move all of
    the lines below the cursor up one line and clear the last
    line. See the man(3) wdeleteln entry for a description of my c
    function call."

    "int wdeleteln (WINDOW *);"
    <cCall: 'wdeleteln' returning: #int 
	args: #(#self )>!

wechochar: aChar
    "I put the character given to me at the current cursor position,
    advance the cursor, and then refresh the screen. See the man(3)
    wechochar entry for a description of my c function call."

    "int wechochar (WINDOW *, const chtype);"
    <cCall: 'wechochar' returning: #int 
	args: #(#self #char )>!

werase
    "I put blanks into every position in the screen. See the man(3)
    werase entry for a description of my c function call."

    "int werase (WINDOW *);"
    <cCall: 'werase' returning: #int 
	args: #(#self )>!

wgetch
    "I read a keystroke from my window. See the man(3) wgetch entry
    for a description of my c function call."

    "int wgetch (WINDOW *);"
    <cCall: 'wgetch' returning: #int 
	args: #(#self )>!

wgetnstr: aString n: anInt
    "I read at most n keystrokes from nm window until a return or
    linefeed key is pressed. See the man(3) wgetnstr entry for a
    description of my c function call."

    "int wgetnstr (WINDOW *, char *, int);"
    <cCall: 'wgetnstr' returning: #int 
	args: #(#self #string #int )>!

wgetstr: aString
    "I read keystrokes from my window until a return or linefeed key
    is pressed. See the man(3) wgetstr entry for a description of my c
    function call."

    "int wgetstr (WINDOW *, char *);"
    <cCall: 'wgetstr' returning: #int 
	args: #(#self #string )>!

whline: aChar n: anInt
    "I draw a horizontal line in my window using the character given
    to me of at most n characters. See the man(3) hline entry for a
    description of my c function call."

    "int whline (WINDOW *, chtype, int);"
    <cCall: 'whline' returning: #int 
	args: #(#self #char #int )>!

winch
    "I return the character or attribute at the current cursor
    location in my window. See the man(3) winch entry for a
    description of my c call function."

    "chtype winch (WINDOW *);"
    <cCall: 'winch' returning: #char 
	args: #(#self )>!

winchnstr: aString n: anInt
    "I return a null terminated array of characters or attributes from
    my window of at most n characters starting at the current cursor
    location. See the man(3) winchnstr entry for a description of my c
    function call."

    "int winchnstr (WINDOW *, chtype *, int);"
    <cCall: 'winchnstr' returning: #int 
	args: #(#self #string #int )>!

winchstr: aString
    "I return a null terminated array of characters or attributes from
    within my window starting at the current cursor location. See the
    man(3) winchstr entry for a description of my c call function."

    "int winchstr (WINDOW *, chtype *);"
    <cCall: 'winchstr' returning: #int 
	args: #(#self #string )>!

winnstr: aString n: anInt
    "I return a string of characters from my window stripped of
    attributes starting at the current cursor location. See the man(3)
    winnstr entry for a description of my c function call."

    "int winnstr (WINDOW *, char *, int);"
    <cCall: 'winnstr' returning: #int 
	args: #(#self #string #int )>!

winsch: aChar
    "I insert a character in my window before the current cursor
    location.  The remaining characters in the line are shifted one
    position to the right. See the man(3) winsch entry for a
    description of my c function call."

    "int winsch (WINDOW *, chtype);"
    <cCall: 'winsch' returning: #int 
	args: #(#self #char )>!

winsdelln: anInt
    "I insert the number of blank lines given to me in my window above
    the current line and delete the same number of lines from the
    bottom. See the man(3) winsdelln entry for a description of my c
    function call."

    "int winsdelln (WINDOW *, int);"
    <cCall: 'winsdelln' returning: #int 
	args: #(#self #int )>!

winsertln
    "I insert a blank line in my window above the current line and
     delete the bottom line. See the man(3) winsertln entry for a
     description of my c function call."

    "int winsertln (WINDOW *);"
    <cCall: 'winsertln' returning: #int 
	args: #(#self )>!

winsnstr: aString n: anInt
    "I insert a string of at most n characters in my window before the
    location of the current cursor. The remaining characters in the
    line are shifted one position to the right. See the man(3)
    winsnstr entry for a description of my c function call."

    "int winsnstr (WINDOW *, const char *, int);"
    <cCall: 'winsnstr' returning: #int 
	args: #(#self #string #int )>!

winsstr: aString
    "I insert a string before the location of the cursor in my window.
    The remaining characters in the line are shifted one position to
    the right. See the man(3) winsstr entry for a description of my c
    function call."

    "int winsstr (WINDOW *, const char *);"
    <cCall: 'winsstr' returning: #int 
	args: #(#self #string )>!

winstr: aString
    "I return a string of characters from my window starting from the
    location of the cursor. See the man(3) mvwinstr for a description
    of my c function call."

    "int winstr (WINDOW *, char *);"
    <cCall: 'winstr' returning: #int 
	args: #(#self #string )>!

wmove: anInt1 x: anInt2
    "I move the cursor in my window to the position given to me. See
    the man(3) wmove entry for a description of my c function call."

    "int wmove (WINDOW *, int, int);"
    <cCall: 'wmove' returning: #int 
	args: #(#self #int #int )>!

wnoutrefresh
    "I update the virtual screen with the contents of my window. See
    the man(3) wnoutrefresh entry for a description of my c function
    call."

    "int wnoutrefresh (WINDOW *);"
    <cCall: 'wnoutrefresh' returning: #int 
	args: #(#self )>!

wprintw: aString 
    "I print a string in my window at the location of the cursor.  See
    the man(3) wprintw entry for a description of my c function call."

    "int wprintw (WINDOW *, const char *, ...)"
    <cCall: 'wprintw' returning: #int 
	args: #(#self #string )>!

wprintw: aString args: anArray
    "I print string and arguments in my window at the location of the
    cursor.  See the man(3) wprintw entry for a description of my c
    function call."

    "int wprintw (WINDOW *, const char *, ...)"
    <cCall: 'wprintw' returning: #int 
	args: #(#self #string #variadic)>!

wredrawln: anInt1 x: anInt2
    "I mark the lines given to me in window to be redrawn by the next
    refresh. See the man(3) wredrawln entry for a description for my c
    function call."

    "int wredrawln (WINDOW *, int, int);"
    <cCall: 'wredrawln' returning: #int 
	args: #(#self #int #int )>!

wrefresh
    "I copy my window to the physical screen. See the man(3) wrefresh
    entry for a description of my c function call."

    "int wrefresh (WINDOW *);"
    <cCall: 'wrefresh' returning: #int 
	args: #(#self )>!

wresize: anInt1 columns: anInt2
    "I adjust my window to the dimensions given to me. See the man(3)
    wresize entry for a description of my c function call."

    "int wresize (WINDOW *, int, int); "
    <cCall: 'wresize' returning: #int 
	args: #(#self #int #int)>!

wscanw: aString args: anArray
    "I scan a string from within my window at the location of the
    cursor See the man(3) mvwscanw entry for a description of my c
    function call."

    "int wscanw (WINDOW *, const char *, ...)"
    <cCall: 'wscanw' returning: #int 
	args: #(#self #string #variadic)>!

wscrl: anInt
    "I scroll up my window the number of lines given to me. See the
    man(3) wscrl entry for a description of my c function call."

    "int wscrl (WINDOW *, int);"
    <cCall: 'wscrl' returning: #int 
	args: #(#self #int )>!

wsetscrreg: anInt1 x: anInt2
    "I enable a scroll region within my window between the top and
    bottom lines given to me. See the man(3) wsetscrreg entry for a
    description of my c function call."

    "int wsetscrreg (WINDOW *, int, int);"
    <cCall: 'wsetscrreg' returning: #int 
	args: #(#self #int #int )>!

wstandend
    "I turn off all attributes in the window. See the man(3) wstandend
    entry for a description of my c function call."

    "int wstandend (WINDOW *);"
    <cCall: 'wstandend' returning: #int 
	args: #(#self )>!

wstandout
    "I turn on the best highlighting available in the window. See the
     man(3) wstandout entry for a description of my c function call."

    "int wstandout (WINDOW *);"
    <cCall: 'wstandout' returning: #int 
	args: #(#self )>!

wsyncdown
    "I mark the same lines in my window for refresh as the lines that
    have been marked for refresh in my ancestor windows. See the
    man(3) wsyncdown entry for a description of my c function call."

    "void wsyncdown (WINDOW *);"
    <cCall: 'wsyncdown' returning: #void 
	args: #(#self )>!

wsyncup
    "I mark the same lines in my ancestore windows for refresh as the
    lines that have been marked for refresh in my window. See the
    man(3) wsyncup entry for a description of my c function call."

    "void wsyncup (WINDOW *);"
    <cCall: 'wsyncup' returning: #void 
	args: #(#self )>!

wtimeout: anInt
    "I configure blocking and non-blocking reads in the window based
    on the value given to me. See the man(3) wtimeout entry for a
    description of my c function call."

    "void wtimeout (WINDOW *, int);"
    <cCall: 'wtimeout' returning: #void 
	args: #(#self #int )>!

wtouchln: anInt1 n: anInt2 changed: anInt3
    "I mark/unmark the number of lines in my window for refresh given
    to me. See the man(3) wtouchln for a description of my c function
    call."

    "int wtouchln (WINDOW *, int, int, int);"
    <cCall: 'wtouchln' returning: #int 
	args: #(#self #int #int #int )>!

wvline: aChar n: anInt
    "I write a vertical line of at most n characters comprised of the
    character given to me. See the man(3) wvline entry for a
    description of my c function call."

    "int wvline (WINDOW *, chtype, int);"
    <cCall: 'wvline' returning: #int 
	args: #(#self #char #int )>! !


!NCWindow class methodsFor: 'C call-outs'!


addch: aChar
    "I put the character given to me into my window at the current
     position, and then advance the current position. See the man(3)
     addch entry for a description of my c function call."

    "int addch (const chtype);"
    <cCall: 'addch' returning: #int
	args: #(#char )>!

addchnstr: aString n: anInt
    "I put at most n charaters of the character/attributes string
     given to me into my window starting at the current position, and
     then advance the current position. See the man(3) addchnstr entry
     for a description of my c function call."

    "int addchnstr (const chtype *, int);"
    <cCall: 'addchnstr' returning: #int
	args: #(#string #int )>!

addchstr: aString
    "I put the character/attributes in the string given to me into my
     window starting at the current position, and then advance the
     current position. See the man(3) addchstr entry for a description
     of my c function call."

    "int addchstr (const chtype *);"
    <cCall: 'addchstr' returning: #int
	args: #(#string )>!

addnstr: aString n: anInt
    "I put at most n characters in the string given to me into my
     window starting at the current position, and then advance the
     current position. See the man(3) addnstr entry for a description
     of my c function call."

    "int addnstr (const char *, int);"
    <cCall: 'addnstr' returning: #int
	args: #(#string #int )>!

addstr: aString
    "I put the characters in the string given to me into my window
     starting at the current position, and then advance the current
     position. See the man(3) addnstr entry for a description of my c
     function call."

    "int addstr (const char *);"
    <cCall: 'addstr' returning: #int
	args: #(#string )>!

assumeDefaultColors: anInt1 bg: anInt2
    "I change my windows default background and forground colors to
     the values given to me. See the man(3) assume_default_colors
     entry for a description of my c function call."

    "int assume_default_colors (int, int); "
    <cCall: 'assume_default_colors' returning: #int
	args: #(#int #int )>!

attrGet: cObject1 pair: cObject2 opts: cObject3
    "I retrieve attribute values for my window from a file.  See the
     man(3) attr_get entry for a description of my c function call."

    "int attr_get (attr_t *, short *, void *);"
    <cCall: 'attr_get' returning: #int
	args: #(#cObject #cObject #cObject )>!

attrOff: anInt opts: cObject
    "I turn off the named attribute given to me in my window.  See the
     man(3) attr_off for a description of my c function call."

    "int attr_off (attr_t, void *);"
    <cCall: 'attr_off' returning: #int
	args: #(#int #cObject )>!

attrOn: anInt opts: cObject
    "I turn on the named attribute given to me in my window.  See the
     man(3) attr_on for a description of my c function call."

    "int attr_on (attr_t, void *);"
    <cCall: 'attr_on' returning: #int
	args: #(#int #cObject )>!

attrSet: anInt1 pair: anInt2 opts: cObject
    "I set the attribute color-pair in my window to the value given to
     me. See the man(3) attr_set entry for a description of my c
     function call."

    "int attr_set (attr_t, short, void *);"
    <cCall: 'attr_set' returning: #int
	args: #(#int #int #cObject )>!

attroff: anInt
    "I turn off the named attribute given to me in my window.  See the
     man(3) attroff for a description of my c function call."

    "int attroff (NCURSES_ATTR_T);"
    <cCall: 'attroff' returning: #int
	args: #(#int )>!

attron: anInt
    "I turn on the named attribute given to me in my window.  See the
     man(3) attron for a description of my c function call."

    "int attron (NCURSES_ATTR_T);"
    <cCall: 'attron' returning: #int
	args: #(#int )>!

attrset: anInt
    "I set the attribute color-pair in my window to the value given to
     me. See the man(3) attrset entry for a description of my c
     function call."

    "int attrset (NCURSES_ATTR_T);"
    <cCall: 'attrset' returning: #int
	args: #(#int )>!

baudrate
    "I return the output speed of the terminal. See the man(3)
     baudrate entry for a description of my c function call."

    "int baudrate (void);"
    <cCall: 'baudrate' returning: #int
	args: #( )>!

beep
    "I ring the terminal alarm. See the man(3) beep entry for a
     description of my c function call."

    "int beep (void);"
    <cCall: 'beep' returning: #int
	args: #( )>!

bkgd: aChar
    "I set the background property of my window and apply it to every
     character in the window to the value given to me. See the man(3)
     bkgd entry for a description of my c function call."

    "int bkgd (chtype);"
    <cCall: 'bkgd' returning: #int
	args: #(#char )>!

bkgdset: aChar
    "I set the background property of the characters in my window to
     the value given to me. See the man(3) bkgdset entry for a
     description of my c function call."

    "void bkgdset (chtype);"
    <cCall: 'bkgdset' returning: #void
	args: #(#char )>!

border: aChar1 rs: aChar2 ts: aChar3 bs: aChar4 
    tl: aChar5 tr: aChar6 bl: aChar7 br: aChar8
    "I draw a border around the edges of my window using the character
     attributes given to me. See the man(3) border entry for a
     description of my c function call."

    "int border (chtype, chtype, chtype, chtype, chtype, chtype, chtype, chtype);"
    <cCall: 'border' returning: #int 
	args: #(#char #char #char #char #char #char #char #char )>!

canChangeColor
    "I return true if the terminal has color capabilities that can be
     changed. See the man(3) can_change_color entry for a description
     of my c function call."

    "bool can_change_color (void);"
    <cCall: 'can_change_color' returning: #boolean
	args: #( )>!

cbreak
    "I disable line buffering and erase/kill character processing.
     See the man(3) cbreak entry for a description of my c function
     call."

    "int cbreak (void);"
    <cCall: 'cbreak' returning: #int
	args: #( )>!

chgat: anInt1 attr: anInt2 color: anInt3 opts: cObject
    "I change up to n character attributes starting at the current
     position. See the man(3) chgat entry for a description for my c
     function calls."

    "int chgat (int, attr_t, short, const void *);"
    <cCall: 'chgat' returning: #int
	args: #(#int #int #int #cObject )>!

clear
    "I put a blank in every character position in my window and set up
    the window to be re-painted the next time that it is
    refreshed. See the man(3) clear entry for a description of my c
    function calls."

    "int clear (void);"
    <cCall: 'clear' returning: #int
	args: #( )>!

clrtobot
    "I erase the current screen from the right of the current
     cursor position all the way to the bottom right of the screen.
     See the man(3) clrtobot entry for a description of my c function
     call."

    "int clrtobot (void);"
    <cCall: 'clrtobot' returning: #int
	args: #( )>!

clrtoeol
    "I erase the current line in my window to the right of the current
     cursor location. See the man(3) clrtoeol entry for a description
     of my c function calls."

    "int clrtoeol (void);"
    <cCall: 'clrtoeol' returning: #int
	args: #( )>!

colorContent: anInt red: cObject1 green: cObject2 blue: cObject3
    "I extract the amount of RGB components in the color attribute
     given to me. See the man(3) color_content entry for a description
     of my c function call."

    "int color_content (short, short*, short*, short*);"
    <cCall: 'color_content' returning: #int 
	args: #(#int #cObject #cObject #cObject )>!

colorPair: anInt
    "I return the number of color pair attributes that my terminal can
     support. See the man(3) COLOR_PAIR entry for a description of my
     c function call."

    "int COLOR_PAIR (int)"
    <cCall: 'COLOR_PAIR' returning: #int
	args: #(#int )>!

colorSet: anInt opts: cObject
    "I set the current color of my window to the color pair attribute
     given to me. See the man(3) color_set entry for a description of
     my c function call."

    "int color_set (short, void*);"
    <cCall: 'color_set' returning: #int
	args: #(#int #cObject )>!

cursesVersion
    "I return the version number and patch level of my ncurses
     library.  See the man(3) curses_version entry for a description
     of my c function call."

    "(const char *) curses_version (void); "
    <cCall: 'curses_version' returning: #string
	args: #(#void )>!

cursSet: anInt
    "I set the cursor visibility in my window to the visibility given
     to me and then return the previous cursor state. See the man(3)
     curs_set entry for a description of my c function call."

    "int curs_set (int);"
    <cCall: 'curs_set' returning: #int
	args: #(#int )>!

defineKey: aString keycode: anInt
    "I define a keycode with its' corresponding control string. See
     the man(3) define_key entry for a description of my c function
     call."

    "int define_key (const char *, int); "
    <cCall: 'define_key' returning: #int
	args: #(#string #int )>! 

defProgMode
    "I save the current terminals program state. See the man(3)
     def_prog_mode entry for a description of my c function call."

    "int def_prog_mode (void);"
    <cCall: 'def_prog_mode' returning: #int
	args: #( )>!

defShellMode
    "I save the current terminals shell state. See the man(3)
     def_shell_mode entry for a description of my c function call."

    "int def_shell_mode (void);"
    <cCall: 'def_shell_mode' returning: #int
	args: #( )>!

delayOutput: anInt
    "I put padding characters into the output while I delay for the
     number of milli-seconds given to me. See the man(3) delay_output
     for a description of my c function call."

    "int delay_output (int);"
    <cCall: 'delay_output' returning: #int
	args: #(#int )>!

delch
    "I delete the character underneath the current cursor position and
     then shift the characters to the right of the cursor one position
     to the left. See the man(3) delch entry for a description of my c
     function call."

    "int delch (void);"
    <cCall: 'delch' returning: #int
	args: #( )>!

deleteln
    "I delete the line under the current cursor position, move all of
     the lines below the cursor up one line and clear the last
     line. See the man(3) deleteln entry for a description of my c
     function call."

    "int deleteln (void);"
    <cCall: 'deleteln' returning: #int
	args: #( )>!

doupdate
    "I transmit the difference between the virtual screen and the
     physcial screen to the physical screen. See the man(3) doupdate
     entry for a description of my c function call."

    "int doupdate (void);"
    <cCall: 'doupdate' returning: #int
	args: #( )>!

echo
    "I turn on the echoing of characters by getch to the screen as
     they are typed. See the man(3) echo entry for a description of my
     c function call."

    "int echo (void);"
    <cCall: 'echo' returning: #int
	args: #( )>!

echochar: aChar
    "I put the character given to me at the current cursor position,
     advance the cursor, and then refresh the screen. See the man(3)
     echochar entry for a description of my c function call."

    "int echochar (const chtype);"
    <cCall: 'echochar' returning: #int
	args: #(#char )>!

endwin
    "I restore the tty mode, position the cursor to the lower
     left-hand corner of the screen and reset the terminal into the
     proper non-visual mode. See the man(3) endwin entry for a
     description of my c function call."

    "int endwin (void);"
    <cCall: 'endwin' returning: #int
	args: #( )>!

erase
    "I put blanks into every position in the screen. See the man(3)
     erase entry for a description of my c function call."

    "int erase (void);"
    <cCall: 'erase' returning: #int
	args: #( )>!

erasechar
    "I return the current character. See the man(3) erasechar for a
     description of my c function."

    "char erasechar (void);"
    <cCall: 'erasechar' returning: #int
	args: #( )>!

filter
    "I restrict terminal input and output to a single line. See the
     man(3) filter entry for a description of my c function."

    "void filter (void);"
    <cCall: 'filter' returning: #void
	args: #( )>!

flash
    "I flash the terminal. See the man(3) entry for a description of
     my c function call."

    "int flash (void);"
    <cCall: 'flash' returning: #int
	args: #( )>!

flushinp
    "I discard any unprocessed keystrokes. See the man(3) entry for a
     description of my c function call."

    "int flushinp (void);"
    <cCall: 'flushinp' returning: #int
	args: #( )>!

getch
    "I read a keystroke from my window. See the man(3) getch entry for
     a description of my c function call."

    "int getch (void);"
    <cCall: 'getch' returning: #int
	args: #( )>!

getnstr: aString n: anInt
    "I read at most n keystrokes from the stdscr window until a return
     or linefeed key is pressed. See the man(3) getnstr entry for a
     description of my c function call."

    "int getnstr (char *, int);"
    <cCall: 'getnstr' returning: #int
	args: #(#string #int )>!

getstr: aString
    "I read keystrokes from the stdscr window until a return or
     linefeed key is pressed. See the man(3) getstr entry for a
     description of my c function call."

    "int getstr (char *);"
    <cCall: 'getstr' returning: #int
	args: #(#string )>!

halfdelay: anInt
    "I return either a character or an error if a key is not pressed
     within the number of 10ths of seconds given to me.  See the
     man(3) halfdelay entry for a description of my c function call."

    "int halfdelay (int);"
    <cCall: 'halfdelay' returning: #int
	args: #(#int )>!

hasColors
    "I return true if my terminal supports colors. See the man(3)
     has_colors entry for a description of my c function call."

    "bool has_colors (void);"
    <cCall: 'has_colors' returning: #boolean
	args: #( )>!

hasIc
    "I return true if my terminal has insert/delete character
     capabilities. See the man(3) has_ic entry for a description of my
     c function call."

    "bool has_ic (void);"
    <cCall: 'has_ic' returning: #boolean
	args: #( )>!

hasIl
    "I return true if my terminal has insert/delete line
     capabilities. See the man(3) has_ic entry for a description of my
     c function call."

    "bool has_il (void);"
    <cCall: 'has_il' returning: #boolean
	args: #( )>!

hline: aChar n: anInt
    "I draw a horizontal line in the terminal using the character
     given to me of at most n characters. See the man(3) hline entry
     for a description of my c function call."

    "int hline (chtype, int);"
    <cCall: 'hline' returning: #int
	args: #(#char #int )>!

inch
    "I return the character/attribute at the current cursor position
     in the terminal. See the man(3) inch entry for a description of
     my c function call."

    "chtype inch (void);"
    <cCall: 'inch' returning: #char 
	args: #( )>!

inchnstr: aString n: anInt
    "I return the character/attribute string of at most n characters
     at the current cursor position in the terminal. See the man(3)
     inchnstr entry for a description of my c function call."

    "int inchnstr (chtype *, int);"
    <cCall: 'inchnstr' returning: #int
	args: #(#string #int )>!

inchstr: aString
    "I return the character/attribute string of characters at the
     current cursor position in the terminal. See the man(3) inchstr
     entry for a description of my c function call."

    "int inchstr (chtype *);"
    <cCall: 'inchstr' returning: #int
	args: #(#string )>!

initColor: anInt1 red: anInt2 green: anInt3 blue: anInt4
    "I change the definition of a color. See the man(3) init_color
     entry for a description of my c function call."

    "int init_color (short, short, short, short);"
    <cCall: 'init_color' returning: #int
	args: #(#int #int #int #int )>!

initPair: anInt1 f: anInt2 b: anInt3
    "I initialize a color pair. See the man(3) init_pair for a
     description of my c function call."

    "int init_pair (short, short, short);"
    <cCall: 'init_pair' returning: #int
	args: #(#int #int #int )>!

initscr
    "WINDOW *initscr (void);"
    ^StdScreen := self primInitScr!

innstr: aString n: anInt
    "I extract up to n characters into a string starting at the
     current curor position in the terminal. See the man(3) innstr
     entry for a description of my c function call."

    "int innstr (char *, int);"
    <cCall: 'innstr' returning: #int
	args: #(#string #int )>!

insch: aChar
    "I put the character given to me in the terminal at the current
     cursor position and shift the remaining characters in the line
     one position to the right. See the man(3) insch entry for a
     description of my c function call."

    "int insch (chtype);"
    <cCall: 'insch' returning: #int
	args: #(#char )>!

insdelln: anInt
    "I insert the number of blank lines given to me above the current
     line and delete the same number of lines from the bottom. See the
     man(3) insdelln entry for a description of my c function call."

    "int insdelln (int);"
    <cCall: 'insdelln' returning: #int
	args: #(#int )>!

insertln
    "I insert a blank line in the terminal above the current line and
     delete the bottom line. See the man(3) insertln entry for a
     description of my c function call."

    "int insertln (void);"
    <cCall: 'insertln' returning: #int
	args: #( )>!

insnstr: aString n: anInt
    "I insert at most n characters in the string given to me into the
     terminal starting at the one character before current cursor
     position. The remaining characters in the line are shifted to the
     right. See the man(3) insnstr entry for a description of my c
     function call."

    "int insnstr (const char *, int);"
    <cCall: 'insnstr' returning: #int
	args: #(#string #int )>!

insstr: aString
    "I insert the characters in the string given to me into the
     terminal starting at the one character before current cursor
     position. The remaining characters in the line are shifted to the
     right. See the man(3) insstr entry for a description of my c
     function call."

    "int insstr (const char *);"
    <cCall: 'insstr' returning: #int
	args: #(#string )>!

instr: aString
    "I return the string of characters in the terminal starting at the
     current cursor position. See the man(3) instr entry for a
     description of my c function call."

    "int instr (char *);"
    <cCall: 'instr' returning: #int
	args: #(#string )>!

isendwin
    "I return true if a refresh message has not been sent since an
     endwin message was sent. Otherwise, I return false. See the
     man(3) isendwin entry for a description of my c function call."

    "bool isendwin (void);"
    <cCall: 'isendwin' returning: #boolean
	args: #( )>!

isTermResized: anInt1 columns: anInt2
    "I return true if the resizeTerm:columns: message was sent, it
     would change the terminal structures. Otherwise, I return false.
     See the man(3) is_term_resized entry for a description of my c
     function call."

    "bool is_term_resized (int, int); "
    <cCall: 'is_term_resized' returning: #char 
	args: #(#int #int )>!

keybound: int1 count: int2
    "I return the string defined in terminfo for the number of entries
     given to me starting with the keycode given to me. See the man(3)
     keybound entry for a description of my c function call."

    "char *keybound (int, int); "
    <cCall: 'keybound' returning: #string
	args: #(#int #int )>!

keyDefined: aString
    "I return the keycode for the string given to me if it exists.  I
     return 0 if there is no match, and I return -1 if the string is a
     substring of more than one string in keycode/string
     associations. See the man(3) key_defined entry for a description
     of my c function call."

    "int key_defined (const char *); "
    <cCall: 'key_defined' returning: #int
	args: #(#string)>!

keyname: anInt
    "I return a string corresponding to the key given to me. See the
     man(3) keyname entry for a description of my c function call."

    "const char *keyname (int);"
    <cCall: 'keyname' returning: #string
	args: #(#int )>!

keyok: anInt enabled: aBool
    "I enable or disable the keycode given to me. See the man(3) keyok
     entry for a description of my c function call."

    "int keyok (int, bool); "
    <cCall: 'keyok' returning: #int
	args: #(#int #boolean)>!

killchar
    "I return the line kill character. See the man(3) killchar entry
     for a description of my c function call."

    "char killchar (void);"
    <cCall: 'killchar' returning: #char
	args: #( )>!

longname
    "I return a string with a verbose description of the current
     terminal. See the man(3) longname entry for a description of my c
     function call."

    "char *longname (void);"
    <cCall: 'longname' returning: #string
	args: #( )>!

move: anInt1 x: anInt2
    "I move the cursor in the terminal to the position given to
     me. See the man(3) move entry for a description of my c function
     call."

    "int move (int, int);"
    <cCall: 'move' returning: #int
	args: #(#int #int )>!

mvaddch: anInt1 x: anInt2 ch: aChar
    "I add a character to the terminal at the current cursor location
     and then advance the cursor to the coordinates given to me. See
     the man(3) mvaddch entry for a description of my c function
     call."
    "int mvaddch (int, int, const chtype);"
    <cCall: 'mvaddch' returning: #int
	args: #(#int #int #char )>!

mvaddchstr: anInt1 x: anInt2 str: aString
    "I copy the characters and attributes of the string given to me
     into the terinal starting at the location specified by the
     coordinates given to me. See the man(3) mvwaddchstr entry for a
     description of my c function call."

    "int mvaddchstr (int, int, const chtype *);"
    <cCall: 'mvaddchstr' returning: #int
	args: #(#int #int #string )>!

mvaddchnstr: anInt1 x: anInt2 str: aString n: anInt3
    "I copy up to n characters and attributes of the string given to
     me into the terinal starting at the location specified by the
     coordinates given to me. See the man(3) mvwaddchnstr entry for a
     description of my c function call."

    "int mvaddchnstr (int, int, const chtype *, int);"
    <cCall: 'mvaddchnstr' returning: #int
	args: #(#int #int #string #int )>!

mvaddnstr: anInt1 x: anInt2 str: aString n: anInt3
    "I copy up to n characters of the string given to me to the
     terminal starting at the location specified by the coordinates
     given to me.  See the man(3) mvaddnstr entry for a description of
     my c function call."

    "int mvaddnstr (int, int, const char *, int);"
    <cCall: 'mvaddnstr' returning: #int
	args: #(#int #int #string #int )>!

mvaddstr: anInt1 x: anInt2 str: aString
    "I copy the string given to me to the terminal starting at the
     location specified by the coordinates given to me. See the man(3)
     mvaddnstr entry for a description of my c function call."

    "int mvaddstr (int, int, const char *);"
    <cCall: 'mvaddstr' returning: #int
	args: #(#int #int #string )>!

mvchgat: anInt1 x: anInt2 n: anInt3 attr: anInt4 color: anInt5 opts: cObject
    "I change the color and attribute of next n characters in the
     terminal starting at the location specified by the coordinates
     given to me. See the man(3) mvwchgat entry for a description of
     my c function call."

    "int mvchgat (int, int, int, attr_t, short, const void *);"
    <cCall: 'mvchgat' returning: #int
	args: #(#int #int #int #int #int #cObject )>!

mvcur: anInt1 oldCol: anInt2 newRow: anInt3 newCol: anInt4
    "I move the cursor immediately in the terminal from the old row
     and column to the new row and column given to me. See the man(3)
     mvcur entry for a description of my c function call."

    "int mvcur (int, int, int, int);"
    <cCall: 'mvcur' returning: #int 
	args: #(#int #int #int #int )>!

mvdelch: anInt1 x: anInt2 
    "I move the cursor to the coordinates given to me in the terminal,
    delete the character under the cursor, and then shift the
    remaining characters in the line one position to the left. See the
    man(3) mvwdelch entry for description of my c function call."

    "int mvdelch (int, int);"
    <cCall: 'mvdelch' returning: #int
	args: #(#int #int )>!

mvgetch: anInt1 x: anInt2
    "I position the cursor to the location in the terminal specified
     by the coordinates given to me, I read a character. See the
     man(3) mvgetch entry for a description of my c function call."

    "int mvgetch (int, int);"
    <cCall: 'mvgetch' returning: #int
	args: #(#int #int )>!

mvgetnstr: anInt1 x: anInt2 str: aString n: anInt3
    "I position the cursor to the location in my window specified by
     the coordinates given to me, and then I read at most n characters
     until a carriage return or newline is pressed. See the man(3)
     mvgetnstr entry for a description of my c function call."

    "int mvgetnstr (int, int, char *, int);"
    <cCall: 'mvgetnstr' returning: #int
	args: #(#int #int #string #int )>!

mvgetstr: anInt1 x: anInt2 str: aString
    "I position the cursor to the location in the terminal specified
     by the coordinates given to me, and thenI read characters until a
     carriage return or a newline is pressed. See man(3) mvgetstr
     entry for a description of my c function call."

    "int mvgetstr (int, int, char *);"
    <cCall: 'mvgetstr' returning: #int
	args: #(#int #int #string )>!

mvhline: anInt1 x: anInt2 ch: aChar n: anInt3
    "I position the cursor to the location in the terminal specified
     by the coordinates given to me, and then I write a horizontal
     line of at most n characters comprised of the character given to
     me.  See the man(3) mvhline entry for a description of my c
     function call."

    "int mvhline (int, int, chtype, int);"
    <cCall: 'mvhline' returning: #int
	args: #(#int #int #char #int )>!

mvinch: anInt1 x: anInt2
    "I return the character or attribute at the cursor location
     specifed by the coordinates given to me. See the man(3) mvinch
     entry for a description of my c call function."

    "chtype mvinch (int, int);"
    <cCall: 'mvinch' returning: #char
	args: #(#int #int )>!

mvinchnstr: anInt1 x: anInt2 str: aString n: anInt3
    "I return a null terminated array of characters or attributes from
     the terminal of at most n characters starting at the cursor
     location specified by the coordinates given to me. See the man(3)
     mvinchnstr entry for a description of my c function call."

    "int mvinchnstr (int, int, chtype *, int);"
    <cCall: 'mvinchnstr' returning: #int
	args: #(#int #int #string #int )>!

mvinchstr: anInt1 x: anInt2 str: aString
    "I return a null terminated array of characters or attributes from
     within the terminal starting at the cursor location given by the
     coordinates given to me. See the man(3) mvinchstr entry for a
     description of my c call function."

    "int mvinchstr (int, int, chtype *);"
    <cCall: 'mvinchstr' returning: #int
	args: #(#int #int #string )>!

mvinnstr: anInt1 x: anInt2 str: aString n: anInt3 
    "I return a string of characters from the termimal stripped of
    attributes starting at the location given to me as
    coordinates. See the man(3) mvinnstr entry for a description of
    my c function call."

    "int mvinnstr (int, int, char *, int);"
    <cCall: 'mvinnstr' returning: #int
	args: #(#int #int #string #int )>!

mvinsch: anInt1 x: anInt2 ch: aChar
    "I insert a character in the terminal before the location given to
     me as coordinates. The remaining characters in the line are
     shifted one position to the right. See the man(3) mvwinsch entry
     for a description of my c function call."

    "int mvinsch (int, int, chtype);"
    <cCall: 'mvinsch' returning: #int
	args: #(#int #int #char )>!

mvinsnstr: anInt1 x: anInt2 str: aString n: anInt3
    "I insert a string of at most n characters in the terminal before
     the location given to me as coordinates. The remaining characters
     in the line are shifted one position to the right. See the man(3)
     mvinsnstr entry for a description of my c function call."

    "int mvinsnstr (int, int, const char *, int);"
    <cCall: 'mvinsnstr' returning: #int
	args: #(#int #int #string #int )>!

mvinsstr: anInt1 x: anInt2 str: aString
    "I insert a string before the location in the terminal given to me
     as coordinates.  The remaining characters in the line are shifted
     one position to the right. See the man(3) mvinsstr entry for a
     description of my c function call."

    "int mvinsstr (int, int, const char *);"
    <cCall: 'mvinsstr' returning: #int
	args: #(#int #int #string )>!

mvinstr: anInt1 x: anInt2 str: aString
    "I return a string of characters from the terminal starting from the
     location given to me as coordinates. See the man(3) mvinstr for a
     description of my c function call."

    "int mvinstr (int, int, char *);"
    <cCall: 'mvinstr' returning: #int
	args: #(#int #int #string )>!

mvprintw: anInt1 x: anInt2 str: aString
    "I print a formated string in the terminal at the location given
     to me as coordinates.  See the man(3) mvprintw entry for a
     description of my c function call."

    "int mvprintw (int, int, const char *, ...)"
    <cCall: 'mvprintw' returning: #int
	args: #(#int #int #string)>!

mvprintw: anInt1 x: anInt2 str: aString args: anArray
    "I print a formated string and arguments in the terminal at the
     location given to me as coordinates.  See the man(3) mvprintw
     entry for a description of my c function call."

    "int mvprintw (int, int, const char *, ...)"
    <cCall: 'mvprintw' returning: #int
	args: #(#int #int #string #variadic)>!

mvscanw: anInt1 x: anInt2 str: aString args: anArray
    "I scan a string from within the terminal at the location given to
     me as coordinates. See the man(3) mvscanw entry for a description
     of my c function call."

    "int mvscanw (int, int, const char *, ...)"
    <cCall: 'mvscanw' returning: #int
	args: #(#int #int #string #variadic)>!

mvvline: anInt1 x: anInt2 ch: aChar n: anInt3
    "I position the cursor to the location in the terminal specified
     by the coordinates given to me, and then write a vertical line of
     at most n characters comprised of the character given to me.  See
     the man(3) mvvline entry for a description of my c function
     call."

    "int mvvline (int, int, chtype, int);"
    <cCall: 'mvvline' returning: #int
	args: #(#int #int #char #int )>!

napms: anInt
    "I sleep for the number of milliseconds given to me. See the
     man(3) napms entry for a description of my c function call."

    "int napms (int);"
    <cCall: 'napms' returning: #int
	args: #(#int )>!
"
Not implemtented
newterm: aString outfd: cObject1 infd: cObject2
    SCREEN *newterm (const char *, FILE *, FILE *);
    <cCall: 'newterm' returning: #cObject args: #(#string #cObject #cObject )>!
"

newpad: anInt1 ncols: anInt2
    "I create a new specialized instance of a window. My size is
     specified by the number of rows and columns given to me. See the
     man(3) newpad entry for a description of my c function call."

    "WINDOW *newpad (int, int);"
    <cCall: 'newpad' returning: NCWindow type
	args: #(#int #int )>!

newwin: anInt1 cols: anInt2 beginY: anInt3 beginX: anInt4
    "I create a new window structure at the location given to me as
     coordinates.  My size is specified by the number of rows and
     columns given to me.  See the man(3) newwin entry for a
     description of my c function call."

    "WINDOW *newwin (int, int, int, int);"
    <cCall: 'newwin' returning: NCWindow type
	args: #(#int #int #int #int )>!

nl
    "I tell the display device to display newline on input and
     newline/return on output. See the man(3) nl entry for a
     description of my c function call."

    "int nl (void);"
    <cCall: 'nl' returning: #int
	args: #( )>!

nocbreak
    "I tell the tty driver to enable line buffering and to process
     erase and kill characters. See the man(3) nocbreak entry for a
     description of my c function call."

    "int nocbreak (void);"
    <cCall: 'nocbreak' returning: #int
	args: #( )>!

noecho
    "I disable getch from echoing characters as they are typed. See
     the man(3) noecho entry for a description of my c function call."

    "int noecho (void);"
    <cCall: 'noecho' returning: #int 
	args: #( )>!

nonl
    "I tell the display device to no display newline on input or
     newline/return on output. See the man(3) nonl entry for a
     description of my c function call."

    "int nonl (void);"
    <cCall: 'nonl' returning: #int
	args: #( )>!

noqiflush
    "I turn off termio input and output queue interrupt flushing. See
     the man(3) noqiflush entry for a description of my c function
     call."

    "void noqiflush (void);"
    <cCall: 'noqiflush' returning: #void
	args: #( )>!

noraw
    "I set the terminal to the non-raw mode. See the man(3) noraw
     entry for a decription of my c function call."

    "int noraw (void);"
    <cCall: 'noraw' returning: #int
	args: #( )>!

pairContent: anInt f: cObject1 b: cObject2
    "I map a color-pair number into it's foreground and background
     color components. See the man(3) pair_content entry for a
     description of my c function call."

    "int pair_content (short, short*, short*);"
    <cCall: 'pair_content' returning: #int
	args: #(#int #cObject #cObject )>!

pairNumber: anInt
    "I return the color pair number associate with the pair attribute
     given to me. See the man(3) PAIR_NUMBER entry for a description
     of my c function call."

    "int PAIR_NUMBER (int);"
    <cCall: 'PAIR_NUMBER' returning: #int
	args: #(#int )>!

primInitScr
    "WINDOW *initscr (void);"
    <cCall: 'initscr' returning: NCWindow type 
	args: #( )>!

printw: aString 
    "I display formatted output. See then man(3) printw entry for a
     description of my c function call."

    "int printw (const char *, ...)"
    <cCall: 'printw' returning: #int
	args: #(#string )>!

printw: aString args: anArray
    "I display formatted output given a string and arguments. See then
     man(3) printw entry for a description of my c function call."

    "int printw (const char *, ...)"
    <cCall: 'printw' returning: #int
	args: #(#string #variadic)>!

putp: aString
    "I am a lowlevel print routine used to interface with the terminfo
     database. See the man(3) putp entry for a description of my c
     function call."

    "int putp (const char *);"
    <cCall: 'putp' returning: #int
	args: #(#string )>!

"
Not Implemented
putwin: cObject1 outfd: cObject2
    int putwin (WINDOW *, FILE *);
    <cCall: 'putwin' returning: #int args: #(#cObject #cObject )>!
"

qiflush
    "I turn on termio input and output queue interrupt flushing. See
     the man(3) qiflush entry for a description of my c function
     call."

    "void qiflush (void);"
    <cCall: 'qiflush' returning: #void
	args: #( )>!

raw
    "I put the terminal in raw input mode. See the man(3) entry for a
     description of my c function call."

    "int raw (void);"
    <cCall: 'raw' returning: #int
	args: #( )>!

refresh
    "I physically move the contents of stdscr to the physical screen.
     See then man(3) refresh entry for a description of my c function
     call."

    "int refresh (void);"
    <cCall: 'refresh' returning: #int
	args: #( )>!

resetProgMode
    "I restore the terminal to the 'program' state. See the man(3)
     reset_prog_mode entry for a description of my c function call."

    "int reset_prog_mode (void);"
    <cCall: 'reset_prog_mode' returning: #int
	args: #( )>!

resetShellMode
    "I restore the terminal to the 'shell' state. See the man(3)
     reset_shell_mode entry for a description of my c function call."

    "int reset_shell_mode (void);"
    <cCall: 'reset_shell_mode' returning: #int
	args: #( )>!

resetty
    "I restore the state of the terminal modes to the state saved by the
     last savetty message. See the man(3) resetty entry for a description
     of my c function call."

    "int resetty (void);"
    <cCall: 'resetty' returning: #int
	args: #( )>!

resizeTerm: anInt1 columns: anInt2
    "I resize the current and the standard windows to the number of
     rows and columns given to me. See the man(3) resizeterm entry for
     a description of my c function call."

    "int resizeterm (int, int); "
    <cCall: 'resizeterm' returning: #int
	args: #(#int #int )>!

savetty
    "I save the state of the terminal modes. See the man(3) savetty
     entry for a description of my c function call."

    "int savetty (void);"
    <cCall: 'savetty' returning: #int 
	args: #( )>!

scanw: aString args: anArray
    "I scan an input string. See the man(3) scanw entry for a
     description of my c function call."

    "int scanw (const char *, ...)"
    <cCall: 'scanw' returning: #int
	args: #(#string #variadic )>!

scrDump: aString
    "I dump the contents of the virtual screen to a file. See the
     man(3) scr_dump entry for a description of my c function call."

    "int scr_dump (const char *);"
    <cCall: 'scr_dump' returning: #int
	args: #(#string )>!

scrInit: aString
    "I initialize the cursors structures based on the contents of a
     file. See the man(3) scr_init entry for a description of my c
     function call."

    "int scr_init (const char *);"
    <cCall: 'scr_init' returning: #int
	args: #(#string )>!

scrRestore: aString
    "I load the contents of a file previously saved by the scr_dump
     into the virtual screen. See the man(3) scr_restore entry for a
     description of my c function call."

    "int scr_restore (const char *);"
    <cCall: 'scr_restore' returning: #int
	args: #(#string )>!

scrSet: aString
    "I load the contents of a file and perform a combination of
     scr_init and scr_restore operations. See the man(3) scr_set entry
     for a description of my c function call."

    "int scr_set (const char *);"
    <cCall: 'scr_set' returning: #int
	args: #(#string )>!

scrl: anInt
    "I scroll up the terminal the number of lines given to me. See the
     man(3) scrl entry for a description of my c function call."

    "int scrl (int);"
    <cCall: 'scrl' returning: #int
	args: #(#int )>!

setTerm: cObject
    "I switch between different terminals. See the man(3) set_term
     entry for a description of my c function call."

    "SCREEN *set_term (SCREEN *);"
    <cCall: 'set_term' returning: #cObject
	args: #(#cObject )>!

setscrreg: anInt1 bot: anInt2
    "I enable a scroll region within a window between the top and
     bottom lines given to me. See the man(3) setscrreg entry for a
     description of my c function call."

    "int setscrreg (int, int);"
    <cCall: 'setscrreg' returning: #int
	args: #(#int #int )>!

slkAttr
    "I return the attribute used for the softkeys. See the man(3)
     slk_attr entyr for a description of the c function call."

    "attr_t slk_attr (void);"
    <cCall: 'slk_attr' returning: #int
	args: #( )>!

slkAttrSet: anInt1 colorPair: anInt2 opts: cObject
    "I set the attribute color-pair for the soft keys to the value
    given to me. See the man(3) slk_attr_set entry for a description
    of my c function call."

    "int slk_attr_set (const attr_t, short, void*);"
    <cCall: 'slk_attr_set' returning: #int
	args: #(#int #int #cObject )>!

slkAttroff: aChar
    "I turn off the named attribute given to me for the soft keys.
    See the man(3) slk_attr_off for a description of my c function
    call."

    "int slk_attroff (const chtype);"
    <cCall: 'slk_attroff' returning: #int
	args: #(#char )>!

slkAttron: aChar
    "I turn on the named attribute given to me for the soft keys.  See
    the man(3) slk_attr_on for a description of my c function call."

    "int slk_attron (const chtype);"
    <cCall: 'slk_attron' returning: #int
	args: #(#char )>!

slkAttrset: aChar
    "I set the attribute color-pair for the soft keys to the value
    given to me. See the man(3) slk_attrset entry for a description of
    my c function call."

    "int slk_attrset (const chtype);"
    <cCall: 'slk_attrset' returning: #int
	args: #(#char )>!

slkClear
    "I clear the soft labels from the screen. See the man(3) slk_attr
    entry for a description of my c function call."

    "int slk_clear (void);"
    <cCall: 'slk_clear' returning: #int
	args: #( )>!

slkColor: anInt
    "I set the current color of the soft keys to the color pair
    attribute given to me. See the man(3) slk_color entry for a
    description of my c function call."

    "int slk_color (short);"
    <cCall: 'slk_color' returning: #int
	args: #(#int )>!

slkInit: anInt
    "I establish the format of the soft key label presentation using
    the value given to me. See the man(3) slk_init entry for a
    description of my c function call."

    "int slk_init (int);"
    <cCall: 'slk_init' returning: #int
	args: #(#int )>!

slkLabel:  anInt
    "I return the label text for the label number given to me. See the
    man(3) slk_label entry for a description of my c function call."

    "char *slk_label (int);"
    <cCall: 'slk_label' returning: #string
	args: #(#int )>!

slkNoutrefresh
    "I commit the differences between the soft labels in the virtual
    screen and the physical screen to the physical screen. See the
    man(3)slk_noutrefresh entry for a description of my c function
    call."

    "int slk_noutrefresh (void);"
    <cCall: 'slk_noutrefresh' returning: #int
	args: #( )>!

slkRefresh
    "I commit the soft labels in the virtual screen to the physical
    screen. See the man(3)slk_refresh entry for a description of my c
    function call."

    "int slk_refresh (void);"
    <cCall: 'slk_refresh' returning: #int
	args: #( )>!

slkRestore
    "I restore the labels to the screen after a slk_clear. See the
    man(3) entry for description of my c function call."

    "int slk_restore (void);"
    <cCall: 'slk_restore' returning: #int
	args: #( )>!

slkSet: anInt1 label: aString format: anInt2
    "I set the label text for the label number given to me using the
    format given to me. See the man(3) slk_set entry for a description
    of my c function call."

    "int slk_set (int, const char *, int);"
    <cCall: 'slk_set' returning: #int 
	args: #(#int #string #int )>!

slkTouch
    "I cause all of the soft labels in the virtual screen to be
    commited to the physical screen the next time a slk_noutrefresh is
    sent. See the man(3) slk_touch entry for a description of my c
    function call."

    "int slk_touch (void);"
    <cCall: 'slk_touch' returning: #int
	args: #( )>!

standend
    "I turn off all attributes in the screen. See the man(3) standend
    entry for a description of my c function call."

    "int standend (void);"
    <cCall: 'standend' returning: #int
	args: #( )>!

standout
    "I turn on the best highlighting available in the screen. See the
     man(3) standout entry for a description of my c function call."

    "int standout (void);"
    <cCall: 'standout' returning: #int
	args: #( )>!

startColor
    "I intitialize the color table. See the man(3) start_color entry for
     a description of my c function call."

    "int start_color (void);"
    <cCall: 'start_color' returning: #int
	args: #( )>!
stdscr
    "WINDOW *stdscr;"
    ^StdScreen!

termattrs
    "I return the logical OR of the attributes supported by my
    terminal.  See the man(3) termattrs entry for a description of my
    c function call."

    "chtype termattrs (void);"
    <cCall: 'termattrs' returning: #char 
	args: #( )>!

termname
    "I return the terminal name used by setupterm. See the man(3)
    termname entry for a description of my c function call."

    "char *termname (void);"
    <cCall: 'termname' returning: #string 
	args: #( )>!

tigetflag: aString
    "I return the compatibillity corresponding to the terminfo capinfo
    given to me. See the man(3) tigetflag entry for a description of
    my c function call."

    "int tigetflag (const char *);"
    <cCall: 'tigetflag' returning: #int 
	args: #(#string )>!

tigetnum: aString
    "I return the compatibillity corresponding to the terminfo capinfo
    given to me. See the man(3) tigetnum entry for a description of my
    c function call."

    "int tigetnum (const char *);"
    <cCall: 'tigetnum' returning: #int 
	args: #(#string )>!

tigetstr: aString
    "I return the compatibillity corresponding to the terminfo capinfo
    given to me. See the man(3) tigetstr entry for a description of my
    c function call."

    "char *tigetstr (const char *);"
    <cCall: 'tigetstr' returning: #string 
	args: #(#string )>!

timeout: anInt
    "I configure blocking and non-blocking reads in the terminal based
    on the value given to me. See the man(3) timeout entry for a
    description of my c function call."

    "void timeout (int);"
    <cCall: 'timeout' returning: #void 
	args: #(#int )>!

tparm: aString 
    "I instantiate the string given to me with the arguments given to
    me.  See the man(3) tparm entry for a description of my c function
    call."

    "char *tparm (const char *, ...);"
    <cCall: 'tparm' returning: #int
	args: #(#string )>!

tparm: aString args: anArray
    "I instantiate the string given to me with the arguments given to
    me.  See the man(3) tparm entry for a description of my c function
    call."

    "char *tparm (const char *, ...);"
    <cCall: 'tparm' returning: #int 
	args: #(#string #variadic)>!

typeahead: anInt
    "I set typeahead fd to be checked to the fd given to me. See the
    man(3) typeahead entry for a description of my c function calls."

    "int typeahead (int);"
    <cCall: 'typeahead' returning: #int 
	args: #(#int )>!

ungetch: anInt
    "I push the character given to me back onto the input stream to be
    re-read. See the man(3) ungetc entry for a description of my c
    function call."

    "int ungetch (int);"
    <cCall: 'ungetch' returning: #int 
	args: #(#int )>!

useDefaultColors
    "I tell the ncurses library to use the default background and
    foreground colors. See the man(3) use_default_colors entry for a
    description of my c function call."

    "int use_default_colors (void); "
    <cCall: 'use_default_colors' returning: #int 
	args: #( )>!

useEnv: aBoolean
    "I cause the number of columns and rows to be used in the window
    to be determined by the value of environment variables if I am
    given the boolean value true. See the man(3) use_env entry for a
    description of my c function call."

    "void use_env (bool);" 
    <cCall: 'use_env' returning: #void 
	args: #(#boolean )>!

useExtendedNames: aBoolean
    "I enable using user-defined terminfo names if I am given the
    boolean value true.  See the man(3) use_extended_names entry for a
    description for a description of my c function call."

    "int use_extended_names (bool); "
    <cCall: 'use_extended_names' returning: #int 
	args: #(#boolean )>!

vidattr: aChar
    "I display a string in the terminal using the attribute given to
    me. See the man(3) vidattr entry for a description of my c
    function call."

    "int vidattr (chtype);" 
    <cCall: 'vidattr' returning: #int 
	args: #(#char )>!

vline: aChar n: anInt
    "I write a vertical line of at most n characters comprised of the
    character given to me in the terminal. See the man(3) vline entry
    for a description of my c function call."

    "int vline (chtype, int);" 
    <cCall: 'vline' returning: #int 
	args: #(#char #int )>!

!NCWindow class methodsFor: 'examples'!

clock
    | screen |

    self
	initscr;
	noecho;
	cbreak;
	refresh.
    screen := self newwin: 13 cols: 27 beginY: 1 beginX: 1.
    screen nodelay: true.
    [ screen wgetch = $q asInteger ] whileFalse: [
	screen
	    mvwprintw: 3 x: 6 str: Date today printString;
	    mvwprintw: 5 x: 6 str: Time now printString;
	    wrefresh.
	(Delay forSeconds: 1) wait ].
    self endwin!

helloWorld
    self
	initscr;
	printw: 'hello world';
	refresh;
	getch;
	endwin! !
