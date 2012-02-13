/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package hotpursuit;

import java.net.SocketException;
import java.util.Calendar;

/**
 *
 * @author Andrei
 */
public class ServerConnection implements Runnable {
    private aiView view;
    //private ServerSocket ssocket;
    private ClientSocket clientSocket;
    private final int INT_SIZE = 32;
    
    public ServerConnection(aiView mainView) throws Exception {
        view = mainView;
    }

    public void run() {
        int header;
        view.outputLog("Connecting to " + ai.server + ":" + ai.port + ", team name = " + ai.team);
        try {
            clientSocket = new ClientSocket(ai.server, ai.port);

            clientSocket.writeInt(1);
            clientSocket.writeInt(ai.team.length());
            clientSocket.writeString(ai.team);

            view.outputLog("Waiting to receive map");
            header = clientSocket.readInt(); // should be 2
            int width = clientSocket.readInt();
            int height = clientSocket.readInt();

            aiView.e.setDimensions(width, height);

            //clientSocket.closeSocket();

            int chunks = (int)Math.ceil(width * (double)height / INT_SIZE);

            view.outputLog("Received w=" + width +" h=" + height + ", expecting " + chunks + " chunks");
            int cWidth = -1;
            int cHeight = 0;
            
            for (int i=0; i<chunks; i++) {
                int chunk = clientSocket.readInt();
                int reverseChunk = 0;

                // reverse bits, ffs >:/
                for (int j = 0; j < INT_SIZE; j++) {
                    reverseChunk = reverseChunk * 2 + (chunk & 1);
                    chunk = chunk >> 1;
                }

                for (int j = 0; j < INT_SIZE; j++) {
                    cWidth++;
                    if (cWidth == width) {
                        cWidth = 0;
                        cHeight++;
                    }

                    if ((cHeight < height) && (cWidth < width)) aiView.e.setPixel(cWidth , cHeight, reverseChunk & 1);
                    reverseChunk = reverseChunk >> 1;
                }
            }

            view.outputLog("Map loaded");

            Point startPosition = new Point();

            header = clientSocket.readInt(); // should be 3
            startPosition.x = clientSocket.readInt();
            startPosition.y = clientSocket.readInt();
            int widthM = clientSocket.readInt();
            int heightM = clientSocket.readInt();
            int direction = clientSocket.readInt(); // 1 clockwise, 0 anti-clockwise
            int laps = clientSocket.readInt();
            int lapTime = clientSocket.readInt(); // miliseconds
            double angle = clientSocket.readDouble();

            aiView.e.setInitialInfo(startPosition, widthM, heightM, direction, laps, lapTime, angle);

            view.outputLog("Starting position: " + startPosition + " direction = " + direction);
            
            Calendar cal;
            cal = Calendar.getInstance();
            aiView.e.startTime = cal.getTimeInMillis();

            Limits defaultLimits = new Limits();
            defaultLimits.acc = 10;
            defaultLimits.brk = 10;
            defaultLimits.spd = 100;
            defaultLimits.str = 0.5;
            aiView.e.setLimits(defaultLimits);

            aiView.e.endSimulation = false;

            double bestSimulationTime = 100000;

            aiView.e.runEngine();

            // start simulating

            //if (!ai.team.equals("Test"))  {
                // try with the default values first
                //System.out.println("[" + cal.getTimeInMillis() + "] Starting simulation with limits = " + defaultLimits);
                bestSimulationTime = aiView.e.simulateRace(aiView.e.getCurrentState(), defaultLimits, bestSimulationTime);
                //System.out.println("[" + cal.getTimeInMillis() + "] Ended simulation with time = " + bestSimulationTime);

                do {
                    Limits randomLimits = new Limits();
                    randomLimits.acc = 7 + (int)Math.round(Math.random() * 13);
                    randomLimits.brk = 20 - randomLimits.acc;
                    randomLimits.spd = 50 + (int)Math.round(Math.random() * 50);
                    randomLimits.str = (double)(400 - 10 * randomLimits.acc - 10 * randomLimits.brk - randomLimits.spd) / 200;

                    cal = Calendar.getInstance();
                    if (cal.getTimeInMillis() - aiView.e.startTime >= ai.simulationLimit) {
                        aiView.e.endSimulation = true;
                        break;
                    }

                    //System.out.println("[" + cal.getTimeInMillis() + "] Starting simulation with limits = " + randomLimits);
                    double simulationTime = aiView.e.simulateRace(aiView.e.getCurrentState(), randomLimits, bestSimulationTime);
                    //System.out.println("[" + cal.getTimeInMillis() + "] Ended simulation with time = " + simulationTime);

                    if (simulationTime < bestSimulationTime) {
                        bestSimulationTime = simulationTime;
                        aiView.e.setLimits(randomLimits);
                    }
                } while (!aiView.e.endSimulation);

                Limits limits = aiView.e.getLimits();
                view.outputLog("Best limits = " + limits + ", time should be = " + bestSimulationTime);
                clientSocket.writeInt(4);
                clientSocket.writeInt(limits.acc);
                clientSocket.writeInt(limits.brk);
                clientSocket.writeInt(limits.spd);
                clientSocket.writeDouble(limits.str);
            /*
            } else {
                Limits limits = new Limits();
                limits.acc = 10;
                limits.brk = 5;
                limits.spd = 100;
                limits.str = 0.75;

                clientSocket.writeInt(4);
                clientSocket.writeInt(limits.acc);
                clientSocket.writeInt(limits.brk);
                clientSocket.writeInt(limits.spd);
                clientSocket.writeDouble(limits.str);
            }
            */
                
            Limits serverLimits = new Limits();
            header = clientSocket.readInt(); // should be 4
            serverLimits.acc = clientSocket.readInt();
            serverLimits.brk = clientSocket.readInt();
            serverLimits.spd = clientSocket.readInt();
            serverLimits.str = clientSocket.readDouble();

            //view.outputLog("Received ["+header+"]: " + serverLimits.toString());

            boolean raceOver = false;

            State currentState = aiView.e.getCurrentState();

            view.outputLog("Starting race");
            while (!raceOver) {
                //view.outputLog("POSITION: " + currentState.toString());
                Command cmd = aiView.e.getNextCommand(currentState, serverLimits);

                //view.outputLog("COMMAND: " + cmd.toString());

                try {
                    clientSocket.writeInt(5);
                    clientSocket.writeDouble(cmd.acc);
                    clientSocket.writeDouble(cmd.dec);
                    clientSocket.writeDouble(cmd.str);
                    clientSocket.writeInt(0);
                } catch (SocketException e) {
                    view.outputLog("Disconnected, probably disqualified :(");
                    raceOver = true;
                    break;
                }

                header = clientSocket.readInt();

                //view.outputLog("Received ["+header+"]");

                if (header == 6) { // position confirmation
                    State newState = new State();
                    newState.position.x = clientSocket.readDouble();
                    newState.position.y = heightM - clientSocket.readDouble();
                    newState.speed = clientSocket.readDouble();
                    newState.angle = clientSocket.readDouble();

                    //view.outputLog("NEW POSITION: " + newState.toString());
                    int currentDirection = clientSocket.readInt();
                    
                    if (currentDirection == -1) {
                        view.outputLog("Wrong way !!!");
                        if (!aiView.e.wrongWay) {
                            aiView.e.trackDirectionBool = !aiView.e.trackDirectionBool;
                        }
                        aiView.e.wrongWay = true;
                    }

                    currentState = new State(newState);
                } else
                if (header == 7) { // race over
                    view.outputLog("End of race!");
                    raceOver = true;
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }

    }
}
