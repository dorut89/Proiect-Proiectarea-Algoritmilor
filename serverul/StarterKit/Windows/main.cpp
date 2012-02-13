#define _WIN32_WINNT 0x0500
#define _USE_MATH_DEFINES
#include <fstream>
#include <iostream>
#include <conio.h>
#include <vector>
#include <math.h>
#include "packet.h"
#include "protocol.h"
#include "networking.h"

#define SERVER_IP_DEFAULT       "127.0.0.1"
#define SERVER_AI_PORT_DEFAULT  6666

using namespace std;

Peer    server;

int main(int argn, char* args[])
{
    char ip[64] = {0};
    unsigned short server_port = SERVER_AI_PORT_DEFAULT;
    if (argn==3)
    {
        strcpy_s(ip, 64, args[1]);
        server_port = atoi(args[2]);
    }
    else
        strcpy_s(ip, 64, SERVER_IP_DEFAULT);

    char teamname[256];
    cin >> teamname;

    WSAInit();
	if (0 != server.Connect(ip, server_port))
	{
		fprintf(stderr, "Connect error: Invalid Socket\n");
		exit(0);
	}

    // send the team name to the server
    {
		string pak;
        int len = MakeTeamNamePacket(pak, teamname);
        send(server.GetSocket(), pak.c_str(), len, 0);
    }

    while(1)
    {
        const int header = server.ReadInt_BE();
        switch (header)
        {
            case P_MAP_DIM:
            {
                cout << "Received map dimentions packet\n";
            }; break;

            case P_INITIAL_INFO:
            {
            }; break;

            case P_CAR_CONFIRM:
            {
            }; break;

            case P_POS_CONFIRM:
            {
            }; break;

            case P_ENDRACE:
            {
            }; break;

            default:
            {
                cout << "Unknown message\n";
            }
        }
    }
}
