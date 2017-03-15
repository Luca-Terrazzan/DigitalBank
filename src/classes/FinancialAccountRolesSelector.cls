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

	/*
	 * For more examples see https://github.com/financialforcedev/fflib-apex-common-samplecode
	 *
	public List<FinServ__FinancialAccountRole__c> selectBySomethingElse(List<String> somethings)
	{
		assertIsAccessible();
		return (List<FinServ__FinancialAccountRole__c>) Database.query(
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