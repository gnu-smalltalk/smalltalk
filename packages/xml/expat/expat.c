/******************************* -*- C -*- ****************************
 *
 *      Expat bindings
 *
 *
 ***********************************************************************/

/***********************************************************************
 *
 * Copyright 2009 Free Software Foundation, Inc.
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


#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include "gstpub.h"
#include <expat.h>

typedef struct st_XMLExpatPullParser
{
  OBJ_HEADER;
  OOP needFlags[4];
  OOP xpOOP;
  OOP nextParserOOP;
  OOP currentEventOOP;
  OOP pendingEventOOP;
  OOP sourceOOP;
  OOP sourceStackOOP;
} *XMLExpatPullParser;

typedef struct st_SAXEventSequence
{
  OBJ_HEADER;
  OOP eventOOP;
  OOP nextOOP;
} *SAXEventSequence;

static OOP attributeClass;
static OOP emptyString;
static OOP nodeTagClass;
static OOP saxEndCdataSectionClass;
static OOP saxEndDoctypeDeclClass;
static OOP saxEndDocumentFragmentClass;
static OOP saxEndDocumentClass;
static OOP saxExternalEntityRefClass;
static OOP saxStartCdataSectionClass;
static OOP saxStartDocumentFragmentClass;
static OOP saxStartDocumentClass;
static OOP saxTagEventClass;
static OOP saxEndTagClass;
static OOP saxStartTagClass;
static OOP saxProcessingInstructionClass;
static OOP saxTextClass;
static OOP saxCommentClass;
static OOP saxStartPrefixMappingClass;
static OOP saxEndPrefixMappingClass;
static OOP saxStartDoctypeDeclClass;
static OOP saxNotationDeclClass;
static OOP saxUnparsedEntityDeclClass;
static OOP saxSkippedEntityClass;
static OOP saxEventSequenceClass;
static VMProxy *vmProxy;


/* Count the number of attributes in the list of strings in ATTR.
   This is the number of strings divided by 2.  */

static int
count_attributes (const char **attr)
{
  int i;
  for (i = 0; *attr; i++)
    attr += 2;

  return i;
}


/* Make a NodeTag object from P, which is a \n-delimited tag triplet
   (URI, local name, prefix).  */

static OOP
make_node_tag (const char *p)
{
  const char *q, *r;
  char *tmp;
  int len;
  OOP tagOOP, nsOOP, typeOOP, qualOOP;
  mst_Object tagObj;

  q = strchr (p, '\n');
  r = q ? strchr (q, '\n') : NULL;

  len = strlen (p);
  tmp = alloca (len + 1);
  memcpy (tmp, p, len + 1);

  if (q)
    {
      tmp[q - p] = '\0';
      nsOOP = vmProxy->stringToOOP (tmp);
      typeOOP = vmProxy->stringToOOP (tmp + (q - p + 1));
    }
  else
    {
      nsOOP = emptyString;
      typeOOP = vmProxy->stringToOOP (tmp);
    }

  if (r)
    {
      tmp[r - p] = '\0';
      qualOOP = vmProxy->stringToOOP (tmp + (r - p + 1));
    }
  else
    qualOOP = emptyString;

  tagOOP = vmProxy->objectAlloc (nodeTagClass, 0);
  tagObj = OOP_TO_OBJ (tagOOP);
  tagObj->data[0] = nsOOP;
  tagObj->data[1] = typeOOP;
  tagObj->data[2] = qualOOP;
  return tagOOP;
}


/* Make an Attribute object from ATTR[0] (a qualified name triplet)
   and ATTR[1] (the value).  Account for our own brain damage: the number
   of instance variables inherited by Attribute is variable.  */

