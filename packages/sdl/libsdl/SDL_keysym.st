"======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
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
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlKeySym
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Core'! !

!SdlKeySym class methodsFor: 'Constants'!

sdlkUnknown
    ^0!

sdlkFirst
    ^0!

sdlkBackspace
    ^8!

sdlkTab
    ^9!

sdlkClear
    ^12!

sdlkReturn
    ^13!

sdlkPause
    ^19!

sdlkEscape
    ^27!

sdlkSpace
    ^32!

sdlkExclaim
    ^33!

sdlkQuotedbl
    ^34!

sdlkHash
    ^35!

sdlkDollar
    ^36!

sdlkAmpersand
    ^38!

sdlkQuote
    ^39!

sdlkLeftparen
    ^40!

sdlkRightparen
    ^41!

sdlkAsterisk
    ^42!

sdlkPlus
    ^43!

sdlkComma
    ^44!

sdlkMinus
    ^45!

sdlkPeriod
    ^46!

sdlkSlash
    ^47!

sdlk0
    ^48!

sdlk1
    ^49!

sdlk2
    ^50!

sdlk3
    ^51!

sdlk4
    ^52!

sdlk5
    ^53!

sdlk6
    ^54!

sdlk7
    ^55!

sdlk8
    ^56!

sdlk9
    ^57!

sdlkColon
    ^58!

sdlkSemicolon
    ^59!

sdlkLess
    ^60!

sdlkEquals
    ^61!

sdlkGreater
    ^62!

sdlkQuestion
    ^63!

sdlkAt
    ^64!

sdlkLeftbracket
    ^91!

sdlkBackslash
    ^92!

sdlkRightbracket
    ^93!

sdlkCaret
    ^94!

sdlkUnderscore
    ^95!

sdlkBackquote
    ^96!

sdlkA
    ^97!

sdlkB
    ^98!

sdlkC
    ^99!

sdlkD
    ^100!

sdlkE
    ^101!

sdlkF
    ^102!

sdlkG
    ^103!

sdlkH
    ^104!

sdlkI
    ^105!

sdlkJ
    ^106!

sdlkK
    ^107!

sdlkL
    ^108!

sdlkM
    ^109!

sdlkN
    ^110!

sdlkO
    ^111!

sdlkP
    ^112!

sdlkQ
    ^113!

sdlkR
    ^114!

sdlkS
    ^115!

sdlkT
    ^116!

sdlkU
    ^117!

sdlkV
    ^118!

sdlkW
    ^119!

sdlkX
    ^120!

sdlkY
    ^121!

sdlkZ
    ^122!

sdlkDelete
    ^127!

sdlkWorld0
    ^160!

sdlkWorld1
    ^161!

sdlkWorld2
    ^162!

sdlkWorld3
    ^163!

sdlkWorld4
    ^164!

sdlkWorld5
    ^165!

sdlkWorld6
    ^166!

sdlkWorld7
    ^167!

sdlkWorld8
    ^168!

sdlkWorld9
    ^169!

sdlkWorld10
    ^170!

sdlkWorld11
    ^171!

sdlkWorld12
    ^172!

sdlkWorld13
    ^173!

sdlkWorld14
    ^174!

sdlkWorld15
    ^175!

sdlkWorld16
    ^176!

sdlkWorld17
    ^177!

sdlkWorld18
    ^178!

sdlkWorld19
    ^179!

sdlkWorld20
    ^180!

sdlkWorld21
    ^181!

sdlkWorld22
    ^182!

sdlkWorld23
    ^183!

sdlkWorld24
    ^184!

sdlkWorld25
    ^185!

sdlkWorld26
    ^186!

sdlkWorld27
    ^187!

sdlkWorld28
    ^188!

sdlkWorld29
    ^189!

sdlkWorld30
    ^190!

sdlkWorld31
    ^191!

sdlkWorld32
    ^192!

sdlkWorld33
    ^193!

sdlkWorld34
    ^194!

sdlkWorld35
    ^195!

sdlkWorld36
    ^196!

sdlkWorld37
    ^197!

sdlkWorld38
    ^198!

sdlkWorld39
    ^199!

sdlkWorld40
    ^200!

sdlkWorld41
    ^201!

sdlkWorld42
    ^202!

sdlkWorld43
    ^203!

sdlkWorld44
    ^204!

sdlkWorld45
    ^205!

sdlkWorld46
    ^206!

sdlkWorld47
    ^207!

sdlkWorld48
    ^208!

sdlkWorld49
    ^209!

sdlkWorld50
    ^210!

sdlkWorld51
    ^211!

sdlkWorld52
    ^212!

sdlkWorld53
    ^213!

