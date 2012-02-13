/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package hotpursuit;

import java.awt.Color;
import java.awt.Graphics;
import java.sql.Time;
import java.util.Calendar;
import java.util.LinkedList;
import java.util.List;
import java.util.Random;
import javax.swing.JLabel;
import javax.swing.JPanel;

/**
 *
 * @author Andrei
 */
public class Engine {
    private TrackColor pixels[][];
    private double distance[][];
    private Point distance_base[][];
    private int width;
    private int height;
    private List<Point> insideEdgePoints;
    private List<Point> outsideEdgePoints;
    private List<Point> waypoints;
    private List<Point> orderedWaypoints;
    private double maxDistance;
    private Segment[][] trackSegments;
    private int drawOffset = 50;
    private Segment finishLine;
    private Limits limits;

    public long startTime;
    public boolean endSimulation;

    private int realWidth;
    private int realHeight;

    private Limits bestLimits;

    private JLabel speed_label;
    private JLabel acc_label;
    private JLabel angle_label;
    private JLabel position_label;
    private JPanel panel;
    private aiView view;

    public boolean wrongWay = false;

    private State initialState;

    private int trackDirection;
    public boolean trackDirectionBool;

    private class Segment {
        private Point a, b;

        public Segment(Point a, Point b) {
            this.a = a;
            this.b = b;
        }
    }

    public RealPoint pointToRealPoint(Point p) {
        return new RealPoint(((double)p.x / (double)width) * realWidth, ((double)p.y / (double)height) * realHeight);
    }

    public Point realPointToPoint(RealPoint rp) {
        return new Point((int)Math.round((double)width * rp.x / realWidth), (int)Math.round((double)height * rp.y / realHeight));
    }

    // Bresenham's Line drawing algorithm
    public LinkedList<Point> Bresenham(Point op1, Point op2) {
        LinkedList<Point> result = new LinkedList<Point>();

        Point p1 = new Point(op1.x, op1.y);
        Point p2 = new Point(op2.x, op2.y);

        boolean steep = Math.abs(p2.y - p1.y) > Math.abs(p2.x - p1.x);

        if (steep) {
            // swap
            int tmp=p1.x;
            p1.x=p1.y;
            p1.y=tmp;

            tmp=p2.x;
            p2.x=p2.y;
            p2.y=tmp;
        }

        if (p1.x > p2.x){
            // swap
            int tmp=p1.x;
            p1.x=p2.x;
            p2.x=tmp;
            tmp=p1.y;
            p1.y=p2.y;
            p2.y=tmp;
        }

        int deltax = p2.x - p1.x;
        int deltay = Math.abs(p2.y - p1.y);
        int error = 0;
        int ystep;
        int y = p1.y;
        
        if (p1.y<p2.y) ystep = 1; else ystep = -1;

        for (int x=p1.x;x<=p2.x;x++) {
            if (steep) result.add(new Point(y,x)); else result.add(new Point(x,y));
            error = error + deltay;
            if (2*error >= deltax) {
                y = y + ystep;
                error = error - deltax;
            }
        }

        if (result.get(0).equals(op2)) {
            LinkedList<Point> reverseResult = new LinkedList<Point>();
            for (int i=0; i<result.size(); i++) {
                reverseResult.add(result.get(result.size()-i-1));
            }
            return reverseResult;
        } else return result;
    }


    private enum TrackColor {
        White,
        Inside,
        Outside,
        Track,
        InsideEdge,
        OutsideEdge,
        Waypoint
    }

    private double cart_distance(int x1, int y1, int x2, int y2) {
        return Math.hypot(x1-x2, y1-y2);
    }

    private Point segment_middle(Point p1, Point p2) {
        return new Point((int)Math.round((p1.x + p2.x) / 2), (int)Math.round((p1.y + p2.y) / 2));
    }

    public static boolean inBounds(Point p, int width, int height) {
        return (p.x >= 0) && (p.y >= 0) && (p.x < width) && (p.y < height);
    }
    
    /** Does the point b lie to the left of an infinite line from point a to point c ? */
    public static boolean isLeft(Point a, Point b, Point c) {
        double det = a.x*(b.y-c.y) - a.y*(b.x-c.x) + (b.x*c.y-c.x*b.y);
        return det < 0;
    }