static OOP
make_attribute (const char **attr)
{
  OOP attributeOOP, nameOOP, valueOOP;
  mst_Object obj;
  size_t n;

  nameOOP = make_node_tag (attr[0]);
  valueOOP = vmProxy->stringToOOP (attr[1]);

  attributeOOP = vmProxy->objectAlloc (attributeClass, 0);
  obj = OOP_TO_OBJ (attributeOOP);
  n = vmProxy->OOPToInt (obj->objSize) - 2 - OBJ_HEADER_SIZE_WORDS;
  obj->data[n] = nameOOP;
  obj->data[n + 1] = valueOOP;
  return attributeOOP;
}


/* Make an event object of class CLASSOOP and save it into PARSEROOP for
   later consumption.  The variable arguments are a NULL-terminated list
   of OOPs to be placed in the instance variables of the event object.  */

static void
make_event (OOP parserOOP, OOP classOOP, ...)
{
  va_list va;
  OOP eventOOP, ptr;
  OOP sentinelOOP;
  XMLExpatPullParser parserObj;
  SAXEventSequence pendingObj, sentinelObj;
  mst_Object obj;
  int i;

  eventOOP = vmProxy->objectAlloc (classOOP, 0);
  obj = OOP_TO_OBJ (eventOOP);

  va_start (va, classOOP);
  for (i = 0; (ptr = va_arg (va, OOP)); i++)
    obj->data[i] = ptr;
  va_end (va);

  parserObj = (XMLExpatPullParser) OOP_TO_OBJ (parserOOP);
  if (parserObj->currentEventOOP == vmProxy->nilOOP)
    {
      parserObj->currentEventOOP = eventOOP;
      return;
    }

  /* Sometimes, expat will return more than one event.  In this case, the
     first will go into currentEventOOP, but the others will go in a
     circular linked list whose sentinel node is in pendingEventOOP.
     
     Using a circular linked list makes it very simple to add new events
     at the end without storing HEAD and TAIL of the list.  To add a new
     node at the end, we put the event in the current sentinel node
     (which becomes the tail of the list!) and allocate a new sentinel.  */
  pendingObj = (SAXEventSequence) OOP_TO_OBJ (parserObj->pendingEventOOP);
  pendingObj->eventOOP = eventOOP;

  /* Allocate a new sentinel node and store it.  */
  sentinelOOP = vmProxy->objectAlloc (saxEventSequenceClass, 0);

  parserObj = (XMLExpatPullParser) OOP_TO_OBJ (parserOOP);
  pendingObj = (SAXEventSequence) OOP_TO_OBJ (parserObj->pendingEventOOP);
  sentinelObj = (SAXEventSequence) OOP_TO_OBJ (sentinelOOP);

  sentinelObj->nextOOP = pendingObj->nextOOP;
  pendingObj->nextOOP = sentinelOOP;
  parserObj->pendingEventOOP = sentinelOOP;
}


/* The event handlers for the expat parser.  We just parse the arguments
   to the handler, make an event and try to stop the parser in order to
   push the event to Smalltalk.  */
 
static void
gst_StartElementHandler (void *userData,
			 const XML_Char * name,
			 const XML_Char ** atts)
{
  XML_Parser p = userData;
  OOP parserOOP = XML_GetUserData (p);
  OOP attributesArray;
  int i;

  attributesArray = vmProxy->objectAlloc (vmProxy->arrayClass,
					  count_attributes (atts));
  for (i = 0; *atts; i++, atts += 2)
    {
      OOP attributeOOP = make_attribute (atts);
      mst_Object attributesObj = OOP_TO_OBJ (attributesArray);
      attributesObj->data[i] = attributeOOP;
    }

  make_event (parserOOP,
	      saxStartTagClass,
	      make_node_tag (name),
	      vmProxy->nilOOP,
	      attributesArray);

  XML_StopParser (p, 1);
}

static void
gst_EndElementHandler (void *userData,
		       const XML_Char * name)
{
  XML_Parser p = userData;
  OOP parserOOP = XML_GetUserData (p);
  make_event (parserOOP,
	      saxEndTagClass,
	      make_node_tag (name),
	      NULL);

  XML_StopParser (p, 1);
}

