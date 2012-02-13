/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package hotpursuit;

/**
 *
 * @author Andrei
 */
public class State {
    public RealPoint position;
    public double speed; // m/s
    public double angle; // rad

    public State(State s) {
        this.position = new RealPoint(s.position);
        this.speed = s.speed;
//          this.acc = s.acc;
//          this.dec = s.dec;
        this.angle = s.angle;
    }

    public State() {
        this.position = new RealPoint(0, 0);
        this.speed = 0;
        this.angle = 0;
    }

    @Override
    public String toString() {
        return "("+ this.position + ", spd = " + this.speed + ", angle = " + this.angle + ")";
    }
}
