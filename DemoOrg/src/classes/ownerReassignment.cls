global class ownerReassignment implements Database.Batchable<sObject>{

    public String query;
    public String email;
    public Id fromId;
    public Id ToId;
    
    global Database.querylocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<Account> lstAcc = new List<Account>();
        
        for(sObject s : scope)
        {
            Account a = (Account)s;
            if(a.OwnerId == FromId)
            {
                a.OwnerId = ToId;
                lstAcc .add(a);
            }
        }
        try
        {
            update lstAcc;
        }
        catch(Exception e)
        {
            throw e;
        }
    }

    global void finish(Database.BatchableContext BC)
    {
        Messaging.singleEmailMessage mc = new Messaging.singleEmailMessage();
        
        mc.setToAddresses(new String[]{email});
        mc.setReplyTo('sagrawal@apttus.com');
        mc.setSenderDisplayName('Batch Processing');
        mc.setSubject('Batch Process Completed');
        mc.setPlainTextBody('Batch Process has completed');

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mc});
        
    }
}