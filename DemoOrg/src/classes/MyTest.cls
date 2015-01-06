public class MyTest{
    String sName;
    String sYearStarted;
    
    public MyTest()
    {
        sName='DefaultName';
        sYearStarted='2014';
    }
    
    public MyTest(String s1, String i1)
    {
        sName=s1;
        sYearStarted=i1;
    }
    public void MyTest(){        
        Account acc = new Account();
        acc.Name = sName;
        acc.YearStarted = sYearStarted;
        insert acc;
    }
}