    public static boolean segmentsIntersect(Segment s1, Segment s2) {
        return (isLeft(s1.a, s2.a, s1.b) ^ isLeft(s1.a, s2.b, s1.b)) && (isLeft(s2.a, s1.a, s2.b) ^ isLeft(s2.a, s1.b, s2.b));
    }

    public boolean insideTrack(Point p) {
        return insideTrack(p, false);
    }

    public boolean insideTrack(Point p, boolean strict) {
        if ((p.x <=0 ) || (p.y <= 0) || (p.x >= width) || (p.y >= height)) return false;

        return !((pixels[p.x][p.y] == TrackColor.Inside) || (pixels[p.x][p.y] == TrackColor.Outside) || ((strict == false) && ((pixels[p.x][p.y] == TrackColor.InsideEdge) || (pixels[p.x][p.y] == TrackColor.OutsideEdge))));
    }

    public boolean isVisible(Point from, Point to) {
        LinkedList<Point> pts = Bresenham(from, to);

        //System.out.println("checking isVisible from = " + from + " to = " + to);
        for (int i=0; i<pts.size(); i++) {
            Point p = pts.get(i);
            if (!insideTrack(p)) return false;
        }

        return true;
    }

    public void setInitialInfo(Point startPosition, int serverRealWidth, int serverRealHeight, int direction, int laps, int lapTime, double angle) {
        realWidth = serverRealWidth;
        realHeight = serverRealHeight;
        initialState = new State();
        initialState.position = pointToRealPoint(startPosition);
        initialState.speed = 0;
        initialState.angle = angle;
        
        trackDirection = direction;
    }

    public Engine(JPanel panel, aiView view) {
        /*
        this.speed_label = l1;
        this.acc_label = l2;
        this.angle_label = l3;
        this.position_label = l4;
         * 
         */
        this.panel = panel;
        this.view = view;
    }

    private void outputLog(String s) {
        view.outputLog(s);
    }

    public void setDimensions(int serverWidth, int serverHeight) {
        width = serverWidth;
        height = serverHeight;
        pixels = new TrackColor[width][height];
    }

    public void init(String src, aiView mainView) {
/*
        BufferedImage img = null;

        try {
            img = ImageIO.read(new File(src));
        } catch (IOException ex) {
            ex.printStackTrace();
        }

        width = img.getWidth();
        height = img.getHeight();
        pixels = new TrackColor[width][height];
        
        for (int i=0; i<width; i++)
            for (int j=0; j<height; j++) {
                int c = img.getRGB(i, j);
                if (c==-1) {
                    pixels[i][j] = TrackColor.White;
                } else {
                    pixels[i][j] = TrackColor.Track;
                }
            }
        
*/
    }

    public static double angle2p(RealPoint p1, RealPoint p2) {
        RealPoint translated = new RealPoint(p2.x - p1.x, - p2.y + p1.y);
        double angle = Math.atan2(translated.y, translated.x);
        if (angle < 0) angle = 2 * Math.PI + angle;

        return angle;
    }

    public void setPixel(int x, int y, int color) {
        //System.out.println("Setting (" + x + "," + y + ") = " + color);

        if (color==0) {
            pixels[x][y] = TrackColor.White;
        } else {
            pixels[x][y] = TrackColor.Track;
        }
    }

    public double deltaAngle(double angle1, double angle2) {
        return min3(Math.abs(angle2 - angle1), Math.abs(angle2 - angle1 - 2 * Math.PI), Math.abs(angle2 - angle1 + 2 * Math.PI));
    }

    private double min2(double a, double b) {
        if (a<b) return a; else return b;
    }

    public List<Point> reverseList(List<Point> list) {
        List<Point> reversed = new LinkedList<Point>();
        for (int i=list.size()-1; i>=0; i--) {
            reversed.add(list.get(i));
        }
        return reversed;
    }

    private double min3(double a, double b, double c) {
        return min2(a, min2(b, c));
    }

