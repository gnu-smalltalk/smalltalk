/******************************* -*- C -*- ****************************
 *
 *      SQLite bindings
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2007, 2008 Free Software Foundation, Inc.
 * Written by Daniele Sciascia.
 *
 * This file is part of GNU Smalltalk.
 *
 * GNU Smalltalk is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2, or (at your option) any later
 * version.
 *
 * Linking GNU Smalltalk statically or dynamically with other modules is
 * making a combined work based on GNU Smalltalk.  Thus, the terms and
 * conditions of the GNU General Public License cover the whole
 * combination.
 *
 * In addition, as a special exception, the Free Software Foundation
 * give you permission to combine GNU Smalltalk with free software
 * programs or libraries that are released under the GNU LGPL and with
 * independent programs running under the GNU Smalltalk virtual machine.
 *
 * You may copy and distribute such a system following the terms of the
 * GNU GPL for GNU Smalltalk and the licenses of the other code
 * concerned, provided that you include the source code of that other
 * code when and as the GNU GPL requires distribution of source code.
 *
 * Note that people who make modified versions of GNU Smalltalk are not
 * obligated to grant this special exception for their modified
 * versions; it is their choice whether to do so.  The GNU General
 * Public License gives permission to release a modified version without
 * this exception; this exception also makes it possible to release a
 * modified version which carries forward this exception.
 *
 * GNU Smalltalk is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * GNU Smalltalk; see the file COPYING.  If not, write to the Free Software
 * Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
 *
 ***********************************************************************/


#include <stdio.h>
#include <stdlib.h>
#include "gstpub.h"
#include "sqlite3.h"

typedef struct st_Sqlite3Handle
{
  OBJ_HEADER;
  OOP db;
} *SQLite3Handle;

typedef struct st_SQLite3StmtHandle
{
  OBJ_HEADER;
  OOP db;
  OOP stmt;
  OOP colCount;
  OOP colTypes;
  OOP colNames;
  OOP returnedRow;
} *SQLite3StmtHandle;


static VMProxy *vmProxy;


static int
gst_sqlite3_open (OOP self, const char *db_name)
{
  int rc;
  sqlite3 *db;
  OOP dbHandle;
  SQLite3Handle h;

  rc = sqlite3_open (db_name, &db);
  dbHandle = vmProxy->cObjectToOOP (db);
  h = (SQLite3Handle) OOP_TO_OBJ (self);
  h->db = dbHandle;

  return rc;
}

static int
gst_sqlite3_close (OOP self)
{
  sqlite3 *db;
  SQLite3Handle h;

  h = (SQLite3Handle) OOP_TO_OBJ (self);
  db = (sqlite3 *) vmProxy->OOPToCObject (h->db);
  return sqlite3_close (db);
}

static int
gst_sqlite3_prepare (OOP self, const char *sql)
{
  int rc, i, cols;
  sqlite3 *db;
  sqlite3_stmt *stmt;
  OOP tmpOOP;
  SQLite3StmtHandle h;

  h = (SQLite3StmtHandle) OOP_TO_OBJ (self);
  db = (sqlite3 *) vmProxy->OOPToCObject (h->db);

  rc = sqlite3_prepare (db, sql, -1, &stmt, 0);
  if (rc != SQLITE_OK)
    return rc;

  tmpOOP = vmProxy->cObjectToOOP (stmt);
  h = (SQLite3StmtHandle) OOP_TO_OBJ (self);
  h->stmt = tmpOOP;

  cols = sqlite3_column_count (stmt);
  tmpOOP = vmProxy->intToOOP (cols);
  h->colCount = tmpOOP;

  tmpOOP = vmProxy->objectAlloc (vmProxy->arrayClass, cols);
  h = (SQLite3StmtHandle) OOP_TO_OBJ (self);
  h->colTypes = tmpOOP;

  tmpOOP = vmProxy->objectAlloc (vmProxy->arrayClass, cols);
  h = (SQLite3StmtHandle) OOP_TO_OBJ (self);
  h->colNames = tmpOOP;

  tmpOOP = vmProxy->objectAlloc (vmProxy->arrayClass, cols);
  h = (SQLite3StmtHandle) OOP_TO_OBJ (self);
  h->returnedRow = tmpOOP;

  for (i = 0; i < cols; i++)
    {
      tmpOOP = vmProxy->stringToOOP (sqlite3_column_name (stmt, i));
      h = (SQLite3StmtHandle) OOP_TO_OBJ (self);
      vmProxy->OOPAtPut (h->colNames, i, tmpOOP);
    }

  return rc;
}

