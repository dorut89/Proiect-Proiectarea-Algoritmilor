package hotpursuit;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.net.SocketAddress;
import java.net.SocketException;
import java.net.SocketTimeoutException;

/**
 *
 * A complete Java class that demonstrates how to use the Socket
 * class, specifically how to open a socket, write to the socket,
 * and read from the socket.
 *
 * @author alvin alexander, devdaily.com.
 *
 */
public class ClientSocket {
    private Socket socket;

    private DataInputStream in;
    private DataOutputStream out;

    public ClientSocket(String server, int port) throws IOException {
        try {
            // open a socket
            socket = openSocket(server, port);
        }
        catch (Exception e) {
            e.printStackTrace();
        }

        in = new DataInputStream(socket.getInputStream());
        out = new DataOutputStream(socket.getOutputStream());
    }

    public void closeStreams() throws IOException {
            in.close();
            out.close();
            socket.close();
    }

    public void writeByte(byte value) throws IOException {
            out.writeByte(value);
    }

    public void writeInt(int value) throws IOException {
            out.writeInt(value);
    }

    public void writeDouble(double value) throws IOException {
            out.writeDouble(value);
    }

    public int readInt() throws IOException {
            return in.readInt();
    }

    public double readDouble() throws IOException {
            return in.readDouble();
    }

    public byte readByte() throws IOException {
            return in.readByte();
    }

    public short readShort() throws IOException {
            return in.readShort();
    }

    public void allowTimeout(int timeout) throws SocketException {
            socket.setSoTimeout(timeout);
    }

    public void writeString(String name) throws IOException {
            out.writeBytes(name);
    }

    /**
    * Open a socket connection to the given server on the given port.
    * This method currently sets the socket timeout value to 10 seconds.
    * (A second version of this method could allow the user to specify this timeout.)
    */
    private Socket openSocket(String server, int port) throws Exception {
        Socket privateSocket = null;
        
        // create a socket with a timeout
        try {
            InetAddress inteAddress = InetAddress.getByName(server);
            SocketAddress socketAddress = new InetSocketAddress(inteAddress, port);

            // create a socket
            privateSocket = new Socket();

            // this method will block no more than timeout ms.
            int timeoutInMs = 10*1000;   // 10 seconds
            privateSocket.connect(socketAddress, timeoutInMs);

            
        }
        catch (SocketTimeoutException ste) {
            System.err.println("Timed out waiting for the socket.");
            ste.printStackTrace();
            //throw ste;
        }

        return privateSocket;
    }

    public void closeSocket() throws IOException {
        closeStreams();
        socket.close();
    }
}