    public void runEngine() {
        // Fill inside and outside and make lists of edge points
        
        outsideEdgePoints = new LinkedList<Point>();
        System.out.println("Filled " + fill(0, 0, TrackColor.Outside) + " on the outside");
        System.out.println("Created " + outsideEdgePoints.size() + " outside edge points");

        Random random = new Random();
        int x, y;
        do {
            x = random.nextInt(width);
            y = random.nextInt(height);
        } while (pixels[x][y] != TrackColor.White);

        insideEdgePoints = new LinkedList<Point>();
        System.out.println("Filled " + fill(x, y, TrackColor.Inside) + " on the inside");
        System.out.println("Created " + insideEdgePoints.size() + " inside edge points");

        // Breadth-first search on the inside to create distances matrix

        waypoints = new LinkedList<Point>();
        trackSegments = new Segment[width][height];
        
        Point p, wp;

        boolean insideOut = true;
        boolean outsideIn = true;

        distance_base = null;

        if (outsideIn) {
            distance_base = findPairs(insideEdgePoints, TrackColor.OutsideEdge);
            for (int i=0; i< outsideEdgePoints.size(); i++) {
                p = outsideEdgePoints.get(i);
                //System.out.println("Outside point " + p + " with base = " + distance_base[p.x][p.y]);
                if (distance_base[p.x][p.y]!=null) {
                    wp = segment_middle(p, distance_base[p.x][p.y]);

                    trackSegments[wp.x][wp.y] = new Segment(distance_base[p.x][p.y], p);

                    maxDistance = Math.max(maxDistance, cart_distance(p.x, p.y, distance_base[p.x][p.y].x, distance_base[p.x][p.y].y));

                    waypoints.add(wp);
                }
            }
        }

        distance_base = null;

        if (insideOut) {
            distance_base = findPairs(outsideEdgePoints, TrackColor.InsideEdge);

            //System.out.println(distance_base);
            
            for (int i=0; i< insideEdgePoints.size(); i++) {
                p = insideEdgePoints.get(i);
                //System.out.println("Inside point " + p + " with base = " + distance_base[p.x][p.y]);
                if (distance_base[p.x][p.y]!=null) {
                    wp = segment_middle(p, distance_base[p.x][p.y]);

                    trackSegments[wp.x][wp.y] = new Segment(p, distance_base[p.x][p.y]);

                    maxDistance = Math.max(maxDistance, cart_distance(p.x, p.y, distance_base[p.x][p.y].x, distance_base[p.x][p.y].y));

                    waypoints.add(wp);
                }
            }
        }

        for (int i=0; i< waypoints.size(); i++) {
            wp = waypoints.get(i);
            pixels[wp.x][wp.y] = TrackColor.Waypoint;
        }
        
        System.out.println("Created " + waypoints.size() + " waypoints. Max distance = " + maxDistance);

        // determine track direction

       


        /*
        double distance_min = 10000;
        double angle_min = 10000;
        boolean _direction = true;
        Point initialPoint = realPointToPoint(initialState.position);

        for (int i=0; i<waypoints.size(); i++) {
            Point _wp = waypoints.get(i);
            RealPoint _rwp = pointToRealPoint(_wp);

            double angle = angle2p(initialState.position, _rwp);
            if (Math.abs(angle - initialState.angle) < Math.PI) {
                double _distance = cart_distance(_wp.x, _wp.y, initialPoint.x, initialPoint.y);
                if (isVisible(_wp, initialPoint) && (angle < angle_min)) {
                    if ((_distance < distance_min) && (_distance > 3)) {
                        distance_min = _distance;
                        angle_min = angle;
                        Segment seg = trackSegments[_wp.x][_wp.y];
                        _direction = isLeft(initialPoint, seg.a, _wp);

                        System.out.println("Found direction = " + _direction);
                        break;
                    }
                }
            }

        }

        trackDirectionBool = _direction;
        */
        
        // starting point
        Point startPoint = realPointToPoint(initialState.position);
        int closestWaypointIndex = getClosestWaypointIndex(waypoints, startPoint);
        Point cPoint = waypoints.get(closestWaypointIndex);



        

        finishLine = trackSegments[cPoint.x][cPoint.y];

        //waypoints.remove(0);

        orderedWaypoints = new LinkedList<Point>();
        
        double minDistance;
        Point minPoint;

        //DrawTrack();

        Graphics g = panel.getGraphics();

        //g.setColor(Color.white);
        //g.drawLine(finishLine.a.x, finishLine.a.y + drawOffset, finishLine.b.x, finishLine.b.y + drawOffset);

        //g.setColor(Color.RED);

        int radius = 2*(int)Math.ceil(maxDistance);

        int[][] directionVector = {
            {1, 0, 0, 1},
            {0, 1, 1, 0},
            {1, 0, 0, -1},
            {0, 1, -1, 0},
        };

        do {
            orderedWaypoints.add(cPoint);
            //g.drawRect(cPoint.x, cPoint.y + drawOffset, 1, 1);

            //System.out.println("Adding " + cPoint + " to orderedWaypoints");

            minDistance = 1000;
            minPoint = null;
//            minIndex = 0;
            boolean stop = false;

            for (int cRadius = 1; cRadius <= radius; cRadius++) {
                for (y = -cRadius; y<=cRadius; y++) {
                    for (int d = 0; d < 4; d++) {

                        Point nextPoint = new Point(cPoint.x + y * directionVector[d][0] + cRadius * directionVector[d][2], cPoint.y + y * directionVector[d][1] + cRadius * directionVector[d][3]);
                        
                        if (!inBounds(nextPoint, width, height)) continue;
                        if (pixels[nextPoint.x][nextPoint.y] != TrackColor.Waypoint) continue;

                        //Point edgePoint = distance_base[nextPoint.x][nextPoint.y];
                        Segment seg = trackSegments[nextPoint.x][nextPoint.y];

                        // TODO: check this clockwise thing
                        boolean left = isLeft(cPoint, seg.a, nextPoint);
                        //System.out.println("trackDirection = " + trackDirection + " isLeft = " + left);
                        //if (trackDirectionBool == left) {
                        if (false == left) {
                            double distance = cart_distance(cPoint.x, cPoint.y, nextPoint.x, nextPoint.y);
                            if ((distance < minDistance) && (distance > 0)) {
                                minDistance = cart_distance(cPoint.x, cPoint.y, nextPoint.x, nextPoint.y);
                                minPoint = nextPoint;
                                stop = true;
                                break;
                            }
                        }
                    }
                    if (stop) break;
                }
                if (stop) break;
            }

            if ((minPoint != null) && (orderedWaypoints.size()>1)) {
                //g.drawLine(cPoint.x, cPoint.y + drawOffset, minPoint.x, minPoint.y + drawOffset);
                if (segmentsIntersect(finishLine, new Segment(cPoint, minPoint))) {
                    System.out.println("Crossed the finish line!");
                    break;                    
                }
            }

            cPoint = minPoint;
            if (cPoint != null) {
                //waypoints.remove(cPoint);
                try {
                    // TODO: comment this out, lol
                    //Thread.sleep(6);
                } catch (Exception e) {
                    
                }
                
                pixels[cPoint.x][cPoint.y] = TrackColor.Track;
            }
        } while (cPoint != null);

        // determine direction, 2

        closestWaypointIndex = getClosestWaypointIndex(orderedWaypoints, startPoint);

        int leftIndex = closestWaypointIndex;
        int rightIndex = closestWaypointIndex;

        for (int i = 1; i <= 5; i++) {
            leftIndex++;
            rightIndex--;

            if (leftIndex == orderedWaypoints.size()) leftIndex = 0;
            if (rightIndex == -1) rightIndex = orderedWaypoints.size() - 1;
        }

        double angle1 = angle2p(initialState.position, pointToRealPoint(orderedWaypoints.get(leftIndex)));
        double angle2 = angle2p(initialState.position, pointToRealPoint(orderedWaypoints.get(rightIndex)));

        double delta1 = deltaAngle(initialState.angle, angle1);
        double delta2 = deltaAngle(initialState.angle, angle2);

        System.out.println("Angles: " + delta1 + " " + delta2);

        if (delta1 > delta2) {
            orderedWaypoints = reverseList(orderedWaypoints);            
        }



        for (int i = 0; i < insideEdgePoints.size(); i++) {
            Point p2 = insideEdgePoints.get(i);
            if ((p2.x > 0) && (pixels[p2.x-1][p2.y] == TrackColor.Track)) pixels[p2.x-1][p2.y] = TrackColor.InsideEdge;
            if ((p2.y > 0) && (pixels[p2.x][p2.y-1] == TrackColor.Track)) pixels[p2.x][p2.y-1] = TrackColor.InsideEdge;
            if ((p2.x < width-1)  && (pixels[p2.x+1][p2.y] == TrackColor.Track)) pixels[p2.x+1][p2.y] = TrackColor.InsideEdge;
            if ((p2.y < height-1) && (pixels[p2.x][p2.y+1] == TrackColor.Track)) pixels[p2.x][p2.y+1] = TrackColor.InsideEdge;
        }

        for (int i = 0; i < outsideEdgePoints.size(); i++) {
            Point p2 = outsideEdgePoints.get(i);
            if ((p2.x > 0) && (pixels[p2.x-1][p2.y] == TrackColor.Track)) pixels[p2.x-1][p2.y] = TrackColor.OutsideEdge;
            if ((p2.y > 0) && (pixels[p2.x][p2.y-1] == TrackColor.Track)) pixels[p2.x][p2.y-1] = TrackColor.OutsideEdge;
            if ((p2.x < width-1)  && (pixels[p2.x+1][p2.y] == TrackColor.Track)) pixels[p2.x+1][p2.y] = TrackColor.OutsideEdge;
            if ((p2.y < height-1) && (pixels[p2.x][p2.y+1] == TrackColor.Track)) pixels[p2.x][p2.y+1] = TrackColor.OutsideEdge;
        }

        System.out.println("Done. Final waypoints polyline has " + orderedWaypoints.size() + " points");
    }

