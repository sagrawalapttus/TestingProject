public class Assignment5Controller
{    
    public List<Account> lstAccounts { get; set; }
    
    public Assignment5Controller()
    {
        lstAccounts = [ Select Name, BillingState, Phone, Website from Account limit 10 ];
    }
    
    public void selectAccount()
    {
        
    }
}