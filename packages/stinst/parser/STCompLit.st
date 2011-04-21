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
| Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.  
|
 ======================================================================"



Eval [
    Smalltalk at: #VMByteCodeNames
	put: ((Dictionary new: 75)
		at: #Send put: 28;
		at: #SendSuper put: 29;
		at: #SendImmediate put: 30;
		at: #SendImmediateSuper put: 31;
		at: #PushTemporaryVariable put: 32;
		at: #PushOuterVariable put: 33;
		at: #PushLitVariable put: 34;
		at: #PushReceiverVariable put: 35;
		at: #StoreTemporaryVariable put: 36;
		at: #StoreOuterVariable put: 37;
		at: #StoreLitVariable put: 38;
		at: #StoreReceiverVariable put: 39;
		at: #JumpBack put: 40;
		at: #Jump put: 41;
		at: #PopJumpTrue put: 42;
		at: #PopJumpFalse put: 43;
		at: #PushInteger put: 44;
		at: #PushSpecial put: 45;
		at: #PushLitConstant put: 46;
		at: #PopStoreIntoArray put: 47;
		at: #PopStackTop put: 48;
		at: #MakeDirtyBlock put: 49;
		at: #ReturnMethodStackTop put: 50;
		at: #ReturnContextStackTop put: 51;
		at: #DupStackTop put: 52;
		at: #LineNumber put: 54;
		at: #ExtByte put: 55;
		at: #PushSelf put: 56;
		yourself).
    Smalltalk at: #VMOtherConstants
	put: ((Dictionary new: 16)
		at: #NilIndex put: 0;
		at: #TrueIndex put: 1;
		at: #FalseIndex put: 2;
		at: #LastImmediateSend put: 24;
		at: #NewColonSpecial put: 32;
		at: #ThisContextSpecial put: 33;
		yourself).
    selectorsMap := IdentityDictionary new: 512.
    CompiledCode specialSelectors keysAndValuesDo: 
	    [:index :selector | 
	    selector isNil ifFalse: [selectorsMap at: selector put: index - 1]].
    VMOtherConstants at: #VMSpecialSelectors put: selectorsMap.
    VMOtherConstants at: #VMSpecialIdentifiers
	put: ((LookupTable new: 8)
		at: 'super' put: [:c | c compileError: 'invalid occurrence of super'];
		at: 'self' put: [:c | c compileByte: VMByteCodeNames.PushSelf];
		at: 'nil'
		    put: 
			[:c | 
			c compileByte: VMByteCodeNames.PushSpecial arg: VMOtherConstants.NilIndex];
		at: 'true'
		    put: 
			[:c | 
			c compileByte: VMByteCodeNames.PushSpecial arg: VMOtherConstants.TrueIndex];
		at: 'false'
		    put: 
			[:c | 
			c compileByte: VMByteCodeNames.PushSpecial arg: VMOtherConstants.FalseIndex];
		at: 'thisContext'
		    put: 
			[:c | 
			c
			    pushLiteralVariable: #{ContextPart};
			    compileByte: VMByteCodeNames.SendImmediate
				arg: VMOtherConstants.ThisContextSpecial];
		yourself).
    VMOtherConstants at: #VMSpecialMethods
	put: ((IdentityDictionary new: 32)
		at: #whileTrue put: #compileWhileLoop:;
		at: #whileFalse put: #compileWhileLoop:;
		at: #whileTrue: put: #compileWhileLoop:;
		at: #whileFalse: put: #compileWhileLoop:;
		at: #repeat put: #compileRepeat:;
		at: #timesRepeat: put: #compileTimesRepeat:;
		at: #to:do: put: #compileLoop:;
		at: #to:by:do: put: #compileLoop:;
		at: #ifTrue: put: #compileBoolean:;
		at: #ifTrue:ifFalse: put: #compileBoolean:;
		at: #ifFalse: put: #compileBoolean:;
		at: #ifFalse:ifTrue: put: #compileBoolean:;
		at: #and: put: #compileBoolean:;
		at: #or: put: #compileBoolean:;
		yourself)
]