    public State getCurrentState() {
        return initialState;
    }

    private State predictNextState(State currentState, Command cmd, Limits limits) {
        double q = 0.001;
        double period = 0.1;
        int steps = (int)Math.round(period / q);
        double stepsDouble = Math.round(period / q);

        State intState = new State(currentState);

        //System.out.println("State = " + currentState);
        //System.out.println("Command = " + cmd);
        //System.out.println("Limits = " + limits);

        int sign;
        double d = cmd.str - currentState.angle;

        if (d > 0) {
            if (Math.abs(d) > Math.PI) {
                sign = -1;
            } else {
                sign = 1;
            }
        } else {
            if (Math.abs(d) > Math.PI) {
                sign = 1;
            } else {
                sign = -1;
            }
        }

        double acc = 0;

        if (cmd.acc > 0) acc = cmd.acc;
        if (cmd.dec > 0) acc = -cmd.dec;

        for (int i=0; i<steps; i++) {
            double distance = intState.speed * q + (0.5) * acc * q * q;

            double finalSpeed = Math.min(intState.speed + q * acc, limits.spd);

            double angle = intState.angle + limits.str * q * sign;

            if (angle < 0) angle = Math.PI * 2 + angle;
            if (angle > Math.PI * 2) angle = angle - Math.PI * 2;
            
            double deltaX = Math.cos(angle) * distance;
            double deltaY = Math.sin(angle) * distance;

            intState.position.x += deltaX;
            intState.position.y -= deltaY;
            intState.speed = finalSpeed;
            intState.angle = angle;

            //System.out.println("Intermediate [d = " + distance + "] = " + intState);
        }

        //System.out.println("Final = " + intState);

        return intState;
    }

