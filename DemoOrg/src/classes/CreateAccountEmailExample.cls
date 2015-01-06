global class CreateAccountEmailExample implements Messaging.InboundEmailHandler 
{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.Inboundenvelope env)
    {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        try
        {
            Account acc = new Account();
            acc .Name = 'TestAccountEmailExample';
            update acc;
        }
        catch(QueryException ex)
        {
            System.debug('Query Issue: ' + ex);
        }
        result.success = true;
   
       // Return the result for the Apex Email Service
       return result;

    }
}