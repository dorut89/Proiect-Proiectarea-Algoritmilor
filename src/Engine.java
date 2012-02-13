
public class Engine {
	
	public static double FromAngleToRadius (double angle){
		return (angle * Math.PI)/180;
	}
	public static double FromRadiusToAngle (double radius){
		return (radius*180)/Math.PI;
	}
	
	public static void evalPosition(){
		
		//daca viteza tinde sa treaca de MAX_SPEED
		if(Data.getCurrentSpeed() >= Data.getMaxSPD()){
			Data.setAccelerationPercentage(0);
			Data.setBrakePercentage(100);
			Data.setWantedAngle(Data.getCurrentAngleInRadians());
		}
		
		//Daca direction is -1
		if(Data.getCurrentDirection() == -1 ){
			Data.setAccelerationPercentage(0);
			Data.setBrakePercentage(100);
			Data.setWantedAngle(Engine.FromAngleToRadius(45)+ Data.getCurrentAngleInRadians());
		}
		//if speed is 0
		if (Data.getCurrentSpeed() == 0){
			Data.setAccelerationPercentage(15);
			Data.setBrakePercentage(0);
			Data.setWantedAngle(Engine.FromAngleToRadius(45)+ Data.getCurrentAngleInRadians());
			
		}
		
	}
	public static void StartPosition(double acc, double brk, double wanted_angle){
		Data.setAccelerationPercentage(acc);
		Data.setBrakePercentage(brk);
		Data.setWantedAngle(wanted_angle);
	}
}