    public double simulateRace(State initialState, Limits carLimits, double bestSimulationTime) {
        double time = 0;
        boolean raceOver = false;
        
        State currentState = new State(initialState);

        while (!raceOver) {
            Calendar cal = Calendar.getInstance();
            if (cal.getTimeInMillis() - startTime >= ai.simulationLimit) {
                aiView.e.endSimulation = true;
                return 10000;
            }

            if (time > bestSimulationTime) {
                return 10000;
            }

            //view.outputLog("[" + cal.getTimeInMillis() + "]: " + currentState.toString());
            Command cmd = getNextCommand(currentState, carLimits);
            State newState = predictNextState(currentState, cmd, carLimits);

            if ((time > 10) && (segmentsIntersect(finishLine, new Segment(realPointToPoint(currentState.position), realPointToPoint(newState.position))))) {
                raceOver = true;
            }

            currentState = new State(newState);
            time = time + 0.1;
        }

        return time;
    }

    public Command getNextCommand(State currentState, Limits l) {
        Point target = this.getTarget(realPointToPoint(currentState.position));
        RealPoint realTarget = pointToRealPoint(target);

        //Limits l = getLimits();

        //System.out.println("Target for " + currentState.position + " = " + target);

        Command cmd = this.getCommand(currentState, realTarget, l);

        double fullbreakTime = currentState.speed / (double)l.brk;

        int steps = (int)Math.ceil(fullbreakTime / 0.1);

        //System.out.println("Break time = " + fullbreakTime + ",  should look ahead " + steps + " steps");


        if (steps > 0) {
            int actualSteps = (int)Math.round(steps / 2.5);
            State futureState = new State(currentState);
            for (int i=1; i<=actualSteps; i++) {
                futureState = this.predictNextState(futureState, cmd, l);
                if (!insideTrack(realPointToPoint(futureState.position), true)) {
                    //cmd.dec = l.brk;

                    //cmd.dec = 100 / ((double)50 + ((double)(actualSteps - i + 1) / (double)actualSteps * (double)50));
                    cmd.dec = 100;
                    cmd.acc = 0;

                    //System.out.println("FULL BREAK");
                    break;
                }
            }

        }

        //System.out.println("Command: " + cmd);

        return cmd;
    }

