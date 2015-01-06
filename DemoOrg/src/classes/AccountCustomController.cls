public class AccountCustomController
{
    
    public List<Account> lstaccount {get; set; }
    public Account myAccount{get; set; }

    public AccountCustomController()
    {
         lstaccount = new List<Account>();
        lstaccount = [ Select Id,Name,Billing_State_Province__c,Phone,Website from Account ];
        myAccount = new Account();
    }
    
    public List<Account> getAccount()
    {
        return lstaccount;
    }
    
    public PageReference save()
    {
        insert myAccount;
        update lstaccount;
       //PageReference pr = new PageReference ('/apex/Assignment1_2');
      myAccount = new Account();
      lstaccount = [ Select Id,Name,Billing_State_Province__c,Phone,Website from Account ];
       return null;
    }
}