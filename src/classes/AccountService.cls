/**
 * Serice class for accounts, encapsulate all the logic calls for the 720 view.
 **/
public class AccountService
{
    public static FinServ__FinancialAccount__c[] selectRetailProducts(Id accountId)
    {
        return new FinancialAccountsSelector().selectByAccount(new Set<Id>{accountId}, false);
    }

    public static FinServ__FinancialAccount__c[] selectCommercialProducts(Id accountId)
    {
        return new FinancialAccountsSelector().selectByAccount(new Set<Id>{accountId}, true);
    }
}