    public Command getCommand(State currentState, RealPoint target, Limits limits) {
        Command cmd = new Command();
        //cmd.acc = limits.acc;
        cmd.acc = 100;

        RealPoint translated = new RealPoint(target.x - currentState.position.x, - target.y + currentState.position.y);
        double reverse = 0;

        cmd.str = Math.atan2(translated.y, translated.x);
        if (cmd.str < 0) cmd.str = 2 * Math.PI + cmd.str;

        //System.out.println("Angle = " + cmd.str);

        /*
        if (translated.x != 0) {
            reverse = Math.atan(Math.abs(translated.y / translated.x));
        } else {
            if (translated.y > 0) {
                reverse = Math.PI / 4;
            } else {
                reverse = Math.PI * 3 / 4;
            }
        }

        System.out.println("Angle offset = " + reverse);

        if (translated.x > 0) {
            if (translated.y > 0) {
                cmd.str = reverse;
            } else {
                cmd.str = 3 * Math.PI / 4 + reverse;
            }
        } else {
            if (translated.y > 0) {
                cmd.str = Math.PI / 4 + reverse;
            } else {
                cmd.str = Math.PI + reverse;
            }
        }

        System.out.println("STR = " + cmd.str);
        cmd.str = reverse;
*/
        //cmd.str = /*currentState.angle + */Math.PI / 5;

        return cmd;
    }

    private boolean raceOver() {
        return false;
    }

    private int getClosestWaypointIndex(List<Point> points, Point from) {
        Point p;
        double distance_min = 10000;
        int index_min = -1;

        for (int i=0; i<points.size(); i++) {
            p = points.get(i);
            if (cart_distance(from.x, from.y, p.x, p.y) < distance_min) {
                distance_min = cart_distance(from.x, from.y, p.x, p.y);
                index_min = i;
            }
        }
        
        return index_min;
    }

    private Point getTarget(Point from) {
        int index_min = getClosestWaypointIndex(orderedWaypoints, from);
        int next_index;

        //System.out.println("Closest = " + orderedWaypoints.get(index_min));

        if (index_min >= 0) {
            next_index = (index_min+1) % orderedWaypoints.size();
            

            while (this.isVisible(from, orderedWaypoints.get(next_index))) {
                //System.out.println("Looking at " + orderedWaypoints.get(next_index));
                index_min = next_index;
                next_index = (index_min+1) % orderedWaypoints.size();
            }

            //index_min = index_min - 20;
            //if (index_min < 0) index_min = orderedWaypoints.size() + index_min; // TODO: lol?

            return orderedWaypoints.get(index_min);
        } else return null;
    }

    public void setLimits(Limits l) {
        this.bestLimits = new Limits();
        this.bestLimits.acc = l.acc;
        this.bestLimits.brk = l.brk;
        this.bestLimits.spd = l.spd;
        this.bestLimits.str = l.str;
    }

    public Limits getLimits() {
        return this.bestLimits;
    }

