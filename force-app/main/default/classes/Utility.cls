public inherited sharing class Utility {
    /** This is pattern for valid Email */
    public static final String EMAIL_VALIDATION_REGEX_PATTERN = '^[a-zA-Z0-9!#$%&\'*+\\/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%&\'*+\\/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$';

    /**
     * Cuts the string and not throws exception if the string is null.
     * That means that the final sting will have it size as
     * parameter length including last three characters will be "."
     * For example: for entered string "Salesforce" and parameter length = 8,
     * the output will be "Sales..."
     * 
     * @param s - string for abbreviation
     * @param  length - final length including three "."
     *
     * @return abbreviated string
     * */
    public static String safeAbbreviate(String s, Integer length) {
        if (!String.isEmpty(s) && length > 0) {
            return s.abbreviate(length);
        }
        return '';
    }

    /**
     * Checks validity of entered email address.
     * Checks:
     * 1) if address contains "@"
     * 2) if part before "@" si not blank and contains allowed characters
     * 3) if part after "@" is not blank and contains allowed characters
     * 4) if suffix after "." is > 1, contains allowed characters and end with this
     * 
     * @param email - email address for checking
     * @return - true if email is valid, false otherwise
     * */
    public static Boolean isValidEmail(String email) {
        if (String.isBlank(email)) {
            return false;
        }
        String emailRegex = EMAIL_VALIDATION_REGEX_PATTERN;
        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher emailMatcher = emailPattern.matcher(email);

        return emailMatcher.matches();
    }
}
