"======================================================================
|
|   Glut Enum Definitions
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

    glVersion11 [
	"GL_VERSION_1_1  1"

	<category: 'constants'>
	^1
    ]

    glVersion12 [
	"GL_VERSION_1_2  1"

	<category: 'constants Ext'>
	^1
    ]

    glVersion13 [
	"GL_VERSION_1_3  1"

	<category: 'constants Ext'>
	^1
    ]

    glFalse [
	"GL_FALSE  0x0"

	<category: 'constants'>
	^0
    ]

    glTrue [
	"GL_TRUE  0x1"

	<category: 'constants'>
	^1
    ]

    glByte [
	"GL_BYTE  0x1400"

	<category: 'constants'>
	^5120
    ]

    glUnsignedByte [
	"GL_UNSIGNED_BYTE  0x1401"

	<category: 'constants'>
	^5121
    ]

    glShort [
	"GL_SHORT  0x1402"

	<category: 'constants'>
	^5122
    ]

    glUnsignedShort [
	"GL_UNSIGNED_SHORT  0x1403"

	<category: 'constants'>
	^5123
    ]

    glInt [
	"GL_INT  0x1404"

	<category: 'constants'>
	^5124
    ]

    glUnsignedInt [
	"GL_UNSIGNED_INT  0x1405"

	<category: 'constants'>
	^5125
    ]

    glFloat [
	"GL_FLOAT  0x1406"

	<category: 'constants'>
	^5126
    ]

    gl2Bytes [
	"GL_2_BYTES  0x1407"

	<category: 'constants'>
	^5127
    ]

    gl3Bytes [
	"GL_3_BYTES  0x1408"

	<category: 'constants'>
	^5128
    ]

    gl4Bytes [
	"GL_4_BYTES  0x1409"

	<category: 'constants'>
	^5129
    ]

    glDouble [
	"GL_DOUBLE  0x140A"

	<category: 'constants'>
	^5130
    ]

    glPoints [
	"GL_POINTS  0x0000"

	<category: 'constants'>
	^0
    ]

    glLines [
	"GL_LINES  0x0001"

	<category: 'constants'>
	^1
    ]

    glLineLoop [
	"GL_LINE_LOOP  0x0002"

	<category: 'constants'>
	^2
    ]

    glLineStrip [
	"GL_LINE_STRIP  0x0003"

	<category: 'constants'>
	^3
    ]

    glTriangles [
	"GL_TRIANGLES  0x0004"

	<category: 'constants'>
	^4
    ]

    glTriangleStrip [
	"GL_TRIANGLE_STRIP  0x0005"

	<category: 'constants'>
	^5
    ]

    glTriangleFan [
	"GL_TRIANGLE_FAN  0x0006"

	<category: 'constants'>
	^6
    ]

    glQuads [
	"GL_QUADS  0x0007"

	<category: 'constants'>
	^7
    ]

    glQuadStrip [
	"GL_QUAD_STRIP  0x0008"

	<category: 'constants'>
	^8
    ]

    glPolygon [
	"GL_POLYGON  0x0009"

	<category: 'constants'>
	^9
    ]

    glVertexArray [
	"GL_VERTEX_ARRAY  0x8074"

	<category: 'constants'>
	^32884
    ]

    glNormalArray [
	"GL_NORMAL_ARRAY  0x8075"

	<category: 'constants'>
	^32885
    ]

    glColorArray [
	"GL_COLOR_ARRAY  0x8076"

	<category: 'constants'>
	^32886
    ]

    glIndexArray [
	"GL_INDEX_ARRAY  0x8077"

	<category: 'constants'>
	^32887
    ]

    glTextureCoordArray [
	"GL_TEXTURE_COORD_ARRAY  0x8078"

	<category: 'constants'>
	^32888
    ]

    glEdgeFlagArray [
	"GL_EDGE_FLAG_ARRAY  0x8079"

	<category: 'constants'>
	^32889
    ]

    glVertexArraySize [
	"GL_VERTEX_ARRAY_SIZE  0x807A"

	<category: 'constants'>
	^32890
    ]

    glVertexArrayType [
	"GL_VERTEX_ARRAY_TYPE  0x807B"

	<category: 'constants'>
	^32891
    ]

    glVertexArrayStride [
	"GL_VERTEX_ARRAY_STRIDE  0x807C"

	<category: 'constants'>
	^32892
    ]

    glNormalArrayType [
	"GL_NORMAL_ARRAY_TYPE  0x807E"

	<category: 'constants'>
	^32894
    ]

    glNormalArrayStride [
	"GL_NORMAL_ARRAY_STRIDE  0x807F"

	<category: 'constants'>
	^32895
    ]

    glColorArraySize [
	"GL_COLOR_ARRAY_SIZE  0x8081"

	<category: 'constants'>
	^32897
    ]

    glColorArrayType [
	"GL_COLOR_ARRAY_TYPE  0x8082"

	<category: 'constants'>
	^32898
    ]

    glColorArrayStride [
	"GL_COLOR_ARRAY_STRIDE  0x8083"

	<category: 'constants'>
	^32899
    ]

    glIndexArrayType [
	"GL_INDEX_ARRAY_TYPE  0x8085"

	<category: 'constants'>
	^32901
    ]

    glIndexArrayStride [
	"GL_INDEX_ARRAY_STRIDE  0x8086"

	<category: 'constants'>
	^32902
    ]

    glTextureCoordArraySize [
	"GL_TEXTURE_COORD_ARRAY_SIZE  0x8088"

	<category: 'constants'>
	^32904
    ]

    glTextureCoordArrayType [
	"GL_TEXTURE_COORD_ARRAY_TYPE  0x8089"

	<category: 'constants'>
	^32905
    ]

    glTextureCoordArrayStride [
	"GL_TEXTURE_COORD_ARRAY_STRIDE  0x808A"

	<category: 'constants'>
	^32906
    ]

    glEdgeFlagArrayStride [
	"GL_EDGE_FLAG_ARRAY_STRIDE  0x808C"

	<category: 'constants'>
	^32908
    ]

    glVertexArrayPointer [
	"GL_VERTEX_ARRAY_POINTER  0x808E"

	<category: 'constants'>
	^32910
    ]

    glNormalArrayPointer [
	"GL_NORMAL_ARRAY_POINTER  0x808F"

	<category: 'constants'>
	^32911
    ]

    glColorArrayPointer [
	"GL_COLOR_ARRAY_POINTER  0x8090"

	<category: 'constants'>
	^32912
    ]

    glIndexArrayPointer [
	"GL_INDEX_ARRAY_POINTER  0x8091"

	<category: 'constants'>
	^32913
    ]

    glTextureCoordArrayPointer [
	"GL_TEXTURE_COORD_ARRAY_POINTER  0x8092"

	<category: 'constants'>
	^32914
    ]

    glEdgeFlagArrayPointer [
	"GL_EDGE_FLAG_ARRAY_POINTER  0x8093"

	<category: 'constants'>
	^32915
    ]

    glV2f [
	"GL_V2F  0x2A20"

	<category: 'constants'>
	^10784
    ]

    glV3f [
	"GL_V3F  0x2A21"

	<category: 'constants'>
	^10785
    ]

    glC4ubV2f [
	"GL_C4UB_V2F  0x2A22"

	<category: 'constants'>
	^10786
    ]

    glC4ubV3f [
	"GL_C4UB_V3F  0x2A23"

	<category: 'constants'>
	^10787
    ]

    glC3fV3f [
	"GL_C3F_V3F  0x2A24"

	<category: 'constants'>
	^10788
    ]

    glN3fV3f [
	"GL_N3F_V3F  0x2A25"

	<category: 'constants'>
	^10789
    ]

    glC4fN3fV3f [
	"GL_C4F_N3F_V3F  0x2A26"

	<category: 'constants'>
	^10790
    ]

    glT2fV3f [
	"GL_T2F_V3F  0x2A27"

	<category: 'constants'>
	^10791
    ]

    glT4fV4f [
	"GL_T4F_V4F  0x2A28"

	<category: 'constants'>
	^10792
    ]

    glT2fC4ubV3f [
	"GL_T2F_C4UB_V3F  0x2A29"

	<category: 'constants'>
	^10793
    ]

    glT2fC3fV3f [
	"GL_T2F_C3F_V3F  0x2A2A"

	<category: 'constants'>
	^10794
    ]

    glT2fN3fV3f [
	"GL_T2F_N3F_V3F  0x2A2B"

	<category: 'constants'>
	^10795
    ]

    glT2fC4fN3fV3f [
	"GL_T2F_C4F_N3F_V3F  0x2A2C"

	<category: 'constants'>
	^10796
    ]

    glT4fC4fN3fV4f [
	"GL_T4F_C4F_N3F_V4F  0x2A2D"

	<category: 'constants'>
	^10797
    ]

    glMatrixMode [
	"GL_MATRIX_MODE  0x0BA0"

	<category: 'constants'>
	^2976
    ]

    glModelview [
	"GL_MODELVIEW  0x1700"

	<category: 'constants'>
	^5888
    ]

    glProjection [
	"GL_PROJECTION  0x1701"

	<category: 'constants'>
	^5889
    ]

    glTexture [
	"GL_TEXTURE  0x1702"

	<category: 'constants'>
	^5890
    ]

    glPointSmooth [
	"GL_POINT_SMOOTH  0x0B10"

	<category: 'constants'>
	^2832
    ]

    glPointSize [
	"GL_POINT_SIZE  0x0B11"

	<category: 'constants'>
	^2833
    ]

    glPointSizeGranularity [
	"GL_POINT_SIZE_GRANULARITY  0x0B13"

	<category: 'constants'>
	^2835
    ]

    glPointSizeRange [
	"GL_POINT_SIZE_RANGE  0x0B12"

	<category: 'constants'>
	^2834
    ]

    glLineSmooth [
	"GL_LINE_SMOOTH  0x0B20"

	<category: 'constants'>
	^2848
    ]

    glLineStipple [
	"GL_LINE_STIPPLE  0x0B24"

	<category: 'constants'>
	^2852
    ]

    glLineStipplePattern [
	"GL_LINE_STIPPLE_PATTERN  0x0B25"

	<category: 'constants'>
	^2853
    ]

    glLineStippleRepeat [
	"GL_LINE_STIPPLE_REPEAT  0x0B26"

	<category: 'constants'>
	^2854
    ]

    glLineWidth [
	"GL_LINE_WIDTH  0x0B21"

	<category: 'constants'>
	^2849
    ]

    glLineWidthGranularity [
	"GL_LINE_WIDTH_GRANULARITY  0x0B23"

	<category: 'constants'>
	^2851
    ]

    glLineWidthRange [
	"GL_LINE_WIDTH_RANGE  0x0B22"

	<category: 'constants'>
	^2850
    ]

    glPoint [
	"GL_POINT  0x1B00"

	<category: 'constants'>
	^6912
    ]

    glLine [
	"GL_LINE  0x1B01"

	<category: 'constants'>
	^6913
    ]

    glFill [
	"GL_FILL  0x1B02"

	<category: 'constants'>
	^6914
    ]

    glCw [
	"GL_CW  0x0900"

	<category: 'constants'>
	^2304
    ]

    glCcw [
	"GL_CCW  0x0901"

	<category: 'constants'>
	^2305
    ]

    glFront [
	"GL_FRONT  0x0404"

	<category: 'constants'>
	^1028
    ]

    glBack [
	"GL_BACK  0x0405"

	<category: 'constants'>
	^1029
    ]

    glPolygonMode [
	"GL_POLYGON_MODE  0x0B40"

	<category: 'constants'>
	^2880
    ]

    glPolygonSmooth [
	"GL_POLYGON_SMOOTH  0x0B41"

	<category: 'constants'>
	^2881
    ]

    glPolygonStipple [
	"GL_POLYGON_STIPPLE  0x0B42"

	<category: 'constants'>
	^2882
    ]

    glEdgeFlag [
	"GL_EDGE_FLAG  0x0B43"

	<category: 'constants'>
	^2883
    ]

    glCullFace [
	"GL_CULL_FACE  0x0B44"

	<category: 'constants'>
	^2884
    ]

    glCullFaceMode [
	"GL_CULL_FACE_MODE  0x0B45"

	<category: 'constants'>
	^2885
    ]

    glFrontFace [
	"GL_FRONT_FACE  0x0B46"

	<category: 'constants'>
	^2886
    ]

    glPolygonOffsetFactor [
	"GL_POLYGON_OFFSET_FACTOR  0x8038"

	<category: 'constants'>
	^32824
    ]

    glPolygonOffsetUnits [
	"GL_POLYGON_OFFSET_UNITS  0x2A00"

	<category: 'constants'>
	^10752
    ]

    glPolygonOffsetPoint [
	"GL_POLYGON_OFFSET_POINT  0x2A01"

	<category: 'constants'>
	^10753
    ]

    glPolygonOffsetLine [
	"GL_POLYGON_OFFSET_LINE  0x2A02"

	<category: 'constants'>
	^10754
    ]

    glPolygonOffsetFill [
	"GL_POLYGON_OFFSET_FILL  0x8037"

	<category: 'constants'>
	^32823
    ]

    glCompile [
	"GL_COMPILE  0x1300"

	<category: 'constants'>
	^4864
    ]

    glCompileAndExecute [
	"GL_COMPILE_AND_EXECUTE  0x1301"

	<category: 'constants'>
	^4865
    ]

    glListBase [
	"GL_LIST_BASE  0x0B32"

	<category: 'constants'>
	^2866
    ]

    glListIndex [
	"GL_LIST_INDEX  0x0B33"

	<category: 'constants'>
	^2867
    ]

    glListMode [
	"GL_LIST_MODE  0x0B30"

	<category: 'constants'>
	^2864
    ]

    glNever [
	"GL_NEVER  0x0200"

	<category: 'constants'>
	^512
    ]

    glLess [
	"GL_LESS  0x0201"

	<category: 'constants'>
	^513
    ]

    glEqual [
	"GL_EQUAL  0x0202"

	<category: 'constants'>
	^514
    ]

    glLequal [
	"GL_LEQUAL  0x0203"

	<category: 'constants'>
	^515
    ]

    glGreater [
	"GL_GREATER  0x0204"

	<category: 'constants'>
	^516
    ]

    glNotequal [
	"GL_NOTEQUAL  0x0205"

	<category: 'constants'>
	^517
    ]

    glGequal [
	"GL_GEQUAL  0x0206"

	<category: 'constants'>
	^518
    ]

    glAlways [
	"GL_ALWAYS  0x0207"

	<category: 'constants'>
	^519
    ]

    glDepthTest [
	"GL_DEPTH_TEST  0x0B71"

	<category: 'constants'>
	^2929
    ]

    glDepthBits [
	"GL_DEPTH_BITS  0x0D56"

	<category: 'constants'>
	^3414
    ]

    glDepthClearValue [
	"GL_DEPTH_CLEAR_VALUE  0x0B73"

	<category: 'constants'>
	^2931
    ]

    glDepthFunc [
	"GL_DEPTH_FUNC  0x0B74"

	<category: 'constants'>
	^2932
    ]

    glDepthRange [
	"GL_DEPTH_RANGE  0x0B70"

	<category: 'constants'>
	^2928
    ]

    glDepthWritemask [
	"GL_DEPTH_WRITEMASK  0x0B72"

	<category: 'constants'>
	^2930
    ]

    glDepthComponent [
	"GL_DEPTH_COMPONENT  0x1902"

	<category: 'constants'>
	^6402
    ]

    glLighting [
	"GL_LIGHTING  0x0B50"

	<category: 'constants'>
	^2896
    ]

    glLight0 [
	"GL_LIGHT0  0x4000"

	<category: 'constants'>
	^16384
    ]

    glLight1 [
	"GL_LIGHT1  0x4001"

	<category: 'constants'>
	^16385
    ]

    glLight2 [
	"GL_LIGHT2  0x4002"

	<category: 'constants'>
	^16386
    ]

    glLight3 [
	"GL_LIGHT3  0x4003"

	<category: 'constants'>
	^16387
    ]

    glLight4 [
	"GL_LIGHT4  0x4004"

	<category: 'constants'>
	^16388
    ]

    glLight5 [
	"GL_LIGHT5  0x4005"

	<category: 'constants'>
	^16389
    ]

    glLight6 [
	"GL_LIGHT6  0x4006"

	<category: 'constants'>
	^16390
    ]

    glLight7 [
	"GL_LIGHT7  0x4007"

	<category: 'constants'>
	^16391
    ]

    glSpotExponent [
	"GL_SPOT_EXPONENT  0x1205"

	<category: 'constants'>
	^4613
    ]

    glSpotCutoff [
	"GL_SPOT_CUTOFF  0x1206"

	<category: 'constants'>
	^4614
    ]

    glConstantAttenuation [
	"GL_CONSTANT_ATTENUATION  0x1207"

	<category: 'constants'>
	^4615
    ]

    glLinearAttenuation [
	"GL_LINEAR_ATTENUATION  0x1208"

	<category: 'constants'>
	^4616
    ]

    glQuadraticAttenuation [
	"GL_QUADRATIC_ATTENUATION  0x1209"

	<category: 'constants'>
	^4617
    ]

    glAmbient [
	"GL_AMBIENT  0x1200"

	<category: 'constants'>
	^4608
    ]

    glDiffuse [
	"GL_DIFFUSE  0x1201"

	<category: 'constants'>
	^4609
    ]

    glSpecular [
	"GL_SPECULAR  0x1202"

	<category: 'constants'>
	^4610
    ]

    glShininess [
	"GL_SHININESS  0x1601"

	<category: 'constants'>
	^5633
    ]

    glEmission [
	"GL_EMISSION  0x1600"

	<category: 'constants'>
	^5632
    ]

    glPosition [
	"GL_POSITION  0x1203"

	<category: 'constants'>
	^4611
    ]

    glSpotDirection [
	"GL_SPOT_DIRECTION  0x1204"

	<category: 'constants'>
	^4612
    ]

    glAmbientAndDiffuse [
	"GL_AMBIENT_AND_DIFFUSE  0x1602"

	<category: 'constants'>
	^5634
    ]

    glColorIndexes [
	"GL_COLOR_INDEXES  0x1603"

	<category: 'constants'>
	^5635
    ]

    glLightModelTwoSide [
	"GL_LIGHT_MODEL_TWO_SIDE  0x0B52"

	<category: 'constants'>
	^2898
    ]

    glLightModelLocalViewer [
	"GL_LIGHT_MODEL_LOCAL_VIEWER  0x0B51"

	<category: 'constants'>
	^2897
    ]

    glLightModelAmbient [
	"GL_LIGHT_MODEL_AMBIENT  0x0B53"

	<category: 'constants'>
	^2899
    ]

    glFrontAndBack [
	"GL_FRONT_AND_BACK  0x0408"

	<category: 'constants'>
	^1032
    ]

    glShadeModel [
	"GL_SHADE_MODEL  0x0B54"

	<category: 'constants'>
	^2900
    ]

    glFlat [
	"GL_FLAT  0x1D00"

	<category: 'constants'>
	^7424
    ]

    glSmooth [
	"GL_SMOOTH  0x1D01"

	<category: 'constants'>
	^7425
    ]

    glColorMaterial [
	"GL_COLOR_MATERIAL  0x0B57"

	<category: 'constants'>
	^2903
    ]

    glColorMaterialFace [
	"GL_COLOR_MATERIAL_FACE  0x0B55"

	<category: 'constants'>
	^2901
    ]

    glColorMaterialParameter [
	"GL_COLOR_MATERIAL_PARAMETER  0x0B56"

	<category: 'constants'>
	^2902
    ]

    glNormalize [
	"GL_NORMALIZE  0x0BA1"

	<category: 'constants'>
	^2977
    ]

    glClipPlane0 [
	"GL_CLIP_PLANE0  0x3000"

	<category: 'constants'>
	^12288
    ]

    glClipPlane1 [
	"GL_CLIP_PLANE1  0x3001"

	<category: 'constants'>
	^12289
    ]

    glClipPlane2 [
	"GL_CLIP_PLANE2  0x3002"

	<category: 'constants'>
	^12290
    ]

    glClipPlane3 [
	"GL_CLIP_PLANE3  0x3003"

	<category: 'constants'>
	^12291
    ]

    glClipPlane4 [
	"GL_CLIP_PLANE4  0x3004"

	<category: 'constants'>
	^12292
    ]

    glClipPlane5 [
	"GL_CLIP_PLANE5  0x3005"

	<category: 'constants'>
	^12293
    ]

    glAccumRedBits [
	"GL_ACCUM_RED_BITS  0x0D58"

	<category: 'constants'>
	^3416
    ]

    glAccumGreenBits [
	"GL_ACCUM_GREEN_BITS  0x0D59"

	<category: 'constants'>
	^3417
    ]

    glAccumBlueBits [
	"GL_ACCUM_BLUE_BITS  0x0D5A"

	<category: 'constants'>
	^3418
    ]

    glAccumAlphaBits [
	"GL_ACCUM_ALPHA_BITS  0x0D5B"

	<category: 'constants'>
	^3419
    ]

    glAccumClearValue [
	"GL_ACCUM_CLEAR_VALUE  0x0B80"

	<category: 'constants'>
	^2944
    ]

    glAccum [
	"GL_ACCUM  0x0100"

	<category: 'constants'>
	^256
    ]

    glAdd [
	"GL_ADD  0x0104"

	<category: 'constants'>
	^260
    ]

    glLoad [
	"GL_LOAD  0x0101"

	<category: 'constants'>
	^257
    ]

    glMult [
	"GL_MULT  0x0103"

	<category: 'constants'>
	^259
    ]

    glReturn [
	"GL_RETURN  0x0102"

	<category: 'constants'>
	^258
    ]

    glAlphaTest [
	"GL_ALPHA_TEST  0x0BC0"

	<category: 'constants'>
	^3008
    ]

    glAlphaTestRef [
	"GL_ALPHA_TEST_REF  0x0BC2"

	<category: 'constants'>
	^3010
    ]

    glAlphaTestFunc [
	"GL_ALPHA_TEST_FUNC  0x0BC1"

	<category: 'constants'>
	^3009
    ]

    glBlend [
	"GL_BLEND  0x0BE2"

	<category: 'constants'>
	^3042
    ]

    glBlendSrc [
	"GL_BLEND_SRC  0x0BE1"

	<category: 'constants'>
	^3041
    ]

    glBlendDst [
	"GL_BLEND_DST  0x0BE0"

	<category: 'constants'>
	^3040
    ]

    glZero [
	"GL_ZERO  0x0"

	<category: 'constants'>
	^0
    ]

    glOne [
	"GL_ONE  0x1"

	<category: 'constants'>
	^1
    ]

    glSrcColor [
	"GL_SRC_COLOR  0x0300"

	<category: 'constants'>
	^768
    ]

    glOneMinusSrcColor [
	"GL_ONE_MINUS_SRC_COLOR  0x0301"

	<category: 'constants'>
	^769
    ]

    glSrcAlpha [
	"GL_SRC_ALPHA  0x0302"

	<category: 'constants'>
	^770
    ]

    glOneMinusSrcAlpha [
	"GL_ONE_MINUS_SRC_ALPHA  0x0303"

	<category: 'constants'>
	^771
    ]

    glDstAlpha [
	"GL_DST_ALPHA  0x0304"

	<category: 'constants'>
	^772
    ]

    glOneMinusDstAlpha [
	"GL_ONE_MINUS_DST_ALPHA  0x0305"

	<category: 'constants'>
	^773
    ]

    glDstColor [
	"GL_DST_COLOR  0x0306"

	<category: 'constants'>
	^774
    ]

    glOneMinusDstColor [
	"GL_ONE_MINUS_DST_COLOR  0x0307"

	<category: 'constants'>
	^775
    ]

    glSrcAlphaSaturate [
	"GL_SRC_ALPHA_SATURATE  0x0308"

	<category: 'constants'>
	^776
    ]

    glFeedback [
	"GL_FEEDBACK  0x1C01"

	<category: 'constants'>
	^7169
    ]

    glRender [
	"GL_RENDER  0x1C00"

	<category: 'constants'>
	^7168
    ]

    glSelect [
	"GL_SELECT  0x1C02"

	<category: 'constants'>
	^7170
    ]

    gl2d [
	"GL_2D  0x0600"

	<category: 'constants'>
	^1536
    ]

    gl3d [
	"GL_3D  0x0601"

	<category: 'constants'>
	^1537
    ]

    gl3dColor [
	"GL_3D_COLOR  0x0602"

	<category: 'constants'>
	^1538
    ]

    gl3dColorTexture [
	"GL_3D_COLOR_TEXTURE  0x0603"

	<category: 'constants'>
	^1539
    ]

    gl4dColorTexture [
	"GL_4D_COLOR_TEXTURE  0x0604"

	<category: 'constants'>
	^1540
    ]

    glPointToken [
	"GL_POINT_TOKEN  0x0701"

	<category: 'constants'>
	^1793
    ]

    glLineToken [
	"GL_LINE_TOKEN  0x0702"

	<category: 'constants'>
	^1794
    ]

    glLineResetToken [
	"GL_LINE_RESET_TOKEN  0x0707"

	<category: 'constants'>
	^1799
    ]

    glPolygonToken [
	"GL_POLYGON_TOKEN  0x0703"

	<category: 'constants'>
	^1795
    ]

    glBitmapToken [
	"GL_BITMAP_TOKEN  0x0704"

	<category: 'constants'>
	^1796
    ]

    glDrawPixelToken [
	"GL_DRAW_PIXEL_TOKEN  0x0705"

	<category: 'constants'>
	^1797
    ]

    glCopyPixelToken [
	"GL_COPY_PIXEL_TOKEN  0x0706"

	<category: 'constants'>
	^1798
    ]

    glPassThroughToken [
	"GL_PASS_THROUGH_TOKEN  0x0700"

	<category: 'constants'>
	^1792
    ]

    glFeedbackBufferPointer [
	"GL_FEEDBACK_BUFFER_POINTER  0x0DF0"

	<category: 'constants'>
	^3568
    ]

    glFeedbackBufferSize [
	"GL_FEEDBACK_BUFFER_SIZE  0x0DF1"

	<category: 'constants'>
	^3569
    ]

    glFeedbackBufferType [
	"GL_FEEDBACK_BUFFER_TYPE  0x0DF2"

	<category: 'constants'>
	^3570
    ]

    glSelectionBufferPointer [
	"GL_SELECTION_BUFFER_POINTER  0x0DF3"

	<category: 'constants'>
	^3571
    ]

    glSelectionBufferSize [
	"GL_SELECTION_BUFFER_SIZE  0x0DF4"

	<category: 'constants'>
	^3572
    ]

    glFog [
	"GL_FOG  0x0B60"

	<category: 'constants'>
	^2912
    ]

    glFogMode [
	"GL_FOG_MODE  0x0B65"

	<category: 'constants'>
	^2917
    ]

    glFogDensity [
	"GL_FOG_DENSITY  0x0B62"

	<category: 'constants'>
	^2914
    ]

    glFogColor [
	"GL_FOG_COLOR  0x0B66"

	<category: 'constants'>
	^2918
    ]

    glFogIndex [
	"GL_FOG_INDEX  0x0B61"

	<category: 'constants'>
	^2913
    ]

    glFogStart [
	"GL_FOG_START  0x0B63"

	<category: 'constants'>
	^2915
    ]

    glFogEnd [
	"GL_FOG_END  0x0B64"

	<category: 'constants'>
	^2916
    ]

    glLinear [
	"GL_LINEAR  0x2601"

	<category: 'constants'>
	^9729
    ]

    glExp [
	"GL_EXP  0x0800"

	<category: 'constants'>
	^2048
    ]

    glExp2 [
	"GL_EXP2  0x0801"

	<category: 'constants'>
	^2049
    ]

    glLogicOp [
	"GL_LOGIC_OP  0x0BF1"

	<category: 'constants'>
	^3057
    ]

    glIndexLogicOp [
	"GL_INDEX_LOGIC_OP  0x0BF1"

	<category: 'constants'>
	^3057
    ]

    glColorLogicOp [
	"GL_COLOR_LOGIC_OP  0x0BF2"

	<category: 'constants'>
	^3058
    ]

    glLogicOpMode [
	"GL_LOGIC_OP_MODE  0x0BF0"

	<category: 'constants'>
	^3056
    ]

    glClear [
	"GL_CLEAR  0x1500"

	<category: 'constants'>
	^5376
    ]

    glSet [
	"GL_SET  0x150F"

	<category: 'constants'>
	^5391
    ]

    glCopy [
	"GL_COPY  0x1503"

	<category: 'constants'>
	^5379
    ]

    glCopyInverted [
	"GL_COPY_INVERTED  0x150C"

	<category: 'constants'>
	^5388
    ]

    glNoop [
	"GL_NOOP  0x1505"

	<category: 'constants'>
	^5381
    ]

    glInvert [
	"GL_INVERT  0x150A"

	<category: 'constants'>
	^5386
    ]

    glAnd [
	"GL_AND  0x1501"

	<category: 'constants'>
	^5377
    ]

    glNand [
	"GL_NAND  0x150E"

	<category: 'constants'>
	^5390
    ]

    glOr [
	"GL_OR  0x1507"

	<category: 'constants'>
	^5383
    ]

    glNor [
	"GL_NOR  0x1508"

	<category: 'constants'>
	^5384
    ]

    glXor [
	"GL_XOR  0x1506"

	<category: 'constants'>
	^5382
    ]

    glEquiv [
	"GL_EQUIV  0x1509"

	<category: 'constants'>
	^5385
    ]

    glAndReverse [
	"GL_AND_REVERSE  0x1502"

	<category: 'constants'>
	^5378
    ]

    glAndInverted [
	"GL_AND_INVERTED  0x1504"

	<category: 'constants'>
	^5380
    ]

    glOrReverse [
	"GL_OR_REVERSE  0x150B"

	<category: 'constants'>
	^5387
    ]

    glOrInverted [
	"GL_OR_INVERTED  0x150D"

	<category: 'constants'>
	^5389
    ]

    glStencilBits [
	"GL_STENCIL_BITS  0x0D57"

	<category: 'constants'>
	^3415
    ]

    glStencilTest [
	"GL_STENCIL_TEST  0x0B90"

	<category: 'constants'>
	^2960
    ]

    glStencilClearValue [
	"GL_STENCIL_CLEAR_VALUE  0x0B91"

	<category: 'constants'>
	^2961
    ]

    glStencilFunc [
	"GL_STENCIL_FUNC  0x0B92"

	<category: 'constants'>
	^2962
    ]

    glStencilValueMask [
	"GL_STENCIL_VALUE_MASK  0x0B93"

	<category: 'constants'>
	^2963
    ]

    glStencilFail [
	"GL_STENCIL_FAIL  0x0B94"

	<category: 'constants'>
	^2964
    ]

    glStencilPassDepthFail [
	"GL_STENCIL_PASS_DEPTH_FAIL  0x0B95"

	<category: 'constants'>
	^2965
    ]

    glStencilPassDepthPass [
	"GL_STENCIL_PASS_DEPTH_PASS  0x0B96"

	<category: 'constants'>
	^2966
    ]

    glStencilRef [
	"GL_STENCIL_REF  0x0B97"

	<category: 'constants'>
	^2967
    ]

    glStencilWritemask [
	"GL_STENCIL_WRITEMASK  0x0B98"

	<category: 'constants'>
	^2968
    ]

    glStencilIndex [
	"GL_STENCIL_INDEX  0x1901"

	<category: 'constants'>
	^6401
    ]

    glKeep [
	"GL_KEEP  0x1E00"

	<category: 'constants'>
	^7680
    ]

    glReplace [
	"GL_REPLACE  0x1E01"

	<category: 'constants'>
	^7681
    ]

    glIncr [
	"GL_INCR  0x1E02"

	<category: 'constants'>
	^7682
    ]

    glDecr [
	"GL_DECR  0x1E03"

	<category: 'constants'>
	^7683
    ]

    glNone [
	"GL_NONE  0x0"

	<category: 'constants'>
	^0
    ]

    glLeft [
	"GL_LEFT  0x0406"

	<category: 'constants'>
	^1030
    ]

    glRight [
	"GL_RIGHT  0x0407"

	<category: 'constants'>
	^1031
    ]

    glFrontLeft [
	"GL_FRONT_LEFT  0x0400"

	<category: 'constants'>
	^1024
    ]

    glFrontRight [
	"GL_FRONT_RIGHT  0x0401"

	<category: 'constants'>
	^1025
    ]

    glBackLeft [
	"GL_BACK_LEFT  0x0402"

	<category: 'constants'>
	^1026
    ]

    glBackRight [
	"GL_BACK_RIGHT  0x0403"

	<category: 'constants'>
	^1027
    ]

    glAux0 [
	"GL_AUX0  0x0409"

	<category: 'constants'>
	^1033
    ]

    glAux1 [
	"GL_AUX1  0x040A"

	<category: 'constants'>
	^1034
    ]

    glAux2 [
	"GL_AUX2  0x040B"

	<category: 'constants'>
	^1035
    ]

    glAux3 [
	"GL_AUX3  0x040C"

	<category: 'constants'>
	^1036
    ]

    glColorIndex [
	"GL_COLOR_INDEX  0x1900"

	<category: 'constants'>
	^6400
    ]

    glRed [
	"GL_RED  0x1903"

	<category: 'constants'>
	^6403
    ]

    glGreen [
	"GL_GREEN  0x1904"

	<category: 'constants'>
	^6404
    ]

    glBlue [
	"GL_BLUE  0x1905"

	<category: 'constants'>
	^6405
    ]

    glAlpha [
	"GL_ALPHA  0x1906"

	<category: 'constants'>
	^6406
    ]

    glLuminance [
	"GL_LUMINANCE  0x1909"

	<category: 'constants'>
	^6409
    ]

    glLuminanceAlpha [
	"GL_LUMINANCE_ALPHA  0x190A"

	<category: 'constants'>
	^6410
    ]

    glAlphaBits [
	"GL_ALPHA_BITS  0x0D55"

	<category: 'constants'>
	^3413
    ]

    glRedBits [
	"GL_RED_BITS  0x0D52"

	<category: 'constants'>
	^3410
    ]

    glGreenBits [
	"GL_GREEN_BITS  0x0D53"

	<category: 'constants'>
	^3411
    ]

    glBlueBits [
	"GL_BLUE_BITS  0x0D54"

	<category: 'constants'>
	^3412
    ]

    glIndexBits [
	"GL_INDEX_BITS  0x0D51"

	<category: 'constants'>
	^3409
    ]

    glSubpixelBits [
	"GL_SUBPIXEL_BITS  0x0D50"

	<category: 'constants'>
	^3408
    ]

    glAuxBuffers [
	"GL_AUX_BUFFERS  0x0C00"

	<category: 'constants'>
	^3072
    ]

    glReadBuffer [
	"GL_READ_BUFFER  0x0C02"

	<category: 'constants'>
	^3074
    ]

    glDrawBuffer [
	"GL_DRAW_BUFFER  0x0C01"

	<category: 'constants'>
	^3073
    ]

    glDoublebuffer [
	"GL_DOUBLEBUFFER  0x0C32"

	<category: 'constants'>
	^3122
    ]

    glStereo [
	"GL_STEREO  0x0C33"

	<category: 'constants'>
	^3123
    ]

    glBitmap [
	"GL_BITMAP  0x1A00"

	<category: 'constants'>
	^6656
    ]

    glColor [
	"GL_COLOR  0x1800"

	<category: 'constants'>
	^6144
    ]

    glDepth [
	"GL_DEPTH  0x1801"

	<category: 'constants'>
	^6145
    ]

    glStencil [
	"GL_STENCIL  0x1802"

	<category: 'constants'>
	^6146
    ]

    glDither [
	"GL_DITHER  0x0BD0"

	<category: 'constants'>
	^3024
    ]

    glRgb [
	"GL_RGB  0x1907"

	<category: 'constants'>
	^6407
    ]

    glRgba [
	"GL_RGBA  0x1908"

	<category: 'constants'>
	^6408
    ]

    glMaxListNesting [
	"GL_MAX_LIST_NESTING  0x0B31"

	<category: 'constants'>
	^2865
    ]

    glMaxEvalOrder [
	"GL_MAX_EVAL_ORDER  0x0D30"

	<category: 'constants'>
	^3376
    ]

    glMaxLights [
	"GL_MAX_LIGHTS  0x0D31"

	<category: 'constants'>
	^3377
    ]

    glMaxClipPlanes [
	"GL_MAX_CLIP_PLANES  0x0D32"

	<category: 'constants'>
	^3378
    ]

    glMaxTextureSize [
	"GL_MAX_TEXTURE_SIZE  0x0D33"

	<category: 'constants'>
	^3379
    ]

    glMaxPixelMapTable [
	"GL_MAX_PIXEL_MAP_TABLE  0x0D34"

	<category: 'constants'>
	^3380
    ]

    glMaxAttribStackDepth [
	"GL_MAX_ATTRIB_STACK_DEPTH  0x0D35"

	<category: 'constants'>
	^3381
    ]

    glMaxModelviewStackDepth [
	"GL_MAX_MODELVIEW_STACK_DEPTH  0x0D36"

	<category: 'constants'>
	^3382
    ]

    glMaxNameStackDepth [
	"GL_MAX_NAME_STACK_DEPTH  0x0D37"

	<category: 'constants'>
	^3383
    ]

    glMaxProjectionStackDepth [
	"GL_MAX_PROJECTION_STACK_DEPTH  0x0D38"

	<category: 'constants'>
	^3384
    ]

    glMaxTextureStackDepth [
	"GL_MAX_TEXTURE_STACK_DEPTH  0x0D39"

	<category: 'constants'>
	^3385
    ]

    glMaxViewportDims [
	"GL_MAX_VIEWPORT_DIMS  0x0D3A"

	<category: 'constants'>
	^3386
    ]

    glMaxClientAttribStackDepth [
	"GL_MAX_CLIENT_ATTRIB_STACK_DEPTH  0x0D3B"

	<category: 'constants'>
	^3387
    ]

    glAttribStackDepth [
	"GL_ATTRIB_STACK_DEPTH  0x0BB0"

	<category: 'constants'>
	^2992
    ]

    glClientAttribStackDepth [
	"GL_CLIENT_ATTRIB_STACK_DEPTH  0x0BB1"

	<category: 'constants'>
	^2993
    ]

    glColorClearValue [
	"GL_COLOR_CLEAR_VALUE  0x0C22"

	<category: 'constants'>
	^3106
    ]

    glColorWritemask [
	"GL_COLOR_WRITEMASK  0x0C23"

	<category: 'constants'>
	^3107
    ]

    glCurrentIndex [
	"GL_CURRENT_INDEX  0x0B01"

	<category: 'constants'>
	^2817
    ]

    glCurrentColor [
	"GL_CURRENT_COLOR  0x0B00"

	<category: 'constants'>
	^2816
    ]

    glCurrentNormal [
	"GL_CURRENT_NORMAL  0x0B02"

	<category: 'constants'>
	^2818
    ]

    glCurrentRasterColor [
	"GL_CURRENT_RASTER_COLOR  0x0B04"

	<category: 'constants'>
	^2820
    ]

    glCurrentRasterDistance [
	"GL_CURRENT_RASTER_DISTANCE  0x0B09"

	<category: 'constants'>
	^2825
    ]

    glCurrentRasterIndex [
	"GL_CURRENT_RASTER_INDEX  0x0B05"

	<category: 'constants'>
	^2821
    ]

    glCurrentRasterPosition [
	"GL_CURRENT_RASTER_POSITION  0x0B07"

	<category: 'constants'>
	^2823
    ]

    glCurrentRasterTextureCoords [
	"GL_CURRENT_RASTER_TEXTURE_COORDS  0x0B06"

	<category: 'constants'>
	^2822
    ]

    glCurrentRasterPositionValid [
	"GL_CURRENT_RASTER_POSITION_VALID  0x0B08"

	<category: 'constants'>
	^2824
    ]

    glCurrentTextureCoords [
	"GL_CURRENT_TEXTURE_COORDS  0x0B03"

	<category: 'constants'>
	^2819
    ]

    glIndexClearValue [
	"GL_INDEX_CLEAR_VALUE  0x0C20"

	<category: 'constants'>
	^3104
    ]

    glIndexMode [
	"GL_INDEX_MODE  0x0C30"

	<category: 'constants'>
	^3120
    ]

    glIndexWritemask [
	"GL_INDEX_WRITEMASK  0x0C21"

	<category: 'constants'>
	^3105
    ]

    glModelviewMatrix [
	"GL_MODELVIEW_MATRIX  0x0BA6"

	<category: 'constants'>
	^2982
    ]

    glModelviewStackDepth [
	"GL_MODELVIEW_STACK_DEPTH  0x0BA3"

	<category: 'constants'>
	^2979
    ]

    glNameStackDepth [
	"GL_NAME_STACK_DEPTH  0x0D70"

	<category: 'constants'>
	^3440
    ]

    glProjectionMatrix [
	"GL_PROJECTION_MATRIX  0x0BA7"

	<category: 'constants'>
	^2983
    ]

    glProjectionStackDepth [
	"GL_PROJECTION_STACK_DEPTH  0x0BA4"

	<category: 'constants'>
	^2980
    ]

    glRenderMode [
	"GL_RENDER_MODE  0x0C40"

	<category: 'constants'>
	^3136
    ]

    glRgbaMode [
	"GL_RGBA_MODE  0x0C31"

	<category: 'constants'>
	^3121
    ]

    glTextureMatrix [
	"GL_TEXTURE_MATRIX  0x0BA8"

	<category: 'constants'>
	^2984
    ]

    glTextureStackDepth [
	"GL_TEXTURE_STACK_DEPTH  0x0BA5"

	<category: 'constants'>
	^2981
    ]

    glViewport [
	"GL_VIEWPORT  0x0BA2"

	<category: 'constants'>
	^2978
    ]

    glAutoNormal [
	"GL_AUTO_NORMAL  0x0D80"

	<category: 'constants'>
	^3456
    ]

    glMap1Color4 [
	"GL_MAP1_COLOR_4  0x0D90"

	<category: 'constants'>
	^3472
    ]

    glMap1Index [
	"GL_MAP1_INDEX  0x0D91"

	<category: 'constants'>
	^3473
    ]

    glMap1Normal [
	"GL_MAP1_NORMAL  0x0D92"

	<category: 'constants'>
	^3474
    ]

    glMap1TextureCoord1 [
	"GL_MAP1_TEXTURE_COORD_1  0x0D93"

	<category: 'constants'>
	^3475
    ]

    glMap1TextureCoord2 [
	"GL_MAP1_TEXTURE_COORD_2  0x0D94"

	<category: 'constants'>
	^3476
    ]

    glMap1TextureCoord3 [
	"GL_MAP1_TEXTURE_COORD_3  0x0D95"

	<category: 'constants'>
	^3477
    ]

    glMap1TextureCoord4 [
	"GL_MAP1_TEXTURE_COORD_4  0x0D96"

	<category: 'constants'>
	^3478
    ]

    glMap1Vertex3 [
	"GL_MAP1_VERTEX_3  0x0D97"

	<category: 'constants'>
	^3479
    ]

    glMap1Vertex4 [
	"GL_MAP1_VERTEX_4  0x0D98"

	<category: 'constants'>
	^3480
    ]

    glMap2Color4 [
	"GL_MAP2_COLOR_4  0x0DB0"

	<category: 'constants'>
	^3504
    ]

    glMap2Index [
	"GL_MAP2_INDEX  0x0DB1"

	<category: 'constants'>
	^3505
    ]

    glMap2Normal [
	"GL_MAP2_NORMAL  0x0DB2"

	<category: 'constants'>
	^3506
    ]

    glMap2TextureCoord1 [
	"GL_MAP2_TEXTURE_COORD_1  0x0DB3"

	<category: 'constants'>
	^3507
    ]

    glMap2TextureCoord2 [
	"GL_MAP2_TEXTURE_COORD_2  0x0DB4"

	<category: 'constants'>
	^3508
    ]

    glMap2TextureCoord3 [
	"GL_MAP2_TEXTURE_COORD_3  0x0DB5"

	<category: 'constants'>
	^3509
    ]

    glMap2TextureCoord4 [
	"GL_MAP2_TEXTURE_COORD_4  0x0DB6"

	<category: 'constants'>
	^3510
    ]

    glMap2Vertex3 [
	"GL_MAP2_VERTEX_3  0x0DB7"

	<category: 'constants'>
	^3511
    ]

    glMap2Vertex4 [
	"GL_MAP2_VERTEX_4  0x0DB8"

	<category: 'constants'>
	^3512
    ]

    glMap1GridDomain [
	"GL_MAP1_GRID_DOMAIN  0x0DD0"

	<category: 'constants'>
	^3536
    ]

    glMap1GridSegments [
	"GL_MAP1_GRID_SEGMENTS  0x0DD1"

	<category: 'constants'>
	^3537
    ]

    glMap2GridDomain [
	"GL_MAP2_GRID_DOMAIN  0x0DD2"

	<category: 'constants'>
	^3538
    ]

    glMap2GridSegments [
	"GL_MAP2_GRID_SEGMENTS  0x0DD3"

	<category: 'constants'>
	^3539
    ]

    glCoeff [
	"GL_COEFF  0x0A00"

	<category: 'constants'>
	^2560
    ]

    glOrder [
	"GL_ORDER  0x0A01"

	<category: 'constants'>
	^2561
    ]

    glDomain [
	"GL_DOMAIN  0x0A02"

	<category: 'constants'>
	^2562
    ]

    glPerspectiveCorrectionHint [
	"GL_PERSPECTIVE_CORRECTION_HINT  0x0C50"

	<category: 'constants'>
	^3152
    ]

    glPointSmoothHint [
	"GL_POINT_SMOOTH_HINT  0x0C51"

	<category: 'constants'>
	^3153
    ]

    glLineSmoothHint [
	"GL_LINE_SMOOTH_HINT  0x0C52"

	<category: 'constants'>
	^3154
    ]

    glPolygonSmoothHint [
	"GL_POLYGON_SMOOTH_HINT  0x0C53"

	<category: 'constants'>
	^3155
    ]

    glFogHint [
	"GL_FOG_HINT  0x0C54"

	<category: 'constants'>
	^3156
    ]

    glDontCare [
	"GL_DONT_CARE  0x1100"

	<category: 'constants'>
	^4352
    ]

    glFastest [
	"GL_FASTEST  0x1101"

	<category: 'constants'>
	^4353
    ]

    glNicest [
	"GL_NICEST  0x1102"

	<category: 'constants'>
	^4354
    ]

    glScissorBox [
	"GL_SCISSOR_BOX  0x0C10"

	<category: 'constants'>
	^3088
    ]

    glScissorTest [
	"GL_SCISSOR_TEST  0x0C11"

	<category: 'constants'>
	^3089
    ]

    glMapColor [
	"GL_MAP_COLOR  0x0D10"

	<category: 'constants'>
	^3344
    ]

    glMapStencil [
	"GL_MAP_STENCIL  0x0D11"

	<category: 'constants'>
	^3345
    ]

    glIndexShift [
	"GL_INDEX_SHIFT  0x0D12"

	<category: 'constants'>
	^3346
    ]

    glIndexOffset [
	"GL_INDEX_OFFSET  0x0D13"

	<category: 'constants'>
	^3347
    ]

    glRedScale [
	"GL_RED_SCALE  0x0D14"

	<category: 'constants'>
	^3348
    ]

    glRedBias [
	"GL_RED_BIAS  0x0D15"

	<category: 'constants'>
	^3349
    ]

    glGreenScale [
	"GL_GREEN_SCALE  0x0D18"

	<category: 'constants'>
	^3352
    ]

    glGreenBias [
	"GL_GREEN_BIAS  0x0D19"

	<category: 'constants'>
	^3353
    ]

    glBlueScale [
	"GL_BLUE_SCALE  0x0D1A"

	<category: 'constants'>
	^3354
    ]

    glBlueBias [
	"GL_BLUE_BIAS  0x0D1B"

	<category: 'constants'>
	^3355
    ]

    glAlphaScale [
	"GL_ALPHA_SCALE  0x0D1C"

	<category: 'constants'>
	^3356
    ]

    glAlphaBias [
	"GL_ALPHA_BIAS  0x0D1D"

	<category: 'constants'>
	^3357
    ]

    glDepthScale [
	"GL_DEPTH_SCALE  0x0D1E"

	<category: 'constants'>
	^3358
    ]

    glDepthBias [
	"GL_DEPTH_BIAS  0x0D1F"

	<category: 'constants'>
	^3359
    ]

    glPixelMapSToSSize [
	"GL_PIXEL_MAP_S_TO_S_SIZE  0x0CB1"

	<category: 'constants'>
	^3249
    ]

    glPixelMapIToISize [
	"GL_PIXEL_MAP_I_TO_I_SIZE  0x0CB0"

	<category: 'constants'>
	^3248
    ]

    glPixelMapIToRSize [
	"GL_PIXEL_MAP_I_TO_R_SIZE  0x0CB2"

	<category: 'constants'>
	^3250
    ]

    glPixelMapIToGSize [
	"GL_PIXEL_MAP_I_TO_G_SIZE  0x0CB3"

	<category: 'constants'>
	^3251
    ]

    glPixelMapIToBSize [
	"GL_PIXEL_MAP_I_TO_B_SIZE  0x0CB4"

	<category: 'constants'>
	^3252
    ]

    glPixelMapIToASize [
	"GL_PIXEL_MAP_I_TO_A_SIZE  0x0CB5"

	<category: 'constants'>
	^3253
    ]

    glPixelMapRToRSize [
	"GL_PIXEL_MAP_R_TO_R_SIZE  0x0CB6"

	<category: 'constants'>
	^3254
    ]

    glPixelMapGToGSize [
	"GL_PIXEL_MAP_G_TO_G_SIZE  0x0CB7"

	<category: 'constants'>
	^3255
    ]

    glPixelMapBToBSize [
	"GL_PIXEL_MAP_B_TO_B_SIZE  0x0CB8"

	<category: 'constants'>
	^3256
    ]

    glPixelMapAToASize [
	"GL_PIXEL_MAP_A_TO_A_SIZE  0x0CB9"

	<category: 'constants'>
	^3257
    ]

    glPixelMapSToS [
	"GL_PIXEL_MAP_S_TO_S  0x0C71"

	<category: 'constants'>
	^3185
    ]

    glPixelMapIToI [
	"GL_PIXEL_MAP_I_TO_I  0x0C70"

	<category: 'constants'>
	^3184
    ]

    glPixelMapIToR [
	"GL_PIXEL_MAP_I_TO_R  0x0C72"

	<category: 'constants'>
	^3186
    ]

    glPixelMapIToG [
	"GL_PIXEL_MAP_I_TO_G  0x0C73"

	<category: 'constants'>
	^3187
    ]

    glPixelMapIToB [
	"GL_PIXEL_MAP_I_TO_B  0x0C74"

	<category: 'constants'>
	^3188
    ]

    glPixelMapIToA [
	"GL_PIXEL_MAP_I_TO_A  0x0C75"

	<category: 'constants'>
	^3189
    ]

    glPixelMapRToR [
	"GL_PIXEL_MAP_R_TO_R  0x0C76"

	<category: 'constants'>
	^3190
    ]

    glPixelMapGToG [
	"GL_PIXEL_MAP_G_TO_G  0x0C77"

	<category: 'constants'>
	^3191
    ]

    glPixelMapBToB [
	"GL_PIXEL_MAP_B_TO_B  0x0C78"

	<category: 'constants'>
	^3192
    ]

    glPixelMapAToA [
	"GL_PIXEL_MAP_A_TO_A  0x0C79"

	<category: 'constants'>
	^3193
    ]

    glPackAlignment [
	"GL_PACK_ALIGNMENT  0x0D05"

	<category: 'constants'>
	^3333
    ]

    glPackLsbFirst [
	"GL_PACK_LSB_FIRST  0x0D01"

	<category: 'constants'>
	^3329
    ]

    glPackRowLength [
	"GL_PACK_ROW_LENGTH  0x0D02"

	<category: 'constants'>
	^3330
    ]

    glPackSkipPixels [
	"GL_PACK_SKIP_PIXELS  0x0D04"

	<category: 'constants'>
	^3332
    ]

    glPackSkipRows [
	"GL_PACK_SKIP_ROWS  0x0D03"

	<category: 'constants'>
	^3331
    ]

    glPackSwapBytes [
	"GL_PACK_SWAP_BYTES  0x0D00"

	<category: 'constants'>
	^3328
    ]

    glUnpackAlignment [
	"GL_UNPACK_ALIGNMENT  0x0CF5"

	<category: 'constants'>
	^3317
    ]

    glUnpackLsbFirst [
	"GL_UNPACK_LSB_FIRST  0x0CF1"

	<category: 'constants'>
	^3313
    ]

    glUnpackRowLength [
	"GL_UNPACK_ROW_LENGTH  0x0CF2"

	<category: 'constants'>
	^3314
    ]

    glUnpackSkipPixels [
	"GL_UNPACK_SKIP_PIXELS  0x0CF4"

	<category: 'constants'>
	^3316
    ]

    glUnpackSkipRows [
	"GL_UNPACK_SKIP_ROWS  0x0CF3"

	<category: 'constants'>
	^3315
    ]

    glUnpackSwapBytes [
	"GL_UNPACK_SWAP_BYTES  0x0CF0"

	<category: 'constants'>
	^3312
    ]

    glZoomX [
	"GL_ZOOM_X  0x0D16"

	<category: 'constants'>
	^3350
    ]

    glZoomY [
	"GL_ZOOM_Y  0x0D17"

	<category: 'constants'>
	^3351
    ]

    glTextureEnv [
	"GL_TEXTURE_ENV  0x2300"

	<category: 'constants'>
	^8960
    ]

    glTextureEnvMode [
	"GL_TEXTURE_ENV_MODE  0x2200"

	<category: 'constants'>
	^8704
    ]

    glTexture1d [
	"GL_TEXTURE_1D  0x0DE0"

	<category: 'constants'>
	^3552
    ]

    glTexture2d [
	"GL_TEXTURE_2D  0x0DE1"

	<category: 'constants'>
	^3553
    ]

    glTextureWrapS [
	"GL_TEXTURE_WRAP_S  0x2802"

	<category: 'constants'>
	^10242
    ]

    glTextureWrapT [
	"GL_TEXTURE_WRAP_T  0x2803"

	<category: 'constants'>
	^10243
    ]

    glTextureMagFilter [
	"GL_TEXTURE_MAG_FILTER  0x2800"

	<category: 'constants'>
	^10240
    ]

    glTextureMinFilter [
	"GL_TEXTURE_MIN_FILTER  0x2801"

	<category: 'constants'>
	^10241
    ]

    glTextureEnvColor [
	"GL_TEXTURE_ENV_COLOR  0x2201"

	<category: 'constants'>
	^8705
    ]

    glTextureGenS [
	"GL_TEXTURE_GEN_S  0x0C60"

	<category: 'constants'>
	^3168
    ]

    glTextureGenT [
	"GL_TEXTURE_GEN_T  0x0C61"

	<category: 'constants'>
	^3169
    ]

    glTextureGenMode [
	"GL_TEXTURE_GEN_MODE  0x2500"

	<category: 'constants'>
	^9472
    ]

    glTextureBorderColor [
	"GL_TEXTURE_BORDER_COLOR  0x1004"

	<category: 'constants'>
	^4100
    ]

    glTextureWidth [
	"GL_TEXTURE_WIDTH  0x1000"

	<category: 'constants'>
	^4096
    ]

    glTextureHeight [
	"GL_TEXTURE_HEIGHT  0x1001"

	<category: 'constants'>
	^4097
    ]

    glTextureBorder [
	"GL_TEXTURE_BORDER  0x1005"

	<category: 'constants'>
	^4101
    ]

    glTextureComponents [
	"GL_TEXTURE_COMPONENTS  0x1003"

	<category: 'constants'>
	^4099
    ]

    glTextureRedSize [
	"GL_TEXTURE_RED_SIZE  0x805C"

	<category: 'constants'>
	^32860
    ]

    glTextureGreenSize [
	"GL_TEXTURE_GREEN_SIZE  0x805D"

	<category: 'constants'>
	^32861
    ]

    glTextureBlueSize [
	"GL_TEXTURE_BLUE_SIZE  0x805E"

	<category: 'constants'>
	^32862
    ]

    glTextureAlphaSize [
	"GL_TEXTURE_ALPHA_SIZE  0x805F"

	<category: 'constants'>
	^32863
    ]

    glTextureLuminanceSize [
	"GL_TEXTURE_LUMINANCE_SIZE  0x8060"

	<category: 'constants'>
	^32864
    ]

    glTextureIntensitySize [
	"GL_TEXTURE_INTENSITY_SIZE  0x8061"

	<category: 'constants'>
	^32865
    ]

    glNearestMipmapNearest [
	"GL_NEAREST_MIPMAP_NEAREST  0x2700"

	<category: 'constants'>
	^9984
    ]

    glNearestMipmapLinear [
	"GL_NEAREST_MIPMAP_LINEAR  0x2702"

	<category: 'constants'>
	^9986
    ]

    glLinearMipmapNearest [
	"GL_LINEAR_MIPMAP_NEAREST  0x2701"

	<category: 'constants'>
	^9985
    ]

    glLinearMipmapLinear [
	"GL_LINEAR_MIPMAP_LINEAR  0x2703"

	<category: 'constants'>
	^9987
    ]

    glObjectLinear [
	"GL_OBJECT_LINEAR  0x2401"

	<category: 'constants'>
	^9217
    ]

    glObjectPlane [
	"GL_OBJECT_PLANE  0x2501"

	<category: 'constants'>
	^9473
    ]

    glEyeLinear [
	"GL_EYE_LINEAR  0x2400"

	<category: 'constants'>
	^9216
    ]

    glEyePlane [
	"GL_EYE_PLANE  0x2502"

	<category: 'constants'>
	^9474
    ]

    glSphereMap [
	"GL_SPHERE_MAP  0x2402"

	<category: 'constants'>
	^9218
    ]

    glDecal [
	"GL_DECAL  0x2101"

	<category: 'constants'>
	^8449
    ]

    glModulate [
	"GL_MODULATE  0x2100"

	<category: 'constants'>
	^8448
    ]

    glNearest [
	"GL_NEAREST  0x2600"

	<category: 'constants'>
	^9728
    ]

    glRepeat [
	"GL_REPEAT  0x2901"

	<category: 'constants'>
	^10497
    ]

    glClamp [
	"GL_CLAMP  0x2900"

	<category: 'constants'>
	^10496
    ]

    glS [
	"GL_S  0x2000"

	<category: 'constants'>
	^8192
    ]

    glT [
	"GL_T  0x2001"

	<category: 'constants'>
	^8193
    ]

    glR [
	"GL_R  0x2002"

	<category: 'constants'>
	^8194
    ]

    glQ [
	"GL_Q  0x2003"

	<category: 'constants'>
	^8195
    ]

    glTextureGenR [
	"GL_TEXTURE_GEN_R  0x0C62"

	<category: 'constants'>
	^3170
    ]

    glTextureGenQ [
	"GL_TEXTURE_GEN_Q  0x0C63"

	<category: 'constants'>
	^3171
    ]

    glVendor [
	"GL_VENDOR  0x1F00"

	<category: 'constants'>
	^7936
    ]

    glRenderer [
	"GL_RENDERER  0x1F01"

	<category: 'constants'>
	^7937
    ]

    glVersion [
	"GL_VERSION  0x1F02"

	<category: 'constants'>
	^7938
    ]

    glExtensions [
	"GL_EXTENSIONS  0x1F03"

	<category: 'constants'>
	^7939
    ]

    glNoError [
	"GL_NO_ERROR  0x0"

	<category: 'constants'>
	^0
    ]

    glInvalidEnum [
	"GL_INVALID_ENUM  0x0500"

	<category: 'constants'>
	^1280
    ]

    glInvalidValue [
	"GL_INVALID_VALUE  0x0501"

	<category: 'constants'>
	^1281
    ]

    glInvalidOperation [
	"GL_INVALID_OPERATION  0x0502"

	<category: 'constants'>
	^1282
    ]

    glStackOverflow [
	"GL_STACK_OVERFLOW  0x0503"

	<category: 'constants'>
	^1283
    ]

    glStackUnderflow [
	"GL_STACK_UNDERFLOW  0x0504"

	<category: 'constants'>
	^1284
    ]

    glOutOfMemory [
	"GL_OUT_OF_MEMORY  0x0505"

	<category: 'constants'>
	^1285
    ]

    glCurrentBit [
	"GL_CURRENT_BIT  0x00000001"

	<category: 'constants'>
	^1
    ]

    glPointBit [
	"GL_POINT_BIT  0x00000002"

	<category: 'constants'>
	^2
    ]

    glLineBit [
	"GL_LINE_BIT  0x00000004"

	<category: 'constants'>
	^4
    ]

    glPolygonBit [
	"GL_POLYGON_BIT  0x00000008"

	<category: 'constants'>
	^8
    ]

    glPolygonStippleBit [
	"GL_POLYGON_STIPPLE_BIT  0x00000010"

	<category: 'constants'>
	^16
    ]

    glPixelModeBit [
	"GL_PIXEL_MODE_BIT  0x00000020"

	<category: 'constants'>
	^32
    ]

    glLightingBit [
	"GL_LIGHTING_BIT  0x00000040"

	<category: 'constants'>
	^64
    ]

    glFogBit [
	"GL_FOG_BIT  0x00000080"

	<category: 'constants'>
	^128
    ]

    glDepthBufferBit [
	"GL_DEPTH_BUFFER_BIT  0x00000100"

	<category: 'constants'>
	^256
    ]

    glAccumBufferBit [
	"GL_ACCUM_BUFFER_BIT  0x00000200"

	<category: 'constants'>
	^512
    ]

    glStencilBufferBit [
	"GL_STENCIL_BUFFER_BIT  0x00000400"

	<category: 'constants'>
	^1024
    ]

    glViewportBit [
	"GL_VIEWPORT_BIT  0x00000800"

	<category: 'constants'>
	^2048
    ]

    glTransformBit [
	"GL_TRANSFORM_BIT  0x00001000"

	<category: 'constants'>
	^4096
    ]

    glEnableBit [
	"GL_ENABLE_BIT  0x00002000"

	<category: 'constants'>
	^8192
    ]

    glColorBufferBit [
	"GL_COLOR_BUFFER_BIT  0x00004000"

	<category: 'constants'>
	^16384
    ]

    glHintBit [
	"GL_HINT_BIT  0x00008000"

	<category: 'constants'>
	^32768
    ]

    glEvalBit [
	"GL_EVAL_BIT  0x00010000"

	<category: 'constants'>
	^65536
    ]

    glListBit [
	"GL_LIST_BIT  0x00020000"

	<category: 'constants'>
	^131072
    ]

    glTextureBit [
	"GL_TEXTURE_BIT  0x00040000"

	<category: 'constants'>
	^262144
    ]

    glScissorBit [
	"GL_SCISSOR_BIT  0x00080000"

	<category: 'constants'>
	^524288
    ]

    glAllAttribBits [
	"GL_ALL_ATTRIB_BITS  0x000FFFFF"

	<category: 'constants'>
	^1048575
    ]

    glProxyTexture1d [
	"GL_PROXY_TEXTURE_1D  0x8063"

	<category: 'constants'>
	^32867
    ]

    glProxyTexture2d [
	"GL_PROXY_TEXTURE_2D  0x8064"

	<category: 'constants'>
	^32868
    ]

    glTexturePriority [
	"GL_TEXTURE_PRIORITY  0x8066"

	<category: 'constants'>
	^32870
    ]

    glTextureResident [
	"GL_TEXTURE_RESIDENT  0x8067"

	<category: 'constants'>
	^32871
    ]

    glTextureBinding1d [
	"GL_TEXTURE_BINDING_1D  0x8068"

	<category: 'constants'>
	^32872
    ]

    glTextureBinding2d [
	"GL_TEXTURE_BINDING_2D  0x8069"

	<category: 'constants'>
	^32873
    ]

    glTextureInternalFormat [
	"GL_TEXTURE_INTERNAL_FORMAT  0x1003"

	<category: 'constants'>
	^4099
    ]

    glAlpha4 [
	"GL_ALPHA4  0x803B"

	<category: 'constants'>
	^32827
    ]

    glAlpha8 [
	"GL_ALPHA8  0x803C"

	<category: 'constants'>
	^32828
    ]

    glAlpha12 [
	"GL_ALPHA12  0x803D"

	<category: 'constants'>
	^32829
    ]

    glAlpha16 [
	"GL_ALPHA16  0x803E"

	<category: 'constants'>
	^32830
    ]

    glLuminance4 [
	"GL_LUMINANCE4  0x803F"

	<category: 'constants'>
	^32831
    ]

    glLuminance8 [
	"GL_LUMINANCE8  0x8040"

	<category: 'constants'>
	^32832
    ]

    glLuminance12 [
	"GL_LUMINANCE12  0x8041"

	<category: 'constants'>
	^32833
    ]

    glLuminance16 [
	"GL_LUMINANCE16  0x8042"

	<category: 'constants'>
	^32834
    ]

    glLuminance4Alpha4 [
	"GL_LUMINANCE4_ALPHA4  0x8043"

	<category: 'constants'>
	^32835
    ]

    glLuminance6Alpha2 [
	"GL_LUMINANCE6_ALPHA2  0x8044"

	<category: 'constants'>
	^32836
    ]

    glLuminance8Alpha8 [
	"GL_LUMINANCE8_ALPHA8  0x8045"

	<category: 'constants'>
	^32837
    ]

    glLuminance12Alpha4 [
	"GL_LUMINANCE12_ALPHA4  0x8046"

	<category: 'constants'>
	^32838
    ]

    glLuminance12Alpha12 [
	"GL_LUMINANCE12_ALPHA12  0x8047"

	<category: 'constants'>
	^32839
    ]

    glLuminance16Alpha16 [
	"GL_LUMINANCE16_ALPHA16  0x8048"

	<category: 'constants'>
	^32840
    ]

    glIntensity [
	"GL_INTENSITY  0x8049"

	<category: 'constants'>
	^32841
    ]

    glIntensity4 [
	"GL_INTENSITY4  0x804A"

	<category: 'constants'>
	^32842
    ]

    glIntensity8 [
	"GL_INTENSITY8  0x804B"

	<category: 'constants'>
	^32843
    ]

    glIntensity12 [
	"GL_INTENSITY12  0x804C"

	<category: 'constants'>
	^32844
    ]

    glIntensity16 [
	"GL_INTENSITY16  0x804D"

	<category: 'constants'>
	^32845
    ]

    glR3G3B2 [
	"GL_R3_G3_B2  0x2A10"

	<category: 'constants'>
	^10768
    ]

    glRgb4 [
	"GL_RGB4  0x804F"

	<category: 'constants'>
	^32847
    ]

    glRgb5 [
	"GL_RGB5  0x8050"

	<category: 'constants'>
	^32848
    ]

    glRgb8 [
	"GL_RGB8  0x8051"

	<category: 'constants'>
	^32849
    ]

    glRgb10 [
	"GL_RGB10  0x8052"

	<category: 'constants'>
	^32850
    ]

    glRgb12 [
	"GL_RGB12  0x8053"

	<category: 'constants'>
	^32851
    ]

    glRgb16 [
	"GL_RGB16  0x8054"

	<category: 'constants'>
	^32852
    ]

    glRgba2 [
	"GL_RGBA2  0x8055"

	<category: 'constants'>
	^32853
    ]

    glRgba4 [
	"GL_RGBA4  0x8056"

	<category: 'constants'>
	^32854
    ]

    glRgb5A1 [
	"GL_RGB5_A1  0x8057"

	<category: 'constants'>
	^32855
    ]

    glRgba8 [
	"GL_RGBA8  0x8058"

	<category: 'constants'>
	^32856
    ]

    glRgb10A2 [
	"GL_RGB10_A2  0x8059"

	<category: 'constants'>
	^32857
    ]

    glRgba12 [
	"GL_RGBA12  0x805A"

	<category: 'constants'>
	^32858
    ]

    glRgba16 [
	"GL_RGBA16  0x805B"

	<category: 'constants'>
	^32859
    ]

    glClientPixelStoreBit [
	"GL_CLIENT_PIXEL_STORE_BIT  0x00000001"

	<category: 'constants'>
	^1
    ]

    glClientVertexArrayBit [
	"GL_CLIENT_VERTEX_ARRAY_BIT  0x00000002"

	<category: 'constants'>
	^2
    ]

    glAllClientAttribBits [
	"GL_ALL_CLIENT_ATTRIB_BITS  0xFFFFFFFF"

	<category: 'constants'>
	^4294967295
    ]

    glClientAllAttribBits [
	"GL_CLIENT_ALL_ATTRIB_BITS  0xFFFFFFFF"

	<category: 'constants'>
	^4294967295
    ]

    glRescaleNormal [
	"GL_RESCALE_NORMAL  0x803A"

	<category: 'constants Ext'>
	^32826
    ]

    glClampToEdge [
	"GL_CLAMP_TO_EDGE  0x812F"

	<category: 'constants Ext'>
	^33071
    ]

    glMaxElementsVertices [
	"GL_MAX_ELEMENTS_VERTICES  0x80E8"

	<category: 'constants Ext'>
	^33000
    ]

    glMaxElementsIndices [
	"GL_MAX_ELEMENTS_INDICES  0x80E9"

	<category: 'constants Ext'>
	^33001
    ]

    glBgr [
	"GL_BGR  0x80E0"

	<category: 'constants Ext'>
	^32992
    ]

    glBgra [
	"GL_BGRA  0x80E1"

	<category: 'constants Ext'>
	^32993
    ]

    glUnsignedByte332 [
	"GL_UNSIGNED_BYTE_3_3_2  0x8032"

	<category: 'constants Ext'>
	^32818
    ]

    glUnsignedByte233Rev [
	"GL_UNSIGNED_BYTE_2_3_3_REV  0x8362"

	<category: 'constants Ext'>
	^33634
    ]

    glUnsignedShort565 [
	"GL_UNSIGNED_SHORT_5_6_5  0x8363"

	<category: 'constants Ext'>
	^33635
    ]

    glUnsignedShort565Rev [
	"GL_UNSIGNED_SHORT_5_6_5_REV  0x8364"

	<category: 'constants Ext'>
	^33636
    ]

    glUnsignedShort4444 [
	"GL_UNSIGNED_SHORT_4_4_4_4  0x8033"

	<category: 'constants Ext'>
	^32819
    ]

    glUnsignedShort4444Rev [
	"GL_UNSIGNED_SHORT_4_4_4_4_REV  0x8365"

	<category: 'constants Ext'>
	^33637
    ]

    glUnsignedShort5551 [
	"GL_UNSIGNED_SHORT_5_5_5_1  0x8034"

	<category: 'constants Ext'>
	^32820
    ]

    glUnsignedShort1555Rev [
	"GL_UNSIGNED_SHORT_1_5_5_5_REV  0x8366"

	<category: 'constants Ext'>
	^33638
    ]

    glUnsignedInt8888 [
	"GL_UNSIGNED_INT_8_8_8_8  0x8035"

	<category: 'constants Ext'>
	^32821
    ]

    glUnsignedInt8888Rev [
	"GL_UNSIGNED_INT_8_8_8_8_REV  0x8367"

	<category: 'constants Ext'>
	^33639
    ]

    glUnsignedInt1010102 [
	"GL_UNSIGNED_INT_10_10_10_2  0x8036"

	<category: 'constants Ext'>
	^32822
    ]

    glUnsignedInt2101010Rev [
	"GL_UNSIGNED_INT_2_10_10_10_REV  0x8368"

	<category: 'constants Ext'>
	^33640
    ]

    glLightModelColorControl [
	"GL_LIGHT_MODEL_COLOR_CONTROL  0x81F8"

	<category: 'constants Ext'>
	^33272
    ]

    glSingleColor [
	"GL_SINGLE_COLOR  0x81F9"

	<category: 'constants Ext'>
	^33273
    ]

    glSeparateSpecularColor [
	"GL_SEPARATE_SPECULAR_COLOR  0x81FA"

	<category: 'constants Ext'>
	^33274
    ]

    glTextureMinLod [
	"GL_TEXTURE_MIN_LOD  0x813A"

	<category: 'constants Ext'>
	^33082
    ]

    glTextureMaxLod [
	"GL_TEXTURE_MAX_LOD  0x813B"

	<category: 'constants Ext'>
	^33083
    ]

    glTextureBaseLevel [
	"GL_TEXTURE_BASE_LEVEL  0x813C"

	<category: 'constants Ext'>
	^33084
    ]

    glTextureMaxLevel [
	"GL_TEXTURE_MAX_LEVEL  0x813D"

	<category: 'constants Ext'>
	^33085
    ]

    glSmoothPointSizeRange [
	"GL_SMOOTH_POINT_SIZE_RANGE  0x0B12"

	<category: 'constants Ext'>
	^2834
    ]

    glSmoothPointSizeGranularity [
	"GL_SMOOTH_POINT_SIZE_GRANULARITY  0x0B13"

	<category: 'constants Ext'>
	^2835
    ]

    glSmoothLineWidthRange [
	"GL_SMOOTH_LINE_WIDTH_RANGE  0x0B22"

	<category: 'constants Ext'>
	^2850
    ]

    glSmoothLineWidthGranularity [
	"GL_SMOOTH_LINE_WIDTH_GRANULARITY  0x0B23"

	<category: 'constants Ext'>
	^2851
    ]

    glAliasedPointSizeRange [
	"GL_ALIASED_POINT_SIZE_RANGE  0x846D"

	<category: 'constants Ext'>
	^33901
    ]

    glAliasedLineWidthRange [
	"GL_ALIASED_LINE_WIDTH_RANGE  0x846E"

	<category: 'constants Ext'>
	^33902
    ]

    glPackSkipImages [
	"GL_PACK_SKIP_IMAGES  0x806B"

	<category: 'constants Ext'>
	^32875
    ]

    glPackImageHeight [
	"GL_PACK_IMAGE_HEIGHT  0x806C"

	<category: 'constants Ext'>
	^32876
    ]

    glUnpackSkipImages [
	"GL_UNPACK_SKIP_IMAGES  0x806D"

	<category: 'constants Ext'>
	^32877
    ]

    glUnpackImageHeight [
	"GL_UNPACK_IMAGE_HEIGHT  0x806E"

	<category: 'constants Ext'>
	^32878
    ]

    glTexture3d [
	"GL_TEXTURE_3D  0x806F"

	<category: 'constants Ext'>
	^32879
    ]

    glProxyTexture3d [
	"GL_PROXY_TEXTURE_3D  0x8070"

	<category: 'constants Ext'>
	^32880
    ]

    glTextureDepth [
	"GL_TEXTURE_DEPTH  0x8071"

	<category: 'constants Ext'>
	^32881
    ]

    glTextureWrapR [
	"GL_TEXTURE_WRAP_R  0x8072"

	<category: 'constants Ext'>
	^32882
    ]

    glMax3dTextureSize [
	"GL_MAX_3D_TEXTURE_SIZE  0x8073"

	<category: 'constants Ext'>
	^32883
    ]

    glTextureBinding3d [
	"GL_TEXTURE_BINDING_3D  0x806A"

	<category: 'constants Ext'>
	^32874
    ]

    glConstantColor [
	"GL_CONSTANT_COLOR  0x8001"

	<category: 'constants Ext'>
	^32769
    ]

    glOneMinusConstantColor [
	"GL_ONE_MINUS_CONSTANT_COLOR  0x8002"

	<category: 'constants Ext'>
	^32770
    ]

    glConstantAlpha [
	"GL_CONSTANT_ALPHA  0x8003"

	<category: 'constants Ext'>
	^32771
    ]

    glOneMinusConstantAlpha [
	"GL_ONE_MINUS_CONSTANT_ALPHA  0x8004"

	<category: 'constants Ext'>
	^32772
    ]

    glColorTable [
	"GL_COLOR_TABLE  0x80D0"

	<category: 'constants Ext'>
	^32976
    ]

    glPostConvolutionColorTable [
	"GL_POST_CONVOLUTION_COLOR_TABLE  0x80D1"

	<category: 'constants Ext'>
	^32977
    ]

    glPostColorMatrixColorTable [
	"GL_POST_COLOR_MATRIX_COLOR_TABLE  0x80D2"

	<category: 'constants Ext'>
	^32978
    ]

    glProxyColorTable [
	"GL_PROXY_COLOR_TABLE  0x80D3"

	<category: 'constants Ext'>
	^32979
    ]

    glProxyPostConvolutionColorTable [
	"GL_PROXY_POST_CONVOLUTION_COLOR_TABLE  0x80D4"

	<category: 'constants Ext'>
	^32980
    ]

    glProxyPostColorMatrixColorTable [
	"GL_PROXY_POST_COLOR_MATRIX_COLOR_TABLE  0x80D5"

	<category: 'constants Ext'>
	^32981
    ]

    glColorTableScale [
	"GL_COLOR_TABLE_SCALE  0x80D6"

	<category: 'constants Ext'>
	^32982
    ]

    glColorTableBias [
	"GL_COLOR_TABLE_BIAS  0x80D7"

	<category: 'constants Ext'>
	^32983
    ]

    glColorTableFormat [
	"GL_COLOR_TABLE_FORMAT  0x80D8"

	<category: 'constants Ext'>
	^32984
    ]

    glColorTableWidth [
	"GL_COLOR_TABLE_WIDTH  0x80D9"

	<category: 'constants Ext'>
	^32985
    ]

    glColorTableRedSize [
	"GL_COLOR_TABLE_RED_SIZE  0x80DA"

	<category: 'constants Ext'>
	^32986
    ]

    glColorTableGreenSize [
	"GL_COLOR_TABLE_GREEN_SIZE  0x80DB"

	<category: 'constants Ext'>
	^32987
    ]

    glColorTableBlueSize [
	"GL_COLOR_TABLE_BLUE_SIZE  0x80DC"

	<category: 'constants Ext'>
	^32988
    ]

    glColorTableAlphaSize [
	"GL_COLOR_TABLE_ALPHA_SIZE  0x80DD"

	<category: 'constants Ext'>
	^32989
    ]

    glColorTableLuminanceSize [
	"GL_COLOR_TABLE_LUMINANCE_SIZE  0x80DE"

	<category: 'constants Ext'>
	^32990
    ]

    glColorTableIntensitySize [
	"GL_COLOR_TABLE_INTENSITY_SIZE  0x80DF"

	<category: 'constants Ext'>
	^32991
    ]

    glConvolution1d [
	"GL_CONVOLUTION_1D  0x8010"

	<category: 'constants Ext'>
	^32784
    ]

    glConvolution2d [
	"GL_CONVOLUTION_2D  0x8011"

	<category: 'constants Ext'>
	^32785
    ]

    glSeparable2d [
	"GL_SEPARABLE_2D  0x8012"

	<category: 'constants Ext'>
	^32786
    ]

    glConvolutionBorderMode [
	"GL_CONVOLUTION_BORDER_MODE  0x8013"

	<category: 'constants Ext'>
	^32787
    ]

    glConvolutionFilterScale [
	"GL_CONVOLUTION_FILTER_SCALE  0x8014"

	<category: 'constants Ext'>
	^32788
    ]

    glConvolutionFilterBias [
	"GL_CONVOLUTION_FILTER_BIAS  0x8015"

	<category: 'constants Ext'>
	^32789
    ]

    glReduce [
	"GL_REDUCE  0x8016"

	<category: 'constants Ext'>
	^32790
    ]

    glConvolutionFormat [
	"GL_CONVOLUTION_FORMAT  0x8017"

	<category: 'constants Ext'>
	^32791
    ]

    glConvolutionWidth [
	"GL_CONVOLUTION_WIDTH  0x8018"

	<category: 'constants Ext'>
	^32792
    ]

    glConvolutionHeight [
	"GL_CONVOLUTION_HEIGHT  0x8019"

	<category: 'constants Ext'>
	^32793
    ]

    glMaxConvolutionWidth [
	"GL_MAX_CONVOLUTION_WIDTH  0x801A"

	<category: 'constants Ext'>
	^32794
    ]

    glMaxConvolutionHeight [
	"GL_MAX_CONVOLUTION_HEIGHT  0x801B"

	<category: 'constants Ext'>
	^32795
    ]

    glPostConvolutionRedScale [
	"GL_POST_CONVOLUTION_RED_SCALE  0x801C"

	<category: 'constants Ext'>
	^32796
    ]

    glPostConvolutionGreenScale [
	"GL_POST_CONVOLUTION_GREEN_SCALE  0x801D"

	<category: 'constants Ext'>
	^32797
    ]

    glPostConvolutionBlueScale [
	"GL_POST_CONVOLUTION_BLUE_SCALE  0x801E"

	<category: 'constants Ext'>
	^32798
    ]

    glPostConvolutionAlphaScale [
	"GL_POST_CONVOLUTION_ALPHA_SCALE  0x801F"

	<category: 'constants Ext'>
	^32799
    ]

    glPostConvolutionRedBias [
	"GL_POST_CONVOLUTION_RED_BIAS  0x8020"

	<category: 'constants Ext'>
	^32800
    ]

    glPostConvolutionGreenBias [
	"GL_POST_CONVOLUTION_GREEN_BIAS  0x8021"

	<category: 'constants Ext'>
	^32801
    ]

    glPostConvolutionBlueBias [
	"GL_POST_CONVOLUTION_BLUE_BIAS  0x8022"

	<category: 'constants Ext'>
	^32802
    ]

    glPostConvolutionAlphaBias [
	"GL_POST_CONVOLUTION_ALPHA_BIAS  0x8023"

	<category: 'constants Ext'>
	^32803
    ]

    glConstantBorder [
	"GL_CONSTANT_BORDER  0x8151"

	<category: 'constants Ext'>
	^33105
    ]

    glReplicateBorder [
	"GL_REPLICATE_BORDER  0x8153"

	<category: 'constants Ext'>
	^33107
    ]

    glConvolutionBorderColor [
	"GL_CONVOLUTION_BORDER_COLOR  0x8154"

	<category: 'constants Ext'>
	^33108
    ]

    glColorMatrix [
	"GL_COLOR_MATRIX  0x80B1"

	<category: 'constants Ext'>
	^32945
    ]

    glColorMatrixStackDepth [
	"GL_COLOR_MATRIX_STACK_DEPTH  0x80B2"

	<category: 'constants Ext'>
	^32946
    ]

    glMaxColorMatrixStackDepth [
	"GL_MAX_COLOR_MATRIX_STACK_DEPTH  0x80B3"

	<category: 'constants Ext'>
	^32947
    ]

    glPostColorMatrixRedScale [
	"GL_POST_COLOR_MATRIX_RED_SCALE  0x80B4"

	<category: 'constants Ext'>
	^32948
    ]

    glPostColorMatrixGreenScale [
	"GL_POST_COLOR_MATRIX_GREEN_SCALE  0x80B5"

	<category: 'constants Ext'>
	^32949
    ]

    glPostColorMatrixBlueScale [
	"GL_POST_COLOR_MATRIX_BLUE_SCALE  0x80B6"

	<category: 'constants Ext'>
	^32950
    ]

    glPostColorMatrixAlphaScale [
	"GL_POST_COLOR_MATRIX_ALPHA_SCALE  0x80B7"

	<category: 'constants Ext'>
	^32951
    ]

    glPostColorMatrixRedBias [
	"GL_POST_COLOR_MATRIX_RED_BIAS  0x80B8"

	<category: 'constants Ext'>
	^32952
    ]

    glPostColorMatrixGreenBias [
	"GL_POST_COLOR_MATRIX_GREEN_BIAS  0x80B9"

	<category: 'constants Ext'>
	^32953
    ]

    glPostColorMatrixBlueBias [
	"GL_POST_COLOR_MATRIX_BLUE_BIAS  0x80BA"

	<category: 'constants Ext'>
	^32954
    ]

    glPostColorMatrixAlphaBias [
	"GL_POST_COLOR_MATRIX_ALPHA_BIAS  0x80BB"

	<category: 'constants Ext'>
	^32955
    ]

    glHistogram [
	"GL_HISTOGRAM  0x8024"

	<category: 'constants Ext'>
	^32804
    ]

    glProxyHistogram [
	"GL_PROXY_HISTOGRAM  0x8025"

	<category: 'constants Ext'>
	^32805
    ]

    glHistogramWidth [
	"GL_HISTOGRAM_WIDTH  0x8026"

	<category: 'constants Ext'>
	^32806
    ]

    glHistogramFormat [
	"GL_HISTOGRAM_FORMAT  0x8027"

	<category: 'constants Ext'>
	^32807
    ]

    glHistogramRedSize [
	"GL_HISTOGRAM_RED_SIZE  0x8028"

	<category: 'constants Ext'>
	^32808
    ]

    glHistogramGreenSize [
	"GL_HISTOGRAM_GREEN_SIZE  0x8029"

	<category: 'constants Ext'>
	^32809
    ]

    glHistogramBlueSize [
	"GL_HISTOGRAM_BLUE_SIZE  0x802A"

	<category: 'constants Ext'>
	^32810
    ]

    glHistogramAlphaSize [
	"GL_HISTOGRAM_ALPHA_SIZE  0x802B"

	<category: 'constants Ext'>
	^32811
    ]

    glHistogramLuminanceSize [
	"GL_HISTOGRAM_LUMINANCE_SIZE  0x802C"

	<category: 'constants Ext'>
	^32812
    ]

    glHistogramSink [
	"GL_HISTOGRAM_SINK  0x802D"

	<category: 'constants Ext'>
	^32813
    ]

    glMinmax [
	"GL_MINMAX  0x802E"

	<category: 'constants Ext'>
	^32814
    ]

    glMinmaxFormat [
	"GL_MINMAX_FORMAT  0x802F"

	<category: 'constants Ext'>
	^32815
    ]

    glMinmaxSink [
	"GL_MINMAX_SINK  0x8030"

	<category: 'constants Ext'>
	^32816
    ]

    glTableTooLarge [
	"GL_TABLE_TOO_LARGE  0x8031"

	<category: 'constants Ext'>
	^32817
    ]

    glBlendEquation [
	"GL_BLEND_EQUATION  0x8009"

	<category: 'constants Ext'>
	^32777
    ]

    glMin [
	"GL_MIN  0x8007"

	<category: 'constants Ext'>
	^32775
    ]

    glMax [
	"GL_MAX  0x8008"

	<category: 'constants Ext'>
	^32776
    ]

    glFuncAdd [
	"GL_FUNC_ADD  0x8006"

	<category: 'constants Ext'>
	^32774
    ]

    glFuncSubtract [
	"GL_FUNC_SUBTRACT  0x800A"

	<category: 'constants Ext'>
	^32778
    ]

    glFuncReverseSubtract [
	"GL_FUNC_REVERSE_SUBTRACT  0x800B"

	<category: 'constants Ext'>
	^32779
    ]

    glBlendColor [
	"GL_BLEND_COLOR  0x8005"

	<category: 'constants Ext'>
	^32773
    ]

    glTexture0 [
	"GL_TEXTURE0  0x84C0"

	<category: 'constants Ext'>
	^33984
    ]

    glTexture1 [
	"GL_TEXTURE1  0x84C1"

	<category: 'constants Ext'>
	^33985
    ]

    glTexture2 [
	"GL_TEXTURE2  0x84C2"

	<category: 'constants Ext'>
	^33986
    ]

    glTexture3 [
	"GL_TEXTURE3  0x84C3"

	<category: 'constants Ext'>
	^33987
    ]

    glTexture4 [
	"GL_TEXTURE4  0x84C4"

	<category: 'constants Ext'>
	^33988
    ]

    glTexture5 [
	"GL_TEXTURE5  0x84C5"

	<category: 'constants Ext'>
	^33989
    ]

    glTexture6 [
	"GL_TEXTURE6  0x84C6"

	<category: 'constants Ext'>
	^33990
    ]

    glTexture7 [
	"GL_TEXTURE7  0x84C7"

	<category: 'constants Ext'>
	^33991
    ]

    glTexture8 [
	"GL_TEXTURE8  0x84C8"

	<category: 'constants Ext'>
	^33992
    ]

    glTexture9 [
	"GL_TEXTURE9  0x84C9"

	<category: 'constants Ext'>
	^33993
    ]

    glTexture10 [
	"GL_TEXTURE10  0x84CA"

	<category: 'constants Ext'>
	^33994
    ]

    glTexture11 [
	"GL_TEXTURE11  0x84CB"

	<category: 'constants Ext'>
	^33995
    ]

    glTexture12 [
	"GL_TEXTURE12  0x84CC"

	<category: 'constants Ext'>
	^33996
    ]

    glTexture13 [
	"GL_TEXTURE13  0x84CD"

	<category: 'constants Ext'>
	^33997
    ]

    glTexture14 [
	"GL_TEXTURE14  0x84CE"

	<category: 'constants Ext'>
	^33998
    ]

    glTexture15 [
	"GL_TEXTURE15  0x84CF"

	<category: 'constants Ext'>
	^33999
    ]

    glTexture16 [
	"GL_TEXTURE16  0x84D0"

	<category: 'constants Ext'>
	^34000
    ]

    glTexture17 [
	"GL_TEXTURE17  0x84D1"

	<category: 'constants Ext'>
	^34001
    ]

    glTexture18 [
	"GL_TEXTURE18  0x84D2"

	<category: 'constants Ext'>
	^34002
    ]

    glTexture19 [
	"GL_TEXTURE19  0x84D3"

	<category: 'constants Ext'>
	^34003
    ]

    glTexture20 [
	"GL_TEXTURE20  0x84D4"

	<category: 'constants Ext'>
	^34004
    ]

    glTexture21 [
	"GL_TEXTURE21  0x84D5"

	<category: 'constants Ext'>
	^34005
    ]

    glTexture22 [
	"GL_TEXTURE22  0x84D6"

	<category: 'constants Ext'>
	^34006
    ]

    glTexture23 [
	"GL_TEXTURE23  0x84D7"

	<category: 'constants Ext'>
	^34007
    ]

    glTexture24 [
	"GL_TEXTURE24  0x84D8"

	<category: 'constants Ext'>
	^34008
    ]

    glTexture25 [
	"GL_TEXTURE25  0x84D9"

	<category: 'constants Ext'>
	^34009
    ]

    glTexture26 [
	"GL_TEXTURE26  0x84DA"

	<category: 'constants Ext'>
	^34010
    ]

    glTexture27 [
	"GL_TEXTURE27  0x84DB"

	<category: 'constants Ext'>
	^34011
    ]

    glTexture28 [
	"GL_TEXTURE28  0x84DC"

	<category: 'constants Ext'>
	^34012
    ]

    glTexture29 [
	"GL_TEXTURE29  0x84DD"

	<category: 'constants Ext'>
	^34013
    ]

    glTexture30 [
	"GL_TEXTURE30  0x84DE"

	<category: 'constants Ext'>
	^34014
    ]

    glTexture31 [
	"GL_TEXTURE31  0x84DF"

	<category: 'constants Ext'>
	^34015
    ]

    glActiveTexture [
	"GL_ACTIVE_TEXTURE  0x84E0"

	<category: 'constants Ext'>
	^34016
    ]

    glClientActiveTexture [
	"GL_CLIENT_ACTIVE_TEXTURE  0x84E1"

	<category: 'constants Ext'>
	^34017
    ]

    glMaxTextureUnits [
	"GL_MAX_TEXTURE_UNITS  0x84E2"

	<category: 'constants Ext'>
	^34018
    ]

    glNormalMap [
	"GL_NORMAL_MAP  0x8511"

	<category: 'constants Ext'>
	^34065
    ]

    glReflectionMap [
	"GL_REFLECTION_MAP  0x8512"

	<category: 'constants Ext'>
	^34066
    ]

    glTextureCubeMap [
	"GL_TEXTURE_CUBE_MAP  0x8513"

	<category: 'constants Ext'>
	^34067
    ]

    glTextureBindingCubeMap [
	"GL_TEXTURE_BINDING_CUBE_MAP  0x8514"

	<category: 'constants Ext'>
	^34068
    ]

    glTextureCubeMapPositiveX [
	"GL_TEXTURE_CUBE_MAP_POSITIVE_X  0x8515"

	<category: 'constants Ext'>
	^34069
    ]

    glTextureCubeMapNegativeX [
	"GL_TEXTURE_CUBE_MAP_NEGATIVE_X  0x8516"

	<category: 'constants Ext'>
	^34070
    ]

    glTextureCubeMapPositiveY [
	"GL_TEXTURE_CUBE_MAP_POSITIVE_Y  0x8517"

	<category: 'constants Ext'>
	^34071
    ]

    glTextureCubeMapNegativeY [
	"GL_TEXTURE_CUBE_MAP_NEGATIVE_Y  0x8518"

	<category: 'constants Ext'>
	^34072
    ]

    glTextureCubeMapPositiveZ [
	"GL_TEXTURE_CUBE_MAP_POSITIVE_Z  0x8519"

	<category: 'constants Ext'>
	^34073
    ]

    glTextureCubeMapNegativeZ [
	"GL_TEXTURE_CUBE_MAP_NEGATIVE_Z  0x851A"

	<category: 'constants Ext'>
	^34074
    ]

    glProxyTextureCubeMap [
	"GL_PROXY_TEXTURE_CUBE_MAP  0x851B"

	<category: 'constants Ext'>
	^34075
    ]

    glMaxCubeMapTextureSize [
	"GL_MAX_CUBE_MAP_TEXTURE_SIZE  0x851C"

	<category: 'constants Ext'>
	^34076
    ]

    glCompressedAlpha [
	"GL_COMPRESSED_ALPHA  0x84E9"

	<category: 'constants Ext'>
	^34025
    ]

    glCompressedLuminance [
	"GL_COMPRESSED_LUMINANCE  0x84EA"

	<category: 'constants Ext'>
	^34026
    ]

    glCompressedLuminanceAlpha [
	"GL_COMPRESSED_LUMINANCE_ALPHA  0x84EB"

	<category: 'constants Ext'>
	^34027
    ]

    glCompressedIntensity [
	"GL_COMPRESSED_INTENSITY  0x84EC"

	<category: 'constants Ext'>
	^34028
    ]

    glCompressedRgb [
	"GL_COMPRESSED_RGB  0x84ED"

	<category: 'constants Ext'>
	^34029
    ]

    glCompressedRgba [
	"GL_COMPRESSED_RGBA  0x84EE"

	<category: 'constants Ext'>
	^34030
    ]

    glTextureCompressionHint [
	"GL_TEXTURE_COMPRESSION_HINT  0x84EF"

	<category: 'constants Ext'>
	^34031
    ]

    glTextureCompressedImageSize [
	"GL_TEXTURE_COMPRESSED_IMAGE_SIZE  0x86A0"

	<category: 'constants Ext'>
	^34464
    ]

    glTextureCompressed [
	"GL_TEXTURE_COMPRESSED  0x86A1"

	<category: 'constants Ext'>
	^34465
    ]

    glNumCompressedTextureFormats [
	"GL_NUM_COMPRESSED_TEXTURE_FORMATS  0x86A2"

	<category: 'constants Ext'>
	^34466
    ]

    glCompressedTextureFormats [
	"GL_COMPRESSED_TEXTURE_FORMATS  0x86A3"

	<category: 'constants Ext'>
	^34467
    ]

    glMultisample [
	"GL_MULTISAMPLE  0x809D"

	<category: 'constants Ext'>
	^32925
    ]

    glSampleAlphaToCoverage [
	"GL_SAMPLE_ALPHA_TO_COVERAGE  0x809E"

	<category: 'constants Ext'>
	^32926
    ]

    glSampleAlphaToOne [
	"GL_SAMPLE_ALPHA_TO_ONE  0x809F"

	<category: 'constants Ext'>
	^32927
    ]

    glSampleCoverage [
	"GL_SAMPLE_COVERAGE  0x80A0"

	<category: 'constants Ext'>
	^32928
    ]

    glSampleBuffers [
	"GL_SAMPLE_BUFFERS  0x80A8"

	<category: 'constants Ext'>
	^32936
    ]

    glSamples [
	"GL_SAMPLES  0x80A9"

	<category: 'constants Ext'>
	^32937
    ]

    glSampleCoverageValue [
	"GL_SAMPLE_COVERAGE_VALUE  0x80AA"

	<category: 'constants Ext'>
	^32938
    ]

    glSampleCoverageInvert [
	"GL_SAMPLE_COVERAGE_INVERT  0x80AB"

	<category: 'constants Ext'>
	^32939
    ]

    glMultisampleBit [
	"GL_MULTISAMPLE_BIT  0x20000000"

	<category: 'constants Ext'>
	^536870912
    ]

    glTransposeModelviewMatrix [
	"GL_TRANSPOSE_MODELVIEW_MATRIX  0x84E3"

	<category: 'constants Ext'>
	^34019
    ]

    glTransposeProjectionMatrix [
	"GL_TRANSPOSE_PROJECTION_MATRIX  0x84E4"

	<category: 'constants Ext'>
	^34020
    ]

    glTransposeTextureMatrix [
	"GL_TRANSPOSE_TEXTURE_MATRIX  0x84E5"

	<category: 'constants Ext'>
	^34021
    ]

    glTransposeColorMatrix [
	"GL_TRANSPOSE_COLOR_MATRIX  0x84E6"

	<category: 'constants Ext'>
	^34022
    ]

    glCombine [
	"GL_COMBINE  0x8570"

	<category: 'constants Ext'>
	^34160
    ]

    glCombineRgb [
	"GL_COMBINE_RGB  0x8571"

	<category: 'constants Ext'>
	^34161
    ]

    glCombineAlpha [
	"GL_COMBINE_ALPHA  0x8572"

	<category: 'constants Ext'>
	^34162
    ]

    glSource0Rgb [
	"GL_SOURCE0_RGB  0x8580"

	<category: 'constants Ext'>
	^34176
    ]

    glSource1Rgb [
	"GL_SOURCE1_RGB  0x8581"

	<category: 'constants Ext'>
	^34177
    ]

    glSource2Rgb [
	"GL_SOURCE2_RGB  0x8582"

	<category: 'constants Ext'>
	^34178
    ]

    glSource0Alpha [
	"GL_SOURCE0_ALPHA  0x8588"

	<category: 'constants Ext'>
	^34184
    ]

    glSource1Alpha [
	"GL_SOURCE1_ALPHA  0x8589"

	<category: 'constants Ext'>
	^34185
    ]

    glSource2Alpha [
	"GL_SOURCE2_ALPHA  0x858A"

	<category: 'constants Ext'>
	^34186
    ]

    glOperand0Rgb [
	"GL_OPERAND0_RGB  0x8590"

	<category: 'constants Ext'>
	^34192
    ]

    glOperand1Rgb [
	"GL_OPERAND1_RGB  0x8591"

	<category: 'constants Ext'>
	^34193
    ]

    glOperand2Rgb [
	"GL_OPERAND2_RGB  0x8592"

	<category: 'constants Ext'>
	^34194
    ]

    glOperand0Alpha [
	"GL_OPERAND0_ALPHA  0x8598"

	<category: 'constants Ext'>
	^34200
    ]

    glOperand1Alpha [
	"GL_OPERAND1_ALPHA  0x8599"

	<category: 'constants Ext'>
	^34201
    ]

    glOperand2Alpha [
	"GL_OPERAND2_ALPHA  0x859A"

	<category: 'constants Ext'>
	^34202
    ]

    glRgbScale [
	"GL_RGB_SCALE  0x8573"

	<category: 'constants Ext'>
	^34163
    ]

    glAddSigned [
	"GL_ADD_SIGNED  0x8574"

	<category: 'constants Ext'>
	^34164
    ]

    glInterpolate [
	"GL_INTERPOLATE  0x8575"

	<category: 'constants Ext'>
	^34165
    ]

    glSubtract [
	"GL_SUBTRACT  0x84E7"

	<category: 'constants Ext'>
	^34023
    ]

    glConstant [
	"GL_CONSTANT  0x8576"

	<category: 'constants Ext'>
	^34166
    ]

    glPrimaryColor [
	"GL_PRIMARY_COLOR  0x8577"

	<category: 'constants Ext'>
	^34167
    ]

    glPrevious [
	"GL_PREVIOUS  0x8578"

	<category: 'constants Ext'>
	^34168
    ]

    glDot3Rgb [
	"GL_DOT3_RGB  0x86AE"

	<category: 'constants Ext'>
	^34478
    ]

    glDot3Rgba [
	"GL_DOT3_RGBA  0x86AF"

	<category: 'constants Ext'>
	^34479
    ]

    glClampToBorder [
	"GL_CLAMP_TO_BORDER  0x812D"

	<category: 'constants Ext'>
	^33069
    ]

    glTexture0Arb [
	"GL_TEXTURE0_ARB  0x84C0"

	<category: 'constants Ext'>
	^33984
    ]

    glTexture1Arb [
	"GL_TEXTURE1_ARB  0x84C1"

	<category: 'constants Ext'>
	^33985
    ]

    glTexture2Arb [
	"GL_TEXTURE2_ARB  0x84C2"

	<category: 'constants Ext'>
	^33986
    ]

    glTexture3Arb [
	"GL_TEXTURE3_ARB  0x84C3"

	<category: 'constants Ext'>
	^33987
    ]

    glTexture4Arb [
	"GL_TEXTURE4_ARB  0x84C4"

	<category: 'constants Ext'>
	^33988
    ]

    glTexture5Arb [
	"GL_TEXTURE5_ARB  0x84C5"

	<category: 'constants Ext'>
	^33989
    ]

    glTexture6Arb [
	"GL_TEXTURE6_ARB  0x84C6"

	<category: 'constants Ext'>
	^33990
    ]

    glTexture7Arb [
	"GL_TEXTURE7_ARB  0x84C7"

	<category: 'constants Ext'>
	^33991
    ]

    glTexture8Arb [
	"GL_TEXTURE8_ARB  0x84C8"

	<category: 'constants Ext'>
	^33992
    ]

    glTexture9Arb [
	"GL_TEXTURE9_ARB  0x84C9"

	<category: 'constants Ext'>
	^33993
    ]

    glTexture10Arb [
	"GL_TEXTURE10_ARB  0x84CA"

	<category: 'constants Ext'>
	^33994
    ]

    glTexture11Arb [
	"GL_TEXTURE11_ARB  0x84CB"

	<category: 'constants Ext'>
	^33995
    ]

    glTexture12Arb [
	"GL_TEXTURE12_ARB  0x84CC"

	<category: 'constants Ext'>
	^33996
    ]

    glTexture13Arb [
	"GL_TEXTURE13_ARB  0x84CD"

	<category: 'constants Ext'>
	^33997
    ]

    glTexture14Arb [
	"GL_TEXTURE14_ARB  0x84CE"

	<category: 'constants Ext'>
	^33998
    ]

    glTexture15Arb [
	"GL_TEXTURE15_ARB  0x84CF"

	<category: 'constants Ext'>
	^33999
    ]

    glTexture16Arb [
	"GL_TEXTURE16_ARB  0x84D0"

	<category: 'constants Ext'>
	^34000
    ]

    glTexture17Arb [
	"GL_TEXTURE17_ARB  0x84D1"

	<category: 'constants Ext'>
	^34001
    ]

    glTexture18Arb [
	"GL_TEXTURE18_ARB  0x84D2"

	<category: 'constants Ext'>
	^34002
    ]

    glTexture19Arb [
	"GL_TEXTURE19_ARB  0x84D3"

	<category: 'constants Ext'>
	^34003
    ]

    glTexture20Arb [
	"GL_TEXTURE20_ARB  0x84D4"

	<category: 'constants Ext'>
	^34004
    ]

    glTexture21Arb [
	"GL_TEXTURE21_ARB  0x84D5"

	<category: 'constants Ext'>
	^34005
    ]

    glTexture22Arb [
	"GL_TEXTURE22_ARB  0x84D6"

	<category: 'constants Ext'>
	^34006
    ]

    glTexture23Arb [
	"GL_TEXTURE23_ARB  0x84D7"

	<category: 'constants Ext'>
	^34007
    ]

    glTexture24Arb [
	"GL_TEXTURE24_ARB  0x84D8"

	<category: 'constants Ext'>
	^34008
    ]

    glTexture25Arb [
	"GL_TEXTURE25_ARB  0x84D9"

	<category: 'constants Ext'>
	^34009
    ]

    glTexture26Arb [
	"GL_TEXTURE26_ARB  0x84DA"

	<category: 'constants Ext'>
	^34010
    ]

    glTexture27Arb [
	"GL_TEXTURE27_ARB  0x84DB"

	<category: 'constants Ext'>
	^34011
    ]

    glTexture28Arb [
	"GL_TEXTURE28_ARB  0x84DC"

	<category: 'constants Ext'>
	^34012
    ]

    glTexture29Arb [
	"GL_TEXTURE29_ARB  0x84DD"

	<category: 'constants Ext'>
	^34013
    ]

    glTexture30Arb [
	"GL_TEXTURE30_ARB  0x84DE"

	<category: 'constants Ext'>
	^34014
    ]

    glTexture31Arb [
	"GL_TEXTURE31_ARB  0x84DF"

	<category: 'constants Ext'>
	^34015
    ]

    glActiveTextureArb [
	"GL_ACTIVE_TEXTURE_ARB  0x84E0"

	<category: 'constants Ext'>
	^34016
    ]

    glClientActiveTextureArb [
	"GL_CLIENT_ACTIVE_TEXTURE_ARB  0x84E1"

	<category: 'constants Ext'>
	^34017
    ]

    glMaxTextureUnitsArb [
	"GL_MAX_TEXTURE_UNITS_ARB  0x84E2"

	<category: 'constants Ext'>
	^34018
    ]

    glDebugObjectMesa [
	"GL_DEBUG_OBJECT_MESA  0x8759"

	<category: 'constants'>
	^34649
    ]

    glDebugPrintMesa [
	"GL_DEBUG_PRINT_MESA  0x875A"

	<category: 'constants'>
	^34650
    ]

    glDebugAssertMesa [
	"GL_DEBUG_ASSERT_MESA  0x875B"

	<category: 'constants'>
	^34651
    ]

    glTraceAllBitsMesa [
	"GL_TRACE_ALL_BITS_MESA  0xFFFF"

	<category: 'constants'>
	^65535
    ]

    glTraceOperationsBitMesa [
	"GL_TRACE_OPERATIONS_BIT_MESA  0x0001"

	<category: 'constants'>
	^1
    ]

    glTracePrimitivesBitMesa [
	"GL_TRACE_PRIMITIVES_BIT_MESA  0x0002"

	<category: 'constants'>
	^2
    ]

    glTraceArraysBitMesa [
	"GL_TRACE_ARRAYS_BIT_MESA  0x0004"

	<category: 'constants'>
	^4
    ]

    glTraceTexturesBitMesa [
	"GL_TRACE_TEXTURES_BIT_MESA  0x0008"

	<category: 'constants'>
	^8
    ]

    glTracePixelsBitMesa [
	"GL_TRACE_PIXELS_BIT_MESA  0x0010"

	<category: 'constants'>
	^16
    ]

    glTraceErrorsBitMesa [
	"GL_TRACE_ERRORS_BIT_MESA  0x0020"

	<category: 'constants'>
	^32
    ]

    glTraceMaskMesa [
	"GL_TRACE_MASK_MESA  0x8755"

	<category: 'constants'>
	^34645
    ]

    glTraceNameMesa [
	"GL_TRACE_NAME_MESA  0x8756"

	<category: 'constants'>
	^34646
    ]

    glDepthStencilMesa [
	"GL_DEPTH_STENCIL_MESA  0x8750"

	<category: 'constants'>
	^34640
    ]

    glUnsignedInt248Mesa [
	"GL_UNSIGNED_INT_24_8_MESA  0x8751"

	<category: 'constants'>
	^34641
    ]

    glUnsignedInt824RevMesa [
	"GL_UNSIGNED_INT_8_24_REV_MESA  0x8752"

	<category: 'constants'>
	^34642
    ]

    glUnsignedShort151Mesa [
	"GL_UNSIGNED_SHORT_15_1_MESA  0x8753"

	<category: 'constants'>
	^34643
    ]

    glUnsignedShort115RevMesa [
	"GL_UNSIGNED_SHORT_1_15_REV_MESA  0x8754"

	<category: 'constants'>
	^34644
    ]

    glFragmentProgramPositionMesa [
	"GL_FRAGMENT_PROGRAM_POSITION_MESA  0x8bb0"

	<category: 'constants'>
	^35760
    ]

    glFragmentProgramCallbackMesa [
	"GL_FRAGMENT_PROGRAM_CALLBACK_MESA  0x8bb1"

	<category: 'constants'>
	^35761
    ]

    glFragmentProgramCallbackFuncMesa [
	"GL_FRAGMENT_PROGRAM_CALLBACK_FUNC_MESA  0x8bb2"

	<category: 'constants'>
	^35762
    ]

    glFragmentProgramCallbackDataMesa [
	"GL_FRAGMENT_PROGRAM_CALLBACK_DATA_MESA  0x8bb3"

	<category: 'constants'>
	^35763
    ]

    glVertexProgramPositionMesa [
	"GL_VERTEX_PROGRAM_POSITION_MESA  0x8bb4"

	<category: 'constants'>
	^35764
    ]

    glVertexProgramCallbackMesa [
	"GL_VERTEX_PROGRAM_CALLBACK_MESA  0x8bb5"

	<category: 'constants'>
	^35765
    ]

    glVertexProgramCallbackFuncMesa [
	"GL_VERTEX_PROGRAM_CALLBACK_FUNC_MESA  0x8bb6"

	<category: 'constants'>
	^35766
    ]

    glVertexProgramCallbackDataMesa [
	"GL_VERTEX_PROGRAM_CALLBACK_DATA_MESA  0x8bb7"

	<category: 'constants'>
	^35767
    ]

    glAlphaBlendEquationAti [
	"GL_ALPHA_BLEND_EQUATION_ATI  0x883D"

	<category: 'constants'>
	^34877
    ]

    glTimeElapsedExt [
	"GL_TIME_ELAPSED_EXT  0x88BF"

	<category: 'constants Ext'>
	^35007
    ]

    glReadFramebufferExt [
	"GL_READ_FRAMEBUFFER_EXT  0x8CA8"

	<category: 'constants Ext'>
	^36008
    ]

    glDrawFramebufferExt [
	"GL_DRAW_FRAMEBUFFER_EXT  0x8CA9"

	<category: 'constants Ext'>
	^36009
    ]

    glDrawFramebufferBindingExt [
	"GL_DRAW_FRAMEBUFFER_BINDING_EXT  0x8CAA"

	<category: 'constants Ext'>
	^36010
    ]

    glReadFramebufferBindingExt [
	"GL_READ_FRAMEBUFFER_BINDING_EXT  GL_FRAMEBUFFER_BINDING_EXT"

	<category: 'constants Ext'>
	^1.5101511e + 23
    ]

    glDepthStencilExt [
	"GL_DEPTH_STENCIL_EXT  0x84F9"

	<category: 'constants Ext'>
	^34041
    ]

    glUnsignedInt248Ext [
	"GL_UNSIGNED_INT_24_8_EXT  0x84FA"

	<category: 'constants Ext'>
	^34042
    ]

    glDepth24Stencil8Ext [
	"GL_DEPTH24_STENCIL8_EXT  0x88F0"

	<category: 'constants Ext'>
	^35056
    ]

    glTextureStencilSizeExt [
	"GL_TEXTURE_STENCIL_SIZE_EXT  0x88F1"

	<category: 'constants Ext'>
	^35057
    ]

    glSrgbExt [
	"GL_SRGB_EXT  0x8C40"

	<category: 'constants Ext'>
	^35904
    ]

    glSrgb8Ext [
	"GL_SRGB8_EXT  0x8C41"

	<category: 'constants Ext'>
	^35905
    ]

    glSrgbAlphaExt [
	"GL_SRGB_ALPHA_EXT  0x8C42"

	<category: 'constants Ext'>
	^35906
    ]

    glSrgb8Alpha8Ext [
	"GL_SRGB8_ALPHA8_EXT  0x8C43"

	<category: 'constants Ext'>
	^35907
    ]

    glSluminanceAlphaExt [
	"GL_SLUMINANCE_ALPHA_EXT  0x8C44"

	<category: 'constants Ext'>
	^35908
    ]

    glSluminance8Alpha8Ext [
	"GL_SLUMINANCE8_ALPHA8_EXT  0x8C45"

	<category: 'constants Ext'>
	^35909
    ]

    glSluminanceExt [
	"GL_SLUMINANCE_EXT  0x8C46"

	<category: 'constants Ext'>
	^35910
    ]

    glSluminance8Ext [
	"GL_SLUMINANCE8_EXT  0x8C47"

	<category: 'constants Ext'>
	^35911
    ]

    glCompressedSrgbExt [
	"GL_COMPRESSED_SRGB_EXT  0x8C48"

	<category: 'constants Ext'>
	^35912
    ]

    glCompressedSrgbAlphaExt [
	"GL_COMPRESSED_SRGB_ALPHA_EXT  0x8C49"

	<category: 'constants Ext'>
	^35913
    ]

    glCompressedSluminanceExt [
	"GL_COMPRESSED_SLUMINANCE_EXT  0x8C4A"

	<category: 'constants Ext'>
	^35914
    ]

    glCompressedSluminanceAlphaExt [
	"GL_COMPRESSED_SLUMINANCE_ALPHA_EXT  0x8C4B"

	<category: 'constants Ext'>
	^35915
    ]

    glCompressedSrgbS3tcDxt1Ext [
	"GL_COMPRESSED_SRGB_S3TC_DXT1_EXT  0x8C4C"

	<category: 'constants Ext'>
	^35916
    ]

    glCompressedSrgbAlphaS3tcDxt1Ext [
	"GL_COMPRESSED_SRGB_ALPHA_S3TC_DXT1_EXT  0x8C4D"

	<category: 'constants Ext'>
	^35917
    ]

    glCompressedSrgbAlphaS3tcDxt3Ext [
	"GL_COMPRESSED_SRGB_ALPHA_S3TC_DXT3_EXT  0x8C4E"

	<category: 'constants Ext'>
	^35918
    ]

    glCompressedSrgbAlphaS3tcDxt5Ext [
	"GL_COMPRESSED_SRGB_ALPHA_S3TC_DXT5_EXT  0x8C4F"

	<category: 'constants Ext'>
	^35919
    ]

    glGlextVersion [
	"GL_GLEXT_VERSION  39"

	<category: 'constants Ext'>
	^39
    ]

    glBlendDstRgb [
	"GL_BLEND_DST_RGB  0x80C8"

	<category: 'constants Ext'>
	^32968
    ]

    glBlendSrcRgb [
	"GL_BLEND_SRC_RGB  0x80C9"

	<category: 'constants Ext'>
	^32969
    ]

    glBlendDstAlpha [
	"GL_BLEND_DST_ALPHA  0x80CA"

	<category: 'constants Ext'>
	^32970
    ]

    glBlendSrcAlpha [
	"GL_BLEND_SRC_ALPHA  0x80CB"

	<category: 'constants Ext'>
	^32971
    ]

    glPointSizeMin [
	"GL_POINT_SIZE_MIN  0x8126"

	<category: 'constants Ext'>
	^33062
    ]

    glPointSizeMax [
	"GL_POINT_SIZE_MAX  0x8127"

	<category: 'constants Ext'>
	^33063
    ]

    glPointFadeThresholdSize [
	"GL_POINT_FADE_THRESHOLD_SIZE  0x8128"

	<category: 'constants Ext'>
	^33064
    ]

    glPointDistanceAttenuation [
	"GL_POINT_DISTANCE_ATTENUATION  0x8129"

	<category: 'constants Ext'>
	^33065
    ]

    glGenerateMipmap [
	"GL_GENERATE_MIPMAP  0x8191"

	<category: 'constants Ext'>
	^33169
    ]

    glGenerateMipmapHint [
	"GL_GENERATE_MIPMAP_HINT  0x8192"

	<category: 'constants Ext'>
	^33170
    ]

    glDepthComponent16 [
	"GL_DEPTH_COMPONENT16  0x81A5"

	<category: 'constants Ext'>
	^33189
    ]

    glDepthComponent24 [
	"GL_DEPTH_COMPONENT24  0x81A6"

	<category: 'constants Ext'>
	^33190
    ]

    glDepthComponent32 [
	"GL_DEPTH_COMPONENT32  0x81A7"

	<category: 'constants Ext'>
	^33191
    ]

    glMirroredRepeat [
	"GL_MIRRORED_REPEAT  0x8370"

	<category: 'constants Ext'>
	^33648
    ]

    glFogCoordinateSource [
	"GL_FOG_COORDINATE_SOURCE  0x8450"

	<category: 'constants Ext'>
	^33872
    ]

    glFogCoordinate [
	"GL_FOG_COORDINATE  0x8451"

	<category: 'constants Ext'>
	^33873
    ]

    glFragmentDepth [
	"GL_FRAGMENT_DEPTH  0x8452"

	<category: 'constants Ext'>
	^33874
    ]

    glCurrentFogCoordinate [
	"GL_CURRENT_FOG_COORDINATE  0x8453"

	<category: 'constants Ext'>
	^33875
    ]

    glFogCoordinateArrayType [
	"GL_FOG_COORDINATE_ARRAY_TYPE  0x8454"

	<category: 'constants Ext'>
	^33876
    ]

    glFogCoordinateArrayStride [
	"GL_FOG_COORDINATE_ARRAY_STRIDE  0x8455"

	<category: 'constants Ext'>
	^33877
    ]

    glFogCoordinateArrayPointer [
	"GL_FOG_COORDINATE_ARRAY_POINTER  0x8456"

	<category: 'constants Ext'>
	^33878
    ]

    glFogCoordinateArray [
	"GL_FOG_COORDINATE_ARRAY  0x8457"

	<category: 'constants Ext'>
	^33879
    ]

    glColorSum [
	"GL_COLOR_SUM  0x8458"

	<category: 'constants Ext'>
	^33880
    ]

    glCurrentSecondaryColor [
	"GL_CURRENT_SECONDARY_COLOR  0x8459"

	<category: 'constants Ext'>
	^33881
    ]

    glSecondaryColorArraySize [
	"GL_SECONDARY_COLOR_ARRAY_SIZE  0x845A"

	<category: 'constants Ext'>
	^33882
    ]

    glSecondaryColorArrayType [
	"GL_SECONDARY_COLOR_ARRAY_TYPE  0x845B"

	<category: 'constants Ext'>
	^33883
    ]

    glSecondaryColorArrayStride [
	"GL_SECONDARY_COLOR_ARRAY_STRIDE  0x845C"

	<category: 'constants Ext'>
	^33884
    ]

    glSecondaryColorArrayPointer [
	"GL_SECONDARY_COLOR_ARRAY_POINTER  0x845D"

	<category: 'constants Ext'>
	^33885
    ]

    glSecondaryColorArray [
	"GL_SECONDARY_COLOR_ARRAY  0x845E"

	<category: 'constants Ext'>
	^33886
    ]

    glMaxTextureLodBias [
	"GL_MAX_TEXTURE_LOD_BIAS  0x84FD"

	<category: 'constants Ext'>
	^34045
    ]

    glTextureFilterControl [
	"GL_TEXTURE_FILTER_CONTROL  0x8500"

	<category: 'constants Ext'>
	^34048
    ]

    glTextureLodBias [
	"GL_TEXTURE_LOD_BIAS  0x8501"

	<category: 'constants Ext'>
	^34049
    ]

    glIncrWrap [
	"GL_INCR_WRAP  0x8507"

	<category: 'constants Ext'>
	^34055
    ]

    glDecrWrap [
	"GL_DECR_WRAP  0x8508"

	<category: 'constants Ext'>
	^34056
    ]

    glTextureDepthSize [
	"GL_TEXTURE_DEPTH_SIZE  0x884A"

	<category: 'constants Ext'>
	^34890
    ]

    glDepthTextureMode [
	"GL_DEPTH_TEXTURE_MODE  0x884B"

	<category: 'constants Ext'>
	^34891
    ]

    glTextureCompareMode [
	"GL_TEXTURE_COMPARE_MODE  0x884C"

	<category: 'constants Ext'>
	^34892
    ]

    glTextureCompareFunc [
	"GL_TEXTURE_COMPARE_FUNC  0x884D"

	<category: 'constants Ext'>
	^34893
    ]

    glCompareRToTexture [
	"GL_COMPARE_R_TO_TEXTURE  0x884E"

	<category: 'constants Ext'>
	^34894
    ]

    glBufferSize [
	"GL_BUFFER_SIZE  0x8764"

	<category: 'constants Ext'>
	^34660
    ]

    glBufferUsage [
	"GL_BUFFER_USAGE  0x8765"

	<category: 'constants Ext'>
	^34661
    ]

    glQueryCounterBits [
	"GL_QUERY_COUNTER_BITS  0x8864"

	<category: 'constants Ext'>
	^34916
    ]

    glCurrentQuery [
	"GL_CURRENT_QUERY  0x8865"

	<category: 'constants Ext'>
	^34917
    ]

    glQueryResult [
	"GL_QUERY_RESULT  0x8866"

	<category: 'constants Ext'>
	^34918
    ]

    glQueryResultAvailable [
	"GL_QUERY_RESULT_AVAILABLE  0x8867"

	<category: 'constants Ext'>
	^34919
    ]

    glArrayBuffer [
	"GL_ARRAY_BUFFER  0x8892"

	<category: 'constants Ext'>
	^34962
    ]

    glElementArrayBuffer [
	"GL_ELEMENT_ARRAY_BUFFER  0x8893"

	<category: 'constants Ext'>
	^34963
    ]

    glArrayBufferBinding [
	"GL_ARRAY_BUFFER_BINDING  0x8894"

	<category: 'constants Ext'>
	^34964
    ]

    glElementArrayBufferBinding [
	"GL_ELEMENT_ARRAY_BUFFER_BINDING  0x8895"

	<category: 'constants Ext'>
	^34965
    ]

    glVertexArrayBufferBinding [
	"GL_VERTEX_ARRAY_BUFFER_BINDING  0x8896"

	<category: 'constants Ext'>
	^34966
    ]

    glNormalArrayBufferBinding [
	"GL_NORMAL_ARRAY_BUFFER_BINDING  0x8897"

	<category: 'constants Ext'>
	^34967
    ]

    glColorArrayBufferBinding [
	"GL_COLOR_ARRAY_BUFFER_BINDING  0x8898"

	<category: 'constants Ext'>
	^34968
    ]

    glIndexArrayBufferBinding [
	"GL_INDEX_ARRAY_BUFFER_BINDING  0x8899"

	<category: 'constants Ext'>
	^34969
    ]

    glTextureCoordArrayBufferBinding [
	"GL_TEXTURE_COORD_ARRAY_BUFFER_BINDING  0x889A"

	<category: 'constants Ext'>
	^34970
    ]

    glEdgeFlagArrayBufferBinding [
	"GL_EDGE_FLAG_ARRAY_BUFFER_BINDING  0x889B"

	<category: 'constants Ext'>
	^34971
    ]

    glSecondaryColorArrayBufferBinding [
	"GL_SECONDARY_COLOR_ARRAY_BUFFER_BINDING  0x889C"

	<category: 'constants Ext'>
	^34972
    ]

    glFogCoordinateArrayBufferBinding [
	"GL_FOG_COORDINATE_ARRAY_BUFFER_BINDING  0x889D"

	<category: 'constants Ext'>
	^34973
    ]

    glWeightArrayBufferBinding [
	"GL_WEIGHT_ARRAY_BUFFER_BINDING  0x889E"

	<category: 'constants Ext'>
	^34974
    ]

    glVertexAttribArrayBufferBinding [
	"GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING  0x889F"

	<category: 'constants Ext'>
	^34975
    ]

    glReadOnly [
	"GL_READ_ONLY  0x88B8"

	<category: 'constants Ext'>
	^35000
    ]

    glWriteOnly [
	"GL_WRITE_ONLY  0x88B9"

	<category: 'constants Ext'>
	^35001
    ]

    glReadWrite [
	"GL_READ_WRITE  0x88BA"

	<category: 'constants Ext'>
	^35002
    ]

    glBufferAccess [
	"GL_BUFFER_ACCESS  0x88BB"

	<category: 'constants Ext'>
	^35003
    ]

    glBufferMapped [
	"GL_BUFFER_MAPPED  0x88BC"

	<category: 'constants Ext'>
	^35004
    ]

    glBufferMapPointer [
	"GL_BUFFER_MAP_POINTER  0x88BD"

	<category: 'constants Ext'>
	^35005
    ]

    glStreamDraw [
	"GL_STREAM_DRAW  0x88E0"

	<category: 'constants Ext'>
	^35040
    ]

    glStreamRead [
	"GL_STREAM_READ  0x88E1"

	<category: 'constants Ext'>
	^35041
    ]

    glStreamCopy [
	"GL_STREAM_COPY  0x88E2"

	<category: 'constants Ext'>
	^35042
    ]

    glStaticDraw [
	"GL_STATIC_DRAW  0x88E4"

	<category: 'constants Ext'>
	^35044
    ]

    glStaticRead [
	"GL_STATIC_READ  0x88E5"

	<category: 'constants Ext'>
	^35045
    ]

    glStaticCopy [
	"GL_STATIC_COPY  0x88E6"

	<category: 'constants Ext'>
	^35046
    ]

    glDynamicDraw [
	"GL_DYNAMIC_DRAW  0x88E8"

	<category: 'constants Ext'>
	^35048
    ]

    glDynamicRead [
	"GL_DYNAMIC_READ  0x88E9"

	<category: 'constants Ext'>
	^35049
    ]

    glDynamicCopy [
	"GL_DYNAMIC_COPY  0x88EA"

	<category: 'constants Ext'>
	^35050
    ]

    glSamplesPassed [
	"GL_SAMPLES_PASSED  0x8914"

	<category: 'constants Ext'>
	^35092
    ]

    glFogCoordSrc [
	"GL_FOG_COORD_SRC  GL_FOG_COORDINATE_SOURCE"

	<category: 'constants Ext'>
	^1.5001199e + 21
    ]

    glFogCoord [
	"GL_FOG_COORD  GL_FOG_COORDINATE"

	<category: 'constants Ext'>
	^150012001301014
    ]

    glCurrentFogCoord [
	"GL_CURRENT_FOG_COORD  GL_CURRENT_FOG_COORDINATE"

	<category: 'constants Ext'>
	^1.20014e + 22
    ]

    glFogCoordArrayType [
	"GL_FOG_COORD_ARRAY_TYPE  GL_FOG_COORDINATE_ARRAY_TYPE"

	<category: 'constants Ext'>
	^1.5001199e + 25
    ]

    glFogCoordArrayStride [
	"GL_FOG_COORD_ARRAY_STRIDE  GL_FOG_COORDINATE_ARRAY_STRIDE"

	<category: 'constants Ext'>
	^1.5001199e + 27
    ]

    glFogCoordArrayPointer [
	"GL_FOG_COORD_ARRAY_POINTER  GL_FOG_COORDINATE_ARRAY_POINTER"

	<category: 'constants Ext'>
	^1.5001199e + 28
    ]

    glFogCoordArray [
	"GL_FOG_COORD_ARRAY  GL_FOG_COORDINATE_ARRAY"

	<category: 'constants Ext'>
	^1.5001199e + 20
    ]

    glFogCoordArrayBufferBinding [
	"GL_FOG_COORD_ARRAY_BUFFER_BINDING  GL_FOG_COORDINATE_ARRAY_BUFFER_BINDING"

	<category: 'constants Ext'>
	^1.5001199e + 35
    ]

    glSrc0Rgb [
	"GL_SRC0_RGB  GL_SOURCE0_RGB"

	<category: 'constants Ext'>
	^13400011
    ]

    glSrc1Rgb [
	"GL_SRC1_RGB  GL_SOURCE1_RGB"

	<category: 'constants Ext'>
	^13410011
    ]

    glSrc2Rgb [
	"GL_SRC2_RGB  GL_SOURCE2_RGB"

	<category: 'constants Ext'>
	^13420011
    ]

    glSrc0Alpha [
	"GL_SRC0_ALPHA  GL_SOURCE0_ALPHA"

	<category: 'constants Ext'>
	^1340100010
    ]

    glSrc1Alpha [
	"GL_SRC1_ALPHA  GL_SOURCE1_ALPHA"

	<category: 'constants Ext'>
	^1341100010
    ]

    glSrc2Alpha [
	"GL_SRC2_ALPHA  GL_SOURCE2_ALPHA"

	<category: 'constants Ext'>
	^1342100010
    ]

    glBlendEquationRgb [
	"GL_BLEND_EQUATION_RGB  GL_BLEND_EQUATION"

	<category: 'constants Ext'>
	^111413140100000
    ]

    glVertexAttribArrayEnabled [
	"GL_VERTEX_ATTRIB_ARRAY_ENABLED  0x8622"

	<category: 'constants Ext'>
	^34338
    ]

    glVertexAttribArraySize [
	"GL_VERTEX_ATTRIB_ARRAY_SIZE  0x8623"

	<category: 'constants Ext'>
	^34339
    ]

    glVertexAttribArrayStride [
	"GL_VERTEX_ATTRIB_ARRAY_STRIDE  0x8624"

	<category: 'constants Ext'>
	^34340
    ]

    glVertexAttribArrayType [
	"GL_VERTEX_ATTRIB_ARRAY_TYPE  0x8625"

	<category: 'constants Ext'>
	^34341
    ]

    glCurrentVertexAttrib [
	"GL_CURRENT_VERTEX_ATTRIB  0x8626"

	<category: 'constants Ext'>
	^34342
    ]

    glVertexProgramPointSize [
	"GL_VERTEX_PROGRAM_POINT_SIZE  0x8642"

	<category: 'constants Ext'>
	^34370
    ]

    glVertexProgramTwoSide [
	"GL_VERTEX_PROGRAM_TWO_SIDE  0x8643"

	<category: 'constants Ext'>
	^34371
    ]

    glVertexAttribArrayPointer [
	"GL_VERTEX_ATTRIB_ARRAY_POINTER  0x8645"

	<category: 'constants Ext'>
	^34373
    ]

    glStencilBackFunc [
	"GL_STENCIL_BACK_FUNC  0x8800"

	<category: 'constants Ext'>
	^34816
    ]

    glStencilBackFail [
	"GL_STENCIL_BACK_FAIL  0x8801"

	<category: 'constants Ext'>
	^34817
    ]

    glStencilBackPassDepthFail [
	"GL_STENCIL_BACK_PASS_DEPTH_FAIL  0x8802"

	<category: 'constants Ext'>
	^34818
    ]

    glStencilBackPassDepthPass [
	"GL_STENCIL_BACK_PASS_DEPTH_PASS  0x8803"

	<category: 'constants Ext'>
	^34819
    ]

    glMaxDrawBuffers [
	"GL_MAX_DRAW_BUFFERS  0x8824"

	<category: 'constants Ext'>
	^34852
    ]

    glDrawBuffer0 [
	"GL_DRAW_BUFFER0  0x8825"

	<category: 'constants Ext'>
	^34853
    ]

    glDrawBuffer1 [
	"GL_DRAW_BUFFER1  0x8826"

	<category: 'constants Ext'>
	^34854
    ]

    glDrawBuffer2 [
	"GL_DRAW_BUFFER2  0x8827"

	<category: 'constants Ext'>
	^34855
    ]

    glDrawBuffer3 [
	"GL_DRAW_BUFFER3  0x8828"

	<category: 'constants Ext'>
	^34856
    ]

    glDrawBuffer4 [
	"GL_DRAW_BUFFER4  0x8829"

	<category: 'constants Ext'>
	^34857
    ]

    glDrawBuffer5 [
	"GL_DRAW_BUFFER5  0x882A"

	<category: 'constants Ext'>
	^34858
    ]

    glDrawBuffer6 [
	"GL_DRAW_BUFFER6  0x882B"

	<category: 'constants Ext'>
	^34859
    ]

    glDrawBuffer7 [
	"GL_DRAW_BUFFER7  0x882C"

	<category: 'constants Ext'>
	^34860
    ]

    glDrawBuffer8 [
	"GL_DRAW_BUFFER8  0x882D"

	<category: 'constants Ext'>
	^34861
    ]

    glDrawBuffer9 [
	"GL_DRAW_BUFFER9  0x882E"

	<category: 'constants Ext'>
	^34862
    ]

    glDrawBuffer10 [
	"GL_DRAW_BUFFER10  0x882F"

	<category: 'constants Ext'>
	^34863
    ]

    glDrawBuffer11 [
	"GL_DRAW_BUFFER11  0x8830"

	<category: 'constants Ext'>
	^34864
    ]

    glDrawBuffer12 [
	"GL_DRAW_BUFFER12  0x8831"

	<category: 'constants Ext'>
	^34865
    ]

    glDrawBuffer13 [
	"GL_DRAW_BUFFER13  0x8832"

	<category: 'constants Ext'>
	^34866
    ]

    glDrawBuffer14 [
	"GL_DRAW_BUFFER14  0x8833"

	<category: 'constants Ext'>
	^34867
    ]

    glDrawBuffer15 [
	"GL_DRAW_BUFFER15  0x8834"

	<category: 'constants Ext'>
	^34868
    ]

    glBlendEquationAlpha [
	"GL_BLEND_EQUATION_ALPHA  0x883D"

	<category: 'constants Ext'>
	^34877
    ]

    glPointSprite [
	"GL_POINT_SPRITE  0x8861"

	<category: 'constants Ext'>
	^34913
    ]

    glCoordReplace [
	"GL_COORD_REPLACE  0x8862"

	<category: 'constants Ext'>
	^34914
    ]

    glMaxVertexAttribs [
	"GL_MAX_VERTEX_ATTRIBS  0x8869"

	<category: 'constants Ext'>
	^34921
    ]

    glVertexAttribArrayNormalized [
	"GL_VERTEX_ATTRIB_ARRAY_NORMALIZED  0x886A"

	<category: 'constants Ext'>
	^34922
    ]

    glMaxTextureCoords [
	"GL_MAX_TEXTURE_COORDS  0x8871"

	<category: 'constants Ext'>
	^34929
    ]

    glMaxTextureImageUnits [
	"GL_MAX_TEXTURE_IMAGE_UNITS  0x8872"

	<category: 'constants Ext'>
	^34930
    ]

    glFragmentShader [
	"GL_FRAGMENT_SHADER  0x8B30"

	<category: 'constants Ext'>
	^35632
    ]

    glVertexShader [
	"GL_VERTEX_SHADER  0x8B31"

	<category: 'constants Ext'>
	^35633
    ]

    glMaxFragmentUniformComponents [
	"GL_MAX_FRAGMENT_UNIFORM_COMPONENTS  0x8B49"

	<category: 'constants Ext'>
	^35657
    ]

    glMaxVertexUniformComponents [
	"GL_MAX_VERTEX_UNIFORM_COMPONENTS  0x8B4A"

	<category: 'constants Ext'>
	^35658
    ]

    glMaxVaryingFloats [
	"GL_MAX_VARYING_FLOATS  0x8B4B"

	<category: 'constants Ext'>
	^35659
    ]

    glMaxVertexTextureImageUnits [
	"GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS  0x8B4C"

	<category: 'constants Ext'>
	^35660
    ]

    glMaxCombinedTextureImageUnits [
	"GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS  0x8B4D"

	<category: 'constants Ext'>
	^35661
    ]

    glShaderType [
	"GL_SHADER_TYPE  0x8B4F"

	<category: 'constants Ext'>
	^35663
    ]

    glFloatVec2 [
	"GL_FLOAT_VEC2  0x8B50"

	<category: 'constants Ext'>
	^35664
    ]

    glFloatVec3 [
	"GL_FLOAT_VEC3  0x8B51"

	<category: 'constants Ext'>
	^35665
    ]

    glFloatVec4 [
	"GL_FLOAT_VEC4  0x8B52"

	<category: 'constants Ext'>
	^35666
    ]

    glIntVec2 [
	"GL_INT_VEC2  0x8B53"

	<category: 'constants Ext'>
	^35667
    ]

    glIntVec3 [
	"GL_INT_VEC3  0x8B54"

	<category: 'constants Ext'>
	^35668
    ]

    glIntVec4 [
	"GL_INT_VEC4  0x8B55"

	<category: 'constants Ext'>
	^35669
    ]

    glBool [
	"GL_BOOL  0x8B56"

	<category: 'constants Ext'>
	^35670
    ]

    glBoolVec2 [
	"GL_BOOL_VEC2  0x8B57"

	<category: 'constants Ext'>
	^35671
    ]

    glBoolVec3 [
	"GL_BOOL_VEC3  0x8B58"

	<category: 'constants Ext'>
	^35672
    ]

    glBoolVec4 [
	"GL_BOOL_VEC4  0x8B59"

	<category: 'constants Ext'>
	^35673
    ]

    glFloatMat2 [
	"GL_FLOAT_MAT2  0x8B5A"

	<category: 'constants Ext'>
	^35674
    ]

    glFloatMat3 [
	"GL_FLOAT_MAT3  0x8B5B"

	<category: 'constants Ext'>
	^35675
    ]

    glFloatMat4 [
	"GL_FLOAT_MAT4  0x8B5C"

	<category: 'constants Ext'>
	^35676
    ]

    glSampler1d [
	"GL_SAMPLER_1D  0x8B5D"

	<category: 'constants Ext'>
	^35677
    ]

    glSampler2d [
	"GL_SAMPLER_2D  0x8B5E"

	<category: 'constants Ext'>
	^35678
    ]

    glSampler3d [
	"GL_SAMPLER_3D  0x8B5F"

	<category: 'constants Ext'>
	^35679
    ]

    glSamplerCube [
	"GL_SAMPLER_CUBE  0x8B60"

	<category: 'constants Ext'>
	^35680
    ]

    glSampler1dShadow [
	"GL_SAMPLER_1D_SHADOW  0x8B61"

	<category: 'constants Ext'>
	^35681
    ]

    glSampler2dShadow [
	"GL_SAMPLER_2D_SHADOW  0x8B62"

	<category: 'constants Ext'>
	^35682
    ]

    glDeleteStatus [
	"GL_DELETE_STATUS  0x8B80"

	<category: 'constants Ext'>
	^35712
    ]

    glCompileStatus [
	"GL_COMPILE_STATUS  0x8B81"

	<category: 'constants Ext'>
	^35713
    ]

    glLinkStatus [
	"GL_LINK_STATUS  0x8B82"

	<category: 'constants Ext'>
	^35714
    ]

    glValidateStatus [
	"GL_VALIDATE_STATUS  0x8B83"

	<category: 'constants Ext'>
	^35715
    ]

    glInfoLogLength [
	"GL_INFO_LOG_LENGTH  0x8B84"

	<category: 'constants Ext'>
	^35716
    ]

    glAttachedShaders [
	"GL_ATTACHED_SHADERS  0x8B85"

	<category: 'constants Ext'>
	^35717
    ]

    glActiveUniforms [
	"GL_ACTIVE_UNIFORMS  0x8B86"

	<category: 'constants Ext'>
	^35718
    ]

    glActiveUniformMaxLength [
	"GL_ACTIVE_UNIFORM_MAX_LENGTH  0x8B87"

	<category: 'constants Ext'>
	^35719
    ]

    glShaderSourceLength [
	"GL_SHADER_SOURCE_LENGTH  0x8B88"

	<category: 'constants Ext'>
	^35720
    ]

    glActiveAttributes [
	"GL_ACTIVE_ATTRIBUTES  0x8B89"

	<category: 'constants Ext'>
	^35721
    ]

    glActiveAttributeMaxLength [
	"GL_ACTIVE_ATTRIBUTE_MAX_LENGTH  0x8B8A"

	<category: 'constants Ext'>
	^35722
    ]

    glFragmentShaderDerivativeHint [
	"GL_FRAGMENT_SHADER_DERIVATIVE_HINT  0x8B8B"

	<category: 'constants Ext'>
	^35723
    ]

    glShadingLanguageVersion [
	"GL_SHADING_LANGUAGE_VERSION  0x8B8C"

	<category: 'constants Ext'>
	^35724
    ]

    glCurrentProgram [
	"GL_CURRENT_PROGRAM  0x8B8D"

	<category: 'constants Ext'>
	^35725
    ]

    glPointSpriteCoordOrigin [
	"GL_POINT_SPRITE_COORD_ORIGIN  0x8CA0"

	<category: 'constants Ext'>
	^36000
    ]

    glLowerLeft [
	"GL_LOWER_LEFT  0x8CA1"

	<category: 'constants Ext'>
	^36001
    ]

    glUpperLeft [
	"GL_UPPER_LEFT  0x8CA2"

	<category: 'constants Ext'>
	^36002
    ]

    glStencilBackRef [
	"GL_STENCIL_BACK_REF  0x8CA3"

	<category: 'constants Ext'>
	^36003
    ]

    glStencilBackValueMask [
	"GL_STENCIL_BACK_VALUE_MASK  0x8CA4"

	<category: 'constants Ext'>
	^36004
    ]

    glStencilBackWritemask [
	"GL_STENCIL_BACK_WRITEMASK  0x8CA5"

	<category: 'constants Ext'>
	^36005
    ]

    glCurrentRasterSecondaryColor [
	"GL_CURRENT_RASTER_SECONDARY_COLOR  0x845F"

	<category: 'constants Ext'>
	^33887
    ]

    glPixelPackBuffer [
	"GL_PIXEL_PACK_BUFFER  0x88EB"

	<category: 'constants Ext'>
	^35051
    ]

    glPixelUnpackBuffer [
	"GL_PIXEL_UNPACK_BUFFER  0x88EC"

	<category: 'constants Ext'>
	^35052
    ]

    glPixelPackBufferBinding [
	"GL_PIXEL_PACK_BUFFER_BINDING  0x88ED"

	<category: 'constants Ext'>
	^35053
    ]

    glPixelUnpackBufferBinding [
	"GL_PIXEL_UNPACK_BUFFER_BINDING  0x88EF"

	<category: 'constants Ext'>
	^35055
    ]

    glSrgb [
	"GL_SRGB  0x8C40"

	<category: 'constants Ext'>
	^35904
    ]

    glSrgb8 [
	"GL_SRGB8  0x8C41"

	<category: 'constants Ext'>
	^35905
    ]

    glSrgbAlpha [
	"GL_SRGB_ALPHA  0x8C42"

	<category: 'constants Ext'>
	^35906
    ]

    glSrgb8Alpha8 [
	"GL_SRGB8_ALPHA8  0x8C43"

	<category: 'constants Ext'>
	^35907
    ]

    glSluminanceAlpha [
	"GL_SLUMINANCE_ALPHA  0x8C44"

	<category: 'constants Ext'>
	^35908
    ]

    glSluminance8Alpha8 [
	"GL_SLUMINANCE8_ALPHA8  0x8C45"

	<category: 'constants Ext'>
	^35909
    ]

    glSluminance [
	"GL_SLUMINANCE  0x8C46"

	<category: 'constants Ext'>
	^35910
    ]

    glSluminance8 [
	"GL_SLUMINANCE8  0x8C47"

	<category: 'constants Ext'>
	^35911
    ]

    glCompressedSrgb [
	"GL_COMPRESSED_SRGB  0x8C48"

	<category: 'constants Ext'>
	^35912
    ]

    glCompressedSrgbAlpha [
	"GL_COMPRESSED_SRGB_ALPHA  0x8C49"

	<category: 'constants Ext'>
	^35913
    ]

    glCompressedSluminance [
	"GL_COMPRESSED_SLUMINANCE  0x8C4A"

	<category: 'constants Ext'>
	^35914
    ]

    glCompressedSluminanceAlpha [
	"GL_COMPRESSED_SLUMINANCE_ALPHA  0x8C4B"

	<category: 'constants Ext'>
	^35915
    ]

    glTransposeModelviewMatrixArb [
	"GL_TRANSPOSE_MODELVIEW_MATRIX_ARB  0x84E3"

	<category: 'constants Ext'>
	^34019
    ]

    glTransposeProjectionMatrixArb [
	"GL_TRANSPOSE_PROJECTION_MATRIX_ARB  0x84E4"

	<category: 'constants Ext'>
	^34020
    ]

    glTransposeTextureMatrixArb [
	"GL_TRANSPOSE_TEXTURE_MATRIX_ARB  0x84E5"

	<category: 'constants Ext'>
	^34021
    ]

    glTransposeColorMatrixArb [
	"GL_TRANSPOSE_COLOR_MATRIX_ARB  0x84E6"

	<category: 'constants Ext'>
	^34022
    ]

    glMultisampleArb [
	"GL_MULTISAMPLE_ARB  0x809D"

	<category: 'constants Ext'>
	^32925
    ]

    glSampleAlphaToCoverageArb [
	"GL_SAMPLE_ALPHA_TO_COVERAGE_ARB  0x809E"

	<category: 'constants Ext'>
	^32926
    ]

    glSampleAlphaToOneArb [
	"GL_SAMPLE_ALPHA_TO_ONE_ARB  0x809F"

	<category: 'constants Ext'>
	^32927
    ]

    glSampleCoverageArb [
	"GL_SAMPLE_COVERAGE_ARB  0x80A0"

	<category: 'constants Ext'>
	^32928
    ]

    glSampleBuffersArb [
	"GL_SAMPLE_BUFFERS_ARB  0x80A8"

	<category: 'constants Ext'>
	^32936
    ]

    glSamplesArb [
	"GL_SAMPLES_ARB  0x80A9"

	<category: 'constants Ext'>
	^32937
    ]

    glSampleCoverageValueArb [
	"GL_SAMPLE_COVERAGE_VALUE_ARB  0x80AA"

	<category: 'constants Ext'>
	^32938
    ]

    glSampleCoverageInvertArb [
	"GL_SAMPLE_COVERAGE_INVERT_ARB  0x80AB"

	<category: 'constants Ext'>
	^32939
    ]

    glMultisampleBitArb [
	"GL_MULTISAMPLE_BIT_ARB  0x20000000"

	<category: 'constants Ext'>
	^536870912
    ]

    glNormalMapArb [
	"GL_NORMAL_MAP_ARB  0x8511"

	<category: 'constants Ext'>
	^34065
    ]

    glReflectionMapArb [
	"GL_REFLECTION_MAP_ARB  0x8512"

	<category: 'constants Ext'>
	^34066
    ]

    glTextureCubeMapArb [
	"GL_TEXTURE_CUBE_MAP_ARB  0x8513"

	<category: 'constants Ext'>
	^34067
    ]

    glTextureBindingCubeMapArb [
	"GL_TEXTURE_BINDING_CUBE_MAP_ARB  0x8514"

	<category: 'constants Ext'>
	^34068
    ]

    glTextureCubeMapPositiveXArb [
	"GL_TEXTURE_CUBE_MAP_POSITIVE_X_ARB  0x8515"

	<category: 'constants Ext'>
	^34069
    ]

    glTextureCubeMapNegativeXArb [
	"GL_TEXTURE_CUBE_MAP_NEGATIVE_X_ARB  0x8516"

	<category: 'constants Ext'>
	^34070
    ]

    glTextureCubeMapPositiveYArb [
	"GL_TEXTURE_CUBE_MAP_POSITIVE_Y_ARB  0x8517"

	<category: 'constants Ext'>
	^34071
    ]

    glTextureCubeMapNegativeYArb [
	"GL_TEXTURE_CUBE_MAP_NEGATIVE_Y_ARB  0x8518"

	<category: 'constants Ext'>
	^34072
    ]

    glTextureCubeMapPositiveZArb [
	"GL_TEXTURE_CUBE_MAP_POSITIVE_Z_ARB  0x8519"

	<category: 'constants Ext'>
	^34073
    ]

    glTextureCubeMapNegativeZArb [
	"GL_TEXTURE_CUBE_MAP_NEGATIVE_Z_ARB  0x851A"

	<category: 'constants Ext'>
	^34074
    ]

    glProxyTextureCubeMapArb [
	"GL_PROXY_TEXTURE_CUBE_MAP_ARB  0x851B"

	<category: 'constants Ext'>
	^34075
    ]

    glMaxCubeMapTextureSizeArb [
	"GL_MAX_CUBE_MAP_TEXTURE_SIZE_ARB  0x851C"

	<category: 'constants Ext'>
	^34076
    ]

    glCompressedAlphaArb [
	"GL_COMPRESSED_ALPHA_ARB  0x84E9"

	<category: 'constants Ext'>
	^34025
    ]

    glCompressedLuminanceArb [
	"GL_COMPRESSED_LUMINANCE_ARB  0x84EA"

	<category: 'constants Ext'>
	^34026
    ]

    glCompressedLuminanceAlphaArb [
	"GL_COMPRESSED_LUMINANCE_ALPHA_ARB  0x84EB"

	<category: 'constants Ext'>
	^34027
    ]

    glCompressedIntensityArb [
	"GL_COMPRESSED_INTENSITY_ARB  0x84EC"

	<category: 'constants Ext'>
	^34028
    ]

    glCompressedRgbArb [
	"GL_COMPRESSED_RGB_ARB  0x84ED"

	<category: 'constants Ext'>
	^34029
    ]

    glCompressedRgbaArb [
	"GL_COMPRESSED_RGBA_ARB  0x84EE"

	<category: 'constants Ext'>
	^34030
    ]

    glTextureCompressionHintArb [
	"GL_TEXTURE_COMPRESSION_HINT_ARB  0x84EF"

	<category: 'constants Ext'>
	^34031
    ]

    glTextureCompressedImageSizeArb [
	"GL_TEXTURE_COMPRESSED_IMAGE_SIZE_ARB  0x86A0"

	<category: 'constants Ext'>
	^34464
    ]

    glTextureCompressedArb [
	"GL_TEXTURE_COMPRESSED_ARB  0x86A1"

	<category: 'constants Ext'>
	^34465
    ]

    glNumCompressedTextureFormatsArb [
	"GL_NUM_COMPRESSED_TEXTURE_FORMATS_ARB  0x86A2"

	<category: 'constants Ext'>
	^34466
    ]

    glCompressedTextureFormatsArb [
	"GL_COMPRESSED_TEXTURE_FORMATS_ARB  0x86A3"

	<category: 'constants Ext'>
	^34467
    ]

    glClampToBorderArb [
	"GL_CLAMP_TO_BORDER_ARB  0x812D"

	<category: 'constants Ext'>
	^33069
    ]

    glPointSizeMinArb [
	"GL_POINT_SIZE_MIN_ARB  0x8126"

	<category: 'constants Ext'>
	^33062
    ]

    glPointSizeMaxArb [
	"GL_POINT_SIZE_MAX_ARB  0x8127"

	<category: 'constants Ext'>
	^33063
    ]

    glPointFadeThresholdSizeArb [
	"GL_POINT_FADE_THRESHOLD_SIZE_ARB  0x8128"

	<category: 'constants Ext'>
	^33064
    ]

    glPointDistanceAttenuationArb [
	"GL_POINT_DISTANCE_ATTENUATION_ARB  0x8129"

	<category: 'constants Ext'>
	^33065
    ]

    glMaxVertexUnitsArb [
	"GL_MAX_VERTEX_UNITS_ARB  0x86A4"

	<category: 'constants Ext'>
	^34468
    ]

    glActiveVertexUnitsArb [
	"GL_ACTIVE_VERTEX_UNITS_ARB  0x86A5"

	<category: 'constants Ext'>
	^34469
    ]

    glWeightSumUnityArb [
	"GL_WEIGHT_SUM_UNITY_ARB  0x86A6"

	<category: 'constants Ext'>
	^34470
    ]

    glVertexBlendArb [
	"GL_VERTEX_BLEND_ARB  0x86A7"

	<category: 'constants Ext'>
	^34471
    ]

    glCurrentWeightArb [
	"GL_CURRENT_WEIGHT_ARB  0x86A8"

	<category: 'constants Ext'>
	^34472
    ]

    glWeightArrayTypeArb [
	"GL_WEIGHT_ARRAY_TYPE_ARB  0x86A9"

	<category: 'constants Ext'>
	^34473
    ]

    glWeightArrayStrideArb [
	"GL_WEIGHT_ARRAY_STRIDE_ARB  0x86AA"

	<category: 'constants Ext'>
	^34474
    ]

    glWeightArraySizeArb [
	"GL_WEIGHT_ARRAY_SIZE_ARB  0x86AB"

	<category: 'constants Ext'>
	^34475
    ]

    glWeightArrayPointerArb [
	"GL_WEIGHT_ARRAY_POINTER_ARB  0x86AC"

	<category: 'constants Ext'>
	^34476
    ]

    glWeightArrayArb [
	"GL_WEIGHT_ARRAY_ARB  0x86AD"

	<category: 'constants Ext'>
	^34477
    ]

    glModelview0Arb [
	"GL_MODELVIEW0_ARB  0x1700"

	<category: 'constants Ext'>
	^5888
    ]

    glModelview1Arb [
	"GL_MODELVIEW1_ARB  0x850A"

	<category: 'constants Ext'>
	^34058
    ]

    glModelview2Arb [
	"GL_MODELVIEW2_ARB  0x8722"

	<category: 'constants Ext'>
	^34594
    ]

    glModelview3Arb [
	"GL_MODELVIEW3_ARB  0x8723"

	<category: 'constants Ext'>
	^34595
    ]

    glModelview4Arb [
	"GL_MODELVIEW4_ARB  0x8724"

	<category: 'constants Ext'>
	^34596
    ]

    glModelview5Arb [
	"GL_MODELVIEW5_ARB  0x8725"

	<category: 'constants Ext'>
	^34597
    ]

    glModelview6Arb [
	"GL_MODELVIEW6_ARB  0x8726"

	<category: 'constants Ext'>
	^34598
    ]

    glModelview7Arb [
	"GL_MODELVIEW7_ARB  0x8727"

	<category: 'constants Ext'>
	^34599
    ]

    glModelview8Arb [
	"GL_MODELVIEW8_ARB  0x8728"

	<category: 'constants Ext'>
	^34600
    ]

    glModelview9Arb [
	"GL_MODELVIEW9_ARB  0x8729"

	<category: 'constants Ext'>
	^34601
    ]

    glModelview10Arb [
	"GL_MODELVIEW10_ARB  0x872A"

	<category: 'constants Ext'>
	^34602
    ]

    glModelview11Arb [
	"GL_MODELVIEW11_ARB  0x872B"

	<category: 'constants Ext'>
	^34603
    ]

    glModelview12Arb [
	"GL_MODELVIEW12_ARB  0x872C"

	<category: 'constants Ext'>
	^34604
    ]

    glModelview13Arb [
	"GL_MODELVIEW13_ARB  0x872D"

	<category: 'constants Ext'>
	^34605
    ]

    glModelview14Arb [
	"GL_MODELVIEW14_ARB  0x872E"

	<category: 'constants Ext'>
	^34606
    ]

    glModelview15Arb [
	"GL_MODELVIEW15_ARB  0x872F"

	<category: 'constants Ext'>
	^34607
    ]

    glModelview16Arb [
	"GL_MODELVIEW16_ARB  0x8730"

	<category: 'constants Ext'>
	^34608
    ]

    glModelview17Arb [
	"GL_MODELVIEW17_ARB  0x8731"

	<category: 'constants Ext'>
	^34609
    ]

    glModelview18Arb [
	"GL_MODELVIEW18_ARB  0x8732"

	<category: 'constants Ext'>
	^34610
    ]

    glModelview19Arb [
	"GL_MODELVIEW19_ARB  0x8733"

	<category: 'constants Ext'>
	^34611
    ]

    glModelview20Arb [
	"GL_MODELVIEW20_ARB  0x8734"

	<category: 'constants Ext'>
	^34612
    ]

    glModelview21Arb [
	"GL_MODELVIEW21_ARB  0x8735"

	<category: 'constants Ext'>
	^34613
    ]

    glModelview22Arb [
	"GL_MODELVIEW22_ARB  0x8736"

	<category: 'constants Ext'>
	^34614
    ]

    glModelview23Arb [
	"GL_MODELVIEW23_ARB  0x8737"

	<category: 'constants Ext'>
	^34615
    ]

    glModelview24Arb [
	"GL_MODELVIEW24_ARB  0x8738"

	<category: 'constants Ext'>
	^34616
    ]

    glModelview25Arb [
	"GL_MODELVIEW25_ARB  0x8739"

	<category: 'constants Ext'>
	^34617
    ]

    glModelview26Arb [
	"GL_MODELVIEW26_ARB  0x873A"

	<category: 'constants Ext'>
	^34618
    ]

    glModelview27Arb [
	"GL_MODELVIEW27_ARB  0x873B"

	<category: 'constants Ext'>
	^34619
    ]

    glModelview28Arb [
	"GL_MODELVIEW28_ARB  0x873C"

	<category: 'constants Ext'>
	^34620
    ]

    glModelview29Arb [
	"GL_MODELVIEW29_ARB  0x873D"

	<category: 'constants Ext'>
	^34621
    ]

    glModelview30Arb [
	"GL_MODELVIEW30_ARB  0x873E"

	<category: 'constants Ext'>
	^34622
    ]

    glModelview31Arb [
	"GL_MODELVIEW31_ARB  0x873F"

	<category: 'constants Ext'>
	^34623
    ]

    glMatrixPaletteArb [
	"GL_MATRIX_PALETTE_ARB  0x8840"

	<category: 'constants Ext'>
	^34880
    ]

    glMaxMatrixPaletteStackDepthArb [
	"GL_MAX_MATRIX_PALETTE_STACK_DEPTH_ARB  0x8841"

	<category: 'constants Ext'>
	^34881
    ]

    glMaxPaletteMatricesArb [
	"GL_MAX_PALETTE_MATRICES_ARB  0x8842"

	<category: 'constants Ext'>
	^34882
    ]

    glCurrentPaletteMatrixArb [
	"GL_CURRENT_PALETTE_MATRIX_ARB  0x8843"

	<category: 'constants Ext'>
	^34883
    ]

    glMatrixIndexArrayArb [
	"GL_MATRIX_INDEX_ARRAY_ARB  0x8844"

	<category: 'constants Ext'>
	^34884
    ]

    glCurrentMatrixIndexArb [
	"GL_CURRENT_MATRIX_INDEX_ARB  0x8845"

	<category: 'constants Ext'>
	^34885
    ]

    glMatrixIndexArraySizeArb [
	"GL_MATRIX_INDEX_ARRAY_SIZE_ARB  0x8846"

	<category: 'constants Ext'>
	^34886
    ]

    glMatrixIndexArrayTypeArb [
	"GL_MATRIX_INDEX_ARRAY_TYPE_ARB  0x8847"

	<category: 'constants Ext'>
	^34887
    ]

    glMatrixIndexArrayStrideArb [
	"GL_MATRIX_INDEX_ARRAY_STRIDE_ARB  0x8848"

	<category: 'constants Ext'>
	^34888
    ]

    glMatrixIndexArrayPointerArb [
	"GL_MATRIX_INDEX_ARRAY_POINTER_ARB  0x8849"

	<category: 'constants Ext'>
	^34889
    ]

    glCombineArb [
	"GL_COMBINE_ARB  0x8570"

	<category: 'constants Ext'>
	^34160
    ]

    glCombineRgbArb [
	"GL_COMBINE_RGB_ARB  0x8571"

	<category: 'constants Ext'>
	^34161
    ]

    glCombineAlphaArb [
	"GL_COMBINE_ALPHA_ARB  0x8572"

	<category: 'constants Ext'>
	^34162
    ]

    glSource0RgbArb [
	"GL_SOURCE0_RGB_ARB  0x8580"

	<category: 'constants Ext'>
	^34176
    ]

    glSource1RgbArb [
	"GL_SOURCE1_RGB_ARB  0x8581"

	<category: 'constants Ext'>
	^34177
    ]

    glSource2RgbArb [
	"GL_SOURCE2_RGB_ARB  0x8582"

	<category: 'constants Ext'>
	^34178
    ]

    glSource0AlphaArb [
	"GL_SOURCE0_ALPHA_ARB  0x8588"

	<category: 'constants Ext'>
	^34184
    ]

    glSource1AlphaArb [
	"GL_SOURCE1_ALPHA_ARB  0x8589"

	<category: 'constants Ext'>
	^34185
    ]

    glSource2AlphaArb [
	"GL_SOURCE2_ALPHA_ARB  0x858A"

	<category: 'constants Ext'>
	^34186
    ]

    glOperand0RgbArb [
	"GL_OPERAND0_RGB_ARB  0x8590"

	<category: 'constants Ext'>
	^34192
    ]

    glOperand1RgbArb [
	"GL_OPERAND1_RGB_ARB  0x8591"

	<category: 'constants Ext'>
	^34193
    ]

    glOperand2RgbArb [
	"GL_OPERAND2_RGB_ARB  0x8592"

	<category: 'constants Ext'>
	^34194
    ]

    glOperand0AlphaArb [
	"GL_OPERAND0_ALPHA_ARB  0x8598"

	<category: 'constants Ext'>
	^34200
    ]

    glOperand1AlphaArb [
	"GL_OPERAND1_ALPHA_ARB  0x8599"

	<category: 'constants Ext'>
	^34201
    ]

    glOperand2AlphaArb [
	"GL_OPERAND2_ALPHA_ARB  0x859A"

	<category: 'constants Ext'>
	^34202
    ]

    glRgbScaleArb [
	"GL_RGB_SCALE_ARB  0x8573"

	<category: 'constants Ext'>
	^34163
    ]

    glAddSignedArb [
	"GL_ADD_SIGNED_ARB  0x8574"

	<category: 'constants Ext'>
	^34164
    ]

    glInterpolateArb [
	"GL_INTERPOLATE_ARB  0x8575"

	<category: 'constants Ext'>
	^34165
    ]

    glSubtractArb [
	"GL_SUBTRACT_ARB  0x84E7"

	<category: 'constants Ext'>
	^34023
    ]

    glConstantArb [
	"GL_CONSTANT_ARB  0x8576"

	<category: 'constants Ext'>
	^34166
    ]

    glPrimaryColorArb [
	"GL_PRIMARY_COLOR_ARB  0x8577"

	<category: 'constants Ext'>
	^34167
    ]

    glPreviousArb [
	"GL_PREVIOUS_ARB  0x8578"

	<category: 'constants Ext'>
	^34168
    ]

    glDot3RgbArb [
	"GL_DOT3_RGB_ARB  0x86AE"

	<category: 'constants Ext'>
	^34478
    ]

    glDot3RgbaArb [
	"GL_DOT3_RGBA_ARB  0x86AF"

	<category: 'constants Ext'>
	^34479
    ]

    glMirroredRepeatArb [
	"GL_MIRRORED_REPEAT_ARB  0x8370"

	<category: 'constants Ext'>
	^33648
    ]

    glDepthComponent16Arb [
	"GL_DEPTH_COMPONENT16_ARB  0x81A5"

	<category: 'constants Ext'>
	^33189
    ]

    glDepthComponent24Arb [
	"GL_DEPTH_COMPONENT24_ARB  0x81A6"

	<category: 'constants Ext'>
	^33190
    ]

    glDepthComponent32Arb [
	"GL_DEPTH_COMPONENT32_ARB  0x81A7"

	<category: 'constants Ext'>
	^33191
    ]

    glTextureDepthSizeArb [
	"GL_TEXTURE_DEPTH_SIZE_ARB  0x884A"

	<category: 'constants Ext'>
	^34890
    ]

    glDepthTextureModeArb [
	"GL_DEPTH_TEXTURE_MODE_ARB  0x884B"

	<category: 'constants Ext'>
	^34891
    ]

    glTextureCompareModeArb [
	"GL_TEXTURE_COMPARE_MODE_ARB  0x884C"

	<category: 'constants Ext'>
	^34892
    ]

    glTextureCompareFuncArb [
	"GL_TEXTURE_COMPARE_FUNC_ARB  0x884D"

	<category: 'constants Ext'>
	^34893
    ]

    glCompareRToTextureArb [
	"GL_COMPARE_R_TO_TEXTURE_ARB  0x884E"

	<category: 'constants Ext'>
	^34894
    ]

    glTextureCompareFailValueArb [
	"GL_TEXTURE_COMPARE_FAIL_VALUE_ARB  0x80BF"

	<category: 'constants Ext'>
	^32959
    ]

    glColorSumArb [
	"GL_COLOR_SUM_ARB  0x8458"

	<category: 'constants Ext'>
	^33880
    ]

    glVertexProgramArb [
	"GL_VERTEX_PROGRAM_ARB  0x8620"

	<category: 'constants Ext'>
	^34336
    ]

    glVertexAttribArrayEnabledArb [
	"GL_VERTEX_ATTRIB_ARRAY_ENABLED_ARB  0x8622"

	<category: 'constants Ext'>
	^34338
    ]

    glVertexAttribArraySizeArb [
	"GL_VERTEX_ATTRIB_ARRAY_SIZE_ARB  0x8623"

	<category: 'constants Ext'>
	^34339
    ]

    glVertexAttribArrayStrideArb [
	"GL_VERTEX_ATTRIB_ARRAY_STRIDE_ARB  0x8624"

	<category: 'constants Ext'>
	^34340
    ]

    glVertexAttribArrayTypeArb [
	"GL_VERTEX_ATTRIB_ARRAY_TYPE_ARB  0x8625"

	<category: 'constants Ext'>
	^34341
    ]

    glCurrentVertexAttribArb [
	"GL_CURRENT_VERTEX_ATTRIB_ARB  0x8626"

	<category: 'constants Ext'>
	^34342
    ]

    glProgramLengthArb [
	"GL_PROGRAM_LENGTH_ARB  0x8627"

	<category: 'constants Ext'>
	^34343
    ]

    glProgramStringArb [
	"GL_PROGRAM_STRING_ARB  0x8628"

	<category: 'constants Ext'>
	^34344
    ]

    glMaxProgramMatrixStackDepthArb [
	"GL_MAX_PROGRAM_MATRIX_STACK_DEPTH_ARB  0x862E"

	<category: 'constants Ext'>
	^34350
    ]

    glMaxProgramMatricesArb [
	"GL_MAX_PROGRAM_MATRICES_ARB  0x862F"

	<category: 'constants Ext'>
	^34351
    ]

    glCurrentMatrixStackDepthArb [
	"GL_CURRENT_MATRIX_STACK_DEPTH_ARB  0x8640"

	<category: 'constants Ext'>
	^34368
    ]

    glCurrentMatrixArb [
	"GL_CURRENT_MATRIX_ARB  0x8641"

	<category: 'constants Ext'>
	^34369
    ]

    glVertexProgramPointSizeArb [
	"GL_VERTEX_PROGRAM_POINT_SIZE_ARB  0x8642"

	<category: 'constants Ext'>
	^34370
    ]

    glVertexProgramTwoSideArb [
	"GL_VERTEX_PROGRAM_TWO_SIDE_ARB  0x8643"

	<category: 'constants Ext'>
	^34371
    ]

    glVertexAttribArrayPointerArb [
	"GL_VERTEX_ATTRIB_ARRAY_POINTER_ARB  0x8645"

	<category: 'constants Ext'>
	^34373
    ]

    glProgramErrorPositionArb [
	"GL_PROGRAM_ERROR_POSITION_ARB  0x864B"

	<category: 'constants Ext'>
	^34379
    ]

    glProgramBindingArb [
	"GL_PROGRAM_BINDING_ARB  0x8677"

	<category: 'constants Ext'>
	^34423
    ]

    glMaxVertexAttribsArb [
	"GL_MAX_VERTEX_ATTRIBS_ARB  0x8869"

	<category: 'constants Ext'>
	^34921
    ]

    glVertexAttribArrayNormalizedArb [
	"GL_VERTEX_ATTRIB_ARRAY_NORMALIZED_ARB  0x886A"

	<category: 'constants Ext'>
	^34922
    ]

    glProgramErrorStringArb [
	"GL_PROGRAM_ERROR_STRING_ARB  0x8874"

	<category: 'constants Ext'>
	^34932
    ]

    glProgramFormatAsciiArb [
	"GL_PROGRAM_FORMAT_ASCII_ARB  0x8875"

	<category: 'constants Ext'>
	^34933
    ]

    glProgramFormatArb [
	"GL_PROGRAM_FORMAT_ARB  0x8876"

	<category: 'constants Ext'>
	^34934
    ]

    glProgramInstructionsArb [
	"GL_PROGRAM_INSTRUCTIONS_ARB  0x88A0"

	<category: 'constants Ext'>
	^34976
    ]

    glMaxProgramInstructionsArb [
	"GL_MAX_PROGRAM_INSTRUCTIONS_ARB  0x88A1"

	<category: 'constants Ext'>
	^34977
    ]

    glProgramNativeInstructionsArb [
	"GL_PROGRAM_NATIVE_INSTRUCTIONS_ARB  0x88A2"

	<category: 'constants Ext'>
	^34978
    ]

    glMaxProgramNativeInstructionsArb [
	"GL_MAX_PROGRAM_NATIVE_INSTRUCTIONS_ARB  0x88A3"

	<category: 'constants Ext'>
	^34979
    ]

    glProgramTemporariesArb [
	"GL_PROGRAM_TEMPORARIES_ARB  0x88A4"

	<category: 'constants Ext'>
	^34980
    ]

    glMaxProgramTemporariesArb [
	"GL_MAX_PROGRAM_TEMPORARIES_ARB  0x88A5"

	<category: 'constants Ext'>
	^34981
    ]

    glProgramNativeTemporariesArb [
	"GL_PROGRAM_NATIVE_TEMPORARIES_ARB  0x88A6"

	<category: 'constants Ext'>
	^34982
    ]

    glMaxProgramNativeTemporariesArb [
	"GL_MAX_PROGRAM_NATIVE_TEMPORARIES_ARB  0x88A7"

	<category: 'constants Ext'>
	^34983
    ]

    glProgramParametersArb [
	"GL_PROGRAM_PARAMETERS_ARB  0x88A8"

	<category: 'constants Ext'>
	^34984
    ]

    glMaxProgramParametersArb [
	"GL_MAX_PROGRAM_PARAMETERS_ARB  0x88A9"

	<category: 'constants Ext'>
	^34985
    ]

    glProgramNativeParametersArb [
	"GL_PROGRAM_NATIVE_PARAMETERS_ARB  0x88AA"

	<category: 'constants Ext'>
	^34986
    ]

    glMaxProgramNativeParametersArb [
	"GL_MAX_PROGRAM_NATIVE_PARAMETERS_ARB  0x88AB"

	<category: 'constants Ext'>
	^34987
    ]

    glProgramAttribsArb [
	"GL_PROGRAM_ATTRIBS_ARB  0x88AC"

	<category: 'constants Ext'>
	^34988
    ]

    glMaxProgramAttribsArb [
	"GL_MAX_PROGRAM_ATTRIBS_ARB  0x88AD"

	<category: 'constants Ext'>
	^34989
    ]

    glProgramNativeAttribsArb [
	"GL_PROGRAM_NATIVE_ATTRIBS_ARB  0x88AE"

	<category: 'constants Ext'>
	^34990
    ]

    glMaxProgramNativeAttribsArb [
	"GL_MAX_PROGRAM_NATIVE_ATTRIBS_ARB  0x88AF"

	<category: 'constants Ext'>
	^34991
    ]

    glProgramAddressRegistersArb [
	"GL_PROGRAM_ADDRESS_REGISTERS_ARB  0x88B0"

	<category: 'constants Ext'>
	^34992
    ]

    glMaxProgramAddressRegistersArb [
	"GL_MAX_PROGRAM_ADDRESS_REGISTERS_ARB  0x88B1"

	<category: 'constants Ext'>
	^34993
    ]

    glProgramNativeAddressRegistersArb [
	"GL_PROGRAM_NATIVE_ADDRESS_REGISTERS_ARB  0x88B2"

	<category: 'constants Ext'>
	^34994
    ]

    glMaxProgramNativeAddressRegistersArb [
	"GL_MAX_PROGRAM_NATIVE_ADDRESS_REGISTERS_ARB  0x88B3"

	<category: 'constants Ext'>
	^34995
    ]

    glMaxProgramLocalParametersArb [
	"GL_MAX_PROGRAM_LOCAL_PARAMETERS_ARB  0x88B4"

	<category: 'constants Ext'>
	^34996
    ]

    glMaxProgramEnvParametersArb [
	"GL_MAX_PROGRAM_ENV_PARAMETERS_ARB  0x88B5"

	<category: 'constants Ext'>
	^34997
    ]

    glProgramUnderNativeLimitsArb [
	"GL_PROGRAM_UNDER_NATIVE_LIMITS_ARB  0x88B6"

	<category: 'constants Ext'>
	^34998
    ]

    glTransposeCurrentMatrixArb [
	"GL_TRANSPOSE_CURRENT_MATRIX_ARB  0x88B7"

	<category: 'constants Ext'>
	^34999
    ]

    glMatrix0Arb [
	"GL_MATRIX0_ARB  0x88C0"

	<category: 'constants Ext'>
	^35008
    ]

    glMatrix1Arb [
	"GL_MATRIX1_ARB  0x88C1"

	<category: 'constants Ext'>
	^35009
    ]

    glMatrix2Arb [
	"GL_MATRIX2_ARB  0x88C2"

	<category: 'constants Ext'>
	^35010
    ]

    glMatrix3Arb [
	"GL_MATRIX3_ARB  0x88C3"

	<category: 'constants Ext'>
	^35011
    ]

    glMatrix4Arb [
	"GL_MATRIX4_ARB  0x88C4"

	<category: 'constants Ext'>
	^35012
    ]

    glMatrix5Arb [
	"GL_MATRIX5_ARB  0x88C5"

	<category: 'constants Ext'>
	^35013
    ]

    glMatrix6Arb [
	"GL_MATRIX6_ARB  0x88C6"

	<category: 'constants Ext'>
	^35014
    ]

    glMatrix7Arb [
	"GL_MATRIX7_ARB  0x88C7"

	<category: 'constants Ext'>
	^35015
    ]

    glMatrix8Arb [
	"GL_MATRIX8_ARB  0x88C8"

	<category: 'constants Ext'>
	^35016
    ]

    glMatrix9Arb [
	"GL_MATRIX9_ARB  0x88C9"

	<category: 'constants Ext'>
	^35017
    ]

    glMatrix10Arb [
	"GL_MATRIX10_ARB  0x88CA"

	<category: 'constants Ext'>
	^35018
    ]

    glMatrix11Arb [
	"GL_MATRIX11_ARB  0x88CB"

	<category: 'constants Ext'>
	^35019
    ]

    glMatrix12Arb [
	"GL_MATRIX12_ARB  0x88CC"

	<category: 'constants Ext'>
	^35020
    ]

    glMatrix13Arb [
	"GL_MATRIX13_ARB  0x88CD"

	<category: 'constants Ext'>
	^35021
    ]

    glMatrix14Arb [
	"GL_MATRIX14_ARB  0x88CE"

	<category: 'constants Ext'>
	^35022
    ]

    glMatrix15Arb [
	"GL_MATRIX15_ARB  0x88CF"

	<category: 'constants Ext'>
	^35023
    ]

    glMatrix16Arb [
	"GL_MATRIX16_ARB  0x88D0"

	<category: 'constants Ext'>
	^35024
    ]

    glMatrix17Arb [
	"GL_MATRIX17_ARB  0x88D1"

	<category: 'constants Ext'>
	^35025
    ]

    glMatrix18Arb [
	"GL_MATRIX18_ARB  0x88D2"

	<category: 'constants Ext'>
	^35026
    ]

    glMatrix19Arb [
	"GL_MATRIX19_ARB  0x88D3"

	<category: 'constants Ext'>
	^35027
    ]

    glMatrix20Arb [
	"GL_MATRIX20_ARB  0x88D4"

	<category: 'constants Ext'>
	^35028
    ]

    glMatrix21Arb [
	"GL_MATRIX21_ARB  0x88D5"

	<category: 'constants Ext'>
	^35029
    ]

    glMatrix22Arb [
	"GL_MATRIX22_ARB  0x88D6"

	<category: 'constants Ext'>
	^35030
    ]

    glMatrix23Arb [
	"GL_MATRIX23_ARB  0x88D7"

	<category: 'constants Ext'>
	^35031
    ]

    glMatrix24Arb [
	"GL_MATRIX24_ARB  0x88D8"

	<category: 'constants Ext'>
	^35032
    ]

    glMatrix25Arb [
	"GL_MATRIX25_ARB  0x88D9"

	<category: 'constants Ext'>
	^35033
    ]

    glMatrix26Arb [
	"GL_MATRIX26_ARB  0x88DA"

	<category: 'constants Ext'>
	^35034
    ]

    glMatrix27Arb [
	"GL_MATRIX27_ARB  0x88DB"

	<category: 'constants Ext'>
	^35035
    ]

    glMatrix28Arb [
	"GL_MATRIX28_ARB  0x88DC"

	<category: 'constants Ext'>
	^35036
    ]

    glMatrix29Arb [
	"GL_MATRIX29_ARB  0x88DD"

	<category: 'constants Ext'>
	^35037
    ]

    glMatrix30Arb [
	"GL_MATRIX30_ARB  0x88DE"

	<category: 'constants Ext'>
	^35038
    ]

    glMatrix31Arb [
	"GL_MATRIX31_ARB  0x88DF"

	<category: 'constants Ext'>
	^35039
    ]

    glFragmentProgramArb [
	"GL_FRAGMENT_PROGRAM_ARB  0x8804"

	<category: 'constants Ext'>
	^34820
    ]

    glProgramAluInstructionsArb [
	"GL_PROGRAM_ALU_INSTRUCTIONS_ARB  0x8805"

	<category: 'constants Ext'>
	^34821
    ]

    glProgramTexInstructionsArb [
	"GL_PROGRAM_TEX_INSTRUCTIONS_ARB  0x8806"

	<category: 'constants Ext'>
	^34822
    ]

    glProgramTexIndirectionsArb [
	"GL_PROGRAM_TEX_INDIRECTIONS_ARB  0x8807"

	<category: 'constants Ext'>
	^34823
    ]

    glProgramNativeAluInstructionsArb [
	"GL_PROGRAM_NATIVE_ALU_INSTRUCTIONS_ARB  0x8808"

	<category: 'constants Ext'>
	^34824
    ]

    glProgramNativeTexInstructionsArb [
	"GL_PROGRAM_NATIVE_TEX_INSTRUCTIONS_ARB  0x8809"

	<category: 'constants Ext'>
	^34825
    ]

    glProgramNativeTexIndirectionsArb [
	"GL_PROGRAM_NATIVE_TEX_INDIRECTIONS_ARB  0x880A"

	<category: 'constants Ext'>
	^34826
    ]

    glMaxProgramAluInstructionsArb [
	"GL_MAX_PROGRAM_ALU_INSTRUCTIONS_ARB  0x880B"

	<category: 'constants Ext'>
	^34827
    ]

    glMaxProgramTexInstructionsArb [
	"GL_MAX_PROGRAM_TEX_INSTRUCTIONS_ARB  0x880C"

	<category: 'constants Ext'>
	^34828
    ]

    glMaxProgramTexIndirectionsArb [
	"GL_MAX_PROGRAM_TEX_INDIRECTIONS_ARB  0x880D"

	<category: 'constants Ext'>
	^34829
    ]

    glMaxProgramNativeAluInstructionsArb [
	"GL_MAX_PROGRAM_NATIVE_ALU_INSTRUCTIONS_ARB  0x880E"

	<category: 'constants Ext'>
	^34830
    ]

    glMaxProgramNativeTexInstructionsArb [
	"GL_MAX_PROGRAM_NATIVE_TEX_INSTRUCTIONS_ARB  0x880F"

	<category: 'constants Ext'>
	^34831
    ]

    glMaxProgramNativeTexIndirectionsArb [
	"GL_MAX_PROGRAM_NATIVE_TEX_INDIRECTIONS_ARB  0x8810"

	<category: 'constants Ext'>
	^34832
    ]

    glMaxTextureCoordsArb [
	"GL_MAX_TEXTURE_COORDS_ARB  0x8871"

	<category: 'constants Ext'>
	^34929
    ]

    glMaxTextureImageUnitsArb [
	"GL_MAX_TEXTURE_IMAGE_UNITS_ARB  0x8872"

	<category: 'constants Ext'>
	^34930
    ]

    glBufferSizeArb [
	"GL_BUFFER_SIZE_ARB  0x8764"

	<category: 'constants Ext'>
	^34660
    ]

    glBufferUsageArb [
	"GL_BUFFER_USAGE_ARB  0x8765"

	<category: 'constants Ext'>
	^34661
    ]

    glArrayBufferArb [
	"GL_ARRAY_BUFFER_ARB  0x8892"

	<category: 'constants Ext'>
	^34962
    ]

    glElementArrayBufferArb [
	"GL_ELEMENT_ARRAY_BUFFER_ARB  0x8893"

	<category: 'constants Ext'>
	^34963
    ]

    glArrayBufferBindingArb [
	"GL_ARRAY_BUFFER_BINDING_ARB  0x8894"

	<category: 'constants Ext'>
	^34964
    ]

    glElementArrayBufferBindingArb [
	"GL_ELEMENT_ARRAY_BUFFER_BINDING_ARB  0x8895"

	<category: 'constants Ext'>
	^34965
    ]

    glVertexArrayBufferBindingArb [
	"GL_VERTEX_ARRAY_BUFFER_BINDING_ARB  0x8896"

	<category: 'constants Ext'>
	^34966
    ]

    glNormalArrayBufferBindingArb [
	"GL_NORMAL_ARRAY_BUFFER_BINDING_ARB  0x8897"

	<category: 'constants Ext'>
	^34967
    ]

    glColorArrayBufferBindingArb [
	"GL_COLOR_ARRAY_BUFFER_BINDING_ARB  0x8898"

	<category: 'constants Ext'>
	^34968
    ]

    glIndexArrayBufferBindingArb [
	"GL_INDEX_ARRAY_BUFFER_BINDING_ARB  0x8899"

	<category: 'constants Ext'>
	^34969
    ]

    glTextureCoordArrayBufferBindingArb [
	"GL_TEXTURE_COORD_ARRAY_BUFFER_BINDING_ARB  0x889A"

	<category: 'constants Ext'>
	^34970
    ]

    glEdgeFlagArrayBufferBindingArb [
	"GL_EDGE_FLAG_ARRAY_BUFFER_BINDING_ARB  0x889B"

	<category: 'constants Ext'>
	^34971
    ]

    glSecondaryColorArrayBufferBindingArb [
	"GL_SECONDARY_COLOR_ARRAY_BUFFER_BINDING_ARB  0x889C"

	<category: 'constants Ext'>
	^34972
    ]

    glFogCoordinateArrayBufferBindingArb [
	"GL_FOG_COORDINATE_ARRAY_BUFFER_BINDING_ARB  0x889D"

	<category: 'constants Ext'>
	^34973
    ]

    glWeightArrayBufferBindingArb [
	"GL_WEIGHT_ARRAY_BUFFER_BINDING_ARB  0x889E"

	<category: 'constants Ext'>
	^34974
    ]

    glVertexAttribArrayBufferBindingArb [
	"GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING_ARB  0x889F"

	<category: 'constants Ext'>
	^34975
    ]

    glReadOnlyArb [
	"GL_READ_ONLY_ARB  0x88B8"

	<category: 'constants Ext'>
	^35000
    ]

    glWriteOnlyArb [
	"GL_WRITE_ONLY_ARB  0x88B9"

	<category: 'constants Ext'>
	^35001
    ]

    glReadWriteArb [
	"GL_READ_WRITE_ARB  0x88BA"

	<category: 'constants Ext'>
	^35002
    ]

    glBufferAccessArb [
	"GL_BUFFER_ACCESS_ARB  0x88BB"

	<category: 'constants Ext'>
	^35003
    ]

    glBufferMappedArb [
	"GL_BUFFER_MAPPED_ARB  0x88BC"

	<category: 'constants Ext'>
	^35004
    ]

    glBufferMapPointerArb [
	"GL_BUFFER_MAP_POINTER_ARB  0x88BD"

	<category: 'constants Ext'>
	^35005
    ]

    glStreamDrawArb [
	"GL_STREAM_DRAW_ARB  0x88E0"

	<category: 'constants Ext'>
	^35040
    ]

    glStreamReadArb [
	"GL_STREAM_READ_ARB  0x88E1"

	<category: 'constants Ext'>
	^35041
    ]

    glStreamCopyArb [
	"GL_STREAM_COPY_ARB  0x88E2"

	<category: 'constants Ext'>
	^35042
    ]

    glStaticDrawArb [
	"GL_STATIC_DRAW_ARB  0x88E4"

	<category: 'constants Ext'>
	^35044
    ]

    glStaticReadArb [
	"GL_STATIC_READ_ARB  0x88E5"

	<category: 'constants Ext'>
	^35045
    ]

    glStaticCopyArb [
	"GL_STATIC_COPY_ARB  0x88E6"

	<category: 'constants Ext'>
	^35046
    ]

    glDynamicDrawArb [
	"GL_DYNAMIC_DRAW_ARB  0x88E8"

	<category: 'constants Ext'>
	^35048
    ]

    glDynamicReadArb [
	"GL_DYNAMIC_READ_ARB  0x88E9"

	<category: 'constants Ext'>
	^35049
    ]

    glDynamicCopyArb [
	"GL_DYNAMIC_COPY_ARB  0x88EA"

	<category: 'constants Ext'>
	^35050
    ]

    glQueryCounterBitsArb [
	"GL_QUERY_COUNTER_BITS_ARB  0x8864"

	<category: 'constants Ext'>
	^34916
    ]

    glCurrentQueryArb [
	"GL_CURRENT_QUERY_ARB  0x8865"

	<category: 'constants Ext'>
	^34917
    ]

    glQueryResultArb [
	"GL_QUERY_RESULT_ARB  0x8866"

	<category: 'constants Ext'>
	^34918
    ]

    glQueryResultAvailableArb [
	"GL_QUERY_RESULT_AVAILABLE_ARB  0x8867"

	<category: 'constants Ext'>
	^34919
    ]

    glSamplesPassedArb [
	"GL_SAMPLES_PASSED_ARB  0x8914"

	<category: 'constants Ext'>
	^35092
    ]

    glProgramObjectArb [
	"GL_PROGRAM_OBJECT_ARB  0x8B40"

	<category: 'constants Ext'>
	^35648
    ]

    glShaderObjectArb [
	"GL_SHADER_OBJECT_ARB  0x8B48"

	<category: 'constants Ext'>
	^35656
    ]

    glObjectTypeArb [
	"GL_OBJECT_TYPE_ARB  0x8B4E"

	<category: 'constants Ext'>
	^35662
    ]

    glObjectSubtypeArb [
	"GL_OBJECT_SUBTYPE_ARB  0x8B4F"

	<category: 'constants Ext'>
	^35663
    ]

    glFloatVec2Arb [
	"GL_FLOAT_VEC2_ARB  0x8B50"

	<category: 'constants Ext'>
	^35664
    ]

    glFloatVec3Arb [
	"GL_FLOAT_VEC3_ARB  0x8B51"

	<category: 'constants Ext'>
	^35665
    ]

    glFloatVec4Arb [
	"GL_FLOAT_VEC4_ARB  0x8B52"

	<category: 'constants Ext'>
	^35666
    ]

    glIntVec2Arb [
	"GL_INT_VEC2_ARB  0x8B53"

	<category: 'constants Ext'>
	^35667
    ]

    glIntVec3Arb [
	"GL_INT_VEC3_ARB  0x8B54"

	<category: 'constants Ext'>
	^35668
    ]

    glIntVec4Arb [
	"GL_INT_VEC4_ARB  0x8B55"

	<category: 'constants Ext'>
	^35669
    ]

    glBoolArb [
	"GL_BOOL_ARB  0x8B56"

	<category: 'constants Ext'>
	^35670
    ]

    glBoolVec2Arb [
	"GL_BOOL_VEC2_ARB  0x8B57"

	<category: 'constants Ext'>
	^35671
    ]

    glBoolVec3Arb [
	"GL_BOOL_VEC3_ARB  0x8B58"

	<category: 'constants Ext'>
	^35672
    ]

    glBoolVec4Arb [
	"GL_BOOL_VEC4_ARB  0x8B59"

	<category: 'constants Ext'>
	^35673
    ]

    glFloatMat2Arb [
	"GL_FLOAT_MAT2_ARB  0x8B5A"

	<category: 'constants Ext'>
	^35674
    ]

    glFloatMat3Arb [
	"GL_FLOAT_MAT3_ARB  0x8B5B"

	<category: 'constants Ext'>
	^35675
    ]

    glFloatMat4Arb [
	"GL_FLOAT_MAT4_ARB  0x8B5C"

	<category: 'constants Ext'>
	^35676
    ]

    glSampler1dArb [
	"GL_SAMPLER_1D_ARB  0x8B5D"

	<category: 'constants Ext'>
	^35677
    ]

    glSampler2dArb [
	"GL_SAMPLER_2D_ARB  0x8B5E"

	<category: 'constants Ext'>
	^35678
    ]

    glSampler3dArb [
	"GL_SAMPLER_3D_ARB  0x8B5F"

	<category: 'constants Ext'>
	^35679
    ]

    glSamplerCubeArb [
	"GL_SAMPLER_CUBE_ARB  0x8B60"

	<category: 'constants Ext'>
	^35680
    ]

    glSampler1dShadowArb [
	"GL_SAMPLER_1D_SHADOW_ARB  0x8B61"

	<category: 'constants Ext'>
	^35681
    ]

    glSampler2dShadowArb [
	"GL_SAMPLER_2D_SHADOW_ARB  0x8B62"

	<category: 'constants Ext'>
	^35682
    ]

    glSampler2dRectArb [
	"GL_SAMPLER_2D_RECT_ARB  0x8B63"

	<category: 'constants Ext'>
	^35683
    ]

    glSampler2dRectShadowArb [
	"GL_SAMPLER_2D_RECT_SHADOW_ARB  0x8B64"

	<category: 'constants Ext'>
	^35684
    ]

    glObjectDeleteStatusArb [
	"GL_OBJECT_DELETE_STATUS_ARB  0x8B80"

	<category: 'constants Ext'>
	^35712
    ]

    glObjectCompileStatusArb [
	"GL_OBJECT_COMPILE_STATUS_ARB  0x8B81"

	<category: 'constants Ext'>
	^35713
    ]

    glObjectLinkStatusArb [
	"GL_OBJECT_LINK_STATUS_ARB  0x8B82"

	<category: 'constants Ext'>
	^35714
    ]

    glObjectValidateStatusArb [
	"GL_OBJECT_VALIDATE_STATUS_ARB  0x8B83"

	<category: 'constants Ext'>
	^35715
    ]

    glObjectInfoLogLengthArb [
	"GL_OBJECT_INFO_LOG_LENGTH_ARB  0x8B84"

	<category: 'constants Ext'>
	^35716
    ]

    glObjectAttachedObjectsArb [
	"GL_OBJECT_ATTACHED_OBJECTS_ARB  0x8B85"

	<category: 'constants Ext'>
	^35717
    ]

    glObjectActiveUniformsArb [
	"GL_OBJECT_ACTIVE_UNIFORMS_ARB  0x8B86"

	<category: 'constants Ext'>
	^35718
    ]

    glObjectActiveUniformMaxLengthArb [
	"GL_OBJECT_ACTIVE_UNIFORM_MAX_LENGTH_ARB  0x8B87"

	<category: 'constants Ext'>
	^35719
    ]

    glObjectShaderSourceLengthArb [
	"GL_OBJECT_SHADER_SOURCE_LENGTH_ARB  0x8B88"

	<category: 'constants Ext'>
	^35720
    ]

    glVertexShaderArb [
	"GL_VERTEX_SHADER_ARB  0x8B31"

	<category: 'constants Ext'>
	^35633
    ]

    glMaxVertexUniformComponentsArb [
	"GL_MAX_VERTEX_UNIFORM_COMPONENTS_ARB  0x8B4A"

	<category: 'constants Ext'>
	^35658
    ]

    glMaxVaryingFloatsArb [
	"GL_MAX_VARYING_FLOATS_ARB  0x8B4B"

	<category: 'constants Ext'>
	^35659
    ]

    glMaxVertexTextureImageUnitsArb [
	"GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS_ARB  0x8B4C"

	<category: 'constants Ext'>
	^35660
    ]

    glMaxCombinedTextureImageUnitsArb [
	"GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS_ARB  0x8B4D"

	<category: 'constants Ext'>
	^35661
    ]

    glObjectActiveAttributesArb [
	"GL_OBJECT_ACTIVE_ATTRIBUTES_ARB  0x8B89"

	<category: 'constants Ext'>
	^35721
    ]

    glObjectActiveAttributeMaxLengthArb [
	"GL_OBJECT_ACTIVE_ATTRIBUTE_MAX_LENGTH_ARB  0x8B8A"

	<category: 'constants Ext'>
	^35722
    ]

    glFragmentShaderArb [
	"GL_FRAGMENT_SHADER_ARB  0x8B30"

	<category: 'constants Ext'>
	^35632
    ]

    glMaxFragmentUniformComponentsArb [
	"GL_MAX_FRAGMENT_UNIFORM_COMPONENTS_ARB  0x8B49"

	<category: 'constants Ext'>
	^35657
    ]

    glFragmentShaderDerivativeHintArb [
	"GL_FRAGMENT_SHADER_DERIVATIVE_HINT_ARB  0x8B8B"

	<category: 'constants Ext'>
	^35723
    ]

    glShadingLanguageVersionArb [
	"GL_SHADING_LANGUAGE_VERSION_ARB  0x8B8C"

	<category: 'constants Ext'>
	^35724
    ]

    glPointSpriteArb [
	"GL_POINT_SPRITE_ARB  0x8861"

	<category: 'constants Ext'>
	^34913
    ]

    glCoordReplaceArb [
	"GL_COORD_REPLACE_ARB  0x8862"

	<category: 'constants Ext'>
	^34914
    ]

    glMaxDrawBuffersArb [
	"GL_MAX_DRAW_BUFFERS_ARB  0x8824"

	<category: 'constants Ext'>
	^34852
    ]

    glDrawBuffer0Arb [
	"GL_DRAW_BUFFER0_ARB  0x8825"

	<category: 'constants Ext'>
	^34853
    ]

    glDrawBuffer1Arb [
	"GL_DRAW_BUFFER1_ARB  0x8826"

	<category: 'constants Ext'>
	^34854
    ]

    glDrawBuffer2Arb [
	"GL_DRAW_BUFFER2_ARB  0x8827"

	<category: 'constants Ext'>
	^34855
    ]

    glDrawBuffer3Arb [
	"GL_DRAW_BUFFER3_ARB  0x8828"

	<category: 'constants Ext'>
	^34856
    ]

    glDrawBuffer4Arb [
	"GL_DRAW_BUFFER4_ARB  0x8829"

	<category: 'constants Ext'>
	^34857
    ]

    glDrawBuffer5Arb [
	"GL_DRAW_BUFFER5_ARB  0x882A"

	<category: 'constants Ext'>
	^34858
    ]

    glDrawBuffer6Arb [
	"GL_DRAW_BUFFER6_ARB  0x882B"

	<category: 'constants Ext'>
	^34859
    ]

    glDrawBuffer7Arb [
	"GL_DRAW_BUFFER7_ARB  0x882C"

	<category: 'constants Ext'>
	^34860
    ]

    glDrawBuffer8Arb [
	"GL_DRAW_BUFFER8_ARB  0x882D"

	<category: 'constants Ext'>
	^34861
    ]

    glDrawBuffer9Arb [
	"GL_DRAW_BUFFER9_ARB  0x882E"

	<category: 'constants Ext'>
	^34862
    ]

    glDrawBuffer10Arb [
	"GL_DRAW_BUFFER10_ARB  0x882F"

	<category: 'constants Ext'>
	^34863
    ]

    glDrawBuffer11Arb [
	"GL_DRAW_BUFFER11_ARB  0x8830"

	<category: 'constants Ext'>
	^34864
    ]

    glDrawBuffer12Arb [
	"GL_DRAW_BUFFER12_ARB  0x8831"

	<category: 'constants Ext'>
	^34865
    ]

    glDrawBuffer13Arb [
	"GL_DRAW_BUFFER13_ARB  0x8832"

	<category: 'constants Ext'>
	^34866
    ]

    glDrawBuffer14Arb [
	"GL_DRAW_BUFFER14_ARB  0x8833"

	<category: 'constants Ext'>
	^34867
    ]

    glDrawBuffer15Arb [
	"GL_DRAW_BUFFER15_ARB  0x8834"

	<category: 'constants Ext'>
	^34868
    ]

    glTextureRectangleArb [
	"GL_TEXTURE_RECTANGLE_ARB  0x84F5"

	<category: 'constants Ext'>
	^34037
    ]

    glTextureBindingRectangleArb [
	"GL_TEXTURE_BINDING_RECTANGLE_ARB  0x84F6"

	<category: 'constants Ext'>
	^34038
    ]

    glProxyTextureRectangleArb [
	"GL_PROXY_TEXTURE_RECTANGLE_ARB  0x84F7"

	<category: 'constants Ext'>
	^34039
    ]

    glMaxRectangleTextureSizeArb [
	"GL_MAX_RECTANGLE_TEXTURE_SIZE_ARB  0x84F8"

	<category: 'constants Ext'>
	^34040
    ]

    glRgbaFloatModeArb [
	"GL_RGBA_FLOAT_MODE_ARB  0x8820"

	<category: 'constants Ext'>
	^34848
    ]

    glClampVertexColorArb [
	"GL_CLAMP_VERTEX_COLOR_ARB  0x891A"

	<category: 'constants Ext'>
	^35098
    ]

    glClampFragmentColorArb [
	"GL_CLAMP_FRAGMENT_COLOR_ARB  0x891B"

	<category: 'constants Ext'>
	^35099
    ]

    glClampReadColorArb [
	"GL_CLAMP_READ_COLOR_ARB  0x891C"

	<category: 'constants Ext'>
	^35100
    ]

    glFixedOnlyArb [
	"GL_FIXED_ONLY_ARB  0x891D"

	<category: 'constants Ext'>
	^35101
    ]

    glHalfFloatArb [
	"GL_HALF_FLOAT_ARB  0x140B"

	<category: 'constants Ext'>
	^5131
    ]

    glTextureRedTypeArb [
	"GL_TEXTURE_RED_TYPE_ARB  0x8C10"

	<category: 'constants Ext'>
	^35856
    ]

    glTextureGreenTypeArb [
	"GL_TEXTURE_GREEN_TYPE_ARB  0x8C11"

	<category: 'constants Ext'>
	^35857
    ]

    glTextureBlueTypeArb [
	"GL_TEXTURE_BLUE_TYPE_ARB  0x8C12"

	<category: 'constants Ext'>
	^35858
    ]

    glTextureAlphaTypeArb [
	"GL_TEXTURE_ALPHA_TYPE_ARB  0x8C13"

	<category: 'constants Ext'>
	^35859
    ]

    glTextureLuminanceTypeArb [
	"GL_TEXTURE_LUMINANCE_TYPE_ARB  0x8C14"

	<category: 'constants Ext'>
	^35860
    ]

    glTextureIntensityTypeArb [
	"GL_TEXTURE_INTENSITY_TYPE_ARB  0x8C15"

	<category: 'constants Ext'>
	^35861
    ]

    glTextureDepthTypeArb [
	"GL_TEXTURE_DEPTH_TYPE_ARB  0x8C16"

	<category: 'constants Ext'>
	^35862
    ]

    glUnsignedNormalizedArb [
	"GL_UNSIGNED_NORMALIZED_ARB  0x8C17"

	<category: 'constants Ext'>
	^35863
    ]

    glRgba32fArb [
	"GL_RGBA32F_ARB  0x8814"

	<category: 'constants Ext'>
	^34836
    ]

    glRgb32fArb [
	"GL_RGB32F_ARB  0x8815"

	<category: 'constants Ext'>
	^34837
    ]

    glAlpha32fArb [
	"GL_ALPHA32F_ARB  0x8816"

	<category: 'constants Ext'>
	^34838
    ]

    glIntensity32fArb [
	"GL_INTENSITY32F_ARB  0x8817"

	<category: 'constants Ext'>
	^34839
    ]

    glLuminance32fArb [
	"GL_LUMINANCE32F_ARB  0x8818"

	<category: 'constants Ext'>
	^34840
    ]

    glLuminanceAlpha32fArb [
	"GL_LUMINANCE_ALPHA32F_ARB  0x8819"

	<category: 'constants Ext'>
	^34841
    ]

    glRgba16fArb [
	"GL_RGBA16F_ARB  0x881A"

	<category: 'constants Ext'>
	^34842
    ]

    glRgb16fArb [
	"GL_RGB16F_ARB  0x881B"

	<category: 'constants Ext'>
	^34843
    ]

    glAlpha16fArb [
	"GL_ALPHA16F_ARB  0x881C"

	<category: 'constants Ext'>
	^34844
    ]

    glIntensity16fArb [
	"GL_INTENSITY16F_ARB  0x881D"

	<category: 'constants Ext'>
	^34845
    ]

    glLuminance16fArb [
	"GL_LUMINANCE16F_ARB  0x881E"

	<category: 'constants Ext'>
	^34846
    ]

    glLuminanceAlpha16fArb [
	"GL_LUMINANCE_ALPHA16F_ARB  0x881F"

	<category: 'constants Ext'>
	^34847
    ]

    glPixelPackBufferArb [
	"GL_PIXEL_PACK_BUFFER_ARB  0x88EB"

	<category: 'constants Ext'>
	^35051
    ]

    glPixelUnpackBufferArb [
	"GL_PIXEL_UNPACK_BUFFER_ARB  0x88EC"

	<category: 'constants Ext'>
	^35052
    ]

    glPixelPackBufferBindingArb [
	"GL_PIXEL_PACK_BUFFER_BINDING_ARB  0x88ED"

	<category: 'constants Ext'>
	^35053
    ]

    glPixelUnpackBufferBindingArb [
	"GL_PIXEL_UNPACK_BUFFER_BINDING_ARB  0x88EF"

	<category: 'constants Ext'>
	^35055
    ]

    glAbgrExt [
	"GL_ABGR_EXT  0x8000"

	<category: 'constants Ext'>
	^32768
    ]

    glConstantColorExt [
	"GL_CONSTANT_COLOR_EXT  0x8001"

	<category: 'constants Ext'>
	^32769
    ]

    glOneMinusConstantColorExt [
	"GL_ONE_MINUS_CONSTANT_COLOR_EXT  0x8002"

	<category: 'constants Ext'>
	^32770
    ]

    glConstantAlphaExt [
	"GL_CONSTANT_ALPHA_EXT  0x8003"

	<category: 'constants Ext'>
	^32771
    ]

    glOneMinusConstantAlphaExt [
	"GL_ONE_MINUS_CONSTANT_ALPHA_EXT  0x8004"

	<category: 'constants Ext'>
	^32772
    ]

    glBlendColorExt [
	"GL_BLEND_COLOR_EXT  0x8005"

	<category: 'constants Ext'>
	^32773
    ]

    glPolygonOffsetExt [
	"GL_POLYGON_OFFSET_EXT  0x8037"

	<category: 'constants Ext'>
	^32823
    ]

    glPolygonOffsetFactorExt [
	"GL_POLYGON_OFFSET_FACTOR_EXT  0x8038"

	<category: 'constants Ext'>
	^32824
    ]

    glPolygonOffsetBiasExt [
	"GL_POLYGON_OFFSET_BIAS_EXT  0x8039"

	<category: 'constants Ext'>
	^32825
    ]

    glAlpha4Ext [
	"GL_ALPHA4_EXT  0x803B"

	<category: 'constants Ext'>
	^32827
    ]

    glAlpha8Ext [
	"GL_ALPHA8_EXT  0x803C"

	<category: 'constants Ext'>
	^32828
    ]

    glAlpha12Ext [
	"GL_ALPHA12_EXT  0x803D"

	<category: 'constants Ext'>
	^32829
    ]

    glAlpha16Ext [
	"GL_ALPHA16_EXT  0x803E"

	<category: 'constants Ext'>
	^32830
    ]

    glLuminance4Ext [
	"GL_LUMINANCE4_EXT  0x803F"

	<category: 'constants Ext'>
	^32831
    ]

    glLuminance8Ext [
	"GL_LUMINANCE8_EXT  0x8040"

	<category: 'constants Ext'>
	^32832
    ]

    glLuminance12Ext [
	"GL_LUMINANCE12_EXT  0x8041"

	<category: 'constants Ext'>
	^32833
    ]

    glLuminance16Ext [
	"GL_LUMINANCE16_EXT  0x8042"

	<category: 'constants Ext'>
	^32834
    ]

    glLuminance4Alpha4Ext [
	"GL_LUMINANCE4_ALPHA4_EXT  0x8043"

	<category: 'constants Ext'>
	^32835
    ]

    glLuminance6Alpha2Ext [
	"GL_LUMINANCE6_ALPHA2_EXT  0x8044"

	<category: 'constants Ext'>
	^32836
    ]

    glLuminance8Alpha8Ext [
	"GL_LUMINANCE8_ALPHA8_EXT  0x8045"

	<category: 'constants Ext'>
	^32837
    ]

    glLuminance12Alpha4Ext [
	"GL_LUMINANCE12_ALPHA4_EXT  0x8046"

	<category: 'constants Ext'>
	^32838
    ]

    glLuminance12Alpha12Ext [
	"GL_LUMINANCE12_ALPHA12_EXT  0x8047"

	<category: 'constants Ext'>
	^32839
    ]

    glLuminance16Alpha16Ext [
	"GL_LUMINANCE16_ALPHA16_EXT  0x8048"

	<category: 'constants Ext'>
	^32840
    ]

    glIntensityExt [
	"GL_INTENSITY_EXT  0x8049"

	<category: 'constants Ext'>
	^32841
    ]

    glIntensity4Ext [
	"GL_INTENSITY4_EXT  0x804A"

	<category: 'constants Ext'>
	^32842
    ]

    glIntensity8Ext [
	"GL_INTENSITY8_EXT  0x804B"

	<category: 'constants Ext'>
	^32843
    ]

    glIntensity12Ext [
	"GL_INTENSITY12_EXT  0x804C"

	<category: 'constants Ext'>
	^32844
    ]

    glIntensity16Ext [
	"GL_INTENSITY16_EXT  0x804D"

	<category: 'constants Ext'>
	^32845
    ]

    glRgb2Ext [
	"GL_RGB2_EXT  0x804E"

	<category: 'constants Ext'>
	^32846
    ]

    glRgb4Ext [
	"GL_RGB4_EXT  0x804F"

	<category: 'constants Ext'>
	^32847
    ]

    glRgb5Ext [
	"GL_RGB5_EXT  0x8050"

	<category: 'constants Ext'>
	^32848
    ]

    glRgb8Ext [
	"GL_RGB8_EXT  0x8051"

	<category: 'constants Ext'>
	^32849
    ]

    glRgb10Ext [
	"GL_RGB10_EXT  0x8052"

	<category: 'constants Ext'>
	^32850
    ]

    glRgb12Ext [
	"GL_RGB12_EXT  0x8053"

	<category: 'constants Ext'>
	^32851
    ]

    glRgb16Ext [
	"GL_RGB16_EXT  0x8054"

	<category: 'constants Ext'>
	^32852
    ]

    glRgba2Ext [
	"GL_RGBA2_EXT  0x8055"

	<category: 'constants Ext'>
	^32853
    ]

    glRgba4Ext [
	"GL_RGBA4_EXT  0x8056"

	<category: 'constants Ext'>
	^32854
    ]

    glRgb5A1Ext [
	"GL_RGB5_A1_EXT  0x8057"

	<category: 'constants Ext'>
	^32855
    ]

    glRgba8Ext [
	"GL_RGBA8_EXT  0x8058"

	<category: 'constants Ext'>
	^32856
    ]

    glRgb10A2Ext [
	"GL_RGB10_A2_EXT  0x8059"

	<category: 'constants Ext'>
	^32857
    ]

    glRgba12Ext [
	"GL_RGBA12_EXT  0x805A"

	<category: 'constants Ext'>
	^32858
    ]

    glRgba16Ext [
	"GL_RGBA16_EXT  0x805B"

	<category: 'constants Ext'>
	^32859
    ]

    glTextureRedSizeExt [
	"GL_TEXTURE_RED_SIZE_EXT  0x805C"

	<category: 'constants Ext'>
	^32860
    ]

    glTextureGreenSizeExt [
	"GL_TEXTURE_GREEN_SIZE_EXT  0x805D"

	<category: 'constants Ext'>
	^32861
    ]

    glTextureBlueSizeExt [
	"GL_TEXTURE_BLUE_SIZE_EXT  0x805E"

	<category: 'constants Ext'>
	^32862
    ]

    glTextureAlphaSizeExt [
	"GL_TEXTURE_ALPHA_SIZE_EXT  0x805F"

	<category: 'constants Ext'>
	^32863
    ]

    glTextureLuminanceSizeExt [
	"GL_TEXTURE_LUMINANCE_SIZE_EXT  0x8060"

	<category: 'constants Ext'>
	^32864
    ]

    glTextureIntensitySizeExt [
	"GL_TEXTURE_INTENSITY_SIZE_EXT  0x8061"

	<category: 'constants Ext'>
	^32865
    ]

    glReplaceExt [
	"GL_REPLACE_EXT  0x8062"

	<category: 'constants Ext'>
	^32866
    ]

    glProxyTexture1dExt [
	"GL_PROXY_TEXTURE_1D_EXT  0x8063"

	<category: 'constants Ext'>
	^32867
    ]

    glProxyTexture2dExt [
	"GL_PROXY_TEXTURE_2D_EXT  0x8064"

	<category: 'constants Ext'>
	^32868
    ]

    glTextureTooLargeExt [
	"GL_TEXTURE_TOO_LARGE_EXT  0x8065"

	<category: 'constants Ext'>
	^32869
    ]

    glPackSkipImagesExt [
	"GL_PACK_SKIP_IMAGES_EXT  0x806B"

	<category: 'constants Ext'>
	^32875
    ]

    glPackImageHeightExt [
	"GL_PACK_IMAGE_HEIGHT_EXT  0x806C"

	<category: 'constants Ext'>
	^32876
    ]

    glUnpackSkipImagesExt [
	"GL_UNPACK_SKIP_IMAGES_EXT  0x806D"

	<category: 'constants Ext'>
	^32877
    ]

    glUnpackImageHeightExt [
	"GL_UNPACK_IMAGE_HEIGHT_EXT  0x806E"

	<category: 'constants Ext'>
	^32878
    ]

    glTexture3dExt [
	"GL_TEXTURE_3D_EXT  0x806F"

	<category: 'constants Ext'>
	^32879
    ]

    glProxyTexture3dExt [
	"GL_PROXY_TEXTURE_3D_EXT  0x8070"

	<category: 'constants Ext'>
	^32880
    ]

    glTextureDepthExt [
	"GL_TEXTURE_DEPTH_EXT  0x8071"

	<category: 'constants Ext'>
	^32881
    ]

    glTextureWrapRExt [
	"GL_TEXTURE_WRAP_R_EXT  0x8072"

	<category: 'constants Ext'>
	^32882
    ]

    glMax3dTextureSizeExt [
	"GL_MAX_3D_TEXTURE_SIZE_EXT  0x8073"

	<category: 'constants Ext'>
	^32883
    ]

    glFilter4Sgis [
	"GL_FILTER4_SGIS  0x8146"

	<category: 'constants Ext'>
	^33094
    ]

    glTextureFilter4SizeSgis [
	"GL_TEXTURE_FILTER4_SIZE_SGIS  0x8147"

	<category: 'constants Ext'>
	^33095
    ]

    glHistogramExt [
	"GL_HISTOGRAM_EXT  0x8024"

	<category: 'constants Ext'>
	^32804
    ]

    glProxyHistogramExt [
	"GL_PROXY_HISTOGRAM_EXT  0x8025"

	<category: 'constants Ext'>
	^32805
    ]

    glHistogramWidthExt [
	"GL_HISTOGRAM_WIDTH_EXT  0x8026"

	<category: 'constants Ext'>
	^32806
    ]

    glHistogramFormatExt [
	"GL_HISTOGRAM_FORMAT_EXT  0x8027"

	<category: 'constants Ext'>
	^32807
    ]

    glHistogramRedSizeExt [
	"GL_HISTOGRAM_RED_SIZE_EXT  0x8028"

	<category: 'constants Ext'>
	^32808
    ]

    glHistogramGreenSizeExt [
	"GL_HISTOGRAM_GREEN_SIZE_EXT  0x8029"

	<category: 'constants Ext'>
	^32809
    ]

    glHistogramBlueSizeExt [
	"GL_HISTOGRAM_BLUE_SIZE_EXT  0x802A"

	<category: 'constants Ext'>
	^32810
    ]

    glHistogramAlphaSizeExt [
	"GL_HISTOGRAM_ALPHA_SIZE_EXT  0x802B"

	<category: 'constants Ext'>
	^32811
    ]

    glHistogramLuminanceSizeExt [
	"GL_HISTOGRAM_LUMINANCE_SIZE_EXT  0x802C"

	<category: 'constants Ext'>
	^32812
    ]

    glHistogramSinkExt [
	"GL_HISTOGRAM_SINK_EXT  0x802D"

	<category: 'constants Ext'>
	^32813
    ]

    glMinmaxExt [
	"GL_MINMAX_EXT  0x802E"

	<category: 'constants Ext'>
	^32814
    ]

    glMinmaxFormatExt [
	"GL_MINMAX_FORMAT_EXT  0x802F"

	<category: 'constants Ext'>
	^32815
    ]

    glMinmaxSinkExt [
	"GL_MINMAX_SINK_EXT  0x8030"

	<category: 'constants Ext'>
	^32816
    ]

    glTableTooLargeExt [
	"GL_TABLE_TOO_LARGE_EXT  0x8031"

	<category: 'constants Ext'>
	^32817
    ]

    glConvolution1dExt [
	"GL_CONVOLUTION_1D_EXT  0x8010"

	<category: 'constants Ext'>
	^32784
    ]

    glConvolution2dExt [
	"GL_CONVOLUTION_2D_EXT  0x8011"

	<category: 'constants Ext'>
	^32785
    ]

    glSeparable2dExt [
	"GL_SEPARABLE_2D_EXT  0x8012"

	<category: 'constants Ext'>
	^32786
    ]

    glConvolutionBorderModeExt [
	"GL_CONVOLUTION_BORDER_MODE_EXT  0x8013"

	<category: 'constants Ext'>
	^32787
    ]

    glConvolutionFilterScaleExt [
	"GL_CONVOLUTION_FILTER_SCALE_EXT  0x8014"

	<category: 'constants Ext'>
	^32788
    ]

    glConvolutionFilterBiasExt [
	"GL_CONVOLUTION_FILTER_BIAS_EXT  0x8015"

	<category: 'constants Ext'>
	^32789
    ]

    glReduceExt [
	"GL_REDUCE_EXT  0x8016"

	<category: 'constants Ext'>
	^32790
    ]

    glConvolutionFormatExt [
	"GL_CONVOLUTION_FORMAT_EXT  0x8017"

	<category: 'constants Ext'>
	^32791
    ]

    glConvolutionWidthExt [
	"GL_CONVOLUTION_WIDTH_EXT  0x8018"

	<category: 'constants Ext'>
	^32792
    ]

    glConvolutionHeightExt [
	"GL_CONVOLUTION_HEIGHT_EXT  0x8019"

	<category: 'constants Ext'>
	^32793
    ]

    glMaxConvolutionWidthExt [
	"GL_MAX_CONVOLUTION_WIDTH_EXT  0x801A"

	<category: 'constants Ext'>
	^32794
    ]

    glMaxConvolutionHeightExt [
	"GL_MAX_CONVOLUTION_HEIGHT_EXT  0x801B"

	<category: 'constants Ext'>
	^32795
    ]

    glPostConvolutionRedScaleExt [
	"GL_POST_CONVOLUTION_RED_SCALE_EXT  0x801C"

	<category: 'constants Ext'>
	^32796
    ]

    glPostConvolutionGreenScaleExt [
	"GL_POST_CONVOLUTION_GREEN_SCALE_EXT  0x801D"

	<category: 'constants Ext'>
	^32797
    ]

    glPostConvolutionBlueScaleExt [
	"GL_POST_CONVOLUTION_BLUE_SCALE_EXT  0x801E"

	<category: 'constants Ext'>
	^32798
    ]

    glPostConvolutionAlphaScaleExt [
	"GL_POST_CONVOLUTION_ALPHA_SCALE_EXT  0x801F"

	<category: 'constants Ext'>
	^32799
    ]

    glPostConvolutionRedBiasExt [
	"GL_POST_CONVOLUTION_RED_BIAS_EXT  0x8020"

	<category: 'constants Ext'>
	^32800
    ]

    glPostConvolutionGreenBiasExt [
	"GL_POST_CONVOLUTION_GREEN_BIAS_EXT  0x8021"

	<category: 'constants Ext'>
	^32801
    ]

    glPostConvolutionBlueBiasExt [
	"GL_POST_CONVOLUTION_BLUE_BIAS_EXT  0x8022"

	<category: 'constants Ext'>
	^32802
    ]

    glPostConvolutionAlphaBiasExt [
	"GL_POST_CONVOLUTION_ALPHA_BIAS_EXT  0x8023"

	<category: 'constants Ext'>
	^32803
    ]

    glColorMatrixSgi [
	"GL_COLOR_MATRIX_SGI  0x80B1"

	<category: 'constants Ext'>
	^32945
    ]

    glColorMatrixStackDepthSgi [
	"GL_COLOR_MATRIX_STACK_DEPTH_SGI  0x80B2"

	<category: 'constants Ext'>
	^32946
    ]

    glMaxColorMatrixStackDepthSgi [
	"GL_MAX_COLOR_MATRIX_STACK_DEPTH_SGI  0x80B3"

	<category: 'constants Ext'>
	^32947
    ]

    glPostColorMatrixRedScaleSgi [
	"GL_POST_COLOR_MATRIX_RED_SCALE_SGI  0x80B4"

	<category: 'constants Ext'>
	^32948
    ]

    glPostColorMatrixGreenScaleSgi [
	"GL_POST_COLOR_MATRIX_GREEN_SCALE_SGI  0x80B5"

	<category: 'constants Ext'>
	^32949
    ]

    glPostColorMatrixBlueScaleSgi [
	"GL_POST_COLOR_MATRIX_BLUE_SCALE_SGI  0x80B6"

	<category: 'constants Ext'>
	^32950
    ]

    glPostColorMatrixAlphaScaleSgi [
	"GL_POST_COLOR_MATRIX_ALPHA_SCALE_SGI  0x80B7"

	<category: 'constants Ext'>
	^32951
    ]

    glPostColorMatrixRedBiasSgi [
	"GL_POST_COLOR_MATRIX_RED_BIAS_SGI  0x80B8"

	<category: 'constants Ext'>
	^32952
    ]

    glPostColorMatrixGreenBiasSgi [
	"GL_POST_COLOR_MATRIX_GREEN_BIAS_SGI  0x80B9"

	<category: 'constants Ext'>
	^32953
    ]

    glPostColorMatrixBlueBiasSgi [
	"GL_POST_COLOR_MATRIX_BLUE_BIAS_SGI  0x80BA"

	<category: 'constants Ext'>
	^32954
    ]

    glPostColorMatrixAlphaBiasSgi [
	"GL_POST_COLOR_MATRIX_ALPHA_BIAS_SGI  0x80BB"

	<category: 'constants Ext'>
	^32955
    ]

    glColorTableSgi [
	"GL_COLOR_TABLE_SGI  0x80D0"

	<category: 'constants Ext'>
	^32976
    ]

    glPostConvolutionColorTableSgi [
	"GL_POST_CONVOLUTION_COLOR_TABLE_SGI  0x80D1"

	<category: 'constants Ext'>
	^32977
    ]

    glPostColorMatrixColorTableSgi [
	"GL_POST_COLOR_MATRIX_COLOR_TABLE_SGI  0x80D2"

	<category: 'constants Ext'>
	^32978
    ]

    glProxyColorTableSgi [
	"GL_PROXY_COLOR_TABLE_SGI  0x80D3"

	<category: 'constants Ext'>
	^32979
    ]

    glProxyPostConvolutionColorTableSgi [
	"GL_PROXY_POST_CONVOLUTION_COLOR_TABLE_SGI  0x80D4"

	<category: 'constants Ext'>
	^32980
    ]

    glProxyPostColorMatrixColorTableSgi [
	"GL_PROXY_POST_COLOR_MATRIX_COLOR_TABLE_SGI  0x80D5"

	<category: 'constants Ext'>
	^32981
    ]

    glColorTableScaleSgi [
	"GL_COLOR_TABLE_SCALE_SGI  0x80D6"

	<category: 'constants Ext'>
	^32982
    ]

    glColorTableBiasSgi [
	"GL_COLOR_TABLE_BIAS_SGI  0x80D7"

	<category: 'constants Ext'>
	^32983
    ]

    glColorTableFormatSgi [
	"GL_COLOR_TABLE_FORMAT_SGI  0x80D8"

	<category: 'constants Ext'>
	^32984
    ]

    glColorTableWidthSgi [
	"GL_COLOR_TABLE_WIDTH_SGI  0x80D9"

	<category: 'constants Ext'>
	^32985
    ]

    glColorTableRedSizeSgi [
	"GL_COLOR_TABLE_RED_SIZE_SGI  0x80DA"

	<category: 'constants Ext'>
	^32986
    ]

    glColorTableGreenSizeSgi [
	"GL_COLOR_TABLE_GREEN_SIZE_SGI  0x80DB"

	<category: 'constants Ext'>
	^32987
    ]

    glColorTableBlueSizeSgi [
	"GL_COLOR_TABLE_BLUE_SIZE_SGI  0x80DC"

	<category: 'constants Ext'>
	^32988
    ]

    glColorTableAlphaSizeSgi [
	"GL_COLOR_TABLE_ALPHA_SIZE_SGI  0x80DD"

	<category: 'constants Ext'>
	^32989
    ]

    glColorTableLuminanceSizeSgi [
	"GL_COLOR_TABLE_LUMINANCE_SIZE_SGI  0x80DE"

	<category: 'constants Ext'>
	^32990
    ]

    glColorTableIntensitySizeSgi [
	"GL_COLOR_TABLE_INTENSITY_SIZE_SGI  0x80DF"

	<category: 'constants Ext'>
	^32991
    ]

    glPixelTextureSgis [
	"GL_PIXEL_TEXTURE_SGIS  0x8353"

	<category: 'constants Ext'>
	^33619
    ]

    glPixelFragmentRgbSourceSgis [
	"GL_PIXEL_FRAGMENT_RGB_SOURCE_SGIS  0x8354"

	<category: 'constants Ext'>
	^33620
    ]

    glPixelFragmentAlphaSourceSgis [
	"GL_PIXEL_FRAGMENT_ALPHA_SOURCE_SGIS  0x8355"

	<category: 'constants Ext'>
	^33621
    ]

    glPixelGroupColorSgis [
	"GL_PIXEL_GROUP_COLOR_SGIS  0x8356"

	<category: 'constants Ext'>
	^33622
    ]

    glPixelTexGenSgix [
	"GL_PIXEL_TEX_GEN_SGIX  0x8139"

	<category: 'constants Ext'>
	^33081
    ]

    glPixelTexGenModeSgix [
	"GL_PIXEL_TEX_GEN_MODE_SGIX  0x832B"

	<category: 'constants Ext'>
	^33579
    ]

    glPackSkipVolumesSgis [
	"GL_PACK_SKIP_VOLUMES_SGIS  0x8130"

	<category: 'constants Ext'>
	^33072
    ]

    glPackImageDepthSgis [
	"GL_PACK_IMAGE_DEPTH_SGIS  0x8131"

	<category: 'constants Ext'>
	^33073
    ]

    glUnpackSkipVolumesSgis [
	"GL_UNPACK_SKIP_VOLUMES_SGIS  0x8132"

	<category: 'constants Ext'>
	^33074
    ]

    glUnpackImageDepthSgis [
	"GL_UNPACK_IMAGE_DEPTH_SGIS  0x8133"

	<category: 'constants Ext'>
	^33075
    ]

    glTexture4dSgis [
	"GL_TEXTURE_4D_SGIS  0x8134"

	<category: 'constants Ext'>
	^33076
    ]

    glProxyTexture4dSgis [
	"GL_PROXY_TEXTURE_4D_SGIS  0x8135"

	<category: 'constants Ext'>
	^33077
    ]

    glTexture4dsizeSgis [
	"GL_TEXTURE_4DSIZE_SGIS  0x8136"

	<category: 'constants Ext'>
	^33078
    ]

    glTextureWrapQSgis [
	"GL_TEXTURE_WRAP_Q_SGIS  0x8137"

	<category: 'constants Ext'>
	^33079
    ]

    glMax4dTextureSizeSgis [
	"GL_MAX_4D_TEXTURE_SIZE_SGIS  0x8138"

	<category: 'constants Ext'>
	^33080
    ]

    glTexture4dBindingSgis [
	"GL_TEXTURE_4D_BINDING_SGIS  0x814F"

	<category: 'constants Ext'>
	^33103
    ]

    glTextureColorTableSgi [
	"GL_TEXTURE_COLOR_TABLE_SGI  0x80BC"

	<category: 'constants Ext'>
	^32956
    ]

    glProxyTextureColorTableSgi [
	"GL_PROXY_TEXTURE_COLOR_TABLE_SGI  0x80BD"

	<category: 'constants Ext'>
	^32957
    ]

    glCmykExt [
	"GL_CMYK_EXT  0x800C"

	<category: 'constants Ext'>
	^32780
    ]

    glCmykaExt [
	"GL_CMYKA_EXT  0x800D"

	<category: 'constants Ext'>
	^32781
    ]

    glPackCmykHintExt [
	"GL_PACK_CMYK_HINT_EXT  0x800E"

	<category: 'constants Ext'>
	^32782
    ]

    glUnpackCmykHintExt [
	"GL_UNPACK_CMYK_HINT_EXT  0x800F"

	<category: 'constants Ext'>
	^32783
    ]

    glTexturePriorityExt [
	"GL_TEXTURE_PRIORITY_EXT  0x8066"

	<category: 'constants Ext'>
	^32870
    ]

    glTextureResidentExt [
	"GL_TEXTURE_RESIDENT_EXT  0x8067"

	<category: 'constants Ext'>
	^32871
    ]

    glTexture1dBindingExt [
	"GL_TEXTURE_1D_BINDING_EXT  0x8068"

	<category: 'constants Ext'>
	^32872
    ]

    glTexture2dBindingExt [
	"GL_TEXTURE_2D_BINDING_EXT  0x8069"

	<category: 'constants Ext'>
	^32873
    ]

    glTexture3dBindingExt [
	"GL_TEXTURE_3D_BINDING_EXT  0x806A"

	<category: 'constants Ext'>
	^32874
    ]

    glDetailTexture2dSgis [
	"GL_DETAIL_TEXTURE_2D_SGIS  0x8095"

	<category: 'constants Ext'>
	^32917
    ]

    glDetailTexture2dBindingSgis [
	"GL_DETAIL_TEXTURE_2D_BINDING_SGIS  0x8096"

	<category: 'constants Ext'>
	^32918
    ]

    glLinearDetailSgis [
	"GL_LINEAR_DETAIL_SGIS  0x8097"

	<category: 'constants Ext'>
	^32919
    ]

    glLinearDetailAlphaSgis [
	"GL_LINEAR_DETAIL_ALPHA_SGIS  0x8098"

	<category: 'constants Ext'>
	^32920
    ]

    glLinearDetailColorSgis [
	"GL_LINEAR_DETAIL_COLOR_SGIS  0x8099"

	<category: 'constants Ext'>
	^32921
    ]

    glDetailTextureLevelSgis [
	"GL_DETAIL_TEXTURE_LEVEL_SGIS  0x809A"

	<category: 'constants Ext'>
	^32922
    ]

    glDetailTextureModeSgis [
	"GL_DETAIL_TEXTURE_MODE_SGIS  0x809B"

	<category: 'constants Ext'>
	^32923
    ]

    glDetailTextureFuncPointsSgis [
	"GL_DETAIL_TEXTURE_FUNC_POINTS_SGIS  0x809C"

	<category: 'constants Ext'>
	^32924
    ]

    glLinearSharpenSgis [
	"GL_LINEAR_SHARPEN_SGIS  0x80AD"

	<category: 'constants Ext'>
	^32941
    ]

    glLinearSharpenAlphaSgis [
	"GL_LINEAR_SHARPEN_ALPHA_SGIS  0x80AE"

	<category: 'constants Ext'>
	^32942
    ]

    glLinearSharpenColorSgis [
	"GL_LINEAR_SHARPEN_COLOR_SGIS  0x80AF"

	<category: 'constants Ext'>
	^32943
    ]

    glSharpenTextureFuncPointsSgis [
	"GL_SHARPEN_TEXTURE_FUNC_POINTS_SGIS  0x80B0"

	<category: 'constants Ext'>
	^32944
    ]

    glUnsignedByte332Ext [
	"GL_UNSIGNED_BYTE_3_3_2_EXT  0x8032"

	<category: 'constants Ext'>
	^32818
    ]

    glUnsignedShort4444Ext [
	"GL_UNSIGNED_SHORT_4_4_4_4_EXT  0x8033"

	<category: 'constants Ext'>
	^32819
    ]

    glUnsignedShort5551Ext [
	"GL_UNSIGNED_SHORT_5_5_5_1_EXT  0x8034"

	<category: 'constants Ext'>
	^32820
    ]

    glUnsignedInt8888Ext [
	"GL_UNSIGNED_INT_8_8_8_8_EXT  0x8035"

	<category: 'constants Ext'>
	^32821
    ]

    glUnsignedInt1010102Ext [
	"GL_UNSIGNED_INT_10_10_10_2_EXT  0x8036"

	<category: 'constants Ext'>
	^32822
    ]

    glTextureMinLodSgis [
	"GL_TEXTURE_MIN_LOD_SGIS  0x813A"

	<category: 'constants Ext'>
	^33082
    ]

    glTextureMaxLodSgis [
	"GL_TEXTURE_MAX_LOD_SGIS  0x813B"

	<category: 'constants Ext'>
	^33083
    ]

    glTextureBaseLevelSgis [
	"GL_TEXTURE_BASE_LEVEL_SGIS  0x813C"

	<category: 'constants Ext'>
	^33084
    ]

    glTextureMaxLevelSgis [
	"GL_TEXTURE_MAX_LEVEL_SGIS  0x813D"

	<category: 'constants Ext'>
	^33085
    ]

    glMultisampleSgis [
	"GL_MULTISAMPLE_SGIS  0x809D"

	<category: 'constants Ext'>
	^32925
    ]

    glSampleAlphaToMaskSgis [
	"GL_SAMPLE_ALPHA_TO_MASK_SGIS  0x809E"

	<category: 'constants Ext'>
	^32926
    ]

    glSampleAlphaToOneSgis [
	"GL_SAMPLE_ALPHA_TO_ONE_SGIS  0x809F"

	<category: 'constants Ext'>
	^32927
    ]

    glSampleMaskSgis [
	"GL_SAMPLE_MASK_SGIS  0x80A0"

	<category: 'constants Ext'>
	^32928
    ]

    gl1passSgis [
	"GL_1PASS_SGIS  0x80A1"

	<category: 'constants Ext'>
	^32929
    ]

    gl2pass0Sgis [
	"GL_2PASS_0_SGIS  0x80A2"

	<category: 'constants Ext'>
	^32930
    ]

    gl2pass1Sgis [
	"GL_2PASS_1_SGIS  0x80A3"

	<category: 'constants Ext'>
	^32931
    ]

    gl4pass0Sgis [
	"GL_4PASS_0_SGIS  0x80A4"

	<category: 'constants Ext'>
	^32932
    ]

    gl4pass1Sgis [
	"GL_4PASS_1_SGIS  0x80A5"

	<category: 'constants Ext'>
	^32933
    ]

    gl4pass2Sgis [
	"GL_4PASS_2_SGIS  0x80A6"

	<category: 'constants Ext'>
	^32934
    ]

    gl4pass3Sgis [
	"GL_4PASS_3_SGIS  0x80A7"

	<category: 'constants Ext'>
	^32935
    ]

    glSampleBuffersSgis [
	"GL_SAMPLE_BUFFERS_SGIS  0x80A8"

	<category: 'constants Ext'>
	^32936
    ]

    glSamplesSgis [
	"GL_SAMPLES_SGIS  0x80A9"

	<category: 'constants Ext'>
	^32937
    ]

    glSampleMaskValueSgis [
	"GL_SAMPLE_MASK_VALUE_SGIS  0x80AA"

	<category: 'constants Ext'>
	^32938
    ]

    glSampleMaskInvertSgis [
	"GL_SAMPLE_MASK_INVERT_SGIS  0x80AB"

	<category: 'constants Ext'>
	^32939
    ]

    glSamplePatternSgis [
	"GL_SAMPLE_PATTERN_SGIS  0x80AC"

	<category: 'constants Ext'>
	^32940
    ]

    glRescaleNormalExt [
	"GL_RESCALE_NORMAL_EXT  0x803A"

	<category: 'constants Ext'>
	^32826
    ]

    glVertexArrayExt [
	"GL_VERTEX_ARRAY_EXT  0x8074"

	<category: 'constants Ext'>
	^32884
    ]

    glNormalArrayExt [
	"GL_NORMAL_ARRAY_EXT  0x8075"

	<category: 'constants Ext'>
	^32885
    ]

    glColorArrayExt [
	"GL_COLOR_ARRAY_EXT  0x8076"

	<category: 'constants Ext'>
	^32886
    ]

    glIndexArrayExt [
	"GL_INDEX_ARRAY_EXT  0x8077"

	<category: 'constants Ext'>
	^32887
    ]

    glTextureCoordArrayExt [
	"GL_TEXTURE_COORD_ARRAY_EXT  0x8078"

	<category: 'constants Ext'>
	^32888
    ]

    glEdgeFlagArrayExt [
	"GL_EDGE_FLAG_ARRAY_EXT  0x8079"

	<category: 'constants Ext'>
	^32889
    ]

    glVertexArraySizeExt [
	"GL_VERTEX_ARRAY_SIZE_EXT  0x807A"

	<category: 'constants Ext'>
	^32890
    ]

    glVertexArrayTypeExt [
	"GL_VERTEX_ARRAY_TYPE_EXT  0x807B"

	<category: 'constants Ext'>
	^32891
    ]

    glVertexArrayStrideExt [
	"GL_VERTEX_ARRAY_STRIDE_EXT  0x807C"

	<category: 'constants Ext'>
	^32892
    ]

    glVertexArrayCountExt [
	"GL_VERTEX_ARRAY_COUNT_EXT  0x807D"

	<category: 'constants Ext'>
	^32893
    ]

    glNormalArrayTypeExt [
	"GL_NORMAL_ARRAY_TYPE_EXT  0x807E"

	<category: 'constants Ext'>
	^32894
    ]

    glNormalArrayStrideExt [
	"GL_NORMAL_ARRAY_STRIDE_EXT  0x807F"

	<category: 'constants Ext'>
	^32895
    ]

    glNormalArrayCountExt [
	"GL_NORMAL_ARRAY_COUNT_EXT  0x8080"

	<category: 'constants Ext'>
	^32896
    ]

    glColorArraySizeExt [
	"GL_COLOR_ARRAY_SIZE_EXT  0x8081"

	<category: 'constants Ext'>
	^32897
    ]

    glColorArrayTypeExt [
	"GL_COLOR_ARRAY_TYPE_EXT  0x8082"

	<category: 'constants Ext'>
	^32898
    ]

    glColorArrayStrideExt [
	"GL_COLOR_ARRAY_STRIDE_EXT  0x8083"

	<category: 'constants Ext'>
	^32899
    ]

    glColorArrayCountExt [
	"GL_COLOR_ARRAY_COUNT_EXT  0x8084"

	<category: 'constants Ext'>
	^32900
    ]

    glIndexArrayTypeExt [
	"GL_INDEX_ARRAY_TYPE_EXT  0x8085"

	<category: 'constants Ext'>
	^32901
    ]

    glIndexArrayStrideExt [
	"GL_INDEX_ARRAY_STRIDE_EXT  0x8086"

	<category: 'constants Ext'>
	^32902
    ]

    glIndexArrayCountExt [
	"GL_INDEX_ARRAY_COUNT_EXT  0x8087"

	<category: 'constants Ext'>
	^32903
    ]

    glTextureCoordArraySizeExt [
	"GL_TEXTURE_COORD_ARRAY_SIZE_EXT  0x8088"

	<category: 'constants Ext'>
	^32904
    ]

    glTextureCoordArrayTypeExt [
	"GL_TEXTURE_COORD_ARRAY_TYPE_EXT  0x8089"

	<category: 'constants Ext'>
	^32905
    ]

    glTextureCoordArrayStrideExt [
	"GL_TEXTURE_COORD_ARRAY_STRIDE_EXT  0x808A"

	<category: 'constants Ext'>
	^32906
    ]

    glTextureCoordArrayCountExt [
	"GL_TEXTURE_COORD_ARRAY_COUNT_EXT  0x808B"

	<category: 'constants Ext'>
	^32907
    ]

    glEdgeFlagArrayStrideExt [
	"GL_EDGE_FLAG_ARRAY_STRIDE_EXT  0x808C"

	<category: 'constants Ext'>
	^32908
    ]

    glEdgeFlagArrayCountExt [
	"GL_EDGE_FLAG_ARRAY_COUNT_EXT  0x808D"

	<category: 'constants Ext'>
	^32909
    ]

    glVertexArrayPointerExt [
	"GL_VERTEX_ARRAY_POINTER_EXT  0x808E"

	<category: 'constants Ext'>
	^32910
    ]

    glNormalArrayPointerExt [
	"GL_NORMAL_ARRAY_POINTER_EXT  0x808F"

	<category: 'constants Ext'>
	^32911
    ]

    glColorArrayPointerExt [
	"GL_COLOR_ARRAY_POINTER_EXT  0x8090"

	<category: 'constants Ext'>
	^32912
    ]

    glIndexArrayPointerExt [
	"GL_INDEX_ARRAY_POINTER_EXT  0x8091"

	<category: 'constants Ext'>
	^32913
    ]

    glTextureCoordArrayPointerExt [
	"GL_TEXTURE_COORD_ARRAY_POINTER_EXT  0x8092"

	<category: 'constants Ext'>
	^32914
    ]

    glEdgeFlagArrayPointerExt [
	"GL_EDGE_FLAG_ARRAY_POINTER_EXT  0x8093"

	<category: 'constants Ext'>
	^32915
    ]

    glGenerateMipmapSgis [
	"GL_GENERATE_MIPMAP_SGIS  0x8191"

	<category: 'constants Ext'>
	^33169
    ]

    glGenerateMipmapHintSgis [
	"GL_GENERATE_MIPMAP_HINT_SGIS  0x8192"

	<category: 'constants Ext'>
	^33170
    ]

    glLinearClipmapLinearSgix [
	"GL_LINEAR_CLIPMAP_LINEAR_SGIX  0x8170"

	<category: 'constants Ext'>
	^33136
    ]

    glTextureClipmapCenterSgix [
	"GL_TEXTURE_CLIPMAP_CENTER_SGIX  0x8171"

	<category: 'constants Ext'>
	^33137
    ]

    glTextureClipmapFrameSgix [
	"GL_TEXTURE_CLIPMAP_FRAME_SGIX  0x8172"

	<category: 'constants Ext'>
	^33138
    ]

    glTextureClipmapOffsetSgix [
	"GL_TEXTURE_CLIPMAP_OFFSET_SGIX  0x8173"

	<category: 'constants Ext'>
	^33139
    ]

    glTextureClipmapVirtualDepthSgix [
	"GL_TEXTURE_CLIPMAP_VIRTUAL_DEPTH_SGIX  0x8174"

	<category: 'constants Ext'>
	^33140
    ]

    glTextureClipmapLodOffsetSgix [
	"GL_TEXTURE_CLIPMAP_LOD_OFFSET_SGIX  0x8175"

	<category: 'constants Ext'>
	^33141
    ]

    glTextureClipmapDepthSgix [
	"GL_TEXTURE_CLIPMAP_DEPTH_SGIX  0x8176"

	<category: 'constants Ext'>
	^33142
    ]

    glMaxClipmapDepthSgix [
	"GL_MAX_CLIPMAP_DEPTH_SGIX  0x8177"

	<category: 'constants Ext'>
	^33143
    ]

    glMaxClipmapVirtualDepthSgix [
	"GL_MAX_CLIPMAP_VIRTUAL_DEPTH_SGIX  0x8178"

	<category: 'constants Ext'>
	^33144
    ]

    glNearestClipmapNearestSgix [
	"GL_NEAREST_CLIPMAP_NEAREST_SGIX  0x844D"

	<category: 'constants Ext'>
	^33869
    ]

    glNearestClipmapLinearSgix [
	"GL_NEAREST_CLIPMAP_LINEAR_SGIX  0x844E"

	<category: 'constants Ext'>
	^33870
    ]

    glLinearClipmapNearestSgix [
	"GL_LINEAR_CLIPMAP_NEAREST_SGIX  0x844F"

	<category: 'constants Ext'>
	^33871
    ]

    glTextureCompareSgix [
	"GL_TEXTURE_COMPARE_SGIX  0x819A"

	<category: 'constants Ext'>
	^33178
    ]

    glTextureCompareOperatorSgix [
	"GL_TEXTURE_COMPARE_OPERATOR_SGIX  0x819B"

	<category: 'constants Ext'>
	^33179
    ]

    glTextureLequalRSgix [
	"GL_TEXTURE_LEQUAL_R_SGIX  0x819C"

	<category: 'constants Ext'>
	^33180
    ]

    glTextureGequalRSgix [
	"GL_TEXTURE_GEQUAL_R_SGIX  0x819D"

	<category: 'constants Ext'>
	^33181
    ]

    glClampToEdgeSgis [
	"GL_CLAMP_TO_EDGE_SGIS  0x812F"

	<category: 'constants Ext'>
	^33071
    ]

    glClampToBorderSgis [
	"GL_CLAMP_TO_BORDER_SGIS  0x812D"

	<category: 'constants Ext'>
	^33069
    ]

    glFuncAddExt [
	"GL_FUNC_ADD_EXT  0x8006"

	<category: 'constants Ext'>
	^32774
    ]

    glMinExt [
	"GL_MIN_EXT  0x8007"

	<category: 'constants Ext'>
	^32775
    ]

    glMaxExt [
	"GL_MAX_EXT  0x8008"

	<category: 'constants Ext'>
	^32776
    ]

    glBlendEquationExt [
	"GL_BLEND_EQUATION_EXT  0x8009"

	<category: 'constants Ext'>
	^32777
    ]

    glFuncSubtractExt [
	"GL_FUNC_SUBTRACT_EXT  0x800A"

	<category: 'constants Ext'>
	^32778
    ]

    glFuncReverseSubtractExt [
	"GL_FUNC_REVERSE_SUBTRACT_EXT  0x800B"

	<category: 'constants Ext'>
	^32779
    ]

    glInterlaceSgix [
	"GL_INTERLACE_SGIX  0x8094"

	<category: 'constants Ext'>
	^32916
    ]

    glPixelTileBestAlignmentSgix [
	"GL_PIXEL_TILE_BEST_ALIGNMENT_SGIX  0x813E"

	<category: 'constants Ext'>
	^33086
    ]

    glPixelTileCacheIncrementSgix [
	"GL_PIXEL_TILE_CACHE_INCREMENT_SGIX  0x813F"

	<category: 'constants Ext'>
	^33087
    ]

    glPixelTileWidthSgix [
	"GL_PIXEL_TILE_WIDTH_SGIX  0x8140"

	<category: 'constants Ext'>
	^33088
    ]

    glPixelTileHeightSgix [
	"GL_PIXEL_TILE_HEIGHT_SGIX  0x8141"

	<category: 'constants Ext'>
	^33089
    ]

    glPixelTileGridWidthSgix [
	"GL_PIXEL_TILE_GRID_WIDTH_SGIX  0x8142"

	<category: 'constants Ext'>
	^33090
    ]

    glPixelTileGridHeightSgix [
	"GL_PIXEL_TILE_GRID_HEIGHT_SGIX  0x8143"

	<category: 'constants Ext'>
	^33091
    ]

    glPixelTileGridDepthSgix [
	"GL_PIXEL_TILE_GRID_DEPTH_SGIX  0x8144"

	<category: 'constants Ext'>
	^33092
    ]

    glPixelTileCacheSizeSgix [
	"GL_PIXEL_TILE_CACHE_SIZE_SGIX  0x8145"

	<category: 'constants Ext'>
	^33093
    ]

    glDualAlpha4Sgis [
	"GL_DUAL_ALPHA4_SGIS  0x8110"

	<category: 'constants Ext'>
	^33040
    ]

    glDualAlpha8Sgis [
	"GL_DUAL_ALPHA8_SGIS  0x8111"

	<category: 'constants Ext'>
	^33041
    ]

    glDualAlpha12Sgis [
	"GL_DUAL_ALPHA12_SGIS  0x8112"

	<category: 'constants Ext'>
	^33042
    ]

    glDualAlpha16Sgis [
	"GL_DUAL_ALPHA16_SGIS  0x8113"

	<category: 'constants Ext'>
	^33043
    ]

    glDualLuminance4Sgis [
	"GL_DUAL_LUMINANCE4_SGIS  0x8114"

	<category: 'constants Ext'>
	^33044
    ]

    glDualLuminance8Sgis [
	"GL_DUAL_LUMINANCE8_SGIS  0x8115"

	<category: 'constants Ext'>
	^33045
    ]

    glDualLuminance12Sgis [
	"GL_DUAL_LUMINANCE12_SGIS  0x8116"

	<category: 'constants Ext'>
	^33046
    ]

    glDualLuminance16Sgis [
	"GL_DUAL_LUMINANCE16_SGIS  0x8117"

	<category: 'constants Ext'>
	^33047
    ]

    glDualIntensity4Sgis [
	"GL_DUAL_INTENSITY4_SGIS  0x8118"

	<category: 'constants Ext'>
	^33048
    ]

    glDualIntensity8Sgis [
	"GL_DUAL_INTENSITY8_SGIS  0x8119"

	<category: 'constants Ext'>
	^33049
    ]

    glDualIntensity12Sgis [
	"GL_DUAL_INTENSITY12_SGIS  0x811A"

	<category: 'constants Ext'>
	^33050
    ]

    glDualIntensity16Sgis [
	"GL_DUAL_INTENSITY16_SGIS  0x811B"

	<category: 'constants Ext'>
	^33051
    ]

    glDualLuminanceAlpha4Sgis [
	"GL_DUAL_LUMINANCE_ALPHA4_SGIS  0x811C"

	<category: 'constants Ext'>
	^33052
    ]

    glDualLuminanceAlpha8Sgis [
	"GL_DUAL_LUMINANCE_ALPHA8_SGIS  0x811D"

	<category: 'constants Ext'>
	^33053
    ]

    glQuadAlpha4Sgis [
	"GL_QUAD_ALPHA4_SGIS  0x811E"

	<category: 'constants Ext'>
	^33054
    ]

    glQuadAlpha8Sgis [
	"GL_QUAD_ALPHA8_SGIS  0x811F"

	<category: 'constants Ext'>
	^33055
    ]

    glQuadLuminance4Sgis [
	"GL_QUAD_LUMINANCE4_SGIS  0x8120"

	<category: 'constants Ext'>
	^33056
    ]

    glQuadLuminance8Sgis [
	"GL_QUAD_LUMINANCE8_SGIS  0x8121"

	<category: 'constants Ext'>
	^33057
    ]

    glQuadIntensity4Sgis [
	"GL_QUAD_INTENSITY4_SGIS  0x8122"

	<category: 'constants Ext'>
	^33058
    ]

    glQuadIntensity8Sgis [
	"GL_QUAD_INTENSITY8_SGIS  0x8123"

	<category: 'constants Ext'>
	^33059
    ]

    glDualTextureSelectSgis [
	"GL_DUAL_TEXTURE_SELECT_SGIS  0x8124"

	<category: 'constants Ext'>
	^33060
    ]

    glQuadTextureSelectSgis [
	"GL_QUAD_TEXTURE_SELECT_SGIS  0x8125"

	<category: 'constants Ext'>
	^33061
    ]

    glSpriteSgix [
	"GL_SPRITE_SGIX  0x8148"

	<category: 'constants Ext'>
	^33096
    ]

    glSpriteModeSgix [
	"GL_SPRITE_MODE_SGIX  0x8149"

	<category: 'constants Ext'>
	^33097
    ]

    glSpriteAxisSgix [
	"GL_SPRITE_AXIS_SGIX  0x814A"

	<category: 'constants Ext'>
	^33098
    ]

    glSpriteTranslationSgix [
	"GL_SPRITE_TRANSLATION_SGIX  0x814B"

	<category: 'constants Ext'>
	^33099
    ]

    glSpriteAxialSgix [
	"GL_SPRITE_AXIAL_SGIX  0x814C"

	<category: 'constants Ext'>
	^33100
    ]

    glSpriteObjectAlignedSgix [
	"GL_SPRITE_OBJECT_ALIGNED_SGIX  0x814D"

	<category: 'constants Ext'>
	^33101
    ]

    glSpriteEyeAlignedSgix [
	"GL_SPRITE_EYE_ALIGNED_SGIX  0x814E"

	<category: 'constants Ext'>
	^33102
    ]

    glTextureMultiBufferHintSgix [
	"GL_TEXTURE_MULTI_BUFFER_HINT_SGIX  0x812E"

	<category: 'constants Ext'>
	^33070
    ]

    glPointSizeMinExt [
	"GL_POINT_SIZE_MIN_EXT  0x8126"

	<category: 'constants Ext'>
	^33062
    ]

    glPointSizeMaxExt [
	"GL_POINT_SIZE_MAX_EXT  0x8127"

	<category: 'constants Ext'>
	^33063
    ]

    glPointFadeThresholdSizeExt [
	"GL_POINT_FADE_THRESHOLD_SIZE_EXT  0x8128"

	<category: 'constants Ext'>
	^33064
    ]

    glDistanceAttenuationExt [
	"GL_DISTANCE_ATTENUATION_EXT  0x8129"

	<category: 'constants Ext'>
	^33065
    ]

    glPointSizeMinSgis [
	"GL_POINT_SIZE_MIN_SGIS  0x8126"

	<category: 'constants Ext'>
	^33062
    ]

    glPointSizeMaxSgis [
	"GL_POINT_SIZE_MAX_SGIS  0x8127"

	<category: 'constants Ext'>
	^33063
    ]

    glPointFadeThresholdSizeSgis [
	"GL_POINT_FADE_THRESHOLD_SIZE_SGIS  0x8128"

	<category: 'constants Ext'>
	^33064
    ]

    glDistanceAttenuationSgis [
	"GL_DISTANCE_ATTENUATION_SGIS  0x8129"

	<category: 'constants Ext'>
	^33065
    ]

    glInstrumentBufferPointerSgix [
	"GL_INSTRUMENT_BUFFER_POINTER_SGIX  0x8180"

	<category: 'constants Ext'>
	^33152
    ]

    glInstrumentMeasurementsSgix [
	"GL_INSTRUMENT_MEASUREMENTS_SGIX  0x8181"

	<category: 'constants Ext'>
	^33153
    ]

    glPostTextureFilterBiasSgix [
	"GL_POST_TEXTURE_FILTER_BIAS_SGIX  0x8179"

	<category: 'constants Ext'>
	^33145
    ]

    glPostTextureFilterScaleSgix [
	"GL_POST_TEXTURE_FILTER_SCALE_SGIX  0x817A"

	<category: 'constants Ext'>
	^33146
    ]

    glPostTextureFilterBiasRangeSgix [
	"GL_POST_TEXTURE_FILTER_BIAS_RANGE_SGIX  0x817B"

	<category: 'constants Ext'>
	^33147
    ]

    glPostTextureFilterScaleRangeSgix [
	"GL_POST_TEXTURE_FILTER_SCALE_RANGE_SGIX  0x817C"

	<category: 'constants Ext'>
	^33148
    ]

    glFramezoomSgix [
	"GL_FRAMEZOOM_SGIX  0x818B"

	<category: 'constants Ext'>
	^33163
    ]

    glFramezoomFactorSgix [
	"GL_FRAMEZOOM_FACTOR_SGIX  0x818C"

	<category: 'constants Ext'>
	^33164
    ]

    glMaxFramezoomFactorSgix [
	"GL_MAX_FRAMEZOOM_FACTOR_SGIX  0x818D"

	<category: 'constants Ext'>
	^33165
    ]

    glTextureDeformationBitSgix [
	"GL_TEXTURE_DEFORMATION_BIT_SGIX  0x00000001"

	<category: 'constants Ext'>
	^1
    ]

    glGeometryDeformationBitSgix [
	"GL_GEOMETRY_DEFORMATION_BIT_SGIX  0x00000002"

	<category: 'constants Ext'>
	^2
    ]

    glGeometryDeformationSgix [
	"GL_GEOMETRY_DEFORMATION_SGIX  0x8194"

	<category: 'constants Ext'>
	^33172
    ]

    glTextureDeformationSgix [
	"GL_TEXTURE_DEFORMATION_SGIX  0x8195"

	<category: 'constants Ext'>
	^33173
    ]

    glDeformationsMaskSgix [
	"GL_DEFORMATIONS_MASK_SGIX  0x8196"

	<category: 'constants Ext'>
	^33174
    ]

    glMaxDeformationOrderSgix [
	"GL_MAX_DEFORMATION_ORDER_SGIX  0x8197"

	<category: 'constants Ext'>
	^33175
    ]

    glReferencePlaneSgix [
	"GL_REFERENCE_PLANE_SGIX  0x817D"

	<category: 'constants Ext'>
	^33149
    ]

    glReferencePlaneEquationSgix [
	"GL_REFERENCE_PLANE_EQUATION_SGIX  0x817E"

	<category: 'constants Ext'>
	^33150
    ]

    glDepthComponent16Sgix [
	"GL_DEPTH_COMPONENT16_SGIX  0x81A5"

	<category: 'constants Ext'>
	^33189
    ]

    glDepthComponent24Sgix [
	"GL_DEPTH_COMPONENT24_SGIX  0x81A6"

	<category: 'constants Ext'>
	^33190
    ]

    glDepthComponent32Sgix [
	"GL_DEPTH_COMPONENT32_SGIX  0x81A7"

	<category: 'constants Ext'>
	^33191
    ]

    glFogFuncSgis [
	"GL_FOG_FUNC_SGIS  0x812A"

	<category: 'constants Ext'>
	^33066
    ]

    glFogFuncPointsSgis [
	"GL_FOG_FUNC_POINTS_SGIS  0x812B"

	<category: 'constants Ext'>
	^33067
    ]

    glMaxFogFuncPointsSgis [
	"GL_MAX_FOG_FUNC_POINTS_SGIS  0x812C"

	<category: 'constants Ext'>
	^33068
    ]

    glFogOffsetSgix [
	"GL_FOG_OFFSET_SGIX  0x8198"

	<category: 'constants Ext'>
	^33176
    ]

    glFogOffsetValueSgix [
	"GL_FOG_OFFSET_VALUE_SGIX  0x8199"

	<category: 'constants Ext'>
	^33177
    ]

    glImageScaleXHp [
	"GL_IMAGE_SCALE_X_HP  0x8155"

	<category: 'constants Ext'>
	^33109
    ]

    glImageScaleYHp [
	"GL_IMAGE_SCALE_Y_HP  0x8156"

	<category: 'constants Ext'>
	^33110
    ]

    glImageTranslateXHp [
	"GL_IMAGE_TRANSLATE_X_HP  0x8157"

	<category: 'constants Ext'>
	^33111
    ]

    glImageTranslateYHp [
	"GL_IMAGE_TRANSLATE_Y_HP  0x8158"

	<category: 'constants Ext'>
	^33112
    ]

    glImageRotateAngleHp [
	"GL_IMAGE_ROTATE_ANGLE_HP  0x8159"

	<category: 'constants Ext'>
	^33113
    ]

    glImageRotateOriginXHp [
	"GL_IMAGE_ROTATE_ORIGIN_X_HP  0x815A"

	<category: 'constants Ext'>
	^33114
    ]

    glImageRotateOriginYHp [
	"GL_IMAGE_ROTATE_ORIGIN_Y_HP  0x815B"

	<category: 'constants Ext'>
	^33115
    ]

    glImageMagFilterHp [
	"GL_IMAGE_MAG_FILTER_HP  0x815C"

	<category: 'constants Ext'>
	^33116
    ]

    glImageMinFilterHp [
	"GL_IMAGE_MIN_FILTER_HP  0x815D"

	<category: 'constants Ext'>
	^33117
    ]

    glImageCubicWeightHp [
	"GL_IMAGE_CUBIC_WEIGHT_HP  0x815E"

	<category: 'constants Ext'>
	^33118
    ]

    glCubicHp [
	"GL_CUBIC_HP  0x815F"

	<category: 'constants Ext'>
	^33119
    ]

    glAverageHp [
	"GL_AVERAGE_HP  0x8160"

	<category: 'constants Ext'>
	^33120
    ]

    glImageTransform2dHp [
	"GL_IMAGE_TRANSFORM_2D_HP  0x8161"

	<category: 'constants Ext'>
	^33121
    ]

    glPostImageTransformColorTableHp [
	"GL_POST_IMAGE_TRANSFORM_COLOR_TABLE_HP  0x8162"

	<category: 'constants Ext'>
	^33122
    ]

    glProxyPostImageTransformColorTableHp [
	"GL_PROXY_POST_IMAGE_TRANSFORM_COLOR_TABLE_HP  0x8163"

	<category: 'constants Ext'>
	^33123
    ]

    glIgnoreBorderHp [
	"GL_IGNORE_BORDER_HP  0x8150"

	<category: 'constants Ext'>
	^33104
    ]

    glConstantBorderHp [
	"GL_CONSTANT_BORDER_HP  0x8151"

	<category: 'constants Ext'>
	^33105
    ]

    glReplicateBorderHp [
	"GL_REPLICATE_BORDER_HP  0x8153"

	<category: 'constants Ext'>
	^33107
    ]

    glConvolutionBorderColorHp [
	"GL_CONVOLUTION_BORDER_COLOR_HP  0x8154"

	<category: 'constants Ext'>
	^33108
    ]

    glTextureEnvBiasSgix [
	"GL_TEXTURE_ENV_BIAS_SGIX  0x80BE"

	<category: 'constants Ext'>
	^32958
    ]

    glVertexDataHintPgi [
	"GL_VERTEX_DATA_HINT_PGI  0x1A22A"

	<category: 'constants Ext'>
	^107050
    ]

    glVertexConsistentHintPgi [
	"GL_VERTEX_CONSISTENT_HINT_PGI  0x1A22B"

	<category: 'constants Ext'>
	^107051
    ]

    glMaterialSideHintPgi [
	"GL_MATERIAL_SIDE_HINT_PGI  0x1A22C"

	<category: 'constants Ext'>
	^107052
    ]

    glMaxVertexHintPgi [
	"GL_MAX_VERTEX_HINT_PGI  0x1A22D"

	<category: 'constants Ext'>
	^107053
    ]

    glColor3BitPgi [
	"GL_COLOR3_BIT_PGI  0x00010000"

	<category: 'constants Ext'>
	^65536
    ]

    glColor4BitPgi [
	"GL_COLOR4_BIT_PGI  0x00020000"

	<category: 'constants Ext'>
	^131072
    ]

    glEdgeflagBitPgi [
	"GL_EDGEFLAG_BIT_PGI  0x00040000"

	<category: 'constants Ext'>
	^262144
    ]

    glIndexBitPgi [
	"GL_INDEX_BIT_PGI  0x00080000"

	<category: 'constants Ext'>
	^524288
    ]

    glMatAmbientBitPgi [
	"GL_MAT_AMBIENT_BIT_PGI  0x00100000"

	<category: 'constants Ext'>
	^1048576
    ]

    glMatAmbientAndDiffuseBitPgi [
	"GL_MAT_AMBIENT_AND_DIFFUSE_BIT_PGI  0x00200000"

	<category: 'constants Ext'>
	^2097152
    ]

    glMatDiffuseBitPgi [
	"GL_MAT_DIFFUSE_BIT_PGI  0x00400000"

	<category: 'constants Ext'>
	^4194304
    ]

    glMatEmissionBitPgi [
	"GL_MAT_EMISSION_BIT_PGI  0x00800000"

	<category: 'constants Ext'>
	^8388608
    ]

    glMatColorIndexesBitPgi [
	"GL_MAT_COLOR_INDEXES_BIT_PGI  0x01000000"

	<category: 'constants Ext'>
	^16777216
    ]

    glMatShininessBitPgi [
	"GL_MAT_SHININESS_BIT_PGI  0x02000000"

	<category: 'constants Ext'>
	^33554432
    ]

    glMatSpecularBitPgi [
	"GL_MAT_SPECULAR_BIT_PGI  0x04000000"

	<category: 'constants Ext'>
	^67108864
    ]

    glNormalBitPgi [
	"GL_NORMAL_BIT_PGI  0x08000000"

	<category: 'constants Ext'>
	^134217728
    ]

    glTexcoord1BitPgi [
	"GL_TEXCOORD1_BIT_PGI  0x10000000"

	<category: 'constants Ext'>
	^268435456
    ]

    glTexcoord2BitPgi [
	"GL_TEXCOORD2_BIT_PGI  0x20000000"

	<category: 'constants Ext'>
	^536870912
    ]

    glTexcoord3BitPgi [
	"GL_TEXCOORD3_BIT_PGI  0x40000000"

	<category: 'constants Ext'>
	^1073741824
    ]

    glTexcoord4BitPgi [
	"GL_TEXCOORD4_BIT_PGI  0x80000000"

	<category: 'constants Ext'>
	^2147483648
    ]

    glVertex23BitPgi [
	"GL_VERTEX23_BIT_PGI  0x00000004"

	<category: 'constants Ext'>
	^4
    ]

    glVertex4BitPgi [
	"GL_VERTEX4_BIT_PGI  0x00000008"

	<category: 'constants Ext'>
	^8
    ]

    glPreferDoublebufferHintPgi [
	"GL_PREFER_DOUBLEBUFFER_HINT_PGI  0x1A1F8"

	<category: 'constants Ext'>
	^107000
    ]

    glConserveMemoryHintPgi [
	"GL_CONSERVE_MEMORY_HINT_PGI  0x1A1FD"

	<category: 'constants Ext'>
	^107005
    ]

    glReclaimMemoryHintPgi [
	"GL_RECLAIM_MEMORY_HINT_PGI  0x1A1FE"

	<category: 'constants Ext'>
	^107006
    ]

    glNativeGraphicsHandlePgi [
	"GL_NATIVE_GRAPHICS_HANDLE_PGI  0x1A202"

	<category: 'constants Ext'>
	^107010
    ]

    glNativeGraphicsBeginHintPgi [
	"GL_NATIVE_GRAPHICS_BEGIN_HINT_PGI  0x1A203"

	<category: 'constants Ext'>
	^107011
    ]

    glNativeGraphicsEndHintPgi [
	"GL_NATIVE_GRAPHICS_END_HINT_PGI  0x1A204"

	<category: 'constants Ext'>
	^107012
    ]

    glAlwaysFastHintPgi [
	"GL_ALWAYS_FAST_HINT_PGI  0x1A20C"

	<category: 'constants Ext'>
	^107020
    ]

    glAlwaysSoftHintPgi [
	"GL_ALWAYS_SOFT_HINT_PGI  0x1A20D"

	<category: 'constants Ext'>
	^107021
    ]

    glAllowDrawObjHintPgi [
	"GL_ALLOW_DRAW_OBJ_HINT_PGI  0x1A20E"

	<category: 'constants Ext'>
	^107022
    ]

    glAllowDrawWinHintPgi [
	"GL_ALLOW_DRAW_WIN_HINT_PGI  0x1A20F"

	<category: 'constants Ext'>
	^107023
    ]

    glAllowDrawFrgHintPgi [
	"GL_ALLOW_DRAW_FRG_HINT_PGI  0x1A210"

	<category: 'constants Ext'>
	^107024
    ]

    glAllowDrawMemHintPgi [
	"GL_ALLOW_DRAW_MEM_HINT_PGI  0x1A211"

	<category: 'constants Ext'>
	^107025
    ]

    glStrictDepthfuncHintPgi [
	"GL_STRICT_DEPTHFUNC_HINT_PGI  0x1A216"

	<category: 'constants Ext'>
	^107030
    ]

    glStrictLightingHintPgi [
	"GL_STRICT_LIGHTING_HINT_PGI  0x1A217"

	<category: 'constants Ext'>
	^107031
    ]

    glStrictScissorHintPgi [
	"GL_STRICT_SCISSOR_HINT_PGI  0x1A218"

	<category: 'constants Ext'>
	^107032
    ]

    glFullStippleHintPgi [
	"GL_FULL_STIPPLE_HINT_PGI  0x1A219"

	<category: 'constants Ext'>
	^107033
    ]

    glClipNearHintPgi [
	"GL_CLIP_NEAR_HINT_PGI  0x1A220"

	<category: 'constants Ext'>
	^107040
    ]

    glClipFarHintPgi [
	"GL_CLIP_FAR_HINT_PGI  0x1A221"

	<category: 'constants Ext'>
	^107041
    ]

    glWideLineHintPgi [
	"GL_WIDE_LINE_HINT_PGI  0x1A222"

	<category: 'constants Ext'>
	^107042
    ]

    glBackNormalsHintPgi [
	"GL_BACK_NORMALS_HINT_PGI  0x1A223"

	<category: 'constants Ext'>
	^107043
    ]

    glColorIndex1Ext [
	"GL_COLOR_INDEX1_EXT  0x80E2"

	<category: 'constants Ext'>
	^32994
    ]

    glColorIndex2Ext [
	"GL_COLOR_INDEX2_EXT  0x80E3"

	<category: 'constants Ext'>
	^32995
    ]

    glColorIndex4Ext [
	"GL_COLOR_INDEX4_EXT  0x80E4"

	<category: 'constants Ext'>
	^32996
    ]

    glColorIndex8Ext [
	"GL_COLOR_INDEX8_EXT  0x80E5"

	<category: 'constants Ext'>
	^32997
    ]

    glColorIndex12Ext [
	"GL_COLOR_INDEX12_EXT  0x80E6"

	<category: 'constants Ext'>
	^32998
    ]

    glColorIndex16Ext [
	"GL_COLOR_INDEX16_EXT  0x80E7"

	<category: 'constants Ext'>
	^32999
    ]

    glTextureIndexSizeExt [
	"GL_TEXTURE_INDEX_SIZE_EXT  0x80ED"

	<category: 'constants Ext'>
	^33005
    ]

    glClipVolumeClippingHintExt [
	"GL_CLIP_VOLUME_CLIPPING_HINT_EXT  0x80F0"

	<category: 'constants Ext'>
	^33008
    ]

    glListPrioritySgix [
	"GL_LIST_PRIORITY_SGIX  0x8182"

	<category: 'constants Ext'>
	^33154
    ]

    glIrInstrument1Sgix [
	"GL_IR_INSTRUMENT1_SGIX  0x817F"

	<category: 'constants Ext'>
	^33151
    ]

    glCalligraphicFragmentSgix [
	"GL_CALLIGRAPHIC_FRAGMENT_SGIX  0x8183"

	<category: 'constants Ext'>
	^33155
    ]

    glTextureLodBiasSSgix [
	"GL_TEXTURE_LOD_BIAS_S_SGIX  0x818E"

	<category: 'constants Ext'>
	^33166
    ]

    glTextureLodBiasTSgix [
	"GL_TEXTURE_LOD_BIAS_T_SGIX  0x818F"

	<category: 'constants Ext'>
	^33167
    ]

    glTextureLodBiasRSgix [
	"GL_TEXTURE_LOD_BIAS_R_SGIX  0x8190"

	<category: 'constants Ext'>
	^33168
    ]

    glShadowAmbientSgix [
	"GL_SHADOW_AMBIENT_SGIX  0x80BF"

	<category: 'constants Ext'>
	^32959
    ]

    glIndexMaterialExt [
	"GL_INDEX_MATERIAL_EXT  0x81B8"

	<category: 'constants Ext'>
	^33208
    ]

    glIndexMaterialParameterExt [
	"GL_INDEX_MATERIAL_PARAMETER_EXT  0x81B9"

	<category: 'constants Ext'>
	^33209
    ]

    glIndexMaterialFaceExt [
	"GL_INDEX_MATERIAL_FACE_EXT  0x81BA"

	<category: 'constants Ext'>
	^33210
    ]

    glIndexTestExt [
	"GL_INDEX_TEST_EXT  0x81B5"

	<category: 'constants Ext'>
	^33205
    ]

    glIndexTestFuncExt [
	"GL_INDEX_TEST_FUNC_EXT  0x81B6"

	<category: 'constants Ext'>
	^33206
    ]

    glIndexTestRefExt [
	"GL_INDEX_TEST_REF_EXT  0x81B7"

	<category: 'constants Ext'>
	^33207
    ]

    glIuiV2fExt [
	"GL_IUI_V2F_EXT  0x81AD"

	<category: 'constants Ext'>
	^33197
    ]

    glIuiV3fExt [
	"GL_IUI_V3F_EXT  0x81AE"

	<category: 'constants Ext'>
	^33198
    ]

    glIuiN3fV2fExt [
	"GL_IUI_N3F_V2F_EXT  0x81AF"

	<category: 'constants Ext'>
	^33199
    ]

    glIuiN3fV3fExt [
	"GL_IUI_N3F_V3F_EXT  0x81B0"

	<category: 'constants Ext'>
	^33200
    ]

    glT2fIuiV2fExt [
	"GL_T2F_IUI_V2F_EXT  0x81B1"

	<category: 'constants Ext'>
	^33201
    ]

    glT2fIuiV3fExt [
	"GL_T2F_IUI_V3F_EXT  0x81B2"

	<category: 'constants Ext'>
	^33202
    ]

    glT2fIuiN3fV2fExt [
	"GL_T2F_IUI_N3F_V2F_EXT  0x81B3"

	<category: 'constants Ext'>
	^33203
    ]

    glT2fIuiN3fV3fExt [
	"GL_T2F_IUI_N3F_V3F_EXT  0x81B4"

	<category: 'constants Ext'>
	^33204
    ]

    glArrayElementLockFirstExt [
	"GL_ARRAY_ELEMENT_LOCK_FIRST_EXT  0x81A8"

	<category: 'constants Ext'>
	^33192
    ]

    glArrayElementLockCountExt [
	"GL_ARRAY_ELEMENT_LOCK_COUNT_EXT  0x81A9"

	<category: 'constants Ext'>
	^33193
    ]

    glCullVertexExt [
	"GL_CULL_VERTEX_EXT  0x81AA"

	<category: 'constants Ext'>
	^33194
    ]

    glCullVertexEyePositionExt [
	"GL_CULL_VERTEX_EYE_POSITION_EXT  0x81AB"

	<category: 'constants Ext'>
	^33195
    ]

    glCullVertexObjectPositionExt [
	"GL_CULL_VERTEX_OBJECT_POSITION_EXT  0x81AC"

	<category: 'constants Ext'>
	^33196
    ]

    glYcrcb422Sgix [
	"GL_YCRCB_422_SGIX  0x81BB"

	<category: 'constants Ext'>
	^33211
    ]

    glYcrcb444Sgix [
	"GL_YCRCB_444_SGIX  0x81BC"

	<category: 'constants Ext'>
	^33212
    ]

    glFragmentLightingSgix [
	"GL_FRAGMENT_LIGHTING_SGIX  0x8400"

	<category: 'constants Ext'>
	^33792
    ]

    glFragmentColorMaterialSgix [
	"GL_FRAGMENT_COLOR_MATERIAL_SGIX  0x8401"

	<category: 'constants Ext'>
	^33793
    ]

    glFragmentColorMaterialFaceSgix [
	"GL_FRAGMENT_COLOR_MATERIAL_FACE_SGIX  0x8402"

	<category: 'constants Ext'>
	^33794
    ]

    glFragmentColorMaterialParameterSgix [
	"GL_FRAGMENT_COLOR_MATERIAL_PARAMETER_SGIX  0x8403"

	<category: 'constants Ext'>
	^33795
    ]

    glMaxFragmentLightsSgix [
	"GL_MAX_FRAGMENT_LIGHTS_SGIX  0x8404"

	<category: 'constants Ext'>
	^33796
    ]

    glMaxActiveLightsSgix [
	"GL_MAX_ACTIVE_LIGHTS_SGIX  0x8405"

	<category: 'constants Ext'>
	^33797
    ]

    glCurrentRasterNormalSgix [
	"GL_CURRENT_RASTER_NORMAL_SGIX  0x8406"

	<category: 'constants Ext'>
	^33798
    ]

    glLightEnvModeSgix [
	"GL_LIGHT_ENV_MODE_SGIX  0x8407"

	<category: 'constants Ext'>
	^33799
    ]

    glFragmentLightModelLocalViewerSgix [
	"GL_FRAGMENT_LIGHT_MODEL_LOCAL_VIEWER_SGIX  0x8408"

	<category: 'constants Ext'>
	^33800
    ]

    glFragmentLightModelTwoSideSgix [
	"GL_FRAGMENT_LIGHT_MODEL_TWO_SIDE_SGIX  0x8409"

	<category: 'constants Ext'>
	^33801
    ]

    glFragmentLightModelAmbientSgix [
	"GL_FRAGMENT_LIGHT_MODEL_AMBIENT_SGIX  0x840A"

	<category: 'constants Ext'>
	^33802
    ]

    glFragmentLightModelNormalInterpolationSgix [
	"GL_FRAGMENT_LIGHT_MODEL_NORMAL_INTERPOLATION_SGIX  0x840B"

	<category: 'constants Ext'>
	^33803
    ]

    glFragmentLight0Sgix [
	"GL_FRAGMENT_LIGHT0_SGIX  0x840C"

	<category: 'constants Ext'>
	^33804
    ]

    glFragmentLight1Sgix [
	"GL_FRAGMENT_LIGHT1_SGIX  0x840D"

	<category: 'constants Ext'>
	^33805
    ]

    glFragmentLight2Sgix [
	"GL_FRAGMENT_LIGHT2_SGIX  0x840E"

	<category: 'constants Ext'>
	^33806
    ]

    glFragmentLight3Sgix [
	"GL_FRAGMENT_LIGHT3_SGIX  0x840F"

	<category: 'constants Ext'>
	^33807
    ]

    glFragmentLight4Sgix [
	"GL_FRAGMENT_LIGHT4_SGIX  0x8410"

	<category: 'constants Ext'>
	^33808
    ]

    glFragmentLight5Sgix [
	"GL_FRAGMENT_LIGHT5_SGIX  0x8411"

	<category: 'constants Ext'>
	^33809
    ]

    glFragmentLight6Sgix [
	"GL_FRAGMENT_LIGHT6_SGIX  0x8412"

	<category: 'constants Ext'>
	^33810
    ]

    glFragmentLight7Sgix [
	"GL_FRAGMENT_LIGHT7_SGIX  0x8413"

	<category: 'constants Ext'>
	^33811
    ]

    glRasterPositionUnclippedIbm [
	"GL_RASTER_POSITION_UNCLIPPED_IBM  0x19262"

	<category: 'constants Ext'>
	^103010
    ]

    glTextureLightingModeHp [
	"GL_TEXTURE_LIGHTING_MODE_HP  0x8167"

	<category: 'constants Ext'>
	^33127
    ]

    glTexturePostSpecularHp [
	"GL_TEXTURE_POST_SPECULAR_HP  0x8168"

	<category: 'constants Ext'>
	^33128
    ]

    glTexturePreSpecularHp [
	"GL_TEXTURE_PRE_SPECULAR_HP  0x8169"

	<category: 'constants Ext'>
	^33129
    ]

    glMaxElementsVerticesExt [
	"GL_MAX_ELEMENTS_VERTICES_EXT  0x80E8"

	<category: 'constants Ext'>
	^33000
    ]

    glMaxElementsIndicesExt [
	"GL_MAX_ELEMENTS_INDICES_EXT  0x80E9"

	<category: 'constants Ext'>
	^33001
    ]

    glPhongWin [
	"GL_PHONG_WIN  0x80EA"

	<category: 'constants Ext'>
	^33002
    ]

    glPhongHintWin [
	"GL_PHONG_HINT_WIN  0x80EB"

	<category: 'constants Ext'>
	^33003
    ]

    glFogSpecularTextureWin [
	"GL_FOG_SPECULAR_TEXTURE_WIN  0x80EC"

	<category: 'constants Ext'>
	^33004
    ]

    glFragmentMaterialExt [
	"GL_FRAGMENT_MATERIAL_EXT  0x8349"

	<category: 'constants Ext'>
	^33609
    ]

    glFragmentNormalExt [
	"GL_FRAGMENT_NORMAL_EXT  0x834A"

	<category: 'constants Ext'>
	^33610
    ]

    glFragmentColorExt [
	"GL_FRAGMENT_COLOR_EXT  0x834C"

	<category: 'constants Ext'>
	^33612
    ]

    glAttenuationExt [
	"GL_ATTENUATION_EXT  0x834D"

	<category: 'constants Ext'>
	^33613
    ]

    glShadowAttenuationExt [
	"GL_SHADOW_ATTENUATION_EXT  0x834E"

	<category: 'constants Ext'>
	^33614
    ]

    glTextureApplicationModeExt [
	"GL_TEXTURE_APPLICATION_MODE_EXT  0x834F"

	<category: 'constants Ext'>
	^33615
    ]

    glTextureLightExt [
	"GL_TEXTURE_LIGHT_EXT  0x8350"

	<category: 'constants Ext'>
	^33616
    ]

    glTextureMaterialFaceExt [
	"GL_TEXTURE_MATERIAL_FACE_EXT  0x8351"

	<category: 'constants Ext'>
	^33617
    ]

    glTextureMaterialParameterExt [
	"GL_TEXTURE_MATERIAL_PARAMETER_EXT  0x8352"

	<category: 'constants Ext'>
	^33618
    ]

    glAlphaMinSgix [
	"GL_ALPHA_MIN_SGIX  0x8320"

	<category: 'constants Ext'>
	^33568
    ]

    glAlphaMaxSgix [
	"GL_ALPHA_MAX_SGIX  0x8321"

	<category: 'constants Ext'>
	^33569
    ]

    glPixelTexGenQCeilingSgix [
	"GL_PIXEL_TEX_GEN_Q_CEILING_SGIX  0x8184"

	<category: 'constants Ext'>
	^33156
    ]

    glPixelTexGenQRoundSgix [
	"GL_PIXEL_TEX_GEN_Q_ROUND_SGIX  0x8185"

	<category: 'constants Ext'>
	^33157
    ]

    glPixelTexGenQFloorSgix [
	"GL_PIXEL_TEX_GEN_Q_FLOOR_SGIX  0x8186"

	<category: 'constants Ext'>
	^33158
    ]

    glPixelTexGenAlphaReplaceSgix [
	"GL_PIXEL_TEX_GEN_ALPHA_REPLACE_SGIX  0x8187"

	<category: 'constants Ext'>
	^33159
    ]

    glPixelTexGenAlphaNoReplaceSgix [
	"GL_PIXEL_TEX_GEN_ALPHA_NO_REPLACE_SGIX  0x8188"

	<category: 'constants Ext'>
	^33160
    ]

    glPixelTexGenAlphaLsSgix [
	"GL_PIXEL_TEX_GEN_ALPHA_LS_SGIX  0x8189"

	<category: 'constants Ext'>
	^33161
    ]

    glPixelTexGenAlphaMsSgix [
	"GL_PIXEL_TEX_GEN_ALPHA_MS_SGIX  0x818A"

	<category: 'constants Ext'>
	^33162
    ]

    glBgrExt [
	"GL_BGR_EXT  0x80E0"

	<category: 'constants Ext'>
	^32992
    ]

    glBgraExt [
	"GL_BGRA_EXT  0x80E1"

	<category: 'constants Ext'>
	^32993
    ]

    glAsyncMarkerSgix [
	"GL_ASYNC_MARKER_SGIX  0x8329"

	<category: 'constants Ext'>
	^33577
    ]

    glAsyncTexImageSgix [
	"GL_ASYNC_TEX_IMAGE_SGIX  0x835C"

	<category: 'constants Ext'>
	^33628
    ]

    glAsyncDrawPixelsSgix [
	"GL_ASYNC_DRAW_PIXELS_SGIX  0x835D"

	<category: 'constants Ext'>
	^33629
    ]

    glAsyncReadPixelsSgix [
	"GL_ASYNC_READ_PIXELS_SGIX  0x835E"

	<category: 'constants Ext'>
	^33630
    ]

    glMaxAsyncTexImageSgix [
	"GL_MAX_ASYNC_TEX_IMAGE_SGIX  0x835F"

	<category: 'constants Ext'>
	^33631
    ]

    glMaxAsyncDrawPixelsSgix [
	"GL_MAX_ASYNC_DRAW_PIXELS_SGIX  0x8360"

	<category: 'constants Ext'>
	^33632
    ]

    glMaxAsyncReadPixelsSgix [
	"GL_MAX_ASYNC_READ_PIXELS_SGIX  0x8361"

	<category: 'constants Ext'>
	^33633
    ]

    glAsyncHistogramSgix [
	"GL_ASYNC_HISTOGRAM_SGIX  0x832C"

	<category: 'constants Ext'>
	^33580
    ]

    glMaxAsyncHistogramSgix [
	"GL_MAX_ASYNC_HISTOGRAM_SGIX  0x832D"

	<category: 'constants Ext'>
	^33581
    ]

    glParallelArraysIntel [
	"GL_PARALLEL_ARRAYS_INTEL  0x83F4"

	<category: 'constants Ext'>
	^33780
    ]

    glVertexArrayParallelPointersIntel [
	"GL_VERTEX_ARRAY_PARALLEL_POINTERS_INTEL  0x83F5"

	<category: 'constants Ext'>
	^33781
    ]

    glNormalArrayParallelPointersIntel [
	"GL_NORMAL_ARRAY_PARALLEL_POINTERS_INTEL  0x83F6"

	<category: 'constants Ext'>
	^33782
    ]

    glColorArrayParallelPointersIntel [
	"GL_COLOR_ARRAY_PARALLEL_POINTERS_INTEL  0x83F7"

	<category: 'constants Ext'>
	^33783
    ]

    glTextureCoordArrayParallelPointersIntel [
	"GL_TEXTURE_COORD_ARRAY_PARALLEL_POINTERS_INTEL  0x83F8"

	<category: 'constants Ext'>
	^33784
    ]

    glOcclusionTestHp [
	"GL_OCCLUSION_TEST_HP  0x8165"

	<category: 'constants Ext'>
	^33125
    ]

    glOcclusionTestResultHp [
	"GL_OCCLUSION_TEST_RESULT_HP  0x8166"

	<category: 'constants Ext'>
	^33126
    ]

    glPixelTransform2dExt [
	"GL_PIXEL_TRANSFORM_2D_EXT  0x8330"

	<category: 'constants Ext'>
	^33584
    ]

    glPixelMagFilterExt [
	"GL_PIXEL_MAG_FILTER_EXT  0x8331"

	<category: 'constants Ext'>
	^33585
    ]

    glPixelMinFilterExt [
	"GL_PIXEL_MIN_FILTER_EXT  0x8332"

	<category: 'constants Ext'>
	^33586
    ]

    glPixelCubicWeightExt [
	"GL_PIXEL_CUBIC_WEIGHT_EXT  0x8333"

	<category: 'constants Ext'>
	^33587
    ]

    glCubicExt [
	"GL_CUBIC_EXT  0x8334"

	<category: 'constants Ext'>
	^33588
    ]

    glAverageExt [
	"GL_AVERAGE_EXT  0x8335"

	<category: 'constants Ext'>
	^33589
    ]

    glPixelTransform2dStackDepthExt [
	"GL_PIXEL_TRANSFORM_2D_STACK_DEPTH_EXT  0x8336"

	<category: 'constants Ext'>
	^33590
    ]

    glMaxPixelTransform2dStackDepthExt [
	"GL_MAX_PIXEL_TRANSFORM_2D_STACK_DEPTH_EXT  0x8337"

	<category: 'constants Ext'>
	^33591
    ]

    glPixelTransform2dMatrixExt [
	"GL_PIXEL_TRANSFORM_2D_MATRIX_EXT  0x8338"

	<category: 'constants Ext'>
	^33592
    ]

    glSharedTexturePaletteExt [
	"GL_SHARED_TEXTURE_PALETTE_EXT  0x81FB"

	<category: 'constants Ext'>
	^33275
    ]

    glLightModelColorControlExt [
	"GL_LIGHT_MODEL_COLOR_CONTROL_EXT  0x81F8"

	<category: 'constants Ext'>
	^33272
    ]

    glSingleColorExt [
	"GL_SINGLE_COLOR_EXT  0x81F9"

	<category: 'constants Ext'>
	^33273
    ]

    glSeparateSpecularColorExt [
	"GL_SEPARATE_SPECULAR_COLOR_EXT  0x81FA"

	<category: 'constants Ext'>
	^33274
    ]

    glColorSumExt [
	"GL_COLOR_SUM_EXT  0x8458"

	<category: 'constants Ext'>
	^33880
    ]

    glCurrentSecondaryColorExt [
	"GL_CURRENT_SECONDARY_COLOR_EXT  0x8459"

	<category: 'constants Ext'>
	^33881
    ]

    glSecondaryColorArraySizeExt [
	"GL_SECONDARY_COLOR_ARRAY_SIZE_EXT  0x845A"

	<category: 'constants Ext'>
	^33882
    ]

    glSecondaryColorArrayTypeExt [
	"GL_SECONDARY_COLOR_ARRAY_TYPE_EXT  0x845B"

	<category: 'constants Ext'>
	^33883
    ]

    glSecondaryColorArrayStrideExt [
	"GL_SECONDARY_COLOR_ARRAY_STRIDE_EXT  0x845C"

	<category: 'constants Ext'>
	^33884
    ]

    glSecondaryColorArrayPointerExt [
	"GL_SECONDARY_COLOR_ARRAY_POINTER_EXT  0x845D"

	<category: 'constants Ext'>
	^33885
    ]

    glSecondaryColorArrayExt [
	"GL_SECONDARY_COLOR_ARRAY_EXT  0x845E"

	<category: 'constants Ext'>
	^33886
    ]

    glPerturbExt [
	"GL_PERTURB_EXT  0x85AE"

	<category: 'constants Ext'>
	^34222
    ]

    glTextureNormalExt [
	"GL_TEXTURE_NORMAL_EXT  0x85AF"

	<category: 'constants Ext'>
	^34223
    ]

    glFogCoordinateSourceExt [
	"GL_FOG_COORDINATE_SOURCE_EXT  0x8450"

	<category: 'constants Ext'>
	^33872
    ]

    glFogCoordinateExt [
	"GL_FOG_COORDINATE_EXT  0x8451"

	<category: 'constants Ext'>
	^33873
    ]

    glFragmentDepthExt [
	"GL_FRAGMENT_DEPTH_EXT  0x8452"

	<category: 'constants Ext'>
	^33874
    ]

    glCurrentFogCoordinateExt [
	"GL_CURRENT_FOG_COORDINATE_EXT  0x8453"

	<category: 'constants Ext'>
	^33875
    ]

    glFogCoordinateArrayTypeExt [
	"GL_FOG_COORDINATE_ARRAY_TYPE_EXT  0x8454"

	<category: 'constants Ext'>
	^33876
    ]

    glFogCoordinateArrayStrideExt [
	"GL_FOG_COORDINATE_ARRAY_STRIDE_EXT  0x8455"

	<category: 'constants Ext'>
	^33877
    ]

    glFogCoordinateArrayPointerExt [
	"GL_FOG_COORDINATE_ARRAY_POINTER_EXT  0x8456"

	<category: 'constants Ext'>
	^33878
    ]

    glFogCoordinateArrayExt [
	"GL_FOG_COORDINATE_ARRAY_EXT  0x8457"

	<category: 'constants Ext'>
	^33879
    ]

    glScreenCoordinatesRend [
	"GL_SCREEN_COORDINATES_REND  0x8490"

	<category: 'constants Ext'>
	^33936
    ]

    glInvertedScreenWRend [
	"GL_INVERTED_SCREEN_W_REND  0x8491"

	<category: 'constants Ext'>
	^33937
    ]

    glTangentArrayExt [
	"GL_TANGENT_ARRAY_EXT  0x8439"

	<category: 'constants Ext'>
	^33849
    ]

    glBinormalArrayExt [
	"GL_BINORMAL_ARRAY_EXT  0x843A"

	<category: 'constants Ext'>
	^33850
    ]

    glCurrentTangentExt [
	"GL_CURRENT_TANGENT_EXT  0x843B"

	<category: 'constants Ext'>
	^33851
    ]

    glCurrentBinormalExt [
	"GL_CURRENT_BINORMAL_EXT  0x843C"

	<category: 'constants Ext'>
	^33852
    ]

    glTangentArrayTypeExt [
	"GL_TANGENT_ARRAY_TYPE_EXT  0x843E"

	<category: 'constants Ext'>
	^33854
    ]

    glTangentArrayStrideExt [
	"GL_TANGENT_ARRAY_STRIDE_EXT  0x843F"

	<category: 'constants Ext'>
	^33855
    ]

    glBinormalArrayTypeExt [
	"GL_BINORMAL_ARRAY_TYPE_EXT  0x8440"

	<category: 'constants Ext'>
	^33856
    ]

    glBinormalArrayStrideExt [
	"GL_BINORMAL_ARRAY_STRIDE_EXT  0x8441"

	<category: 'constants Ext'>
	^33857
    ]

    glTangentArrayPointerExt [
	"GL_TANGENT_ARRAY_POINTER_EXT  0x8442"

	<category: 'constants Ext'>
	^33858
    ]

    glBinormalArrayPointerExt [
	"GL_BINORMAL_ARRAY_POINTER_EXT  0x8443"

	<category: 'constants Ext'>
	^33859
    ]

    glMap1TangentExt [
	"GL_MAP1_TANGENT_EXT  0x8444"

	<category: 'constants Ext'>
	^33860
    ]

    glMap2TangentExt [
	"GL_MAP2_TANGENT_EXT  0x8445"

	<category: 'constants Ext'>
	^33861
    ]

    glMap1BinormalExt [
	"GL_MAP1_BINORMAL_EXT  0x8446"

	<category: 'constants Ext'>
	^33862
    ]

    glMap2BinormalExt [
	"GL_MAP2_BINORMAL_EXT  0x8447"

	<category: 'constants Ext'>
	^33863
    ]

    glCombineExt [
	"GL_COMBINE_EXT  0x8570"

	<category: 'constants Ext'>
	^34160
    ]

    glCombineRgbExt [
	"GL_COMBINE_RGB_EXT  0x8571"

	<category: 'constants Ext'>
	^34161
    ]

    glCombineAlphaExt [
	"GL_COMBINE_ALPHA_EXT  0x8572"

	<category: 'constants Ext'>
	^34162
    ]

    glRgbScaleExt [
	"GL_RGB_SCALE_EXT  0x8573"

	<category: 'constants Ext'>
	^34163
    ]

    glAddSignedExt [
	"GL_ADD_SIGNED_EXT  0x8574"

	<category: 'constants Ext'>
	^34164
    ]

    glInterpolateExt [
	"GL_INTERPOLATE_EXT  0x8575"

	<category: 'constants Ext'>
	^34165
    ]

    glConstantExt [
	"GL_CONSTANT_EXT  0x8576"

	<category: 'constants Ext'>
	^34166
    ]

    glPrimaryColorExt [
	"GL_PRIMARY_COLOR_EXT  0x8577"

	<category: 'constants Ext'>
	^34167
    ]

    glPreviousExt [
	"GL_PREVIOUS_EXT  0x8578"

	<category: 'constants Ext'>
	^34168
    ]

    glSource0RgbExt [
	"GL_SOURCE0_RGB_EXT  0x8580"

	<category: 'constants Ext'>
	^34176
    ]

    glSource1RgbExt [
	"GL_SOURCE1_RGB_EXT  0x8581"

	<category: 'constants Ext'>
	^34177
    ]

    glSource2RgbExt [
	"GL_SOURCE2_RGB_EXT  0x8582"

	<category: 'constants Ext'>
	^34178
    ]

    glSource0AlphaExt [
	"GL_SOURCE0_ALPHA_EXT  0x8588"

	<category: 'constants Ext'>
	^34184
    ]

    glSource1AlphaExt [
	"GL_SOURCE1_ALPHA_EXT  0x8589"

	<category: 'constants Ext'>
	^34185
    ]

    glSource2AlphaExt [
	"GL_SOURCE2_ALPHA_EXT  0x858A"

	<category: 'constants Ext'>
	^34186
    ]

    glOperand0RgbExt [
	"GL_OPERAND0_RGB_EXT  0x8590"

	<category: 'constants Ext'>
	^34192
    ]

    glOperand1RgbExt [
	"GL_OPERAND1_RGB_EXT  0x8591"

	<category: 'constants Ext'>
	^34193
    ]

    glOperand2RgbExt [
	"GL_OPERAND2_RGB_EXT  0x8592"

	<category: 'constants Ext'>
	^34194
    ]

    glOperand0AlphaExt [
	"GL_OPERAND0_ALPHA_EXT  0x8598"

	<category: 'constants Ext'>
	^34200
    ]

    glOperand1AlphaExt [
	"GL_OPERAND1_ALPHA_EXT  0x8599"

	<category: 'constants Ext'>
	^34201
    ]

    glOperand2AlphaExt [
	"GL_OPERAND2_ALPHA_EXT  0x859A"

	<category: 'constants Ext'>
	^34202
    ]

    glLightModelSpecularVectorApple [
	"GL_LIGHT_MODEL_SPECULAR_VECTOR_APPLE  0x85B0"

	<category: 'constants Ext'>
	^34224
    ]

    glTransformHintApple [
	"GL_TRANSFORM_HINT_APPLE  0x85B1"

	<category: 'constants Ext'>
	^34225
    ]

    glFogScaleSgix [
	"GL_FOG_SCALE_SGIX  0x81FC"

	<category: 'constants Ext'>
	^33276
    ]

    glFogScaleValueSgix [
	"GL_FOG_SCALE_VALUE_SGIX  0x81FD"

	<category: 'constants Ext'>
	^33277
    ]

    glUnpackConstantDataSunx [
	"GL_UNPACK_CONSTANT_DATA_SUNX  0x81D5"

	<category: 'constants Ext'>
	^33237
    ]

    glTextureConstantDataSunx [
	"GL_TEXTURE_CONSTANT_DATA_SUNX  0x81D6"

	<category: 'constants Ext'>
	^33238
    ]

    glGlobalAlphaSun [
	"GL_GLOBAL_ALPHA_SUN  0x81D9"

	<category: 'constants Ext'>
	^33241
    ]

    glGlobalAlphaFactorSun [
	"GL_GLOBAL_ALPHA_FACTOR_SUN  0x81DA"

	<category: 'constants Ext'>
	^33242
    ]

    glRestartSun [
	"GL_RESTART_SUN  0x0001"

	<category: 'constants Ext'>
	^1
    ]

    glReplaceMiddleSun [
	"GL_REPLACE_MIDDLE_SUN  0x0002"

	<category: 'constants Ext'>
	^2
    ]

    glReplaceOldestSun [
	"GL_REPLACE_OLDEST_SUN  0x0003"

	<category: 'constants Ext'>
	^3
    ]

    glTriangleListSun [
	"GL_TRIANGLE_LIST_SUN  0x81D7"

	<category: 'constants Ext'>
	^33239
    ]

    glReplacementCodeSun [
	"GL_REPLACEMENT_CODE_SUN  0x81D8"

	<category: 'constants Ext'>
	^33240
    ]

    glReplacementCodeArraySun [
	"GL_REPLACEMENT_CODE_ARRAY_SUN  0x85C0"

	<category: 'constants Ext'>
	^34240
    ]

    glReplacementCodeArrayTypeSun [
	"GL_REPLACEMENT_CODE_ARRAY_TYPE_SUN  0x85C1"

	<category: 'constants Ext'>
	^34241
    ]

    glReplacementCodeArrayStrideSun [
	"GL_REPLACEMENT_CODE_ARRAY_STRIDE_SUN  0x85C2"

	<category: 'constants Ext'>
	^34242
    ]

    glReplacementCodeArrayPointerSun [
	"GL_REPLACEMENT_CODE_ARRAY_POINTER_SUN  0x85C3"

	<category: 'constants Ext'>
	^34243
    ]

    glR1uiV3fSun [
	"GL_R1UI_V3F_SUN  0x85C4"

	<category: 'constants Ext'>
	^34244
    ]

    glR1uiC4ubV3fSun [
	"GL_R1UI_C4UB_V3F_SUN  0x85C5"

	<category: 'constants Ext'>
	^34245
    ]

    glR1uiC3fV3fSun [
	"GL_R1UI_C3F_V3F_SUN  0x85C6"

	<category: 'constants Ext'>
	^34246
    ]

    glR1uiN3fV3fSun [
	"GL_R1UI_N3F_V3F_SUN  0x85C7"

	<category: 'constants Ext'>
	^34247
    ]

    glR1uiC4fN3fV3fSun [
	"GL_R1UI_C4F_N3F_V3F_SUN  0x85C8"

	<category: 'constants Ext'>
	^34248
    ]

    glR1uiT2fV3fSun [
	"GL_R1UI_T2F_V3F_SUN  0x85C9"

	<category: 'constants Ext'>
	^34249
    ]

    glR1uiT2fN3fV3fSun [
	"GL_R1UI_T2F_N3F_V3F_SUN  0x85CA"

	<category: 'constants Ext'>
	^34250
    ]

    glR1uiT2fC4fN3fV3fSun [
	"GL_R1UI_T2F_C4F_N3F_V3F_SUN  0x85CB"

	<category: 'constants Ext'>
	^34251
    ]

    glBlendDstRgbExt [
	"GL_BLEND_DST_RGB_EXT  0x80C8"

	<category: 'constants Ext'>
	^32968
    ]

    glBlendSrcRgbExt [
	"GL_BLEND_SRC_RGB_EXT  0x80C9"

	<category: 'constants Ext'>
	^32969
    ]

    glBlendDstAlphaExt [
	"GL_BLEND_DST_ALPHA_EXT  0x80CA"

	<category: 'constants Ext'>
	^32970
    ]

    glBlendSrcAlphaExt [
	"GL_BLEND_SRC_ALPHA_EXT  0x80CB"

	<category: 'constants Ext'>
	^32971
    ]

    glRedMinClampIngr [
	"GL_RED_MIN_CLAMP_INGR  0x8560"

	<category: 'constants Ext'>
	^34144
    ]

    glGreenMinClampIngr [
	"GL_GREEN_MIN_CLAMP_INGR  0x8561"

	<category: 'constants Ext'>
	^34145
    ]

    glBlueMinClampIngr [
	"GL_BLUE_MIN_CLAMP_INGR  0x8562"

	<category: 'constants Ext'>
	^34146
    ]

    glAlphaMinClampIngr [
	"GL_ALPHA_MIN_CLAMP_INGR  0x8563"

	<category: 'constants Ext'>
	^34147
    ]

    glRedMaxClampIngr [
	"GL_RED_MAX_CLAMP_INGR  0x8564"

	<category: 'constants Ext'>
	^34148
    ]

    glGreenMaxClampIngr [
	"GL_GREEN_MAX_CLAMP_INGR  0x8565"

	<category: 'constants Ext'>
	^34149
    ]

    glBlueMaxClampIngr [
	"GL_BLUE_MAX_CLAMP_INGR  0x8566"

	<category: 'constants Ext'>
	^34150
    ]

    glAlphaMaxClampIngr [
	"GL_ALPHA_MAX_CLAMP_INGR  0x8567"

	<category: 'constants Ext'>
	^34151
    ]

    glInterlaceReadIngr [
	"GL_INTERLACE_READ_INGR  0x8568"

	<category: 'constants Ext'>
	^34152
    ]

    glIncrWrapExt [
	"GL_INCR_WRAP_EXT  0x8507"

	<category: 'constants Ext'>
	^34055
    ]

    glDecrWrapExt [
	"GL_DECR_WRAP_EXT  0x8508"

	<category: 'constants Ext'>
	^34056
    ]

    gl422Ext [
	"GL_422_EXT  0x80CC"

	<category: 'constants Ext'>
	^32972
    ]

    gl422RevExt [
	"GL_422_REV_EXT  0x80CD"

	<category: 'constants Ext'>
	^32973
    ]

    gl422AverageExt [
	"GL_422_AVERAGE_EXT  0x80CE"

	<category: 'constants Ext'>
	^32974
    ]

    gl422RevAverageExt [
	"GL_422_REV_AVERAGE_EXT  0x80CF"

	<category: 'constants Ext'>
	^32975
    ]

    glNormalMapNv [
	"GL_NORMAL_MAP_NV  0x8511"

	<category: 'constants Ext'>
	^34065
    ]

    glReflectionMapNv [
	"GL_REFLECTION_MAP_NV  0x8512"

	<category: 'constants Ext'>
	^34066
    ]

    glNormalMapExt [
	"GL_NORMAL_MAP_EXT  0x8511"

	<category: 'constants Ext'>
	^34065
    ]

    glReflectionMapExt [
	"GL_REFLECTION_MAP_EXT  0x8512"

	<category: 'constants Ext'>
	^34066
    ]

    glTextureCubeMapExt [
	"GL_TEXTURE_CUBE_MAP_EXT  0x8513"

	<category: 'constants Ext'>
	^34067
    ]

    glTextureBindingCubeMapExt [
	"GL_TEXTURE_BINDING_CUBE_MAP_EXT  0x8514"

	<category: 'constants Ext'>
	^34068
    ]

    glTextureCubeMapPositiveXExt [
	"GL_TEXTURE_CUBE_MAP_POSITIVE_X_EXT  0x8515"

	<category: 'constants Ext'>
	^34069
    ]

    glTextureCubeMapNegativeXExt [
	"GL_TEXTURE_CUBE_MAP_NEGATIVE_X_EXT  0x8516"

	<category: 'constants Ext'>
	^34070
    ]

    glTextureCubeMapPositiveYExt [
	"GL_TEXTURE_CUBE_MAP_POSITIVE_Y_EXT  0x8517"

	<category: 'constants Ext'>
	^34071
    ]

    glTextureCubeMapNegativeYExt [
	"GL_TEXTURE_CUBE_MAP_NEGATIVE_Y_EXT  0x8518"

	<category: 'constants Ext'>
	^34072
    ]

    glTextureCubeMapPositiveZExt [
	"GL_TEXTURE_CUBE_MAP_POSITIVE_Z_EXT  0x8519"

	<category: 'constants Ext'>
	^34073
    ]

    glTextureCubeMapNegativeZExt [
	"GL_TEXTURE_CUBE_MAP_NEGATIVE_Z_EXT  0x851A"

	<category: 'constants Ext'>
	^34074
    ]

    glProxyTextureCubeMapExt [
	"GL_PROXY_TEXTURE_CUBE_MAP_EXT  0x851B"

	<category: 'constants Ext'>
	^34075
    ]

    glMaxCubeMapTextureSizeExt [
	"GL_MAX_CUBE_MAP_TEXTURE_SIZE_EXT  0x851C"

	<category: 'constants Ext'>
	^34076
    ]

    glWrapBorderSun [
	"GL_WRAP_BORDER_SUN  0x81D4"

	<category: 'constants Ext'>
	^33236
    ]

    glMaxTextureLodBiasExt [
	"GL_MAX_TEXTURE_LOD_BIAS_EXT  0x84FD"

	<category: 'constants Ext'>
	^34045
    ]

    glTextureFilterControlExt [
	"GL_TEXTURE_FILTER_CONTROL_EXT  0x8500"

	<category: 'constants Ext'>
	^34048
    ]

    glTextureLodBiasExt [
	"GL_TEXTURE_LOD_BIAS_EXT  0x8501"

	<category: 'constants Ext'>
	^34049
    ]

    glTextureMaxAnisotropyExt [
	"GL_TEXTURE_MAX_ANISOTROPY_EXT  0x84FE"

	<category: 'constants Ext'>
	^34046
    ]

    glMaxTextureMaxAnisotropyExt [
	"GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT  0x84FF"

	<category: 'constants Ext'>
	^34047
    ]

    glModelview0StackDepthExt [
	"GL_MODELVIEW0_STACK_DEPTH_EXT  GL_MODELVIEW_STACK_DEPTH"

	<category: 'constants Ext'>
	^1.4400139e + 19
    ]

    glModelview1StackDepthExt [
	"GL_MODELVIEW1_STACK_DEPTH_EXT  0x8502"

	<category: 'constants Ext'>
	^34050
    ]

    glModelview0MatrixExt [
	"GL_MODELVIEW0_MATRIX_EXT  GL_MODELVIEW_MATRIX"

	<category: 'constants Ext'>
	^144001400100000
    ]

    glModelview1MatrixExt [
	"GL_MODELVIEW1_MATRIX_EXT  0x8506"

	<category: 'constants Ext'>
	^34054
    ]

    glVertexWeightingExt [
	"GL_VERTEX_WEIGHTING_EXT  0x8509"

	<category: 'constants Ext'>
	^34057
    ]

    glModelview0Ext [
	"GL_MODELVIEW0_EXT  GL_MODELVIEW"

	<category: 'constants Ext'>
	^14400140
    ]

    glModelview1Ext [
	"GL_MODELVIEW1_EXT  0x850A"

	<category: 'constants Ext'>
	^34058
    ]

    glCurrentVertexWeightExt [
	"GL_CURRENT_VERTEX_WEIGHT_EXT  0x850B"

	<category: 'constants Ext'>
	^34059
    ]

    glVertexWeightArrayExt [
	"GL_VERTEX_WEIGHT_ARRAY_EXT  0x850C"

	<category: 'constants Ext'>
	^34060
    ]

    glVertexWeightArraySizeExt [
	"GL_VERTEX_WEIGHT_ARRAY_SIZE_EXT  0x850D"

	<category: 'constants Ext'>
	^34061
    ]

    glVertexWeightArrayTypeExt [
	"GL_VERTEX_WEIGHT_ARRAY_TYPE_EXT  0x850E"

	<category: 'constants Ext'>
	^34062
    ]

    glVertexWeightArrayStrideExt [
	"GL_VERTEX_WEIGHT_ARRAY_STRIDE_EXT  0x850F"

	<category: 'constants Ext'>
	^34063
    ]

    glVertexWeightArrayPointerExt [
	"GL_VERTEX_WEIGHT_ARRAY_POINTER_EXT  0x8510"

	<category: 'constants Ext'>
	^34064
    ]

    glMaxShininessNv [
	"GL_MAX_SHININESS_NV  0x8504"

	<category: 'constants Ext'>
	^34052
    ]

    glMaxSpotExponentNv [
	"GL_MAX_SPOT_EXPONENT_NV  0x8505"

	<category: 'constants Ext'>
	^34053
    ]

    glVertexArrayRangeNv [
	"GL_VERTEX_ARRAY_RANGE_NV  0x851D"

	<category: 'constants Ext'>
	^34077
    ]

    glVertexArrayRangeLengthNv [
	"GL_VERTEX_ARRAY_RANGE_LENGTH_NV  0x851E"

	<category: 'constants Ext'>
	^34078
    ]

    glVertexArrayRangeValidNv [
	"GL_VERTEX_ARRAY_RANGE_VALID_NV  0x851F"

	<category: 'constants Ext'>
	^34079
    ]

    glMaxVertexArrayRangeElementNv [
	"GL_MAX_VERTEX_ARRAY_RANGE_ELEMENT_NV  0x8520"

	<category: 'constants Ext'>
	^34080
    ]

    glVertexArrayRangePointerNv [
	"GL_VERTEX_ARRAY_RANGE_POINTER_NV  0x8521"

	<category: 'constants Ext'>
	^34081
    ]

    glRegisterCombinersNv [
	"GL_REGISTER_COMBINERS_NV  0x8522"

	<category: 'constants Ext'>
	^34082
    ]

    glVariableANv [
	"GL_VARIABLE_A_NV  0x8523"

	<category: 'constants Ext'>
	^34083
    ]

    glVariableBNv [
	"GL_VARIABLE_B_NV  0x8524"

	<category: 'constants Ext'>
	^34084
    ]

    glVariableCNv [
	"GL_VARIABLE_C_NV  0x8525"

	<category: 'constants Ext'>
	^34085
    ]

    glVariableDNv [
	"GL_VARIABLE_D_NV  0x8526"

	<category: 'constants Ext'>
	^34086
    ]

    glVariableENv [
	"GL_VARIABLE_E_NV  0x8527"

	<category: 'constants Ext'>
	^34087
    ]

    glVariableFNv [
	"GL_VARIABLE_F_NV  0x8528"

	<category: 'constants Ext'>
	^34088
    ]

    glVariableGNv [
	"GL_VARIABLE_G_NV  0x8529"

	<category: 'constants Ext'>
	^34089
    ]

    glConstantColor0Nv [
	"GL_CONSTANT_COLOR0_NV  0x852A"

	<category: 'constants Ext'>
	^34090
    ]

    glConstantColor1Nv [
	"GL_CONSTANT_COLOR1_NV  0x852B"

	<category: 'constants Ext'>
	^34091
    ]

    glPrimaryColorNv [
	"GL_PRIMARY_COLOR_NV  0x852C"

	<category: 'constants Ext'>
	^34092
    ]

    glSecondaryColorNv [
	"GL_SECONDARY_COLOR_NV  0x852D"

	<category: 'constants Ext'>
	^34093
    ]

    glSpare0Nv [
	"GL_SPARE0_NV  0x852E"

	<category: 'constants Ext'>
	^34094
    ]

    glSpare1Nv [
	"GL_SPARE1_NV  0x852F"

	<category: 'constants Ext'>
	^34095
    ]

    glDiscardNv [
	"GL_DISCARD_NV  0x8530"

	<category: 'constants Ext'>
	^34096
    ]

    glETimesFNv [
	"GL_E_TIMES_F_NV  0x8531"

	<category: 'constants Ext'>
	^34097
    ]

    glSpare0PlusSecondaryColorNv [
	"GL_SPARE0_PLUS_SECONDARY_COLOR_NV  0x8532"

	<category: 'constants Ext'>
	^34098
    ]

    glUnsignedIdentityNv [
	"GL_UNSIGNED_IDENTITY_NV  0x8536"

	<category: 'constants Ext'>
	^34102
    ]

    glUnsignedInvertNv [
	"GL_UNSIGNED_INVERT_NV  0x8537"

	<category: 'constants Ext'>
	^34103
    ]

    glExpandNormalNv [
	"GL_EXPAND_NORMAL_NV  0x8538"

	<category: 'constants Ext'>
	^34104
    ]

    glExpandNegateNv [
	"GL_EXPAND_NEGATE_NV  0x8539"

	<category: 'constants Ext'>
	^34105
    ]

    glHalfBiasNormalNv [
	"GL_HALF_BIAS_NORMAL_NV  0x853A"

	<category: 'constants Ext'>
	^34106
    ]

    glHalfBiasNegateNv [
	"GL_HALF_BIAS_NEGATE_NV  0x853B"

	<category: 'constants Ext'>
	^34107
    ]

    glSignedIdentityNv [
	"GL_SIGNED_IDENTITY_NV  0x853C"

	<category: 'constants Ext'>
	^34108
    ]

    glSignedNegateNv [
	"GL_SIGNED_NEGATE_NV  0x853D"

	<category: 'constants Ext'>
	^34109
    ]

    glScaleByTwoNv [
	"GL_SCALE_BY_TWO_NV  0x853E"

	<category: 'constants Ext'>
	^34110
    ]

    glScaleByFourNv [
	"GL_SCALE_BY_FOUR_NV  0x853F"

	<category: 'constants Ext'>
	^34111
    ]

    glScaleByOneHalfNv [
	"GL_SCALE_BY_ONE_HALF_NV  0x8540"

	<category: 'constants Ext'>
	^34112
    ]

    glBiasByNegativeOneHalfNv [
	"GL_BIAS_BY_NEGATIVE_ONE_HALF_NV  0x8541"

	<category: 'constants Ext'>
	^34113
    ]

    glCombinerInputNv [
	"GL_COMBINER_INPUT_NV  0x8542"

	<category: 'constants Ext'>
	^34114
    ]

    glCombinerMappingNv [
	"GL_COMBINER_MAPPING_NV  0x8543"

	<category: 'constants Ext'>
	^34115
    ]

    glCombinerComponentUsageNv [
	"GL_COMBINER_COMPONENT_USAGE_NV  0x8544"

	<category: 'constants Ext'>
	^34116
    ]

    glCombinerAbDotProductNv [
	"GL_COMBINER_AB_DOT_PRODUCT_NV  0x8545"

	<category: 'constants Ext'>
	^34117
    ]

    glCombinerCdDotProductNv [
	"GL_COMBINER_CD_DOT_PRODUCT_NV  0x8546"

	<category: 'constants Ext'>
	^34118
    ]

    glCombinerMuxSumNv [
	"GL_COMBINER_MUX_SUM_NV  0x8547"

	<category: 'constants Ext'>
	^34119
    ]

    glCombinerScaleNv [
	"GL_COMBINER_SCALE_NV  0x8548"

	<category: 'constants Ext'>
	^34120
    ]

    glCombinerBiasNv [
	"GL_COMBINER_BIAS_NV  0x8549"

	<category: 'constants Ext'>
	^34121
    ]

    glCombinerAbOutputNv [
	"GL_COMBINER_AB_OUTPUT_NV  0x854A"

	<category: 'constants Ext'>
	^34122
    ]

    glCombinerCdOutputNv [
	"GL_COMBINER_CD_OUTPUT_NV  0x854B"

	<category: 'constants Ext'>
	^34123
    ]

    glCombinerSumOutputNv [
	"GL_COMBINER_SUM_OUTPUT_NV  0x854C"

	<category: 'constants Ext'>
	^34124
    ]

    glMaxGeneralCombinersNv [
	"GL_MAX_GENERAL_COMBINERS_NV  0x854D"

	<category: 'constants Ext'>
	^34125
    ]

    glNumGeneralCombinersNv [
	"GL_NUM_GENERAL_COMBINERS_NV  0x854E"

	<category: 'constants Ext'>
	^34126
    ]

    glColorSumClampNv [
	"GL_COLOR_SUM_CLAMP_NV  0x854F"

	<category: 'constants Ext'>
	^34127
    ]

    glCombiner0Nv [
	"GL_COMBINER0_NV  0x8550"

	<category: 'constants Ext'>
	^34128
    ]

    glCombiner1Nv [
	"GL_COMBINER1_NV  0x8551"

	<category: 'constants Ext'>
	^34129
    ]

    glCombiner2Nv [
	"GL_COMBINER2_NV  0x8552"

	<category: 'constants Ext'>
	^34130
    ]

    glCombiner3Nv [
	"GL_COMBINER3_NV  0x8553"

	<category: 'constants Ext'>
	^34131
    ]

    glCombiner4Nv [
	"GL_COMBINER4_NV  0x8554"

	<category: 'constants Ext'>
	^34132
    ]

    glCombiner5Nv [
	"GL_COMBINER5_NV  0x8555"

	<category: 'constants Ext'>
	^34133
    ]

    glCombiner6Nv [
	"GL_COMBINER6_NV  0x8556"

	<category: 'constants Ext'>
	^34134
    ]

    glCombiner7Nv [
	"GL_COMBINER7_NV  0x8557"

	<category: 'constants Ext'>
	^34135
    ]

    glFogDistanceModeNv [
	"GL_FOG_DISTANCE_MODE_NV  0x855A"

	<category: 'constants Ext'>
	^34138
    ]

    glEyeRadialNv [
	"GL_EYE_RADIAL_NV  0x855B"

	<category: 'constants Ext'>
	^34139
    ]

    glEyePlaneAbsoluteNv [
	"GL_EYE_PLANE_ABSOLUTE_NV  0x855C"

	<category: 'constants Ext'>
	^34140
    ]

    glEmbossLightNv [
	"GL_EMBOSS_LIGHT_NV  0x855D"

	<category: 'constants Ext'>
	^34141
    ]

    glEmbossConstantNv [
	"GL_EMBOSS_CONSTANT_NV  0x855E"

	<category: 'constants Ext'>
	^34142
    ]

    glEmbossMapNv [
	"GL_EMBOSS_MAP_NV  0x855F"

	<category: 'constants Ext'>
	^34143
    ]

    glCombine4Nv [
	"GL_COMBINE4_NV  0x8503"

	<category: 'constants Ext'>
	^34051
    ]

    glSource3RgbNv [
	"GL_SOURCE3_RGB_NV  0x8583"

	<category: 'constants Ext'>
	^34179
    ]

    glSource3AlphaNv [
	"GL_SOURCE3_ALPHA_NV  0x858B"

	<category: 'constants Ext'>
	^34187
    ]

    glOperand3RgbNv [
	"GL_OPERAND3_RGB_NV  0x8593"

	<category: 'constants Ext'>
	^34195
    ]

    glOperand3AlphaNv [
	"GL_OPERAND3_ALPHA_NV  0x859B"

	<category: 'constants Ext'>
	^34203
    ]

    glCompressedRgbS3tcDxt1Ext [
	"GL_COMPRESSED_RGB_S3TC_DXT1_EXT  0x83F0"

	<category: 'constants Ext'>
	^33776
    ]

    glCompressedRgbaS3tcDxt1Ext [
	"GL_COMPRESSED_RGBA_S3TC_DXT1_EXT  0x83F1"

	<category: 'constants Ext'>
	^33777
    ]

    glCompressedRgbaS3tcDxt3Ext [
	"GL_COMPRESSED_RGBA_S3TC_DXT3_EXT  0x83F2"

	<category: 'constants Ext'>
	^33778
    ]

    glCompressedRgbaS3tcDxt5Ext [
	"GL_COMPRESSED_RGBA_S3TC_DXT5_EXT  0x83F3"

	<category: 'constants Ext'>
	^33779
    ]

    glCullVertexIbm [
	"GL_CULL_VERTEX_IBM  103050"

	<category: 'constants Ext'>
	^103050
    ]

    glVertexArrayListIbm [
	"GL_VERTEX_ARRAY_LIST_IBM  103070"

	<category: 'constants Ext'>
	^103070
    ]

    glNormalArrayListIbm [
	"GL_NORMAL_ARRAY_LIST_IBM  103071"

	<category: 'constants Ext'>
	^103071
    ]

    glColorArrayListIbm [
	"GL_COLOR_ARRAY_LIST_IBM  103072"

	<category: 'constants Ext'>
	^103072
    ]

    glIndexArrayListIbm [
	"GL_INDEX_ARRAY_LIST_IBM  103073"

	<category: 'constants Ext'>
	^103073
    ]

    glTextureCoordArrayListIbm [
	"GL_TEXTURE_COORD_ARRAY_LIST_IBM  103074"

	<category: 'constants Ext'>
	^103074
    ]

    glEdgeFlagArrayListIbm [
	"GL_EDGE_FLAG_ARRAY_LIST_IBM  103075"

	<category: 'constants Ext'>
	^103075
    ]

    glFogCoordinateArrayListIbm [
	"GL_FOG_COORDINATE_ARRAY_LIST_IBM  103076"

	<category: 'constants Ext'>
	^103076
    ]

    glSecondaryColorArrayListIbm [
	"GL_SECONDARY_COLOR_ARRAY_LIST_IBM  103077"

	<category: 'constants Ext'>
	^103077
    ]

    glVertexArrayListStrideIbm [
	"GL_VERTEX_ARRAY_LIST_STRIDE_IBM  103080"

	<category: 'constants Ext'>
	^103080
    ]

    glNormalArrayListStrideIbm [
	"GL_NORMAL_ARRAY_LIST_STRIDE_IBM  103081"

	<category: 'constants Ext'>
	^103081
    ]

    glColorArrayListStrideIbm [
	"GL_COLOR_ARRAY_LIST_STRIDE_IBM  103082"

	<category: 'constants Ext'>
	^103082
    ]

    glIndexArrayListStrideIbm [
	"GL_INDEX_ARRAY_LIST_STRIDE_IBM  103083"

	<category: 'constants Ext'>
	^103083
    ]

    glTextureCoordArrayListStrideIbm [
	"GL_TEXTURE_COORD_ARRAY_LIST_STRIDE_IBM  103084"

	<category: 'constants Ext'>
	^103084
    ]

    glEdgeFlagArrayListStrideIbm [
	"GL_EDGE_FLAG_ARRAY_LIST_STRIDE_IBM  103085"

	<category: 'constants Ext'>
	^103085
    ]

    glFogCoordinateArrayListStrideIbm [
	"GL_FOG_COORDINATE_ARRAY_LIST_STRIDE_IBM  103086"

	<category: 'constants Ext'>
	^103086
    ]

    glSecondaryColorArrayListStrideIbm [
	"GL_SECONDARY_COLOR_ARRAY_LIST_STRIDE_IBM  103087"

	<category: 'constants Ext'>
	^103087
    ]

    glPackSubsampleRateSgix [
	"GL_PACK_SUBSAMPLE_RATE_SGIX  0x85A0"

	<category: 'constants Ext'>
	^34208
    ]

    glUnpackSubsampleRateSgix [
	"GL_UNPACK_SUBSAMPLE_RATE_SGIX  0x85A1"

	<category: 'constants Ext'>
	^34209
    ]

    glPixelSubsample4444Sgix [
	"GL_PIXEL_SUBSAMPLE_4444_SGIX  0x85A2"

	<category: 'constants Ext'>
	^34210
    ]

    glPixelSubsample2424Sgix [
	"GL_PIXEL_SUBSAMPLE_2424_SGIX  0x85A3"

	<category: 'constants Ext'>
	^34211
    ]

    glPixelSubsample4242Sgix [
	"GL_PIXEL_SUBSAMPLE_4242_SGIX  0x85A4"

	<category: 'constants Ext'>
	^34212
    ]

    glYcrcbSgix [
	"GL_YCRCB_SGIX  0x8318"

	<category: 'constants Ext'>
	^33560
    ]

    glYcrcbaSgix [
	"GL_YCRCBA_SGIX  0x8319"

	<category: 'constants Ext'>
	^33561
    ]

    glDepthPassInstrumentSgix [
	"GL_DEPTH_PASS_INSTRUMENT_SGIX  0x8310"

	<category: 'constants Ext'>
	^33552
    ]

    glDepthPassInstrumentCountersSgix [
	"GL_DEPTH_PASS_INSTRUMENT_COUNTERS_SGIX  0x8311"

	<category: 'constants Ext'>
	^33553
    ]

    glDepthPassInstrumentMaxSgix [
	"GL_DEPTH_PASS_INSTRUMENT_MAX_SGIX  0x8312"

	<category: 'constants Ext'>
	^33554
    ]

    glCompressedRgbFxt13dfx [
	"GL_COMPRESSED_RGB_FXT1_3DFX  0x86B0"

	<category: 'constants Ext'>
	^34480
    ]

    glCompressedRgbaFxt13dfx [
	"GL_COMPRESSED_RGBA_FXT1_3DFX  0x86B1"

	<category: 'constants Ext'>
	^34481
    ]

    glMultisample3dfx [
	"GL_MULTISAMPLE_3DFX  0x86B2"

	<category: 'constants Ext'>
	^34482
    ]

    glSampleBuffers3dfx [
	"GL_SAMPLE_BUFFERS_3DFX  0x86B3"

	<category: 'constants Ext'>
	^34483
    ]

    glSamples3dfx [
	"GL_SAMPLES_3DFX  0x86B4"

	<category: 'constants Ext'>
	^34484
    ]

    glMultisampleBit3dfx [
	"GL_MULTISAMPLE_BIT_3DFX  0x20000000"

	<category: 'constants Ext'>
	^536870912
    ]

    glMultisampleExt [
	"GL_MULTISAMPLE_EXT  0x809D"

	<category: 'constants Ext'>
	^32925
    ]

    glSampleAlphaToMaskExt [
	"GL_SAMPLE_ALPHA_TO_MASK_EXT  0x809E"

	<category: 'constants Ext'>
	^32926
    ]

    glSampleAlphaToOneExt [
	"GL_SAMPLE_ALPHA_TO_ONE_EXT  0x809F"

	<category: 'constants Ext'>
	^32927
    ]

    glSampleMaskExt [
	"GL_SAMPLE_MASK_EXT  0x80A0"

	<category: 'constants Ext'>
	^32928
    ]

    gl1passExt [
	"GL_1PASS_EXT  0x80A1"

	<category: 'constants Ext'>
	^32929
    ]

    gl2pass0Ext [
	"GL_2PASS_0_EXT  0x80A2"

	<category: 'constants Ext'>
	^32930
    ]

    gl2pass1Ext [
	"GL_2PASS_1_EXT  0x80A3"

	<category: 'constants Ext'>
	^32931
    ]

    gl4pass0Ext [
	"GL_4PASS_0_EXT  0x80A4"

	<category: 'constants Ext'>
	^32932
    ]

    gl4pass1Ext [
	"GL_4PASS_1_EXT  0x80A5"

	<category: 'constants Ext'>
	^32933
    ]

    gl4pass2Ext [
	"GL_4PASS_2_EXT  0x80A6"

	<category: 'constants Ext'>
	^32934
    ]

    gl4pass3Ext [
	"GL_4PASS_3_EXT  0x80A7"

	<category: 'constants Ext'>
	^32935
    ]

    glSampleBuffersExt [
	"GL_SAMPLE_BUFFERS_EXT  0x80A8"

	<category: 'constants Ext'>
	^32936
    ]

    glSamplesExt [
	"GL_SAMPLES_EXT  0x80A9"

	<category: 'constants Ext'>
	^32937
    ]

    glSampleMaskValueExt [
	"GL_SAMPLE_MASK_VALUE_EXT  0x80AA"

	<category: 'constants Ext'>
	^32938
    ]

    glSampleMaskInvertExt [
	"GL_SAMPLE_MASK_INVERT_EXT  0x80AB"

	<category: 'constants Ext'>
	^32939
    ]

    glSamplePatternExt [
	"GL_SAMPLE_PATTERN_EXT  0x80AC"

	<category: 'constants Ext'>
	^32940
    ]

    glMultisampleBitExt [
	"GL_MULTISAMPLE_BIT_EXT  0x20000000"

	<category: 'constants Ext'>
	^536870912
    ]

    glVertexPreclipSgix [
	"GL_VERTEX_PRECLIP_SGIX  0x83EE"

	<category: 'constants Ext'>
	^33774
    ]

    glVertexPreclipHintSgix [
	"GL_VERTEX_PRECLIP_HINT_SGIX  0x83EF"

	<category: 'constants Ext'>
	^33775
    ]

    glConvolutionHintSgix [
	"GL_CONVOLUTION_HINT_SGIX  0x8316"

	<category: 'constants Ext'>
	^33558
    ]

    glPackResampleSgix [
	"GL_PACK_RESAMPLE_SGIX  0x842C"

	<category: 'constants Ext'>
	^33836
    ]

    glUnpackResampleSgix [
	"GL_UNPACK_RESAMPLE_SGIX  0x842D"

	<category: 'constants Ext'>
	^33837
    ]

    glResampleReplicateSgix [
	"GL_RESAMPLE_REPLICATE_SGIX  0x842E"

	<category: 'constants Ext'>
	^33838
    ]

    glResampleZeroFillSgix [
	"GL_RESAMPLE_ZERO_FILL_SGIX  0x842F"

	<category: 'constants Ext'>
	^33839
    ]

    glResampleDecimateSgix [
	"GL_RESAMPLE_DECIMATE_SGIX  0x8430"

	<category: 'constants Ext'>
	^33840
    ]

    glEyeDistanceToPointSgis [
	"GL_EYE_DISTANCE_TO_POINT_SGIS  0x81F0"

	<category: 'constants Ext'>
	^33264
    ]

    glObjectDistanceToPointSgis [
	"GL_OBJECT_DISTANCE_TO_POINT_SGIS  0x81F1"

	<category: 'constants Ext'>
	^33265
    ]

    glEyeDistanceToLineSgis [
	"GL_EYE_DISTANCE_TO_LINE_SGIS  0x81F2"

	<category: 'constants Ext'>
	^33266
    ]

    glObjectDistanceToLineSgis [
	"GL_OBJECT_DISTANCE_TO_LINE_SGIS  0x81F3"

	<category: 'constants Ext'>
	^33267
    ]

    glEyePointSgis [
	"GL_EYE_POINT_SGIS  0x81F4"

	<category: 'constants Ext'>
	^33268
    ]

    glObjectPointSgis [
	"GL_OBJECT_POINT_SGIS  0x81F5"

	<category: 'constants Ext'>
	^33269
    ]

    glEyeLineSgis [
	"GL_EYE_LINE_SGIS  0x81F6"

	<category: 'constants Ext'>
	^33270
    ]

    glObjectLineSgis [
	"GL_OBJECT_LINE_SGIS  0x81F7"

	<category: 'constants Ext'>
	^33271
    ]

    glTextureColorWritemaskSgis [
	"GL_TEXTURE_COLOR_WRITEMASK_SGIS  0x81EF"

	<category: 'constants Ext'>
	^33263
    ]

    glDot3RgbExt [
	"GL_DOT3_RGB_EXT  0x8740"

	<category: 'constants Ext'>
	^34624
    ]

    glDot3RgbaExt [
	"GL_DOT3_RGBA_EXT  0x8741"

	<category: 'constants Ext'>
	^34625
    ]

    glMirrorClampAti [
	"GL_MIRROR_CLAMP_ATI  0x8742"

	<category: 'constants Ext'>
	^34626
    ]

    glMirrorClampToEdgeAti [
	"GL_MIRROR_CLAMP_TO_EDGE_ATI  0x8743"

	<category: 'constants Ext'>
	^34627
    ]

    glAllCompletedNv [
	"GL_ALL_COMPLETED_NV  0x84F2"

	<category: 'constants Ext'>
	^34034
    ]

    glFenceStatusNv [
	"GL_FENCE_STATUS_NV  0x84F3"

	<category: 'constants Ext'>
	^34035
    ]

    glFenceConditionNv [
	"GL_FENCE_CONDITION_NV  0x84F4"

	<category: 'constants Ext'>
	^34036
    ]

    glMirroredRepeatIbm [
	"GL_MIRRORED_REPEAT_IBM  0x8370"

	<category: 'constants Ext'>
	^33648
    ]

    glEval2dNv [
	"GL_EVAL_2D_NV  0x86C0"

	<category: 'constants Ext'>
	^34496
    ]

    glEvalTriangular2dNv [
	"GL_EVAL_TRIANGULAR_2D_NV  0x86C1"

	<category: 'constants Ext'>
	^34497
    ]

    glMapTessellationNv [
	"GL_MAP_TESSELLATION_NV  0x86C2"

	<category: 'constants Ext'>
	^34498
    ]

    glMapAttribUOrderNv [
	"GL_MAP_ATTRIB_U_ORDER_NV  0x86C3"

	<category: 'constants Ext'>
	^34499
    ]

    glMapAttribVOrderNv [
	"GL_MAP_ATTRIB_V_ORDER_NV  0x86C4"

	<category: 'constants Ext'>
	^34500
    ]

    glEvalFractionalTessellationNv [
	"GL_EVAL_FRACTIONAL_TESSELLATION_NV  0x86C5"

	<category: 'constants Ext'>
	^34501
    ]

    glEvalVertexAttrib0Nv [
	"GL_EVAL_VERTEX_ATTRIB0_NV  0x86C6"

	<category: 'constants Ext'>
	^34502
    ]

    glEvalVertexAttrib1Nv [
	"GL_EVAL_VERTEX_ATTRIB1_NV  0x86C7"

	<category: 'constants Ext'>
	^34503
    ]

    glEvalVertexAttrib2Nv [
	"GL_EVAL_VERTEX_ATTRIB2_NV  0x86C8"

	<category: 'constants Ext'>
	^34504
    ]

    glEvalVertexAttrib3Nv [
	"GL_EVAL_VERTEX_ATTRIB3_NV  0x86C9"

	<category: 'constants Ext'>
	^34505
    ]

    glEvalVertexAttrib4Nv [
	"GL_EVAL_VERTEX_ATTRIB4_NV  0x86CA"

	<category: 'constants Ext'>
	^34506
    ]

    glEvalVertexAttrib5Nv [
	"GL_EVAL_VERTEX_ATTRIB5_NV  0x86CB"

	<category: 'constants Ext'>
	^34507
    ]

    glEvalVertexAttrib6Nv [
	"GL_EVAL_VERTEX_ATTRIB6_NV  0x86CC"

	<category: 'constants Ext'>
	^34508
    ]

    glEvalVertexAttrib7Nv [
	"GL_EVAL_VERTEX_ATTRIB7_NV  0x86CD"

	<category: 'constants Ext'>
	^34509
    ]

    glEvalVertexAttrib8Nv [
	"GL_EVAL_VERTEX_ATTRIB8_NV  0x86CE"

	<category: 'constants Ext'>
	^34510
    ]

    glEvalVertexAttrib9Nv [
	"GL_EVAL_VERTEX_ATTRIB9_NV  0x86CF"

	<category: 'constants Ext'>
	^34511
    ]

    glEvalVertexAttrib10Nv [
	"GL_EVAL_VERTEX_ATTRIB10_NV  0x86D0"

	<category: 'constants Ext'>
	^34512
    ]

    glEvalVertexAttrib11Nv [
	"GL_EVAL_VERTEX_ATTRIB11_NV  0x86D1"

	<category: 'constants Ext'>
	^34513
    ]

    glEvalVertexAttrib12Nv [
	"GL_EVAL_VERTEX_ATTRIB12_NV  0x86D2"

	<category: 'constants Ext'>
	^34514
    ]

    glEvalVertexAttrib13Nv [
	"GL_EVAL_VERTEX_ATTRIB13_NV  0x86D3"

	<category: 'constants Ext'>
	^34515
    ]

    glEvalVertexAttrib14Nv [
	"GL_EVAL_VERTEX_ATTRIB14_NV  0x86D4"

	<category: 'constants Ext'>
	^34516
    ]

    glEvalVertexAttrib15Nv [
	"GL_EVAL_VERTEX_ATTRIB15_NV  0x86D5"

	<category: 'constants Ext'>
	^34517
    ]

    glMaxMapTessellationNv [
	"GL_MAX_MAP_TESSELLATION_NV  0x86D6"

	<category: 'constants Ext'>
	^34518
    ]

    glMaxRationalEvalOrderNv [
	"GL_MAX_RATIONAL_EVAL_ORDER_NV  0x86D7"

	<category: 'constants Ext'>
	^34519
    ]

    glDepthStencilNv [
	"GL_DEPTH_STENCIL_NV  0x84F9"

	<category: 'constants Ext'>
	^34041
    ]

    glUnsignedInt248Nv [
	"GL_UNSIGNED_INT_24_8_NV  0x84FA"

	<category: 'constants Ext'>
	^34042
    ]

    glPerStageConstantsNv [
	"GL_PER_STAGE_CONSTANTS_NV  0x8535"

	<category: 'constants Ext'>
	^34101
    ]

    glTextureRectangleNv [
	"GL_TEXTURE_RECTANGLE_NV  0x84F5"

	<category: 'constants Ext'>
	^34037
    ]

    glTextureBindingRectangleNv [
	"GL_TEXTURE_BINDING_RECTANGLE_NV  0x84F6"

	<category: 'constants Ext'>
	^34038
    ]

    glProxyTextureRectangleNv [
	"GL_PROXY_TEXTURE_RECTANGLE_NV  0x84F7"

	<category: 'constants Ext'>
	^34039
    ]

    glMaxRectangleTextureSizeNv [
	"GL_MAX_RECTANGLE_TEXTURE_SIZE_NV  0x84F8"

	<category: 'constants Ext'>
	^34040
    ]

    glOffsetTextureRectangleNv [
	"GL_OFFSET_TEXTURE_RECTANGLE_NV  0x864C"

	<category: 'constants Ext'>
	^34380
    ]

    glOffsetTextureRectangleScaleNv [
	"GL_OFFSET_TEXTURE_RECTANGLE_SCALE_NV  0x864D"

	<category: 'constants Ext'>
	^34381
    ]

    glDotProductTextureRectangleNv [
	"GL_DOT_PRODUCT_TEXTURE_RECTANGLE_NV  0x864E"

	<category: 'constants Ext'>
	^34382
    ]

    glRgbaUnsignedDotProductMappingNv [
	"GL_RGBA_UNSIGNED_DOT_PRODUCT_MAPPING_NV  0x86D9"

	<category: 'constants Ext'>
	^34521
    ]

    glUnsignedIntS8S888Nv [
	"GL_UNSIGNED_INT_S8_S8_8_8_NV  0x86DA"

	<category: 'constants Ext'>
	^34522
    ]

    glUnsignedInt88S8S8RevNv [
	"GL_UNSIGNED_INT_8_8_S8_S8_REV_NV  0x86DB"

	<category: 'constants Ext'>
	^34523
    ]

    glDsdtMagIntensityNv [
	"GL_DSDT_MAG_INTENSITY_NV  0x86DC"

	<category: 'constants Ext'>
	^34524
    ]

    glShaderConsistentNv [
	"GL_SHADER_CONSISTENT_NV  0x86DD"

	<category: 'constants Ext'>
	^34525
    ]

    glTextureShaderNv [
	"GL_TEXTURE_SHADER_NV  0x86DE"

	<category: 'constants Ext'>
	^34526
    ]

    glShaderOperationNv [
	"GL_SHADER_OPERATION_NV  0x86DF"

	<category: 'constants Ext'>
	^34527
    ]

    glCullModesNv [
	"GL_CULL_MODES_NV  0x86E0"

	<category: 'constants Ext'>
	^34528
    ]

    glOffsetTextureMatrixNv [
	"GL_OFFSET_TEXTURE_MATRIX_NV  0x86E1"

	<category: 'constants Ext'>
	^34529
    ]

    glOffsetTextureScaleNv [
	"GL_OFFSET_TEXTURE_SCALE_NV  0x86E2"

	<category: 'constants Ext'>
	^34530
    ]

    glOffsetTextureBiasNv [
	"GL_OFFSET_TEXTURE_BIAS_NV  0x86E3"

	<category: 'constants Ext'>
	^34531
    ]

    glOffsetTexture2dMatrixNv [
	"GL_OFFSET_TEXTURE_2D_MATRIX_NV  GL_OFFSET_TEXTURE_MATRIX_NV"

	<category: 'constants Ext'>
	^1.6514001e + 23
    ]

    glOffsetTexture2dScaleNv [
	"GL_OFFSET_TEXTURE_2D_SCALE_NV  GL_OFFSET_TEXTURE_SCALE_NV"

	<category: 'constants Ext'>
	^1.6514001e + 22
    ]

    glOffsetTexture2dBiasNv [
	"GL_OFFSET_TEXTURE_2D_BIAS_NV  GL_OFFSET_TEXTURE_BIAS_NV"

	<category: 'constants Ext'>
	^1.6514001e + 21
    ]

    glPreviousTextureInputNv [
	"GL_PREVIOUS_TEXTURE_INPUT_NV  0x86E4"

	<category: 'constants Ext'>
	^34532
    ]

    glConstEyeNv [
	"GL_CONST_EYE_NV  0x86E5"

	<category: 'constants Ext'>
	^34533
    ]

    glPassThroughNv [
	"GL_PASS_THROUGH_NV  0x86E6"

	<category: 'constants Ext'>
	^34534
    ]

    glCullFragmentNv [
	"GL_CULL_FRAGMENT_NV  0x86E7"

	<category: 'constants Ext'>
	^34535
    ]

    glOffsetTexture2dNv [
	"GL_OFFSET_TEXTURE_2D_NV  0x86E8"

	<category: 'constants Ext'>
	^34536
    ]

    glDependentArTexture2dNv [
	"GL_DEPENDENT_AR_TEXTURE_2D_NV  0x86E9"

	<category: 'constants Ext'>
	^34537
    ]

    glDependentGbTexture2dNv [
	"GL_DEPENDENT_GB_TEXTURE_2D_NV  0x86EA"

	<category: 'constants Ext'>
	^34538
    ]

    glDotProductNv [
	"GL_DOT_PRODUCT_NV  0x86EC"

	<category: 'constants Ext'>
	^34540
    ]

    glDotProductDepthReplaceNv [
	"GL_DOT_PRODUCT_DEPTH_REPLACE_NV  0x86ED"

	<category: 'constants Ext'>
	^34541
    ]

    glDotProductTexture2dNv [
	"GL_DOT_PRODUCT_TEXTURE_2D_NV  0x86EE"

	<category: 'constants Ext'>
	^34542
    ]

    glDotProductTextureCubeMapNv [
	"GL_DOT_PRODUCT_TEXTURE_CUBE_MAP_NV  0x86F0"

	<category: 'constants Ext'>
	^34544
    ]

    glDotProductDiffuseCubeMapNv [
	"GL_DOT_PRODUCT_DIFFUSE_CUBE_MAP_NV  0x86F1"

	<category: 'constants Ext'>
	^34545
    ]

    glDotProductReflectCubeMapNv [
	"GL_DOT_PRODUCT_REFLECT_CUBE_MAP_NV  0x86F2"

	<category: 'constants Ext'>
	^34546
    ]

    glDotProductConstEyeReflectCubeMapNv [
	"GL_DOT_PRODUCT_CONST_EYE_REFLECT_CUBE_MAP_NV  0x86F3"

	<category: 'constants Ext'>
	^34547
    ]

    glHiloNv [
	"GL_HILO_NV  0x86F4"

	<category: 'constants Ext'>
	^34548
    ]

    glDsdtNv [
	"GL_DSDT_NV  0x86F5"

	<category: 'constants Ext'>
	^34549
    ]

    glDsdtMagNv [
	"GL_DSDT_MAG_NV  0x86F6"

	<category: 'constants Ext'>
	^34550
    ]

    glDsdtMagVibNv [
	"GL_DSDT_MAG_VIB_NV  0x86F7"

	<category: 'constants Ext'>
	^34551
    ]

    glHilo16Nv [
	"GL_HILO16_NV  0x86F8"

	<category: 'constants Ext'>
	^34552
    ]

    glSignedHiloNv [
	"GL_SIGNED_HILO_NV  0x86F9"

	<category: 'constants Ext'>
	^34553
    ]

    glSignedHilo16Nv [
	"GL_SIGNED_HILO16_NV  0x86FA"

	<category: 'constants Ext'>
	^34554
    ]

    glSignedRgbaNv [
	"GL_SIGNED_RGBA_NV  0x86FB"

	<category: 'constants Ext'>
	^34555
    ]

    glSignedRgba8Nv [
	"GL_SIGNED_RGBA8_NV  0x86FC"

	<category: 'constants Ext'>
	^34556
    ]

    glSignedRgbNv [
	"GL_SIGNED_RGB_NV  0x86FE"

	<category: 'constants Ext'>
	^34558
    ]

    glSignedRgb8Nv [
	"GL_SIGNED_RGB8_NV  0x86FF"

	<category: 'constants Ext'>
	^34559
    ]

    glSignedLuminanceNv [
	"GL_SIGNED_LUMINANCE_NV  0x8701"

	<category: 'constants Ext'>
	^34561
    ]

    glSignedLuminance8Nv [
	"GL_SIGNED_LUMINANCE8_NV  0x8702"

	<category: 'constants Ext'>
	^34562
    ]

    glSignedLuminanceAlphaNv [
	"GL_SIGNED_LUMINANCE_ALPHA_NV  0x8703"

	<category: 'constants Ext'>
	^34563
    ]

    glSignedLuminance8Alpha8Nv [
	"GL_SIGNED_LUMINANCE8_ALPHA8_NV  0x8704"

	<category: 'constants Ext'>
	^34564
    ]

    glSignedAlphaNv [
	"GL_SIGNED_ALPHA_NV  0x8705"

	<category: 'constants Ext'>
	^34565
    ]

    glSignedAlpha8Nv [
	"GL_SIGNED_ALPHA8_NV  0x8706"

	<category: 'constants Ext'>
	^34566
    ]

    glSignedIntensityNv [
	"GL_SIGNED_INTENSITY_NV  0x8707"

	<category: 'constants Ext'>
	^34567
    ]

    glSignedIntensity8Nv [
	"GL_SIGNED_INTENSITY8_NV  0x8708"

	<category: 'constants Ext'>
	^34568
    ]

    glDsdt8Nv [
	"GL_DSDT8_NV  0x8709"

	<category: 'constants Ext'>
	^34569
    ]

    glDsdt8Mag8Nv [
	"GL_DSDT8_MAG8_NV  0x870A"

	<category: 'constants Ext'>
	^34570
    ]

    glDsdt8Mag8Intensity8Nv [
	"GL_DSDT8_MAG8_INTENSITY8_NV  0x870B"

	<category: 'constants Ext'>
	^34571
    ]

    glSignedRgbUnsignedAlphaNv [
	"GL_SIGNED_RGB_UNSIGNED_ALPHA_NV  0x870C"

	<category: 'constants Ext'>
	^34572
    ]

    glSignedRgb8UnsignedAlpha8Nv [
	"GL_SIGNED_RGB8_UNSIGNED_ALPHA8_NV  0x870D"

	<category: 'constants Ext'>
	^34573
    ]

    glHiScaleNv [
	"GL_HI_SCALE_NV  0x870E"

	<category: 'constants Ext'>
	^34574
    ]

    glLoScaleNv [
	"GL_LO_SCALE_NV  0x870F"

	<category: 'constants Ext'>
	^34575
    ]

    glDsScaleNv [
	"GL_DS_SCALE_NV  0x8710"

	<category: 'constants Ext'>
	^34576
    ]

    glDtScaleNv [
	"GL_DT_SCALE_NV  0x8711"

	<category: 'constants Ext'>
	^34577
    ]

    glMagnitudeScaleNv [
	"GL_MAGNITUDE_SCALE_NV  0x8712"

	<category: 'constants Ext'>
	^34578
    ]

    glVibranceScaleNv [
	"GL_VIBRANCE_SCALE_NV  0x8713"

	<category: 'constants Ext'>
	^34579
    ]

    glHiBiasNv [
	"GL_HI_BIAS_NV  0x8714"

	<category: 'constants Ext'>
	^34580
    ]

    glLoBiasNv [
	"GL_LO_BIAS_NV  0x8715"

	<category: 'constants Ext'>
	^34581
    ]

    glDsBiasNv [
	"GL_DS_BIAS_NV  0x8716"

	<category: 'constants Ext'>
	^34582
    ]

    glDtBiasNv [
	"GL_DT_BIAS_NV  0x8717"

	<category: 'constants Ext'>
	^34583
    ]

    glMagnitudeBiasNv [
	"GL_MAGNITUDE_BIAS_NV  0x8718"

	<category: 'constants Ext'>
	^34584
    ]

    glVibranceBiasNv [
	"GL_VIBRANCE_BIAS_NV  0x8719"

	<category: 'constants Ext'>
	^34585
    ]

    glTextureBorderValuesNv [
	"GL_TEXTURE_BORDER_VALUES_NV  0x871A"

	<category: 'constants Ext'>
	^34586
    ]

    glTextureHiSizeNv [
	"GL_TEXTURE_HI_SIZE_NV  0x871B"

	<category: 'constants Ext'>
	^34587
    ]

    glTextureLoSizeNv [
	"GL_TEXTURE_LO_SIZE_NV  0x871C"

	<category: 'constants Ext'>
	^34588
    ]

    glTextureDsSizeNv [
	"GL_TEXTURE_DS_SIZE_NV  0x871D"

	<category: 'constants Ext'>
	^34589
    ]

    glTextureDtSizeNv [
	"GL_TEXTURE_DT_SIZE_NV  0x871E"

	<category: 'constants Ext'>
	^34590
    ]

    glTextureMagSizeNv [
	"GL_TEXTURE_MAG_SIZE_NV  0x871F"

	<category: 'constants Ext'>
	^34591
    ]

    glDotProductTexture3dNv [
	"GL_DOT_PRODUCT_TEXTURE_3D_NV  0x86EF"

	<category: 'constants Ext'>
	^34543
    ]

    glVertexArrayRangeWithoutFlushNv [
	"GL_VERTEX_ARRAY_RANGE_WITHOUT_FLUSH_NV  0x8533"

	<category: 'constants Ext'>
	^34099
    ]

    glVertexProgramNv [
	"GL_VERTEX_PROGRAM_NV  0x8620"

	<category: 'constants Ext'>
	^34336
    ]

    glVertexStateProgramNv [
	"GL_VERTEX_STATE_PROGRAM_NV  0x8621"

	<category: 'constants Ext'>
	^34337
    ]

    glAttribArraySizeNv [
	"GL_ATTRIB_ARRAY_SIZE_NV  0x8623"

	<category: 'constants Ext'>
	^34339
    ]

    glAttribArrayStrideNv [
	"GL_ATTRIB_ARRAY_STRIDE_NV  0x8624"

	<category: 'constants Ext'>
	^34340
    ]

    glAttribArrayTypeNv [
	"GL_ATTRIB_ARRAY_TYPE_NV  0x8625"

	<category: 'constants Ext'>
	^34341
    ]

    glCurrentAttribNv [
	"GL_CURRENT_ATTRIB_NV  0x8626"

	<category: 'constants Ext'>
	^34342
    ]

    glProgramLengthNv [
	"GL_PROGRAM_LENGTH_NV  0x8627"

	<category: 'constants Ext'>
	^34343
    ]

    glProgramStringNv [
	"GL_PROGRAM_STRING_NV  0x8628"

	<category: 'constants Ext'>
	^34344
    ]

    glModelviewProjectionNv [
	"GL_MODELVIEW_PROJECTION_NV  0x8629"

	<category: 'constants Ext'>
	^34345
    ]

    glIdentityNv [
	"GL_IDENTITY_NV  0x862A"

	<category: 'constants Ext'>
	^34346
    ]

    glInverseNv [
	"GL_INVERSE_NV  0x862B"

	<category: 'constants Ext'>
	^34347
    ]

    glTransposeNv [
	"GL_TRANSPOSE_NV  0x862C"

	<category: 'constants Ext'>
	^34348
    ]

    glInverseTransposeNv [
	"GL_INVERSE_TRANSPOSE_NV  0x862D"

	<category: 'constants Ext'>
	^34349
    ]

    glMaxTrackMatrixStackDepthNv [
	"GL_MAX_TRACK_MATRIX_STACK_DEPTH_NV  0x862E"

	<category: 'constants Ext'>
	^34350
    ]

    glMaxTrackMatricesNv [
	"GL_MAX_TRACK_MATRICES_NV  0x862F"

	<category: 'constants Ext'>
	^34351
    ]

    glMatrix0Nv [
	"GL_MATRIX0_NV  0x8630"

	<category: 'constants Ext'>
	^34352
    ]

    glMatrix1Nv [
	"GL_MATRIX1_NV  0x8631"

	<category: 'constants Ext'>
	^34353
    ]

    glMatrix2Nv [
	"GL_MATRIX2_NV  0x8632"

	<category: 'constants Ext'>
	^34354
    ]

    glMatrix3Nv [
	"GL_MATRIX3_NV  0x8633"

	<category: 'constants Ext'>
	^34355
    ]

    glMatrix4Nv [
	"GL_MATRIX4_NV  0x8634"

	<category: 'constants Ext'>
	^34356
    ]

    glMatrix5Nv [
	"GL_MATRIX5_NV  0x8635"

	<category: 'constants Ext'>
	^34357
    ]

    glMatrix6Nv [
	"GL_MATRIX6_NV  0x8636"

	<category: 'constants Ext'>
	^34358
    ]

    glMatrix7Nv [
	"GL_MATRIX7_NV  0x8637"

	<category: 'constants Ext'>
	^34359
    ]

    glCurrentMatrixStackDepthNv [
	"GL_CURRENT_MATRIX_STACK_DEPTH_NV  0x8640"

	<category: 'constants Ext'>
	^34368
    ]

    glCurrentMatrixNv [
	"GL_CURRENT_MATRIX_NV  0x8641"

	<category: 'constants Ext'>
	^34369
    ]

    glVertexProgramPointSizeNv [
	"GL_VERTEX_PROGRAM_POINT_SIZE_NV  0x8642"

	<category: 'constants Ext'>
	^34370
    ]

    glVertexProgramTwoSideNv [
	"GL_VERTEX_PROGRAM_TWO_SIDE_NV  0x8643"

	<category: 'constants Ext'>
	^34371
    ]

    glProgramParameterNv [
	"GL_PROGRAM_PARAMETER_NV  0x8644"

	<category: 'constants Ext'>
	^34372
    ]

    glAttribArrayPointerNv [
	"GL_ATTRIB_ARRAY_POINTER_NV  0x8645"

	<category: 'constants Ext'>
	^34373
    ]

    glProgramTargetNv [
	"GL_PROGRAM_TARGET_NV  0x8646"

	<category: 'constants Ext'>
	^34374
    ]

    glProgramResidentNv [
	"GL_PROGRAM_RESIDENT_NV  0x8647"

	<category: 'constants Ext'>
	^34375
    ]

    glTrackMatrixNv [
	"GL_TRACK_MATRIX_NV  0x8648"

	<category: 'constants Ext'>
	^34376
    ]

    glTrackMatrixTransformNv [
	"GL_TRACK_MATRIX_TRANSFORM_NV  0x8649"

	<category: 'constants Ext'>
	^34377
    ]

    glVertexProgramBindingNv [
	"GL_VERTEX_PROGRAM_BINDING_NV  0x864A"

	<category: 'constants Ext'>
	^34378
    ]

    glProgramErrorPositionNv [
	"GL_PROGRAM_ERROR_POSITION_NV  0x864B"

	<category: 'constants Ext'>
	^34379
    ]

    glVertexAttribArray0Nv [
	"GL_VERTEX_ATTRIB_ARRAY0_NV  0x8650"

	<category: 'constants Ext'>
	^34384
    ]

    glVertexAttribArray1Nv [
	"GL_VERTEX_ATTRIB_ARRAY1_NV  0x8651"

	<category: 'constants Ext'>
	^34385
    ]

    glVertexAttribArray2Nv [
	"GL_VERTEX_ATTRIB_ARRAY2_NV  0x8652"

	<category: 'constants Ext'>
	^34386
    ]

    glVertexAttribArray3Nv [
	"GL_VERTEX_ATTRIB_ARRAY3_NV  0x8653"

	<category: 'constants Ext'>
	^34387
    ]

    glVertexAttribArray4Nv [
	"GL_VERTEX_ATTRIB_ARRAY4_NV  0x8654"

	<category: 'constants Ext'>
	^34388
    ]

    glVertexAttribArray5Nv [
	"GL_VERTEX_ATTRIB_ARRAY5_NV  0x8655"

	<category: 'constants Ext'>
	^34389
    ]

    glVertexAttribArray6Nv [
	"GL_VERTEX_ATTRIB_ARRAY6_NV  0x8656"

	<category: 'constants Ext'>
	^34390
    ]

    glVertexAttribArray7Nv [
	"GL_VERTEX_ATTRIB_ARRAY7_NV  0x8657"

	<category: 'constants Ext'>
	^34391
    ]

    glVertexAttribArray8Nv [
	"GL_VERTEX_ATTRIB_ARRAY8_NV  0x8658"

	<category: 'constants Ext'>
	^34392
    ]

    glVertexAttribArray9Nv [
	"GL_VERTEX_ATTRIB_ARRAY9_NV  0x8659"

	<category: 'constants Ext'>
	^34393
    ]

    glVertexAttribArray10Nv [
	"GL_VERTEX_ATTRIB_ARRAY10_NV  0x865A"

	<category: 'constants Ext'>
	^34394
    ]

    glVertexAttribArray11Nv [
	"GL_VERTEX_ATTRIB_ARRAY11_NV  0x865B"

	<category: 'constants Ext'>
	^34395
    ]

    glVertexAttribArray12Nv [
	"GL_VERTEX_ATTRIB_ARRAY12_NV  0x865C"

	<category: 'constants Ext'>
	^34396
    ]

    glVertexAttribArray13Nv [
	"GL_VERTEX_ATTRIB_ARRAY13_NV  0x865D"

	<category: 'constants Ext'>
	^34397
    ]

    glVertexAttribArray14Nv [
	"GL_VERTEX_ATTRIB_ARRAY14_NV  0x865E"

	<category: 'constants Ext'>
	^34398
    ]

    glVertexAttribArray15Nv [
	"GL_VERTEX_ATTRIB_ARRAY15_NV  0x865F"

	<category: 'constants Ext'>
	^34399
    ]

    glMap1VertexAttrib04Nv [
	"GL_MAP1_VERTEX_ATTRIB0_4_NV  0x8660"

	<category: 'constants Ext'>
	^34400
    ]

    glMap1VertexAttrib14Nv [
	"GL_MAP1_VERTEX_ATTRIB1_4_NV  0x8661"

	<category: 'constants Ext'>
	^34401
    ]

    glMap1VertexAttrib24Nv [
	"GL_MAP1_VERTEX_ATTRIB2_4_NV  0x8662"

	<category: 'constants Ext'>
	^34402
    ]

    glMap1VertexAttrib34Nv [
	"GL_MAP1_VERTEX_ATTRIB3_4_NV  0x8663"

	<category: 'constants Ext'>
	^34403
    ]

    glMap1VertexAttrib44Nv [
	"GL_MAP1_VERTEX_ATTRIB4_4_NV  0x8664"

	<category: 'constants Ext'>
	^34404
    ]

    glMap1VertexAttrib54Nv [
	"GL_MAP1_VERTEX_ATTRIB5_4_NV  0x8665"

	<category: 'constants Ext'>
	^34405
    ]

    glMap1VertexAttrib64Nv [
	"GL_MAP1_VERTEX_ATTRIB6_4_NV  0x8666"

	<category: 'constants Ext'>
	^34406
    ]

    glMap1VertexAttrib74Nv [
	"GL_MAP1_VERTEX_ATTRIB7_4_NV  0x8667"

	<category: 'constants Ext'>
	^34407
    ]

    glMap1VertexAttrib84Nv [
	"GL_MAP1_VERTEX_ATTRIB8_4_NV  0x8668"

	<category: 'constants Ext'>
	^34408
    ]

    glMap1VertexAttrib94Nv [
	"GL_MAP1_VERTEX_ATTRIB9_4_NV  0x8669"

	<category: 'constants Ext'>
	^34409
    ]

    glMap1VertexAttrib104Nv [
	"GL_MAP1_VERTEX_ATTRIB10_4_NV  0x866A"

	<category: 'constants Ext'>
	^34410
    ]

    glMap1VertexAttrib114Nv [
	"GL_MAP1_VERTEX_ATTRIB11_4_NV  0x866B"

	<category: 'constants Ext'>
	^34411
    ]

    glMap1VertexAttrib124Nv [
	"GL_MAP1_VERTEX_ATTRIB12_4_NV  0x866C"

	<category: 'constants Ext'>
	^34412
    ]

    glMap1VertexAttrib134Nv [
	"GL_MAP1_VERTEX_ATTRIB13_4_NV  0x866D"

	<category: 'constants Ext'>
	^34413
    ]

    glMap1VertexAttrib144Nv [
	"GL_MAP1_VERTEX_ATTRIB14_4_NV  0x866E"

	<category: 'constants Ext'>
	^34414
    ]

    glMap1VertexAttrib154Nv [
	"GL_MAP1_VERTEX_ATTRIB15_4_NV  0x866F"

	<category: 'constants Ext'>
	^34415
    ]

    glMap2VertexAttrib04Nv [
	"GL_MAP2_VERTEX_ATTRIB0_4_NV  0x8670"

	<category: 'constants Ext'>
	^34416
    ]

    glMap2VertexAttrib14Nv [
	"GL_MAP2_VERTEX_ATTRIB1_4_NV  0x8671"

	<category: 'constants Ext'>
	^34417
    ]

    glMap2VertexAttrib24Nv [
	"GL_MAP2_VERTEX_ATTRIB2_4_NV  0x8672"

	<category: 'constants Ext'>
	^34418
    ]

    glMap2VertexAttrib34Nv [
	"GL_MAP2_VERTEX_ATTRIB3_4_NV  0x8673"

	<category: 'constants Ext'>
	^34419
    ]

    glMap2VertexAttrib44Nv [
	"GL_MAP2_VERTEX_ATTRIB4_4_NV  0x8674"

	<category: 'constants Ext'>
	^34420
    ]

    glMap2VertexAttrib54Nv [
	"GL_MAP2_VERTEX_ATTRIB5_4_NV  0x8675"

	<category: 'constants Ext'>
	^34421
    ]

    glMap2VertexAttrib64Nv [
	"GL_MAP2_VERTEX_ATTRIB6_4_NV  0x8676"

	<category: 'constants Ext'>
	^34422
    ]

    glMap2VertexAttrib74Nv [
	"GL_MAP2_VERTEX_ATTRIB7_4_NV  0x8677"

	<category: 'constants Ext'>
	^34423
    ]

    glMap2VertexAttrib84Nv [
	"GL_MAP2_VERTEX_ATTRIB8_4_NV  0x8678"

	<category: 'constants Ext'>
	^34424
    ]

    glMap2VertexAttrib94Nv [
	"GL_MAP2_VERTEX_ATTRIB9_4_NV  0x8679"

	<category: 'constants Ext'>
	^34425
    ]

    glMap2VertexAttrib104Nv [
	"GL_MAP2_VERTEX_ATTRIB10_4_NV  0x867A"

	<category: 'constants Ext'>
	^34426
    ]

    glMap2VertexAttrib114Nv [
	"GL_MAP2_VERTEX_ATTRIB11_4_NV  0x867B"

	<category: 'constants Ext'>
	^34427
    ]

    glMap2VertexAttrib124Nv [
	"GL_MAP2_VERTEX_ATTRIB12_4_NV  0x867C"

	<category: 'constants Ext'>
	^34428
    ]

    glMap2VertexAttrib134Nv [
	"GL_MAP2_VERTEX_ATTRIB13_4_NV  0x867D"

	<category: 'constants Ext'>
	^34429
    ]

    glMap2VertexAttrib144Nv [
	"GL_MAP2_VERTEX_ATTRIB14_4_NV  0x867E"

	<category: 'constants Ext'>
	^34430
    ]

    glMap2VertexAttrib154Nv [
	"GL_MAP2_VERTEX_ATTRIB15_4_NV  0x867F"

	<category: 'constants Ext'>
	^34431
    ]

    glTextureMaxClampSSgix [
	"GL_TEXTURE_MAX_CLAMP_S_SGIX  0x8369"

	<category: 'constants Ext'>
	^33641
    ]

    glTextureMaxClampTSgix [
	"GL_TEXTURE_MAX_CLAMP_T_SGIX  0x836A"

	<category: 'constants Ext'>
	^33642
    ]

    glTextureMaxClampRSgix [
	"GL_TEXTURE_MAX_CLAMP_R_SGIX  0x836B"

	<category: 'constants Ext'>
	^33643
    ]

    glScalebiasHintSgix [
	"GL_SCALEBIAS_HINT_SGIX  0x8322"

	<category: 'constants Ext'>
	^33570
    ]

    glInterlaceOml [
	"GL_INTERLACE_OML  0x8980"

	<category: 'constants Ext'>
	^35200
    ]

    glInterlaceReadOml [
	"GL_INTERLACE_READ_OML  0x8981"

	<category: 'constants Ext'>
	^35201
    ]

    glFormatSubsample2424Oml [
	"GL_FORMAT_SUBSAMPLE_24_24_OML  0x8982"

	<category: 'constants Ext'>
	^35202
    ]

    glFormatSubsample244244Oml [
	"GL_FORMAT_SUBSAMPLE_244_244_OML  0x8983"

	<category: 'constants Ext'>
	^35203
    ]

    glPackResampleOml [
	"GL_PACK_RESAMPLE_OML  0x8984"

	<category: 'constants Ext'>
	^35204
    ]

    glUnpackResampleOml [
	"GL_UNPACK_RESAMPLE_OML  0x8985"

	<category: 'constants Ext'>
	^35205
    ]

    glResampleReplicateOml [
	"GL_RESAMPLE_REPLICATE_OML  0x8986"

	<category: 'constants Ext'>
	^35206
    ]

    glResampleZeroFillOml [
	"GL_RESAMPLE_ZERO_FILL_OML  0x8987"

	<category: 'constants Ext'>
	^35207
    ]

    glResampleAverageOml [
	"GL_RESAMPLE_AVERAGE_OML  0x8988"

	<category: 'constants Ext'>
	^35208
    ]

    glResampleDecimateOml [
	"GL_RESAMPLE_DECIMATE_OML  0x8989"

	<category: 'constants Ext'>
	^35209
    ]

    glDepthStencilToRgbaNv [
	"GL_DEPTH_STENCIL_TO_RGBA_NV  0x886E"

	<category: 'constants Ext'>
	^34926
    ]

    glDepthStencilToBgraNv [
	"GL_DEPTH_STENCIL_TO_BGRA_NV  0x886F"

	<category: 'constants Ext'>
	^34927
    ]

    glBumpRotMatrixAti [
	"GL_BUMP_ROT_MATRIX_ATI  0x8775"

	<category: 'constants Ext'>
	^34677
    ]

    glBumpRotMatrixSizeAti [
	"GL_BUMP_ROT_MATRIX_SIZE_ATI  0x8776"

	<category: 'constants Ext'>
	^34678
    ]

    glBumpNumTexUnitsAti [
	"GL_BUMP_NUM_TEX_UNITS_ATI  0x8777"

	<category: 'constants Ext'>
	^34679
    ]

    glBumpTexUnitsAti [
	"GL_BUMP_TEX_UNITS_ATI  0x8778"

	<category: 'constants Ext'>
	^34680
    ]

    glDudvAti [
	"GL_DUDV_ATI  0x8779"

	<category: 'constants Ext'>
	^34681
    ]

    glDu8dv8Ati [
	"GL_DU8DV8_ATI  0x877A"

	<category: 'constants Ext'>
	^34682
    ]

    glBumpEnvmapAti [
	"GL_BUMP_ENVMAP_ATI  0x877B"

	<category: 'constants Ext'>
	^34683
    ]

    glBumpTargetAti [
	"GL_BUMP_TARGET_ATI  0x877C"

	<category: 'constants Ext'>
	^34684
    ]

    glFragmentShaderAti [
	"GL_FRAGMENT_SHADER_ATI  0x8920"

	<category: 'constants Ext'>
	^35104
    ]

    glReg0Ati [
	"GL_REG_0_ATI  0x8921"

	<category: 'constants Ext'>
	^35105
    ]

    glReg1Ati [
	"GL_REG_1_ATI  0x8922"

	<category: 'constants Ext'>
	^35106
    ]

    glReg2Ati [
	"GL_REG_2_ATI  0x8923"

	<category: 'constants Ext'>
	^35107
    ]

    glReg3Ati [
	"GL_REG_3_ATI  0x8924"

	<category: 'constants Ext'>
	^35108
    ]

    glReg4Ati [
	"GL_REG_4_ATI  0x8925"

	<category: 'constants Ext'>
	^35109
    ]

    glReg5Ati [
	"GL_REG_5_ATI  0x8926"

	<category: 'constants Ext'>
	^35110
    ]

    glReg6Ati [
	"GL_REG_6_ATI  0x8927"

	<category: 'constants Ext'>
	^35111
    ]

    glReg7Ati [
	"GL_REG_7_ATI  0x8928"

	<category: 'constants Ext'>
	^35112
    ]

    glReg8Ati [
	"GL_REG_8_ATI  0x8929"

	<category: 'constants Ext'>
	^35113
    ]

    glReg9Ati [
	"GL_REG_9_ATI  0x892A"

	<category: 'constants Ext'>
	^35114
    ]

    glReg10Ati [
	"GL_REG_10_ATI  0x892B"

	<category: 'constants Ext'>
	^35115
    ]

    glReg11Ati [
	"GL_REG_11_ATI  0x892C"

	<category: 'constants Ext'>
	^35116
    ]

    glReg12Ati [
	"GL_REG_12_ATI  0x892D"

	<category: 'constants Ext'>
	^35117
    ]

    glReg13Ati [
	"GL_REG_13_ATI  0x892E"

	<category: 'constants Ext'>
	^35118
    ]

    glReg14Ati [
	"GL_REG_14_ATI  0x892F"

	<category: 'constants Ext'>
	^35119
    ]

    glReg15Ati [
	"GL_REG_15_ATI  0x8930"

	<category: 'constants Ext'>
	^35120
    ]

    glReg16Ati [
	"GL_REG_16_ATI  0x8931"

	<category: 'constants Ext'>
	^35121
    ]

    glReg17Ati [
	"GL_REG_17_ATI  0x8932"

	<category: 'constants Ext'>
	^35122
    ]

    glReg18Ati [
	"GL_REG_18_ATI  0x8933"

	<category: 'constants Ext'>
	^35123
    ]

    glReg19Ati [
	"GL_REG_19_ATI  0x8934"

	<category: 'constants Ext'>
	^35124
    ]

    glReg20Ati [
	"GL_REG_20_ATI  0x8935"

	<category: 'constants Ext'>
	^35125
    ]

    glReg21Ati [
	"GL_REG_21_ATI  0x8936"

	<category: 'constants Ext'>
	^35126
    ]

    glReg22Ati [
	"GL_REG_22_ATI  0x8937"

	<category: 'constants Ext'>
	^35127
    ]

    glReg23Ati [
	"GL_REG_23_ATI  0x8938"

	<category: 'constants Ext'>
	^35128
    ]

    glReg24Ati [
	"GL_REG_24_ATI  0x8939"

	<category: 'constants Ext'>
	^35129
    ]

    glReg25Ati [
	"GL_REG_25_ATI  0x893A"

	<category: 'constants Ext'>
	^35130
    ]

    glReg26Ati [
	"GL_REG_26_ATI  0x893B"

	<category: 'constants Ext'>
	^35131
    ]

    glReg27Ati [
	"GL_REG_27_ATI  0x893C"

	<category: 'constants Ext'>
	^35132
    ]

    glReg28Ati [
	"GL_REG_28_ATI  0x893D"

	<category: 'constants Ext'>
	^35133
    ]

    glReg29Ati [
	"GL_REG_29_ATI  0x893E"

	<category: 'constants Ext'>
	^35134
    ]

    glReg30Ati [
	"GL_REG_30_ATI  0x893F"

	<category: 'constants Ext'>
	^35135
    ]

    glReg31Ati [
	"GL_REG_31_ATI  0x8940"

	<category: 'constants Ext'>
	^35136
    ]

    glCon0Ati [
	"GL_CON_0_ATI  0x8941"

	<category: 'constants Ext'>
	^35137
    ]

    glCon1Ati [
	"GL_CON_1_ATI  0x8942"

	<category: 'constants Ext'>
	^35138
    ]

    glCon2Ati [
	"GL_CON_2_ATI  0x8943"

	<category: 'constants Ext'>
	^35139
    ]

    glCon3Ati [
	"GL_CON_3_ATI  0x8944"

	<category: 'constants Ext'>
	^35140
    ]

    glCon4Ati [
	"GL_CON_4_ATI  0x8945"

	<category: 'constants Ext'>
	^35141
    ]

    glCon5Ati [
	"GL_CON_5_ATI  0x8946"

	<category: 'constants Ext'>
	^35142
    ]

    glCon6Ati [
	"GL_CON_6_ATI  0x8947"

	<category: 'constants Ext'>
	^35143
    ]

    glCon7Ati [
	"GL_CON_7_ATI  0x8948"

	<category: 'constants Ext'>
	^35144
    ]

    glCon8Ati [
	"GL_CON_8_ATI  0x8949"

	<category: 'constants Ext'>
	^35145
    ]

    glCon9Ati [
	"GL_CON_9_ATI  0x894A"

	<category: 'constants Ext'>
	^35146
    ]

    glCon10Ati [
	"GL_CON_10_ATI  0x894B"

	<category: 'constants Ext'>
	^35147
    ]

    glCon11Ati [
	"GL_CON_11_ATI  0x894C"

	<category: 'constants Ext'>
	^35148
    ]

    glCon12Ati [
	"GL_CON_12_ATI  0x894D"

	<category: 'constants Ext'>
	^35149
    ]

    glCon13Ati [
	"GL_CON_13_ATI  0x894E"

	<category: 'constants Ext'>
	^35150
    ]

    glCon14Ati [
	"GL_CON_14_ATI  0x894F"

	<category: 'constants Ext'>
	^35151
    ]

    glCon15Ati [
	"GL_CON_15_ATI  0x8950"

	<category: 'constants Ext'>
	^35152
    ]

    glCon16Ati [
	"GL_CON_16_ATI  0x8951"

	<category: 'constants Ext'>
	^35153
    ]

    glCon17Ati [
	"GL_CON_17_ATI  0x8952"

	<category: 'constants Ext'>
	^35154
    ]

    glCon18Ati [
	"GL_CON_18_ATI  0x8953"

	<category: 'constants Ext'>
	^35155
    ]

    glCon19Ati [
	"GL_CON_19_ATI  0x8954"

	<category: 'constants Ext'>
	^35156
    ]

    glCon20Ati [
	"GL_CON_20_ATI  0x8955"

	<category: 'constants Ext'>
	^35157
    ]

    glCon21Ati [
	"GL_CON_21_ATI  0x8956"

	<category: 'constants Ext'>
	^35158
    ]

    glCon22Ati [
	"GL_CON_22_ATI  0x8957"

	<category: 'constants Ext'>
	^35159
    ]

    glCon23Ati [
	"GL_CON_23_ATI  0x8958"

	<category: 'constants Ext'>
	^35160
    ]

    glCon24Ati [
	"GL_CON_24_ATI  0x8959"

	<category: 'constants Ext'>
	^35161
    ]

    glCon25Ati [
	"GL_CON_25_ATI  0x895A"

	<category: 'constants Ext'>
	^35162
    ]

    glCon26Ati [
	"GL_CON_26_ATI  0x895B"

	<category: 'constants Ext'>
	^35163
    ]

    glCon27Ati [
	"GL_CON_27_ATI  0x895C"

	<category: 'constants Ext'>
	^35164
    ]

    glCon28Ati [
	"GL_CON_28_ATI  0x895D"

	<category: 'constants Ext'>
	^35165
    ]

    glCon29Ati [
	"GL_CON_29_ATI  0x895E"

	<category: 'constants Ext'>
	^35166
    ]

    glCon30Ati [
	"GL_CON_30_ATI  0x895F"

	<category: 'constants Ext'>
	^35167
    ]

    glCon31Ati [
	"GL_CON_31_ATI  0x8960"

	<category: 'constants Ext'>
	^35168
    ]

    glMovAti [
	"GL_MOV_ATI  0x8961"

	<category: 'constants Ext'>
	^35169
    ]

    glAddAti [
	"GL_ADD_ATI  0x8963"

	<category: 'constants Ext'>
	^35171
    ]

    glMulAti [
	"GL_MUL_ATI  0x8964"

	<category: 'constants Ext'>
	^35172
    ]

    glSubAti [
	"GL_SUB_ATI  0x8965"

	<category: 'constants Ext'>
	^35173
    ]

    glDot3Ati [
	"GL_DOT3_ATI  0x8966"

	<category: 'constants Ext'>
	^35174
    ]

    glDot4Ati [
	"GL_DOT4_ATI  0x8967"

	<category: 'constants Ext'>
	^35175
    ]

    glMadAti [
	"GL_MAD_ATI  0x8968"

	<category: 'constants Ext'>
	^35176
    ]

    glLerpAti [
	"GL_LERP_ATI  0x8969"

	<category: 'constants Ext'>
	^35177
    ]

    glCndAti [
	"GL_CND_ATI  0x896A"

	<category: 'constants Ext'>
	^35178
    ]

    glCnd0Ati [
	"GL_CND0_ATI  0x896B"

	<category: 'constants Ext'>
	^35179
    ]

    glDot2AddAti [
	"GL_DOT2_ADD_ATI  0x896C"

	<category: 'constants Ext'>
	^35180
    ]

    glSecondaryInterpolatorAti [
	"GL_SECONDARY_INTERPOLATOR_ATI  0x896D"

	<category: 'constants Ext'>
	^35181
    ]

    glNumFragmentRegistersAti [
	"GL_NUM_FRAGMENT_REGISTERS_ATI  0x896E"

	<category: 'constants Ext'>
	^35182
    ]

    glNumFragmentConstantsAti [
	"GL_NUM_FRAGMENT_CONSTANTS_ATI  0x896F"

	<category: 'constants Ext'>
	^35183
    ]

    glNumPassesAti [
	"GL_NUM_PASSES_ATI  0x8970"

	<category: 'constants Ext'>
	^35184
    ]

    glNumInstructionsPerPassAti [
	"GL_NUM_INSTRUCTIONS_PER_PASS_ATI  0x8971"

	<category: 'constants Ext'>
	^35185
    ]

    glNumInstructionsTotalAti [
	"GL_NUM_INSTRUCTIONS_TOTAL_ATI  0x8972"

	<category: 'constants Ext'>
	^35186
    ]

    glNumInputInterpolatorComponentsAti [
	"GL_NUM_INPUT_INTERPOLATOR_COMPONENTS_ATI  0x8973"

	<category: 'constants Ext'>
	^35187
    ]

    glNumLoopbackComponentsAti [
	"GL_NUM_LOOPBACK_COMPONENTS_ATI  0x8974"

	<category: 'constants Ext'>
	^35188
    ]

    glColorAlphaPairingAti [
	"GL_COLOR_ALPHA_PAIRING_ATI  0x8975"

	<category: 'constants Ext'>
	^35189
    ]

    glSwizzleStrAti [
	"GL_SWIZZLE_STR_ATI  0x8976"

	<category: 'constants Ext'>
	^35190
    ]

    glSwizzleStqAti [
	"GL_SWIZZLE_STQ_ATI  0x8977"

	<category: 'constants Ext'>
	^35191
    ]

    glSwizzleStrDrAti [
	"GL_SWIZZLE_STR_DR_ATI  0x8978"

	<category: 'constants Ext'>
	^35192
    ]

    glSwizzleStqDqAti [
	"GL_SWIZZLE_STQ_DQ_ATI  0x8979"

	<category: 'constants Ext'>
	^35193
    ]

    glSwizzleStrqAti [
	"GL_SWIZZLE_STRQ_ATI  0x897A"

	<category: 'constants Ext'>
	^35194
    ]

    glSwizzleStrqDqAti [
	"GL_SWIZZLE_STRQ_DQ_ATI  0x897B"

	<category: 'constants Ext'>
	^35195
    ]

    glRedBitAti [
	"GL_RED_BIT_ATI  0x00000001"

	<category: 'constants Ext'>
	^1
    ]

    glGreenBitAti [
	"GL_GREEN_BIT_ATI  0x00000002"

	<category: 'constants Ext'>
	^2
    ]

    glBlueBitAti [
	"GL_BLUE_BIT_ATI  0x00000004"

	<category: 'constants Ext'>
	^4
    ]

    gl2xBitAti [
	"GL_2X_BIT_ATI  0x00000001"

	<category: 'constants Ext'>
	^1
    ]

    gl4xBitAti [
	"GL_4X_BIT_ATI  0x00000002"

	<category: 'constants Ext'>
	^2
    ]

    gl8xBitAti [
	"GL_8X_BIT_ATI  0x00000004"

	<category: 'constants Ext'>
	^4
    ]

    glHalfBitAti [
	"GL_HALF_BIT_ATI  0x00000008"

	<category: 'constants Ext'>
	^8
    ]

    glQuarterBitAti [
	"GL_QUARTER_BIT_ATI  0x00000010"

	<category: 'constants Ext'>
	^16
    ]

    glEighthBitAti [
	"GL_EIGHTH_BIT_ATI  0x00000020"

	<category: 'constants Ext'>
	^32
    ]

    glSaturateBitAti [
	"GL_SATURATE_BIT_ATI  0x00000040"

	<category: 'constants Ext'>
	^64
    ]

    glCompBitAti [
	"GL_COMP_BIT_ATI  0x00000002"

	<category: 'constants Ext'>
	^2
    ]

    glNegateBitAti [
	"GL_NEGATE_BIT_ATI  0x00000004"

	<category: 'constants Ext'>
	^4
    ]

    glBiasBitAti [
	"GL_BIAS_BIT_ATI  0x00000008"

	<category: 'constants Ext'>
	^8
    ]

    glPnTrianglesAti [
	"GL_PN_TRIANGLES_ATI  0x87F0"

	<category: 'constants Ext'>
	^34800
    ]

    glMaxPnTrianglesTesselationLevelAti [
	"GL_MAX_PN_TRIANGLES_TESSELATION_LEVEL_ATI  0x87F1"

	<category: 'constants Ext'>
	^34801
    ]

    glPnTrianglesPointModeAti [
	"GL_PN_TRIANGLES_POINT_MODE_ATI  0x87F2"

	<category: 'constants Ext'>
	^34802
    ]

    glPnTrianglesNormalModeAti [
	"GL_PN_TRIANGLES_NORMAL_MODE_ATI  0x87F3"

	<category: 'constants Ext'>
	^34803
    ]

    glPnTrianglesTesselationLevelAti [
	"GL_PN_TRIANGLES_TESSELATION_LEVEL_ATI  0x87F4"

	<category: 'constants Ext'>
	^34804
    ]

    glPnTrianglesPointModeLinearAti [
	"GL_PN_TRIANGLES_POINT_MODE_LINEAR_ATI  0x87F5"

	<category: 'constants Ext'>
	^34805
    ]

    glPnTrianglesPointModeCubicAti [
	"GL_PN_TRIANGLES_POINT_MODE_CUBIC_ATI  0x87F6"

	<category: 'constants Ext'>
	^34806
    ]

    glPnTrianglesNormalModeLinearAti [
	"GL_PN_TRIANGLES_NORMAL_MODE_LINEAR_ATI  0x87F7"

	<category: 'constants Ext'>
	^34807
    ]

    glPnTrianglesNormalModeQuadraticAti [
	"GL_PN_TRIANGLES_NORMAL_MODE_QUADRATIC_ATI  0x87F8"

	<category: 'constants Ext'>
	^34808
    ]

    glStaticAti [
	"GL_STATIC_ATI  0x8760"

	<category: 'constants Ext'>
	^34656
    ]

    glDynamicAti [
	"GL_DYNAMIC_ATI  0x8761"

	<category: 'constants Ext'>
	^34657
    ]

    glPreserveAti [
	"GL_PRESERVE_ATI  0x8762"

	<category: 'constants Ext'>
	^34658
    ]

    glDiscardAti [
	"GL_DISCARD_ATI  0x8763"

	<category: 'constants Ext'>
	^34659
    ]

    glObjectBufferSizeAti [
	"GL_OBJECT_BUFFER_SIZE_ATI  0x8764"

	<category: 'constants Ext'>
	^34660
    ]

    glObjectBufferUsageAti [
	"GL_OBJECT_BUFFER_USAGE_ATI  0x8765"

	<category: 'constants Ext'>
	^34661
    ]

    glArrayObjectBufferAti [
	"GL_ARRAY_OBJECT_BUFFER_ATI  0x8766"

	<category: 'constants Ext'>
	^34662
    ]

    glArrayObjectOffsetAti [
	"GL_ARRAY_OBJECT_OFFSET_ATI  0x8767"

	<category: 'constants Ext'>
	^34663
    ]

    glVertexShaderExt [
	"GL_VERTEX_SHADER_EXT  0x8780"

	<category: 'constants Ext'>
	^34688
    ]

    glVertexShaderBindingExt [
	"GL_VERTEX_SHADER_BINDING_EXT  0x8781"

	<category: 'constants Ext'>
	^34689
    ]

    glOpIndexExt [
	"GL_OP_INDEX_EXT  0x8782"

	<category: 'constants Ext'>
	^34690
    ]

    glOpNegateExt [
	"GL_OP_NEGATE_EXT  0x8783"

	<category: 'constants Ext'>
	^34691
    ]

    glOpDot3Ext [
	"GL_OP_DOT3_EXT  0x8784"

	<category: 'constants Ext'>
	^34692
    ]

    glOpDot4Ext [
	"GL_OP_DOT4_EXT  0x8785"

	<category: 'constants Ext'>
	^34693
    ]

    glOpMulExt [
	"GL_OP_MUL_EXT  0x8786"

	<category: 'constants Ext'>
	^34694
    ]

    glOpAddExt [
	"GL_OP_ADD_EXT  0x8787"

	<category: 'constants Ext'>
	^34695
    ]

    glOpMaddExt [
	"GL_OP_MADD_EXT  0x8788"

	<category: 'constants Ext'>
	^34696
    ]

    glOpFracExt [
	"GL_OP_FRAC_EXT  0x8789"

	<category: 'constants Ext'>
	^34697
    ]

    glOpMaxExt [
	"GL_OP_MAX_EXT  0x878A"

	<category: 'constants Ext'>
	^34698
    ]

    glOpMinExt [
	"GL_OP_MIN_EXT  0x878B"

	<category: 'constants Ext'>
	^34699
    ]

    glOpSetGeExt [
	"GL_OP_SET_GE_EXT  0x878C"

	<category: 'constants Ext'>
	^34700
    ]

    glOpSetLtExt [
	"GL_OP_SET_LT_EXT  0x878D"

	<category: 'constants Ext'>
	^34701
    ]

    glOpClampExt [
	"GL_OP_CLAMP_EXT  0x878E"

	<category: 'constants Ext'>
	^34702
    ]

    glOpFloorExt [
	"GL_OP_FLOOR_EXT  0x878F"

	<category: 'constants Ext'>
	^34703
    ]

    glOpRoundExt [
	"GL_OP_ROUND_EXT  0x8790"

	<category: 'constants Ext'>
	^34704
    ]

    glOpExpBase2Ext [
	"GL_OP_EXP_BASE_2_EXT  0x8791"

	<category: 'constants Ext'>
	^34705
    ]

    glOpLogBase2Ext [
	"GL_OP_LOG_BASE_2_EXT  0x8792"

	<category: 'constants Ext'>
	^34706
    ]

    glOpPowerExt [
	"GL_OP_POWER_EXT  0x8793"

	<category: 'constants Ext'>
	^34707
    ]

    glOpRecipExt [
	"GL_OP_RECIP_EXT  0x8794"

	<category: 'constants Ext'>
	^34708
    ]

    glOpRecipSqrtExt [
	"GL_OP_RECIP_SQRT_EXT  0x8795"

	<category: 'constants Ext'>
	^34709
    ]

    glOpSubExt [
	"GL_OP_SUB_EXT  0x8796"

	<category: 'constants Ext'>
	^34710
    ]

    glOpCrossProductExt [
	"GL_OP_CROSS_PRODUCT_EXT  0x8797"

	<category: 'constants Ext'>
	^34711
    ]

    glOpMultiplyMatrixExt [
	"GL_OP_MULTIPLY_MATRIX_EXT  0x8798"

	<category: 'constants Ext'>
	^34712
    ]

    glOpMovExt [
	"GL_OP_MOV_EXT  0x8799"

	<category: 'constants Ext'>
	^34713
    ]

    glOutputVertexExt [
	"GL_OUTPUT_VERTEX_EXT  0x879A"

	<category: 'constants Ext'>
	^34714
    ]

    glOutputColor0Ext [
	"GL_OUTPUT_COLOR0_EXT  0x879B"

	<category: 'constants Ext'>
	^34715
    ]

    glOutputColor1Ext [
	"GL_OUTPUT_COLOR1_EXT  0x879C"

	<category: 'constants Ext'>
	^34716
    ]

    glOutputTextureCoord0Ext [
	"GL_OUTPUT_TEXTURE_COORD0_EXT  0x879D"

	<category: 'constants Ext'>
	^34717
    ]

    glOutputTextureCoord1Ext [
	"GL_OUTPUT_TEXTURE_COORD1_EXT  0x879E"

	<category: 'constants Ext'>
	^34718
    ]

    glOutputTextureCoord2Ext [
	"GL_OUTPUT_TEXTURE_COORD2_EXT  0x879F"

	<category: 'constants Ext'>
	^34719
    ]

    glOutputTextureCoord3Ext [
	"GL_OUTPUT_TEXTURE_COORD3_EXT  0x87A0"

	<category: 'constants Ext'>
	^34720
    ]

    glOutputTextureCoord4Ext [
	"GL_OUTPUT_TEXTURE_COORD4_EXT  0x87A1"

	<category: 'constants Ext'>
	^34721
    ]

    glOutputTextureCoord5Ext [
	"GL_OUTPUT_TEXTURE_COORD5_EXT  0x87A2"

	<category: 'constants Ext'>
	^34722
    ]

    glOutputTextureCoord6Ext [
	"GL_OUTPUT_TEXTURE_COORD6_EXT  0x87A3"

	<category: 'constants Ext'>
	^34723
    ]

    glOutputTextureCoord7Ext [
	"GL_OUTPUT_TEXTURE_COORD7_EXT  0x87A4"

	<category: 'constants Ext'>
	^34724
    ]

    glOutputTextureCoord8Ext [
	"GL_OUTPUT_TEXTURE_COORD8_EXT  0x87A5"

	<category: 'constants Ext'>
	^34725
    ]

    glOutputTextureCoord9Ext [
	"GL_OUTPUT_TEXTURE_COORD9_EXT  0x87A6"

	<category: 'constants Ext'>
	^34726
    ]

    glOutputTextureCoord10Ext [
	"GL_OUTPUT_TEXTURE_COORD10_EXT  0x87A7"

	<category: 'constants Ext'>
	^34727
    ]

    glOutputTextureCoord11Ext [
	"GL_OUTPUT_TEXTURE_COORD11_EXT  0x87A8"

	<category: 'constants Ext'>
	^34728
    ]

    glOutputTextureCoord12Ext [
	"GL_OUTPUT_TEXTURE_COORD12_EXT  0x87A9"

	<category: 'constants Ext'>
	^34729
    ]

    glOutputTextureCoord13Ext [
	"GL_OUTPUT_TEXTURE_COORD13_EXT  0x87AA"

	<category: 'constants Ext'>
	^34730
    ]

    glOutputTextureCoord14Ext [
	"GL_OUTPUT_TEXTURE_COORD14_EXT  0x87AB"

	<category: 'constants Ext'>
	^34731
    ]

    glOutputTextureCoord15Ext [
	"GL_OUTPUT_TEXTURE_COORD15_EXT  0x87AC"

	<category: 'constants Ext'>
	^34732
    ]

    glOutputTextureCoord16Ext [
	"GL_OUTPUT_TEXTURE_COORD16_EXT  0x87AD"

	<category: 'constants Ext'>
	^34733
    ]

    glOutputTextureCoord17Ext [
	"GL_OUTPUT_TEXTURE_COORD17_EXT  0x87AE"

	<category: 'constants Ext'>
	^34734
    ]

    glOutputTextureCoord18Ext [
	"GL_OUTPUT_TEXTURE_COORD18_EXT  0x87AF"

	<category: 'constants Ext'>
	^34735
    ]

    glOutputTextureCoord19Ext [
	"GL_OUTPUT_TEXTURE_COORD19_EXT  0x87B0"

	<category: 'constants Ext'>
	^34736
    ]

    glOutputTextureCoord20Ext [
	"GL_OUTPUT_TEXTURE_COORD20_EXT  0x87B1"

	<category: 'constants Ext'>
	^34737
    ]

    glOutputTextureCoord21Ext [
	"GL_OUTPUT_TEXTURE_COORD21_EXT  0x87B2"

	<category: 'constants Ext'>
	^34738
    ]

    glOutputTextureCoord22Ext [
	"GL_OUTPUT_TEXTURE_COORD22_EXT  0x87B3"

	<category: 'constants Ext'>
	^34739
    ]

    glOutputTextureCoord23Ext [
	"GL_OUTPUT_TEXTURE_COORD23_EXT  0x87B4"

	<category: 'constants Ext'>
	^34740
    ]

    glOutputTextureCoord24Ext [
	"GL_OUTPUT_TEXTURE_COORD24_EXT  0x87B5"

	<category: 'constants Ext'>
	^34741
    ]

    glOutputTextureCoord25Ext [
	"GL_OUTPUT_TEXTURE_COORD25_EXT  0x87B6"

	<category: 'constants Ext'>
	^34742
    ]

    glOutputTextureCoord26Ext [
	"GL_OUTPUT_TEXTURE_COORD26_EXT  0x87B7"

	<category: 'constants Ext'>
	^34743
    ]

    glOutputTextureCoord27Ext [
	"GL_OUTPUT_TEXTURE_COORD27_EXT  0x87B8"

	<category: 'constants Ext'>
	^34744
    ]

    glOutputTextureCoord28Ext [
	"GL_OUTPUT_TEXTURE_COORD28_EXT  0x87B9"

	<category: 'constants Ext'>
	^34745
    ]

    glOutputTextureCoord29Ext [
	"GL_OUTPUT_TEXTURE_COORD29_EXT  0x87BA"

	<category: 'constants Ext'>
	^34746
    ]

    glOutputTextureCoord30Ext [
	"GL_OUTPUT_TEXTURE_COORD30_EXT  0x87BB"

	<category: 'constants Ext'>
	^34747
    ]

    glOutputTextureCoord31Ext [
	"GL_OUTPUT_TEXTURE_COORD31_EXT  0x87BC"

	<category: 'constants Ext'>
	^34748
    ]

    glOutputFogExt [
	"GL_OUTPUT_FOG_EXT  0x87BD"

	<category: 'constants Ext'>
	^34749
    ]

    glScalarExt [
	"GL_SCALAR_EXT  0x87BE"

	<category: 'constants Ext'>
	^34750
    ]

    glVectorExt [
	"GL_VECTOR_EXT  0x87BF"

	<category: 'constants Ext'>
	^34751
    ]

    glMatrixExt [
	"GL_MATRIX_EXT  0x87C0"

	<category: 'constants Ext'>
	^34752
    ]

    glVariantExt [
	"GL_VARIANT_EXT  0x87C1"

	<category: 'constants Ext'>
	^34753
    ]

    glInvariantExt [
	"GL_INVARIANT_EXT  0x87C2"

	<category: 'constants Ext'>
	^34754
    ]

    glLocalConstantExt [
	"GL_LOCAL_CONSTANT_EXT  0x87C3"

	<category: 'constants Ext'>
	^34755
    ]

    glLocalExt [
	"GL_LOCAL_EXT  0x87C4"

	<category: 'constants Ext'>
	^34756
    ]

    glMaxVertexShaderInstructionsExt [
	"GL_MAX_VERTEX_SHADER_INSTRUCTIONS_EXT  0x87C5"

	<category: 'constants Ext'>
	^34757
    ]

    glMaxVertexShaderVariantsExt [
	"GL_MAX_VERTEX_SHADER_VARIANTS_EXT  0x87C6"

	<category: 'constants Ext'>
	^34758
    ]

    glMaxVertexShaderInvariantsExt [
	"GL_MAX_VERTEX_SHADER_INVARIANTS_EXT  0x87C7"

	<category: 'constants Ext'>
	^34759
    ]

    glMaxVertexShaderLocalConstantsExt [
	"GL_MAX_VERTEX_SHADER_LOCAL_CONSTANTS_EXT  0x87C8"

	<category: 'constants Ext'>
	^34760
    ]

    glMaxVertexShaderLocalsExt [
	"GL_MAX_VERTEX_SHADER_LOCALS_EXT  0x87C9"

	<category: 'constants Ext'>
	^34761
    ]

    glMaxOptimizedVertexShaderInstructionsExt [
	"GL_MAX_OPTIMIZED_VERTEX_SHADER_INSTRUCTIONS_EXT  0x87CA"

	<category: 'constants Ext'>
	^34762
    ]

    glMaxOptimizedVertexShaderVariantsExt [
	"GL_MAX_OPTIMIZED_VERTEX_SHADER_VARIANTS_EXT  0x87CB"

	<category: 'constants Ext'>
	^34763
    ]

    glMaxOptimizedVertexShaderLocalConstantsExt [
	"GL_MAX_OPTIMIZED_VERTEX_SHADER_LOCAL_CONSTANTS_EXT  0x87CC"

	<category: 'constants Ext'>
	^34764
    ]

    glMaxOptimizedVertexShaderInvariantsExt [
	"GL_MAX_OPTIMIZED_VERTEX_SHADER_INVARIANTS_EXT  0x87CD"

	<category: 'constants Ext'>
	^34765
    ]

    glMaxOptimizedVertexShaderLocalsExt [
	"GL_MAX_OPTIMIZED_VERTEX_SHADER_LOCALS_EXT  0x87CE"

	<category: 'constants Ext'>
	^34766
    ]

    glVertexShaderInstructionsExt [
	"GL_VERTEX_SHADER_INSTRUCTIONS_EXT  0x87CF"

	<category: 'constants Ext'>
	^34767
    ]

    glVertexShaderVariantsExt [
	"GL_VERTEX_SHADER_VARIANTS_EXT  0x87D0"

	<category: 'constants Ext'>
	^34768
    ]

    glVertexShaderInvariantsExt [
	"GL_VERTEX_SHADER_INVARIANTS_EXT  0x87D1"

	<category: 'constants Ext'>
	^34769
    ]

    glVertexShaderLocalConstantsExt [
	"GL_VERTEX_SHADER_LOCAL_CONSTANTS_EXT  0x87D2"

	<category: 'constants Ext'>
	^34770
    ]

    glVertexShaderLocalsExt [
	"GL_VERTEX_SHADER_LOCALS_EXT  0x87D3"

	<category: 'constants Ext'>
	^34771
    ]

    glVertexShaderOptimizedExt [
	"GL_VERTEX_SHADER_OPTIMIZED_EXT  0x87D4"

	<category: 'constants Ext'>
	^34772
    ]

    glXExt [
	"GL_X_EXT  0x87D5"

	<category: 'constants Ext'>
	^34773
    ]

    glYExt [
	"GL_Y_EXT  0x87D6"

	<category: 'constants Ext'>
	^34774
    ]

    glZExt [
	"GL_Z_EXT  0x87D7"

	<category: 'constants Ext'>
	^34775
    ]

    glWExt [
	"GL_W_EXT  0x87D8"

	<category: 'constants Ext'>
	^34776
    ]

    glNegativeXExt [
	"GL_NEGATIVE_X_EXT  0x87D9"

	<category: 'constants Ext'>
	^34777
    ]

    glNegativeYExt [
	"GL_NEGATIVE_Y_EXT  0x87DA"

	<category: 'constants Ext'>
	^34778
    ]

    glNegativeZExt [
	"GL_NEGATIVE_Z_EXT  0x87DB"

	<category: 'constants Ext'>
	^34779
    ]

    glNegativeWExt [
	"GL_NEGATIVE_W_EXT  0x87DC"

	<category: 'constants Ext'>
	^34780
    ]

    glZeroExt [
	"GL_ZERO_EXT  0x87DD"

	<category: 'constants Ext'>
	^34781
    ]

    glOneExt [
	"GL_ONE_EXT  0x87DE"

	<category: 'constants Ext'>
	^34782
    ]

    glNegativeOneExt [
	"GL_NEGATIVE_ONE_EXT  0x87DF"

	<category: 'constants Ext'>
	^34783
    ]

    glNormalizedRangeExt [
	"GL_NORMALIZED_RANGE_EXT  0x87E0"

	<category: 'constants Ext'>
	^34784
    ]

    glFullRangeExt [
	"GL_FULL_RANGE_EXT  0x87E1"

	<category: 'constants Ext'>
	^34785
    ]

    glCurrentVertexExt [
	"GL_CURRENT_VERTEX_EXT  0x87E2"

	<category: 'constants Ext'>
	^34786
    ]

    glMvpMatrixExt [
	"GL_MVP_MATRIX_EXT  0x87E3"

	<category: 'constants Ext'>
	^34787
    ]

    glVariantValueExt [
	"GL_VARIANT_VALUE_EXT  0x87E4"

	<category: 'constants Ext'>
	^34788
    ]

    glVariantDatatypeExt [
	"GL_VARIANT_DATATYPE_EXT  0x87E5"

	<category: 'constants Ext'>
	^34789
    ]

    glVariantArrayStrideExt [
	"GL_VARIANT_ARRAY_STRIDE_EXT  0x87E6"

	<category: 'constants Ext'>
	^34790
    ]

    glVariantArrayTypeExt [
	"GL_VARIANT_ARRAY_TYPE_EXT  0x87E7"

	<category: 'constants Ext'>
	^34791
    ]

    glVariantArrayExt [
	"GL_VARIANT_ARRAY_EXT  0x87E8"

	<category: 'constants Ext'>
	^34792
    ]

    glVariantArrayPointerExt [
	"GL_VARIANT_ARRAY_POINTER_EXT  0x87E9"

	<category: 'constants Ext'>
	^34793
    ]

    glInvariantValueExt [
	"GL_INVARIANT_VALUE_EXT  0x87EA"

	<category: 'constants Ext'>
	^34794
    ]

    glInvariantDatatypeExt [
	"GL_INVARIANT_DATATYPE_EXT  0x87EB"

	<category: 'constants Ext'>
	^34795
    ]

    glLocalConstantValueExt [
	"GL_LOCAL_CONSTANT_VALUE_EXT  0x87EC"

	<category: 'constants Ext'>
	^34796
    ]

    glLocalConstantDatatypeExt [
	"GL_LOCAL_CONSTANT_DATATYPE_EXT  0x87ED"

	<category: 'constants Ext'>
	^34797
    ]

    glMaxVertexStreamsAti [
	"GL_MAX_VERTEX_STREAMS_ATI  0x876B"

	<category: 'constants Ext'>
	^34667
    ]

    glVertexStream0Ati [
	"GL_VERTEX_STREAM0_ATI  0x876C"

	<category: 'constants Ext'>
	^34668
    ]

    glVertexStream1Ati [
	"GL_VERTEX_STREAM1_ATI  0x876D"

	<category: 'constants Ext'>
	^34669
    ]

    glVertexStream2Ati [
	"GL_VERTEX_STREAM2_ATI  0x876E"

	<category: 'constants Ext'>
	^34670
    ]

    glVertexStream3Ati [
	"GL_VERTEX_STREAM3_ATI  0x876F"

	<category: 'constants Ext'>
	^34671
    ]

    glVertexStream4Ati [
	"GL_VERTEX_STREAM4_ATI  0x8770"

	<category: 'constants Ext'>
	^34672
    ]

    glVertexStream5Ati [
	"GL_VERTEX_STREAM5_ATI  0x8771"

	<category: 'constants Ext'>
	^34673
    ]

    glVertexStream6Ati [
	"GL_VERTEX_STREAM6_ATI  0x8772"

	<category: 'constants Ext'>
	^34674
    ]

    glVertexStream7Ati [
	"GL_VERTEX_STREAM7_ATI  0x8773"

	<category: 'constants Ext'>
	^34675
    ]

    glVertexSourceAti [
	"GL_VERTEX_SOURCE_ATI  0x8774"

	<category: 'constants Ext'>
	^34676
    ]

    glElementArrayAti [
	"GL_ELEMENT_ARRAY_ATI  0x8768"

	<category: 'constants Ext'>
	^34664
    ]

    glElementArrayTypeAti [
	"GL_ELEMENT_ARRAY_TYPE_ATI  0x8769"

	<category: 'constants Ext'>
	^34665
    ]

    glElementArrayPointerAti [
	"GL_ELEMENT_ARRAY_POINTER_ATI  0x876A"

	<category: 'constants Ext'>
	^34666
    ]

    glQuadMeshSun [
	"GL_QUAD_MESH_SUN  0x8614"

	<category: 'constants Ext'>
	^34324
    ]

    glTriangleMeshSun [
	"GL_TRIANGLE_MESH_SUN  0x8615"

	<category: 'constants Ext'>
	^34325
    ]

    glSliceAccumSun [
	"GL_SLICE_ACCUM_SUN  0x85CC"

	<category: 'constants Ext'>
	^34252
    ]

    glMultisampleFilterHintNv [
	"GL_MULTISAMPLE_FILTER_HINT_NV  0x8534"

	<category: 'constants Ext'>
	^34100
    ]

    glDepthClampNv [
	"GL_DEPTH_CLAMP_NV  0x864F"

	<category: 'constants Ext'>
	^34383
    ]

    glPixelCounterBitsNv [
	"GL_PIXEL_COUNTER_BITS_NV  0x8864"

	<category: 'constants Ext'>
	^34916
    ]

    glCurrentOcclusionQueryIdNv [
	"GL_CURRENT_OCCLUSION_QUERY_ID_NV  0x8865"

	<category: 'constants Ext'>
	^34917
    ]

    glPixelCountNv [
	"GL_PIXEL_COUNT_NV  0x8866"

	<category: 'constants Ext'>
	^34918
    ]

    glPixelCountAvailableNv [
	"GL_PIXEL_COUNT_AVAILABLE_NV  0x8867"

	<category: 'constants Ext'>
	^34919
    ]

    glPointSpriteNv [
	"GL_POINT_SPRITE_NV  0x8861"

	<category: 'constants Ext'>
	^34913
    ]

    glCoordReplaceNv [
	"GL_COORD_REPLACE_NV  0x8862"

	<category: 'constants Ext'>
	^34914
    ]

    glPointSpriteRModeNv [
	"GL_POINT_SPRITE_R_MODE_NV  0x8863"

	<category: 'constants Ext'>
	^34915
    ]

    glOffsetProjectiveTexture2dNv [
	"GL_OFFSET_PROJECTIVE_TEXTURE_2D_NV  0x8850"

	<category: 'constants Ext'>
	^34896
    ]

    glOffsetProjectiveTexture2dScaleNv [
	"GL_OFFSET_PROJECTIVE_TEXTURE_2D_SCALE_NV  0x8851"

	<category: 'constants Ext'>
	^34897
    ]

    glOffsetProjectiveTextureRectangleNv [
	"GL_OFFSET_PROJECTIVE_TEXTURE_RECTANGLE_NV  0x8852"

	<category: 'constants Ext'>
	^34898
    ]

    glOffsetProjectiveTextureRectangleScaleNv [
	"GL_OFFSET_PROJECTIVE_TEXTURE_RECTANGLE_SCALE_NV  0x8853"

	<category: 'constants Ext'>
	^34899
    ]

    glOffsetHiloTexture2dNv [
	"GL_OFFSET_HILO_TEXTURE_2D_NV  0x8854"

	<category: 'constants Ext'>
	^34900
    ]

    glOffsetHiloTextureRectangleNv [
	"GL_OFFSET_HILO_TEXTURE_RECTANGLE_NV  0x8855"

	<category: 'constants Ext'>
	^34901
    ]

    glOffsetHiloProjectiveTexture2dNv [
	"GL_OFFSET_HILO_PROJECTIVE_TEXTURE_2D_NV  0x8856"

	<category: 'constants Ext'>
	^34902
    ]

    glOffsetHiloProjectiveTextureRectangleNv [
	"GL_OFFSET_HILO_PROJECTIVE_TEXTURE_RECTANGLE_NV  0x8857"

	<category: 'constants Ext'>
	^34903
    ]

    glDependentHiloTexture2dNv [
	"GL_DEPENDENT_HILO_TEXTURE_2D_NV  0x8858"

	<category: 'constants Ext'>
	^34904
    ]

    glDependentRgbTexture3dNv [
	"GL_DEPENDENT_RGB_TEXTURE_3D_NV  0x8859"

	<category: 'constants Ext'>
	^34905
    ]

    glDependentRgbTextureCubeMapNv [
	"GL_DEPENDENT_RGB_TEXTURE_CUBE_MAP_NV  0x885A"

	<category: 'constants Ext'>
	^34906
    ]

    glDotProductPassThroughNv [
	"GL_DOT_PRODUCT_PASS_THROUGH_NV  0x885B"

	<category: 'constants Ext'>
	^34907
    ]

    glDotProductTexture1dNv [
	"GL_DOT_PRODUCT_TEXTURE_1D_NV  0x885C"

	<category: 'constants Ext'>
	^34908
    ]

    glDotProductAffineDepthReplaceNv [
	"GL_DOT_PRODUCT_AFFINE_DEPTH_REPLACE_NV  0x885D"

	<category: 'constants Ext'>
	^34909
    ]

    glHilo8Nv [
	"GL_HILO8_NV  0x885E"

	<category: 'constants Ext'>
	^34910
    ]

    glSignedHilo8Nv [
	"GL_SIGNED_HILO8_NV  0x885F"

	<category: 'constants Ext'>
	^34911
    ]

    glForceBlueToOneNv [
	"GL_FORCE_BLUE_TO_ONE_NV  0x8860"

	<category: 'constants Ext'>
	^34912
    ]

    glStencilTestTwoSideExt [
	"GL_STENCIL_TEST_TWO_SIDE_EXT  0x8910"

	<category: 'constants Ext'>
	^35088
    ]

    glActiveStencilFaceExt [
	"GL_ACTIVE_STENCIL_FACE_EXT  0x8911"

	<category: 'constants Ext'>
	^35089
    ]

    glTextFragmentShaderAti [
	"GL_TEXT_FRAGMENT_SHADER_ATI  0x8200"

	<category: 'constants Ext'>
	^33280
    ]

    glUnpackClientStorageApple [
	"GL_UNPACK_CLIENT_STORAGE_APPLE  0x85B2"

	<category: 'constants Ext'>
	^34226
    ]

    glElementArrayApple [
	"GL_ELEMENT_ARRAY_APPLE  0x8768"

	<category: 'constants Ext'>
	^34664
    ]

    glElementArrayTypeApple [
	"GL_ELEMENT_ARRAY_TYPE_APPLE  0x8769"

	<category: 'constants Ext'>
	^34665
    ]

    glElementArrayPointerApple [
	"GL_ELEMENT_ARRAY_POINTER_APPLE  0x876A"

	<category: 'constants Ext'>
	^34666
    ]

    glDrawPixelsApple [
	"GL_DRAW_PIXELS_APPLE  0x8A0A"

	<category: 'constants Ext'>
	^35338
    ]

    glFenceApple [
	"GL_FENCE_APPLE  0x8A0B"

	<category: 'constants Ext'>
	^35339
    ]

    glVertexArrayBindingApple [
	"GL_VERTEX_ARRAY_BINDING_APPLE  0x85B5"

	<category: 'constants Ext'>
	^34229
    ]

    glVertexArrayRangeApple [
	"GL_VERTEX_ARRAY_RANGE_APPLE  0x851D"

	<category: 'constants Ext'>
	^34077
    ]

    glVertexArrayRangeLengthApple [
	"GL_VERTEX_ARRAY_RANGE_LENGTH_APPLE  0x851E"

	<category: 'constants Ext'>
	^34078
    ]

    glVertexArrayStorageHintApple [
	"GL_VERTEX_ARRAY_STORAGE_HINT_APPLE  0x851F"

	<category: 'constants Ext'>
	^34079
    ]

    glVertexArrayRangePointerApple [
	"GL_VERTEX_ARRAY_RANGE_POINTER_APPLE  0x8521"

	<category: 'constants Ext'>
	^34081
    ]

    glTextureStorageHintApple [
	"GL_TEXTURE_STORAGE_HINT_APPLE  0x85BC"

	<category: 'constants Ext'>
	^34236
    ]

    glStoragePrivateApple [
	"GL_STORAGE_PRIVATE_APPLE  0x85BD"

	<category: 'constants Ext'>
	^34237
    ]

    glStorageCachedApple [
	"GL_STORAGE_CACHED_APPLE  0x85BE"

	<category: 'constants Ext'>
	^34238
    ]

    glStorageSharedApple [
	"GL_STORAGE_SHARED_APPLE  0x85BF"

	<category: 'constants Ext'>
	^34239
    ]

    glYcbcr422Apple [
	"GL_YCBCR_422_APPLE  0x85B9"

	<category: 'constants Ext'>
	^34233
    ]

    glUnsignedShort88Apple [
	"GL_UNSIGNED_SHORT_8_8_APPLE  0x85BA"

	<category: 'constants Ext'>
	^34234
    ]

    glUnsignedShort88RevApple [
	"GL_UNSIGNED_SHORT_8_8_REV_APPLE  0x85BB"

	<category: 'constants Ext'>
	^34235
    ]

    glRgbS3tc [
	"GL_RGB_S3TC  0x83A0"

	<category: 'constants Ext'>
	^33696
    ]

    glRgb4S3tc [
	"GL_RGB4_S3TC  0x83A1"

	<category: 'constants Ext'>
	^33697
    ]

    glRgbaS3tc [
	"GL_RGBA_S3TC  0x83A2"

	<category: 'constants Ext'>
	^33698
    ]

    glRgba4S3tc [
	"GL_RGBA4_S3TC  0x83A3"

	<category: 'constants Ext'>
	^33699
    ]

    glMaxDrawBuffersAti [
	"GL_MAX_DRAW_BUFFERS_ATI  0x8824"

	<category: 'constants Ext'>
	^34852
    ]

    glDrawBuffer0Ati [
	"GL_DRAW_BUFFER0_ATI  0x8825"

	<category: 'constants Ext'>
	^34853
    ]

    glDrawBuffer1Ati [
	"GL_DRAW_BUFFER1_ATI  0x8826"

	<category: 'constants Ext'>
	^34854
    ]

    glDrawBuffer2Ati [
	"GL_DRAW_BUFFER2_ATI  0x8827"

	<category: 'constants Ext'>
	^34855
    ]

    glDrawBuffer3Ati [
	"GL_DRAW_BUFFER3_ATI  0x8828"

	<category: 'constants Ext'>
	^34856
    ]

    glDrawBuffer4Ati [
	"GL_DRAW_BUFFER4_ATI  0x8829"

	<category: 'constants Ext'>
	^34857
    ]

    glDrawBuffer5Ati [
	"GL_DRAW_BUFFER5_ATI  0x882A"

	<category: 'constants Ext'>
	^34858
    ]

    glDrawBuffer6Ati [
	"GL_DRAW_BUFFER6_ATI  0x882B"

	<category: 'constants Ext'>
	^34859
    ]

    glDrawBuffer7Ati [
	"GL_DRAW_BUFFER7_ATI  0x882C"

	<category: 'constants Ext'>
	^34860
    ]

    glDrawBuffer8Ati [
	"GL_DRAW_BUFFER8_ATI  0x882D"

	<category: 'constants Ext'>
	^34861
    ]

    glDrawBuffer9Ati [
	"GL_DRAW_BUFFER9_ATI  0x882E"

	<category: 'constants Ext'>
	^34862
    ]

    glDrawBuffer10Ati [
	"GL_DRAW_BUFFER10_ATI  0x882F"

	<category: 'constants Ext'>
	^34863
    ]

    glDrawBuffer11Ati [
	"GL_DRAW_BUFFER11_ATI  0x8830"

	<category: 'constants Ext'>
	^34864
    ]

    glDrawBuffer12Ati [
	"GL_DRAW_BUFFER12_ATI  0x8831"

	<category: 'constants Ext'>
	^34865
    ]

    glDrawBuffer13Ati [
	"GL_DRAW_BUFFER13_ATI  0x8832"

	<category: 'constants Ext'>
	^34866
    ]

    glDrawBuffer14Ati [
	"GL_DRAW_BUFFER14_ATI  0x8833"

	<category: 'constants Ext'>
	^34867
    ]

    glDrawBuffer15Ati [
	"GL_DRAW_BUFFER15_ATI  0x8834"

	<category: 'constants Ext'>
	^34868
    ]

    glTypeRgbaFloatAti [
	"GL_TYPE_RGBA_FLOAT_ATI  0x8820"

	<category: 'constants Ext'>
	^34848
    ]

    glColorClearUnclampedValueAti [
	"GL_COLOR_CLEAR_UNCLAMPED_VALUE_ATI  0x8835"

	<category: 'constants Ext'>
	^34869
    ]

    glModulateAddAti [
	"GL_MODULATE_ADD_ATI  0x8744"

	<category: 'constants Ext'>
	^34628
    ]

    glModulateSignedAddAti [
	"GL_MODULATE_SIGNED_ADD_ATI  0x8745"

	<category: 'constants Ext'>
	^34629
    ]

    glModulateSubtractAti [
	"GL_MODULATE_SUBTRACT_ATI  0x8746"

	<category: 'constants Ext'>
	^34630
    ]

    glRgbaFloat32Ati [
	"GL_RGBA_FLOAT32_ATI  0x8814"

	<category: 'constants Ext'>
	^34836
    ]

    glRgbFloat32Ati [
	"GL_RGB_FLOAT32_ATI  0x8815"

	<category: 'constants Ext'>
	^34837
    ]

    glAlphaFloat32Ati [
	"GL_ALPHA_FLOAT32_ATI  0x8816"

	<category: 'constants Ext'>
	^34838
    ]

    glIntensityFloat32Ati [
	"GL_INTENSITY_FLOAT32_ATI  0x8817"

	<category: 'constants Ext'>
	^34839
    ]

    glLuminanceFloat32Ati [
	"GL_LUMINANCE_FLOAT32_ATI  0x8818"

	<category: 'constants Ext'>
	^34840
    ]

    glLuminanceAlphaFloat32Ati [
	"GL_LUMINANCE_ALPHA_FLOAT32_ATI  0x8819"

	<category: 'constants Ext'>
	^34841
    ]

    glRgbaFloat16Ati [
	"GL_RGBA_FLOAT16_ATI  0x881A"

	<category: 'constants Ext'>
	^34842
    ]

    glRgbFloat16Ati [
	"GL_RGB_FLOAT16_ATI  0x881B"

	<category: 'constants Ext'>
	^34843
    ]

    glAlphaFloat16Ati [
	"GL_ALPHA_FLOAT16_ATI  0x881C"

	<category: 'constants Ext'>
	^34844
    ]

    glIntensityFloat16Ati [
	"GL_INTENSITY_FLOAT16_ATI  0x881D"

	<category: 'constants Ext'>
	^34845
    ]

    glLuminanceFloat16Ati [
	"GL_LUMINANCE_FLOAT16_ATI  0x881E"

	<category: 'constants Ext'>
	^34846
    ]

    glLuminanceAlphaFloat16Ati [
	"GL_LUMINANCE_ALPHA_FLOAT16_ATI  0x881F"

	<category: 'constants Ext'>
	^34847
    ]

    glFloatRNv [
	"GL_FLOAT_R_NV  0x8880"

	<category: 'constants Ext'>
	^34944
    ]

    glFloatRgNv [
	"GL_FLOAT_RG_NV  0x8881"

	<category: 'constants Ext'>
	^34945
    ]

    glFloatRgbNv [
	"GL_FLOAT_RGB_NV  0x8882"

	<category: 'constants Ext'>
	^34946
    ]

    glFloatRgbaNv [
	"GL_FLOAT_RGBA_NV  0x8883"

	<category: 'constants Ext'>
	^34947
    ]

    glFloatR16Nv [
	"GL_FLOAT_R16_NV  0x8884"

	<category: 'constants Ext'>
	^34948
    ]

    glFloatR32Nv [
	"GL_FLOAT_R32_NV  0x8885"

	<category: 'constants Ext'>
	^34949
    ]

    glFloatRg16Nv [
	"GL_FLOAT_RG16_NV  0x8886"

	<category: 'constants Ext'>
	^34950
    ]

    glFloatRg32Nv [
	"GL_FLOAT_RG32_NV  0x8887"

	<category: 'constants Ext'>
	^34951
    ]

    glFloatRgb16Nv [
	"GL_FLOAT_RGB16_NV  0x8888"

	<category: 'constants Ext'>
	^34952
    ]

    glFloatRgb32Nv [
	"GL_FLOAT_RGB32_NV  0x8889"

	<category: 'constants Ext'>
	^34953
    ]

    glFloatRgba16Nv [
	"GL_FLOAT_RGBA16_NV  0x888A"

	<category: 'constants Ext'>
	^34954
    ]

    glFloatRgba32Nv [
	"GL_FLOAT_RGBA32_NV  0x888B"

	<category: 'constants Ext'>
	^34955
    ]

    glTextureFloatComponentsNv [
	"GL_TEXTURE_FLOAT_COMPONENTS_NV  0x888C"

	<category: 'constants Ext'>
	^34956
    ]

    glFloatClearColorValueNv [
	"GL_FLOAT_CLEAR_COLOR_VALUE_NV  0x888D"

	<category: 'constants Ext'>
	^34957
    ]

    glFloatRgbaModeNv [
	"GL_FLOAT_RGBA_MODE_NV  0x888E"

	<category: 'constants Ext'>
	^34958
    ]

    glMaxFragmentProgramLocalParametersNv [
	"GL_MAX_FRAGMENT_PROGRAM_LOCAL_PARAMETERS_NV  0x8868"

	<category: 'constants Ext'>
	^34920
    ]

    glFragmentProgramNv [
	"GL_FRAGMENT_PROGRAM_NV  0x8870"

	<category: 'constants Ext'>
	^34928
    ]

    glMaxTextureCoordsNv [
	"GL_MAX_TEXTURE_COORDS_NV  0x8871"

	<category: 'constants Ext'>
	^34929
    ]

    glMaxTextureImageUnitsNv [
	"GL_MAX_TEXTURE_IMAGE_UNITS_NV  0x8872"

	<category: 'constants Ext'>
	^34930
    ]

    glFragmentProgramBindingNv [
	"GL_FRAGMENT_PROGRAM_BINDING_NV  0x8873"

	<category: 'constants Ext'>
	^34931
    ]

    glProgramErrorStringNv [
	"GL_PROGRAM_ERROR_STRING_NV  0x8874"

	<category: 'constants Ext'>
	^34932
    ]

    glHalfFloatNv [
	"GL_HALF_FLOAT_NV  0x140B"

	<category: 'constants Ext'>
	^5131
    ]

    glWritePixelDataRangeNv [
	"GL_WRITE_PIXEL_DATA_RANGE_NV  0x8878"

	<category: 'constants Ext'>
	^34936
    ]

    glReadPixelDataRangeNv [
	"GL_READ_PIXEL_DATA_RANGE_NV  0x8879"

	<category: 'constants Ext'>
	^34937
    ]

    glWritePixelDataRangeLengthNv [
	"GL_WRITE_PIXEL_DATA_RANGE_LENGTH_NV  0x887A"

	<category: 'constants Ext'>
	^34938
    ]

    glReadPixelDataRangeLengthNv [
	"GL_READ_PIXEL_DATA_RANGE_LENGTH_NV  0x887B"

	<category: 'constants Ext'>
	^34939
    ]

    glWritePixelDataRangePointerNv [
	"GL_WRITE_PIXEL_DATA_RANGE_POINTER_NV  0x887C"

	<category: 'constants Ext'>
	^34940
    ]

    glReadPixelDataRangePointerNv [
	"GL_READ_PIXEL_DATA_RANGE_POINTER_NV  0x887D"

	<category: 'constants Ext'>
	^34941
    ]

    glPrimitiveRestartNv [
	"GL_PRIMITIVE_RESTART_NV  0x8558"

	<category: 'constants Ext'>
	^34136
    ]

    glPrimitiveRestartIndexNv [
	"GL_PRIMITIVE_RESTART_INDEX_NV  0x8559"

	<category: 'constants Ext'>
	^34137
    ]

    glTextureUnsignedRemapModeNv [
	"GL_TEXTURE_UNSIGNED_REMAP_MODE_NV  0x888F"

	<category: 'constants Ext'>
	^34959
    ]

    glStencilBackFuncAti [
	"GL_STENCIL_BACK_FUNC_ATI  0x8800"

	<category: 'constants Ext'>
	^34816
    ]

    glStencilBackFailAti [
	"GL_STENCIL_BACK_FAIL_ATI  0x8801"

	<category: 'constants Ext'>
	^34817
    ]

    glStencilBackPassDepthFailAti [
	"GL_STENCIL_BACK_PASS_DEPTH_FAIL_ATI  0x8802"

	<category: 'constants Ext'>
	^34818
    ]

    glStencilBackPassDepthPassAti [
	"GL_STENCIL_BACK_PASS_DEPTH_PASS_ATI  0x8803"

	<category: 'constants Ext'>
	^34819
    ]

    glImplementationColorReadTypeOes [
	"GL_IMPLEMENTATION_COLOR_READ_TYPE_OES  0x8B9A"

	<category: 'constants Ext'>
	^35738
    ]

    glImplementationColorReadFormatOes [
	"GL_IMPLEMENTATION_COLOR_READ_FORMAT_OES  0x8B9B"

	<category: 'constants Ext'>
	^35739
    ]

    glDepthBoundsTestExt [
	"GL_DEPTH_BOUNDS_TEST_EXT  0x8890"

	<category: 'constants Ext'>
	^34960
    ]

    glDepthBoundsExt [
	"GL_DEPTH_BOUNDS_EXT  0x8891"

	<category: 'constants Ext'>
	^34961
    ]

    glMirrorClampExt [
	"GL_MIRROR_CLAMP_EXT  0x8742"

	<category: 'constants Ext'>
	^34626
    ]

    glMirrorClampToEdgeExt [
	"GL_MIRROR_CLAMP_TO_EDGE_EXT  0x8743"

	<category: 'constants Ext'>
	^34627
    ]

    glMirrorClampToBorderExt [
	"GL_MIRROR_CLAMP_TO_BORDER_EXT  0x8912"

	<category: 'constants Ext'>
	^35090
    ]

    glBlendEquationRgbExt [
	"GL_BLEND_EQUATION_RGB_EXT  GL_BLEND_EQUATION"

	<category: 'constants Ext'>
	^111413140100000
    ]

    glBlendEquationAlphaExt [
	"GL_BLEND_EQUATION_ALPHA_EXT  0x883D"

	<category: 'constants Ext'>
	^34877
    ]

    glPackInvertMesa [
	"GL_PACK_INVERT_MESA  0x8758"

	<category: 'constants Ext'>
	^34648
    ]

    glUnsignedShort88Mesa [
	"GL_UNSIGNED_SHORT_8_8_MESA  0x85BA"

	<category: 'constants Ext'>
	^34234
    ]

    glUnsignedShort88RevMesa [
	"GL_UNSIGNED_SHORT_8_8_REV_MESA  0x85BB"

	<category: 'constants Ext'>
	^34235
    ]

    glYcbcrMesa [
	"GL_YCBCR_MESA  0x8757"

	<category: 'constants Ext'>
	^34647
    ]

    glPixelPackBufferExt [
	"GL_PIXEL_PACK_BUFFER_EXT  0x88EB"

	<category: 'constants Ext'>
	^35051
    ]

    glPixelUnpackBufferExt [
	"GL_PIXEL_UNPACK_BUFFER_EXT  0x88EC"

	<category: 'constants Ext'>
	^35052
    ]

    glPixelPackBufferBindingExt [
	"GL_PIXEL_PACK_BUFFER_BINDING_EXT  0x88ED"

	<category: 'constants Ext'>
	^35053
    ]

    glPixelUnpackBufferBindingExt [
	"GL_PIXEL_UNPACK_BUFFER_BINDING_EXT  0x88EF"

	<category: 'constants Ext'>
	^35055
    ]

    glMaxProgramExecInstructionsNv [
	"GL_MAX_PROGRAM_EXEC_INSTRUCTIONS_NV  0x88F4"

	<category: 'constants Ext'>
	^35060
    ]

    glMaxProgramCallDepthNv [
	"GL_MAX_PROGRAM_CALL_DEPTH_NV  0x88F5"

	<category: 'constants Ext'>
	^35061
    ]

    glMaxProgramIfDepthNv [
	"GL_MAX_PROGRAM_IF_DEPTH_NV  0x88F6"

	<category: 'constants Ext'>
	^35062
    ]

    glMaxProgramLoopDepthNv [
	"GL_MAX_PROGRAM_LOOP_DEPTH_NV  0x88F7"

	<category: 'constants Ext'>
	^35063
    ]

    glMaxProgramLoopCountNv [
	"GL_MAX_PROGRAM_LOOP_COUNT_NV  0x88F8"

	<category: 'constants Ext'>
	^35064
    ]

    glInvalidFramebufferOperationExt [
	"GL_INVALID_FRAMEBUFFER_OPERATION_EXT  0x0506"

	<category: 'constants Ext'>
	^1286
    ]

    glMaxRenderbufferSizeExt [
	"GL_MAX_RENDERBUFFER_SIZE_EXT  0x84E8"

	<category: 'constants Ext'>
	^34024
    ]

    glFramebufferBindingExt [
	"GL_FRAMEBUFFER_BINDING_EXT  0x8CA6"

	<category: 'constants Ext'>
	^36006
    ]

    glRenderbufferBindingExt [
	"GL_RENDERBUFFER_BINDING_EXT  0x8CA7"

	<category: 'constants Ext'>
	^36007
    ]

    glFramebufferAttachmentObjectTypeExt [
	"GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE_EXT  0x8CD0"

	<category: 'constants Ext'>
	^36048
    ]

    glFramebufferAttachmentObjectNameExt [
	"GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME_EXT  0x8CD1"

	<category: 'constants Ext'>
	^36049
    ]

    glFramebufferAttachmentTextureLevelExt [
	"GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL_EXT  0x8CD2"

	<category: 'constants Ext'>
	^36050
    ]

    glFramebufferAttachmentTextureCubeMapFaceExt [
	"GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE_EXT  0x8CD3"

	<category: 'constants Ext'>
	^36051
    ]

    glFramebufferAttachmentTexture3dZoffsetExt [
	"GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_3D_ZOFFSET_EXT  0x8CD4"

	<category: 'constants Ext'>
	^36052
    ]

    glFramebufferCompleteExt [
	"GL_FRAMEBUFFER_COMPLETE_EXT  0x8CD5"

	<category: 'constants Ext'>
	^36053
    ]

    glFramebufferIncompleteAttachmentExt [
	"GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT  0x8CD6"

	<category: 'constants Ext'>
	^36054
    ]

    glFramebufferIncompleteMissingAttachmentExt [
	"GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT  0x8CD7"

	<category: 'constants Ext'>
	^36055
    ]

    glFramebufferIncompleteDimensionsExt [
	"GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT  0x8CD9"

	<category: 'constants Ext'>
	^36057
    ]

    glFramebufferIncompleteFormatsExt [
	"GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT  0x8CDA"

	<category: 'constants Ext'>
	^36058
    ]

    glFramebufferIncompleteDrawBufferExt [
	"GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT  0x8CDB"

	<category: 'constants Ext'>
	^36059
    ]

    glFramebufferIncompleteReadBufferExt [
	"GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT  0x8CDC"

	<category: 'constants Ext'>
	^36060
    ]

    glFramebufferUnsupportedExt [
	"GL_FRAMEBUFFER_UNSUPPORTED_EXT  0x8CDD"

	<category: 'constants Ext'>
	^36061
    ]

    glMaxColorAttachmentsExt [
	"GL_MAX_COLOR_ATTACHMENTS_EXT  0x8CDF"

	<category: 'constants Ext'>
	^36063
    ]

    glColorAttachment0Ext [
	"GL_COLOR_ATTACHMENT0_EXT  0x8CE0"

	<category: 'constants Ext'>
	^36064
    ]

    glColorAttachment1Ext [
	"GL_COLOR_ATTACHMENT1_EXT  0x8CE1"

	<category: 'constants Ext'>
	^36065
    ]

    glColorAttachment2Ext [
	"GL_COLOR_ATTACHMENT2_EXT  0x8CE2"

	<category: 'constants Ext'>
	^36066
    ]

    glColorAttachment3Ext [
	"GL_COLOR_ATTACHMENT3_EXT  0x8CE3"

	<category: 'constants Ext'>
	^36067
    ]

    glColorAttachment4Ext [
	"GL_COLOR_ATTACHMENT4_EXT  0x8CE4"

	<category: 'constants Ext'>
	^36068
    ]

    glColorAttachment5Ext [
	"GL_COLOR_ATTACHMENT5_EXT  0x8CE5"

	<category: 'constants Ext'>
	^36069
    ]

    glColorAttachment6Ext [
	"GL_COLOR_ATTACHMENT6_EXT  0x8CE6"

	<category: 'constants Ext'>
	^36070
    ]

    glColorAttachment7Ext [
	"GL_COLOR_ATTACHMENT7_EXT  0x8CE7"

	<category: 'constants Ext'>
	^36071
    ]

    glColorAttachment8Ext [
	"GL_COLOR_ATTACHMENT8_EXT  0x8CE8"

	<category: 'constants Ext'>
	^36072
    ]

    glColorAttachment9Ext [
	"GL_COLOR_ATTACHMENT9_EXT  0x8CE9"

	<category: 'constants Ext'>
	^36073
    ]

    glColorAttachment10Ext [
	"GL_COLOR_ATTACHMENT10_EXT  0x8CEA"

	<category: 'constants Ext'>
	^36074
    ]

    glColorAttachment11Ext [
	"GL_COLOR_ATTACHMENT11_EXT  0x8CEB"

	<category: 'constants Ext'>
	^36075
    ]

    glColorAttachment12Ext [
	"GL_COLOR_ATTACHMENT12_EXT  0x8CEC"

	<category: 'constants Ext'>
	^36076
    ]

    glColorAttachment13Ext [
	"GL_COLOR_ATTACHMENT13_EXT  0x8CED"

	<category: 'constants Ext'>
	^36077
    ]

    glColorAttachment14Ext [
	"GL_COLOR_ATTACHMENT14_EXT  0x8CEE"

	<category: 'constants Ext'>
	^36078
    ]

    glColorAttachment15Ext [
	"GL_COLOR_ATTACHMENT15_EXT  0x8CEF"

	<category: 'constants Ext'>
	^36079
    ]

    glDepthAttachmentExt [
	"GL_DEPTH_ATTACHMENT_EXT  0x8D00"

	<category: 'constants Ext'>
	^36096
    ]

    glStencilAttachmentExt [
	"GL_STENCIL_ATTACHMENT_EXT  0x8D20"

	<category: 'constants Ext'>
	^36128
    ]

    glFramebufferExt [
	"GL_FRAMEBUFFER_EXT  0x8D40"

	<category: 'constants Ext'>
	^36160
    ]

    glRenderbufferExt [
	"GL_RENDERBUFFER_EXT  0x8D41"

	<category: 'constants Ext'>
	^36161
    ]

    glRenderbufferWidthExt [
	"GL_RENDERBUFFER_WIDTH_EXT  0x8D42"

	<category: 'constants Ext'>
	^36162
    ]

    glRenderbufferHeightExt [
	"GL_RENDERBUFFER_HEIGHT_EXT  0x8D43"

	<category: 'constants Ext'>
	^36163
    ]

    glRenderbufferInternalFormatExt [
	"GL_RENDERBUFFER_INTERNAL_FORMAT_EXT  0x8D44"

	<category: 'constants Ext'>
	^36164
    ]

    glStencilIndex1Ext [
	"GL_STENCIL_INDEX1_EXT  0x8D46"

	<category: 'constants Ext'>
	^36166
    ]

    glStencilIndex4Ext [
	"GL_STENCIL_INDEX4_EXT  0x8D47"

	<category: 'constants Ext'>
	^36167
    ]

    glStencilIndex8Ext [
	"GL_STENCIL_INDEX8_EXT  0x8D48"

	<category: 'constants Ext'>
	^36168
    ]

    glStencilIndex16Ext [
	"GL_STENCIL_INDEX16_EXT  0x8D49"

	<category: 'constants Ext'>
	^36169
    ]

    glRenderbufferRedSizeExt [
	"GL_RENDERBUFFER_RED_SIZE_EXT  0x8D50"

	<category: 'constants Ext'>
	^36176
    ]

    glRenderbufferGreenSizeExt [
	"GL_RENDERBUFFER_GREEN_SIZE_EXT  0x8D51"

	<category: 'constants Ext'>
	^36177
    ]

    glRenderbufferBlueSizeExt [
	"GL_RENDERBUFFER_BLUE_SIZE_EXT  0x8D52"

	<category: 'constants Ext'>
	^36178
    ]

    glRenderbufferAlphaSizeExt [
	"GL_RENDERBUFFER_ALPHA_SIZE_EXT  0x8D53"

	<category: 'constants Ext'>
	^36179
    ]

    glRenderbufferDepthSizeExt [
	"GL_RENDERBUFFER_DEPTH_SIZE_EXT  0x8D54"

	<category: 'constants Ext'>
	^36180
    ]

    glRenderbufferStencilSizeExt [
	"GL_RENDERBUFFER_STENCIL_SIZE_EXT  0x8D55"

	<category: 'constants Ext'>
	^36181
    ]

    glStencilTagBitsExt [
	"GL_STENCIL_TAG_BITS_EXT  0x88F2"

	<category: 'constants Ext'>
	^35058
    ]

    glStencilClearTagValueExt [
	"GL_STENCIL_CLEAR_TAG_VALUE_EXT  0x88F3"

	<category: 'constants Ext'>
	^35059
    ]

    glRenderbufferSamplesExt [
	"GL_RENDERBUFFER_SAMPLES_EXT  0x8CAB"

	<category: 'constants Ext'>
	^36011
    ]

    glFramebufferIncompleteMultisampleExt [
	"GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE_EXT  0x8D56"

	<category: 'constants Ext'>
	^36182
    ]

    glMaxSamplesExt [
	"GL_MAX_SAMPLES_EXT  0x8D57"

	<category: 'constants Ext'>
	^36183
    ]

    glTexture1dStackMesax [
	"GL_TEXTURE_1D_STACK_MESAX  0x8759"

	<category: 'constants Ext'>
	^34649
    ]

    glTexture2dStackMesax [
	"GL_TEXTURE_2D_STACK_MESAX  0x875A"

	<category: 'constants Ext'>
	^34650
    ]

    glProxyTexture1dStackMesax [
	"GL_PROXY_TEXTURE_1D_STACK_MESAX  0x875B"

	<category: 'constants Ext'>
	^34651
    ]

    glProxyTexture2dStackMesax [
	"GL_PROXY_TEXTURE_2D_STACK_MESAX  0x875C"

	<category: 'constants Ext'>
	^34652
    ]

    glTexture1dStackBindingMesax [
	"GL_TEXTURE_1D_STACK_BINDING_MESAX  0x875D"

	<category: 'constants Ext'>
	^34653
    ]

    glTexture2dStackBindingMesax [
	"GL_TEXTURE_2D_STACK_BINDING_MESAX  0x875E"

	<category: 'constants Ext'>
	^34654
    ]

    glBufferSerializedModifyApple [
	"GL_BUFFER_SERIALIZED_MODIFY_APPLE  0x8A12"

	<category: 'constants Ext'>
	^35346
    ]

    glBufferFlushingUnmapApple [
	"GL_BUFFER_FLUSHING_UNMAP_APPLE  0x8A13"

	<category: 'constants Ext'>
	^35347
    ]

    glMinProgramTexelOffsetNv [
	"GL_MIN_PROGRAM_TEXEL_OFFSET_NV  0x8904"

	<category: 'constants Ext'>
	^35076
    ]

    glMaxProgramTexelOffsetNv [
	"GL_MAX_PROGRAM_TEXEL_OFFSET_NV  0x8905"

	<category: 'constants Ext'>
	^35077
    ]

    glProgramAttribComponentsNv [
	"GL_PROGRAM_ATTRIB_COMPONENTS_NV  0x8906"

	<category: 'constants Ext'>
	^35078
    ]

    glProgramResultComponentsNv [
	"GL_PROGRAM_RESULT_COMPONENTS_NV  0x8907"

	<category: 'constants Ext'>
	^35079
    ]

    glMaxProgramAttribComponentsNv [
	"GL_MAX_PROGRAM_ATTRIB_COMPONENTS_NV  0x8908"

	<category: 'constants Ext'>
	^35080
    ]

    glMaxProgramResultComponentsNv [
	"GL_MAX_PROGRAM_RESULT_COMPONENTS_NV  0x8909"

	<category: 'constants Ext'>
	^35081
    ]

    glMaxProgramGenericAttribsNv [
	"GL_MAX_PROGRAM_GENERIC_ATTRIBS_NV  0x8DA5"

	<category: 'constants Ext'>
	^36261
    ]

    glMaxProgramGenericResultsNv [
	"GL_MAX_PROGRAM_GENERIC_RESULTS_NV  0x8DA6"

	<category: 'constants Ext'>
	^36262
    ]

    glLinesAdjacencyExt [
	"GL_LINES_ADJACENCY_EXT  0x000A"

	<category: 'constants Ext'>
	^10
    ]

    glLineStripAdjacencyExt [
	"GL_LINE_STRIP_ADJACENCY_EXT  0x000B"

	<category: 'constants Ext'>
	^11
    ]

    glTrianglesAdjacencyExt [
	"GL_TRIANGLES_ADJACENCY_EXT  0x000C"

	<category: 'constants Ext'>
	^12
    ]

    glTriangleStripAdjacencyExt [
	"GL_TRIANGLE_STRIP_ADJACENCY_EXT  0x000D"

	<category: 'constants Ext'>
	^13
    ]

    glGeometryProgramNv [
	"GL_GEOMETRY_PROGRAM_NV  0x8C26"

	<category: 'constants Ext'>
	^35878
    ]

    glMaxProgramOutputVerticesNv [
	"GL_MAX_PROGRAM_OUTPUT_VERTICES_NV  0x8C27"

	<category: 'constants Ext'>
	^35879
    ]

    glMaxProgramTotalOutputComponentsNv [
	"GL_MAX_PROGRAM_TOTAL_OUTPUT_COMPONENTS_NV  0x8C28"

	<category: 'constants Ext'>
	^35880
    ]

    glGeometryVerticesOutExt [
	"GL_GEOMETRY_VERTICES_OUT_EXT  0x8DDA"

	<category: 'constants Ext'>
	^36314
    ]

    glGeometryInputTypeExt [
	"GL_GEOMETRY_INPUT_TYPE_EXT  0x8DDB"

	<category: 'constants Ext'>
	^36315
    ]

    glGeometryOutputTypeExt [
	"GL_GEOMETRY_OUTPUT_TYPE_EXT  0x8DDC"

	<category: 'constants Ext'>
	^36316
    ]

    glMaxGeometryTextureImageUnitsExt [
	"GL_MAX_GEOMETRY_TEXTURE_IMAGE_UNITS_EXT  0x8C29"

	<category: 'constants Ext'>
	^35881
    ]

    glFramebufferAttachmentLayeredExt [
	"GL_FRAMEBUFFER_ATTACHMENT_LAYERED_EXT  0x8DA7"

	<category: 'constants Ext'>
	^36263
    ]

    glFramebufferIncompleteLayerTargetsExt [
	"GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS_EXT  0x8DA8"

	<category: 'constants Ext'>
	^36264
    ]

    glFramebufferIncompleteLayerCountExt [
	"GL_FRAMEBUFFER_INCOMPLETE_LAYER_COUNT_EXT  0x8DA9"

	<category: 'constants Ext'>
	^36265
    ]

    glFramebufferAttachmentTextureLayerExt [
	"GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER_EXT  0x8CD4"

	<category: 'constants Ext'>
	^36052
    ]

    glProgramPointSizeExt [
	"GL_PROGRAM_POINT_SIZE_EXT  0x8642"

	<category: 'constants Ext'>
	^34370
    ]

    glGeometryShaderExt [
	"GL_GEOMETRY_SHADER_EXT  0x8DD9"

	<category: 'constants Ext'>
	^36313
    ]

    glMaxGeometryVaryingComponentsExt [
	"GL_MAX_GEOMETRY_VARYING_COMPONENTS_EXT  0x8DDD"

	<category: 'constants Ext'>
	^36317
    ]

    glMaxVertexVaryingComponentsExt [
	"GL_MAX_VERTEX_VARYING_COMPONENTS_EXT  0x8DDE"

	<category: 'constants Ext'>
	^36318
    ]

    glMaxVaryingComponentsExt [
	"GL_MAX_VARYING_COMPONENTS_EXT  0x8B4B"

	<category: 'constants Ext'>
	^35659
    ]

    glMaxGeometryUniformComponentsExt [
	"GL_MAX_GEOMETRY_UNIFORM_COMPONENTS_EXT  0x8DDF"

	<category: 'constants Ext'>
	^36319
    ]

    glMaxGeometryOutputVerticesExt [
	"GL_MAX_GEOMETRY_OUTPUT_VERTICES_EXT  0x8DE0"

	<category: 'constants Ext'>
	^36320
    ]

    glMaxGeometryTotalOutputComponentsExt [
	"GL_MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS_EXT  0x8DE1"

	<category: 'constants Ext'>
	^36321
    ]

    glVertexAttribArrayIntegerNv [
	"GL_VERTEX_ATTRIB_ARRAY_INTEGER_NV  0x88FD"

	<category: 'constants Ext'>
	^35069
    ]

    glSampler1dArrayExt [
	"GL_SAMPLER_1D_ARRAY_EXT  0x8DC0"

	<category: 'constants Ext'>
	^36288
    ]

    glSampler2dArrayExt [
	"GL_SAMPLER_2D_ARRAY_EXT  0x8DC1"

	<category: 'constants Ext'>
	^36289
    ]

    glSamplerBufferExt [
	"GL_SAMPLER_BUFFER_EXT  0x8DC2"

	<category: 'constants Ext'>
	^36290
    ]

    glSampler1dArrayShadowExt [
	"GL_SAMPLER_1D_ARRAY_SHADOW_EXT  0x8DC3"

	<category: 'constants Ext'>
	^36291
    ]

    glSampler2dArrayShadowExt [
	"GL_SAMPLER_2D_ARRAY_SHADOW_EXT  0x8DC4"

	<category: 'constants Ext'>
	^36292
    ]

    glSamplerCubeShadowExt [
	"GL_SAMPLER_CUBE_SHADOW_EXT  0x8DC5"

	<category: 'constants Ext'>
	^36293
    ]

    glUnsignedIntVec2Ext [
	"GL_UNSIGNED_INT_VEC2_EXT  0x8DC6"

	<category: 'constants Ext'>
	^36294
    ]

    glUnsignedIntVec3Ext [
	"GL_UNSIGNED_INT_VEC3_EXT  0x8DC7"

	<category: 'constants Ext'>
	^36295
    ]

    glUnsignedIntVec4Ext [
	"GL_UNSIGNED_INT_VEC4_EXT  0x8DC8"

	<category: 'constants Ext'>
	^36296
    ]

    glIntSampler1dExt [
	"GL_INT_SAMPLER_1D_EXT  0x8DC9"

	<category: 'constants Ext'>
	^36297
    ]

    glIntSampler2dExt [
	"GL_INT_SAMPLER_2D_EXT  0x8DCA"

	<category: 'constants Ext'>
	^36298
    ]

    glIntSampler3dExt [
	"GL_INT_SAMPLER_3D_EXT  0x8DCB"

	<category: 'constants Ext'>
	^36299
    ]

    glIntSamplerCubeExt [
	"GL_INT_SAMPLER_CUBE_EXT  0x8DCC"

	<category: 'constants Ext'>
	^36300
    ]

    glIntSampler2dRectExt [
	"GL_INT_SAMPLER_2D_RECT_EXT  0x8DCD"

	<category: 'constants Ext'>
	^36301
    ]

    glIntSampler1dArrayExt [
	"GL_INT_SAMPLER_1D_ARRAY_EXT  0x8DCE"

	<category: 'constants Ext'>
	^36302
    ]

    glIntSampler2dArrayExt [
	"GL_INT_SAMPLER_2D_ARRAY_EXT  0x8DCF"

	<category: 'constants Ext'>
	^36303
    ]

    glIntSamplerBufferExt [
	"GL_INT_SAMPLER_BUFFER_EXT  0x8DD0"

	<category: 'constants Ext'>
	^36304
    ]

    glUnsignedIntSampler1dExt [
	"GL_UNSIGNED_INT_SAMPLER_1D_EXT  0x8DD1"

	<category: 'constants Ext'>
	^36305
    ]

    glUnsignedIntSampler2dExt [
	"GL_UNSIGNED_INT_SAMPLER_2D_EXT  0x8DD2"

	<category: 'constants Ext'>
	^36306
    ]

    glUnsignedIntSampler3dExt [
	"GL_UNSIGNED_INT_SAMPLER_3D_EXT  0x8DD3"

	<category: 'constants Ext'>
	^36307
    ]

    glUnsignedIntSamplerCubeExt [
	"GL_UNSIGNED_INT_SAMPLER_CUBE_EXT  0x8DD4"

	<category: 'constants Ext'>
	^36308
    ]

    glUnsignedIntSampler2dRectExt [
	"GL_UNSIGNED_INT_SAMPLER_2D_RECT_EXT  0x8DD5"

	<category: 'constants Ext'>
	^36309
    ]

    glUnsignedIntSampler1dArrayExt [
	"GL_UNSIGNED_INT_SAMPLER_1D_ARRAY_EXT  0x8DD6"

	<category: 'constants Ext'>
	^36310
    ]

    glUnsignedIntSampler2dArrayExt [
	"GL_UNSIGNED_INT_SAMPLER_2D_ARRAY_EXT  0x8DD7"

	<category: 'constants Ext'>
	^36311
    ]

    glUnsignedIntSamplerBufferExt [
	"GL_UNSIGNED_INT_SAMPLER_BUFFER_EXT  0x8DD8"

	<category: 'constants Ext'>
	^36312
    ]

    glR11fG11fB10fExt [
	"GL_R11F_G11F_B10F_EXT  0x8C3A"

	<category: 'constants Ext'>
	^35898
    ]

    glUnsignedInt10f11f11fRevExt [
	"GL_UNSIGNED_INT_10F_11F_11F_REV_EXT  0x8C3B"

	<category: 'constants Ext'>
	^35899
    ]

    glRgbaSignedComponentsExt [
	"GL_RGBA_SIGNED_COMPONENTS_EXT  0x8C3C"

	<category: 'constants Ext'>
	^35900
    ]

    glTexture1dArrayExt [
	"GL_TEXTURE_1D_ARRAY_EXT  0x8C18"

	<category: 'constants Ext'>
	^35864
    ]

    glProxyTexture1dArrayExt [
	"GL_PROXY_TEXTURE_1D_ARRAY_EXT  0x8C19"

	<category: 'constants Ext'>
	^35865
    ]

    glTexture2dArrayExt [
	"GL_TEXTURE_2D_ARRAY_EXT  0x8C1A"

	<category: 'constants Ext'>
	^35866
    ]

    glProxyTexture2dArrayExt [
	"GL_PROXY_TEXTURE_2D_ARRAY_EXT  0x8C1B"

	<category: 'constants Ext'>
	^35867
    ]

    glTextureBinding1dArrayExt [
	"GL_TEXTURE_BINDING_1D_ARRAY_EXT  0x8C1C"

	<category: 'constants Ext'>
	^35868
    ]

    glTextureBinding2dArrayExt [
	"GL_TEXTURE_BINDING_2D_ARRAY_EXT  0x8C1D"

	<category: 'constants Ext'>
	^35869
    ]

    glMaxArrayTextureLayersExt [
	"GL_MAX_ARRAY_TEXTURE_LAYERS_EXT  0x88FF"

	<category: 'constants Ext'>
	^35071
    ]

    glCompareRefDepthToTextureExt [
	"GL_COMPARE_REF_DEPTH_TO_TEXTURE_EXT  0x884E"

	<category: 'constants Ext'>
	^34894
    ]

    glTextureBufferExt [
	"GL_TEXTURE_BUFFER_EXT  0x8C2A"

	<category: 'constants Ext'>
	^35882
    ]

    glMaxTextureBufferSizeExt [
	"GL_MAX_TEXTURE_BUFFER_SIZE_EXT  0x8C2B"

	<category: 'constants Ext'>
	^35883
    ]

    glTextureBindingBufferExt [
	"GL_TEXTURE_BINDING_BUFFER_EXT  0x8C2C"

	<category: 'constants Ext'>
	^35884
    ]

    glTextureBufferDataStoreBindingExt [
	"GL_TEXTURE_BUFFER_DATA_STORE_BINDING_EXT  0x8C2D"

	<category: 'constants Ext'>
	^35885
    ]

    glTextureBufferFormatExt [
	"GL_TEXTURE_BUFFER_FORMAT_EXT  0x8C2E"

	<category: 'constants Ext'>
	^35886
    ]

    glCompressedLuminanceLatc1Ext [
	"GL_COMPRESSED_LUMINANCE_LATC1_EXT  0x8C70"

	<category: 'constants Ext'>
	^35952
    ]

    glCompressedSignedLuminanceLatc1Ext [
	"GL_COMPRESSED_SIGNED_LUMINANCE_LATC1_EXT  0x8C71"

	<category: 'constants Ext'>
	^35953
    ]

    glCompressedLuminanceAlphaLatc2Ext [
	"GL_COMPRESSED_LUMINANCE_ALPHA_LATC2_EXT  0x8C72"

	<category: 'constants Ext'>
	^35954
    ]

    glCompressedSignedLuminanceAlphaLatc2Ext [
	"GL_COMPRESSED_SIGNED_LUMINANCE_ALPHA_LATC2_EXT  0x8C73"

	<category: 'constants Ext'>
	^35955
    ]

    glCompressedRedRgtc1Ext [
	"GL_COMPRESSED_RED_RGTC1_EXT  0x8DBB"

	<category: 'constants Ext'>
	^36283
    ]

    glCompressedSignedRedRgtc1Ext [
	"GL_COMPRESSED_SIGNED_RED_RGTC1_EXT  0x8DBC"

	<category: 'constants Ext'>
	^36284
    ]

    glCompressedRedGreenRgtc2Ext [
	"GL_COMPRESSED_RED_GREEN_RGTC2_EXT  0x8DBD"

	<category: 'constants Ext'>
	^36285
    ]

    glCompressedSignedRedGreenRgtc2Ext [
	"GL_COMPRESSED_SIGNED_RED_GREEN_RGTC2_EXT  0x8DBE"

	<category: 'constants Ext'>
	^36286
    ]

    glRgb9E5Ext [
	"GL_RGB9_E5_EXT  0x8C3D"

	<category: 'constants Ext'>
	^35901
    ]

    glUnsignedInt5999RevExt [
	"GL_UNSIGNED_INT_5_9_9_9_REV_EXT  0x8C3E"

	<category: 'constants Ext'>
	^35902
    ]

    glTextureSharedSizeExt [
	"GL_TEXTURE_SHARED_SIZE_EXT  0x8C3F"

	<category: 'constants Ext'>
	^35903
    ]

    glDepthComponent32fNv [
	"GL_DEPTH_COMPONENT32F_NV  0x8DAB"

	<category: 'constants Ext'>
	^36267
    ]

    glDepth32fStencil8Nv [
	"GL_DEPTH32F_STENCIL8_NV  0x8DAC"

	<category: 'constants Ext'>
	^36268
    ]

    glFloat32UnsignedInt248RevNv [
	"GL_FLOAT_32_UNSIGNED_INT_24_8_REV_NV  0x8DAD"

	<category: 'constants Ext'>
	^36269
    ]

    glDepthBufferFloatModeNv [
	"GL_DEPTH_BUFFER_FLOAT_MODE_NV  0x8DAF"

	<category: 'constants Ext'>
	^36271
    ]

    glRenderbufferCoverageSamplesNv [
	"GL_RENDERBUFFER_COVERAGE_SAMPLES_NV  0x8CAB"

	<category: 'constants Ext'>
	^36011
    ]

    glRenderbufferColorSamplesNv [
	"GL_RENDERBUFFER_COLOR_SAMPLES_NV  0x8E10"

	<category: 'constants Ext'>
	^36368
    ]

    glMaxMultisampleCoverageModesNv [
	"GL_MAX_MULTISAMPLE_COVERAGE_MODES_NV  0x8E11"

	<category: 'constants Ext'>
	^36369
    ]

    glMultisampleCoverageModesNv [
	"GL_MULTISAMPLE_COVERAGE_MODES_NV  0x8E12"

	<category: 'constants Ext'>
	^36370
    ]

    glFramebufferSrgbExt [
	"GL_FRAMEBUFFER_SRGB_EXT  0x8DB9"

	<category: 'constants Ext'>
	^36281
    ]

    glFramebufferSrgbCapableExt [
	"GL_FRAMEBUFFER_SRGB_CAPABLE_EXT  0x8DBA"

	<category: 'constants Ext'>
	^36282
    ]

    glMaxProgramParameterBufferBindingsNv [
	"GL_MAX_PROGRAM_PARAMETER_BUFFER_BINDINGS_NV  0x8DA0"

	<category: 'constants Ext'>
	^36256
    ]

    glMaxProgramParameterBufferSizeNv [
	"GL_MAX_PROGRAM_PARAMETER_BUFFER_SIZE_NV  0x8DA1"

	<category: 'constants Ext'>
	^36257
    ]

    glVertexProgramParameterBufferNv [
	"GL_VERTEX_PROGRAM_PARAMETER_BUFFER_NV  0x8DA2"

	<category: 'constants Ext'>
	^36258
    ]

    glGeometryProgramParameterBufferNv [
	"GL_GEOMETRY_PROGRAM_PARAMETER_BUFFER_NV  0x8DA3"

	<category: 'constants Ext'>
	^36259
    ]

    glFragmentProgramParameterBufferNv [
	"GL_FRAGMENT_PROGRAM_PARAMETER_BUFFER_NV  0x8DA4"

	<category: 'constants Ext'>
	^36260
    ]

    glBackPrimaryColorNv [
	"GL_BACK_PRIMARY_COLOR_NV  0x8C77"

	<category: 'constants Ext'>
	^35959
    ]

    glBackSecondaryColorNv [
	"GL_BACK_SECONDARY_COLOR_NV  0x8C78"

	<category: 'constants Ext'>
	^35960
    ]

    glTextureCoordNv [
	"GL_TEXTURE_COORD_NV  0x8C79"

	<category: 'constants Ext'>
	^35961
    ]

    glClipDistanceNv [
	"GL_CLIP_DISTANCE_NV  0x8C7A"

	<category: 'constants Ext'>
	^35962
    ]

    glVertexIdNv [
	"GL_VERTEX_ID_NV  0x8C7B"

	<category: 'constants Ext'>
	^35963
    ]

    glPrimitiveIdNv [
	"GL_PRIMITIVE_ID_NV  0x8C7C"

	<category: 'constants Ext'>
	^35964
    ]

    glGenericAttribNv [
	"GL_GENERIC_ATTRIB_NV  0x8C7D"

	<category: 'constants Ext'>
	^35965
    ]

    glTransformFeedbackAttribsNv [
	"GL_TRANSFORM_FEEDBACK_ATTRIBS_NV  0x8C7E"

	<category: 'constants Ext'>
	^35966
    ]

    glTransformFeedbackBufferModeNv [
	"GL_TRANSFORM_FEEDBACK_BUFFER_MODE_NV  0x8C7F"

	<category: 'constants Ext'>
	^35967
    ]

    glMaxTransformFeedbackSeparateComponentsNv [
	"GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS_NV  0x8C80"

	<category: 'constants Ext'>
	^35968
    ]

    glActiveVaryingsNv [
	"GL_ACTIVE_VARYINGS_NV  0x8C81"

	<category: 'constants Ext'>
	^35969
    ]

    glActiveVaryingMaxLengthNv [
	"GL_ACTIVE_VARYING_MAX_LENGTH_NV  0x8C82"

	<category: 'constants Ext'>
	^35970
    ]

    glTransformFeedbackVaryingsNv [
	"GL_TRANSFORM_FEEDBACK_VARYINGS_NV  0x8C83"

	<category: 'constants Ext'>
	^35971
    ]

    glTransformFeedbackBufferStartNv [
	"GL_TRANSFORM_FEEDBACK_BUFFER_START_NV  0x8C84"

	<category: 'constants Ext'>
	^35972
    ]

    glTransformFeedbackBufferSizeNv [
	"GL_TRANSFORM_FEEDBACK_BUFFER_SIZE_NV  0x8C85"

	<category: 'constants Ext'>
	^35973
    ]

    glTransformFeedbackRecordNv [
	"GL_TRANSFORM_FEEDBACK_RECORD_NV  0x8C86"

	<category: 'constants Ext'>
	^35974
    ]

    glPrimitivesGeneratedNv [
	"GL_PRIMITIVES_GENERATED_NV  0x8C87"

	<category: 'constants Ext'>
	^35975
    ]

    glTransformFeedbackPrimitivesWrittenNv [
	"GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN_NV  0x8C88"

	<category: 'constants Ext'>
	^35976
    ]

    glRasterizerDiscardNv [
	"GL_RASTERIZER_DISCARD_NV  0x8C89"

	<category: 'constants Ext'>
	^35977
    ]

    glMaxTransformFeedbackInterleavedAttribsNv [
	"GL_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_ATTRIBS_NV  0x8C8A"

	<category: 'constants Ext'>
	^35978
    ]

    glMaxTransformFeedbackSeparateAttribsNv [
	"GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS_NV  0x8C8B"

	<category: 'constants Ext'>
	^35979
    ]

    glInterleavedAttribsNv [
	"GL_INTERLEAVED_ATTRIBS_NV  0x8C8C"

	<category: 'constants Ext'>
	^35980
    ]

    glSeparateAttribsNv [
	"GL_SEPARATE_ATTRIBS_NV  0x8C8D"

	<category: 'constants Ext'>
	^35981
    ]

    glTransformFeedbackBufferNv [
	"GL_TRANSFORM_FEEDBACK_BUFFER_NV  0x8C8E"

	<category: 'constants Ext'>
	^35982
    ]

    glTransformFeedbackBufferBindingNv [
	"GL_TRANSFORM_FEEDBACK_BUFFER_BINDING_NV  0x8C8F"

	<category: 'constants Ext'>
	^35983
    ]

    glMaxVertexBindableUniformsExt [
	"GL_MAX_VERTEX_BINDABLE_UNIFORMS_EXT  0x8DE2"

	<category: 'constants Ext'>
	^36322
    ]

    glMaxFragmentBindableUniformsExt [
	"GL_MAX_FRAGMENT_BINDABLE_UNIFORMS_EXT  0x8DE3"

	<category: 'constants Ext'>
	^36323
    ]

    glMaxGeometryBindableUniformsExt [
	"GL_MAX_GEOMETRY_BINDABLE_UNIFORMS_EXT  0x8DE4"

	<category: 'constants Ext'>
	^36324
    ]

    glMaxBindableUniformSizeExt [
	"GL_MAX_BINDABLE_UNIFORM_SIZE_EXT  0x8DED"

	<category: 'constants Ext'>
	^36333
    ]

    glUniformBufferExt [
	"GL_UNIFORM_BUFFER_EXT  0x8DEE"

	<category: 'constants Ext'>
	^36334
    ]

    glUniformBufferBindingExt [
	"GL_UNIFORM_BUFFER_BINDING_EXT  0x8DEF"

	<category: 'constants Ext'>
	^36335
    ]

    glRgba32uiExt [
	"GL_RGBA32UI_EXT  0x8D70"

	<category: 'constants Ext'>
	^36208
    ]

    glRgb32uiExt [
	"GL_RGB32UI_EXT  0x8D71"

	<category: 'constants Ext'>
	^36209
    ]

    glAlpha32uiExt [
	"GL_ALPHA32UI_EXT  0x8D72"

	<category: 'constants Ext'>
	^36210
    ]

    glIntensity32uiExt [
	"GL_INTENSITY32UI_EXT  0x8D73"

	<category: 'constants Ext'>
	^36211
    ]

    glLuminance32uiExt [
	"GL_LUMINANCE32UI_EXT  0x8D74"

	<category: 'constants Ext'>
	^36212
    ]

    glLuminanceAlpha32uiExt [
	"GL_LUMINANCE_ALPHA32UI_EXT  0x8D75"

	<category: 'constants Ext'>
	^36213
    ]

    glRgba16uiExt [
	"GL_RGBA16UI_EXT  0x8D76"

	<category: 'constants Ext'>
	^36214
    ]

    glRgb16uiExt [
	"GL_RGB16UI_EXT  0x8D77"

	<category: 'constants Ext'>
	^36215
    ]

    glAlpha16uiExt [
	"GL_ALPHA16UI_EXT  0x8D78"

	<category: 'constants Ext'>
	^36216
    ]

    glIntensity16uiExt [
	"GL_INTENSITY16UI_EXT  0x8D79"

	<category: 'constants Ext'>
	^36217
    ]

    glLuminance16uiExt [
	"GL_LUMINANCE16UI_EXT  0x8D7A"

	<category: 'constants Ext'>
	^36218
    ]

    glLuminanceAlpha16uiExt [
	"GL_LUMINANCE_ALPHA16UI_EXT  0x8D7B"

	<category: 'constants Ext'>
	^36219
    ]

    glRgba8uiExt [
	"GL_RGBA8UI_EXT  0x8D7C"

	<category: 'constants Ext'>
	^36220
    ]

    glRgb8uiExt [
	"GL_RGB8UI_EXT  0x8D7D"

	<category: 'constants Ext'>
	^36221
    ]

    glAlpha8uiExt [
	"GL_ALPHA8UI_EXT  0x8D7E"

	<category: 'constants Ext'>
	^36222
    ]

    glIntensity8uiExt [
	"GL_INTENSITY8UI_EXT  0x8D7F"

	<category: 'constants Ext'>
	^36223
    ]

    glLuminance8uiExt [
	"GL_LUMINANCE8UI_EXT  0x8D80"

	<category: 'constants Ext'>
	^36224
    ]

    glLuminanceAlpha8uiExt [
	"GL_LUMINANCE_ALPHA8UI_EXT  0x8D81"

	<category: 'constants Ext'>
	^36225
    ]

    glRgba32iExt [
	"GL_RGBA32I_EXT  0x8D82"

	<category: 'constants Ext'>
	^36226
    ]

    glRgb32iExt [
	"GL_RGB32I_EXT  0x8D83"

	<category: 'constants Ext'>
	^36227
    ]

    glAlpha32iExt [
	"GL_ALPHA32I_EXT  0x8D84"

	<category: 'constants Ext'>
	^36228
    ]

    glIntensity32iExt [
	"GL_INTENSITY32I_EXT  0x8D85"

	<category: 'constants Ext'>
	^36229
    ]

    glLuminance32iExt [
	"GL_LUMINANCE32I_EXT  0x8D86"

	<category: 'constants Ext'>
	^36230
    ]

    glLuminanceAlpha32iExt [
	"GL_LUMINANCE_ALPHA32I_EXT  0x8D87"

	<category: 'constants Ext'>
	^36231
    ]

    glRgba16iExt [
	"GL_RGBA16I_EXT  0x8D88"

	<category: 'constants Ext'>
	^36232
    ]

    glRgb16iExt [
	"GL_RGB16I_EXT  0x8D89"

	<category: 'constants Ext'>
	^36233
    ]

    glAlpha16iExt [
	"GL_ALPHA16I_EXT  0x8D8A"

	<category: 'constants Ext'>
	^36234
    ]

    glIntensity16iExt [
	"GL_INTENSITY16I_EXT  0x8D8B"

	<category: 'constants Ext'>
	^36235
    ]

    glLuminance16iExt [
	"GL_LUMINANCE16I_EXT  0x8D8C"

	<category: 'constants Ext'>
	^36236
    ]

    glLuminanceAlpha16iExt [
	"GL_LUMINANCE_ALPHA16I_EXT  0x8D8D"

	<category: 'constants Ext'>
	^36237
    ]

    glRgba8iExt [
	"GL_RGBA8I_EXT  0x8D8E"

	<category: 'constants Ext'>
	^36238
    ]

    glRgb8iExt [
	"GL_RGB8I_EXT  0x8D8F"

	<category: 'constants Ext'>
	^36239
    ]

    glAlpha8iExt [
	"GL_ALPHA8I_EXT  0x8D90"

	<category: 'constants Ext'>
	^36240
    ]

    glIntensity8iExt [
	"GL_INTENSITY8I_EXT  0x8D91"

	<category: 'constants Ext'>
	^36241
    ]

    glLuminance8iExt [
	"GL_LUMINANCE8I_EXT  0x8D92"

	<category: 'constants Ext'>
	^36242
    ]

    glLuminanceAlpha8iExt [
	"GL_LUMINANCE_ALPHA8I_EXT  0x8D93"

	<category: 'constants Ext'>
	^36243
    ]

    glRedIntegerExt [
	"GL_RED_INTEGER_EXT  0x8D94"

	<category: 'constants Ext'>
	^36244
    ]

    glGreenIntegerExt [
	"GL_GREEN_INTEGER_EXT  0x8D95"

	<category: 'constants Ext'>
	^36245
    ]

    glBlueIntegerExt [
	"GL_BLUE_INTEGER_EXT  0x8D96"

	<category: 'constants Ext'>
	^36246
    ]

    glAlphaIntegerExt [
	"GL_ALPHA_INTEGER_EXT  0x8D97"

	<category: 'constants Ext'>
	^36247
    ]

    glRgbIntegerExt [
	"GL_RGB_INTEGER_EXT  0x8D98"

	<category: 'constants Ext'>
	^36248
    ]

    glRgbaIntegerExt [
	"GL_RGBA_INTEGER_EXT  0x8D99"

	<category: 'constants Ext'>
	^36249
    ]

    glBgrIntegerExt [
	"GL_BGR_INTEGER_EXT  0x8D9A"

	<category: 'constants Ext'>
	^36250
    ]

    glBgraIntegerExt [
	"GL_BGRA_INTEGER_EXT  0x8D9B"

	<category: 'constants Ext'>
	^36251
    ]

    glLuminanceIntegerExt [
	"GL_LUMINANCE_INTEGER_EXT  0x8D9C"

	<category: 'constants Ext'>
	^36252
    ]

    glLuminanceAlphaIntegerExt [
	"GL_LUMINANCE_ALPHA_INTEGER_EXT  0x8D9D"

	<category: 'constants Ext'>
	^36253
    ]

    glRgbaIntegerModeExt [
	"GL_RGBA_INTEGER_MODE_EXT  0x8D9E"

	<category: 'constants Ext'>
	^36254
    ]

    glVersion14 [
	"GL_VERSION_1_4  1"

	<category: 'constants Ext'>
	^1
    ]

    glVersion15 [
	"GL_VERSION_1_5  1"

	<category: 'constants Ext'>
	^1
    ]

    glVersion20 [
	"GL_VERSION_2_0  1"

	<category: 'constants Ext'>
	^1
    ]

    glVersion21 [
	"GL_VERSION_2_1  1"

	<category: 'constants Ext'>
	^1
    ]

]

