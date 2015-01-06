public class MyTestClass {
    public Book__c[] lstBooks {get; set; }
    
    public MyTestClass()
    {
        lstBooks = [SELECT Name,Price__c FROM Book__c];        
    }

   
}