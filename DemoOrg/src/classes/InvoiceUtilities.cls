global class InvoiceUtilities {
    // Class method to renumber Line Items for a given Invoice number.
   // Returns a string that indicates success or failure.
    webservice static String renumberLineItems(String invoiceName) {
 
    // create a copy of the target Invoice object and it's Line Items
    Invoice__c invoice = [Select i.Name,(Select Name from Line_Items__r order by Name ) from Invoice__c i
                            where i.Name = :invoiceName limit 1];
        
    // loop through each Line Item, renumbering as you go
     Integer i = 1;
       for(Line_Item__c item : invoice.Line_Items__r)
       {
           item.Name = String.valueOf(i);
           System.debug(item.Name);
           i++;
       }  
    // update the Line Items in one transaction, rollback if any problems
    // and return error messages to the calling environment
    try
    {
        Database.update(invoice.Line_items__r);
    }
    catch(DmlException e)
    {
        return e.getMessage();
    }
    // on success, return the list to the calling program
   
        
        return 'Line items renumbered successfully';
  }
}