static int
gst_sqlite3_exec (OOP self)
{
  int rc;
  sqlite3_stmt *stmt;
  SQLite3StmtHandle h;

  h = (SQLite3StmtHandle) OOP_TO_OBJ (self);
  if (h->stmt == vmProxy->nilOOP)
    return SQLITE_MISUSE;

  stmt = (sqlite3_stmt *) vmProxy->OOPToCObject (h->stmt);
  rc = sqlite3_step (stmt);

  if (rc == SQLITE_ROW)
    {
      int i, cols, type;
      OOP tmpOOP;

      cols = sqlite3_column_count (stmt);
      for (i = 0; i < cols; i++)
	{
	  type = sqlite3_column_type (stmt, i);
	  tmpOOP = vmProxy->intToOOP (type);
	  vmProxy->OOPAtPut (h->colTypes, i, tmpOOP);

	  switch (type)
	    {
	    case SQLITE_INTEGER:
	      tmpOOP = vmProxy->intToOOP (sqlite3_column_int (stmt, i));
	      break;
	    case SQLITE_FLOAT:
	      tmpOOP = vmProxy->floatToOOP (sqlite3_column_double (stmt, i));
	      break;
	    case SQLITE_TEXT:
	      tmpOOP = vmProxy->stringToOOP (sqlite3_column_text (stmt, i));
	      break;
	    case SQLITE_BLOB:
	      tmpOOP = vmProxy->stringToOOP (sqlite3_column_text (stmt, i));
	      break;
	    case SQLITE_NULL:
	      tmpOOP = vmProxy->nilOOP;
	      break;
	    default:
	      fprintf (stderr, "sqlite3 error: %s\n",
		       "returned type not recognized");
	    }

	  h = (SQLite3StmtHandle) OOP_TO_OBJ (self);
	  vmProxy->OOPAtPut (h->returnedRow, i, tmpOOP);
	}
    }

  return rc;
}

static int
gst_sqlite3_bind (OOP self, OOP key, OOP value)
{
    sqlite3_stmt *stmt;
    SQLite3StmtHandle h;
    int index;
    
    h = (SQLite3StmtHandle) OOP_TO_OBJ (self);
    if (h->stmt == vmProxy->nilOOP)
        return SQLITE_MISUSE;
        
    stmt = (sqlite3_stmt *) vmProxy->OOPToCObject (h->stmt);
    if (vmProxy->objectIsKindOf (key, vmProxy->smallIntegerClass))
      index = vmProxy->OOPToInt (key);

    else if (vmProxy->objectIsKindOf (key, vmProxy->stringClass))
      {
	char *name = vmProxy->OOPToString (key);
	index = sqlite3_bind_parameter_index(stmt, name);
	free (name);
	if (index == 0)
	  return SQLITE_OK;
      }

    else
      return -1;

    if (vmProxy->objectIsKindOf (value, vmProxy->smallIntegerClass))
#if SIZEOF_LONG == 4
        return sqlite3_bind_int (stmt, index, vmProxy->OOPToInt (value));
#else
        return sqlite3_bind_int64 (stmt, index,
				   (sqlite_int64) vmProxy->OOPToInt (value));
#endif
        
    if (vmProxy->objectIsKindOf (value, vmProxy->stringClass)
	|| vmProxy->objectIsKindOf (value, vmProxy->byteArrayClass))
        return sqlite3_bind_text (stmt, index, vmProxy->OOPIndexedBase (value),
				  vmProxy->basicSize (value), SQLITE_TRANSIENT);
        
    if (vmProxy->objectIsKindOf (value, vmProxy->floatDClass))
        return sqlite3_bind_double (stmt, index, vmProxy->OOPToFloat (value));
        
    if (value == vmProxy->nilOOP)
        return sqlite3_bind_null (stmt, index);

    return -1;
}

