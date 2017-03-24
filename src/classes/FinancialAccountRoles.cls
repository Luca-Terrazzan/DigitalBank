/**
 * See https://github.com/financialforcedev/fflib-apex-common for more info
 *
 * Install library via 
 *   https://githubsfdeploy.herokuapp.com/app/githubdeploy/financialforcedev/fflib-apex-common
 */

/**
 * Encapsulates all behaviour logic relating to the FinServ__FinancialAccountRole__c object
 * 
 * For more guidelines and details see 
 *   https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Domain_Layer
 *
 **/
public class FinancialAccountRoles extends fflib_SObjectDomain 
{
	public FinancialAccountRoles(List<FinServ__FinancialAccountRole__c> records) 
	{
		super(records);	
	}

	public override void onValidate()
	{
		for(FinServ__FinancialAccountRole__c record : (List<FinServ__FinancialAccountRole__c>) Records)
		{
		}
	}

	public override void onValidate(Map<Id,SObject> existingRecords)
	{
		for(FinServ__FinancialAccountRole__c record : (List<FinServ__FinancialAccountRole__c>) Records)
		{
		}
	}

	public override void onBeforeInsert()
	{
		for(FinServ__FinancialAccountRole__c record : (List<FinServ__FinancialAccountRole__c>) Records)
		{
		}
	}

	public void someMethod()
	{
		for(FinServ__FinancialAccountRole__c record : (List<FinServ__FinancialAccountRole__c>) Records)
		{
		}		
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new FinancialAccountRoles(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return new FinancialAccountRoles(sObjectList);
		}			
	}	
}