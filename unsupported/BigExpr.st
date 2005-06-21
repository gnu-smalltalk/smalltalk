"======================================================================
|
|   Test out large expression handling 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 1988-92, 1994-95, 1999, 2000 Free Software Foundation, Inc.
| Written by Steve Byrne.
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


#(#T #Chart #Rectangle #Legend #LinearAxis #XYLinePlot #Ingres #GPen
#GLine #ScatterPlot #Gsymbol #Gfill) do: [ :x | Smalltalk at: x put: nil ]

!


"T := (Tablet new: 6.5 by: 5) open!"

T add: (
  (Chart new) yourself;
    frame: (Rectangle origin: 0.75@0.75 corner: 4.5@4.375);
    legend: (
      (Legend new) yourself;
	frame: (Rectangle origin: 4.59999999999999@2.97499999999999 corner: 6.19999999999999@4.375);
	title: 'EXPLANATION');
    at: 'bottom' location: (0.0@0.0 corner: 1.0@0.0) putAxis: (
      (LinearAxis new) yourself;
	frame: (Rectangle origin: 0.75@0.75 corner: 4.5@0.75);
	side: 1.0;
	addLabel: 'MONTH');
    at: 'left' location: (0.0@0.0 corner: 0.0@1.0) putAxis: (
      (LinearAxis new) yourself;
	frame: (Rectangle origin: 0.75@0.75 corner: 0.75@4.375);
	side: 1.0;
	addLabel: 'FLOW90, FLOW91, MEDIAN';
	addLabel: 'FLOW90, FLOW91');
    at: 'top' location: (0.0@1.0 corner: 1.0@1.0) putAxis: (
      (LinearAxis new) yourself;
	frame: (Rectangle origin: 0.75@4.375 corner: 4.5@4.375);
	side: -1.0;
	addLabel: 'MEDIAN');
    withXAxis: 'bottom' withYAxis: 'left'  addPlot: (
      (XYLinePlot new) yourself;
	frame: nil;
	data: ((Ingres new: 'nwc') table: 'v9091');
	x: 'month';
	ys: #('flow90'
	  'flow91'
	  'median'
	  );
	componentAt: 1 put: (
	  (GPen new) yourself;
	    label: 'flow90';
	    line: (
	      (GLine new) yourself;
		type: 1;
		color: 1;
		width: 1.0));
	componentAt: 2 put: (
	  (GPen new) yourself;
	    label: 'flow91';
	    line: (
	      (GLine new) yourself;
		type: 1;
		color: 2;
		width: 1.0));
	componentAt: 3 put: (
	  (GPen new) yourself;
	    label: 'median';
	    line: (
	      (GLine new) yourself;
		type: 1;
		color: 3;
		width: 1.0)));
    withYAxis: 'left' withXAxis: 'top'  addPlot: (
      (ScatterPlot new) yourself;
	frame: nil;
	data: ((Ingres new: 'nwc') table: 'v9091');
	x: 'median';
	ys: #('flow90'
	  'flow91'
	  );
	componentAt: 1 put: (
	  (GPen new) yourself;
	    label: 'flow90';
	    symbol: (
	      (Gsymbol new) yourself;
		type: 'plus';
		size: 0.1;
		angle: nil;
		fill: (
		  (Gfill new) yourself;
		    type: 0;
		    color: 1);
		store));
	componentAt: 2 put: (
	  (GPen new) yourself;
	    label: 'flow91';
	    symbol: (
	      (Gsymbol new) yourself;
		type: 'plus';
		size: 0.1;
		angle: 0.785398163397448;
		fill: (
		  (Gfill new) yourself;
		    type: 0;
		    color: 1);
		store))))!

