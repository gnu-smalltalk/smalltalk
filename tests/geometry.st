"======================================================================
|
|   Testing script for basic Point anr Rectangle class primitives
|   Tests the basic primitives to verify that they work
|   The test isn't exhaustive so some errors that do not show up
|
|
 ======================================================================"


"======================================================================
|
| Copyright (C) 1995, 1999  Free Software Foundation.
| Written by Doug McCallum.
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


"Creation methods and printing"
| p1 p2 |
  p1 := Point x: 123 y: 456.
  p2 := 123@456.
  'p1 = ' print.
  p1 printNl.
  'p2 = ' print.
  p2 printNl.
!

"accessing"

| p |
  p := 123@456.
  '(p x) = ' print.
  (p x) printNl.
  '(p y) = ' print.
  (p y) printNl.
  p x: 321.
  'p = ' print.
  p printNl.
  p y: 654.
  'p = ' print.
  p printNl.
!

"comparing"
| A B C |
  A := 45@230.
  B := 175@270.
  C := 175@200.
  'A < B = ' print.
  (A < B) printNl.
  'A < C = ' print.
  (A < C) printNl.
  'A > C = ' print.
  (A > C) printNl.
  'B > A = ' print.
  (B > A) printNl.
  'A max: B = ' print.
  (A max: B) printNl.
  'A min: B = ' print.
  (A min: B) printNl.
!

"arithmetic"

| A B C D|
  A := 45@230.
  B := 175@300.
  C := 50@50.
  D := 160@240.
  'A + B = ' print.
  (A + B) printNl.
  'A + 175 = ' print.
  (A + 175) printNl.
  'A - B = ' print.
  (A - B) printNl.
  'D / 50 = ' print.
  (D / 50) printNl.
  'D // 50 = ' print.
  (D // 50) printNl.
  'D // C = ' print.
  (D // C) printNl.
  '(A - B) abs = ' print.
  ((A - B) abs) printNl.
  '120.5@220.7 rounded = ' print.
  ((120.5@220.7) rounded) printNl.
  'D truncateTo: 50 = ' print.
  (D truncateTo: 50) printNl.
!

"point functions"

| A B C D |
  A := 45@230.
  B := 175@270.
  C := 160@240.
  D := 50@50.
  'A dist: B = ' print.
  (A dist: B) printNl.
  'C dotProduct: D = ' print.
  (C dotProduct: D) printNl.
  'C grid: D = ' print.
  (C grid: D) printNl.
  'C normal = ' print.
  (C normal) printNl.
  'C truncatedGrid: D = ' print.
  (C truncatedGrid: D) printNl.
  '175@300 transpose = ' print.
  ((175@300) transpose) printNl.
!


"RECTANGLES--------------------------"

"creation and printing"
| A |
    '5 lines should be the same: A = 100@100 corner: 200@200' printNl.
    A := Rectangle left: 100 right: 200 top: 100 bottom: 200.
    'A = ' print.
    A printNl.
    A := Rectangle origin: 100@100 corner: 200@200.
    'A = ' print.
    A printNl.
    A := Rectangle origin: 100@100 extent: 100@100.
    'A = ' print.
    A printNl.
    A := (100@100) corner: 200@200.
    'A = ' print.
    A printNl.
    A := (100@100) extent: 100@100.
    'A = ' print.
    A printNl!

"accessing"
| A |
    A := Rectangle origin: 100@100 extent: 150@150.
    'A = ' print.
    A printNl.
    'topLeft = ' print.
    (A topLeft) printNl.
    'top = ' print.
    (A top) printNl.
    'rightCenter = ' print.
    (A rightCenter) printNl.
    'bottom = ' print.
    (A bottom) printNl.
    'center = ' print.
    (A center) printNl.
    'extent = ' print.
    (A extent) printNl.
    'area = ' print.
    (A area) printNl!

"rectangle functions"
| A B C D |
    A := 50@50 corner: 200@200.
    B := 120@120 corner: 260@240.
    C := 100@300 corner: 300@400.
    D := 20@20 corner: 400@400.
    (A amountToTranslateWithin: C) printNl.
    (A intersect: B) printNl.
    (D intersect: C) printNl.
    (A areasOutside: B) printNl.
    (D areasOutside: C) printNl.
    (D areasOutside: B) printNl.
    (C expandBy: 10) printNl.
    (C insetBy: 10@20) printNl.
    (B merge: C) printNl!

"testing"
| A B C |
    A := 50@50 corner: 200@200.
    B := 120@120 corner: 260@240.
    C := 100@300 corner: 300@400.
    (A contains: B) printNl.
    (C containsPoint: 200@320) printNl.
    (A intersects: B) printNl!

"truncation and round off and transforming"
| A B C |
    A := 50@50 corner: 200@200.
    B := 120@120 corner: 260@240.
    C := 100@300 corner: 300@400.
    (A moveBy: 50@50) printNl.
    (A moveTo: 200@300) printNl.
    (A scaleBy: 2) printNl.
    (A translateBy: -100) printNl!