sdlkWorld54
    ^214!

sdlkWorld55
    ^215!

sdlkWorld56
    ^216!

sdlkWorld57
    ^217!

sdlkWorld58
    ^218!

sdlkWorld59
    ^219!

sdlkWorld60
    ^220!

sdlkWorld61
    ^221!

sdlkWorld62
    ^222!

sdlkWorld63
    ^223!

sdlkWorld64
    ^224!

sdlkWorld65
    ^225!

sdlkWorld66
    ^226!

sdlkWorld67
    ^227!

sdlkWorld68
    ^228!

sdlkWorld69
    ^229!

sdlkWorld70
    ^230!

sdlkWorld71
    ^231!

sdlkWorld72
    ^232!

sdlkWorld73
    ^233!

sdlkWorld74
    ^234!

sdlkWorld75
    ^235!

sdlkWorld76
    ^236!

sdlkWorld77
    ^237!

sdlkWorld78
    ^238!

sdlkWorld79
    ^239!

sdlkWorld80
    ^240!

sdlkWorld81
    ^241!

sdlkWorld82
    ^242!

sdlkWorld83
    ^243!

sdlkWorld84
    ^244!

sdlkWorld85
    ^245!

sdlkWorld86
    ^246!

sdlkWorld87
    ^247!

sdlkWorld88
    ^248!

sdlkWorld89
    ^249!

sdlkWorld90
    ^250!

sdlkWorld91
    ^251!

sdlkWorld92
    ^252!

sdlkWorld93
    ^253!

sdlkWorld94
    ^254!

sdlkWorld95
    ^255!

sdlkKp0
    ^256!

sdlkKp1
    ^257!

sdlkKp2
    ^258!

sdlkKp3
    ^259!

sdlkKp4
    ^260!

sdlkKp5
    ^261!

sdlkKp6
    ^262!

sdlkKp7
    ^263!

sdlkKp8
    ^264!

sdlkKp9
    ^265!

sdlkKpPeriod
    ^266!

sdlkKpDivide
    ^267!

sdlkKpMultiply
    ^268!

sdlkKpMinus
    ^269!

sdlkKpPlus
    ^270!

sdlkKpEnter
    ^271!

sdlkKpEquals
    ^272!

sdlkUp
    ^273!

sdlkDown
    ^274!

sdlkRight
    ^275!

sdlkLeft
    ^276!

sdlkInsert
    ^277!

sdlkHome
    ^278!

sdlkEnd
    ^279!

sdlkPageup
    ^280!

sdlkPagedown
    ^281!

sdlkF1
    ^282!

sdlkF2
    ^283!

sdlkF3
    ^284!

sdlkF4
    ^285!

sdlkF5
    ^286!

sdlkF6
    ^287!

sdlkF7
    ^288!

sdlkF8
    ^289!

sdlkF9
    ^290!

sdlkF10
    ^291!

sdlkF11
    ^292!

sdlkF12
    ^293!

sdlkF13
    ^294!

sdlkF14
    ^295!

sdlkF15
    ^296!

sdlkNumlock
    ^300!

sdlkCapslock
    ^301!

sdlkScrollock
    ^302!

sdlkRshift
    ^303!

sdlkLshift
    ^304!

sdlkRctrl
    ^305!

sdlkLctrl
    ^306!

sdlkRalt
    ^307!

sdlkLalt
    ^308!

sdlkRmeta
    ^309!

sdlkLmeta
    ^310!

sdlkLsuper
    ^311!

sdlkRsuper
    ^312!

sdlkMode
    ^313!

sdlkCompose
    ^314!

sdlkHelp
    ^315!

sdlkPrint
    ^316!

sdlkSysreq
    ^317!

sdlkBreak
    ^318!

sdlkMenu
    ^319!

sdlkPower
    ^320!

sdlkEuro
    ^321!

sdlkUndo
    ^322!

sdlkLast
    ^0!

kmodNone
    ^16r0000!

kmodLshift
    ^16r0001!

kmodRshift
    ^16r0002!

kmodLctrl
    ^16r0040!

kmodRctrl
    ^16r0080!

kmodLalt
    ^16r0100!

kmodRalt
    ^16r0200!

kmodLmeta
    ^16r0400!

kmodRmeta
    ^16r0800!

kmodNum
    ^16r1000!

kmodCaps
    ^16r2000!

kmodMode
    ^16r4000!

kmodReserved
    ^16r8000!

kmodCtrl
    ^16r0040 | 16r0080!

kmodShift
    ^16r0002 | 16r0040!

kmodAlt
    ^16r0100 | 16r0200!

kmodMeta
    ^16r0400 | 16r0800! !
