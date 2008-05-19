"======================================================================
|
|   OpenGL GLU Method Definitions
|
|
 ======================================================================"

"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Written by Olivier Blanc.
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



OpenGLInterface class extend [

    gluFalse [
	<category: 'constants'>
	^0
    ]

    gluTrue [
	<category: 'constants'>
	^1
    ]

    gluVersion11 [
	<category: 'constants'>
	^1
    ]

    gluVersion12 [
	<category: 'constants'>
	^1
    ]

    gluVersion13 [
	<category: 'constants'>
	^1
    ]

    gluVersion [
	<category: 'constants'>
	^100800
    ]

    gluExtensions [
	<category: 'constants'>
	^100801
    ]

    gluInvalidEnum [
	<category: 'constants'>
	^100900
    ]

    gluInvalidValue [
	<category: 'constants'>
	^100901
    ]

    gluOutOfMemory [
	<category: 'constants'>
	^100902
    ]

    gluIncompatibleGlVersion [
	<category: 'constants'>
	^100903
    ]

    gluInvalidOperation [
	<category: 'constants'>
	^100904
    ]

    gluOutlinePolygon [
	<category: 'constants'>
	^100240
    ]

    gluOutlinePatch [
	<category: 'constants'>
	^100241
    ]

    gluNurbsError [
	<category: 'constants'>
	^100103
    ]

    gluError [
	<category: 'constants'>
	^100103
    ]

    gluNurbsBegin [
	<category: 'constants'>
	^100164
    ]

    gluNurbsBeginExt [
	<category: 'constants'>
	^100164
    ]

    gluNurbsVertex [
	<category: 'constants'>
	^100165
    ]

    gluNurbsVertexExt [
	<category: 'constants'>
	^100165
    ]

    gluNurbsNormal [
	<category: 'constants'>
	^100166
    ]

    gluNurbsNormalExt [
	<category: 'constants'>
	^100166
    ]

    gluNurbsColor [
	<category: 'constants'>
	^100167
    ]

    gluNurbsColorExt [
	<category: 'constants'>
	^100167
    ]

    gluNurbsTextureCoord [
	<category: 'constants'>
	^100168
    ]

    gluNurbsTexCoordExt [
	<category: 'constants'>
	^100168
    ]

    gluNurbsEnd [
	<category: 'constants'>
	^100169
    ]

    gluNurbsEndExt [
	<category: 'constants'>
	^100169
    ]

    gluNurbsBeginData [
	<category: 'constants'>
	^100170
    ]

    gluNurbsBeginDataExt [
	<category: 'constants'>
	^100170
    ]

    gluNurbsVertexData [
	<category: 'constants'>
	^100171
    ]

    gluNurbsVertexDataExt [
	<category: 'constants'>
	^100171
    ]

    gluNurbsNormalData [
	<category: 'constants'>
	^100172
    ]

    gluNurbsNormalDataExt [
	<category: 'constants'>
	^100172
    ]

    gluNurbsColorData [
	<category: 'constants'>
	^100173
    ]

    gluNurbsColorDataExt [
	<category: 'constants'>
	^100173
    ]

    gluNurbsTextureCoordData [
	<category: 'constants'>
	^100174
    ]

    gluNurbsTexCoordDataExt [
	<category: 'constants'>
	^100174
    ]

    gluNurbsEndData [
	<category: 'constants'>
	^100175
    ]

    gluNurbsEndDataExt [
	<category: 'constants'>
	^100175
    ]

    gluNurbsError1 [
	<category: 'constants'>
	^100251
    ]

    gluNurbsError2 [
	<category: 'constants'>
	^100252
    ]

    gluNurbsError3 [
	<category: 'constants'>
	^100253
    ]

    gluNurbsError4 [
	<category: 'constants'>
	^100254
    ]

    gluNurbsError5 [
	<category: 'constants'>
	^100255
    ]

    gluNurbsError6 [
	<category: 'constants'>
	^100256
    ]

    gluNurbsError7 [
	<category: 'constants'>
	^100257
    ]

    gluNurbsError8 [
	<category: 'constants'>
	^100258
    ]

    gluNurbsError9 [
	<category: 'constants'>
	^100259
    ]

    gluNurbsError10 [
	<category: 'constants'>
	^100260
    ]

    gluNurbsError11 [
	<category: 'constants'>
	^100261
    ]

    gluNurbsError12 [
	<category: 'constants'>
	^100262
    ]

    gluNurbsError13 [
	<category: 'constants'>
	^100263
    ]

    gluNurbsError14 [
	<category: 'constants'>
	^100264
    ]

    gluNurbsError15 [
	<category: 'constants'>
	^100265
    ]

    gluNurbsError16 [
	<category: 'constants'>
	^100266
    ]

    gluNurbsError17 [
	<category: 'constants'>
	^100267
    ]

    gluNurbsError18 [
	<category: 'constants'>
	^100268
    ]

    gluNurbsError19 [
	<category: 'constants'>
	^100269
    ]

    gluNurbsError20 [
	<category: 'constants'>
	^100270
    ]

    gluNurbsError21 [
	<category: 'constants'>
	^100271
    ]

    gluNurbsError22 [
	<category: 'constants'>
	^100272
    ]

    gluNurbsError23 [
	<category: 'constants'>
	^100273
    ]

    gluNurbsError24 [
	<category: 'constants'>
	^100274
    ]

    gluNurbsError25 [
	<category: 'constants'>
	^100275
    ]

    gluNurbsError26 [
	<category: 'constants'>
	^100276
    ]

    gluNurbsError27 [
	<category: 'constants'>
	^100277
    ]

    gluNurbsError28 [
	<category: 'constants'>
	^100278
    ]

    gluNurbsError29 [
	<category: 'constants'>
	^100279
    ]

    gluNurbsError30 [
	<category: 'constants'>
	^100280
    ]

    gluNurbsError31 [
	<category: 'constants'>
	^100281
    ]

    gluNurbsError32 [
	<category: 'constants'>
	^100282
    ]

    gluNurbsError33 [
	<category: 'constants'>
	^100283
    ]

    gluNurbsError34 [
	<category: 'constants'>
	^100284
    ]

    gluNurbsError35 [
	<category: 'constants'>
	^100285
    ]

    gluNurbsError36 [
	<category: 'constants'>
	^100286
    ]

    gluNurbsError37 [
	<category: 'constants'>
	^100287
    ]

    gluAutoLoadMatrix [
	<category: 'constants'>
	^100200
    ]

    gluCulling [
	<category: 'constants'>
	^100201
    ]

    gluSamplingTolerance [
	<category: 'constants'>
	^100203
    ]

    gluDisplayMode [
	<category: 'constants'>
	^100204
    ]

    gluParametricTolerance [
	<category: 'constants'>
	^100202
    ]

    gluSamplingMethod [
	<category: 'constants'>
	^100205
    ]

    gluUStep [
	<category: 'constants'>
	^100206
    ]

    gluVStep [
	<category: 'constants'>
	^100207
    ]

    gluNurbsMode [
	<category: 'constants'>
	^100160
    ]

    gluNurbsModeExt [
	<category: 'constants'>
	^100160
    ]

    gluNurbsTessellator [
	<category: 'constants'>
	^100161
    ]

    gluNurbsTessellatorExt [
	<category: 'constants'>
	^100161
    ]

    gluNurbsRenderer [
	<category: 'constants'>
	^100162
    ]

    gluNurbsRendererExt [
	<category: 'constants'>
	^100162
    ]

    gluObjectParametricError [
	<category: 'constants'>
	^100208
    ]

    gluObjectParametricErrorExt [
	<category: 'constants'>
	^100208
    ]

    gluObjectPathLength [
	<category: 'constants'>
	^100209
    ]

    gluObjectPathLengthExt [
	<category: 'constants'>
	^100209
    ]

    gluPathLength [
	<category: 'constants'>
	^100215
    ]

    gluParametricError [
	<category: 'constants'>
	^100216
    ]

    gluDomainDistance [
	<category: 'constants'>
	^100217
    ]

    gluMap1Trim2 [
	<category: 'constants'>
	^100210
    ]

    gluMap1Trim3 [
	<category: 'constants'>
	^100211
    ]

    gluPoint [
	<category: 'constants'>
	^100010
    ]

    gluLine [
	<category: 'constants'>
	^100011
    ]

    gluFill [
	<category: 'constants'>
	^100012
    ]

    gluSilhouette [
	<category: 'constants'>
	^100013
    ]

    gluSmooth [
	<category: 'constants'>
	^100000
    ]

    gluFlat [
	<category: 'constants'>
	^100001
    ]

    gluNone [
	<category: 'constants'>
	^100002
    ]

    gluOutside [
	<category: 'constants'>
	^100020
    ]

    gluInside [
	<category: 'constants'>
	^100021
    ]

    gluTessBegin [
	<category: 'constants'>
	^100100
    ]

    gluBegin [
	<category: 'constants'>
	^100100
    ]

    gluTessVertex [
	<category: 'constants'>
	^100101
    ]

    gluVertex [
	<category: 'constants'>
	^100101
    ]

    gluTessEnd [
	<category: 'constants'>
	^100102
    ]

    gluEnd [
	<category: 'constants'>
	^100102
    ]

    gluTessError [
	<category: 'constants'>
	^100103
    ]

    gluTessEdgeFlag [
	<category: 'constants'>
	^100104
    ]

    gluEdgeFlag [
	<category: 'constants'>
	^100104
    ]

    gluTessCombine [
	<category: 'constants'>
	^100105
    ]

    gluTessBeginData [
	<category: 'constants'>
	^100106
    ]

    gluTessVertexData [
	<category: 'constants'>
	^100107
    ]

    gluTessEndData [
	<category: 'constants'>
	^100108
    ]

    gluTessErrorData [
	<category: 'constants'>
	^100109
    ]

    gluTessEdgeFlagData [
	<category: 'constants'>
	^100110
    ]

    gluTessCombineData [
	<category: 'constants'>
	^100111
    ]

    gluCw [
	<category: 'constants'>
	^100120
    ]

    gluCcw [
	<category: 'constants'>
	^100121
    ]

    gluInterior [
	<category: 'constants'>
	^100122
    ]

    gluExterior [
	<category: 'constants'>
	^100123
    ]

    gluUnknown [
	<category: 'constants'>
	^100124
    ]

    gluTessWindingRule [
	<category: 'constants'>
	^100140
    ]

    gluTessBoundaryOnly [
	<category: 'constants'>
	^100141
    ]

    gluTessTolerance [
	<category: 'constants'>
	^100142
    ]

    gluTessError1 [
	<category: 'constants'>
	^100151
    ]

    gluTessError2 [
	<category: 'constants'>
	^100152
    ]

    gluTessError3 [
	<category: 'constants'>
	^100153
    ]

    gluTessError4 [
	<category: 'constants'>
	^100154
    ]

    gluTessError5 [
	<category: 'constants'>
	^100155
    ]

    gluTessError6 [
	<category: 'constants'>
	^100156
    ]

    gluTessError7 [
	<category: 'constants'>
	^100157
    ]

    gluTessError8 [
	<category: 'constants'>
	^100158
    ]

    gluTessMissingBeginPolygon [
	<category: 'constants'>
	^100151
    ]

    gluTessMissingBeginContour [
	<category: 'constants'>
	^100152
    ]

    gluTessMissingEndPolygon [
	<category: 'constants'>
	^100153
    ]

    gluTessMissingEndContour [
	<category: 'constants'>
	^100154
    ]

    gluTessCoordTooLarge [
	<category: 'constants'>
	^100155
    ]

    gluTessNeedCombineCallback [
	<category: 'constants'>
	^100156
    ]

    gluTessWindingOdd [
	<category: 'constants'>
	^100130
    ]

    gluTessWindingNonzero [
	<category: 'constants'>
	^100131
    ]

    gluTessWindingPositive [
	<category: 'constants'>
	^100132
    ]

    gluTessWindingNegative [
	<category: 'constants'>
	^100133
    ]

    gluTessWindingAbsGeqTwo [
	<category: 'constants'>
	^100134
    ]

    gluTessMaxCoord [
	<category: 'constants'>
	^10014150
    ]

]

