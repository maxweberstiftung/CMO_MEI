package ngb;

import javax.swing.JOptionPane;

public class App {
    
    public static void main(String[] args) {
        if (args.length == 0) {
            showError("No files given");
            return;
        }
    }
    
    public static void showError(String message) {
        JOptionPane.showMessageDialog(null, message, "Error Processing Files", JOptionPane.WARNING_MESSAGE);
    }
}
