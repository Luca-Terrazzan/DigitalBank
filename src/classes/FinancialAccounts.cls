/**
 * See https://github.com/financialforcedev/fflib-apex-common for more info
 *
 * Install library via
 *   https://githubsfdeploy.herokuapp.com/app/githubdeploy/financialforcedev/fflib-apex-common
 */

/**
 * Encapsulates all behaviour logic relating to the FinServ__FinancialAccount__c object
 *
 * For more guidelines and details see
 *   https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Domain_Layer
 *
 **/
public class FinancialAccounts extends fflib_SObjectDomain
{
    public FinancialAccounts(List<FinServ__FinancialAccount__c> records)
    {
        super(records);
    }

    public override void onValidate()
    {
        for(FinServ__FinancialAccount__c record : (List<FinServ__FinancialAccount__c>) Records)
        {
        }
    }

    public override void onValidate(Map<Id,SObject> existingRecords)
    {
        for(FinServ__FinancialAccount__c record : (List<FinServ__FinancialAccount__c>) Records)
        {
        }
    }

    public override void onAfterInsert()
    {
        for(FinServ__FinancialAccount__c record : (List<FinServ__FinancialAccount__c>) Records)
        {
        }
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords)
    {

    }

    public override void onAfterDelete()
    {

    }

    public void someMethod()
    {
        for(FinServ__FinancialAccount__c record : (List<FinServ__FinancialAccount__c>) Records)
        {
        }
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable2
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new FinancialAccounts(sObjectList);
        }

        public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
        {
            return new FinancialAccounts(sObjectList);
        }
    }
}