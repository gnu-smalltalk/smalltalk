"======================================================================
|
|   SDL declarations 
|
|
 ======================================================================"


"======================================================================
|
| Copyright 2006, 2008 Free Software Foundation, Inc.
| Written by Brad Watson
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


"======================================================================
|
|   Notes: implemented without callbacks.  
|  
 ======================================================================"

Object subclass: #SdlNet
    instanceVariableNames: ''
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Net'! !

CStruct subclass: #IpAddress
    declaration: #(
        (#host #uInt)
        (#port #short))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Net'! !

CStruct subclass: #UdpPacket
    declaration: #(
        (#channel #int)
        (#data (#ptr #CObject))
        (#len #int)
        (#maxLen #int)
        (#status #int)
        (#host #uInt)
        (#port #short))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Net'! !

CStruct subclass: #GenericSocket
    declaration: #(
        (#ready #int))
    classVariableNames: ''
    poolDictionaries: ''
    category: 'LibSDL-Net'! !

!SdlNet class methodsFor: 'Constants'!

inAddrAny
    ^16r00000000!

inAddrNone
    ^16rFFFFFFFF!

inAddrBroadcast
    ^16rFFFFFFFF!

sdlNetMaxUDPChannels
    ^32!

sdlNetMaxUDPAddresses
    ^4!

sdlDataAligned
    ^0!

!SdlNet class methodsFor: 'C call-outs'!

sdlNetInit
    "I initialize the SDL Net API. My C function call prototype:

    extern DECLSPEC int  SDLCALL SDLNet_Init(void);"
    <cCall: 'SDLNet_Init' returning: #int
        args: #( )>!

sdlNetQuit
    "I shutdown the SDL Net API. My C function call prototype:

    extern DECLSPEC void SDLCALL SDLNet_Quit(void);"
    <cCall: 'SDLNet_Quit' returning: #int
        args: #( )>!

sdlNetResolveHost: aCobject0 host: aString1 port: aInt2
    "I resolve a host name and port to an IP address in network
    form. My C function call prototype:

    extern DECLSPEC int SDLCALL SDLNet_ResolveHost(IPaddress *address, const char *host, Uint16 port);"
    <cCall: 'SDLNet_ResolveHost' returning: #int 
        args: #( #cObject #string #int )>!

sdlNetResolveIP: aCobject0
    "I resolve an ip address to a host name in canonical form. My C
    function call prototype:

    extern DECLSPEC const char * SDLCALL SDLNet_ResolveIP(IPaddress *ip);"
    <cCall: 'SDLNet_ResolveIP' returning: #string 
        args: #( #cObject )>!

sdlNetTCPOpen: aCobject0 
    "I open a TCP network socket. My C function call prototype:

    extern DECLSPEC TCPsocket SDLCALL SDLNet_TCP_Open(IPaddress *ip);"
    <cCall: 'SDLNet_TCP_Open' returning: #cObject 
        args: #( #cObject  )>!

sdlNetTCPAccept: aCobject0 
    "I accept an incoming connection on the given server socket. My C
    function call prototype:

    extern DECLSPEC TCPsocket SDLCALL SDLNet_TCP_Accept(TCPsocket server);"
    <cCall: 'SDLNet_TCP_Accept' returning: #cObject 
        args: #( #cObject  )>!

sdlNetTCPGetPeerAddress: aCobject0 
    "I answer the IP address of the remote system associated with the
    socket. My C function call prototype

    extern DECLSPEC IPaddress * SDLCALL SDLNet_TCP_GetPeerAddress(TCPsocket sock);"
    <cCall: 'SDLNet_TCP_GetPeerAddress' returning: #cObject 
        args: #( #cObject  )>!

sdlNetTCPSend: aCobject0 data: aCobject1 len: aInt2
    "I send 'len' bytes of 'data' over the non-server socket
    'sock'. My C function call prototype:

    extern DECLSPEC int SDLCALL SDLNet_TCP_Send(TCPsocket sock, void *data, int len);"
    <cCall: 'SDLNet_TCP_Send' returning: #int 
        args: #( #cObject #cObject #int )>!

sdlNetTCPRecv: aCobject0 data: aCobject1 maxLen: aInt2
    "I receive up to 'maxlen' bytes of data over the non-server socket
    'sock'. My C function call prototype:

    extern DECLSPEC int SDLCALL SDLNet_TCP_Recv(TCPsocket sock, void *data, int maxlen);"
    <cCall: 'SDLNet_TCP_Recv' returning: #int 
        args: #( #cObject #cObject #int )>!

sdlNetTCPClose: aCobject0
    "I close a TCP network socket. My C function call prototype:

    extern DECLSPEC void SDLCALL SDLNet_TCP_Close(TCPsocket sock);"
    <cCall: 'SDLNet_TCP_Close' returning: #void 
        args: #( #cObject )>!

sdlNetAllocPacket: aInt0 
    "I allocate a single UDP packet 'size' bytes long. My C function
    call prototype:

    extern DECLSPEC UDPpacket * SDLCALL SDLNet_AllocPacket(int size);"
    <cCall: 'SDLNet_AllocPacket' returning: #cObject 
        args: #( #int  )>!

sdlNetResizePacket: aCobject newSize: aInt1
    "I resize a single UDP packet 'size' bytes long. My C function
    call prototype:

    extern DECLSPEC int SDLCALL SDLNet_ResizePacket(UDPpacket *packet, int newsize);"
    <cCall: 'SDLNet_ResizePacket' returning: #int 
        args: #( #cObject #int )>!

sdlFreePacket: aCobject0
    "I free a single UDP packet 'size' bytes long. My C function
    call prototype:

    extern DECLSPEC void SDLCALL SDLNet_FreePacket(UDPpacket *packet);"
    <cCall: 'SDLNet_FreePacket' returning: #void 
        args: #( #cObject )>!

sdlNetAllocPacketV: aInt0 size: aInt1 
    "I allocate a UDP packet vector. My C function call prototype:

    extern DECLSPEC UDPpacket ** SDLCALL SDLNet_AllocPacketV(int howmany, int size);"
    <cCall: 'SDLNet_AllocPacketV' returning: #cObjectPtr
        args: #( #int #int  )>!

sdlNetFreePacketV: aCobjectPtr0
    "I free a UDP packet vector. My C function call prototype:

    extern DECLSPEC void SDLCALL SDLNet_FreePacketV(UDPpacket **packetV);"
    <cCall: 'SDLNet_FreePacketV' returning: #void 
        args: #( #cObjectPtr )>!

sdlNetUDPOpen: aInt0 
    "I open a UDP network socket. My C function call prototype:

    extern DECLSPEC UDPsocket SDLCALL SDLNet_UDP_Open(Uint16 port);"
    <cCall: 'SDLNet_UDP_Open' returning: #cObject 
        args: #( #int  )>!

sdlNetUDPBind: aCobject0 channel: aInt1 address: aCobject2
    "I bind the address given to me to the requested channel on the
    UDP socket. My C function call prototype:

    extern DECLSPEC int SDLCALL SDLNet_UDP_Bind(UDPsocket sock, int channel, 
         IPaddress *address);"
    <cCall: 'SDLNet_UDP_Bind' returning: #int 
        args: #( #cObject #int #cObject )>!

sdlNetUDPUnbind: aCobject0 channel: aInt1
    "I unbind all addresses from the given channel. My C function call
    prototype:

    extern DECLSPEC void SDLCALL SDLNet_UDP_Unbind(UDPsocket sock, int channel);"
    <cCall: 'SDLNet_UDP_Unbind' returning: #void 
        args: #( #cObject #int )>!

sdlNetUDPGetPeerAddress: aCobject0 channel: aInt1 
    "I get the primary IP address of the remote system associated with
    the socket and channel. My C function call prototype:

    extern DECLSPEC IPaddress * SDLCALL SDLNet_UDP_GetPeerAddress(UDPsocket sock, 
         int channel);"
    <cCall: 'SDLNet_UDP_GetPeerAddress' returning: #cObject 
        args: #( #cObject #int  )>!

sdlNetUDPSendV: aCobject0 packets: aCobjectPtr1 nPackets: aInt2
    "I send a vector of packets to the the channels specified within
    the packet. My C function call prototype:

    extern DECLSPEC int SDLCALL SDLNet_UDP_SendV(UDPsocket sock, 
         UDPpacket **packets, int npackets);"
    <cCall: 'SDLNet_UDP_SendV' returning: #int 
        args: #( #cObject #cObjectPtr #int )>!

sdlNetUDPSend: aCobject0 channel: aInt1 packet: aCobject2
    "I send a single packet to the specified channel. My C function
    call prototype:

    extern DECLSPEC int SDLCALL SDLNet_UDP_Send(UDPsocket sock, int channel, 
         UDPpacket *packet);"
    <cCall: 'SDLNet_UDP_Send' returning: #int 
        args: #( #cObject #int #cObject )>!

sdlNetUDPRecvV: aCobject0 packets: aCobjectPtr1
    "I Receive a vector of pending packets from the UDP socket. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDLNet_UDP_RecvV(UDPsocket sock, 
         UDPpacket **packets);"
    <cCall: 'SDLNet_UDP_RecvV' returning: #int 
        args: #( #cObject #cObjectPtr )>!

sdlNetUDPRecv: aCobject0 packet: aCobject1
    "I receive a vector of pending packets from the UDP socket. My C
    function call prototype:

    extern DECLSPEC int SDLCALL SDLNet_UDP_Recv(UDPsocket sock, 
         UDPpacket *packet);"
    <cCall: 'SDLNet_UDP_Recv' returning: #int 
        args: #( #cObject #cObject )>!

sdlNetUdpClose: aCobject0
    "I close a UDP network socket. My C function call prototype:

    extern DECLSPEC void SDLCALL SDLNet_UDP_Close(UDPsocket sock);"
    <cCall: 'SDLNet_UDP_Close' returning: #void 
        args: #( #cObject )>!

sdlNetAllocSocketSet: aInt0 
    "I allocate a socket set for use with SDLNet_CheckSockets(). My C
    function call prototype:

    extern DECLSPEC SDLNet_SocketSet SDLCALL SDLNet_AllocSocketSet(int maxsockets);"
    <cCall: 'SDLNet_AllocSocketSet' returning: #cObject 
        args: #( #int  )>!

sdlNetAddSocket: aCobject0 sock: aCobject1
    "I add a socket to a set of sockets to be checked for available
    data. My C function call prototype:

    extern DECLSPEC int SDLCALL SDLNet_AddSocket(SDLNet_SocketSet set, 
         SDLNet_GenericSocket sock);"
    <cCall: 'SDLNet_AddSocket' returning: #int 
        args: #( #cObject #cObject )>!

sdlNetDelSocket: aCobject0 sock: aCobject1
    "I remove a socket from a set of sockets to be checked for
    available data. My C function call prototype:

    extern DECLSPEC int SDLCALL SDLNet_DelSocket(SDLNet_SocketSet set, 
         SDLNet_GenericSocket sock);"
    <cCall: 'SDLNet_DelSocket' returning: #int 
        args: #( #cObject #cObject )>!

sdlNetCheckSockets: aCobject0 timeOut: aUint1
    "I answer if data is available for reading on the given set of
    sockets. My C function call prototype:

    extern DECLSPEC int SDLCALL SDLNet_CheckSockets(SDLNet_SocketSet set, 
         Uint32 timeout);"
    <cCall: 'SDLNet_CheckSockets' returning: #int 
        args: #( #cObject #uInt )>!

sdlNetFreeSocketSet: aCobject0
    "I free a set of sockets allocated by SDL_NetAllocSocketSet(). My
    C function call prototype:

    extern DECLSPEC void SDLCALL SDLNet_FreeSocketSet(SDLNet_SocketSet set);"
    <cCall: 'SDLNet_FreeSocketSet' returning: #void 
        args: #( #cObject )>!

sdlNetWrite16: aInt0 area: aCobject1
    "I write a 16 bit value to network packet buffer. My C function
    call prototype:

    extern DECLSPEC void SDLCALL SDLNet_Write16(Uint16 value, void *area);"
    <cCall: 'SDLNet_Write16' returning: #void 
        args: #( #int #cObject )>!

sdlNetWrite32: aInt0 area: aCobject1
    "I write a 32 bit value to network packet buffer. My C function
    call prototype:
    
    extern DECLSPEC void SDLCALL SDLNet_Write32(Uint32 value, void *area);"
    <cCall: 'SDLNet_Write32' returning: #void 
        args: #( #int #cObject )>!

sdlNetRead16: aCobject0 
    "I read a 16 bit value from network packet buffer. My C function
    call prototype:

    extern DECLSPEC Uint16 SDLCALL SDLNet_Read16(void *area);"
    <cCall: 'SDLNet_Read16' returning: #int 
        args: #( #cObject  )>!

sdlNetRead32: aCobject0 
    "I read a 32 bit value from network packet buffer. My C function
    call prototype:

    extern DECLSPEC Uint32 SDLCALL SDLNet_Read32(void *area);"
    <cCall: 'SDLNet_Read32' returning: #int 
        args: #( #cObject  )>! !
"
sdlNetSetError: aString0 args: aVariadic1
    I report a net error. My C function call prototype:

    extern no_parse_DECLSPEC void SDLCALL SDLNet_SetError(const char *fmt, ...);
    <cCall: 'SDLNet_SetError' returning: #void 
        args: #( #string #variadic )>!

sdlNetGetError
    I answer a net error. My C function call prototype:

    extern no_parse_DECLSPEC char * SDLCALL SDLNet_GetError(void);
    <cCall: 'SDLNet_GetError' returning: #string 
        args: #( )>! !
"
