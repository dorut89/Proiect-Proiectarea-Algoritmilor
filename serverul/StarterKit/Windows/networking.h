#ifndef __NETWORKING_H__
#define __NETWORKING_H__

#include <winsock2.h>
#include <Mswsock.h>
#include <Windows.h>
#include <string>
#include <iostream>
using namespace std;

int     WSAInit();
int     CloseConnection(const SOCKET sockfd);
int     BindSocket(const SOCKET& listenfd, const unsigned short port);
SOCKET  ConnectTo(const char *name, const unsigned short port);

SOCKET  CreateSocketListen();

int     ListenForConnections(SOCKET listenfd, const int backlog);

SOCKET  WSAListenForConnections(const unsigned short port, 
                                const int backlog,
                                const bool overlapped);

class Peer
{
public:
    Peer() : sockfd(0)
    {}

    Peer(const SOCKET sockfd)
    {
        if (this->sockfd)
        {
            CloseConnection(this->sockfd);
        }
        this->sockfd=sockfd;
    }

    inline const SOCKET& GetSocket() const
    {
        return sockfd;
    }

    inline void SetSocket(const SOCKET sockfd)
    {
        this->sockfd=sockfd;
    }

	inline int Connect(const char *name, const unsigned short port)
	{
		if ((sockfd=ConnectTo(name,port))==INVALID_SOCKET)
		{
			return 1;
		}

		int on = 176; // anything not 0 or 1
		int len = sizeof(on);
		getsockopt(sockfd, IPPROTO_TCP, TCP_NODELAY, (char *)&on, &len);
		cout << "TCP_NODELAY value was " << on << endl;

		on = 1;
		setsockopt(sockfd, IPPROTO_TCP, TCP_NODELAY, (char *)&on, sizeof(on));

		len = sizeof(on);
		getsockopt(sockfd, IPPROTO_TCP, TCP_NODELAY, (char *)&on, &len );
		cout << "TCP_NODELAY value now is " << on << endl;

		return 0;
	}

	inline int Connect(const string& name, const unsigned short port)
	{
		return Connect(name.c_str(), port);
	}

    inline void CreateListenSocket()
    {
        sockfd = CreateSocketListen();

		int on = 176; // anything not 0 or 1
		int len = sizeof(on);

		getsockopt(sockfd, IPPROTO_TCP, TCP_NODELAY, (char *)&on, &len);
		cout << "TCP_NODELAY value was " << on << endl;

		on = 1;
		setsockopt(sockfd, IPPROTO_TCP, TCP_NODELAY, (char *)&on, sizeof(on));

		len = sizeof(on);
		getsockopt(sockfd, IPPROTO_TCP, TCP_NODELAY, (char *)&on, &len );
		cout << "TCP_NODELAY value now is " << on << endl;
    }

	inline int Listen(const int backlog=SOMAXCONN)
	{
		return ListenForConnections(sockfd, backlog);
	}

    inline int Bind(const unsigned short port)
    {
        return BindSocket(this->sockfd, port);
    }

	inline int Disconnect()
	{
		const int res = CloseConnection(sockfd);
		sockfd = 0;
		return res;
    }

	// read exactly size bytes (no more, no less)
	inline void recv_b(const int sockfd, char buf[], const int size) const
	{
		int iSum = 0;
		while (iSum < size)
		{
			int iResult = recv(sockfd, buf+iSum, size-iSum, 0); 
			if (iResult > 0)
			{
				iSum += iResult;
			}
			else if (iResult == 0)
			{
				fprintf(stderr, "recv error: connection closed\n");
				exit(0);
			}
			else if (iResult < 0)
			{
				fprintf(stderr, "recv failed: %d\n", WSAGetLastError());
				exit(0);
			}
		}
	}

	// read int in little endian format
    inline int ReadInt_LE() const
    {
        int val = 0;
        const int size = 4;
        char buf[8] = {0};

        recv_b(sockfd, buf, size);
        memcpy(&val, buf, size);

        return val;
    }

	// read double in little endian format
    inline double ReadDouble_LE() const
    {
        double val = 0;
        const int size = 8;
        char buf[8] = {0};

        recv_b(sockfd, buf, size);
        memcpy(&val, buf, size);

        return val;
    }

	// read int in big endian format
    inline int ReadInt_BE() const
    {
        int val = 0;
        const int size = 4;
        char buf[8] = {0};
		
		recv_b(sockfd, buf, size);        

		// flip it
        for (int i=0; i<size/2; ++i)
	    {
		    char tmp = buf[i];
		    buf[i] = buf[size-i-1];
		    buf[size-i-1] = tmp;
	    }

        memcpy(&val, buf, size);

        return val;
    }

	// read double in big endian format
    inline double ReadDouble_BE() const
    {
        double val = 0;
        const int size = 8;
        char buf[8] = {0};

        recv_b(sockfd, buf, size);
        
		// flip it
	    for (int i=0; i<size/2; ++i)
	    {
		    char tmp = buf[i];
		    buf[i] = buf[size-i-1];
		    buf[size-i-1] = tmp;
	    }
		
        memcpy(&val, buf, size);

        return val;
    }

	~Peer()
	{
        if(sockfd)
        {
            CloseConnection(sockfd);
        }
    }

protected:
    SOCKET sockfd;
};

int PSend(const Peer& p, const string &s, int flags=0);

#endif
