#define _USE_MATH_DEFINES
#include "protocol.h"
#include "packet.h"
#include <string.h>
#include <iostream>
#include <math.h>

void byte_flip(char buf[], int size)
{
	char tmp;
	for (int i=0; i<size/2; ++i)
	{
		tmp = buf[i];
		buf[i] = buf[size-i-1];
		buf[size-i-1] = tmp;
	}
}

const int GetPacketType(const char* const packet)
{
    int type;
    char buf[5] = {0};
    buf[0] = packet[3];
    buf[1] = packet[2];
    buf[2] = packet[1];
    buf[3] = packet[0];
    memcpy(&type, buf, 4);

    //memcpy(&type, packet, 4);
    return type;
}

int MakeTeamNamePacket(string& pak, const string& name)
{
    int header = P_TEAMNAME;
    int len = name.length();
    char buf[9] = {0};
    memcpy(buf, &header, 4);
    byte_flip(buf, 4);
    memcpy(buf+4, &len, 4);
    byte_flip(buf+4, 4);

    pak.assign(buf, 8);
    pak.append(name);

    return len+8;
}

int MakeCarConfigPacket(string& pak, const int maxacc,
                                     const int maxbrk,
                                     const int maxspd,
                                     const double maxstr)
{
    int header = P_CAR_CONFIG;
    char buf[28] = {0};

    memcpy(buf, &header, 4);
    byte_flip(buf, 4);

    memcpy(buf+4, &maxacc, 4);
    byte_flip(buf+4, 4);

    memcpy(buf+8, &maxbrk, 4);
    byte_flip(buf+8, 4);

    memcpy(buf+12, &maxspd, 4);
    byte_flip(buf+12, 4);

    memcpy(buf+16, &maxstr, 8);
    byte_flip(buf+16, 8);

    pak.assign(buf, 24);

    return 24;
}

int MakeDriveInfoPacket(string& pak, const double accp,
                                     const double brkp,
                                     const double desiredangle,
                                     const int drop)
{
    int header = P_DRIVE_INFO;
    char buf[36] = {0};

    memcpy(buf, &header, 4);
    byte_flip(buf, 4);

    memcpy(buf+4, &accp, 8);
    byte_flip(buf+4, 8);

    memcpy(buf+12, &brkp, 8);
    byte_flip(buf+12, 8);

    memcpy(buf+20, &desiredangle, 8);
    byte_flip(buf+20, 8);

    memcpy(buf+28, &drop, 4);
    byte_flip(buf+28, 4);

    pak.assign(buf, 32);

    return 32;
}

void PrintDriveInfoPacket(string& pak, const int len)
{
    double accp;
    double brkp;
    double desiredangle;

    memcpy(&accp, pak.c_str()+4, 8);
	cout << "Sending Drive Info Packet to server:" << endl;
    cout << "ACC% = " << accp << endl;
    memcpy(&brkp, pak.c_str()+12, 8);
    cout << "BRK% = " << brkp << endl;
    memcpy(&desiredangle, pak.c_str()+20, 8);
    cout << "angle: " << desiredangle << " in degrees: " << (180*desiredangle)/M_PI <<endl;
}

