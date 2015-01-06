trigger AccountCreate on Account (before insert, before update, before delete) {
   List<Account> accList = new List<Account>();
   if(Trigger.isInsert)
   {
    for(account acc : Trigger.New)
    {
        acc.Site = 'TestSite';
       
    }
    }
    
    if(Trigger.isUpdate)
    {
        for(account acc : Trigger.New)
        {
            if(acc.Type=='Customer - Direct')
            {
                accList.add(acc);
            }
        }
        
        for(Account acc :accList)
        {
            for(account accOld : Trigger.Old)
            {
                if(acc.Id == accOld.Id && acc.AccountNumber != accOld.AccountNumber)
                {
                    acc.addError('cannot update account number for Customer Direct');
                }
            }
        }
    }
    
    if(Trigger.isDelete)
    {
    //User u = [select Id, username,UserRole.Name from User where Id = :UserInfo.getUserId()];
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        for(account acc : Trigger.Old)
        {
            
            if(profileName != 'System Administrator')
            {
                acc.addError('Cannot delete! Permission Denied');
            }
        }
    }
    
   
    }