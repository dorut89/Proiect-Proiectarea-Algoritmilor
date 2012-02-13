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

	public static void main(String[] args) throws IOException
	{
		
		int n;
		String aux [] = new String [32];
		int linie,coloana;
		Data.setACC(10);
		Data.setBRK(10);
		Data.setMaxSPD(100);
		Data.setgetSteeringCar(0.5);
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
			//comm.writeString("void");
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
					case H_MAP_DIM:  //2
					{
						
						Data.setMapWidth(comm.readInt());
						Data.setMapHeigh(comm.readInt());
						Data.Map = new int[Data.getMapHeigh()][Data.getMapWidth()];
						
						int nr_data_recieve = Data.getMapHeigh()*Data.getMapWidth()/32 + 1;
						for( int i = 0; i < nr_data_recieve; i++){
							n = comm.readInt();
							for(int j = 0 ; j < 32; j++){
								if ((n & (1 << j)) == 0)
									aux[31-j] = "0";
								else 
									aux[31-j] = "1";
							}
							for(int k = 0; k < 32; k++){
								linie = (32*i+k)/Data.getMapWidth();
								coloana = (32*i+k) - (linie * Data.getMapWidth());
								if(Data.getMapHeigh() > linie && Data.getMapWidth() > coloana)
									Data.Map[linie][coloana] = Integer.parseInt(aux[k]);
							
						}}
						
						System.out.println("Received map dimentions packet");
					}; break;
					
					case H_INITIAL_INFO: //3
					{
						
						Data.setStartPointX(comm.readInt());
						Data.setStartPointY(comm.readInt());
						Data.setWidth_meters(comm.readInt());
						Data.setHeight_meters(comm.readInt());
						Data.setDirection(comm.readInt());
						Data.setNumberOfLaps(comm.readInt());
						Data.setMaximumLapTime(comm.readInt());
						Data.setCarAngle(comm.readDouble());
						
						//trimite-m la server car configuration
						comm.writeInt(H_CAR_CONFIG);
						comm.writeInt(Data.getACC());
						comm.writeInt(Data.getBRK());
						comm.writeInt(Data.getMaxSPD());
						comm.writeDouble(Data.getSteeringCar());
						
						System.out.println("Received initial information packet");
					}; break;
					
					case H_CAR_CONFIRM: //4
					{
						
						Data.setACC(comm.readInt());
						Data.setBRK(comm.readInt());
						Data.setMaxSPD(comm.readInt());
						Data.setgetSteeringCar(comm.readDouble());
						System.out.println("Received car confirm packet");
						
						//System.out.println(Data.getACC()+" "+Data.getBRK()+" "+Data.getSteeringCar());
						
						//pornim masina :))
						Engine.StartPosition(100, 0, Data.getCarAngle());
						
						comm.writeInt(H_DRIVE_INFO);
						comm.writeDouble(Data.getAccelerationPercentage());
						comm.writeDouble(Data.getBrakePercentage());
						comm.writeDouble(Data.getWantedAngle());
						comm.writeInt(0); //drop queue
						
						System.out.println("Send driving info1");
					}; break;
					
					case H_POS_CONFIRM: //6
					{
						
						Data.setCurrent_X_Meters(comm.readDouble());
						Data.setCurrent_Y_Meters(comm.readDouble());
						Data.setCurrentSpeed(comm.readDouble());
						Data.setCurrentAngleInRadians(comm.readDouble());
						Data.setCurrentDirection(comm.readInt());
						System.out.println("Received position confirmation packet");
						//System.out.println(Data.getCurrent_X_Meters()+"-"+Data.getCurrent_Y_Meters()+"pozitia masinii");
						//System.out.println(Data.getCurrentSpeed()+"-"+Data.getCurrentDirection()+"-"+Engine.FromRadiusToAngle(Data.getCurrentAngleInRadians()));
						
						Engine.evalPosition();
						
						comm.writeInt(H_DRIVE_INFO);
						comm.writeDouble(Data.getAccelerationPercentage());
						comm.writeDouble(Data.getBrakePercentage());
						comm.writeDouble(Data.getWantedAngle());
						comm.writeInt(0); //drop queue
						
						//System.out.println("Send driving info2");
						
					}; break;
					
					case H_END_RACE:
					{
						System.out.println("Received end race packet");
					}; break;
					
					default:
					{
						System.out.println("Unknown packet"); 
						//System.out.println(header);
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
