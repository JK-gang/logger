public inherited sharing class LogService {
    /**
    * Creates 'Salesforce Log' records based on Log__e platform events.
    *
    * @param eventLogs map of Log__e platform events
    */
    public static void recordSalesforceLogs(Map<Id,Log__e> eventLogs) {
        List<Salesforce_Log__c> sfLogs = new List<Salesforce_Log__c>();
        Map<String, Salesforce_Log_Setting__mdt> settingsByLocation = getSalesforceLogSettings();   

        try{ 
            for(Log__e eventLog : eventLogs.values()) {
                // Check whether we have Salesforce_Log_Setting__mdt record for the location defined. Location__c
                // If yes, create only logs with respective logging level. Otherwise the logging level is not checked and logs are created.
                if(settingsByLocation.containsKey(eventLog.Location__c)){
                    if(eventLog.Level__c == 'DEBUG' && settingsByLocation.get(eventLog.Location__c).DEBUG__c == true
                        || eventLog.Level__c == 'ERROR' && settingsByLocation.get(eventLog.Location__c).ERROR__c == true){
                            sfLogs.add(prepareSalesforceLogRecord(eventLog));
                    }  
                } else {
                    sfLogs.add(prepareSalesforceLogRecord(eventLog));
                }
            }
            insert sfLogs;
        } 
        catch (Exception e){
            Logger.log(Logger.Level.ERROR, 'Something fatal has occurred and hence failed to create Salesforce Log records.', 'LogService', e);
        }
    }

    private static Salesforce_Log__c prepareSalesforceLogRecord(Log__e eventLog){
        Salesforce_Log__c log = new Salesforce_Log__c();
        log.Running_User_ID__c = eventLog.Running_User_ID__c;
        log.Level__c = eventLog.Level__c;
        log.Location__c = eventLog.Location__c;
        log.Related_Record_ID__c = eventLog.Related_Record_ID__c;
        log.Message__c = eventLog.Message__c;
        log.Time_Stamp__c = eventLog.Time_Stamp__c;
        log.Exception_Type__c = eventLog.Exception_Type__c;
        log.Exception_Stack_Trace__c = eventLog.Exception_Stack_Trace__c;
        log.Exception_Message__c = eventLog.Exception_Message__c;
        log.Quiddity__c = eventLog.Quiddity__c;
        log.Request_Id__c = eventLog.Request_Id__c;
        log.Limits__c = eventLog.Limits__c;

        if (String.isNotBlank( eventLog.Notification_Email__c )){
            if (Utility.isValidEmail( eventLog.Notification_Email__c )) {
                log.Notification_Email__c = eventLog.Notification_Email__c; 
            } else {
                log.Message__c = 'Email address for notification is not in correct format! \n\n' + log.Message__c;
            }
        }

        return log;
    }

    private static Map<String, Salesforce_Log_Setting__mdt> getSalesforceLogSettings(){
        Map<String, Salesforce_Log_Setting__mdt> logSettings = new Map<String, Salesforce_Log_Setting__mdt>(Salesforce_Log_Setting__mdt.getAll());
        Map<String, Salesforce_Log_Setting__mdt> settingsByLocation = new Map<String, Salesforce_Log_Setting__mdt>();

        for(Salesforce_Log_Setting__mdt setting : logSettings.values()){
            settingsByLocation.put(setting.Location__c, setting);
        }
        return settingsByLocation;
    }
}