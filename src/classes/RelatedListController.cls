public with sharing class RelatedListController {

    @AuraEnabled
    public static FinServ__FinancialAccountRole__c[] getFinancialAccount(Id accountId, String category)
    {
        return AccountService.selectProducts(accountId, category);
    }

     @AuraEnabled
    public static Opportunity[] getOpportunities(Id accountId, String category)
    {
        return AccountService.selectOpportunities(accountId, category);
    }

    @AuraEnabled
    public static Id getFADefaultRecordType()
    {
        return FinancialAccountRolesSelector.getDefaultRecordType();
    }

    @AuraEnabled
    public static Id getOppDefaultRecordType()
    {
        return OpportunitiesSelector.getDefaultRecordType();
    }
}