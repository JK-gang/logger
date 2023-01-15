trigger LogTrigger on Log__e (after insert) {
    new LogTriggerHandler().afterInsert(Trigger.newMap);
}