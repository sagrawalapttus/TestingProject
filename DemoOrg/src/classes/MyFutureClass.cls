global class MyFutureClass {
	@future
    public static void MyMethod()
    {
        List<Account> lstAcc = new List<Account>();
        
        System.debug('@@'+lstAcc);
        for(Account acc :[Select Id,Name,RecordType.Name  from Account ])
        {
            acc.Name = acc.RecordType.Name + acc.Name;
            System.debug('**'+acc.Name);
            lstAcc.add(acc);
        }
        update lstAcc;
        //System.debug('**'+acc);
    }
}