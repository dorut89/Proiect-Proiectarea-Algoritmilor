#ifndef __PACKET_H__
#define __PACKET_H__

#include <string>

using namespace std;

void byte_flip(char buf[], int size);

const int GetPacketType(const char* const packet);

int MakeTeamNamePacket(string& pak, const string& name);

int MakeCarConfigPacket(string& pak, const int maxacc,
                                     const int maxbrk,
                                     const int maxspd,
                                     const double maxstr);

int MakeDriveInfoPacket(string& pak, const double accp,
                                     const double brkp,
                                     const double desiredangle,
                                     const int drop);

void PrintDriveInfoPacket(string& pak, const int len);

#endif