#ifndef HAVE_LIBSQLITE3_SQLITE3_CLEAR_BINDINGS
#define sqlite3_clear_bindings my_sqlite3_clear_bindings

static int
sqlite3_clear_bindings (sqlite3_stmt *stmt)
{
  int n = sqlite3_bind_parameter_count (stmt);
  int index;

  for (index = 1; index <= n; index++)
    {
      int result = sqlite3_bind_null (stmt, index);
      if (result != SQLITE_OK)
	return result;
    }

  return SQLITE_OK;
}

#endif
static int 
gst_sqlite3_clear_bindings (OOP self) 
{
    sqlite3_stmt *stmt;
    SQLite3StmtHandle h;
    
    h = (SQLite3StmtHandle) OOP_TO_OBJ (self);
    if (h->stmt == vmProxy->nilOOP)
        return SQLITE_MISUSE;
        
    stmt = (sqlite3_stmt *) vmProxy->OOPToCObject (h->stmt);
    return sqlite3_clear_bindings (stmt);   
}

static int 
gst_sqlite3_reset (OOP self) 
{
    sqlite3_stmt *stmt;
    SQLite3StmtHandle h;
    
    h = (SQLite3StmtHandle) OOP_TO_OBJ (self);
    if (h->stmt == vmProxy->nilOOP)
        return SQLITE_MISUSE;
        
    stmt = (sqlite3_stmt *) vmProxy->OOPToCObject (h->stmt);
    return sqlite3_reset (stmt);   
}

static const char *
gst_sqlite3_error_message (OOP self)
{
  sqlite3 *db;
  SQLite3Handle h;

  h = (SQLite3Handle) OOP_TO_OBJ (self);
  db = (sqlite3 *) vmProxy->OOPToCObject (h->db);

  return sqlite3_errmsg (db);
}

static int
gst_sqlite3_finalize (OOP self)
{
  sqlite3_stmt *stmt;
  SQLite3StmtHandle h;

  h = (SQLite3StmtHandle) OOP_TO_OBJ (self);
  if (h->stmt == vmProxy->nilOOP)
    return 0;

  stmt = (sqlite3_stmt *) vmProxy->OOPToCObject (h->stmt);
  h->stmt = vmProxy->nilOOP;
  return sqlite3_finalize (stmt);
}

static int
gst_sqlite3_changes (OOP self)
{
  sqlite3 *db;
  SQLite3StmtHandle h;

  h = (SQLite3StmtHandle) OOP_TO_OBJ (self);
  db = (sqlite3 *) vmProxy->OOPToCObject (h->db);

  return sqlite3_changes (db);
}

void
gst_initModule (VMProxy * proxy)
{
  vmProxy = proxy;
  vmProxy->defineCFunc ("gst_sqlite3_open", gst_sqlite3_open);
  vmProxy->defineCFunc ("gst_sqlite3_close", gst_sqlite3_close);
  vmProxy->defineCFunc ("gst_sqlite3_prepare", gst_sqlite3_prepare);
  vmProxy->defineCFunc ("gst_sqlite3_exec", gst_sqlite3_exec);
  vmProxy->defineCFunc ("gst_sqlite3_bind", gst_sqlite3_bind);
  vmProxy->defineCFunc ("gst_sqlite3_clear_bindings", gst_sqlite3_clear_bindings);
  vmProxy->defineCFunc ("gst_sqlite3_reset", gst_sqlite3_reset);
  vmProxy->defineCFunc ("gst_sqlite3_changes", gst_sqlite3_changes);
  vmProxy->defineCFunc ("gst_sqlite3_error_message", gst_sqlite3_error_message);
  vmProxy->defineCFunc ("gst_sqlite3_finalize", gst_sqlite3_finalize);
}
