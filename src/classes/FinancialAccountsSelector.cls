/**
 * Encapsulate query logic for Financial Accounts
 */
public class FinancialAccountsSelector extends fflib_SObjectSelector
{
    /**
     * Gets the s object field list.
     * @return     The s object field list.
     */
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            FinServ__FinancialAccount__c.Id,
            FinServ__FinancialAccount__c.Name,
            FinServ__FinancialAccount__c.FinServ__Balance__c,
            FinServ__FinancialAccount__c.FinServ__FinancialAccountType__c,
            FinServ__FinancialAccount__c.FinServ__OwnerType__c,
            FinServ__FinancialAccount__c.FinServ__OpenDate__c,
            FinServ__FinancialAccount__c.FinServ__Status__c
        };
    }

    /**
     * Gets a list of strings representing the fields returned by getSObjectFieldList()
     * @return     The field list string.
     */
    public List<String> getFieldListString()
    {
        List<String> fieldList = new List<String>();
        for(Schema.SObjectField field : getSObjectFieldList()){
            fieldList.add(field.getDescribe().getName());
        }
        return fieldList;
    }

    /**
     * Gets currently represented sobject type name
     * @return     The s object type.
     */
    public Schema.SObjectType getSObjectType()
    {
        return FinServ__FinancialAccount__c.sObjectType;
    }

    /**
     * Default selection of items by id
     * @param      idSet  The identifier set
     * @return     List of financial accounts
     */
    public List<FinServ__FinancialAccount__c> selectById(Set<ID> idSet)
    {
        if (idSet == null || idSet.isEmpty()) return new FinServ__FinancialAccount__c[]{};
        return (List<FinServ__FinancialAccount__c>) selectSObjectsById(idSet);
    }

    public FinServ__FinancialAccount__c[] selectByAccount(Set<Id> accountIds)
    {
        return selectByAccount(accountIds, 'retail');
    }

    /**
     * Select all financial accounts primarily related to a list of accounts
     * @param      accountIds  The account identifiers
     * @return     List of financial accounts
     */
    public FinServ__FinancialAccount__c[] selectByAccount(Set<Id> accountIds, String category)
    {
        assertIsAccessible();
        String query = String.format(
                'select {0} ' +
                    'from {1} ' +
                    'where FinServ__PrimaryOwner__c IN: accountIds ' +
                    'AND Category__c =: category',
                new List<String> {
                    String.join(getFieldListString(), ', '),
                    getSObjectName()
                }
            );
        System.debug('query: ' + query);
        System.debug('id: ' + accountIds);
        System.debug('category: ' + category);
        return (List<FinServ__FinancialAccount__c>) Database.query(query);
    }

}