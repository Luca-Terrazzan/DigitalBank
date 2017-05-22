/**
 * Service class for accounts, encapsulate all the logic calls for the 720 view.
 */
public class AccountService
{
    /**
     * Select products only based on a specific Account - mostly individual accounts
     * @param      accountId  The account identifier
     * @param      category  The financial account category
     * @return     FinServ__FinancialAccount__c[]
     */
    public static FinServ__FinancialAccountRole__c[] selectProducts(Id accountId, String category)
    {
        return new FinancialAccountRolesSelector().selectByAccount(new Set<Id>{accountId}, category.toLowerCase());
    }

    /**
     * Select all opportunities based upon a certain account and category
     * @param      accountId  The account identifier
     * @param      category   The category
     * @return     Opportunity[]
     */
    public static Opportunity[] selectOpportunities(Id accountId, String category)
    {
        return new OpportunitiesSelector().selectByAccount(new Set<Id>{accountId}, category.toLowerCase());
    }

    /**
     * Select all Transactions based upon a certain account and category
     * @param      accountId  The account identifier
     * @param      category   The category
     * @return     Transaction__c[]
     */
    public static Transaction__c[] selectTransactions(Id accountId, String category)
    {
        return new TransactionsSelector().selectByAccount(new Set<Id>{accountId}, category.toLowerCase());
    }

    /**
     * Gets the account fields.
     * @param      accountId  The account identifier
     * @param      fieldList  The field list
     * @return     The account fields.
     */
    @AuraEnabled
    public static String getAccountFields(Id accountId, String fieldList)
    {
        return new AccountsSelector().getAccountFields(accountId, fieldList);
    }
}