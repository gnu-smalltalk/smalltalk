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



CStruct subclass: NCWindow [
    
    <category: 'NCurses Wrapper'>
    <comment: nil>
    <declaration: #(#(#curY #short ) #(#curX #short ) #(#maxY #short ) #(#maxX #short ) #(#begY #short ) #(#begX #short ) #(#flags #short ) #(#attrs #uInt ) #(#bkGd #uInt ) #(#noTimeout #uChar ) #(#clear #uChar ) #(#leaveOk #uChar ) #(#scroll #uChar ) #(#idlOk #uChar ) #(#immed #uChar ) #(#sync #uChar ) #(#useKeypad #uChar ) #(#delay #uChar ) #(#line #(#ptr #CObject ) ) #(#regTop #short ) #(#regBottom #short ) #(#parX #int ) #(#parY #int ) #(#parent #(#ptr #CObject ) ) #(#padY #short ) #(#padX #short ) #(#padTop #short ) #(#padLeft #short ) #(#padBottom #short ) #(#padRight #short ) #(#yOffset #short ) #(#attr #short ) #(#chars #(#array #char 5 ) ) )>

    StdScreen := nil.

    NCWindow class >> colorBlack [
	<category: 'Constants'>
	^0
    ]

    NCWindow class >> colorBlue [
	<category: 'Constants'>
	^4
    ]

    NCWindow class >> colorCyan [
	<category: 'Constants'>
	^6
    ]

    NCWindow class >> colorGreen [
	<category: 'Constants'>
	^2
    ]

    NCWindow class >> colorMagenta [
	<category: 'Constants'>
	^5
    ]

    NCWindow class >> colorRed [
	<category: 'Constants'>
	^1
    ]

    NCWindow class >> colorWhite [
	<category: 'Constants'>
	^7
    ]

    NCWindow class >> colorYellow [
	<category: 'Constants'>
	^3
    ]

    NCWindow class >> endLine [
	<category: 'Constants'>
	^2
    ]

    NCWindow class >> err [
	<category: 'Constants'>
	^-1
    ]

    NCWindow class >> false [
	<category: 'Constants'>
	^0
    ]

    NCWindow class >> fullWin [
	<category: 'Constants'>
	^4
    ]

    NCWindow class >> hasMoved [
	<category: 'Constants'>
	^1620
    ]

    NCWindow class >> isPad [
	<category: 'Constants'>
	^1610
    ]

    NCWindow class >> keyA1 [
	<category: 'Constants'>
	^534
    ]

    NCWindow class >> keyA3 [
	<category: 'Constants'>
	^535
    ]

    NCWindow class >> keyBackspace [
	<category: 'Constants'>
	^407
    ]

    NCWindow class >> keyBreak [
	<category: 'Constants'>
	^401
    ]

    NCWindow class >> keyB2 [
	<category: 'Constants'>
	^536
    ]

    NCWindow class >> keyBeg [
	<category: 'Constants'>
	^542
    ]

    NCWindow class >> keyBtab [
	<category: 'Constants'>
	^541
    ]

    NCWindow class >> keyC1 [
	<category: 'Constants'>
	^537
    ]

    NCWindow class >> keyC3 [
	<category: 'Constants'>
	^540
    ]

    NCWindow class >> keyCancel [
	<category: 'Constants'>
	^543
    ]

    NCWindow class >> keyCatab [
	<category: 'Constants'>
	^526
    ]

    NCWindow class >> keyClose [
	<category: 'Constants'>
	^544
    ]

    NCWindow class >> keyCommand [
	<category: 'Constants'>
	^545
    ]

    NCWindow class >> keyCopy [
	<category: 'Constants'>
	^546
    ]

    NCWindow class >> keyCreate [
	<category: 'Constants'>
	^547
    ]

    NCWindow class >> keyClear [
	<category: 'Constants'>
	^515
    ]

    NCWindow class >> keyCodeYes [
	<category: 'Constants'>
	^400
    ]

    NCWindow class >> keyCtab [
	<category: 'Constants'>
	^525
    ]

    NCWindow class >> keyDl [
	<category: 'Constants'>
	^510
    ]

    NCWindow class >> keyDc [
	<category: 'Constants'>
	^512
    ]

    NCWindow class >> keyDown [
	<category: 'Constants'>
	^402
    ]

    NCWindow class >> keyEic [
	<category: 'Constants'>
	^514
    ]

    NCWindow class >> keyEnd [
	<category: 'Constants'>
	^550
    ]

    NCWindow class >> keyEnter [
	<category: 'Constants'>
	^527
    ]

    NCWindow class >> keyEol [
	<category: 'Constants'>
	^517
    ]

    NCWindow class >> keyEos [
	<category: 'Constants'>
	^516
    ]

    NCWindow class >> keyEvent [
	<category: 'Constants'>
	^633
    ]

    NCWindow class >> keyExit [
	<category: 'Constants'>
	^551
    ]

    NCWindow class >> keyFind [
	<category: 'Constants'>
	^552
    ]

    NCWindow class >> keyHelp [
	<category: 'Constants'>
	^553
    ]

    NCWindow class >> keyHome [
	<category: 'Constants'>
	^406
    ]

    NCWindow class >> keyIl [
	<category: 'Constants'>
	^511
    ]

    NCWindow class >> keyIc [
	<category: 'Constants'>
	^513
    ]

    NCWindow class >> keyLeft [
	<category: 'Constants'>
	^404
    ]

    NCWindow class >> keyLl [
	<category: 'Constants'>
	^533
    ]

    NCWindow class >> keyMax [
	<category: 'Constants'>
	^777
    ]

    NCWindow class >> keyMark [
	<category: 'Constants'>
	^554
    ]

    NCWindow class >> keyMessage [
	<category: 'Constants'>
	^555
    ]

    NCWindow class >> keyMin [
	<category: 'Constants'>
	^401
    ]

    NCWindow class >> keyMouse [
	<category: 'Constants'>
	^631
    ]

    NCWindow class >> keyMove [
	<category: 'Constants'>
	^556
    ]

    NCWindow class >> keyNext [
	<category: 'Constants'>
	^557
    ]

    NCWindow class >> keyNpage [
	<category: 'Constants'>
	^522
    ]

    NCWindow class >> keyOpen [
	<category: 'Constants'>
	^560
    ]

    NCWindow class >> keyOptions [
	<category: 'Constants'>
	^561
    ]

    NCWindow class >> keyPrevious [
	<category: 'Constants'>
	^562
    ]

    NCWindow class >> keyPrint [
	<category: 'Constants'>
	^532
    ]

    NCWindow class >> keyPpage [
	<category: 'Constants'>
	^523
    ]

    NCWindow class >> keyRedo [
	<category: 'Constants'>
	^563
    ]

    NCWindow class >> keyReference [
	<category: 'Constants'>
	^564
    ]

    NCWindow class >> keyRefresh [
	<category: 'Constants'>
	^565
    ]

    NCWindow class >> keyReplace [
	<category: 'Constants'>
	^566
    ]

    NCWindow class >> keyReset [
	<category: 'Constants'>
	^531
    ]

    NCWindow class >> keyResize [
	<category: 'Constants'>
	^632
    ]

    NCWindow class >> keyRestart [
	<category: 'Constants'>
	^567
    ]

    NCWindow class >> keyResume [
	<category: 'Constants'>
	^570
    ]

    NCWindow class >> keyRight [
	<category: 'Constants'>
	^405
    ]

    NCWindow class >> keySave [
	<category: 'Constants'>
	^571
    ]

    NCWindow class >> keySbeg [
	<category: 'Constants'>
	^572
    ]

    NCWindow class >> keyScancel [
	<category: 'Constants'>
	^573
    ]

    NCWindow class >> keyScommand [
	<category: 'Constants'>
	^574
    ]

    NCWindow class >> keyScopy [
	<category: 'Constants'>
	^575
    ]

    NCWindow class >> keyScreate [
	<category: 'Constants'>
	^576
    ]

    NCWindow class >> keySdc [
	<category: 'Constants'>
	^577
    ]

    NCWindow class >> keySdel [
	<category: 'Constants'>
	^600
    ]

    NCWindow class >> keySelect [
	<category: 'Constants'>
	^601
    ]

    NCWindow class >> keySend [
	<category: 'Constants'>
	^602
    ]

    NCWindow class >> keySeol [
	<category: 'Constants'>
	^603
    ]

    NCWindow class >> keySexit [
	<category: 'Constants'>
	^604
    ]

    NCWindow class >> keySf [
	<category: 'Constants'>
	^520
    ]

    NCWindow class >> keySfind [
	<category: 'Constants'>
	^605
    ]

    NCWindow class >> keyShelp [
	<category: 'Constants'>
	^606
    ]

    NCWindow class >> keyShome [
	<category: 'Constants'>
	^607
    ]

    NCWindow class >> keySic [
	<category: 'Constants'>
	^610
    ]

    NCWindow class >> keySleft [
	<category: 'Constants'>
	^611
    ]

    NCWindow class >> keySmessage [
	<category: 'Constants'>
	^612
    ]

    NCWindow class >> keySmove [
	<category: 'Constants'>
	^613
    ]

    NCWindow class >> keySnext [
	<category: 'Constants'>
	^614
    ]

    NCWindow class >> keySoptions [
	<category: 'Constants'>
	^615
    ]

    NCWindow class >> keySprevious [
	<category: 'Constants'>
	^616
    ]

    NCWindow class >> keySprint [
	<category: 'Constants'>
	^617
    ]

    NCWindow class >> keySr [
	<category: 'Constants'>
	^521
    ]

    NCWindow class >> keySredo [
	<category: 'Constants'>
	^620
    ]

    NCWindow class >> keySreplace [
	<category: 'Constants'>
	^621
    ]

    NCWindow class >> keySReset [
	<category: 'Constants'>
	^530
    ]

    NCWindow class >> keySright [
	<category: 'Constants'>
	^622
    ]

    NCWindow class >> keySrsume [
	<category: 'Constants'>
	^623
    ]

    NCWindow class >> keySsave [
	<category: 'Constants'>
	^624
    ]

    NCWindow class >> keySsuspend [
	<category: 'Constants'>
	^625
    ]

    NCWindow class >> keyStab [
	<category: 'Constants'>
	^524
    ]

    NCWindow class >> keySundo [
	<category: 'Constants'>
	^626
    ]

    NCWindow class >> keySuspend [
	<category: 'Constants'>
	^627
    ]

    NCWindow class >> keyUndo [
	<category: 'Constants'>
	^630
    ]

    NCWindow class >> keyUp [
	<category: 'Constants'>
	^403
    ]

    NCWindow class >> noChange [
	<category: 'Constants'>
	^-1
    ]

    NCWindow class >> newIndex [
	<category: 'Constants'>
	^-1
    ]

    NCWindow class >> ok [
	<category: 'Constants'>
	^0
    ]

    NCWindow class >> subWin [
	<category: 'Constants'>
	^0
    ]

    NCWindow class >> scrollWin [
	<category: 'Constants'>
	^8
    ]

    NCWindow class >> true [
	<category: 'Constants'>
	^1
    ]

    NCWindow class >> wrapped [
	<category: 'Constants'>
	^64
    ]

    NCWindow class >> addch: aChar [
	"I put the character given to me into my window at the current
	 position, and then advance the current position. See the man(3)
	 addch entry for a description of my c function call."

	"int addch (const chtype);"

	<category: 'C call-outs'>
	<cCall: 'addch' returning: #int
	args: #(#char )>
	
    ]

    NCWindow class >> addchnstr: aString n: anInt [
	"I put at most n charaters of the character/attributes string
	 given to me into my window starting at the current position, and
	 then advance the current position. See the man(3) addchnstr entry
	 for a description of my c function call."

	"int addchnstr (const chtype *, int);"

	<category: 'C call-outs'>
	<cCall: 'addchnstr' returning: #int
	args: #(#string #int )>
	
    ]

    NCWindow class >> addchstr: aString [
	"I put the character/attributes in the string given to me into my
	 window starting at the current position, and then advance the
	 current position. See the man(3) addchstr entry for a description
	 of my c function call."

	"int addchstr (const chtype *);"

	<category: 'C call-outs'>
	<cCall: 'addchstr' returning: #int
	args: #(#string )>
	
    ]

    NCWindow class >> addnstr: aString n: anInt [
	"I put at most n characters in the string given to me into my
	 window starting at the current position, and then advance the
	 current position. See the man(3) addnstr entry for a description
	 of my c function call."

	"int addnstr (const char *, int);"

	<category: 'C call-outs'>
	<cCall: 'addnstr' returning: #int
	args: #(#string #int )>
	
    ]

    NCWindow class >> addstr: aString [
	"I put the characters in the string given to me into my window
	 starting at the current position, and then advance the current
	 position. See the man(3) addnstr entry for a description of my c
	 function call."

	"int addstr (const char *);"

	<category: 'C call-outs'>
	<cCall: 'addstr' returning: #int
	args: #(#string )>
	
    ]

    NCWindow class >> assumeDefaultColors: anInt1 bg: anInt2 [
	"I change my windows default background and forground colors to
	 the values given to me. See the man(3) assume_default_colors
	 entry for a description of my c function call."

	"int assume_default_colors (int, int);"

	<category: 'C call-outs'>
	<cCall: 'assume_default_colors' returning: #int
	args: #(#int #int )>
	
    ]

    NCWindow class >> attrGet: cObject1 pair: cObject2 opts: cObject3 [
	"I retrieve attribute values for my window from a file.  See the
	 man(3) attr_get entry for a description of my c function call."

	"int attr_get (attr_t *, short *, void *);"

	<category: 'C call-outs'>
	<cCall: 'attr_get' returning: #int
	args: #(#cObject #cObject #cObject )>
	
    ]

    NCWindow class >> attrOff: anInt opts: cObject [
	"I turn off the named attribute given to me in my window.  See the
	 man(3) attr_off for a description of my c function call."

	"int attr_off (attr_t, void *);"

	<category: 'C call-outs'>
	<cCall: 'attr_off' returning: #int
	args: #(#int #cObject )>
	
    ]

    NCWindow class >> attrOn: anInt opts: cObject [
	"I turn on the named attribute given to me in my window.  See the
	 man(3) attr_on for a description of my c function call."

	"int attr_on (attr_t, void *);"

	<category: 'C call-outs'>
	<cCall: 'attr_on' returning: #int
	args: #(#int #cObject )>
	
    ]

    NCWindow class >> attrSet: anInt1 pair: anInt2 opts: cObject [
	"I set the attribute color-pair in my window to the value given to
	 me. See the man(3) attr_set entry for a description of my c
	 function call."

	"int attr_set (attr_t, short, void *);"

	<category: 'C call-outs'>
	<cCall: 'attr_set' returning: #int
	args: #(#int #int #cObject )>
	
    ]

    NCWindow class >> attroff: anInt [
	"I turn off the named attribute given to me in my window.  See the
	 man(3) attroff for a description of my c function call."

	"int attroff (NCURSES_ATTR_T);"

	<category: 'C call-outs'>
	<cCall: 'attroff' returning: #int
	args: #(#int )>
	
    ]

    NCWindow class >> attron: anInt [
	"I turn on the named attribute given to me in my window.  See the
	 man(3) attron for a description of my c function call."

	"int attron (NCURSES_ATTR_T);"

	<category: 'C call-outs'>
	<cCall: 'attron' returning: #int
	args: #(#int )>
	
    ]

    NCWindow class >> attrset: anInt [
	"I set the attribute color-pair in my window to the value given to
	 me. See the man(3) attrset entry for a description of my c
	 function call."

	"int attrset (NCURSES_ATTR_T);"

	<category: 'C call-outs'>
	<cCall: 'attrset' returning: #int
	args: #(#int )>
	
    ]

    NCWindow class >> baudrate [
	"I return the output speed of the terminal. See the man(3)
	 baudrate entry for a description of my c function call."

	"int baudrate (void);"

	<category: 'C call-outs'>
	<cCall: 'baudrate' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> beep [
	"I ring the terminal alarm. See the man(3) beep entry for a
	 description of my c function call."

	"int beep (void);"

	<category: 'C call-outs'>
	<cCall: 'beep' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> bkgd: aChar [
	"I set the background property of my window and apply it to every
	 character in the window to the value given to me. See the man(3)
	 bkgd entry for a description of my c function call."

	"int bkgd (chtype);"

	<category: 'C call-outs'>
	<cCall: 'bkgd' returning: #int
	args: #(#char )>
	
    ]

    NCWindow class >> bkgdset: aChar [
	"I set the background property of the characters in my window to
	 the value given to me. See the man(3) bkgdset entry for a
	 description of my c function call."

	"void bkgdset (chtype);"

	<category: 'C call-outs'>
	<cCall: 'bkgdset' returning: #void
	args: #(#char )>
	
    ]

    NCWindow class >> border: aChar1 rs: aChar2 ts: aChar3 bs: aChar4 tl: aChar5 tr: aChar6 bl: aChar7 br: aChar8 [
	"I draw a border around the edges of my window using the character
	 attributes given to me. See the man(3) border entry for a
	 description of my c function call."

	"int border (chtype, chtype, chtype, chtype, chtype, chtype, chtype, chtype);"

	<category: 'C call-outs'>
	<cCall: 'border' returning: #int 
	args: #(#char #char #char #char #char #char #char #char )>
	
    ]

    NCWindow class >> canChangeColor [
	"I return true if the terminal has color capabilities that can be
	 changed. See the man(3) can_change_color entry for a description
	 of my c function call."

	"bool can_change_color (void);"

	<category: 'C call-outs'>
	<cCall: 'can_change_color' returning: #boolean
	args: #( )>
	
    ]

    NCWindow class >> cbreak [
	"I disable line buffering and erase/kill character processing.
	 See the man(3) cbreak entry for a description of my c function
	 call."

	"int cbreak (void);"

	<category: 'C call-outs'>
	<cCall: 'cbreak' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> chgat: anInt1 attr: anInt2 color: anInt3 opts: cObject [
	"I change up to n character attributes starting at the current
	 position. See the man(3) chgat entry for a description for my c
	 function calls."

	"int chgat (int, attr_t, short, const void *);"

	<category: 'C call-outs'>
	<cCall: 'chgat' returning: #int
	args: #(#int #int #int #cObject )>
	
    ]

    NCWindow class >> clear [
	"I put a blank in every character position in my window and set up
	 the window to be re-painted the next time that it is
	 refreshed. See the man(3) clear entry for a description of my c
	 function calls."

	"int clear (void);"

	<category: 'C call-outs'>
	<cCall: 'clear' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> clrtobot [
	"I erase the current screen from the right of the current
	 cursor position all the way to the bottom right of the screen.
	 See the man(3) clrtobot entry for a description of my c function
	 call."

	"int clrtobot (void);"

	<category: 'C call-outs'>
	<cCall: 'clrtobot' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> clrtoeol [
	"I erase the current line in my window to the right of the current
	 cursor location. See the man(3) clrtoeol entry for a description
	 of my c function calls."

	"int clrtoeol (void);"

	<category: 'C call-outs'>
	<cCall: 'clrtoeol' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> colorContent: anInt red: cObject1 green: cObject2 blue: cObject3 [
	"I extract the amount of RGB components in the color attribute
	 given to me. See the man(3) color_content entry for a description
	 of my c function call."

	"int color_content (short, short*, short*, short*);"

	<category: 'C call-outs'>
	<cCall: 'color_content' returning: #int 
	args: #(#int #cObject #cObject #cObject )>
	
    ]

    NCWindow class >> colorPair: anInt [
	"I return the number of color pair attributes that my terminal can
	 support. See the man(3) COLOR_PAIR entry for a description of my
	 c function call."

	"int COLOR_PAIR (int)"

	<category: 'C call-outs'>
	<cCall: 'COLOR_PAIR' returning: #int
	args: #(#int )>
	
    ]

    NCWindow class >> colorSet: anInt opts: cObject [
	"I set the current color of my window to the color pair attribute
	 given to me. See the man(3) color_set entry for a description of
	 my c function call."

	"int color_set (short, void*);"

	<category: 'C call-outs'>
	<cCall: 'color_set' returning: #int
	args: #(#int #cObject )>
	
    ]

    NCWindow class >> cursesVersion [
	"I return the version number and patch level of my ncurses
	 library.  See the man(3) curses_version entry for a description
	 of my c function call."

	"(const char *) curses_version (void);"

	<category: 'C call-outs'>
	<cCall: 'curses_version' returning: #string
	args: #(#void )>
	
    ]

    NCWindow class >> cursSet: anInt [
	"I set the cursor visibility in my window to the visibility given
	 to me and then return the previous cursor state. See the man(3)
	 curs_set entry for a description of my c function call."

	"int curs_set (int);"

	<category: 'C call-outs'>
	<cCall: 'curs_set' returning: #int
	args: #(#int )>
	
    ]

    NCWindow class >> defineKey: aString keycode: anInt [
	"I define a keycode with its' corresponding control string. See
	 the man(3) define_key entry for a description of my c function
	 call."

	"int define_key (const char *, int);"

	<category: 'C call-outs'>
	<cCall: 'define_key' returning: #int
	args: #(#string #int )>
	
    ]

    NCWindow class >> defProgMode [
	"I save the current terminals program state. See the man(3)
	 def_prog_mode entry for a description of my c function call."

	"int def_prog_mode (void);"

	<category: 'C call-outs'>
	<cCall: 'def_prog_mode' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> defShellMode [
	"I save the current terminals shell state. See the man(3)
	 def_shell_mode entry for a description of my c function call."

	"int def_shell_mode (void);"

	<category: 'C call-outs'>
	<cCall: 'def_shell_mode' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> delayOutput: anInt [
	"I put padding characters into the output while I delay for the
	 number of milli-seconds given to me. See the man(3) delay_output
	 for a description of my c function call."

	"int delay_output (int);"

	<category: 'C call-outs'>
	<cCall: 'delay_output' returning: #int
	args: #(#int )>
	
    ]

    NCWindow class >> delch [
	"I delete the character underneath the current cursor position and
	 then shift the characters to the right of the cursor one position
	 to the left. See the man(3) delch entry for a description of my c
	 function call."

	"int delch (void);"

	<category: 'C call-outs'>
	<cCall: 'delch' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> deleteln [
	"I delete the line under the current cursor position, move all of
	 the lines below the cursor up one line and clear the last
	 line. See the man(3) deleteln entry for a description of my c
	 function call."

	"int deleteln (void);"

	<category: 'C call-outs'>
	<cCall: 'deleteln' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> doupdate [
	"I transmit the difference between the virtual screen and the
	 physcial screen to the physical screen. See the man(3) doupdate
	 entry for a description of my c function call."

	"int doupdate (void);"

	<category: 'C call-outs'>
	<cCall: 'doupdate' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> echo [
	"I turn on the echoing of characters by getch to the screen as
	 they are typed. See the man(3) echo entry for a description of my
	 c function call."

	"int echo (void);"

	<category: 'C call-outs'>
	<cCall: 'echo' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> echochar: aChar [
	"I put the character given to me at the current cursor position,
	 advance the cursor, and then refresh the screen. See the man(3)
	 echochar entry for a description of my c function call."

	"int echochar (const chtype);"

	<category: 'C call-outs'>
	<cCall: 'echochar' returning: #int
	args: #(#char )>
	
    ]

    NCWindow class >> endwin [
	"I restore the tty mode, position the cursor to the lower
	 left-hand corner of the screen and reset the terminal into the
	 proper non-visual mode. See the man(3) endwin entry for a
	 description of my c function call."

	"int endwin (void);"

	<category: 'C call-outs'>
	<cCall: 'endwin' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> erase [
	"I put blanks into every position in the screen. See the man(3)
	 erase entry for a description of my c function call."

	"int erase (void);"

	<category: 'C call-outs'>
	<cCall: 'erase' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> erasechar [
	"I return the current character. See the man(3) erasechar for a
	 description of my c function."

	"char erasechar (void);"

	<category: 'C call-outs'>
	<cCall: 'erasechar' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> filter [
	"I restrict terminal input and output to a single line. See the
	 man(3) filter entry for a description of my c function."

	"void filter (void);"

	<category: 'C call-outs'>
	<cCall: 'filter' returning: #void
	args: #( )>
	
    ]

    NCWindow class >> flash [
	"I flash the terminal. See the man(3) entry for a description of
	 my c function call."

	"int flash (void);"

	<category: 'C call-outs'>
	<cCall: 'flash' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> flushinp [
	"I discard any unprocessed keystrokes. See the man(3) entry for a
	 description of my c function call."

	"int flushinp (void);"

	<category: 'C call-outs'>
	<cCall: 'flushinp' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> getch [
	"I read a keystroke from my window. See the man(3) getch entry for
	 a description of my c function call."

	"int getch (void);"

	<category: 'C call-outs'>
	<cCall: 'getch' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> getnstr: aString n: anInt [
	"I read at most n keystrokes from the stdscr window until a return
	 or linefeed key is pressed. See the man(3) getnstr entry for a
	 description of my c function call."

	"int getnstr (char *, int);"

	<category: 'C call-outs'>
	<cCall: 'getnstr' returning: #int
	args: #(#string #int )>
	
    ]

    NCWindow class >> getstr: aString [
	"I read keystrokes from the stdscr window until a return or
	 linefeed key is pressed. See the man(3) getstr entry for a
	 description of my c function call."

	"int getstr (char *);"

	<category: 'C call-outs'>
	<cCall: 'getstr' returning: #int
	args: #(#string )>
	
    ]

    NCWindow class >> halfdelay: anInt [
	"I return either a character or an error if a key is not pressed
	 within the number of 10ths of seconds given to me.  See the
	 man(3) halfdelay entry for a description of my c function call."

	"int halfdelay (int);"

	<category: 'C call-outs'>
	<cCall: 'halfdelay' returning: #int
	args: #(#int )>
	
    ]

    NCWindow class >> hasColors [
	"I return true if my terminal supports colors. See the man(3)
	 has_colors entry for a description of my c function call."

	"bool has_colors (void);"

	<category: 'C call-outs'>
	<cCall: 'has_colors' returning: #boolean
	args: #( )>
	
    ]

    NCWindow class >> hasIc [
	"I return true if my terminal has insert/delete character
	 capabilities. See the man(3) has_ic entry for a description of my
	 c function call."

	"bool has_ic (void);"

	<category: 'C call-outs'>
	<cCall: 'has_ic' returning: #boolean
	args: #( )>
	
    ]

    NCWindow class >> hasIl [
	"I return true if my terminal has insert/delete line
	 capabilities. See the man(3) has_ic entry for a description of my
	 c function call."

	"bool has_il (void);"

	<category: 'C call-outs'>
	<cCall: 'has_il' returning: #boolean
	args: #( )>
	
    ]

    NCWindow class >> hline: aChar n: anInt [
	"I draw a horizontal line in the terminal using the character
	 given to me of at most n characters. See the man(3) hline entry
	 for a description of my c function call."

	"int hline (chtype, int);"

	<category: 'C call-outs'>
	<cCall: 'hline' returning: #int
	args: #(#char #int )>
	
    ]

    NCWindow class >> inch [
	"I return the character/attribute at the current cursor position
	 in the terminal. See the man(3) inch entry for a description of
	 my c function call."

	"chtype inch (void);"

	<category: 'C call-outs'>
	<cCall: 'inch' returning: #char 
	args: #( )>
	
    ]

    NCWindow class >> inchnstr: aString n: anInt [
	"I return the character/attribute string of at most n characters
	 at the current cursor position in the terminal. See the man(3)
	 inchnstr entry for a description of my c function call."

	"int inchnstr (chtype *, int);"

	<category: 'C call-outs'>
	<cCall: 'inchnstr' returning: #int
	args: #(#string #int )>
	
    ]

    NCWindow class >> inchstr: aString [
	"I return the character/attribute string of characters at the
	 current cursor position in the terminal. See the man(3) inchstr
	 entry for a description of my c function call."

	"int inchstr (chtype *);"

	<category: 'C call-outs'>
	<cCall: 'inchstr' returning: #int
	args: #(#string )>
	
    ]

    NCWindow class >> initColor: anInt1 red: anInt2 green: anInt3 blue: anInt4 [
	"I change the definition of a color. See the man(3) init_color
	 entry for a description of my c function call."

	"int init_color (short, short, short, short);"

	<category: 'C call-outs'>
	<cCall: 'init_color' returning: #int
	args: #(#int #int #int #int )>
	
    ]

    NCWindow class >> initPair: anInt1 f: anInt2 b: anInt3 [
	"I initialize a color pair. See the man(3) init_pair for a
	 description of my c function call."

	"int init_pair (short, short, short);"

	<category: 'C call-outs'>
	<cCall: 'init_pair' returning: #int
	args: #(#int #int #int )>
	
    ]

    NCWindow class >> initscr [
	"WINDOW *initscr (void);"

	<category: 'C call-outs'>
	^StdScreen := self primInitScr
    ]

    NCWindow class >> innstr: aString n: anInt [
	"I extract up to n characters into a string starting at the
	 current curor position in the terminal. See the man(3) innstr
	 entry for a description of my c function call."

	"int innstr (char *, int);"

	<category: 'C call-outs'>
	<cCall: 'innstr' returning: #int
	args: #(#string #int )>
	
    ]

    NCWindow class >> insch: aChar [
	"I put the character given to me in the terminal at the current
	 cursor position and shift the remaining characters in the line
	 one position to the right. See the man(3) insch entry for a
	 description of my c function call."

	"int insch (chtype);"

	<category: 'C call-outs'>
	<cCall: 'insch' returning: #int
	args: #(#char )>
	
    ]

    NCWindow class >> insdelln: anInt [
	"I insert the number of blank lines given to me above the current
	 line and delete the same number of lines from the bottom. See the
	 man(3) insdelln entry for a description of my c function call."

	"int insdelln (int);"

	<category: 'C call-outs'>
	<cCall: 'insdelln' returning: #int
	args: #(#int )>
	
    ]

    NCWindow class >> insertln [
	"I insert a blank line in the terminal above the current line and
	 delete the bottom line. See the man(3) insertln entry for a
	 description of my c function call."

	"int insertln (void);"

	<category: 'C call-outs'>
	<cCall: 'insertln' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> insnstr: aString n: anInt [
	"I insert at most n characters in the string given to me into the
	 terminal starting at the one character before current cursor
	 position. The remaining characters in the line are shifted to the
	 right. See the man(3) insnstr entry for a description of my c
	 function call."

	"int insnstr (const char *, int);"

	<category: 'C call-outs'>
	<cCall: 'insnstr' returning: #int
	args: #(#string #int )>
	
    ]

    NCWindow class >> insstr: aString [
	"I insert the characters in the string given to me into the
	 terminal starting at the one character before current cursor
	 position. The remaining characters in the line are shifted to the
	 right. See the man(3) insstr entry for a description of my c
	 function call."

	"int insstr (const char *);"

	<category: 'C call-outs'>
	<cCall: 'insstr' returning: #int
	args: #(#string )>
	
    ]

    NCWindow class >> instr: aString [
	"I return the string of characters in the terminal starting at the
	 current cursor position. See the man(3) instr entry for a
	 description of my c function call."

	"int instr (char *);"

	<category: 'C call-outs'>
	<cCall: 'instr' returning: #int
	args: #(#string )>
	
    ]

    NCWindow class >> isendwin [
	"I return true if a refresh message has not been sent since an
	 endwin message was sent. Otherwise, I return false. See the
	 man(3) isendwin entry for a description of my c function call."

	"bool isendwin (void);"

	<category: 'C call-outs'>
	<cCall: 'isendwin' returning: #boolean
	args: #( )>
	
    ]

    NCWindow class >> isTermResized: anInt1 columns: anInt2 [
	"I return true if the resizeTerm:columns: message was sent, it
	 would change the terminal structures. Otherwise, I return false.
	 See the man(3) is_term_resized entry for a description of my c
	 function call."

	"bool is_term_resized (int, int);"

	<category: 'C call-outs'>
	<cCall: 'is_term_resized' returning: #char 
	args: #(#int #int )>
	
    ]

    NCWindow class >> keybound: int1 count: int2 [
	"I return the string defined in terminfo for the number of entries
	 given to me starting with the keycode given to me. See the man(3)
	 keybound entry for a description of my c function call."

	"char *keybound (int, int);"

	<category: 'C call-outs'>
	<cCall: 'keybound' returning: #string
	args: #(#int #int )>
	
    ]

    NCWindow class >> keyDefined: aString [
	"I return the keycode for the string given to me if it exists.  I
	 return 0 if there is no match, and I return -1 if the string is a
	 substring of more than one string in keycode/string
	 associations. See the man(3) key_defined entry for a description
	 of my c function call."

	"int key_defined (const char *);"

	<category: 'C call-outs'>
	<cCall: 'key_defined' returning: #int
	args: #(#string)>
	
    ]

    NCWindow class >> keyname: anInt [
	"I return a string corresponding to the key given to me. See the
	 man(3) keyname entry for a description of my c function call."

	"const char *keyname (int);"

	<category: 'C call-outs'>
	<cCall: 'keyname' returning: #string
	args: #(#int )>
	
    ]

    NCWindow class >> keyok: anInt enabled: aBool [
	"I enable or disable the keycode given to me. See the man(3) keyok
	 entry for a description of my c function call."

	"int keyok (int, bool);"

	<category: 'C call-outs'>
	<cCall: 'keyok' returning: #int
	args: #(#int #boolean)>
	
    ]

    NCWindow class >> killchar [
	"I return the line kill character. See the man(3) killchar entry
	 for a description of my c function call."

	"char killchar (void);"

	<category: 'C call-outs'>
	<cCall: 'killchar' returning: #char
	args: #( )>
	
    ]

    NCWindow class >> longname [
	"I return a string with a verbose description of the current
	 terminal. See the man(3) longname entry for a description of my c
	 function call."

	"char *longname (void);"

	<category: 'C call-outs'>
	<cCall: 'longname' returning: #string
	args: #( )>
	
    ]

    NCWindow class >> move: anInt1 x: anInt2 [
	"I move the cursor in the terminal to the position given to
	 me. See the man(3) move entry for a description of my c function
	 call."

	"int move (int, int);"

	<category: 'C call-outs'>
	<cCall: 'move' returning: #int
	args: #(#int #int )>
	
    ]

    NCWindow class >> mvaddch: anInt1 x: anInt2 ch: aChar [
	"I add a character to the terminal at the current cursor location
	 and then advance the cursor to the coordinates given to me. See
	 the man(3) mvaddch entry for a description of my c function
	 call."

	"int mvaddch (int, int, const chtype);"

	<category: 'C call-outs'>
	<cCall: 'mvaddch' returning: #int
	args: #(#int #int #char )>
	
    ]

    NCWindow class >> mvaddchstr: anInt1 x: anInt2 str: aString [
	"I copy the characters and attributes of the string given to me
	 into the terinal starting at the location specified by the
	 coordinates given to me. See the man(3) mvwaddchstr entry for a
	 description of my c function call."

	"int mvaddchstr (int, int, const chtype *);"

	<category: 'C call-outs'>
	<cCall: 'mvaddchstr' returning: #int
	args: #(#int #int #string )>
	
    ]

    NCWindow class >> mvaddchnstr: anInt1 x: anInt2 str: aString n: anInt3 [
	"I copy up to n characters and attributes of the string given to
	 me into the terinal starting at the location specified by the
	 coordinates given to me. See the man(3) mvwaddchnstr entry for a
	 description of my c function call."

	"int mvaddchnstr (int, int, const chtype *, int);"

	<category: 'C call-outs'>
	<cCall: 'mvaddchnstr' returning: #int
	args: #(#int #int #string #int )>
	
    ]

    NCWindow class >> mvaddnstr: anInt1 x: anInt2 str: aString n: anInt3 [
	"I copy up to n characters of the string given to me to the
	 terminal starting at the location specified by the coordinates
	 given to me.  See the man(3) mvaddnstr entry for a description of
	 my c function call."

	"int mvaddnstr (int, int, const char *, int);"

	<category: 'C call-outs'>
	<cCall: 'mvaddnstr' returning: #int
	args: #(#int #int #string #int )>
	
    ]

    NCWindow class >> mvaddstr: anInt1 x: anInt2 str: aString [
	"I copy the string given to me to the terminal starting at the
	 location specified by the coordinates given to me. See the man(3)
	 mvaddnstr entry for a description of my c function call."

	"int mvaddstr (int, int, const char *);"

	<category: 'C call-outs'>
	<cCall: 'mvaddstr' returning: #int
	args: #(#int #int #string )>
	
    ]

    NCWindow class >> mvchgat: anInt1 x: anInt2 n: anInt3 attr: anInt4 color: anInt5 opts: cObject [
	"I change the color and attribute of next n characters in the
	 terminal starting at the location specified by the coordinates
	 given to me. See the man(3) mvwchgat entry for a description of
	 my c function call."

	"int mvchgat (int, int, int, attr_t, short, const void *);"

	<category: 'C call-outs'>
	<cCall: 'mvchgat' returning: #int
	args: #(#int #int #int #int #int #cObject )>
	
    ]

    NCWindow class >> mvcur: anInt1 oldCol: anInt2 newRow: anInt3 newCol: anInt4 [
	"I move the cursor immediately in the terminal from the old row
	 and column to the new row and column given to me. See the man(3)
	 mvcur entry for a description of my c function call."

	"int mvcur (int, int, int, int);"

	<category: 'C call-outs'>
	<cCall: 'mvcur' returning: #int 
	args: #(#int #int #int #int )>
	
    ]

    NCWindow class >> mvdelch: anInt1 x: anInt2 [
	"I move the cursor to the coordinates given to me in the terminal,
	 delete the character under the cursor, and then shift the
	 remaining characters in the line one position to the left. See the
	 man(3) mvwdelch entry for description of my c function call."

	"int mvdelch (int, int);"

	<category: 'C call-outs'>
	<cCall: 'mvdelch' returning: #int
	args: #(#int #int )>
	
    ]

    NCWindow class >> mvgetch: anInt1 x: anInt2 [
	"I position the cursor to the location in the terminal specified
	 by the coordinates given to me, I read a character. See the
	 man(3) mvgetch entry for a description of my c function call."

	"int mvgetch (int, int);"

	<category: 'C call-outs'>
	<cCall: 'mvgetch' returning: #int
	args: #(#int #int )>
	
    ]

    NCWindow class >> mvgetnstr: anInt1 x: anInt2 str: aString n: anInt3 [
	"I position the cursor to the location in my window specified by
	 the coordinates given to me, and then I read at most n characters
	 until a carriage return or newline is pressed. See the man(3)
	 mvgetnstr entry for a description of my c function call."

	"int mvgetnstr (int, int, char *, int);"

	<category: 'C call-outs'>
	<cCall: 'mvgetnstr' returning: #int
	args: #(#int #int #string #int )>
	
    ]

    NCWindow class >> mvgetstr: anInt1 x: anInt2 str: aString [
	"I position the cursor to the location in the terminal specified
	 by the coordinates given to me, and thenI read characters until a
	 carriage return or a newline is pressed. See man(3) mvgetstr
	 entry for a description of my c function call."

	"int mvgetstr (int, int, char *);"

	<category: 'C call-outs'>
	<cCall: 'mvgetstr' returning: #int
	args: #(#int #int #string )>
	
    ]

    NCWindow class >> mvhline: anInt1 x: anInt2 ch: aChar n: anInt3 [
	"I position the cursor to the location in the terminal specified
	 by the coordinates given to me, and then I write a horizontal
	 line of at most n characters comprised of the character given to
	 me.  See the man(3) mvhline entry for a description of my c
	 function call."

	"int mvhline (int, int, chtype, int);"

	<category: 'C call-outs'>
	<cCall: 'mvhline' returning: #int
	args: #(#int #int #char #int )>
	
    ]

    NCWindow class >> mvinch: anInt1 x: anInt2 [
	"I return the character or attribute at the cursor location
	 specifed by the coordinates given to me. See the man(3) mvinch
	 entry for a description of my c call function."

	"chtype mvinch (int, int);"

	<category: 'C call-outs'>
	<cCall: 'mvinch' returning: #char
	args: #(#int #int )>
	
    ]

    NCWindow class >> mvinchnstr: anInt1 x: anInt2 str: aString n: anInt3 [
	"I return a null terminated array of characters or attributes from
	 the terminal of at most n characters starting at the cursor
	 location specified by the coordinates given to me. See the man(3)
	 mvinchnstr entry for a description of my c function call."

	"int mvinchnstr (int, int, chtype *, int);"

	<category: 'C call-outs'>
	<cCall: 'mvinchnstr' returning: #int
	args: #(#int #int #string #int )>
	
    ]

    NCWindow class >> mvinchstr: anInt1 x: anInt2 str: aString [
	"I return a null terminated array of characters or attributes from
	 within the terminal starting at the cursor location given by the
	 coordinates given to me. See the man(3) mvinchstr entry for a
	 description of my c call function."

	"int mvinchstr (int, int, chtype *);"

	<category: 'C call-outs'>
	<cCall: 'mvinchstr' returning: #int
	args: #(#int #int #string )>
	
    ]

    NCWindow class >> mvinnstr: anInt1 x: anInt2 str: aString n: anInt3 [
	"I return a string of characters from the termimal stripped of
	 attributes starting at the location given to me as
	 coordinates. See the man(3) mvinnstr entry for a description of
	 my c function call."

	"int mvinnstr (int, int, char *, int);"

	<category: 'C call-outs'>
	<cCall: 'mvinnstr' returning: #int
	args: #(#int #int #string #int )>
	
    ]

    NCWindow class >> mvinsch: anInt1 x: anInt2 ch: aChar [
	"I insert a character in the terminal before the location given to
	 me as coordinates. The remaining characters in the line are
	 shifted one position to the right. See the man(3) mvwinsch entry
	 for a description of my c function call."

	"int mvinsch (int, int, chtype);"

	<category: 'C call-outs'>
	<cCall: 'mvinsch' returning: #int
	args: #(#int #int #char )>
	
    ]

    NCWindow class >> mvinsnstr: anInt1 x: anInt2 str: aString n: anInt3 [
	"I insert a string of at most n characters in the terminal before
	 the location given to me as coordinates. The remaining characters
	 in the line are shifted one position to the right. See the man(3)
	 mvinsnstr entry for a description of my c function call."

	"int mvinsnstr (int, int, const char *, int);"

	<category: 'C call-outs'>
	<cCall: 'mvinsnstr' returning: #int
	args: #(#int #int #string #int )>
	
    ]

    NCWindow class >> mvinsstr: anInt1 x: anInt2 str: aString [
	"I insert a string before the location in the terminal given to me
	 as coordinates.  The remaining characters in the line are shifted
	 one position to the right. See the man(3) mvinsstr entry for a
	 description of my c function call."

	"int mvinsstr (int, int, const char *);"

	<category: 'C call-outs'>
	<cCall: 'mvinsstr' returning: #int
	args: #(#int #int #string )>
	
    ]

    NCWindow class >> mvinstr: anInt1 x: anInt2 str: aString [
	"I return a string of characters from the terminal starting from the
	 location given to me as coordinates. See the man(3) mvinstr for a
	 description of my c function call."

	"int mvinstr (int, int, char *);"

	<category: 'C call-outs'>
	<cCall: 'mvinstr' returning: #int
	args: #(#int #int #string )>
	
    ]

    NCWindow class >> mvprintw: anInt1 x: anInt2 str: aString [
	"I print a formated string in the terminal at the location given
	 to me as coordinates.  See the man(3) mvprintw entry for a
	 description of my c function call."

	"int mvprintw (int, int, const char *, ...)"

	<category: 'C call-outs'>
	<cCall: 'mvprintw' returning: #int
	args: #(#int #int #string)>
	
    ]

    NCWindow class >> mvprintw: anInt1 x: anInt2 str: aString args: anArray [
	"I print a formated string and arguments in the terminal at the
	 location given to me as coordinates.  See the man(3) mvprintw
	 entry for a description of my c function call."

	"int mvprintw (int, int, const char *, ...)"

	<category: 'C call-outs'>
	<cCall: 'mvprintw' returning: #int
	args: #(#int #int #string #variadic)>
	
    ]

    NCWindow class >> mvscanw: anInt1 x: anInt2 str: aString args: anArray [
	"I scan a string from within the terminal at the location given to
	 me as coordinates. See the man(3) mvscanw entry for a description
	 of my c function call."

	"int mvscanw (int, int, const char *, ...)"

	<category: 'C call-outs'>
	<cCall: 'mvscanw' returning: #int
	args: #(#int #int #string #variadic)>
	
    ]

    NCWindow class >> mvvline: anInt1 x: anInt2 ch: aChar n: anInt3 [
	"I position the cursor to the location in the terminal specified
	 by the coordinates given to me, and then write a vertical line of
	 at most n characters comprised of the character given to me.  See
	 the man(3) mvvline entry for a description of my c function
	 call."

	"int mvvline (int, int, chtype, int);"

	<category: 'C call-outs'>
	<cCall: 'mvvline' returning: #int
	args: #(#int #int #char #int )>
	
    ]

    NCWindow class >> napms: anInt [
	"I sleep for the number of milliseconds given to me. See the
	 man(3) napms entry for a description of my c function call."

	"int napms (int);"

	<category: 'C call-outs'>
	<cCall: 'napms' returning: #int
	args: #(#int )>
	
    ]

    NCWindow class >> newpad: anInt1 ncols: anInt2 [
	"I create a new specialized instance of a window. My size is
	 specified by the number of rows and columns given to me. See the
	 man(3) newpad entry for a description of my c function call."

	"WINDOW *newpad (int, int);"

	<category: 'C call-outs'>
	<cCall: 'newpad' returning: #{NCWindow}
	args: #(#int #int )>
	
    ]

    NCWindow class >> newwin: anInt1 cols: anInt2 beginY: anInt3 beginX: anInt4 [
	"I create a new window structure at the location given to me as
	 coordinates.  My size is specified by the number of rows and
	 columns given to me.  See the man(3) newwin entry for a
	 description of my c function call."

	"WINDOW *newwin (int, int, int, int);"

	<category: 'C call-outs'>
	<cCall: 'newwin' returning: #{NCWindow}
	args: #(#int #int #int #int )>
	
    ]

    NCWindow class >> nl [
	"I tell the display device to display newline on input and
	 newline/return on output. See the man(3) nl entry for a
	 description of my c function call."

	"int nl (void);"

	<category: 'C call-outs'>
	<cCall: 'nl' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> nocbreak [
	"I tell the tty driver to enable line buffering and to process
	 erase and kill characters. See the man(3) nocbreak entry for a
	 description of my c function call."

	"int nocbreak (void);"

	<category: 'C call-outs'>
	<cCall: 'nocbreak' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> noecho [
	"I disable getch from echoing characters as they are typed. See
	 the man(3) noecho entry for a description of my c function call."

	"int noecho (void);"

	<category: 'C call-outs'>
	<cCall: 'noecho' returning: #int 
	args: #( )>
	
    ]

    NCWindow class >> nonl [
	"I tell the display device to no display newline on input or
	 newline/return on output. See the man(3) nonl entry for a
	 description of my c function call."

	"int nonl (void);"

	<category: 'C call-outs'>
	<cCall: 'nonl' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> noqiflush [
	"I turn off termio input and output queue interrupt flushing. See
	 the man(3) noqiflush entry for a description of my c function
	 call."

	"void noqiflush (void);"

	<category: 'C call-outs'>
	<cCall: 'noqiflush' returning: #void
	args: #( )>
	
    ]

    NCWindow class >> noraw [
	"I set the terminal to the non-raw mode. See the man(3) noraw
	 entry for a decription of my c function call."

	"int noraw (void);"

	<category: 'C call-outs'>
	<cCall: 'noraw' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> pairContent: anInt f: cObject1 b: cObject2 [
	"I map a color-pair number into it's foreground and background
	 color components. See the man(3) pair_content entry for a
	 description of my c function call."

	"int pair_content (short, short*, short*);"

	<category: 'C call-outs'>
	<cCall: 'pair_content' returning: #int
	args: #(#int #cObject #cObject )>
	
    ]

    NCWindow class >> pairNumber: anInt [
	"I return the color pair number associate with the pair attribute
	 given to me. See the man(3) PAIR_NUMBER entry for a description
	 of my c function call."

	"int PAIR_NUMBER (int);"

	<category: 'C call-outs'>
	<cCall: 'PAIR_NUMBER' returning: #int
	args: #(#int )>
	
    ]

    NCWindow class >> primInitScr [
	"WINDOW *initscr (void);"

	<category: 'C call-outs'>
	<cCall: 'initscr' returning: #{NCWindow}
	args: #( )>
	
    ]

    NCWindow class >> printw: aString [
	"I display formatted output. See then man(3) printw entry for a
	 description of my c function call."

	"int printw (const char *, ...)"

	<category: 'C call-outs'>
	<cCall: 'printw' returning: #int
	args: #(#string )>
	
    ]

    NCWindow class >> printw: aString args: anArray [
	"I display formatted output given a string and arguments. See then
	 man(3) printw entry for a description of my c function call."

	"int printw (const char *, ...)"

	<category: 'C call-outs'>
	<cCall: 'printw' returning: #int
	args: #(#string #variadic)>
	
    ]

    NCWindow class >> putp: aString [
	"I am a lowlevel print routine used to interface with the terminfo
	 database. See the man(3) putp entry for a description of my c
	 function call."

	"int putp (const char *);"

	<category: 'C call-outs'>
	<cCall: 'putp' returning: #int
	args: #(#string )>
	
    ]

    NCWindow class >> qiflush [
	"I turn on termio input and output queue interrupt flushing. See
	 the man(3) qiflush entry for a description of my c function
	 call."

	"void qiflush (void);"

	<category: 'C call-outs'>
	<cCall: 'qiflush' returning: #void
	args: #( )>
	
    ]

    NCWindow class >> raw [
	"I put the terminal in raw input mode. See the man(3) entry for a
	 description of my c function call."

	"int raw (void);"

	<category: 'C call-outs'>
	<cCall: 'raw' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> refresh [
	"I physically move the contents of stdscr to the physical screen.
	 See then man(3) refresh entry for a description of my c function
	 call."

	"int refresh (void);"

	<category: 'C call-outs'>
	<cCall: 'refresh' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> resetProgMode [
	"I restore the terminal to the 'program' state. See the man(3)
	 reset_prog_mode entry for a description of my c function call."

	"int reset_prog_mode (void);"

	<category: 'C call-outs'>
	<cCall: 'reset_prog_mode' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> resetShellMode [
	"I restore the terminal to the 'shell' state. See the man(3)
	 reset_shell_mode entry for a description of my c function call."

	"int reset_shell_mode (void);"

	<category: 'C call-outs'>
	<cCall: 'reset_shell_mode' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> resetty [
	"I restore the state of the terminal modes to the state saved by the
	 last savetty message. See the man(3) resetty entry for a description
	 of my c function call."

	"int resetty (void);"

	<category: 'C call-outs'>
	<cCall: 'resetty' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> resizeTerm: anInt1 columns: anInt2 [
	"I resize the current and the standard windows to the number of
	 rows and columns given to me. See the man(3) resizeterm entry for
	 a description of my c function call."

	"int resizeterm (int, int);"

	<category: 'C call-outs'>
	<cCall: 'resizeterm' returning: #int
	args: #(#int #int )>
	
    ]

    NCWindow class >> savetty [
	"I save the state of the terminal modes. See the man(3) savetty
	 entry for a description of my c function call."

	"int savetty (void);"

	<category: 'C call-outs'>
	<cCall: 'savetty' returning: #int 
	args: #( )>
	
    ]

    NCWindow class >> scanw: aString args: anArray [
	"I scan an input string. See the man(3) scanw entry for a
	 description of my c function call."

	"int scanw (const char *, ...)"

	<category: 'C call-outs'>
	<cCall: 'scanw' returning: #int
	args: #(#string #variadic )>
	
    ]

    NCWindow class >> scrDump: aString [
	"I dump the contents of the virtual screen to a file. See the
	 man(3) scr_dump entry for a description of my c function call."

	"int scr_dump (const char *);"

	<category: 'C call-outs'>
	<cCall: 'scr_dump' returning: #int
	args: #(#string )>
	
    ]

    NCWindow class >> scrInit: aString [
	"I initialize the cursors structures based on the contents of a
	 file. See the man(3) scr_init entry for a description of my c
	 function call."

	"int scr_init (const char *);"

	<category: 'C call-outs'>
	<cCall: 'scr_init' returning: #int
	args: #(#string )>
	
    ]

    NCWindow class >> scrRestore: aString [
	"I load the contents of a file previously saved by the scr_dump
	 into the virtual screen. See the man(3) scr_restore entry for a
	 description of my c function call."

	"int scr_restore (const char *);"

	<category: 'C call-outs'>
	<cCall: 'scr_restore' returning: #int
	args: #(#string )>
	
    ]

    NCWindow class >> scrSet: aString [
	"I load the contents of a file and perform a combination of
	 scr_init and scr_restore operations. See the man(3) scr_set entry
	 for a description of my c function call."

	"int scr_set (const char *);"

	<category: 'C call-outs'>
	<cCall: 'scr_set' returning: #int
	args: #(#string )>
	
    ]

    NCWindow class >> scrl: anInt [
	"I scroll up the terminal the number of lines given to me. See the
	 man(3) scrl entry for a description of my c function call."

	"int scrl (int);"

	<category: 'C call-outs'>
	<cCall: 'scrl' returning: #int
	args: #(#int )>
	
    ]

    NCWindow class >> setTerm: cObject [
	"I switch between different terminals. See the man(3) set_term
	 entry for a description of my c function call."

	"SCREEN *set_term (SCREEN *);"

	<category: 'C call-outs'>
	<cCall: 'set_term' returning: #cObject
	args: #(#cObject )>
	
    ]

    NCWindow class >> setscrreg: anInt1 bot: anInt2 [
	"I enable a scroll region within a window between the top and
	 bottom lines given to me. See the man(3) setscrreg entry for a
	 description of my c function call."

	"int setscrreg (int, int);"

	<category: 'C call-outs'>
	<cCall: 'setscrreg' returning: #int
	args: #(#int #int )>
	
    ]

    NCWindow class >> slkAttr [
	"I return the attribute used for the softkeys. See the man(3)
	 slk_attr entyr for a description of the c function call."

	"attr_t slk_attr (void);"

	<category: 'C call-outs'>
	<cCall: 'slk_attr' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> slkAttrSet: anInt1 colorPair: anInt2 opts: cObject [
	"I set the attribute color-pair for the soft keys to the value
	 given to me. See the man(3) slk_attr_set entry for a description
	 of my c function call."

	"int slk_attr_set (const attr_t, short, void*);"

	<category: 'C call-outs'>
	<cCall: 'slk_attr_set' returning: #int
	args: #(#int #int #cObject )>
	
    ]

    NCWindow class >> slkAttroff: aChar [
	"I turn off the named attribute given to me for the soft keys.
	 See the man(3) slk_attr_off for a description of my c function
	 call."

	"int slk_attroff (const chtype);"

	<category: 'C call-outs'>
	<cCall: 'slk_attroff' returning: #int
	args: #(#char )>
	
    ]

    NCWindow class >> slkAttron: aChar [
	"I turn on the named attribute given to me for the soft keys.  See
	 the man(3) slk_attr_on for a description of my c function call."

	"int slk_attron (const chtype);"

	<category: 'C call-outs'>
	<cCall: 'slk_attron' returning: #int
	args: #(#char )>
	
    ]

    NCWindow class >> slkAttrset: aChar [
	"I set the attribute color-pair for the soft keys to the value
	 given to me. See the man(3) slk_attrset entry for a description of
	 my c function call."

	"int slk_attrset (const chtype);"

	<category: 'C call-outs'>
	<cCall: 'slk_attrset' returning: #int
	args: #(#char )>
	
    ]

    NCWindow class >> slkClear [
	"I clear the soft labels from the screen. See the man(3) slk_attr
	 entry for a description of my c function call."

	"int slk_clear (void);"

	<category: 'C call-outs'>
	<cCall: 'slk_clear' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> slkColor: anInt [
	"I set the current color of the soft keys to the color pair
	 attribute given to me. See the man(3) slk_color entry for a
	 description of my c function call."

	"int slk_color (short);"

	<category: 'C call-outs'>
	<cCall: 'slk_color' returning: #int
	args: #(#int )>
	
    ]

    NCWindow class >> slkInit: anInt [
	"I establish the format of the soft key label presentation using
	 the value given to me. See the man(3) slk_init entry for a
	 description of my c function call."

	"int slk_init (int);"

	<category: 'C call-outs'>
	<cCall: 'slk_init' returning: #int
	args: #(#int )>
	
    ]

    NCWindow class >> slkLabel: anInt [
	"I return the label text for the label number given to me. See the
	 man(3) slk_label entry for a description of my c function call."

	"char *slk_label (int);"

	<category: 'C call-outs'>
	<cCall: 'slk_label' returning: #string
	args: #(#int )>
	
    ]

    NCWindow class >> slkNoutrefresh [
	"I commit the differences between the soft labels in the virtual
	 screen and the physical screen to the physical screen. See the
	 man(3)slk_noutrefresh entry for a description of my c function
	 call."

	"int slk_noutrefresh (void);"

	<category: 'C call-outs'>
	<cCall: 'slk_noutrefresh' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> slkRefresh [
	"I commit the soft labels in the virtual screen to the physical
	 screen. See the man(3)slk_refresh entry for a description of my c
	 function call."

	"int slk_refresh (void);"

	<category: 'C call-outs'>
	<cCall: 'slk_refresh' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> slkRestore [
	"I restore the labels to the screen after a slk_clear. See the
	 man(3) entry for description of my c function call."

	"int slk_restore (void);"

	<category: 'C call-outs'>
	<cCall: 'slk_restore' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> slkSet: anInt1 label: aString format: anInt2 [
	"I set the label text for the label number given to me using the
	 format given to me. See the man(3) slk_set entry for a description
	 of my c function call."

	"int slk_set (int, const char *, int);"

	<category: 'C call-outs'>
	<cCall: 'slk_set' returning: #int 
	args: #(#int #string #int )>
	
    ]

    NCWindow class >> slkTouch [
	"I cause all of the soft labels in the virtual screen to be
	 commited to the physical screen the next time a slk_noutrefresh is
	 sent. See the man(3) slk_touch entry for a description of my c
	 function call."

	"int slk_touch (void);"

	<category: 'C call-outs'>
	<cCall: 'slk_touch' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> standend [
	"I turn off all attributes in the screen. See the man(3) standend
	 entry for a description of my c function call."

	"int standend (void);"

	<category: 'C call-outs'>
	<cCall: 'standend' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> standout [
	"I turn on the best highlighting available in the screen. See the
	 man(3) standout entry for a description of my c function call."

	"int standout (void);"

	<category: 'C call-outs'>
	<cCall: 'standout' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> startColor [
	"I intitialize the color table. See the man(3) start_color entry for
	 a description of my c function call."

	"int start_color (void);"

	<category: 'C call-outs'>
	<cCall: 'start_color' returning: #int
	args: #( )>
	
    ]

    NCWindow class >> stdscr [
	"WINDOW *stdscr;"

	<category: 'C call-outs'>
	^StdScreen
    ]

    NCWindow class >> termattrs [
	"I return the logical OR of the attributes supported by my
	 terminal.  See the man(3) termattrs entry for a description of my
	 c function call."

	"chtype termattrs (void);"

	<category: 'C call-outs'>
	<cCall: 'termattrs' returning: #char 
	args: #( )>
	
    ]

    NCWindow class >> termname [
	"I return the terminal name used by setupterm. See the man(3)
	 termname entry for a description of my c function call."

	"char *termname (void);"

	<category: 'C call-outs'>
	<cCall: 'termname' returning: #string 
	args: #( )>
	
    ]

    NCWindow class >> tigetflag: aString [
	"I return the compatibillity corresponding to the terminfo capinfo
	 given to me. See the man(3) tigetflag entry for a description of
	 my c function call."

	"int tigetflag (const char *);"

	<category: 'C call-outs'>
	<cCall: 'tigetflag' returning: #int 
	args: #(#string )>
	
    ]

    NCWindow class >> tigetnum: aString [
	"I return the compatibillity corresponding to the terminfo capinfo
	 given to me. See the man(3) tigetnum entry for a description of my
	 c function call."

	"int tigetnum (const char *);"

	<category: 'C call-outs'>
	<cCall: 'tigetnum' returning: #int 
	args: #(#string )>
	
    ]

    NCWindow class >> tigetstr: aString [
	"I return the compatibillity corresponding to the terminfo capinfo
	 given to me. See the man(3) tigetstr entry for a description of my
	 c function call."

	"char *tigetstr (const char *);"

	<category: 'C call-outs'>
	<cCall: 'tigetstr' returning: #string 
	args: #(#string )>
	
    ]

    NCWindow class >> timeout: anInt [
	"I configure blocking and non-blocking reads in the terminal based
	 on the value given to me. See the man(3) timeout entry for a
	 description of my c function call."

	"void timeout (int);"

	<category: 'C call-outs'>
	<cCall: 'timeout' returning: #void 
	args: #(#int )>
	
    ]

    NCWindow class >> tparm: aString [
	"I instantiate the string given to me with the arguments given to
	 me.  See the man(3) tparm entry for a description of my c function
	 call."

	"char *tparm (const char *, ...);"

	<category: 'C call-outs'>
	<cCall: 'tparm' returning: #int
	args: #(#string )>
	
    ]

    NCWindow class >> tparm: aString args: anArray [
	"I instantiate the string given to me with the arguments given to
	 me.  See the man(3) tparm entry for a description of my c function
	 call."

	"char *tparm (const char *, ...);"

	<category: 'C call-outs'>
	<cCall: 'tparm' returning: #int 
	args: #(#string #variadic)>
	
    ]

    NCWindow class >> typeahead: anInt [
	"I set typeahead fd to be checked to the fd given to me. See the
	 man(3) typeahead entry for a description of my c function calls."

	"int typeahead (int);"

	<category: 'C call-outs'>
	<cCall: 'typeahead' returning: #int 
	args: #(#int )>
	
    ]

    NCWindow class >> ungetch: anInt [
	"I push the character given to me back onto the input stream to be
	 re-read. See the man(3) ungetc entry for a description of my c
	 function call."

	"int ungetch (int);"

	<category: 'C call-outs'>
	<cCall: 'ungetch' returning: #int 
	args: #(#int )>
	
    ]

    NCWindow class >> useDefaultColors [
	"I tell the ncurses library to use the default background and
	 foreground colors. See the man(3) use_default_colors entry for a
	 description of my c function call."

	"int use_default_colors (void);"

	<category: 'C call-outs'>
	<cCall: 'use_default_colors' returning: #int 
	args: #( )>
	
    ]

    NCWindow class >> useEnv: aBoolean [
	"I cause the number of columns and rows to be used in the window
	 to be determined by the value of environment variables if I am
	 given the boolean value true. See the man(3) use_env entry for a
	 description of my c function call."

	"void use_env (bool);"

	<category: 'C call-outs'>
	<cCall: 'use_env' returning: #void 
	args: #(#boolean )>
	
    ]

    NCWindow class >> useExtendedNames: aBoolean [
	"I enable using user-defined terminfo names if I am given the
	 boolean value true.  See the man(3) use_extended_names entry for a
	 description for a description of my c function call."

	"int use_extended_names (bool);"

	<category: 'C call-outs'>
	<cCall: 'use_extended_names' returning: #int 
	args: #(#boolean )>
	
    ]

    NCWindow class >> vidattr: aChar [
	"I display a string in the terminal using the attribute given to
	 me. See the man(3) vidattr entry for a description of my c
	 function call."

	"int vidattr (chtype);"

	<category: 'C call-outs'>
	<cCall: 'vidattr' returning: #int 
	args: #(#char )>
	
    ]

    NCWindow class >> vline: aChar n: anInt [
	"I write a vertical line of at most n characters comprised of the
	 character given to me in the terminal. See the man(3) vline entry
	 for a description of my c function call."

	"int vline (chtype, int);"

	<category: 'C call-outs'>
	<cCall: 'vline' returning: #int 
	args: #(#char #int )>
	
    ]

    NCWindow class >> clock [
	<category: 'examples'>
	| screen |
	self
	    initscr;
	    noecho;
	    cbreak;
	    refresh.
	screen := self 
		    newwin: 13
		    cols: 27
		    beginY: 1
		    beginX: 1.
	screen nodelay: true.
	[screen wgetch = $q asInteger] whileFalse: 
		[screen
		    mvwprintw: 3
			x: 6
			str: Date today printString;
		    mvwprintw: 5
			x: 6
			str: Time now printString;
		    wrefresh.
		(Delay forSeconds: 1) wait].
	self endwin
    ]

    NCWindow class >> helloWorld [
	<category: 'examples'>
	self
	    initscr;
	    printw: 'hello world';
	    refresh;
	    getch;
	    endwin
    ]

    box: aChar1 withHorizontalChar: aChar2 [
	"I draw a box using the characters sent as arguments.  See the
	 man(3) box entry for a description of my c function call."

	"int box (WINDOW *, chtype, chtype);"

	<category: 'C call-outs'>
	<cCall: 'box' returning: #int
	args: #(#self #char #char )>
	
    ]

    clearok: aBoolean [
	"I cause the screen to be cleared and re-drawn from scratch the
	 next time the refresh message is sent when I receive the boolean
	 value 'true' as an argument.  See the man(3) clearok entry for a
	 description of my c function call."

	"int clearok (WINDOW *, bool);"

	<category: 'C call-outs'>
	<cCall: 'clearok' returning: #int
	args: #(#self #boolean )>
	
    ]

    copywin: cObject sourceMinimumRow: anInt1 sourceMinimumColumn: anInt2 destinationMinimumRow: anInt3 destinationMinimumColumn: anInt4 destinationMaximumRow: anInt5 destinationMaximumColumn: anInt6 overlay: anInt7 [
	"I overlay or overwrite a destination window with my window. See
	 the man(3) copywin entry for a description of my c function
	 call."

	"int copywin (const WINDOW*, WINDOW*, int, int, int, int, int, int, int);"

	<category: 'C call-outs'>
	<cCall: 'copywin' returning: #int
	args: #(#self #cObject #int #int #int #int #int #int #int )>
	
    ]

    delscreen: cObject [
	"I release the storage associated with a screen structure. See the
	 man(3) delscreen entry for a description of my c function call."

	"void delscreen (SCREEN *);"

	<category: 'C call-outs'>
	<cCall: 'delscreen' returning: #void
	args: #(#cObject )>
	
    ]

    delwin [
	"I release the storage associated with my window structure. See
	 the man(3) delwin entry for a description of my c function call."

	"int delwin (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'delwin' returning: #int
	args: #(#self )>
	
    ]

    derwin: anInt1 forColumns: anInt2 atY: anInt3 atX: anInt4 [
	"I return a new window with the given number lines and columns
	 with the top left corner at the location given as coorindates.
	 See the man(3) derwin entry for a description of my c function
	 call."

	"WINDOW *derwin (WINDOW *, int, int, int, int);"

	<category: 'C call-outs'>
	<cCall: 'derwin' returning: #{NCWindow}
	args: #(#self #int #int #int #int )>
	
    ]

    dupwin [
	"I return a duplicate of my window. See the man(3) dupwin entry
	 for a description of my c function call."

	"WINDOW *dupwin (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'dupwin' returning: #{NCWindow}
	args: #(#self )>
	
    ]

    getbkgd [
	"I return my windows' attribute/character pair.  See the man(3)
	 getbkgd entry for a description of my c function call."

	"chtype getbkgd (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'getbkgd' returning: #char
	args: #(#self )>
	
    ]

    idcok: aBoolean [
	"I enable or disable the use of the hardware character
	 insert/delete terminal feature if it's available. See the man(3)
	 idcok entry for a description of my c function call."

	"void idcok (WINDOW *, bool);"

	<category: 'C call-outs'>
	<cCall: 'idcok' returning: #void
        args: #(#self #boolean )>
	
    ]

    idlok: aBoolean [
	"I enable or disable the use of the hardware line insert/delete
	 terminal feature if it's available. See the man(3) idlok entry
	 for a description of my c function call."

	"int idlok (WINDOW *, bool);"

	<category: 'C call-outs'>
	<cCall: 'idlok' returning: #int
	args: #(#self #boolean )>
	
    ]

    immedok: aBoolean [
	"I enable or disable the automatic refresh of my window whenever
	 it's updated. See the man(3) immedok entry for a description of
	 my c function call."

	"void immedok (WINDOW *, bool);"

	<category: 'C call-outs'>
	<cCall: 'immedok' returning: #void 
	args: #(#self #boolean )>
	
    ]

    intrflush: aBoolean [
	"I enable or disable flushing the tty driver queue whenever an
	 interrupt key is pressed. See then man(3) intrflush entry for
	 a description of my c call function."

	"int intrflush (WINDOW *, bool);"

	<category: 'C call-outs'>
	<cCall: 'intrflush' returning: #int 
	args: #(#self #boolean )>
	
    ]

    isLinetouched: anInt [
	"I return true if the line number sent to me as a parameter is
	 within my window otherwise I return false.  See the man(3)
	 is_linetouched entry for a description of my c function call."

	"bool is_linetouched (WINDOW *, int);"

	<category: 'C call-outs'>
	<cCall: 'is_linetouched' returning: #boolean 
	args: #(#self #int )>
	
    ]

    isWintouched [
	"I return true if my window has been updated since the last
	 refresh message was sent. See the man(3) is_wintouched entry
	 for a description of my c function call."

	"bool is_wintouched (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'is_wintouched' returning: #boolean
	args: #(#self )>
	
    ]

    keypad: aBoolean [
	"I enable or disable the use of the keyboard keypad. See the
	 man(3) keypad entry for a description of my c function call."

	"int keypad (WINDOW *, bool);"

	<category: 'C call-outs'>
	<cCall: 'keypad' returning: #int
	args: #(#self #boolean )>
	
    ]

    leaveok: aBoolean [
	"I enable or disable leaving the cursor at the location an update
	 places it. See the man(3) leaveok entry for a description of my c
	 function call."

	"int leaveok (WINDOW *, bool);"

	<category: 'C call-outs'>
	<cCall: 'leaveok' returning: #int
	args: #(#self #boolean )>
	
    ]

    meta: aBoolean [
	"I ask the tty driver to return 8-bits if I'm passed the boolean
	 value true, and 7-bits if I'm passed the boolean value false.
	 See the man(3) meta entry for a description of my c function
	 call."

	"int meta (WINDOW *, bool);"

	<category: 'C call-outs'>
	<cCall: 'meta' returning: #int
	args: #(#self #boolean )>
	
    ]

    mvderwin: anInt1 parX: anInt2 [
	"I move a subwindow within my window to new location and put
	 it's top left corner at the location given to me as a
	 coordinates. See the man(3) mvderwin entry for a description of
	 my c function call."

	"int mvderwin (WINDOW *, int, int);"

	<category: 'C call-outs'>
	<cCall: 'mvderwin' returning: #int
	args: #(#self #int #int )>
	
    ]

    mvwaddch: anInt1 x: anInt2 ch: aChar [
	"I add a character to my window at the current cursor location after
	 advancing the cursor to the coordinates given to me. See the
	 man(3) mvwaddch entry for a description of my c function call."

	"int mvwaddch (WINDOW *, int, int, const chtype);"

	<category: 'C call-outs'>
	<cCall: 'mvwaddch' returning: #int
	args: #(#self #int #int #char )>
	
    ]

    mvwaddchnstr: anInt1 x: anInt2 str: aString n: anInt3 [
	"I copy up to n characters of the string and attributes given to
	 me into my window starting at the location specified by the
	 coordinates given to me. See the man(3) mvwaddchnstr entry for a
	 description of my c function call."

	"int mvwaddchnstr (WINDOW *, int, int, const chtype *, int);"

	<category: 'C call-outs'>
	<cCall: 'mvwaddchnstr' returning: #int
	args: #(#self #int #int #string #int )>
	
    ]

    mvwaddchstr: anInt1 x: anInt2 str: aString [
	"I copy the string and attributes given to me into my window
	 starting at the location specified by the point given to me. See
	 the man(3) mvwaddchnstr entry for a description of my c function
	 call."

	"int mvwaddchstr (WINDOW *, int, int, const chtype *);"

	<category: 'C call-outs'>
	<cCall: 'mvwaddchstr' returning: #int
	args: #(#self #int #int #string )>
	
    ]

    mvwaddnstr: anInt1 x: anInt2 str: aString n: anInt3 [
	"I copy up to n characters of the string given to me in my window
	 starting at the location specified by the coordinates given to
	 me.  See the man(3) mvwaddnstr entry for a description of my c
	 function call."

	"int mvwaddnstr (WINDOW *, int, int, const char *, int);"

	<category: 'C call-outs'>
	<cCall: 'mvwaddnstr' returning: #int
	args: #(#self #int #int #string #int )>
	
    ]

    mvwaddstr: anInt1 x: anInt2 str: aString [
	"I copy the string given to me into my window starting at the
	 location given to me as a point. See the man(3) mvwaddstr entry
	 for a description of my c function call."

	"int mvwaddstr (WINDOW *, int, int, const char *);"

	<category: 'C call-outs'>
	<cCall: 'mvwaddstr' returning: #int
	args: #(#self #int #int #string )>
	
    ]

    mvwchgat: anInt1 x: anInt2 n: anInt3 attr: anInt4 color: anInt5 opts: cObject [
	"I change the color and attribute of next n characters in my
	 window starting at the location specified by the point given to
	 me. See the man(3) mvwchgat entry for a description of my c
	 function call."

	"int mvwchgat (WINDOW *, int, int, int, attr_t, short, const void *);"

	<category: 'C call-outs'>
	<cCall: 'mvwchgat' returning: #int 
        args: #(#self #int #int #int #int #int #cObject )>
	
    ]

    mvwdelch: anInt1 x: anInt2 [
	"I move the cursor to the coordinates given to me in my window,
	 delete the character under the cursor, and then shift the
	 remaining characters in the line one position to the left. See
	 the man(3) mvwdelch entry for description of my c function call."

	"int mvwdelch (WINDOW *, int, int);"

	<category: 'C call-outs'>
	<cCall: 'mvwdelch' returning: #int
	args: #(#self #int #int )>
	
    ]

    mvwgetch: anInt1 x: anInt2 [
	"I position the cursor to the location in my window specified by
	 the point given to me, I read a character. See the man(3)
	 mvwgetch entry for a description of my c function call."

	"int mvwgetch (WINDOW *, int, int);"

	<category: 'C call-outs'>
	<cCall: 'mvwgetch' returning: #int
	args: #(#self #int #int )>
	
    ]

    mvwgetnstr: anInt1 x: anInt2 str: aString n: anInt3 [
	"I position the cursor to the location in my window specified by
	 the coordinates given to me, and then I read at most n characters
	 until a carriage return or newline is pressed. See the man(3)
	 mvwgetnstr entry for a description of my c function call."

	"int mvwgetnstr (WINDOW *, int, int, char *, int);"

	<category: 'C call-outs'>
	<cCall: 'mvwgetnstr' returning: #int
	args: #(#self #int #int #string #int )>
	
    ]

    mvwgetstr: anInt1 x: anInt2 str: aString [
	"I position the cursor to the location in my window specified by
	 the coordinates given to me, and thenI read characters until a
	 carriage return or a newline is pressed. See man(3) mvwgetstr
	 entry for a description of my c function call."

	"int mvwgetstr (WINDOW *, int, int, char *);"

	<category: 'C call-outs'>
	<cCall: 'mvwgetstr' returning: #int
	args: #(#self #int #int #string )>
	
    ]

    mvwhline: anInt1 x: anInt2 ch: aChar n: anInt3 [
	"I position the cursor to the location in my window specified by
	 the coordinates given to me, and then I write a horizontal line
	 of at most n characters comprised of the character given to me.
	 See the man(3) mvwhline entry for a description of my c function
	 call."

	"int mvwhline (WINDOW *, int, int, chtype, int);"

	<category: 'C call-outs'>
	<cCall: 'mvwhline' returning: #int
	args: #(#self #int #int #char #int )>
	
    ]

    mvwin: anInt1 x: anInt2 [
	"I move the top-left-corner of my window to the location given to
	 me as coordinates. See the man(3) mvwin entry for a description
	 of my c function call."

	"int mvwin (WINDOW *, int, int);"

	<category: 'C call-outs'>
	<cCall: 'mvwin' returning: #int
	args: #(#self #int #int )>
	
    ]

    mvwinch: anInt1 x: anInt2 [
	"I return the character or attribute at the cursor location
	 specifed by the coordinates given to me. See the man(3) mvwinch
	 entry for a description of my c call function."

	"chtype mvwinch (WINDOW *, int, int);"

	<category: 'C call-outs'>
	<cCall: 'mvwinch' returning: #char
	args: #(#self #int #int )>
	
    ]

    mvwinchnstr: anInt1 x: anInt2 str: aString n: anInt3 [
	"I return a null terminated array of characters or attributes from
	 my window of at most n characters starting at the cursor location
	 specified by the coordinates given to me. See the man(3)
	 mvwinchnstr entry for a description of my c function call."

	"int mvwinchnstr (WINDOW *, int, int, chtype *, int);"

	<category: 'C call-outs'>
	<cCall: 'mvwinchnstr' returning: #int
	args: #(#self #int #int #string #int )>
	
    ]

    mvwinchstr: anInt1 x: anInt2 str: aString [
	"I return a null terminated array of characters or attributes from
	 within my window starting at the cursor location given by the
	 coordinates given to me. See the man(3) mvwinchstr entry for a
	 description of my c call function."

	"int mvwinchstr (WINDOW *, int, int, chtype *);"

	<category: 'C call-outs'>
	<cCall: 'mvwinchstr' returning: #int
	args: #(#self #int #int #string )>
	
    ]

    mvwinnstr: anInt1 x: anInt2 str: aString n: anInt3 [
	"I return a string of characters from my window stripped of
	 attributes starting at the location given to me as
	 coordinates. See the man(3) mvwinnstr entry for a description of
	 my c function call."

	"int mvwinnstr (WINDOW *, int, int, char *, int);"

	<category: 'C call-outs'>
	<cCall: 'mvwinnstr' returning: #int
	args: #(#self #int #int #string #int )>
	
    ]

    mvwinsch: anInt1 x: anInt2 ch: aChar [
	"I insert a character in my window before the location given to me
	 as coordinates. The remaining characters in the line are shifted
	 one position to the right. See the man(3) mvwinsch entry for a
	 description of my c function call."

	"int mvwinsch (WINDOW *, int, int, chtype);"

	<category: 'C call-outs'>
	<cCall: 'mvwinsch' returning: #int
	args: #(#self #int #int #char )>
	
    ]

    mvwinsnstr: anInt1 x: anInt2 str: aString n: anInt3 [
	"I insert a string of at most n characters in my window before the
	 location given to me as coordinates. The remaining characters in
	 the line are shifted one position to the right. See the man(3)
	 mvwinsnstr entry for a description of my c function call."

	"int mvwinsnstr (WINDOW *, int, int, const char *, int);"

	<category: 'C call-outs'>
	<cCall: 'mvwinsnstr' returning: #int
	args: #(#self #int #int #string #int )>
	
    ]

    mvwinsstr: anInt1 x: anInt2 str: aString [
	"I insert a string before the location in my window given to me as
	 coordinates.  The remaining characters in the line are shifted
	 one position to the right. See the man(3) mvwinsstr entry for a
	 description of my c function call."

	"int mvwinsstr (WINDOW *, int, int, const char *);"

	<category: 'C call-outs'>
	<cCall: 'mvwinsstr' returning: #int
	args: #(#self #int #int #string )>
	
    ]

    mvwinstr: anInt1 x: anInt2 str: aString [
	"I return a string of characters from my window starting from the
	 location given to me as coordinates. See the man(3) mvwinstr for a
	 description of my c function call."

	"int mvwinstr (WINDOW *, int, int, char *);"

	<category: 'C call-outs'>
	<cCall: 'mvwinstr' returning: #int
	args: #(#self #int #int #string )>
	
    ]

    mvwprintw: anInt1 x: anInt2 str: aString [
	"I print a string in my window at the location given to me as
	 coordinates.  See the man(3) mvwprintw entry for a description of
	 my c function call."

	"int mvwprintw (WINDOW*, int, int, const char *)"

	<category: 'C call-outs'>
	<cCall: 'mvwprintw' returning: #int
	args: #(#self #int #int #string )>
	
    ]

    mvwprintw: anInt1 x: anInt2 str: aString args: anArray [
	"I print a formated string and arguments in my window at the
	 location given to me as coordinates.  See the man(3) mvwprintw
	 entry for a description of my c function call."

	"int mvwprintw (WINDOW*, int, int, const char *, ...)"

	<category: 'C call-outs'>
	<cCall: 'mvwprintw' returning: #int
	args: #(#self #int #int #string #variadic )>
	
    ]

    mvwscanw: anInt1 x: anInt2 str: aString args: anArray [
	"I scan a string from within my window at the location given to me
	 a point. See the man(3) mvwscanw entry for a description of my c
	 function call."

	"int mvwscanw (WINDOW *, int, int, const char *, ...)"

	<category: 'C call-outs'>
	<cCall: 'mvwscanw' returning: #int
	args: #(#self #int #int #string #variadic )>
	
    ]

    mvwvline: anInt1 x: anInt2 ch: aChar n: anInt3 [
	"I position the cursor to the location in my window specified by
	 the coordinates given to me, then I write a vertical line of at
	 most n characters comprised of the character given to me.  See
	 the man(3) mvwvline entry for a description of my c function
	 call."

	"int mvwvline (WINDOW *, int, int, chtype, int);"

	<category: 'C call-outs'>
	<cCall: 'mvwvline' returning: #int
	args: #(#self #int #int #char #int )>
	
    ]

    nodelay: aBoolean [
	"I set getch to be non-blocking in my window if I'm given a value
	 of true. Otherwise I set getch be blocking. See the man(3)
	 nodelay entry for a description of my c function call."

	"int nodelay (WINDOW *, bool);"

	<category: 'C call-outs'>
	<cCall: 'nodelay' returning: #int
	args: #(#self #boolean )>
	
    ]

    notimeout: aBoolean [
	"I turn off the timer for reading an escape sequence by wgetch for
	 my window if I am given the boolean value true.  Otherwise, I
	 turn the timer on. See the man(3) notimeout entry for a
	 description of my c functtion call."

	"int notimeout (WINDOW *, bool);"

	<category: 'C call-outs'>
	<cCall: 'notimeout' returning: #int
	args: #(#self #boolean )>
	
    ]

    overlay: cObject [
	"I overlay the window given to me with my window. See the man(3)
	 overlay entry for a description of my c function call."

	"int overlay (const WINDOW*, WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'overlay' returning: #int
	args: #(#self #cObject )>
	
    ]

    overwrite: cObject [
	"I overwrite the window given to me with my window. See the man(3)
	 overwrite entry for a description of my c function call."

	"int overwrite (const WINDOW*, WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'overwrite' returning: #int
	args: #(#self #cObject )>
	
    ]

    pechochar: aChar [
	"I output a character to the pad in my window. See the man(3)
	 pechochar entry for a description of my c function call."

	"int pechochar (WINDOW *, const chtype);"

	<category: 'C call-outs'>
	<cCall: 'pechochar' returning: #int
	args: #(#self #char )>
	
    ]

    pnoutrefresh: anInt1 pmincol: anInt2 sminrow: anInt3 smincol: anInt4 smaxrow: anInt5 smaxcol: anInt6 [
	"I copy my windows pad to the virtual screen. See the man(3)
	 pnoutrefresh entry for a description of my c function call."

	"int pnoutrefresh (WINDOW*, int, int, int, int, int, int);"

	<category: 'C call-outs'>
	<cCall: 'pnoutrefresh' returning: #int
	args: #(#self #int #int #int #int #int #int )>
	
    ]

    prefresh: anInt1 pmincol: anInt2 sminrow: anInt3 smincol: anInt4 smaxrow: anInt5 smaxcol: anInt6 [
	"I copy the pad in my window to the physical screen. See the
	 man(3) entry for a description of my c function call."

	"int prefresh (WINDOW *, int, int, int, int, int, int);"

	<category: 'C call-outs'>
	<cCall: 'prefresh' returning: #int
	args: #(#self #int #int #int #int #int #int )>
	
    ]

    redrawwin [
	"I tag all the lines in my window to be output during the next
	 refresh.  See the man(3) redrawwin entry for a description of my
	 c function call."

	"int redrawwin (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'redrawwin' returning: #int
	args: #(#self )>
	
    ]

    scroll [
	"I scroll up my window up one line. See the man(3) scroll entry
	 for a description of my c function call."

	"int scroll (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'scroll' returning: #int
	args: #(#self )>
	
    ]

    scrollok: aBoolean [
	"I enable scrolling the window when the cursor is within a scroll
	 region if I am given the boolean value true. Otherwise, I disable
	 scrolling the window when the cursor is in the scroll region."

	"int scrollok (WINDOW *, bool);"

	<category: 'C call-outs'>
	<cCall: 'scrollok' returning: #int
	args: #(#self #boolean )>
	
    ]

    subpad: anInt1 ncols: anInt2 beginY: anInt3 beginX: anInt4 [
	"I create a sub-window within a pad in my window of the given size
	 and location. See the man(3) subpad entry for a description of my
	 c function call."

	"WINDOW *subpad (WINDOW *, int, int, int, int);"

	<category: 'C call-outs'>
	<cCall: 'subpad' returning: #{NCWindow}
	args: #(#self #int #int #int #int )>
	
    ]

    subwin: anInt1 ncols: anInt2 beginY: anInt3 beginX: anInt4 [
	"I create a new sub-window with m y window of the given size and
	 location.  See the man(3) subwin entry for a description of my c
	 function call."

	"WINDOW *subwin (WINDOW *, int, int, int, int);"

	<category: 'C call-outs'>
	<cCall: 'subwin' returning: #{NCWindow}
	args: #(#self #int #int #int #int )>
	
    ]

    syncok: aBoolean [
	"I enable the automatic updating of ancestor windows when a change
	 occurs if my window if given the boolean true value. See the
	 man(3) syncok entry for a description of my c function call."

	"int syncok (WINDOW *, bool);"

	<category: 'C call-outs'>
	<cCall: 'syncok' returning: #int 
	args: #(#self #boolean )>
	
    ]

    touchline: anInt1 count: anInt2 [
	"I configure the lines in my window given to me to be redrawn
	 during the next refresh.  See the man(3) touchline entry for a
	 description of my c function call."

	"int touchline (WINDOW *, int, int);"

	<category: 'C call-outs'>
	<cCall: 'touchline' returning: #int 
	args: #(#self #int #int )>
	
    ]

    touchwin [
	"I configure my window to be to be redraw during the next refresh.
	 See the man(3) touchwin entry for a description of my c function
	 call."

	"int touchwin (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'touchwin' returning: #int
	args: #(#self )>
	
    ]

    untouchwin [
	"I mark all the lines in my windows as untouched since the last
	 refresh. See the man(3) untouchwin entry for a description of my c
	 function call."

	"int untouchwin (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'untouchwin' returning: #int 
	args: #(#self )>
	
    ]

    waddch: aChar [
	"I add a character given to me to my window at the current cursor
	 location and then advance the cursor. See the man(3) waddch entry
	 for a description of my c function call."

	"int waddch (WINDOW *, const chtype);"

	<category: 'C call-outs'>
	<cCall: 'waddch' returning: #int 
	args: #(#self #char )>
	
    ]

    waddchnstr: aString n: anInt [
	"I copy up to n characters of the string and attributes given to
	 me into my window starting at the location specified by the
	 coordinates given to me. See the man(3) mvwaddchnstr entry for a
	 description of my c function call."

	"int waddchnstr (WINDOW *, const chtype *, int);"

	<category: 'C call-outs'>
	<cCall: 'waddchnstr' returning: #int
	args: #(#self #string #int )>
	
    ]

    waddchstr: aString [
	"I copy the string and attributes given to me into my window. See
	 the man(3) waddchstr entry for a description of my c function
	 call."

	"int waddchstr (WINDOW *, const chtype *);"

	<category: 'C call-outs'>
	<cCall: 'waddchstr' returning: #int 
	args: #(#self #string )>
	
    ]

    waddnstr: aString n: anInt [
	"I copy up to n characters of the string given to me in my window.
	 See the man(3) waddnstr entry for a description of my c function
	 call."

	"int waddnstr (WINDOW *, const char *, int);"

	<category: 'C call-outs'>
	<cCall: 'waddnstr' returning: #int 
	args: #(#self #string #int )>
	
    ]

    waddstr: aString [
	"I copy the string given to me into my window. See the man(3)
	 waddstr entry for a description of my c function call."

	"int waddstr (WINDOW *, const char *);"

	<category: 'C call-outs'>
	<cCall: 'waddstr' returning: #int 
	args: #(#self #string )>
	
    ]

    wattrGet: cObject2 opts: cObject3 [
	"I return the attribute and color pair for my window. See the
	 man(3) wattr_get entry for a description of my c function call."

	"int wattr_get (WINDOW *, attr_t *, short *, void *);"

	<category: 'C call-outs'>
	<cCall: 'wattr_get' returning: #int 
	args: #(#self #cObject #cObject #cObject )>
	
    ]

    wattrOff: anInt opts: cObject [
	"I turn off the attributes given to me for my window. See the
	 man(3) wattr_off entry for a description of my c function call."

	"int wattr_off (WINDOW *, attr_t, void *);"

	<category: 'C call-outs'>
	<cCall: 'wattr_off' returning: #int 
	args: #(#self #int #cObject )>
	
    ]

    wattrOn: anInt opts: cObject [
	"I turn on the named attribute given to me in my window.  See the
	 man(3) wattr_on for a description of my c function call."

	"int wattr_on (WINDOW *, attr_t, void *);"

	<category: 'C call-outs'>
	<cCall: 'wattr_on' returning: #int 
	args: #(#self #int #cObject )>
	
    ]

    wattrSet: anInt1 pair: anInt2 opts: cObject [
	"I set the attribute color-pair in my window to the value given to
	 me. See the man(3) attr_set entry for a description of my c
	 function call."

	"int wattr_set (WINDOW *, attr_t, short, void *);"

	<category: 'C call-outs'>
	<cCall: 'wattr_set' returning: #int 
	args: #(#self #int #int #cObject )>
	
    ]

    wattroff: anInt [
	"I turn off the named attribute given to me in my window.  See the
	 man(3) wattroff for a description of my c function call."

	"int wattroff (WINDOW *, int);"

	<category: 'C call-outs'>
	<cCall: 'wattroff' returning: #int 
	args: #(#self #int )>
	
    ]

    wattron: anInt [
	"I turn on the named attribute given to me in my window.  See the
	 man(3) wattron for a description of my c function call."

	"int wattron (WINDOW *, int);"

	<category: 'C call-outs'>
	<cCall: 'wattron' returning: #int 
	args: #(#self #int )>
	
    ]

    wattrset: anInt [
	"I set the attribute color-pair in my window to the value given to
	 me. See the man(3) wattrset entry for a description of my c
	 function call."

	"int wattrset (WINDOW *, int);"

	<category: 'C call-outs'>
	<cCall: 'wattrset' returning: #int 
	args: #(#self #int )>
	
    ]

    wbkgd: aChar [
	"I set the background attribute given to me to every character in
	 the window.  See the man(3) wbkgd entry for a description of my c
	 function call."

	"int wbkgd (WINDOW *, chtype);"

	<category: 'C call-outs'>
	<cCall: 'wbkgd' returning: #int 
	args: #(#self #char )>
	
    ]

    wbkgdset: aChar [
	"I set the background to to the value given to me to every
	 position in the window.  See the man(3) wbkgdset entry for a
	 description of my c function call."

	"void wbkgdset (WINDOW *, chtype);"

	<category: 'C call-outs'>
	<cCall: 'wbkgdset' returning: #void 
	args: #(#self #char )>
	
    ]

    wborder: aChar1 rs: aChar2 ts: aChar3 bs: aChar4 tl: aChar5 tr: aChar6 bl: aChar7 br: aChar9 [
	"I draw a box around the edge of my window using the character
	 attributes given to me. See the man(3) wborder entry for a
	 description of my c function call."

	"int wborder (WINDOW *, chtype, chtype, chtype, chtype,
	 chtype, chtype, chtype, chtype);"

	<category: 'C call-outs'>
	<cCall: 'wborder' returning: #int 
	args: #(#self #char #char #char #char #char #char #char #char )>
	
    ]

    wchgat: anInt1 attr: anInt2 color: anInt3 opts: cObject [
	"I change the color and attribute in my window. See the man(3)
	 wchgat entry for a description of my c function call."

	"int wchgat (WINDOW *, int, attr_t, short, const void *);"

	<category: 'C call-outs'>
	<cCall: 'wchgat' returning: #int 
	args: #(#self #int #int #int #cObject )>
	
    ]

    wclear [
	"I put a blank in every character position in my window and set up
	 the window to be re-painted the next time that it is
	 refreshed. See the man(3) wclear entry for a description of my c
	 function calls."

	"int wclear (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'wclear' returning: #int 
	args: #(#self )>
	
    ]

    wclrtobot [
	"I erase my window from the right of the current cursor position
	 all the way to the bottom right of the screen. See the man(3)
	 wclrtobot entry for a description of my c function call."

	"int wclrtobot (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'wclrtobot' returning: #int 
	args: #(#self )>
	
    ]

    wclrtoeol [
	"I erase the current line in my window to the right of the current
	 cursor location. See the man(3) wclrtoeol entry for a description
	 of my c function calls."

	"int wclrtoeol (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'wclrtoeol' returning: #int 
	args: #(#self )>
	
    ]

    wcolorSet: anInt opts: cObject [
	"I set the current color of my window to the color pair attribute
	 given to me. See the man(3) wcolor_set entry for a description of
	 my c function call."

	"int wcolor_set (WINDOW*, short, void*);"

	<category: 'C call-outs'>
	<cCall: 'wcolor_set' returning: #int 
	args: #(#self #int #cObject )>
	
    ]

    wcursyncup [
	"I set the cursor position in all of my ancestor windows to the
	 current location in my window. See the man(3) wcursyncup entry for
	 a description of my c function call."

	"void wcursyncup (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'wcursyncup' returning: #void 
	args: #(#self )>
	
    ]

    wdelch [
	"I delete the character under the cursor, and then shift the
	 remaining characters in the line one position to the left. See the
	 man(3) wdelch entry for description of my c function call."

	"int wdelch (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'wdelch' returning: #int 
	args: #(#self )>
	
    ]

    wdeleteln [
	"I delete the line under the current cursor position, move all of
	 the lines below the cursor up one line and clear the last
	 line. See the man(3) wdeleteln entry for a description of my c
	 function call."

	"int wdeleteln (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'wdeleteln' returning: #int 
	args: #(#self )>
	
    ]

    wechochar: aChar [
	"I put the character given to me at the current cursor position,
	 advance the cursor, and then refresh the screen. See the man(3)
	 wechochar entry for a description of my c function call."

	"int wechochar (WINDOW *, const chtype);"

	<category: 'C call-outs'>
	<cCall: 'wechochar' returning: #int 
	args: #(#self #char )>
	
    ]

    werase [
	"I put blanks into every position in the screen. See the man(3)
	 werase entry for a description of my c function call."

	"int werase (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'werase' returning: #int 
	args: #(#self )>
	
    ]

    wgetch [
	"I read a keystroke from my window. See the man(3) wgetch entry
	 for a description of my c function call."

	"int wgetch (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'wgetch' returning: #int 
	args: #(#self )>
	
    ]

    wgetnstr: aString n: anInt [
	"I read at most n keystrokes from nm window until a return or
	 linefeed key is pressed. See the man(3) wgetnstr entry for a
	 description of my c function call."

	"int wgetnstr (WINDOW *, char *, int);"

	<category: 'C call-outs'>
	<cCall: 'wgetnstr' returning: #int 
	args: #(#self #string #int )>
	
    ]

    wgetstr: aString [
	"I read keystrokes from my window until a return or linefeed key
	 is pressed. See the man(3) wgetstr entry for a description of my c
	 function call."

	"int wgetstr (WINDOW *, char *);"

	<category: 'C call-outs'>
	<cCall: 'wgetstr' returning: #int 
	args: #(#self #string )>
	
    ]

    whline: aChar n: anInt [
	"I draw a horizontal line in my window using the character given
	 to me of at most n characters. See the man(3) hline entry for a
	 description of my c function call."

	"int whline (WINDOW *, chtype, int);"

	<category: 'C call-outs'>
	<cCall: 'whline' returning: #int 
	args: #(#self #char #int )>
	
    ]

    winch [
	"I return the character or attribute at the current cursor
	 location in my window. See the man(3) winch entry for a
	 description of my c call function."

	"chtype winch (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'winch' returning: #char 
	args: #(#self )>
	
    ]

    winchnstr: aString n: anInt [
	"I return a null terminated array of characters or attributes from
	 my window of at most n characters starting at the current cursor
	 location. See the man(3) winchnstr entry for a description of my c
	 function call."

	"int winchnstr (WINDOW *, chtype *, int);"

	<category: 'C call-outs'>
	<cCall: 'winchnstr' returning: #int 
	args: #(#self #string #int )>
	
    ]

    winchstr: aString [
	"I return a null terminated array of characters or attributes from
	 within my window starting at the current cursor location. See the
	 man(3) winchstr entry for a description of my c call function."

	"int winchstr (WINDOW *, chtype *);"

	<category: 'C call-outs'>
	<cCall: 'winchstr' returning: #int 
	args: #(#self #string )>
	
    ]

    winnstr: aString n: anInt [
	"I return a string of characters from my window stripped of
	 attributes starting at the current cursor location. See the man(3)
	 winnstr entry for a description of my c function call."

	"int winnstr (WINDOW *, char *, int);"

	<category: 'C call-outs'>
	<cCall: 'winnstr' returning: #int 
	args: #(#self #string #int )>
	
    ]

    winsch: aChar [
	"I insert a character in my window before the current cursor
	 location.  The remaining characters in the line are shifted one
	 position to the right. See the man(3) winsch entry for a
	 description of my c function call."

	"int winsch (WINDOW *, chtype);"

	<category: 'C call-outs'>
	<cCall: 'winsch' returning: #int 
	args: #(#self #char )>
	
    ]

    winsdelln: anInt [
	"I insert the number of blank lines given to me in my window above
	 the current line and delete the same number of lines from the
	 bottom. See the man(3) winsdelln entry for a description of my c
	 function call."

	"int winsdelln (WINDOW *, int);"

	<category: 'C call-outs'>
	<cCall: 'winsdelln' returning: #int 
	args: #(#self #int )>
	
    ]

    winsertln [
	"I insert a blank line in my window above the current line and
	 delete the bottom line. See the man(3) winsertln entry for a
	 description of my c function call."

	"int winsertln (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'winsertln' returning: #int 
	args: #(#self )>
	
    ]

    winsnstr: aString n: anInt [
	"I insert a string of at most n characters in my window before the
	 location of the current cursor. The remaining characters in the
	 line are shifted one position to the right. See the man(3)
	 winsnstr entry for a description of my c function call."

	"int winsnstr (WINDOW *, const char *, int);"

	<category: 'C call-outs'>
	<cCall: 'winsnstr' returning: #int 
	args: #(#self #string #int )>
	
    ]

    winsstr: aString [
	"I insert a string before the location of the cursor in my window.
	 The remaining characters in the line are shifted one position to
	 the right. See the man(3) winsstr entry for a description of my c
	 function call."

	"int winsstr (WINDOW *, const char *);"

	<category: 'C call-outs'>
	<cCall: 'winsstr' returning: #int 
	args: #(#self #string )>
	
    ]

    winstr: aString [
	"I return a string of characters from my window starting from the
	 location of the cursor. See the man(3) mvwinstr for a description
	 of my c function call."

	"int winstr (WINDOW *, char *);"

	<category: 'C call-outs'>
	<cCall: 'winstr' returning: #int 
	args: #(#self #string )>
	
    ]

    wmove: anInt1 x: anInt2 [
	"I move the cursor in my window to the position given to me. See
	 the man(3) wmove entry for a description of my c function call."

	"int wmove (WINDOW *, int, int);"

	<category: 'C call-outs'>
	<cCall: 'wmove' returning: #int 
	args: #(#self #int #int )>
	
    ]

    wnoutrefresh [
	"I update the virtual screen with the contents of my window. See
	 the man(3) wnoutrefresh entry for a description of my c function
	 call."

	"int wnoutrefresh (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'wnoutrefresh' returning: #int 
	args: #(#self )>
	
    ]

    wprintw: aString [
	"I print a string in my window at the location of the cursor.  See
	 the man(3) wprintw entry for a description of my c function call."

	"int wprintw (WINDOW *, const char *, ...)"

	<category: 'C call-outs'>
	<cCall: 'wprintw' returning: #int 
	args: #(#self #string )>
	
    ]

    wprintw: aString args: anArray [
	"I print string and arguments in my window at the location of the
	 cursor.  See the man(3) wprintw entry for a description of my c
	 function call."

	"int wprintw (WINDOW *, const char *, ...)"

	<category: 'C call-outs'>
	<cCall: 'wprintw' returning: #int 
	args: #(#self #string #variadic)>
	
    ]

    wredrawln: anInt1 x: anInt2 [
	"I mark the lines given to me in window to be redrawn by the next
	 refresh. See the man(3) wredrawln entry for a description for my c
	 function call."

	"int wredrawln (WINDOW *, int, int);"

	<category: 'C call-outs'>
	<cCall: 'wredrawln' returning: #int 
	args: #(#self #int #int )>
	
    ]

    wrefresh [
	"I copy my window to the physical screen. See the man(3) wrefresh
	 entry for a description of my c function call."

	"int wrefresh (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'wrefresh' returning: #int 
	args: #(#self )>
	
    ]

    wresize: anInt1 columns: anInt2 [
	"I adjust my window to the dimensions given to me. See the man(3)
	 wresize entry for a description of my c function call."

	"int wresize (WINDOW *, int, int);"

	<category: 'C call-outs'>
	<cCall: 'wresize' returning: #int 
	args: #(#self #int #int)>
	
    ]

    wscanw: aString args: anArray [
	"I scan a string from within my window at the location of the
	 cursor See the man(3) mvwscanw entry for a description of my c
	 function call."

	"int wscanw (WINDOW *, const char *, ...)"

	<category: 'C call-outs'>
	<cCall: 'wscanw' returning: #int 
	args: #(#self #string #variadic)>
	
    ]

    wscrl: anInt [
	"I scroll up my window the number of lines given to me. See the
	 man(3) wscrl entry for a description of my c function call."

	"int wscrl (WINDOW *, int);"

	<category: 'C call-outs'>
	<cCall: 'wscrl' returning: #int 
	args: #(#self #int )>
	
    ]

    wsetscrreg: anInt1 x: anInt2 [
	"I enable a scroll region within my window between the top and
	 bottom lines given to me. See the man(3) wsetscrreg entry for a
	 description of my c function call."

	"int wsetscrreg (WINDOW *, int, int);"

	<category: 'C call-outs'>
	<cCall: 'wsetscrreg' returning: #int 
	args: #(#self #int #int )>
	
    ]

    wstandend [
	"I turn off all attributes in the window. See the man(3) wstandend
	 entry for a description of my c function call."

	"int wstandend (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'wstandend' returning: #int 
	args: #(#self )>
	
    ]

    wstandout [
	"I turn on the best highlighting available in the window. See the
	 man(3) wstandout entry for a description of my c function call."

	"int wstandout (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'wstandout' returning: #int 
	args: #(#self )>
	
    ]

    wsyncdown [
	"I mark the same lines in my window for refresh as the lines that
	 have been marked for refresh in my ancestor windows. See the
	 man(3) wsyncdown entry for a description of my c function call."

	"void wsyncdown (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'wsyncdown' returning: #void 
	args: #(#self )>
	
    ]

    wsyncup [
	"I mark the same lines in my ancestore windows for refresh as the
	 lines that have been marked for refresh in my window. See the
	 man(3) wsyncup entry for a description of my c function call."

	"void wsyncup (WINDOW *);"

	<category: 'C call-outs'>
	<cCall: 'wsyncup' returning: #void 
	args: #(#self )>
	
    ]

    wtimeout: anInt [
	"I configure blocking and non-blocking reads in the window based
	 on the value given to me. See the man(3) wtimeout entry for a
	 description of my c function call."

	"void wtimeout (WINDOW *, int);"

	<category: 'C call-outs'>
	<cCall: 'wtimeout' returning: #void 
	args: #(#self #int )>
	
    ]

    wtouchln: anInt1 n: anInt2 changed: anInt3 [
	"I mark/unmark the number of lines in my window for refresh given
	 to me. See the man(3) wtouchln for a description of my c function
	 call."

	"int wtouchln (WINDOW *, int, int, int);"

	<category: 'C call-outs'>
	<cCall: 'wtouchln' returning: #int 
	args: #(#self #int #int #int )>
	
    ]

    wvline: aChar n: anInt [
	"I write a vertical line of at most n characters comprised of the
	 character given to me. See the man(3) wvline entry for a
	 description of my c function call."

	"int wvline (WINDOW *, chtype, int);"

	<category: 'C call-outs'>
	<cCall: 'wvline' returning: #int 
	args: #(#self #char #int )>
	
    ]
]

