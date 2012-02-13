#include "networking.h"

int WSAInit()
{
	WSADATA wsaData;
	int iResult;

	iResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
	if (iResult != NO_ERROR)
		return iResult;

	return 0;
}

SOCKET ConnectTo(const char *name, const unsigned short port)
{
    struct hostent *hent;
    struct sockaddr_in server_addr;
    SOCKET s;

    hent = gethostbyname(name);
    if (hent == NULL)
    {
	    return INVALID_SOCKET;
    }

    s = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (s == INVALID_SOCKET)
    {
	    return INVALID_SOCKET;
    }

    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(port);
    memcpy(&server_addr.sin_addr.s_addr, hent->h_addr,
            sizeof(server_addr.sin_addr.s_addr));

    if (connect(s, reinterpret_cast<sockaddr*>(&server_addr),
                    sizeof(server_addr)))
    {
	    return INVALID_SOCKET;
    }

    return s;
}

SOCKET CreateSocketListen()
{
    SOCKET listenfd;

    listenfd = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (listenfd == INVALID_SOCKET)
    {
        return INVALID_SOCKET;
	}

    int sock_opt = 1;
    if (setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR,
        reinterpret_cast<const char *>(&sock_opt), sizeof(int)) < 0)
    {
        exit(EXIT_FAILURE);
    }

    return listenfd;
}

int CloseConnection(const SOCKET sockfd)
{
    if (shutdown(sockfd, SD_BOTH) == SOCKET_ERROR)
    {
	    return WSAGetLastError();
	}

    if (closesocket(sockfd) ==  SOCKET_ERROR)
    {
        return WSAGetLastError();
    }
    return 0;
}

int BindSocket(const SOCKET& listenfd, const unsigned short port)
{
    struct sockaddr_in address;

    memset(&address, 0, sizeof(address));
    address.sin_family = AF_INET;
    address.sin_port = htons(port);
    address.sin_addr.s_addr = INADDR_ANY;

    if (bind(listenfd, reinterpret_cast<sockaddr*>(&address), sizeof(address)))
    {
        const int err = WSAGetLastError();
        closesocket(listenfd);
        return WSAGetLastError();
    }
    return 0;
}

int ListenForConnections(SOCKET listenfd, const int backlog)
{
    if (listen(listenfd, backlog) < 0)
    {
        closesocket(listenfd);
        return 1;
    }
    return 0;
}

int PSend(const Peer& p, const string &s, int flags)
{
    return send(p.GetSocket(), s.c_str(), s.size(), flags);
}
