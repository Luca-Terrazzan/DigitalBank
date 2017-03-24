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
    private Map<Id, Account> accountsMap = new Map<Id, Account>();
    private Map<Id, Account> oldAccountsMap = new Map<Id, Account>();


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
            if (record.Finserv__RelatedAccount__c != null && !record.IslinkingPrimaryOwner__c) {
                filteredRecords.add(record);
            }
        }
    }

    public override void onValidate(Map<Id,SObject> existingRecords)
    {
        for(FinServ__FinancialAccountRole__c record : (List<FinServ__FinancialAccountRole__c>) Records)
        {
            // no need to check for the financial account since it is a master detail
            if (record.Finserv__RelatedAccount__c != null && !record.IslinkingPrimaryOwner__c) {
                filteredRecords.add(record);
            }
        }
    }

    public override void onAfterInsert()
    {

    }

    private Map<Id, Account> getAccountsMap()
    {
        return this.getAccountsMap(null);
    }

    private Map<Id, Account> getAccountsMap(FinServ__FinancialAccountRole__c[] loopRecords)
    {
        Set<Id> accounts = new Set<Id>();
        if (loopRecords == null || loopRecords.isEmpty()) {
            loopRecords = Records;
        } else {
            loopRecords.addAll((FinServ__FinancialAccountRole__c[]) Records);
        }
        for(FinServ__FinancialAccountRole__c fa: loopRecords) {
            accounts.add(fa.Finserv__RelatedAccount__c);
        }
        Map<Id, Account> accountsMap = new Map<Id, Account>(
            [SELECT CommercialBalance__c, CommercialLoan__c
                FROM Account
                WHERE Id IN: accounts FOR UPDATE]
        );
        return accountsMap;
    }

    private void rollUp(FinServ__FinancialAccountRole__c[] roles, Boolean subtract)
    {
        for(FinServ__FinancialAccountRole__c far: roles) {
            Account accToUpdate = accountsMap.get(far.Finserv__RelatedAccount__c);
            if (String.isBlank(far.FinancialAccountCategory__c)) continue;
            String suffix = far.IsLoan__c && far.FinancialAccountCategory__c != 'Wealth' ? 'Loan__c' : 'Balance__c';
            Decimal sum = (Decimal) accToUpdate.get(far.FinancialAccountCategory__c + suffix);
            if (sum == null) sum = 0;
            if (!subtract) sum += far.Balance__c != null ? far.Balance__c : 0.0;
            else           sum -= far.Balance__c != null ? far.Balance__c : 0.0;
            accToUpdate.put(far.FinancialAccountCategory__c + suffix, sum);
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