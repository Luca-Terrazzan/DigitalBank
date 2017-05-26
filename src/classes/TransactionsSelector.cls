/**
 * See https://github.com/financialforcedev/fflib-apex-common for more info
 *
 * Install library via
 *   https://githubsfdeploy.herokuapp.com/app/githubdeploy/financialforcedev/fflib-apex-common
 */

/**
 * Class encapsulates query logic for Opportunity
 *
 * https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Selector_Layer
 **/
 public class TransactionsSelector extends fflib_SObjectSelector
{

    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
            Transaction__c.Id,
            Transaction__c.Name,
            Transaction__c.Amount__c,
            Transaction__c.transaction_date__c,
            Transaction__c.account_number__c,
            Transaction__c.Account__c,
            Transaction__c.Category__c,
            Transaction__c.Status_Img__c,
            Transaction__c.Channel__c,
            Transaction__c.Description__c
        };
    }
    /**
     * Gets the s object field list.
     * @return     The s object field list.
     */
    public List<String> getFieldListString()
    {
        List<String> fieldList = new List<String>{
            'account_number__r.Name'
        };
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
        return Transaction__c.sObjectType;
    }

    /**
     * Default selection of items by id
     * @param      idSet  The identifier set
     * @return     List of financial accounts
     */
    public List<Transaction__c> selectById(Set<ID> idSet)
    {
        if (idSet == null || idSet.isEmpty()) return new Transaction__c[]{};
        return (List<Transaction__c>) selectSObjectsById(idSet);
    }

    public Transaction__c[] selectByAccount(Set<Id> accountIds)
    {
        return selectByAccount(accountIds, 'retail');
    }

    /**
     * Select all financial accounts primarily related to a list of accounts
     * @param      accountIds  The account identifiers
     * @return     List of financial accounts
     */
    public Transaction__c[] selectByAccount(Set<Id> accountIds, String category)
    {
        assertIsAccessible();
        String query = 'select {0} ' +
            'from {1} ' +
            'where Account__c IN: accountIds ';
        if(!String.isBlank(category)) {
            query += 'AND Category__c =: category';
        }
        query += ' ORDER BY transaction_date__c DESC';
        query = String.format(
            query,
            new List<String> {
                String.join(getFieldListString(), ', '),
                getSObjectName()
            }
            );
        return (List<Transaction__c>) Database.query(String.escapeSingleQuotes(query));
    }

}