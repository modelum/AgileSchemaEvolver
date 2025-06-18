package codeql.option;
public enum SeverityEnum {
    WARNING("warning"),
    ERROR("error"),
    RECOMMENDATION("recommendation");

    private final String value;

    SeverityEnum(String value) {
        this.value = value;
    }

    public String getValue() {
        return value;
    }
}