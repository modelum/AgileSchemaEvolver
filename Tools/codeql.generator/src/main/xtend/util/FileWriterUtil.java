package util;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;

public class FileWriterUtil {
	
	private static final String PREFIX = "<SpringDataJPA CodeQL Generator>";

    public static void writeToFile(String filePath, String content) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath))) {
            writer.write(content);
            System.out.println(PREFIX + " File written successfully to: " + filePath);
        } catch (IOException e) {
            System.err.println(PREFIX + " Error writing to file: " + e.getMessage());
        }
    }

    public static void appendToFile(String filePath, String content) {
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(filePath, true))) {
            writer.write(content);
        } catch (IOException e) {
            System.err.println("Error appending to file: " + e.getMessage());
        }
    }
}