static void
gst_CharacterDataHandler (void *userData,
			  const XML_Char * s,
			  int len)
{
  XML_Parser p = userData;
  OOP parserOOP = XML_GetUserData (p);
  OOP stringOOP;
  char *data;

  data = memcpy (alloca (len + 1), s, len);
  data[len] = 0;
  stringOOP = vmProxy->stringToOOP (data);
  make_event (parserOOP,
	      saxTextClass,
	      stringOOP,
	      vmProxy->intToOOP (1),
	      vmProxy->intToOOP (len),
	      stringOOP,
	      NULL);

  XML_StopParser (p, 1);
}

static void
gst_ProcessingInstructionHandler (void *userData,
				  const XML_Char * target,
       				  const XML_Char * data)
{
  XML_Parser p = userData;
  OOP parserOOP = XML_GetUserData (p);
  make_event (parserOOP,
	      saxProcessingInstructionClass,
	      vmProxy->stringToOOP (target),
	      vmProxy->stringToOOP (data),
	      NULL);

  XML_StopParser (p, 1);
}

static void
gst_CommentHandler (void *userData,
		    const XML_Char * data)
{
  XML_Parser p = userData;
  OOP parserOOP = XML_GetUserData (p);
  OOP stringOOP = vmProxy->stringToOOP (data);
  make_event (parserOOP,
	      saxCommentClass,
	      stringOOP,
	      vmProxy->intToOOP (1),
	      vmProxy->intToOOP (strlen (data)),
	      stringOOP,
	      NULL);

  XML_StopParser (p, 1);
}

static void
gst_StartCdataSectionHandler (void *userData)
{
  XML_Parser p = userData;
  OOP parserOOP = XML_GetUserData (p);
  make_event (parserOOP,
	      saxStartCdataSectionClass,
	      NULL);

  XML_StopParser (p, 1);
}

static void
gst_EndCdataSectionHandler (void *userData)
{
  XML_Parser p = userData;
  OOP parserOOP = XML_GetUserData (p);
  make_event (parserOOP,
	      saxEndCdataSectionClass,
	      NULL);

  XML_StopParser (p, 1);
}

static void
gst_StartDoctypeDeclHandler (void *userData,
			     const XML_Char *doctypeName,
			     const XML_Char *systemId,
			     const XML_Char *publicId,
			     int has_internal_subset)

{
  XML_Parser p = userData;
  OOP parserOOP = XML_GetUserData (p);
  make_event (parserOOP,
	      saxStartDoctypeDeclClass,
	      vmProxy->stringToOOP (publicId),
	      vmProxy->stringToOOP (systemId),
	      make_node_tag (doctypeName),
	      vmProxy->boolToOOP (has_internal_subset),
	      NULL);

  XML_StopParser (p, 1);
}

static void
gst_EndDoctypeDeclHandler (void *userData)
{
  XML_Parser p = userData;
  OOP parserOOP = XML_GetUserData (p);
  make_event (parserOOP,
	      saxEndDoctypeDeclClass,
	      NULL);

  XML_StopParser (p, 1);
}


static void
gst_UnparsedEntityDeclHandler (void *userData,
			       const XML_Char * entityName,
			       const XML_Char * base,
			       const XML_Char * systemId,
			       const XML_Char * publicId,
			       const XML_Char * notationName)
{
  XML_Parser p = userData;
  OOP parserOOP = XML_GetUserData (p);
  make_event (parserOOP,
	      saxUnparsedEntityDeclClass,
	      vmProxy->stringToOOP (publicId),
	      vmProxy->stringToOOP (systemId),
	      vmProxy->stringToOOP (entityName),
	      vmProxy->stringToOOP (notationName),
	      NULL);

  XML_StopParser (p, 1);
}


