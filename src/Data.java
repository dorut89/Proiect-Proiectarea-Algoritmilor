
public class Data {
	
	// map values(dupa ce citim latimea*lungimea abia atunci putem sa instantiem Map)
	private static int MapWidth;
	private static int MapHeigh;
	public static int Map[][];
	
	//initial info
	private static int start_point_x;
	private static int start_point_y;
	private static int width_in_meters;
	private static int height_in_meters;
	private static int direction;  //1 for clockwise, 0 for counter-clockwise
	private static int n_laps;
	private static int maximum_lap_time;
	private static double car_angle;  // value in radians in [0:2*PI].
	
	//car configuration
	private static int ACC;
	private static int BRK;
	private static int MaxSPD;
	private static double STR;
	
	//Send driving info
	private static double ACC_per;
	private static double BRK_per;
	private static double wanted_angle;
	@SuppressWarnings("unused")
	private static int drop_queue = 0;
	
	//Receive position confirmation

	private static double current_X_in_meters;
	private static double current_Y_in_meters;
	private static double current_speed;
	private static double current_angle_in_radians;
	private static int current_direction; // (1 integer)
	
	public static int getCurrentDirection()
	{
		return current_direction;
	}
	public static void setCurrentDirection(int x)
	{
		current_direction = x;
	}
	public static double getCurrentAngleInRadians()
	{
		return current_angle_in_radians;
	}
	public static void setCurrentAngleInRadians(double x)
	{
		current_angle_in_radians = x;
	}
	public static double getCurrentSpeed()
	{
		return current_speed;
	}
	public static void setCurrentSpeed(double x)
	{
		current_speed = x;
	}
	public static double getCurrent_Y_Meters()
	{
		return current_Y_in_meters;
	}
	public static void setCurrent_Y_Meters(double x)
	{
		current_Y_in_meters = x;
	}
	public static double getCurrent_X_Meters()
	{
		return current_X_in_meters;
	}
	public static void setCurrent_X_Meters(double x)
	{
		current_X_in_meters = x;
	}
	public static double getWantedAngle()
	{
		return wanted_angle;
	}
	public static void setWantedAngle(double x)
	{
		wanted_angle = x;
	}
	public static double getBrakePercentage()
	{
		return BRK_per;
	}
	public static void setBrakePercentage(double x)
	{
		BRK_per = x;
	}
	public static double getAccelerationPercentage()
	{
		return ACC_per;
	}
	public static void setAccelerationPercentage(double x)
	{
		ACC_per = x;
	}
	public static int getMaxSPD()
	{
		return MaxSPD;
	}
	public static void setMaxSPD(int x)
	{
		MaxSPD = x;
	}
	public static int getACC()
	{
		return ACC;
	}
	public static void setACC(int x)
	{
		ACC = x;
	}
	public static int getBRK()
	{
		return BRK;
	}
	public static void setBRK(int x)
	{
		BRK = x;
	}
	public static double getSteeringCar()
	{
		return STR;
	}
	public static void setgetSteeringCar(double x)
	{
		STR = x;
	}
	public static double getCarAngle()
	{
		return car_angle;
	}
	public static void setCarAngle(double x)
	{
		car_angle = x;
	}
	public static int getMaximumLapTime()
	{
		return maximum_lap_time;
	}
	public static void setMaximumLapTime(int x)
	{
		maximum_lap_time = x;
	}
	public static int getNumberOfLaps()
	{
		return n_laps;
	}
	public static void setNumberOfLaps(int x)
	{
		n_laps = x;
	}
	public static int getDirection()
	{
		return direction;
	}
	public static void setDirection(int x)
	{
		direction = x;
	}
	public static int getHeight_meters()
	{
		return height_in_meters;
	}
	public static void setHeight_meters(int x)
	{
		height_in_meters = x;
	}
	public static int getWidth_meters()
	{
		return width_in_meters;
	}
	public static void setWidth_meters(int x)
	{
		width_in_meters = x;
	}
	public static int getStartPointY()
	{
		return start_point_y;
	}
	public static void setStartPointY(int y)
	{
		start_point_y = y;
	}
	public static int getStartPointX()
	{
		return start_point_x;
	}
	public static void setStartPointX(int x)
	{
		start_point_x = x;
	}
	public static int getMapWidth ()
	{
		return MapWidth;
	}
	public static void setMapWidth (int x)
	{
		MapWidth = x;
	}
	public static int getMapHeigh ()
	{
		return MapHeigh;
	}
	public static void setMapHeigh (int x)
	{
		MapHeigh = x;
	}
}
