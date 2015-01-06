public class CreateAccAndChangeCon {
    
    public void CreateAccAndChangeCon(){
	//Create Account 'Account1' and Account 'Account2'
	Account acc1 = new Account();
    acc1.Name = 'Account1';
    insert acc1;
    Account acc2 = new Account();
    acc2.Name = 'Account2';
    insert acc2;
    
    //Create contact and refernce to Account1
    Contact c = new Contact();
    c.LastName = 'Contact1';
    c.AccountId = acc1.Id;
    insert c;
}
}