    private Point[][] findPairs(List<Point> startPoints, TrackColor endColor) {
        LinkedList queue = new LinkedList();
        distance = new double[width][height];
        distance_base = new Point[width][height];

        for (int i=0; i<width; i++) {
            for (int j=0; j<height; j++) {
                distance[i][j] = 1000;
                distance_base[i][j] = null;
            }
            //Arrays.fill(distance[i], (double)1000.0);
            //Arrays.fill(distance_base[i], null);
        }
        
        
        for (int i=0; i< startPoints.size(); i++) {
            Point p = startPoints.get(i);
            distance[p.x][p.y] = 0;
            distance_base[p.x][p.y] = new Point(p.x, p.y);
            queue.add(p);
        }

        //System.out.println("Starting queue");

        Point p, base;
        do {
            p = (Point)queue.remove();
            base = distance_base[p.x][p.y];
            //System.out.println("Got " + p.x + ", " + p.y + " distance = " + distance[p.x][p.y] +" (" + queue.size() + ")");

            if ((p.x > 0) && ((pixels[p.x-1][p.y] == TrackColor.Track) || (pixels[p.x-1][p.y] == endColor)) && (distance[p.x-1][p.y] > cart_distance(base.x, base.y, p.x-1, p.y))) {
                queue.add(new Point(p.x-1, p.y));
                distance[p.x-1][p.y] = cart_distance(base.x, base.y, p.x-1, p.y);
                distance_base[p.x-1][p.y] = base;
            }
            if ((p.y > 0) && ((pixels[p.x][p.y-1] == TrackColor.Track) || (pixels[p.x][p.y-1] == endColor)) && (distance[p.x][p.y-1] > cart_distance(base.x, base.y, p.x, p.y-1))) {
                queue.add(new Point(p.x, p.y-1));
                distance[p.x][p.y-1] = cart_distance(base.x, base.y, p.x, p.y-1);
                distance_base[p.x][p.y-1] = base;
            }
            if ((p.x < width-1) && ((pixels[p.x+1][p.y] == TrackColor.Track) || (pixels[p.x+1][p.y] == endColor)) && (distance[p.x+1][p.y] > cart_distance(base.x, base.y, p.x+1, p.y))) {
                queue.add(new Point(p.x+1, p.y));
                distance[p.x+1][p.y] = cart_distance(base.x, base.y, p.x+1, p.y);
                distance_base[p.x+1][p.y] = base;
            }
            if ((p.y < height-1) && ((pixels[p.x][p.y+1] == TrackColor.Track) || (pixels[p.x][p.y+1] == endColor)) && (distance[p.x][p.y+1] > cart_distance(base.x, base.y, p.x, p.y+1))) {
                queue.add(new Point(p.x, p.y+1));
                distance[p.x][p.y+1] = cart_distance(base.x, base.y, p.x, p.y+1);
                distance_base[p.x][p.y+1] = base;
            }

            //System.out.println(queue.size());
        } while (queue.size()>0);

        return distance_base;
    }