static void
gst_NotationDeclHandler (void *userData,
			 const XML_Char * notationName,
			 const XML_Char * base,
			 const XML_Char * systemId,
			 const XML_Char * publicId)
{
  XML_Parser p = userData;
  OOP parserOOP = XML_GetUserData (p);
  make_event (parserOOP,
	      saxNotationDeclClass,
	      vmProxy->stringToOOP (publicId),
	      vmProxy->stringToOOP (systemId),
	      vmProxy->stringToOOP (notationName),
	      NULL);

  XML_StopParser (p, 1);
}

static void
gst_StartNamespaceDeclHandler (void *userData,
			       const XML_Char * prefix,
			       const XML_Char * uri)
{
  XML_Parser p = userData;
  OOP parserOOP = XML_GetUserData (p);
  make_event (parserOOP,
	      saxStartPrefixMappingClass,
	      vmProxy->stringToOOP (prefix),
	      vmProxy->stringToOOP (uri),
	      NULL);

  XML_StopParser (p, 1);
}

static void
gst_EndNamespaceDeclHandler (void *userData,
			     const XML_Char * prefix)
{
  XML_Parser p = userData;
  OOP parserOOP = XML_GetUserData (p);
  make_event (parserOOP,
	      saxEndPrefixMappingClass,
	      vmProxy->stringToOOP (prefix),
	      NULL);

  XML_StopParser (p, 1);
}

static void
gst_SkippedEntityHandler (void *userData,
			  const XML_Char * entityName)
{
  XML_Parser p = userData;
  OOP parserOOP = XML_GetUserData (p);
  make_event (parserOOP,
	      saxSkippedEntityClass,
	      vmProxy->stringToOOP (entityName),
	      NULL);

  XML_StopParser (p, 1);
}

/* This is a bit strange, because on the Smalltalk side we want to
   raise a Notification.  So we raise a normal event passing the CONTEXT
   to it; the Smalltalk code arranges to signal the exception and,
   if it is handled, call XML_ExternalEntityParserCreate.

   The chain of parsers is handled on the Smalltalk side.  */

static int
gst_ExternalEntityRefHandler (XML_Parser p,
			      const XML_Char * context,
			      const XML_Char * base,
			      const XML_Char * systemId,
			      const XML_Char * publicId)
{
  OOP parserOOP = XML_GetUserData (p);
  make_event (parserOOP,
	      saxExternalEntityRefClass,
	      vmProxy->stringToOOP (publicId),
	      vmProxy->stringToOOP (systemId),
	      vmProxy->stringToOOP (context),
	      NULL);

  XML_StopParser (p, 1);
  return XML_STATUS_OK;
}


static void
initClasses (void)
{
  emptyString = vmProxy->stringToOOP ("");
  vmProxy->registerOOP (emptyString);

  attributeClass = vmProxy->classNameToOOP ("XML.Attribute");
  nodeTagClass = vmProxy->classNameToOOP ("XML.NodeTag");
  saxCommentClass = vmProxy->classNameToOOP ("XML.SAXComment");
  saxEndCdataSectionClass = vmProxy->classNameToOOP ("XML.SAXEndCdataSection");
  saxEndDoctypeDeclClass = vmProxy->classNameToOOP ("XML.SAXEndDoctypeDecl");
  saxEndDocumentClass = vmProxy->classNameToOOP ("XML.SAXEndDocument");
  saxEndDocumentFragmentClass = vmProxy->classNameToOOP ("XML.SAXEndDocumentFragment");
  saxEndPrefixMappingClass = vmProxy->classNameToOOP ("XML.SAXEndPrefixMapping");
  saxEndTagClass = vmProxy->classNameToOOP ("XML.SAXEndTag");
  saxExternalEntityRefClass = vmProxy->classNameToOOP ("XML.SAXExternalEntityRef");
  saxEventSequenceClass = vmProxy->classNameToOOP ("XML.SAXEventSequence");
  saxNotationDeclClass = vmProxy->classNameToOOP ("XML.SAXNotationDecl");
  saxProcessingInstructionClass = vmProxy->classNameToOOP ("XML.SAXProcessingInstruction");
  saxSkippedEntityClass = vmProxy->classNameToOOP ("XML.SAXSkippedEntity");
  saxStartCdataSectionClass = vmProxy->classNameToOOP ("XML.SAXStartCdataSection");
  saxStartDoctypeDeclClass = vmProxy->classNameToOOP ("XML.SAXStartDoctypeDecl");
  saxStartDocumentClass = vmProxy->classNameToOOP ("XML.SAXStartDocument");
  saxStartDocumentFragmentClass = vmProxy->classNameToOOP ("XML.SAXStartDocumentFragment");
  saxStartPrefixMappingClass = vmProxy->classNameToOOP ("XML.SAXStartPrefixMapping");
  saxStartTagClass = vmProxy->classNameToOOP ("XML.SAXStartTag");
  saxTagEventClass = vmProxy->classNameToOOP ("XML.SAXTagEvent");
  saxTextClass = vmProxy->classNameToOOP ("XML.SAXText");
  saxUnparsedEntityDeclClass = vmProxy->classNameToOOP ("XML.SAXUnparsedEntityDecl");
}


