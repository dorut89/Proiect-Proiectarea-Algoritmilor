import java.lang.*;
import java.io.*;
import java.net.*;

class NetworkCommunication {
	private Socket socket;
	private DataInputStream in;
	private DataOutputStream out;

	public NetworkCommunication(Socket socket) {
		this.socket = socket;
	}

	public void initStreams() throws IOException {
		in = new DataInputStream(socket.getInputStream());
		out = new DataOutputStream(socket.getOutputStream());
	}
	
	public DataInputStream getInpuStream() {
		return in;
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

}

public class AI
{
	static Socket socket = null;
	static NetworkCommunication comm = null;
	
	final static int H_TEAM_NAME = 1;
	final static int H_MAP_DIM = 2;
	final static int H_INITIAL_INFO = 3;
	final static int H_CAR_CONFIG = 4;
	final static int H_CAR_CONFIRM = 4;
	final static int H_DRIVE_INFO = 5;
	final static int H_POS_CONFIRM = 6;
	final static int H_END_RACE = 7;

	AI()
	{
	}

	public static void main(String[] args)
	{
		try
		{
			// create socket
			socket = new Socket("127.0.0.1", 6666);
			// we attempt to bypass nagle's algorithm
			socket.setTcpNoDelay(true);
			
			//initialize our communication class
			comm = new NetworkCommunication(socket);
			comm.initStreams();
			
			// send initial packet, aka the team's name
			comm.writeInt(H_TEAM_NAME);
			comm.writeInt(1);
			comm.writeString(args[0]);
		}
		catch (UnknownHostException e)
		{
			System.out.println("could not connect to server");
			System.exit(1);
		}
		catch  (IOException e)
		{
			System.out.println("No I/O");
			System.exit(1);
		}
		System.out.println("Sent team name....entering main loop");

		while (true)
		{
			try
			{
				int header = comm.readInt();
				switch (header)
				{
					case H_MAP_DIM:
					{
						System.out.println("Received map dimentions packet");
					}; break;
					
					case H_INITIAL_INFO:
					{
						System.out.println("Received initial information packet");
					}; break;
					
					case H_CAR_CONFIRM:
					{
						System.out.println("Received car confirm packet");
					}; break;
					
					case H_POS_CONFIRM:
					{
						System.out.println("Received position confirmation packet");
					}; break;
					
					case H_END_RACE:
					{
						System.out.println("Received end race packet");
					}; break;
					
					default:
					{
						System.out.println("Unknown packet");
					}
				}
			}
			catch  (IOException e)
			{
				System.out.println("No I/O");
				System.exit(1);
			}
		}
		
	}
}
