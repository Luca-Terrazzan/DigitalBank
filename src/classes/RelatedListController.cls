public with sharing class RelatedListController {

    @AuraEnabled
    public static FinServ__FinancialAccount__c[] getRetailFinancialAccount(Id accountId)
    {
        return AccountService.selectRetailProducts(accountId);
    }

    @AuraEnabled
    public static FinServ__FinancialAccount__c[] getCommercialFinancialAccount(Id accountId)
    {
        return AccountService.selectCommercialProducts(accountId);
    }
}