/* Create a parser, associate it to PARSEROOP and set all the event handlers
   properly.  */

static XML_Parser
gst_XML_ParserCreate (OOP parserOOP)
{
  XML_Parser p = XML_ParserCreateNS (NULL, '\n');
  XML_UseParserAsHandlerArg (p);
  XML_SetUserData (p, parserOOP);
  
  XML_SetExternalEntityRefHandler (p, gst_ExternalEntityRefHandler);
  XML_SetStartElementHandler (p, gst_StartElementHandler);
  XML_SetEndElementHandler (p, gst_EndElementHandler);
  XML_SetCharacterDataHandler (p, gst_CharacterDataHandler);
  XML_SetProcessingInstructionHandler (p, gst_ProcessingInstructionHandler);
  XML_SetCommentHandler (p, gst_CommentHandler);
  XML_SetStartCdataSectionHandler (p, gst_StartCdataSectionHandler);
  XML_SetEndCdataSectionHandler (p, gst_EndCdataSectionHandler);
  XML_SetStartDoctypeDeclHandler (p, gst_StartDoctypeDeclHandler);
  XML_SetEndDoctypeDeclHandler (p, gst_EndDoctypeDeclHandler);
  XML_SetUnparsedEntityDeclHandler (p, gst_UnparsedEntityDeclHandler);
  XML_SetNotationDeclHandler (p, gst_NotationDeclHandler);
  XML_SetStartNamespaceDeclHandler (p, gst_StartNamespaceDeclHandler);
  XML_SetEndNamespaceDeclHandler (p, gst_EndNamespaceDeclHandler);
  XML_SetSkippedEntityHandler (p, gst_SkippedEntityHandler);
  XML_SetReturnNSTriplet (p, true);

  if (!saxEventSequenceClass)
    initClasses ();

  return p;
}

void
gst_initModule (VMProxy * proxy)
{
  vmProxy = proxy;
  vmProxy->defineCFunc ("gst_XML_ParserCreate", gst_XML_ParserCreate);
  vmProxy->defineCFunc ("XML_ParserFree", XML_ParserFree);
  vmProxy->defineCFunc ("XML_Parse", XML_Parse);
  vmProxy->defineCFunc ("XML_ResumeParser", XML_ResumeParser);
  vmProxy->defineCFunc ("XML_GetErrorCode", XML_GetErrorCode);
  vmProxy->defineCFunc ("XML_ErrorString", XML_ErrorString);
  vmProxy->defineCFunc ("XML_SetUserData", XML_SetUserData);
  vmProxy->defineCFunc ("XML_ExternalEntityParserCreate", XML_ExternalEntityParserCreate);
}
