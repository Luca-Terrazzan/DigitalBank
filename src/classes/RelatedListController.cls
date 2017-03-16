public with sharing class RelatedListController {

    @AuraEnabled
    public static FinServ__FinancialAccount__c[] getFinancialAccount(Id accountId, String category)
    {
        return AccountService.selectProducts(accountId, category);
    }

     @AuraEnabled
    public static Opportunity[] getOpportunities(Id accountId)
    {
        return AccountService.selectOpportunities(accountId);
    }
}