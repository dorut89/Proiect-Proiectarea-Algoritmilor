/*
 * ai.java
 */

package hotpursuit;

import org.jdesktop.application.Application;
import org.jdesktop.application.SingleFrameApplication;

/**
 * The main class of the application.
 */
public class ai extends SingleFrameApplication {
    public static String team = "HotPursuit";
    public static String server = "localhost";
    public static int port = 4445;
    public static int simulationLimit = 25000;
    /**
     * At startup create and show the main frame of the application.
     */
    @Override protected void startup() {
        show(new aiView(this));
    }

    /**
     * This method is to initialize the specified window by injecting resources.
     * Windows shown in our application come fully initialized from the GUI
     * builder, so this additional configuration is not needed.
     */
    @Override protected void configureWindow(java.awt.Window root) {
    }

    /**
     * A convenient static getter for the application instance.
     * @return the instance of ai
     */
    public static ai getApplication() {
        return Application.getInstance(ai.class);
    }

    /**
     * Main method launching the application.
     */
    public static void main(String[] args) {
        launch(ai.class, args);
    }
}
