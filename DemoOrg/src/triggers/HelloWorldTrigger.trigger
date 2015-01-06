trigger HelloWorldTrigger on Book__c (before insert) {
    Book__c[] books = Trigger.New;
    myHelloWorld.applyDiscount(books);
}