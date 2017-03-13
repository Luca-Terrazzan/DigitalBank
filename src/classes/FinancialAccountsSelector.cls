/**
 * Encapsulate query logic for Financial Accounts
 **/
public class FinancialAccountsSelector extends fflib_SObjectSelector
{
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            FinServ__FinancialAccount__c.Id,
            FinServ__FinancialAccount__c.Name,
            FinServ__FinancialAccount__c.FinServ__Balance__c
        };
    }

    public List<String> getFieldListString()
    {
        List<String> fieldList = new List<String>();
        for(Schema.SObjectField field : getSObjectFieldList()){
            fieldList.add(field.getDescribe().getName());
        }
        return fieldList;
    }

    public Schema.SObjectType getSObjectType()
    {
        return FinServ__FinancialAccount__c.sObjectType;
    }

    public List<FinServ__FinancialAccount__c> selectById(Set<ID> idSet)
    {
        return (List<FinServ__FinancialAccount__c>) selectSObjectsById(idSet);
    }

    public FinServ__FinancialAccount__c[] selectByAccount(Set<Id> accountIds)
    {
        return selectByAccount(accountIds, false);
    }

    public FinServ__FinancialAccount__c[] selectByAccount(Set<Id> accountIds, Boolean isCommercial)
    {
        assertIsAccessible();
        String query = String.format(
                'select {0} ' +
                    'from {1} ' +
                    'where FinServ__FinancialAccount__c.FinServ__PrimaryOwner__c in {2} ' +
                    'AND IsCommercial__c = {3}',
                new List<String> {
                    String.join(getFieldListString(), ', '),
                    getSObjectName(),
                    set2soqlInClause(accountIds),
                    String.valueOf(isCommercial)
                }
            );
        System.debug('query: ' + query);
        return (List<FinServ__FinancialAccount__c>) Database.query(query);
    }

    private String set2soqlInClause(Set<Id> idSet)
    {
        if ( idSet == null || idSet.isEmpty() ) return '';
        List<Id> idList = new List<Id>(idSet);
        return '(\'' + String.join(idList, '\',\'') + '\')';
    }
    /*
     * For more examples see https://github.com/financialforcedev/fflib-apex-common-samplecode
     *
    public List<FinServ__FinancialAccount__c> selectBySomethingElse(List<String> somethings)
    {
        assertIsAccessible();
        return (List<FinServ__FinancialAccount__c>) Database.query(
                String.format(
                'select {0}, ' +
                  'from {1} ' +
                  'where Something__c in :somethings ' +
                  'order by {2}',
                new List<String> {
                    getFieldListString(),
                    getSObjectName(),
                    getOrderBy() } ) );
    }
     */
}