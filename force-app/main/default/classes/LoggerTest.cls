@IsTest
public with sharing class LoggerTest {
    private static final Integer NUM_RECORDS = 10;
    private static final String LOG_LOCATION = 'LoggerTest';
    private static final String TEST_EMAIL = 'logerrordetailtest@mytest.com';

    @TestSetup
    private static void setup(){
        Account a = new TestHelper.AccountFactory()
                .withRecordTypeName('End Customer')
                .insertToDatabase()
                .create();
        new TestHelper.ContactFactory()
                .withEmail(TEST_EMAIL)
                .withFirstName('Olegunar')
                .withLastName('Pavlusik')
                .withAccount(a.Id)
                .insertToDatabase()
                .create();
    }

    @IsTest
    private static void testLogWithMessage(){
        Test.startTest();

        for(Integer i = 0; i < NUM_RECORDS; i++){
            Logger.log(Logger.Level.ERROR, 'testLogWithMessage', LOG_LOCATION);
        }

        Test.stopTest();

        List<Salesforce_Log__c> sfLogs = [SELECT Id, Message__c, Level__c FROM Salesforce_Log__c];
        System.assertEquals(NUM_RECORDS, sfLogs.size());

        for(Salesforce_Log__c log : sfLogs){
            System.assertEquals('testLogWithMessage', log.Message__c);
            System.assertEquals(Logger.Level.ERROR.name(), log.Level__c);
        }
    }

    @IsTest
    private static void testLogWithException(){
        Exception testException;
        Test.startTest();
        try{
            Integer i;
            ++i;
        }catch (Exception e){
            testException = e;
            for(Integer i = 0; i < NUM_RECORDS; i++){
                Logger.log(Logger.Level.ERROR, 'testLogWithException', LOG_LOCATION, e);
            }
        }    
        Test.stopTest();

        List<Salesforce_Log__c> sfLogs = [SELECT Id, Message__c, Level__c, Exception_Type__c, Exception_Stack_Trace__c, Exception_Message__c  FROM Salesforce_Log__c];
        System.assertEquals(NUM_RECORDS, sfLogs.size());

        for(Salesforce_Log__c log : sfLogs){
            System.assertEquals('testLogWithException', log.Message__c);
            System.assertEquals(Logger.Level.ERROR.name(), log.Level__c);
            System.assertEquals(testException.getTypeName(), log.Exception_Type__c);
            System.assertEquals(testException.getStackTraceString(), log.Exception_Stack_Trace__c);
            System.assertEquals(testException.getMessage(), log.Exception_Message__c);
        }
    }

    @IsTest
    private static void testLogWithRelatedRecord(){
        Test.startTest();

        String fakeAccId = fflib_IDGenerator.generate(Account.SObjectType);
        for(Integer i = 0; i < NUM_RECORDS; i++){
            Logger.log(Logger.Level.ERROR, 'testLogWithRelatedRecord', LOG_LOCATION, null, fakeAccId);
        }

        Test.stopTest();

        List<Salesforce_Log__c> sfLogs = [SELECT Id, Message__c, Level__c, Related_Record_ID__c FROM Salesforce_Log__c];
        System.assertEquals(NUM_RECORDS, sfLogs.size());

        for(Salesforce_Log__c log : sfLogs){
            System.assertEquals('testLogWithRelatedRecord', log.Message__c);
            System.assertEquals(Logger.Level.ERROR.name(), log.Level__c);
            System.assertEquals(fakeAccId, log.Related_Record_ID__c);
        }
    }

    @IsTest
    private static void testLogWithCorrectNotificationEmail(){
        Test.startTest();

        for(Integer i = 0; i < NUM_RECORDS; i++){
            Logger.log(Logger.Level.ERROR, 'testLogWithCorrectNotificationEmail', LOG_LOCATION, null, fflib_IDGenerator.generate(Account.SObjectType), 'correct@email.address');
        }

        Test.stopTest();

        List<Salesforce_Log__c> sfLogs = [SELECT Id, Message__c, Level__c, Notification_Email__c FROM Salesforce_Log__c];
        System.assertEquals(NUM_RECORDS, sfLogs.size());

        for(Salesforce_Log__c log : sfLogs){
            System.assertEquals('testLogWithCorrectNotificationEmail', log.Message__c);
            System.assertEquals(Logger.Level.ERROR.name(), log.Level__c);
            System.assertEquals('correct@email.address', log.Notification_Email__c);
        }
    }

    @IsTest
    private static void testLogWithNotCorrectNotificationEmail(){
        Test.startTest();

        for(Integer i = 0; i < NUM_RECORDS; i++){
            Logger.log(Logger.Level.ERROR, 'testLogWithNotCorrectNotificationEmail', LOG_LOCATION, null, fflib_IDGenerator.generate(Account.SObjectType), 'not_correct_email_address');
        }
        
        Test.stopTest();

        List<Salesforce_Log__c> sfLogs = [SELECT Id, Message__c, Level__c FROM Salesforce_Log__c];
        System.assertEquals(NUM_RECORDS, sfLogs.size());

        for(Salesforce_Log__c log : sfLogs){
            System.assertEquals(Logger.Level.ERROR.name(), log.Level__c);
            System.assertEquals('Email address for notification is not in correct format! \n\ntestLogWithNotCorrectNotificationEmail', log.Message__c);
        }
    }

    @IsTest
    private static void testLogWithLoggingLevelDefined(){
        Test.startTest();

        for(Integer i = 0; i < NUM_RECORDS/2; i++){
            Logger.log(Logger.Level.ERROR, 'testLogWithLoggingLevelDefined', LOG_LOCATION);
            Logger.log(Logger.Level.DEBUG, 'testLogWithLoggingLevelDefined', LOG_LOCATION);
        }
        
        Test.stopTest();

        List<Salesforce_Log__c> sfLogs = [SELECT Id, Message__c, Level__c FROM Salesforce_Log__c];
        System.assertEquals(NUM_RECORDS/2, sfLogs.size());

        for(Salesforce_Log__c log : sfLogs){
            System.assertNotEquals(Logger.Level.DEBUG.name(), log.Level__c);
            System.assertEquals('testLogWithLoggingLevelDefined', log.Message__c);
        }
    }

    @IsTest
    private static void testLogWithLoggingLocationAndRelatedObjectDefined(){
        Test.startTest();

        Logger.log(Logger.Level.ERROR, 'testLogWithLoggingLocationAndRelatedObjectDefined', LOG_LOCATION, 'ObjectId');
        
        Test.stopTest();

        List<Salesforce_Log__c> log = [SELECT Id, Message__c, Level__c FROM Salesforce_Log__c];
        System.assertEquals('testLogWithLoggingLocationAndRelatedObjectDefined', log[0].Message__c);
    }

     @IsTest
    private static void testLogWithoutLogSettingsLocationDefined(){
        Test.startTest();

        for(Integer i = 0; i < NUM_RECORDS; i++){
            Logger.log(Logger.Level.ERROR, 'testLogWithoutLogSettingsLocationDefined', 'NOT CORRECT LOCATION');
        }

        Test.stopTest();

        List<Salesforce_Log__c> sfLogs = [SELECT Id, Message__c, Level__c FROM Salesforce_Log__c];
        System.assertEquals(NUM_RECORDS, sfLogs.size());

        for(Salesforce_Log__c log : sfLogs){
            System.assertEquals('testLogWithoutLogSettingsLocationDefined', log.Message__c);
            System.assertEquals(Logger.Level.ERROR.name(), log.Level__c);
        }
    }

    @IsTest
    private static void testLogDetailWithMessage(){
        List<Logger.LogDetail> logDetails = new List<Logger.LogDetail>();

        for(Integer i = 0; i < NUM_RECORDS; i++){
            logDetails.add(new Logger.LogDetail(Logger.Level.ERROR,
                                                'testLogDetail',
                                                LOG_LOCATION));
        }

        Test.startTest();
            Logger.log(logDetails);
        Test.stopTest();

        List<Salesforce_Log__c> sfLogs = [SELECT Id, Message__c, Level__c FROM Salesforce_Log__c];
        System.assertEquals(NUM_RECORDS, sfLogs.size());

        for(Salesforce_Log__c log : sfLogs){
            System.assertEquals('testLogDetail', log.Message__c);
            System.assertEquals(Logger.Level.ERROR.name(), log.Level__c);
        }
    }

    @IsTest
    private static void testLogDetailWithException(){
        Exception testException;
        List<Logger.LogDetail> logDetails = new List<Logger.LogDetail>();

        try{
            Integer i;
            ++i;
        }catch (Exception e){
            testException = e;
            for(Integer i = 0; i < NUM_RECORDS; i++){
                logDetails.add(new Logger.LogDetail(Logger.Level.ERROR,
                                                'testLogWithException',
                                                LOG_LOCATION,
                                                e));
            }
        }

        Test.startTest();
            Logger.log(logDetails);
        Test.stopTest();

        List<Salesforce_Log__c> sfLogs = [SELECT Id, Message__c, Level__c, Exception_Type__c, Exception_Stack_Trace__c, Exception_Message__c  FROM Salesforce_Log__c];
        System.assertEquals(NUM_RECORDS, sfLogs.size());

        for(Salesforce_Log__c log : sfLogs){
            System.assertEquals('testLogWithException', log.Message__c);
            System.assertEquals(Logger.Level.ERROR.name(), log.Level__c);
            System.assertEquals(testException.getTypeName(), log.Exception_Type__c);
            System.assertEquals(testException.getStackTraceString(), log.Exception_Stack_Trace__c);
            System.assertEquals(testException.getMessage(), log.Exception_Message__c);
        }
    }

    @IsTest
    private static void testLogDetailWithRelatedRecord(){
        List<Logger.LogDetail> logDetails = new List<Logger.LogDetail>();
        Contact contact = [SELECT Id, Email FROM Contact WHERE Email = :TEST_EMAIL LIMIT 1];

        for(Integer i = 0; i < NUM_RECORDS; i++){
            logDetails.add(new Logger.LogDetail(Logger.Level.ERROR,
                                                'testLogWithRelatedRecord',
                                                LOG_LOCATION,
                                                null,
                                                contact));
        }

        Test.startTest();
            Logger.log(logDetails);
        Test.stopTest();

        List<Salesforce_Log__c> sfLogs = [SELECT Id, Message__c, Level__c, Related_Record_ID__c FROM Salesforce_Log__c];
        System.assertEquals(NUM_RECORDS, sfLogs.size());

        for(Salesforce_Log__c log : sfLogs){
            System.assert(log.Message__c.startsWith('testLogWithRelatedRecord'));
            System.assertEquals(Logger.Level.ERROR.name(), log.Level__c);
            System.assertEquals(contact.Id, log.Related_Record_ID__c);
            System.assert(log.Message__c.contains(TEST_EMAIL));
        }
    }

    @IsTest
    private static void testLogDetailWithNotificationEmail(){
        List<Logger.LogDetail> logDetails = new List<Logger.LogDetail>();
        Contact contact = [SELECT Id, Email FROM Contact WHERE Email = :TEST_EMAIL LIMIT 1];

        for(Integer i = 0; i < NUM_RECORDS; i++){
            logDetails.add(new Logger.LogDetail(Logger.Level.ERROR,
                                                'testLogDetailWithNotificationEmail',
                                                LOG_LOCATION,
                                                null,
                                                contact,
                                                'correct@email.address'));
        }

        Test.startTest();
            Logger.log(logDetails);
        Test.stopTest();

        List<Salesforce_Log__c> sfLogs = [SELECT Id, Message__c, Level__c, Notification_Email__c FROM Salesforce_Log__c];
        System.assertEquals(NUM_RECORDS, sfLogs.size());

        for(Salesforce_Log__c log : sfLogs){
            System.assert(log.Message__c.startsWith('testLogDetailWithNotificationEmail'));
            System.assertEquals(Logger.Level.ERROR.name(), log.Level__c);
            System.assertEquals('correct@email.address', log.Notification_Email__c);
            System.assert(log.Message__c.contains(TEST_EMAIL));
        }
    }

    @IsTest
    private static void testLogErrorsFromDMLinBulk(){
        List<Contact> contactList = new List<Contact>();
        contactList.addAll(new Set<Contact> {
                new Contact(), new Contact()
        });
        Database.SaveResult[] results = Database.insert(contactList, false);

        Test.startTest();
        Logger.LogErrors('developer test message', results, contactList, LOG_LOCATION);
        Logger.LogErrors(null, results, contactList, LOG_LOCATION);
        Test.stopTest();

        List<Salesforce_Log__c> sfLogs = [SELECT Id, Message__c, Level__c, Notification_Email__c FROM Salesforce_Log__c];
        System.assertEquals(2, sfLogs.size());
        System.assert(sfLogs[0].Message__c.contains('developer test message'));
        System.assert(String.isNotBlank(sfLogs[1].Message__c));
    }

    @IsTest
    private static void testTransactionDetails() {
        Test.startTest();
        Logger.log(Logger.Level.ERROR, 'test transaction details in log', LOG_LOCATION);
        Test.stopTest();
        Salesforce_Log__c log = [SELECT Id, Message__c, Level__c, Request_Id__c, Quiddity__c, Limits__c FROM Salesforce_Log__c][0];
        System.assert(log.Quiddity__c.contains('RUNTEST_'));
        System.assert(!String.isBlank(log.Request_Id__c));
        System.assert(!String.isBlank(log.Limits__c));
        List<LimitService.LimitDTO> limits = (List<LimitService.LimitDTO>)JSON.deserialize(log.Limits__c, List<LimitService.LimitDTO>.class);
        System.assertEquals('CPU_TIME', limits[0].name);
        System.assert(limits[0].usage > 0);
        System.assertEquals('SOQL_QUERIES', limits[1].name);
        System.assert(limits[1].usage == 0);
    }
}