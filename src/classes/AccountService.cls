/**
 * Serice class for accounts, encapsulate all the logic calls for the 720 view.
 */
public class AccountService
{
    /**
     * Select retial products only based on a specific Account - mostly individual accounts
     * @param      accountId  The account identifier
     * @return     FinServ__FinancialAccount__c[]
     */
    public static FinServ__FinancialAccount__c[] selectRetailProducts(Id accountId)
    {
        return new FinancialAccountsSelector().selectByAccount(new Set<Id>{accountId}, false);
    }
    /**
     * Select commercial products only based on a specific Account - mostly individual accounts
     * @param      accountId  The account identifier
     * @return     FinServ__FinancialAccount__c[]
     */
    public static FinServ__FinancialAccount__c[] selectCommercialProducts(Id accountId)
    {
        return new FinancialAccountsSelector().selectByAccount(new Set<Id>{accountId}, true);
    }
}