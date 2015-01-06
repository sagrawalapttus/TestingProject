global class scheduleAccountNameUpdate implements Schedulable
{
   // public static string CRON_Exp = '0 15 4 30 SEP ? 2014';
    
    global void execute(SchedulableContext ctx)
    {
        //CronTrigger ct = [Select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where Id = :ctx.getTriggerId()];
        
               
        Account a = [Select Id, Name from Account where Name ='testScheduledApexFromTestMethod'];
        a.Name = 'testScheduledApexFromTestMethodUpdated';
       Update a;
        
    }
}