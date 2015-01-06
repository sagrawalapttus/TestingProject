trigger  DeleteRestrictInvoice on Invoice__c (before delete) {
    List<Invoice__c> invoices = [Select i.Name, (Select Name from Line_Items__r) from Invoice__c i where i.Id IN :Trigger.oldMap.keySet()];
    
    for(Invoice__c invoice :invoices)
    {
        if(!invoice.Line_Items__r.isEmpty())
        {
            Trigger.oldMap.get(invoice.id).addError('Cannot delete invoice with line items');    
        }
    }
}