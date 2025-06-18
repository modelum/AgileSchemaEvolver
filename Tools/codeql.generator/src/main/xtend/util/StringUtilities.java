package util;

public class StringUtilities {
	
	// metodo que cambia _ por -
	public static String replaceUnderscoreWithDash(String input) {
		if (input == null) {
			return null;
		}
		return input.replace("_", "-");
	}
	
	

}
