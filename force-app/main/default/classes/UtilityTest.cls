@IsTest
public with sharing class UtilityTest {
    @IsTest
    static void safeAbbreviateTest() {

        Test.startTest();
        String testString;
        String result = Utility.safeAbbreviate(testString, 30);
        System.assertEquals('', result);

        testString = '';
        result = Utility.safeAbbreviate(testString, 30);
        System.assertEquals('', result);

        testString = 'Some long testing string';
        result = Utility.safeAbbreviate(testString, 5);
        System.assertEquals('So...', result);

        testString = 'Some long testing string';
        result = Utility.safeAbbreviate(testString, 8);
        System.assertEquals('Some ...', result);

        testString = 'Some long testing string';
        result = Utility.safeAbbreviate(testString, 0);
        System.assertEquals('', result);

        Test.stopTest();
    }

    @IsTest
    static void isValidEmailTest() {

        Test.startTest();
        Boolean validEmail = true;
        String sampleInvalidEmail = 'invalidEmailAddress';
        validEmail = Utility.isValidEmail(sampleInvalidEmail);
        System.assertEquals(false, validEmail, 'Email is not valid: Missing both "@" and "."');
        sampleInvalidEmail = 'invalidEmail@Address';
        validEmail = Utility.isValidEmail(sampleInvalidEmail);
        System.assertEquals(false, validEmail, 'Email is not valid: Missing "."');
        sampleInvalidEmail = 'invalidEmail.Address';
        validEmail = Utility.isValidEmail(sampleInvalidEmail);
        System.assertEquals(false, validEmail, 'Email is not valid: Missing "@"');
        sampleInvalidEmail = 'invalidEmail.Address@';
        validEmail = Utility.isValidEmail(sampleInvalidEmail);
        System.assertEquals(false, validEmail, 'Email is not valid: Symbol "@" has incorrect position');
        sampleInvalidEmail = '@invalidEmail.Address';
        validEmail = Utility.isValidEmail(sampleInvalidEmail);
        System.assertEquals(false, validEmail, 'Email is not valid: Symbol "@" has incorrect position');
        sampleInvalidEmail = 'invalid@Email@Addre.ss';
        validEmail = Utility.isValidEmail(sampleInvalidEmail);
        System.assertEquals(false, validEmail, 'Email is not valid: There are two "@" symbols');
        sampleInvalidEmail = '';
        validEmail = Utility.isValidEmail(sampleInvalidEmail);
        System.assertEquals(false, validEmail, 'Email is not valid: email string is blank');
        sampleInvalidEmail = 'ss@-dsf.com';
        validEmail = Utility.isValidEmail(sampleInvalidEmail);
        System.assertEquals(false, validEmail, 'Email is not valid: email string is blank');
        sampleInvalidEmail = 'sf@.ss.com';
        validEmail = Utility.isValidEmail(sampleInvalidEmail);
        System.assertEquals(false, validEmail, 'Email is not valid: email string is blank');
        sampleInvalidEmail = 'sfsaf.@fsfs.so';
        validEmail = Utility.isValidEmail(sampleInvalidEmail);
        System.assertEquals(false, validEmail, 'Email is not valid: email string is blank');
        sampleInvalidEmail = 'sfsaf@fsfs..so';
        validEmail = Utility.isValidEmail(sampleInvalidEmail);
        System.assertEquals(false, validEmail, 'Email is not valid: email string is blank');

        String sampleValidEmail = 'valid@email.uk';
        validEmail = Utility.isValidEmail(sampleValidEmail);
        System.assertEquals(true, validEmail, 'Email is valid');
        Test.stopTest();
    }
}