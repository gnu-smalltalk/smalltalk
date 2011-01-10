"======================================================================
|
|   Cairo function declarations
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2008 Free Software Foundation, Inc.
| Originally by Mike Anderson
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


Object subclass: Cairo [
    
    <category: 'Cairo-C interface'>
    <comment: 'This class provides the C functions used in
calling Cairo functions.  The user should actually use higher-level
classes such as CairoSurface, CairoPattern and (using #withContextDo:)
CairoContext.'>

    Cairo class >> arc: cr xc: xc yc: yc radius: radius angle1: angle1 angle2: angle2 [
        <cCall: 'cairo_arc' returning: #void args: #(#cObject #double #double #double #double #double )>
    ]

    Cairo class >> arcNegative: cr xc: xc yc: yc radius: radius angle1: angle1 angle2: angle2 [
        <cCall: 'cairo_arc_negative' returning: #void args: #(#cObject #double #double #double #double #double )>
    ]

    Cairo class >> clip: cr [
        <cCall: 'cairo_clip' returning: #void args: #(#cObject )>
    ]

    Cairo class >> clipPreserve: cr [
        <cCall: 'cairo_clip_preserve' returning: #void args: #(#cObject )>
    ]

    Cairo class >> closePath: cr [
        <cCall: 'cairo_close_path' returning: #void args: #(#cObject )>
    ]

    Cairo class >> create: target [
        <cCall: 'cairo_create' returning: #cObject args: #(#cObject )>
    ]

    Cairo class >> curveTo: cr x1: x1 y1: y1 x2: x2 y2: y2 x3: x3 y3: y3 [
        <cCall: 'cairo_curve_to' returning: #void args: #(#cObject #double #double #double #double #double #double )>
    ]

    Cairo class >> destroy: cr [
        <cCall: 'cairo_destroy' returning: #void args: #(#cObject )>
    ]

    Cairo class >> fill: cr [
        <cCall: 'cairo_fill' returning: #void args: #(#cObject )>
    ]

    Cairo class >> fillPreserve: cr [
        <cCall: 'cairo_fill_preserve' returning: #void args: #(#cObject )>
    ]

    Cairo class >> identityMatrix: cr [
        <cCall: 'cairo_identity_matrix' returning: #void args: #(#cObject )>
    ]

    Cairo class >> imageSurfaceCreate: format width: width height: height [
        <cCall: 'cairo_image_surface_create' returning: #cObject args: #(#int #int #int)>
    ]

    Cairo class >> imageSurfaceCreateForData: data format: format width: width height: height stride: stride [
        <cCall: 'cairo_image_surface_create_for_data' returning: #cObject args: #(#cObject #int #int #int #int )>
    ]

    Cairo class >> imageSurfaceCreateFromPng: filename [
        <cCall: 'cairo_image_surface_create_from_png' returning: #cObject args: #(#string )>
    ]

    Cairo class >> imageSurfaceGetData: surface [
        <cCall: 'cairo_image_surface_get_data' returning: #{CByte} args: #(#cObject)>
    ]

    Cairo class >> imageSurfaceGetHeight: filename [
        <cCall: 'cairo_image_surface_get_height' returning: #int args: #(#cObject )>
    ]

    Cairo class >> imageSurfaceGetWidth: filename [
        <cCall: 'cairo_image_surface_get_width' returning: #int args: #(#cObject )>
    ]

    Cairo class >> pdfSurfaceCreate: file width: width height: height [
        <cCall: 'cairo_pdf_surface_create' returning: #cObject args: #(#string #double #double)>
    ]

    Cairo class >> pdfSurfaceSetSize: file width: width height: height [
        <cCall: 'cairo_pdf_surface_set_size' returning: #int args: #(#cObject #double #double)>
    ]

    Cairo class >> svgSurfaceCreate: file width: width height: height [
        <cCall: 'cairo_svg_surface_create' returning: #cObject args: #(#string #double #double)>
    ]

    Cairo class >> showPage: file width: width height: height [
        <cCall: 'cairo_show_page' returning: #void args: #(#cObject)>
    ]

    Cairo class >> lineTo: cr x: x y: y [
        <cCall: 'cairo_line_to' returning: #void args: #(#cObject #double #double )>
    ]

    Cairo class >> mask: cr pattern: pattern [
        <cCall: 'cairo_mask' returning: #void args: #(#cObject #cObject )>
    ]

    Cairo class >> maskSurface: cr surface: surface surfaceX: surfaceX surfaceY: surfaceY [
        <cCall: 'cairo_mask_surface' returning: #void args: #(#cObject #cObject #double #double )>
    ]

    Cairo class >> matrixInit: matrix xx: xx yx: yx xy: xy yy: yy x0: x0 y0: y0 [
        <cCall: 'cairo_matrix_init' returning: #void args: #(#cObject #double #double #double #double #double #double )>
    ]

    Cairo class >> matrixInitIdentity: matrix [
        <cCall: 'cairo_matrix_init_identity' returning: #void args: #(#cObject )>
    ]

    Cairo class >> matrixInvert: matrix [
        <cCall: 'cairo_matrix_invert' returning: #int args: #(#cObject )>
    ]

    Cairo class >> matrixMultiply: result a: a b: b [
        <cCall: 'cairo_matrix_multiply' returning: #void args: #(#cObject #cObject #cObject )>
    ]

    Cairo class >> matrixRotate: matrix radians: radians [
        <cCall: 'cairo_matrix_rotate' returning: #void args: #(#cObject #double )>
    ]

    Cairo class >> matrixScale: matrix sx: sx sy: sy [
        <cCall: 'cairo_matrix_scale' returning: #void args: #(#cObject #double #double )>
    ]

    Cairo class >> matrixTransformDistance: matrix dx: dx dy: dy [
        <cCall: 'cairo_matrix_transform_distance' returning: #void args: #(#cObject #cObject #cObject )>
    ]

    Cairo class >> matrixTransformPoint: matrix x: x y: y [
        <cCall: 'cairo_matrix_transform_point' returning: #void args: #(#cObject #cObject #cObject )>
    ]

    Cairo class >> matrixTranslate: matrix tx: tx ty: ty [
        <cCall: 'cairo_matrix_translate' returning: #void args: #(#cObject #double #double )>
    ]

    Cairo class >> moveTo: cr x: x y: y [
        <cCall: 'cairo_move_to' returning: #void args: #(#cObject #double #double )>
    ]

    Cairo class >> newPath: cr [
        <cCall: 'cairo_new_path' returning: #void args: #(#cObject )>
    ]

    Cairo class >> newSubPath: cr [
        <cCall: 'cairo_new_sub_path' returning: #void args: #(#cObject )>
    ]

    Cairo class >> paint: cr [
        <cCall: 'cairo_paint' returning: #void args: #(#cObject )>
    ]

    Cairo class >> paintWithAlpha: cr alpha: alpha [
        <cCall: 'cairo_paint_with_alpha' returning: #void args: #(#cObject #double )>
    ]

    Cairo class >> patternAddColorStopRgba: pattern offset: offset red: red green: green blue: blue alpha: alpha [
        <cCall: 'cairo_pattern_add_color_stop_rgba' returning: #void args: #(#cObject #double #double #double #double #double )>
    ]

    Cairo class >> patternCreateForSurface: surface [
        <cCall: 'cairo_pattern_create_for_surface' returning: #cObject args: #(#cObject )>
    ]

    Cairo class >> patternCreateLinear: x0 y0: y0 x1: x1 y1: y1 [
        <cCall: 'cairo_pattern_create_linear' returning: #cObject args: #(#double #double #double #double )>
    ]

    Cairo class >> patternCreateRadial: cx0 cy0: cy0 radius0: radius0 cx1: cx1 cy1: cy1 radius1: radius1 [
        <cCall: 'cairo_pattern_create_radial' returning: #cObject args: #(#double #double #double #double #double #double )>
    ]

    Cairo class >> patternCreateRgb: red green: green blue: blue [
        <cCall: 'cairo_pattern_create_rgb' returning: #cObject args: #(#double #double #double )>
    ]

    Cairo class >> patternCreateRgba: red green: green blue: blue alpha: alpha [
        <cCall: 'cairo_pattern_create_rgba' returning: #cObject args: #(#double #double #double #double )>
    ]

    Cairo class >> patternReference: pattern [
        <cCall: 'cairo_pattern_reference' returning: #void args: #(#cObject )>
    ]

    Cairo class >> patternDestroy: pattern [
        <cCall: 'cairo_pattern_destroy' returning: #void args: #(#cObject )>
    ]

    Cairo class >> patternGetExtend: pattern [
        <cCall: 'cairo_pattern_get_extend' returning: #int args: #(#cObject )>
    ]

    Cairo class >> patternSetExtend: pattern extend: extend [
        <cCall: 'cairo_pattern_set_extend' returning: #void args: #(#cObject #int)>
    ]

    Cairo class >> popGroup: cr [
        <cCall: 'cairo_pop_group' returning: #cObject args: #(#cObject )>
    ]

    Cairo class >> pushGroup: cr [
        <cCall: 'cairo_push_group' returning: #void args: #(#cObject )>
    ]

    Cairo class >> rectangle: cr x: x y: y width: width height: height [
        <cCall: 'cairo_rectangle' returning: #void args: #(#cObject #double #double #double #double )>
    ]

    Cairo class >> reference: cr [
        <cCall: 'cairo_reference' returning: #cObject args: #(#cObject )>
    ]

    Cairo class >> relCurveTo: cr dx1: dx1 dy1: dy1 dx2: dx2 dy2: dy2 dx3: dx3 dy3: dy3 [
        <cCall: 'cairo_rel_curve_to' returning: #void args: #(#cObject #double #double #double #double #double #double )>
    ]

    Cairo class >> relLineTo: cr dx: dx dy: dy [
        <cCall: 'cairo_rel_line_to' returning: #void args: #(#cObject #double #double )>
    ]

    Cairo class >> relMoveTo: cr dx: dx dy: dy [
        <cCall: 'cairo_rel_move_to' returning: #void args: #(#cObject #double #double )>
    ]

    Cairo class >> resetClip: cr [
        <cCall: 'cairo_reset_clip' returning: #void args: #(#cObject )>
    ]

    Cairo class >> restore: cr [
        <cCall: 'cairo_restore' returning: #void args: #(#cObject )>
    ]

    Cairo class >> rotate: cr angle: angle [
        <cCall: 'cairo_rotate' returning: #void args: #(#cObject #double )>
    ]

    Cairo class >> save: cr [
        <cCall: 'cairo_save' returning: #void args: #(#cObject )>
    ]

    Cairo class >> scale: cr sx: sx sy: sy [
        <cCall: 'cairo_scale' returning: #void args: #(#cObject #double #double )>
    ]

    Cairo class >> scaledFontCreate: fontFace fontMatrix: fontMatrix ctm: ctm options: options [
        <cCall: 'cairo_scaled_font_create' returning: #cObject args: #(#cObject #cObject #cObject #cObject )>
    ]

    Cairo class >> scaledFontDestroy: scaledFont [
        <cCall: 'cairo_scaled_font_destroy' returning: #void args: #(#cObject )>
    ]

    Cairo class >> scaledFontExtents: scaledFont extents: extents [
        <cCall: 'cairo_scaled_font_extents' returning: #void args: #(#cObject #cObject )>
    ]

    Cairo class >> scaledFontGetCtm: scaledFont ctm: ctm [
        <cCall: 'cairo_scaled_font_get_ctm' returning: #void args: #(#cObject #cObject )>
    ]

    Cairo class >> scaledFontGetFontFace: scaledFont [
        <cCall: 'cairo_scaled_font_get_font_face' returning: #cObject args: #(#cObject )>
    ]

    Cairo class >> scaledFontGetFontMatrix: scaledFont fontMatrix: fontMatrix [
        <cCall: 'cairo_scaled_font_get_font_matrix' returning: #void args: #(#cObject #cObject )>
    ]

    Cairo class >> scaledFontGetFontOptions: scaledFont options: options [
        <cCall: 'cairo_scaled_font_get_font_options' returning: #void args: #(#cObject #cObject )>
    ]

    Cairo class >> scaledFontGetType: scaledFont [
        <cCall: 'cairo_scaled_font_get_type' returning: #int args: #(#cObject )>
    ]

    Cairo class >> scaledFontGlyphExtents: scaledFont glyphs: glyphs numGlyphs: numGlyphs extents: extents [
        <cCall: 'cairo_scaled_font_glyph_extents' returning: #void args: #(#cObject #cObject #int #cObject )>
    ]

    Cairo class >> scaledFontReference: scaledFont [
        <cCall: 'cairo_scaled_font_reference' returning: #cObject args: #(#cObject )>
    ]

    Cairo class >> scaledFontStatus: scaledFont [
        <cCall: 'cairo_scaled_font_status' returning: #int args: #(#cObject )>
    ]

    Cairo class >> scaledFontTextExtents: scaledFont utf8: utf8 extents: extents [
        <cCall: 'cairo_scaled_font_text_extents' returning: #void args: #(#cObject #string #cObject )>
    ]

    Cairo class >> selectFontFace: cr family: family slant: slant weight: weight [
        <cCall: 'cairo_select_font_face' returning: #void args: #(#cObject #string #int #int )>
    ]

    Cairo class >> getSource: cr [
        <cCall: 'cairo_get_source' returning: #cObject args: #(#cObject )>
    ]

    Cairo class >> getMiterLimit: cr [
        <cCall: 'cairo_get_miter_limit' returning: #double args: #(#cObject )>
    ]

    Cairo class >> getFillRule: cr [
        <cCall: 'cairo_get_fill_rule' returning: #int args: #(#cObject )>
    ]

    Cairo class >> getLineCap: cr [
        <cCall: 'cairo_get_line_cap' returning: #int args: #(#cObject )>
    ]

    Cairo class >> getLineJoin: cr [
        <cCall: 'cairo_get_line_join' returning: #int args: #(#cObject )>
    ]

    Cairo class >> getLineWidth: cr [
        <cCall: 'cairo_get_line_width' returning: #double args: #(#cObject )>
    ]

    Cairo class >> getOperator: cr [
        <cCall: 'cairo_get_operator' returning: #int args: #(#cObject )>
    ]

    Cairo class >> setSource: cr source: source [
        <cCall: 'cairo_set_source' returning: #void args: #(#cObject #cObject )>
    ]

    Cairo class >> setSourceRgb: cr red: red green: green blue: blue [
        <cCall: 'cairo_set_source_rgb' returning: #void args: #(#cObject #double #double #double )>
    ]

    Cairo class >> setSourceRgba: cr red: red green: green blue: blue alpha: alpha [
        <cCall: 'cairo_set_source_rgba' returning: #void args: #(#cObject #double #double #double #double )>
    ]

    Cairo class >> setFontSize: cr size: size [
        <cCall: 'cairo_set_font_size' returning: #void args: #(#cObject #double )>
    ]

    Cairo class >> setMiterLimit: cr miterLimit: size [
        <cCall: 'cairo_set_miter_limit' returning: #void args: #(#cObject #double )>
    ]

    Cairo class >> setFillRule: cr fillRule: fillRule [
        <cCall: 'cairo_set_fill_rule' returning: #void args: #(#cObject #int )>
    ]

    Cairo class >> setLineCap: cr lineCap: lineCap [
        <cCall: 'cairo_set_line_cap' returning: #void args: #(#cObject #int )>
    ]

    Cairo class >> setLineJoin: cr lineJoin: lineJoin [
        <cCall: 'cairo_set_line_join' returning: #void args: #(#cObject #int )>
    ]

    Cairo class >> setLineWidth: cr width: width [
        <cCall: 'cairo_set_line_width' returning: #void args: #(#cObject #double )>
    ]

    Cairo class >> setOperator: cr operator: lineJoin [
        <cCall: 'cairo_set_operator' returning: #void args: #(#cObject #int )>
    ]

    Cairo class >> showText: cr utf8: utf8 [
        <cCall: 'cairo_show_text' returning: #void args: #(#cObject #string )>
    ]

    Cairo class >> stroke: cr [
        <cCall: 'cairo_stroke' returning: #void args: #(#cObject )>
    ]

    Cairo class >> strokePreserve: cr [
        <cCall: 'cairo_stroke_preserve' returning: #void args: #(#cObject )>
    ]

    Cairo class >> surfaceWriteToPng: surface filename: filename [
        <cCall: 'cairo_surface_write_to_png' returning: #void args: #(#cObject #string )>
    ]

    Cairo class >> surfaceDestroy: surface [
        <cCall: 'cairo_surface_destroy' returning: #void args: #(#cObject )>
    ]

    Cairo class >> surfaceFinish: surface [
        <cCall: 'cairo_surface_finish' returning: #void args: #(#cObject )>
    ]

    Cairo class >> surfaceFlush: surface [
        <cCall: 'cairo_surface_flush' returning: #void args: #(#cObject )>
    ]

    Cairo class >> textExtents: cr utf8: utf8 extents: extents [
        <cCall: 'cairo_text_extents' returning: #void args: #(#cObject #string #cObject )>
    ]

    Cairo class >> textPath: cr utf8: utf8 [
        <cCall: 'cairo_text_path' returning: #void args: #(#cObject #string )>
    ]

    Cairo class >> transform: cr matrix: matrix [
        <cCall: 'cairo_transform' returning: #void args: #(#cObject #cObject )>
    ]

    Cairo class >> translate: cr tx: tx ty: ty [
        <cCall: 'cairo_translate' returning: #void args: #(#cObject #double #double )>
    ]

    Cairo class >> xlibSurfaceSetDrawable: surface drawable: drawable width: width height: height [
        <cCall: 'cairo_xlib_surface_set_drawable' returning: #void args: #(#cObject #uLong #int #int )>
    ]

    Cairo class >> xlibSurfaceSetSize: surface width: width height: height [
        <cCall: 'cairo_xlib_surface_set_size' returning: #void args: #(#cObject #int #int )>
    ]

    Cairo class >> defaultSelector: aFuncName args: aArgs [
        <category: 'loading'>
        | sel |
        sel := super defaultSelector: aFuncName args: aArgs.
        (sel startsWith: 'cairo') 
            ifTrue: [sel := (sel at: 6) asLowercase asString , (sel copyFrom: 7)].
        ^sel
    ]

    Cairo class >> fillRuleEvenOdd [
        <category: 'loading'>
        ^1
    ]

    Cairo class >> fillRuleWinding [
        <category: 'loading'>
        ^0
    ]

    Cairo class >> lineJoinBevel [
        <category: 'loading'>
        ^2
    ]

    Cairo class >> lineJoinRound [
        <category: 'loading'>
        ^1
    ]

    Cairo class >> lineJoinMiter [
        <category: 'loading'>
        ^0
    ]

    Cairo class >> lineCapSquare [
        <category: 'loading'>
        ^2
    ]

    Cairo class >> lineCapRound [
        <category: 'loading'>
        ^1
    ]

    Cairo class >> lineCapButt [
        <category: 'loading'>
        ^0
    ]

    Cairo class >> fontSlantOblique [
        <category: 'loading'>
        ^2
    ]

    Cairo class >> fontSlantItalic [
        <category: 'loading'>
        ^1
    ]

    Cairo class >> fontSlantNormal [
        <category: 'loading'>
        ^0
    ]

    Cairo class >> fontWeightBold [
        <category: 'loading'>
        ^1
    ]

    Cairo class >> fontWeightNormal [
        <category: 'loading'>
        ^0
    ]

    Cairo class >> extendPad [
        <category: 'loading'>
        ^3
    ]

    Cairo class >> extendReflect [
        <category: 'loading'>
        ^2
    ]

    Cairo class >> extendRepeat [
        <category: 'loading'>
        ^1
    ]

    Cairo class >> extendNone [
        <category: 'loading'>
        ^0
    ]

    Cairo class >> formatArgb32 [
        <category: 'loading'>
        ^0
    ]

    Cairo class >> operatorClear [
        <category: 'loading'>
        ^0
    ]

    Cairo class >> operatorSource [
        <category: 'loading'>
        ^1
    ]

    Cairo class >> operatorOver [
        <category: 'loading'>
        ^2
    ]

    Cairo class >> operatorIn [
        <category: 'loading'>
        ^3
    ]

    Cairo class >> operatorOut [
        <category: 'loading'>
        ^4
    ]

    Cairo class >> operatorAtop [
        <category: 'loading'>
        ^5
    ]

    Cairo class >> operatorDest [
        <category: 'loading'>
        ^6
    ]

    Cairo class >> operatorDestOver [
        <category: 'loading'>
        ^7
    ]

    Cairo class >> operatorDestIn [
        <category: 'loading'>
        ^8
    ]

    Cairo class >> operatorDestOut [
        <category: 'loading'>
        ^9
    ]

    Cairo class >> operatorDestAtop [
        <category: 'loading'>
        ^10
    ]

    Cairo class >> operatorXor [
        <category: 'loading'>
        ^11
    ]

    Cairo class >> operatorAdd [
        <category: 'loading'>
        ^12
    ]

    Cairo class >> operatorSaturate [
        <category: 'loading'>
        ^13
    ]

]

CStruct subclass: CairoTextExtents [
    <declaration: #(
        (#xBearing #double)
        (#yBearing #double)
        (#width #double)
        (#height #double)
        (#xAdvance #double)
        (#yAdvance #double)) >

    <category: 'Cairo-C interface'>
]
