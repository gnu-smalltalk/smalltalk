/******************************** -*- C -*- ****************************
 *
 *	Security-related routines.
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2003, 2006 Free Software Foundation, Inc.
 * Written by Paolo Bonzini.
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

#include "gstpriv.h"

/* Answer whether the permission permissionOOP (typically found in a
   SecurityPolicy object) implies the (name,target,action) tuple
   (which a primitive asks to test).  */
static mst_Boolean check_against_permission (OOP permissionOOP,
					     OOP nameOOP,
					     OOP targetOOP,
					     OOP actionOOP);

static mst_Boolean string_match (char *pattern,
				 char *string,
				 int plen,
				 int slen);

static mst_Boolean permission_is_allowing (OOP permissionOOP);

/* Answer whether the permission permissionOOP (typically found in a
   SecurityPolicy object) implies the (name,target,action) tuple
   (which a primitive asks to test).  */
static mst_Boolean check_against_policy (OOP policyOOP,
					 OOP ownerOOP,
					 OOP nameOOP,
					 OOP targetOOP,
					 OOP actionOOP);

static mst_Boolean check_static_permission (OOP receiverOOP,
					    OOP nameOOP,
					    OOP targetOOP,
					    OOP actionOOP);

mst_Boolean
check_against_permission (OOP permissionOOP,
			  OOP nameOOP,
			  OOP targetOOP,
			  OOP actionOOP)
{
  gst_permission perm = (gst_permission) OOP_TO_OBJ (permissionOOP);
  gst_object actionArray = OOP_TO_OBJ (perm->actions);
  if (perm->name != nameOOP)
    return (false);

  if (!IS_NIL (perm->target) && !IS_NIL (targetOOP))
    {
      mst_Boolean match_target;
      match_target = (targetOOP == perm->target);
      if (!match_target
	  && (OOP_CLASS (targetOOP) != _gst_symbol_class
	      || OOP_CLASS (perm->target) != _gst_symbol_class)
	  && (OOP_CLASS (targetOOP) == _gst_string_class
	      || OOP_CLASS (targetOOP) == _gst_symbol_class)
	  && (OOP_CLASS (perm->target) == _gst_string_class
	      || OOP_CLASS (perm->target) == _gst_symbol_class))
	match_target = string_match ((char *) OOP_TO_OBJ (perm->target)->data,
				     (char *) OOP_TO_OBJ (targetOOP)->data,
				     oop_num_fields (perm->target),
				     oop_num_fields (targetOOP));

      if (!match_target)
	return (false);
    }

  if (!IS_NIL (perm->actions) && !IS_NIL (actionOOP))
    {
      int n = oop_num_fields (perm->actions);
      int i;
      for (i = 0; ;)
	{
	  if (actionArray->data[i] == actionOOP)
	    break;

	  if (++i == n)
	    return (false);
	}
    }

  return (true);
}

mst_Boolean
string_match (char *pattern,
	      char *string,
	      int plen,
	      int slen)
{
  int i;

  for (;;)
    {
      /* If the string has ended, try to match trailing *'s in the
	 pattern.  */
      if (slen == 0)
	{
	  while (plen > 0 && *pattern == '*')
	    pattern++, plen--;

	  return (plen == 0);
	}

      /* If the pattern has ended, fail, because we know that slen > 0.  */
      if (plen == 0)
	return (false);

      switch (*pattern)
	{
	case '*':
	  /* Skip multiple * wildcards, they don't matter.  */
	  do
	    pattern++, plen--;
	  while (*pattern == '*');

	  /* Try to be greedy at first, then try shorter matches.  */
	  for (i = slen; i > 0; i--)
	    if (string_match (pattern, string + i, plen, slen - i))
	      return (true);

	  /* Continue with a void match for the *'s.  */
	  break;

	default:
	  /* Not a wildcard, match a single character.  */
	  if (*pattern != *string)
	    return (false);

	  /* fall through */

	case '#':
	  pattern++, string++, plen--, slen--;
	  break;
	}
    }
}

mst_Boolean
permission_is_allowing (OOP permissionOOP)
{
  gst_permission perm = (gst_permission) OOP_TO_OBJ (permissionOOP);
  return perm->positive != _gst_false_oop;
}

mst_Boolean
check_against_policy (OOP policyOOP,
		      OOP ownerOOP,
		      OOP nameOOP,
		      OOP targetOOP,
		      OOP actionOOP)
{
  gst_security_policy policy;
  OOP *first, *last;
  OOP ocOOP;
  mst_Boolean result;

  if (IS_NIL (policyOOP))
    return (true);

  policy = (gst_security_policy) OOP_TO_OBJ (policyOOP);
  ocOOP = dictionary_at (policy->dictionary, nameOOP);

  result = !IS_OOP_UNTRUSTED (ownerOOP);
  if (IS_NIL (ocOOP))
    return result;

  first = ordered_collection_begin (ocOOP);
  last = ordered_collection_end (ocOOP);
  for (; first < last; first++)
    if (check_against_permission (*first, nameOOP, targetOOP, actionOOP))
      result = permission_is_allowing (*first);

  return result;
}

mst_Boolean
check_static_permission (OOP receiverOOP,
			 OOP nameOOP,
			 OOP targetOOP,
			 OOP actionOOP)
{
  OOP classOOP = _gst_get_class_object (OOP_CLASS (receiverOOP));
  gst_class class = (gst_class) OOP_TO_OBJ (classOOP);
  OOP policyOOP = class->securityPolicy;
  
  return check_against_policy (policyOOP, classOOP,
			       nameOOP, targetOOP, actionOOP);
}

mst_Boolean _gst_check_permission (OOP contextOOP,
				   OOP nameOOP,
				   OOP targetOOP,
				   OOP actionOOP)
{
  gst_method_context context;
  mst_Boolean state, found_annotation;

  do
    {
      OOP infoOOP;
      gst_method_info info;
      int num_attributes, i;

      context = (gst_method_context) OOP_TO_OBJ (contextOOP);
      state = check_static_permission (context->receiver,
				       nameOOP, targetOOP, actionOOP);

      if (!state)
	break;

      infoOOP = get_method_info (context->method);
      info = (gst_method_info) OOP_TO_OBJ (infoOOP);
      num_attributes = NUM_INDEXABLE_FIELDS (infoOOP);
      found_annotation = false;
      for (i = 0; i < num_attributes; i++)
	{
	  gst_message attr = (gst_message) OOP_TO_OBJ (info->attributes[i]);
	  gst_object attr_args;
	  OOP permissionOOP;

	  if (attr->selector != _gst_permission_symbol)
	    continue;

	  attr_args = OOP_TO_OBJ (attr->args);
	  permissionOOP = attr_args->data[0];
	  if (check_against_permission (permissionOOP,
					nameOOP, targetOOP, actionOOP))
	    {
	      /* Should we check if the granted permission is statically
		 available?  Of course, you can only grant permissions if you
		 own them statically, so the real question is, should we
		 check perm or newPerm?  The answer is perm (which has
		 already been found to be available), hence we can skip
		 an expensive static permission check.  Suppose we have a
		 method that grants access to all files: it makes more sense
		 if it means ``grant access to all files allowed by the class
		 security policy'', rather than ``grant access to all files if
		 the security policy allows it, else do not grant access to
		 any file''.  */

	      state = permission_is_allowing (permissionOOP);
	      found_annotation = false;
	    }
	}

      if (found_annotation)
	break;

      contextOOP = context->parentContext;
    }
  while (!IS_NIL (contextOOP));

  return (state);
}

