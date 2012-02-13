/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package hotpursuit;

/**
 *
 * @author Andrei
 */
public class Point {
    public int x, y;

    public Point() {
        this(0, 0);
    }

    public Point(int x, int y) {
        this.x = x;
        this.y = y;
    }

    public Point(Point p) {
        this.x = p.x;
        this.y = p.y;
    }

    @Override
    public boolean equals(Object o) {
        if (o instanceof Point) {
            Point oPoint = (Point)o;
            return (oPoint.x == this.x) && (oPoint.y == this.y);
        } else return false;
    }

    @Override
    public String toString() {
        return "(" + this.x + ", " + this.y + ")";
    }
}

