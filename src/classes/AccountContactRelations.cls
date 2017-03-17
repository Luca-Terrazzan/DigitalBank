/**
 * See https://github.com/financialforcedev/fflib-apex-common for more info
 *
 * Install library via
 *   https://githubsfdeploy.herokuapp.com/app/githubdeploy/financialforcedev/fflib-apex-common
 */

/**
 * Encapsulates all behaviour logic relating to the AccountContactRelation object
 *
 * For more guidelines and details see
 *   https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Domain_Layer
 *
 **/
public class AccountContactRelations extends fflib_SObjectDomain
{
	public AccountContactRelations(List<AccountContactRelation> records)
	{
		super(records);
	}

	public override void onValidate()
	{
		for(AccountContactRelation record : (List<AccountContactRelation>) Records)
		{
		}
	}

	public override void onValidate(Map<Id,SObject> existingRecords)
	{
		for(AccountContactRelation record : (List<AccountContactRelation>) Records)
		{
		}
	}

	public override void onBeforeInsert()
	{
        AccountContactRelationship__c[] shadows = new AccountContactRelationship__c[]{};
		for(AccountContactRelation record : (List<AccountContactRelation>) Records)
		{
            System.debug('ECCCHICEEEEEEE');
		}
	}

	public void someMethod()
	{
		for(AccountContactRelation record : (List<AccountContactRelation>) Records)
		{
		}
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new AccountContactRelations(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return new AccountContactRelations(sObjectList);
		}
	}
}