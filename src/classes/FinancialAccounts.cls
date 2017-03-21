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
    {}

    public override void onValidate(Map<Id,SObject> existingRecords)
    {}

    public override void onAfterInsert()
    {
        Map<Id, Account> accountsMap = this.getAccountsMap();
        for(FinServ__FinancialAccount__c fa: (FinServ__FinancialAccount__c[]) Records) {
            Account accToUpdate = accountsMap.get(fa.FinServ__PrimaryOwner__c);
            Decimal sum = (Decimal) accToUpdate.get(fa.Category__c + 'Balance__c');
            sum += fa.FinServ__Balance__c;
            accToUpdate.put(fa.Category__c + 'Balance__c', sum);
        }
        update accountsMap.values();
    }

    /*public override void onAfterUpdate(Map<Id,SObject> existingRecords)
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
    }*/

    public override void onAfterDelete()
    {
        Map<Id, Account> accountsMap = this.getAccountsMap();
        for(FinServ__FinancialAccount__c fa: (FinServ__FinancialAccount__c[]) Records) {
            Account accToUpdate = accountsMap.get(fa.FinServ__PrimaryOwner__c);
            Decimal sum = (Decimal) accToUpdate.get(fa.Category__c + 'Balance__c');
            sum -= fa.FinServ__Balance__c;
            accToUpdate.put(fa.Category__c + 'Balance__c', sum);
        }
        update accountsMap.values();
    }

    public Map<Id, Account> getAccountsMap()
    {
        Set<Id> accounts = new Set<Id>();
        for(FinServ__FinancialAccount__c fa: (FinServ__FinancialAccount__c[]) Records) {
            accounts.add(fa.FinServ__PrimaryOwner__c);
        }
        Map<Id, Account> accountMap = new Map<Id, Account>(
            [SELECT RetailBalance__c, WealthBalance__c, CommercialBalance__c
                FROM Account
                WHERE Id IN: accounts]
        );
        return accountMap;
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