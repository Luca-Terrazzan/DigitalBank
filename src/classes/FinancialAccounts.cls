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

    private List<FinServ__FinancialAccount__c> sumRecords = new List<FinServ__FinancialAccount__c>();
    private List<FinServ__FinancialAccount__c> oldSumRecords = new List<FinServ__FinancialAccount__c>();

    public FinancialAccounts(List<FinServ__FinancialAccount__c> records)
    {
        super(records);
    }

    public override void onValidate()
    {
        sumRecords = [SELECT Category__c, FinServ__Balance__c, FinServ__PrimaryOwner__r.Retail_Financial_Accounts__c,
                FinServ__PrimaryOwner__r.Wealth_AUM__c, FinServ__PrimaryOwner__r.Commercial_Financial_Accounts__c
            FROM FinServ__FinancialAccount__c
            WHERE Id IN: System.Trigger.newMap.keySet()];
        if (!System.Trigger.isInsert) {
            oldSumRecords = [SELECT Category__c, FinServ__Balance__c, FinServ__PrimaryOwner__r.Retail_Financial_Accounts__c,
                    FinServ__PrimaryOwner__r.Wealth_AUM__c, FinServ__PrimaryOwner__r.Commercial_Financial_Accounts__c
                FROM FinServ__FinancialAccount__c
                WHERE Id IN: System.Trigger.oldMap.keySet()];
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
        List<Account> primaryOwners = new List<Account>();
        for(FinServ__FinancialAccount__c record : sumRecords)
        {
            Account toAdd = new Account(Id = record.FinServ__PrimaryOwner__c);
            if(record.FinServ__Balance__c == null) {
                record.FinServ__Balance__c = 0;
            }
            if (record.Category__c == 'Retail') {
                toAdd.Retail_Financial_Accounts__c = record.FinServ__PrimaryOwner__r.Retail_Financial_Accounts__c + record.FinServ__Balance__c;
            }
            if (record.Category__c == 'Wealth') {
                toAdd.Wealth_AUM__c = record.FinServ__PrimaryOwner__r.Wealth_AUM__c + record.FinServ__Balance__c;
            }
            if (record.Category__c == 'Commercial') {
                toAdd.Commercial_Financial_Accounts__c = record.FinServ__PrimaryOwner__r.Commercial_Financial_Accounts__c + record.FinServ__Balance__c;
            }
            primaryOwners.add(toAdd);
        }
        update primaryOwners;
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords)
    {
        List<Account> primaryOwners = new List<Account>();
        for(FinServ__FinancialAccount__c record : oldSumRecords)
        {
            Account toAdd = new Account(Id = ((FinServ__FinancialAccount__c) existingRecords.get(record.Id)).FinServ__PrimaryOwner__c);
            if(record.FinServ__Balance__c == null) {
                record.FinServ__Balance__c = 0;
            }
            if (record.Category__c == 'Retail') {
                toAdd.Retail_Financial_Accounts__c = record.FinServ__PrimaryOwner__r.Retail_Financial_Accounts__c - record.FinServ__Balance__c;
            }
            if (record.Category__c == 'Wealth') {
                toAdd.Wealth_AUM__c = record.FinServ__PrimaryOwner__r.Wealth_AUM__c - record.FinServ__Balance__c;
            }
            if (record.Category__c == 'Commercial') {
                toAdd.Commercial_Financial_Accounts__c = record.FinServ__PrimaryOwner__r.Commercial_Financial_Accounts__c - record.FinServ__Balance__c;
            }
            primaryOwners.add(toAdd);
        }
        update primaryOwners;
        primaryOwners.clear();

        for(FinServ__FinancialAccount__c record : sumRecords)
        {
            Account toAdd = new Account(Id = record.FinServ__PrimaryOwner__c);
            if(record.FinServ__Balance__c == null) {
                record.FinServ__Balance__c = 0;
            }
            if (record.Category__c == 'Retail') {
                toAdd.Retail_Financial_Accounts__c = record.FinServ__PrimaryOwner__r.Retail_Financial_Accounts__c + record.FinServ__Balance__c;
            }
            if (record.Category__c == 'Wealth') {
                toAdd.Wealth_AUM__c = record.FinServ__PrimaryOwner__r.Wealth_AUM__c + record.FinServ__Balance__c;
            }
            if (record.Category__c == 'Commercial') {
                toAdd.Commercial_Financial_Accounts__c = record.FinServ__PrimaryOwner__r.Commercial_Financial_Accounts__c + record.FinServ__Balance__c;
            }
            primaryOwners.add(toAdd);
        }
        update primaryOwners;
    }

    public override void onAfterDelete()
    {
        List<Account> primaryOwners = new List<Account>();
        for(FinServ__FinancialAccount__c record : sumRecords)
        {
            Account toAdd = new Account(Id = record.FinServ__PrimaryOwner__c);
            if(record.FinServ__Balance__c == null) {
                record.FinServ__Balance__c = 0;
            }
            if (record.Category__c == 'Retail') {
                toAdd.Retail_Financial_Accounts__c = record.FinServ__PrimaryOwner__r.Retail_Financial_Accounts__c - record.FinServ__Balance__c;
            }
            if (record.Category__c == 'Wealth') {
                toAdd.Wealth_AUM__c = record.FinServ__PrimaryOwner__r.Wealth_AUM__c - record.FinServ__Balance__c;
            }
            if (record.Category__c == 'Commercial') {
                toAdd.Commercial_Financial_Accounts__c = record.FinServ__PrimaryOwner__r.Commercial_Financial_Accounts__c - record.FinServ__Balance__c;
            }
            primaryOwners.add(toAdd);
        }
        update primaryOwners;
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