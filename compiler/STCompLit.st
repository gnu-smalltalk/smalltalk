"======================================================================
|
|   Smalltalk in Smalltalk compiler constant definitions
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1999, 2000, 2001, 2002 Free Software Foundation, Inc.
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
| GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
| Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
|
 ======================================================================"

Smalltalk at: #VMByteCodeNames put: ((Dictionary new: 75)
    at: #PushReceiverVariable	put: 0;
    at: #PushTemporaryVariable	put: 16;
    at: #PushLitConstant	put: 32;
    at: #PushLitVariable	put: 64;
    at: #PopReceiverVariable	put: 96;
    at: #PopTemporaryVariable	put: 104;
    at: #PushSpecial		put: 112;
    at: #PushNil    		put: 115;
    at: #Push8BitSigned   	put: 116;
    at: #Push8BitUnsigned   	put: 117;
    at: #PushZero   		put: 118;
    at: #ReturnSpecial		put: 120;
    at: #ReturnSelf		put: 120;
    at: #ReturnMethodStackTop	put: 124;
    at: #ReturnContextStackTop	put: 125;
    at: #BigLiteral		put: 126;
    at: #PushIndexed		put: 128;
    at: #StoreIndexed		put: 129;
    at: #PopStoreIndexed	put: 130;
    at: #SendSelector1ExtByte	put: 131;
    at: #SendSelector2ExtByte	put: 132;
    at: #SendSuper1ExtByte	put: 133;
    at: #BigInstance		put: 134;
    at: #PopStackTop		put: 135;
    at: #DupStackTop		put: 136;
    at: #PushActiveContext	put: 137;
    at: #OuterVar     		put: 138;
    at: #Nop		     	put: 139;
    at: #ReplaceSelf	     	put: 140;
    at: #ReplaceOne	    	put: 141;
    at: #ReplaceIndexed	   	put: 142;
    at: #JumpShort		put: 144;
    at: #PopJumpFalseShort	put: 152;
    at: #JumpLong		put: 160;
    at: #PopJumpTrue		put: 168;
    at: #PopJumpFalse		put: 172;
    at: #SendSpecial		put: 176;
    at: #BlockCopyColonSpecial	put: 200;
    at: #NewColonSpecial	put: 205;
    at: #SendSelectorShort	put: 208;
    yourself).

Smalltalk at: #VMOtherConstants put: ((Dictionary new: 39)
    at: #ReceiverIndex			put: 0;
    at: #TrueIndex			put: 1;
    at: #FalseIndex			put: 2;
    at: #NilIndex			put: 3;
    at: #LiteralZeroIndex		put: 6;
    at: #LiteralOneIndex		put: 7;

    at: #PushLiteral			put: 0;
    at: #PopStoreIntoArray		put: 0;
    at: #PushVariable			put: 64;
    at: #PopStoreVariable		put: 128;
    at: #StoreVariable			put: 192;

    at: #ReceiverLocation		put: 0;
    at: #TemporaryLocation		put: 64;
    at: #LiteralConstantLocation	put: 128;
    at: #LiteralVariableLocation	put: 192;
    yourself)!

VMOtherConstants at: #VMSpecialSelectors put: ((IdentityDictionary new: 65)
    at: #+				put: 0;
    at: #-			    	put: 1;
    at: #<			    	put: 2;
    at: #>			    	put: 3;
    at: #<=				put: 4;
    at: #>=				put: 5;
    at: #=				put: 6;
    at: #~=				put: 7;
    at: #*				put: 8;
    at: #/				put: 9;
    at: #\\				put: 10;
    at: #bitShift:			put: 12;
    at: #//				put: 13;
    at: #bitAnd:			put: 14;
    at: #bitOr:				put: 15;
    at: #at:				put: 16;
    at: #at:put:			put: 17;
    at: #size				put: 18;
    at: #next				put: 19;
    at: #nextPut:			put: 20;
    at: #atEnd				put: 21;
    at: #==				put: 22;
    at: #class				put: 23;
    at: #blockCopy:temporaries:		put: 24;
    at: #value				put: 25;
    at: #value:				put: 26;
    at: #do:				put: 27;
    at: #new				put: 28;
    at: #new:				put: 29;
    at: #isNil				put: 30;
    at: #notNil				put: 31;
    yourself).

VMOtherConstants at: #VMSpecialIdentifiers put: ((LookupTable new: 19)
    at: 'self'		put: 0;
    at: 'true'		put: 1;
    at: 'false'		put: 2;
    at: 'nil'		put: 3;
    at: 'thisContext'	put: 25;

    at: 'super'		put: -1;
    yourself).
    
VMOtherConstants at: #VMSpecialMethods put: ((IdentityDictionary new: 29)
    at: #whileTrue		put: nil		 ;
    at: #whileFalse		put: nil		 ;
    at: #whileTrue:		put: nil		 ;
    at: #whileFalse:		put: nil		 ;
    at: #timesRepeat:		put: #compileTimesRepeat:;
    at: #to:do:			put: #compileLoop:	 ;
    at: #to:by:do:		put: #compileLoop:	 ;
    at: #ifTrue:		put: #compileBoolean:	 ;
    at: #ifTrue:ifFalse:	put: #compileBoolean:	 ;
    at: #ifFalse:		put: #compileBoolean:	 ;
    at: #ifFalse:ifTrue:	put: #compileBoolean:	 ;
    at: #and:			put: #compileBoolean:	 ;
    at: #or:			put: #compileBoolean:	 ;
    yourself)
!

