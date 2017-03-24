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
    private FinServ__FinancialAccountRole__c[] filteredRecords;

    public FinancialAccountRoles(List<FinServ__FinancialAccountRole__c> records)
    {
        super(records);
        this.filteredRecords = new FinServ__FinancialAccountRole__c[]{};
    }

    public override void onValidate()
    {
        for(FinServ__FinancialAccountRole__c record : (List<FinServ__FinancialAccountRole__c>) Records)
        {
            // no need to check for the financial account since it is a master detail
            if (record.Finserv__RelatedAccount__c != null) {
                filteredRecords.add(record);
            }
        }
    }

    public override void onValidate(Map<Id,SObject> existingRecords)
    {
        for(FinServ__FinancialAccountRole__c record : (List<FinServ__FinancialAccountRole__c>) Records)
        {
            // no need to check for the financial account since it is a master detail
            if (record.Finserv__RelatedAccount__c != null) {
                filteredRecords.add(record);
            }
        }
    }

    public override void onBeforeInsert()
    {
        for(FinServ__FinancialAccountRole__c record : (List<FinServ__FinancialAccountRole__c>) Records)
        {
            // no need to check for the financial account since it is a master detail
            if (record.Finserv__RelatedAccount__c != null) {
                filteredRecords.add(record);
            }
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