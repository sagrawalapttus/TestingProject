@isTest
private class HelloWorldTestClass1{

    static testMethod void validateHelloWorld(){
    Book__c b = new Book__c(Name='Behind the cloud', Price__c=100);
    System.debug('Price before inserting new book: ' + b.Price__c);
    
    insert b;
    
     Book__c c = [Select Price__c from Book__c where Id=:b.Id];
    System.debug('Price after trigger fired'+c.Price__c);
    
    System.assertEquals(c.Price__c, 90);
    }
    
}