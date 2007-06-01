"======================================================================
|
|   NetClients loading script.
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2002 Free Software Foundation, Inc.
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

Smalltalk addSubspace: #NetClients!
NetClients addSubspace: #FTP!
NetClients addSubspace: #HTTP!
NetClients addSubspace: #IMAP!
NetClients addSubspace: #MIME!
NetClients addSubspace: #NNTP!
NetClients addSubspace: #POP!
NetClients addSubspace: #SMTP!
Namespace current: NetClients!

FileStream fileIn: 'Base.st'.
FileStream fileIn: 'ContentHandler.st'.
FileStream fileIn: 'MIME.st'.
FileStream fileIn: 'IMAP.st'.
FileStream fileIn: 'POP.st'.
FileStream fileIn: 'SMTP.st'.
FileStream fileIn: 'NNTP.st'.
FileStream fileIn: 'FTP.st'.
FileStream fileIn: 'HTTP.st'.
FileStream fileIn: 'URIResolver.st'.
FileStream fileIn: 'NetServer.st'!

Namespace current: Smalltalk!

