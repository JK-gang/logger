public inherited sharing class LogTriggerHandler {
    public void afterInsert(Map<Id, SObject> newMap) {
        LogService.recordSalesforceLogs((Map<Id, Log__e>) newMap);
    }
}