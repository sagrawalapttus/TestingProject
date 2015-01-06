public class Assignment4Controller{
    public List<Contact> lstContacts { get; set; }
    public Map<Id, List<Contact>> map1 {get; set;}
    public Map<Id, String> mapAccount {get; set;}
   
    public List<Contact> xContact = new List<Contact>();
    
    public Assignment4Controller(){
         map1 = new Map<Id, List<Contact>>();
         mapAccount  = new Map<Id,String>();
        lstContacts = new List<Contact>();
        lstContacts = [Select Id,FirstName, LastName, Phone, Email, Account.Name, Account.Id from contact limit 10];
        
        for(contact c : lstContacts)
        {
            if(map1.containsKey(c.Account.Id))
            {
                //xContact.add(c);
                //Id AccountId = map1.get(c.Account.Id);
                //map1 .put(AccountId , xContact);
                map1.get(c.Account.Id).add(c);
            }
            else
            {   
                xContact = new List<Contact>();             
                xContact.add(c);
                map1.put(c.Account.Id,xContact);
                mapAccount.put(c.Account.Id,c.Account.Name);
            }
        }
    }
}