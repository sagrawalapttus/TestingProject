public class generateTemplatecontroller  {

    public id ProposalId { get; set; }
    public Apttus_Proposal__Proposal__c oProposal { get; set; }
    
    public List<Apttus_Proposal__Proposal_Line_Item__c> oLineItem { get; set; }
    public generateTemplateController(){
        ProposalId =  ApexPages.currentPage().getParameters().get('id');
    }
    public pagereference RenderPDF()
    {
        	oProposal = new Apttus_Proposal__Proposal__c();
        	oLineItem =[Select id,Description_RTF__c,Apttus_Proposal__Unit_Price__c from Apttus_Proposal__Proposal_Line_Item__c where Apttus_Proposal__Proposal__c=:ProposalId];
        	oProposal = [select id,Name from  Apttus_Proposal__Proposal__c where id = :ProposalId];
        	
            Return NULL;        
    }
}