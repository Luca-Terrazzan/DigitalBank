/**
 * See https://github.com/financialforcedev/fflib-apex-common for more info
 *
 * Install library via
 *   https://githubsfdeploy.herokuapp.com/app/githubdeploy/financialforcedev/fflib-apex-common
 */

/**
 * Class encapsulates query logic for FinServ__FinancialAccountRole__c
 *
 * https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Selector_Layer
 **/
public class FinancialAccountRolesSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> {
                FinServ__FinancialAccountRole__c.Id,
                FinServ__FinancialAccountRole__c.FinServ__FinancialAccount__c
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

	public Schema.SObjectType getSObjectType()
	{
		return FinServ__FinancialAccountRole__c.sObjectType;
	}

	public List<FinServ__FinancialAccountRole__c> selectById(Set<ID> idSet)
	{
		return (List<FinServ__FinancialAccountRole__c>) selectSObjectsById(idSet);
	}

    public FinServ__FinancialAccountRole__c[] selectByAccount(Set<Id> accountIds)
    {
        return selectByAccount(accountIds, 'retail');
    }

    /**
     * Select all financial accounts primarily related to a list of accounts
     * @param      accountIds  The account identifiers
     * @return     List of financial accounts
     */
    public FinServ__FinancialAccountRole__c[] selectByAccount(Set<Id> accountIds, String category)
    {
        assertIsAccessible();
        String query = String.format(
            'SELECT {0} ' +
            'FROM {1} ' +
            'WHERE FinServ__FinancialAccount__r.FinServ__PrimaryOwner__c NOT IN: accountIds ' +
            'AND FinServ__FinancialAccount__r.Category__c =: category ' +
            'AND FinServ__RelatedAccount__c IN : accountIds ' +
            'AND FinServ__Active__c = true',
            new List<String> {
                String.join(getFieldListString(), ', '),
                getSObjectName()
            }
        );
        System.debug('query: ' + query);
        return (List<FinServ__FinancialAccountRole__c>) Database.query(query);
    }

}