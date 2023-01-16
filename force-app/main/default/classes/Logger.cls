public with sharing class Logger {
    public enum Level {
        ERROR,
        DEBUG
    }

    /**
    * @description Log errors in bulk which are direct results of a DML
    * @param developerErrorMessage developer added message to identify the issue better
    * @param results List of delete results
    * @param objectList List of objects used in DML
    * @param location Salesforce_Log__c location
    */
    public static void LogErrors(String developerErrorMessage, List<Database.DeleteResult> results, List<SObject> objectList, String location) {
        Integer index = 0;
        Integer errorIds = 0;
        Map<String, SObject> errorMap = new Map<String, SObject>();
        for (Database.DeleteResult dr : results) {
            if (!dr.isSuccess() && errorMap.size() < 1000) {
                for (Database.Error error : dr.getErrors()) {
                    String deleteResultErrMsg = error.getMessage();
                    if (!errorMap.containsKey(deleteResultErrMsg)) {
                        errorMap.put(deleteResultErrMsg, objectList[index]);
                    }
                    errorIds++;
                }
            }
            index++;
        }

        List<LogDetail> errorDetails = new List<LogDetail>();
        for (String deleteResultErrMsg : errorMap.keySet()) {
            String errorMessage = deleteResultErrMsg;
            if (String.isNotBlank(developerErrorMessage)) {
                errorMessage = developerErrorMessage + ': ' + errorMessage;
            }
            errorDetails.add(new LogDetail(Logger.Level.ERROR, errorMessage, location, null, errorMap.get(deleteResultErrMsg)));
        }

        Logger.log(errorDetails);
    }

    /**
    * @description Log errors in bulk which are direct results of a DML
    * @param developerErrorMessage developer added message to identify the issue better
    * @param results List of save results
    * @param objectList List of objects used in DML
    * @param location Salesforce_Log__c location
    */
    public static void LogErrors(String developerErrorMessage, List<Database.SaveResult> results, List<SObject> objectList, String location) {
        Integer index = 0;
        Integer errorIds = 0;
        Map<String, SObject> errorMap = new Map<String, SObject>();
        for (Database.SaveResult sr : results) {
            if (!sr.isSuccess() && errorMap.size() < 1000) {
                for (Database.Error error : sr.getErrors()) {
                    String saveResultErrMsg = error.getMessage();
                    if (!errorMap.containsKey(saveResultErrMsg)) {
                        errorMap.put(saveResultErrMsg, objectList[index]);
                    }
                    errorIds++;
                }
            }
            index++;
        }

        List<LogDetail> errorDetails = new List<LogDetail>();
        for (String saveResultErrMsg : errorMap.keySet()) {
            String errorMessage = saveResultErrMsg;
            if (String.isNotBlank(developerErrorMessage)) {
                errorMessage = developerErrorMessage + ': ' + errorMessage;
            }
            errorDetails.add(new LogDetail(Logger.Level.ERROR, errorMessage, location, null, errorMap.get(saveResultErrMsg)));
        }

        Logger.log(errorDetails);
    }

    public class LogDetail {
        public Level logLevel;
        public String message;
        public String location;
        public Exception e { get; set; }
        public String relatedRecordId { get; set; }
        public String notificationEmail { get; set; }

        public LogDetail(Level logLevel,
                String message,
                String location,
                Exception e,
                SObject relatedRecord,
                String notificationEmail) {
            this.logLevel = logLevel;
            this.message = message + ',\nRecord: ' + String.valueOf(relatedRecord);
            this.location = location;
            this.e = e;
            this.relatedRecordId = relatedRecord?.Id;
            this.notificationEmail = notificationEmail;
        }

        public LogDetail(Level logLevel,
                String message,
                String location,
                Exception e,
                SObject relatedRecord) {
            this.logLevel = logLevel;
            this.message = message + ',\nRecord: ' + String.valueOf(relatedRecord);
            this.location = location;
            this.e = e;
            this.relatedRecordId = relatedRecord?.Id;
        }

        public LogDetail(Level logLevel,
                String message,
                String location,
                Exception e) {
            this.logLevel = logLevel;
            this.message = message;
            this.location = location;
            this.e = e;
            this.relatedRecordId = '';
            this.notificationEmail = '';
        }

        public LogDetail(Level logLevel,
                String message,
                String location) {
            this.logLevel = logLevel;
            this.message = message;
            this.location = location;
            this.e = null;
            this.relatedRecordId = '';
            this.notificationEmail = '';
        }
    }

    public static void log(List<LogDetail> logDetails) {
        List<Log__e> logEvents = new List<Log__e>();

        for (LogDetail detail : logDetails) {
            logEvents.add(createLogEvent(detail.logLevel,
                    detail.message,
                    detail.location,
                    detail.e,
                    detail.relatedRecordId,
                    detail.notificationEmail));
        }
        EventBus.publish(logEvents);
    }

    public static void log(Level logLevel, String message, String location) {
        log(logLevel, message, location, null, '', '');
    }

    public static void log(Level logLevel, String message, String location, Exception e) {
        log(logLevel, message, location, e, '', '');
    }

    public static void log(Level logLevel, String message, String location, Exception e, String relatedRecordId) {
        emit(logLevel, message, location, e, relatedRecordId, '');
    }

    public static void log(Level logLevel, String message, String location, String relatedRecordId) {
        emit(logLevel, message, location, null, relatedRecordId, '');
    }

    public static void log(Level logLevel, String message, String location, Exception e, String relatedRecordId, String notificationEmail) {
        emit(logLevel, message, location, e, relatedRecordId, notificationEmail);
    }

    private static void emit(Level logLevel, String message, String location, Exception e, String relatedRecordId, String notificationEmail) {
        Log__e currentEvent = new Log__e();

        currentEvent = createLogEvent(logLevel, message, location, e, relatedRecordId, notificationEmail);
        EventBus.publish(currentEvent);
    }

    private static Log__e createLogEvent(Level logLevel, String message, String logLocation, Exception e, String relatedRecordId, String notificationEmail) {
        Log__e newEvent = new Log__e();
        newEvent.Related_Record_ID__c = relatedRecordId;
        newEvent.Message__c = Utility.safeAbbreviate(message, Schema.SObjectType.Log__e.fields.Message__c.getLength());
        newEvent.Notification_Email__c = notificationEmail;
        newEvent.Running_User_ID__c = UserInfo.getUserId();
        newEvent.Level__c = logLevel.name();
        newEvent.Time_Stamp__c = System.now();
        newEvent.Location__c = logLocation;

        Request reqInfo = Request.getCurrent();
        newEvent.Request_Id__c = reqInfo.getRequestId();
        newEvent.Quiddity__c = reqInfo.getQuiddity().name();

        List<LimitService.LimitDTO> limits = new List<LimitService.LimitDTO>{
                LimitService.getLimit(LimitService.LimitName.CPU_TIME),
                LimitService.getLimit(LimitService.LimitName.SOQL_QUERIES)
        };
        newEvent.Limits__c = Utility.safeAbbreviate(JSON.serialize(limits), SObjectType.Log__e.fields.Limits__c.length);

        if (e != null) {
            newEvent.Exception_Type__c = e.getTypeName();
            newEvent.Exception_Stack_Trace__c = e.getStackTraceString();
            newEvent.Exception_Message__c = e.getMessage();
        }
        return newEvent;
    }
}