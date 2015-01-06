public class UpdateContactReference{
    public void UpdateContactRefernce(Id ContactId, Id Account2Id)
    {
          Contact con = [Select Id,Name from Contact where Id =:ContactId];          
          con.AccountId = Account2Id;        
          update con;
    }
}