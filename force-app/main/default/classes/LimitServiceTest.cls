@IsTest
private class LimitServiceTest {
    @IsTest
    static void constructorTest() {
        LimitService.LimitDTO testLimit = new LimitService.LimitDTO('test', 10, 100);
        System.assertEquals(90, testLimit.remaining);
    }

    @IsTest
    static void getLimitTest() {
        Test.startTest();
        LimitService.LimitDTO cpu = LimitService.getLimit(LimitService.LimitName.CPU_TIME);
        LimitService.LimitDTO soql = LimitService.getLimit(LimitService.LimitName.SOQL_QUERIES);
        Test.stopTest();

        System.assertEquals('CPU_TIME', cpu.name);
        System.assert(cpu.usage >= 0);
        System.assert(cpu.totalLimit > 0);

        System.assertEquals('SOQL_QUERIES', soql.name);
        System.assert(soql.usage == 0);
        System.assert(soql.totalLimit > 0);
    }
}