/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package hotpursuit;

/**
 *
 * @author Andrei
 */
public class RealPoint {
    public double x, y;

    public RealPoint(double x, double y) {
        this.x = x;
        this.y = y;
    }

    public RealPoint(Point p) {
        this.x = p.x;
        this.y = p.y;
    }

    public RealPoint(RealPoint p) {
        this.x = p.x;
        this.y = p.y;
    }

    @Override
    public boolean equals(Object o) {
        if (o instanceof Point) {
            RealPoint oPoint = (RealPoint)o;
            return (oPoint.x == this.x) && (oPoint.y == this.y);
        } else return false;
    }

    @Override
    public String toString() {
        return "(" + this.x + ", " + this.y + ")";
    }
}

