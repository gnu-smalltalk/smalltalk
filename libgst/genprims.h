/******************************** -*- C -*- ****************************
 *
 *	GNU Smalltalk genprims tool
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2002 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
 *
 * This file is part of GNU Smalltalk.
 *
 * GNU Smalltalk is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later 
 * version.
 * 
 * GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  
 *
 ***********************************************************************/

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif
#include <ctype.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

#include "snprintfv/filament.h"
#include "snprintfv/printf.h"

/* genprims.l declarations */
int yylex (void);
extern int yylineno;

/* genprims.y declarations */
int filprintf (Filament * fil, const char *format, ...);
extern Filament *proto_fil, *stmt_fil, *def_fil, *literal_fil;
