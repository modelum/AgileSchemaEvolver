package orion;

public class Mapper {
	
	public static String OrionType2Java(String typename) {
		switch (typename) {
			case "Integer":
			case "Int":
			case "int":
			case "Number":
			case"Identifier":
				return "int";
			case "Float":
			case "float":
				return "float";
			case "Double":
			case "double":
				return "double";
			case "String":
			case "string":
				return "String";
			case "Boolean":
			case "Bool":
			case "boolean":
			case "bool":
				return "boolean";
			case "Timestamp":
			case "timestamp":
				return "java.util.Date";
		}
		
		if (typename.matches("\\w+\\(\\d+\\.\\.\\d+\\)")) {
            return "int";
        }
        if (typename.matches("\\w+ in \\(.+\\)")) {
            return "int";
        }
		
		if (typename.matches("\"[^\"]*\"\\s*/.+?/")) {
            return "String";
        }

        if (typename.matches("\"[^\"]*\" in \\(.+\\)")) {
            return "String";
        }
        
        return "";
	}

}
