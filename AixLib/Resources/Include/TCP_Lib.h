/** TCP socket support (header-only library).
 *
 * @author		Georg Ferdinand Schneider <Georg.Schneider@ibp.fraunhofer.de>
 * @author		Dr. Jens Oppermann <jens.oppermann@wilo.com>
 * @version	    2015-11-12 17:00:00 V1.1
 * @since		2012-04-01
 * @copyright  WILO SE, Nortkirchenstra�e 100, 44147 Dortmund, Germany
 */

  
#ifndef TCP_LIB_H_
#define TCP_LIB_H_

#include "ModelicaUtilities.h"

#if defined(_MSC_VER)

#include <winsock2.h>
#include <ws2tcpip.h>
//#include <stdlib.h> //Excluded to avoid clashing with dymosim and DDE compilation
//#include <stdio.h> //Excluded to avoid clashing with dymosim and DDE compilation
#include <string.h>

#define MAX_SIZE	256

// Need to link with Ws2_32.lib, Mswsock.lib, and Advapi32.lib
#pragma comment (lib, "Ws2_32.lib")
#pragma comment (lib, "Mswsock.lib")
#pragma comment (lib, "AdvApi32.lib")

// Typedefinitions in the begining
typedef const char* tIpAddr; // string with IP Address of Server
typedef const char* tPort; // String with port number of Server
typedef const char* tData; // String of Data to be send
typedef unsigned char* tByte; // Array of Byte to be received
 
 
// Global data needed in process
    WSADATA gWsaData; 
    SOCKET gConnectSocket = INVALID_SOCKET; // Socket deklaration
    struct addrinfo *gpResult = NULL,
                    *gPtr = NULL,
                    gHints; // 3 times struct addrinfo


/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
// Functions to handle TCP communication


int SocketInit(void) // Initialize a Socket, incorporated in TCPConstructor()
{
	int ans;
   // Initialize Winsock
    ans = WSAStartup(MAKEWORD(2,2), &gWsaData);
    if (ans != 0) {
	ModelicaFormatMessage("SocketInit(): WSAStartup failed with error: %d\n", ans);
	return 1;
    }
	
    ZeroMemory( &gHints, sizeof(gHints) );
    gHints.ai_family = AF_UNSPEC;
    gHints.ai_socktype = SOCK_STREAM;
    gHints.ai_protocol = IPPROTO_TCP;
	return ans;
}

int SocketDestruct(void) // Destruct socket and clean up
{
    // cleanup
    closesocket(gConnectSocket);
    WSACleanup();
	return 0;
}

int SocketConnect(tIpAddr ip, tPort port) // Connect to server on ip and port
{
	int iResult;
    // Resolve the server address and port
    iResult = getaddrinfo(ip, port, &gHints, &gpResult);
    if ( iResult != 0 ) {
		ModelicaFormatMessage("SocketConnect(): getaddrinfo failed with error: %d\n", iResult);
        WSACleanup();
        return 1;
    }

    // Attempt to connect to an address until one succeeds
    for(gPtr=gpResult; gPtr != NULL ;gPtr=gPtr->ai_next) {

        // Create a SOCKET for connecting to server
        gConnectSocket = socket(gPtr->ai_family, gPtr->ai_socktype, 
            gPtr->ai_protocol);
        if (gConnectSocket == INVALID_SOCKET) {
			ModelicaFormatMessage("SocketConnect(): Socket failed with error: %ld\n", WSAGetLastError());
			WSACleanup();
            return 1;
        }

        // Connect to server.
        iResult = connect( gConnectSocket, gPtr->ai_addr, (int)gPtr->ai_addrlen);
        if (iResult == SOCKET_ERROR) {
            closesocket(gConnectSocket);
            gConnectSocket = INVALID_SOCKET;
            continue;
        }
        break;
    }

    freeaddrinfo(gpResult);

    if (gConnectSocket == INVALID_SOCKET) {
		ModelicaFormatMessage("SocketConnect(): Unable to connect to server!\n");     
		WSACleanup();
        return 1;
    }
	return 0;
}

int SocketDisconnect(void) // End communcation
{
 	int iResult;
   // shutdown the connection since no more data will be sent
    iResult = shutdown(gConnectSocket, SD_SEND);
    if (iResult == SOCKET_ERROR) {
        ModelicaFormatMessage("SocketDisconnect(): Shutdown failed with error: %d\n", WSAGetLastError());
        closesocket(gConnectSocket);
        WSACleanup();
        return 1;
    }
	return 0;
}

int SocketSend(tData sendbuf, int len) // Send data via socket
{
	int iResult;
    // Send an initial buffer
    iResult = send( gConnectSocket, sendbuf, len, 0 );
    if (iResult == SOCKET_ERROR) {
        ModelicaFormatMessage("SocketSend(): Send failed with error: %d\n", WSAGetLastError());
        closesocket(gConnectSocket);
        WSACleanup();
        return 1;
    }
	return iResult;
}

int SocketReceive(char **buffer, int maxLen) // Receive data on socket
{
	int iResult;
	char *answerBuffer;
	answerBuffer = ModelicaAllocateString(maxLen);
	iResult = recv(gConnectSocket, answerBuffer, maxLen, 0);
	*buffer = answerBuffer;
	return iResult;
}