    private int fill(int x, int y, TrackColor color) {
        TrackColor prev = pixels[x][y];
        pixels[x][y] = color;
        int total = 1;

        //System.out.println("at " + x + "," + y);

        TrackColor trackModifier = null;
        if (color == TrackColor.Inside) {
            trackModifier = TrackColor.InsideEdge;
        } else
        if (color == TrackColor.Outside) {
            trackModifier = TrackColor.OutsideEdge;
        }

        /*
        if ((x > 0) && (y > 0) && (pixels[x-1][y-1] == prev)) {
            total = total + fill(x-1, y-1, color);
        } else
        if ((x > 0) && (y > 0) && (pixels[x-1][y-1] == TrackColor.Track)) {
            pixels[x-1][y-1] = trackModifier;
            if (trackModifier == TrackColor.InsideEdge) insideEdgePoints.add(new Point(x-1, y-1)); else
            if (trackModifier == TrackColor.OutsideEdge) outsideEdgePoints.add(new Point(x-1, y-1));
        }

        if ((x < width-1) && (y > 0) && (pixels[x+1][y-1] == prev)) {
            total = total + fill(x+1, y-1, color);
        } else
        if ((x < width-1) && (y > 0) && (pixels[x+1][y-1] == TrackColor.Track)) {
            pixels[x+1][y-1] = trackModifier;
            if (trackModifier == TrackColor.InsideEdge) insideEdgePoints.add(new Point(x+1, y-1)); else
            if (trackModifier == TrackColor.OutsideEdge) outsideEdgePoints.add(new Point(x+1, y-1));
        }

        if ((x < width-1) && (y < height-1) && (pixels[x+1][y+1] == prev)) {
            total = total + fill(x+1, y+1, color);
        } else
        if ((x < width-1) && (y < height-1) && (pixels[x+1][y+1] == TrackColor.Track)) {
            pixels[x+1][y+1] = trackModifier;
            if (trackModifier == TrackColor.InsideEdge) insideEdgePoints.add(new Point(x+1, y+1)); else
            if (trackModifier == TrackColor.OutsideEdge) outsideEdgePoints.add(new Point(x+1, y+1));
        }

        if ((x > 0) && (y < height-1) && (pixels[x-1][y+1] == prev)) {
            total = total + fill(x-1, y+1, color);
        } else
        if ((x > 0) && (y < height-1) && (pixels[x-1][y+1] == TrackColor.Track)) {
            pixels[x-1][y+1] = trackModifier;
            if (trackModifier == TrackColor.InsideEdge) insideEdgePoints.add(new Point(x-1, y+1)); else
            if (trackModifier == TrackColor.OutsideEdge) outsideEdgePoints.add(new Point(x-1, y+1));
        }
        */


        if ((x > 0) && (pixels[x-1][y] == prev)) {
            total = total + fill(x-1, y, color);
        } else
        if ((x > 0) && (pixels[x-1][y] == TrackColor.Track)) {
            pixels[x-1][y] = trackModifier;
            if (trackModifier == TrackColor.InsideEdge) insideEdgePoints.add(new Point(x-1, y)); else
            if (trackModifier == TrackColor.OutsideEdge) outsideEdgePoints.add(new Point(x-1, y));
        }

        if ((y > 0) && (pixels[x][y-1] == prev)) {
            total = total + fill(x, y-1, color);
        } else
        if ((y > 0) && (pixels[x][y-1] == TrackColor.Track)) {
            pixels[x][y-1] = trackModifier;
            if (trackModifier == TrackColor.InsideEdge) insideEdgePoints.add(new Point(x, y-1)); else
            if (trackModifier == TrackColor.OutsideEdge) outsideEdgePoints.add(new Point(x, y-1));
        }

        if ((x < width-1) && (pixels[x+1][y] == prev)) {
            total = total + fill(x+1, y, color);
        } else
        if ((x < width-1) && (pixels[x+1][y] == TrackColor.Track)) {
            pixels[x+1][y] = trackModifier;
            if (trackModifier == TrackColor.InsideEdge) insideEdgePoints.add(new Point(x+1, y)); else
            if (trackModifier == TrackColor.OutsideEdge) outsideEdgePoints.add(new Point(x+1, y));
        }

        if ((y < height-1) && (pixels[x][y+1] == prev)) {
            total = total + fill(x, y+1, color);
        } else
        if ((y < height-1) && (pixels[x][y+1] == TrackColor.Track)) {
            pixels[x][y+1] = trackModifier;
            if (trackModifier == TrackColor.InsideEdge) insideEdgePoints.add(new Point(x, y+1)); else
            if (trackModifier == TrackColor.OutsideEdge) outsideEdgePoints.add(new Point(x, y+1));
        }

        return total;
    }

    public void DrawTrack() {
        Graphics g = panel.getGraphics();
        
        for (int i=0; i<width; i++) {
            for (int j=0; j<height; j++) {
                Color drawColor;
                switch (pixels[i][j]) {
                    case White: drawColor = Color.WHITE; break;
                    case Track: drawColor = Color.BLACK; break;
                    case Outside: drawColor = Color.YELLOW; break;
                    case Inside: drawColor = Color.GREEN; break;
                    case OutsideEdge: drawColor = Color.RED; break;
                    case InsideEdge: drawColor = Color.BLUE; break;
                    case Waypoint: drawColor = Color.BLACK; break;
                    default: drawColor = Color.ORANGE; break;
                }
                if (drawColor == Color.BLACK) {
                    //System.out.println("Drawing "+i+","+j+", distance = "+distance[i][j]);
                    //int factor = 1;
                    //System.out.println(distance[i][j]);
                    
                    //drawColor = new Color((int)Math.round(distance[i][j]*factor/2),(int)Math.round(distance[i][j]*factor/3),(int)Math.round(distance[i][j]*factor));
                    drawColor = new Color(0, 0, 0);

                }
                g.setColor(drawColor);

                //g.drawOval(i, j, 10, 4);
                //g.fillOval(i, j, 4, 4);
                g.drawRect(i, j + drawOffset, 1, 1);
            }
        }
    }
}
