/**
 * Serice class for accounts, encapsulate all the logic calls for the 720 view.
 */
public class AccountService
{
    /**
     * Select products only based on a specific Account - mostly individual accounts
     * @param      accountId  The account identifier
     * @param      category  The financial account category
     * @return     FinServ__FinancialAccount__c[]
     */
    public static FinServ__FinancialAccount__c[] selectProducts(Id accountId, String category)
    {
        return new FinancialAccountsSelector().selectByAccount(new Set<Id>{accountId}, category.toLowerCase());
    }

    public static Opportunity[] selectOpportunities(Id accountId)
    {
        return new OpportunitiesSelector().selectByAccount(new Set<Id>{accountId}, 'opportunity');
    }
}