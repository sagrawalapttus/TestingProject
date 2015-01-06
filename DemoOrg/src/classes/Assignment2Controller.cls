public class Assignment2Controller
{
    public string sAccName { get; set; }
    public List<Account> lstAccount { get; set; }
    public boolean Rendered {get; set;}
    
    
    public Assignment2Controller()
    {
        Rendered = false;
    }
    
    public PageReference GetAccountDetails(){
        
        sAccName  = '%' + sAccName + '%';
        lstAccount = [Select Name, Billing_State_Province__c, Phone,WebSite from Account where Name like :'%' + sAccName + '%'];
        Rendered  = true;
        return null;
    }
}