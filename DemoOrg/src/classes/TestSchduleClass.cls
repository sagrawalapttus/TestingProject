@istest
  private class TestSchduleClass
{
     static testmethod void test()
    {
        Test.startTest();
        Account a = new Account();
        a.Name = 'testScheduledApexFromTestMethod';
        insert a;

        //Schedule the test job
        String JobId = System.schedule('testBasicScheduleApex',scheduleAccountNameUpdate.CRON_Exp, new 
        scheduleAccountNameUpdate());

        //Get the information from CronTrigger API object
        CronTrigger ct = [Select Id, CronExpression ,TimesTriggered,NextFireTime from CronTrigger where id = :JobId];

        // Verify the expressions are the same
      System.assertEquals(scheduleAccountNameUpdate.CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run
      System.assertEquals('2014-09-30 14:30:00', 
         String.valueOf(ct.NextFireTime));
      System.assertNotEquals('testScheduledApexFromTestMethodUpdated',
         [SELECT id, name FROM account WHERE id = :a.id].name);

   Test.stopTest();

   System.assertEquals('testScheduledApexFromTestMethodUpdated',
   [SELECT Id, Name FROM Account WHERE Id = :a.Id].Name);

}
}