public class testpdf1
{
    public list<Account> opp{get;set;}

    public testpdf1()
    {
        opp=[SELECT Name  from Account limit 200];
    }
}