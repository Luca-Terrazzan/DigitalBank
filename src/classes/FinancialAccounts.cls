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
    private Map<Id, Account> accountsMap = new Map<Id, Account>();
    private Map<Id, Account> oldAccountsMap = new Map<Id, Account>();

    public FinancialAccounts(List<FinServ__FinancialAccount__c> records)
    {
        super(records);
    }

    public override void onValidate()
    {
        accountsMap = this.getAccountsMap(null);
    }

    public override void onValidate(Map<Id,SObject> existingRecords)
    {
        accountsMap = this.getAccountsMap(null);
        //oldAccountsMap = this.getAccountsMap
    }

    public override void onAfterInsert()
    {
        for(FinServ__FinancialAccount__c fa: (FinServ__FinancialAccount__c[]) Records) {
            Account accToUpdate = accountsMap.get(fa.FinServ__PrimaryOwner__c);
            Decimal sum = (Decimal) accToUpdate.get(fa.Category__c + 'Balance__c');
            sum += fa.FinServ__Balance__c;
            accToUpdate.put(fa.Category__c + 'Balance__c', sum);
        }
        update accountsMap.values();
    }

    public override void onAfterUpdate(Map<Id,SObject> existingRecords)
    {
        Map<Id, Account> accountsMap = this.getAccountsMap(existingRecords.values());
        for(FinServ__FinancialAccount__c fa: (FinServ__FinancialAccount__c[]) Records) {
            Account accToUpdate = accountsMap.get(fa.FinServ__PrimaryOwner__c);
            Decimal sum = (Decimal) accToUpdate.get(fa.Category__c + 'Balance__c');
            sum += fa.FinServ__Balance__c;
            accToUpdate.put(fa.Category__c + 'Balance__c', sum);
        }
        update accountsMap.values();
    }

    public override void onAfterDelete()
    {
        for(FinServ__FinancialAccount__c fa: (FinServ__FinancialAccount__c[]) Records) {
            Account accToUpdate = accountsMap.get(fa.FinServ__PrimaryOwner__c);
            Decimal sum = (Decimal) accToUpdate.get(fa.Category__c + 'Balance__c');
            sum -= fa.FinServ__Balance__c;
            accToUpdate.put(fa.Category__c + 'Balance__c', sum);
        }
        update accountsMap.values();
    }

    private Map<Id, Account> getAccountsMap(FinServ__FinancialAccount__c[] loopRecords)
    {
        Set<Id> accounts = new Set<Id>();
        if (loopRecords == null || loopRecords.isEmpty()) loopRecords = Records;
        for(FinServ__FinancialAccount__c fa: loopRecords) {
            accounts.add(fa.FinServ__PrimaryOwner__c);
        }
        Map<Id, Account> accountsMap = new Map<Id, Account>(
            [SELECT RetailBalance__c, WealthBalance__c, CommercialBalance__c
                FROM Account
                WHERE Id IN: accounts]
        );
        return accountsMap;
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