public with sharing class Assignment2 {    
    public void method1() {
        List<Book__c> lstBooks = new list<Book__c>();
        Book__c book12 = new Book__c(Name = 'test',Price__c=10);
        lstBooks.add(book12);
        insert lstBooks;
        
        Account a = new Account(Name='Account Example');
insert a;
    }
}