int TCPConstructor(tIpAddr ip, tPort port) // Initialize socket and connect to server
{
	// Intialize socket
    if (0 != SocketInit())
	{
	ModelicaFormatMessage("SocketInit(): Unable to initialise socket!\n");  
      return 1;
    }
			
	// Connect to Server with ip on port
	if (0 != SocketConnect(ip, port)) {
	ModelicaFormatMessage("SocketConnect(): Unable to connect to server!\n");  
		return 2;
	}
	return 0;
}

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
// Functions for data conversion of protocol specific problems
 
unsigned char *convertHextoByte(char *HEXStr) {
    int i, n;
	int len = strlen(HEXStr)/2;
	char *buffer;
 
	buffer = ModelicaAllocateString(len);
//	ModelicaFormatMessage("HEX-String: %s\n", HEXStr); //for Debugging

	for(i = 0; i < len; i++) {
        sscanf(HEXStr+2*i, "%02X", &n);
        buffer[i] = (char)n;
//		ModelicaFormatMessage("Byte: %02X %s", buffer[i],"\n"); // for Debugging
    }
	return buffer;
}

float convertBytetoSgl(unsigned char *ByteArray) {
	char byArr[4];
    int i;
  
    union record_4 {
      char c[4];
      unsigned char u[4];
      short s[2];
      long l;
      float f;
    } r;
  
//    strcpy(r.c, "Error !"); // for Debugging
//    strcpy(r.c, "1234567");

// Change order high and low byte
	r.u[0] = ByteArray[1];
	r.u[1] = ByteArray[0];
	r.u[2] = ByteArray[3];
	r.u[3] = ByteArray[2];
  
//    ModelicaFormatMessage("%s\n", r.c);
//    for(i=0;i<4;i++) ModelicaFormatMessage("%d ",  r.c[i]); ModelicaFormatMessage("\n");
//    for(i=0;i<4;i++) ModelicaFormatMessage("%d ",  r.u[i]); ModelicaFormatMessage("\n");
//    for(i=0;i<2;i++) ModelicaFormatMessage("%d ",  r.s[i]); ModelicaFormatMessage("\n");
//    for(i=0;i<1;i++) ModelicaFormatMessage("%ld ", r.l[i]); ModelicaFormatMessage("\n");
//    for(i=0;i<1;i++) ModelicaFormatMessage("%f ",  r.f[i]); ModelicaFormatMessage("\n");
//    ModelicaFormatMessage("%lf\n", r.d);
//    ModelicaFormatMessage("%f\n", r.f);

//		ModelicaFormatMessage("Byte: %02X %s", buffer[i],"\n"); // for Debugging

	return r.f; // *((Float*)&byArr)
}

unsigned char **convertDbltoHex(double num) {
	unsigned char *byArr;
	unsigned char *buffer;
    int i;
    float num_f;

    union record_4 {
      char c[4];
      unsigned char u[4];
      short s[2];
      long l;
      float f;
    } r;
  
	r.f = (float)num; //Type cast into float, because Modelica Type Real is Double.
	byArr = ModelicaAllocateString(4);
	buffer = ModelicaAllocateString(8);
	
	// Change order high and low byte
	byArr[0] = r.u[1];
	byArr[1] = r.u[0];
	byArr[2] = r.u[3];
	byArr[3] = r.u[2];

	//    ModelicaFormatMessage("%s\n", r.c);
/*    for(i=0;i<4;i++) ModelicaFormatMessage("%d ",  r.c[i]); ModelicaFormatMessage("\n");
    for(i=0;i<4;i++) ModelicaFormatMessage("%d ",  r.u[i]); ModelicaFormatMessage("\n");
    for(i=0;i<2;i++) ModelicaFormatMessage("%d ",  r.s[i]); ModelicaFormatMessage("\n");
    for(i=0;i<1;i++) ModelicaFormatMessage("%ld ", r.l); ModelicaFormatMessage("\n");
    for(i=0;i<1;i++) ModelicaFormatMessage("%f ",  r.f); ModelicaFormatMessage("\n");
    ModelicaFormatMessage("%lf\n", num);
	for(i=0;i<4;i++) ModelicaFormatMessage("Byte: %02X %s", byArr[i],"\n"); ModelicaFormatMessage("\n");// for Debugging
*/	
	for(i = 0; i < 4; i++) {
        sprintf(buffer+2*i, "%02X", byArr[i]);
	}
//	ModelicaFormatMessage("%s\n", buffer);
	
	return buffer; // *((Float*)&byArr)
}

char *convertBytetoHex(unsigned char *ByteStr) {
    int i;
	char *buffer;
	int len = strlen(ByteStr);

	buffer = ModelicaAllocateString(len*2+1);

    for(i = 0; i < len; i++) {
        sprintf(buffer+2*i, "%02X", ByteStr[i]);
   //     ModelicaFormatMessage("Byte out: %02X ", ByteStr[i]); // for Debugging
	}
    return buffer;
}


void convertStrtoDbl(char* string, double * data) // convert a string into a double
{
	*data = atof(string);
}

void convertStrtoInt(char* string, int * data) // convert a string into a integer
{
	*data = atoi(string);
}
 
 
#endif /* defined(_MSC_VER) */

#endif /* TCP_LIB_H_ */