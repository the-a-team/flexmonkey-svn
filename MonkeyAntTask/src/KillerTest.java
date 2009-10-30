import java.io.IOException;


public class KillerTest {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		System.out.println("Hello world");
		Process process = null;
		try {
			process = Runtime.getRuntime().exec("/Applications/Firefox.app/Contents/MacOS/firefox-bin http://www.yahoo.com");
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println("goodbye cruel world");
		try {
			Thread.sleep(10000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println("and goodnewt");
		process.destroy();
		System.out.println("my love");		
	}

}
