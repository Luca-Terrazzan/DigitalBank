/**
 * See https://github.com/financialforcedev/fflib-apex-common for more info
 *
 * Install library via
 *   https://githubsfdeploy.herokuapp.com/app/githubdeploy/financialforcedev/fflib-apex-common
 */

/**
 * Encapsulates all behaviour logic relating to the FinServ__FinancialAccountRole__c object.
 * Manages the custom roll-up to keep balances updated in the different 720 overviews
 *
 * For more guidelines and details see
 *   https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Domain_Layer
 *
 **/
public class FinancialAccountRoles extends fflib_SObjectDomain
{
    private final Set<String> ROLL_UP_ROLES = new Set<String>();
    private Map<Id, Account> accountsMap = new Map<Id, Account>();
    private Map<Id, Account> oldAccountsMap = new Map<Id, Account>();


    public FinancialAccountRoles(List<FinServ__FinancialAccountRole__c> records)
    {
        super(records);
        for(RollUpRoles__mdt role: [SELECT MasterLabel FROM RollUpRoles__mdt LIMIT 500]) {
            ROLL_UP_ROLES.add(role.MasterLabel);
        }
    }

    public override void onValidate() {}

    public override void onValidate(Map<Id,SObject> existingRecords) {}

    public override void onAfterInsert()
    {
        // Custom 720 roll-up
        FinServ__FinancialAccountRole__c[] roles = filterRolesByCategory(Records, 'Commercial');
        accountsMap = this.getAccountsMap(roles);
        rollUp((FinServ__FinancialAccountRole__c[]) roles, false);
        update accountsMap.values();
        /////////////////////
    }
    public override void onAfterUpdate(Map<Id, SObject> existingRecords)
    {
        // Custom 720 roll-up
        FinServ__FinancialAccountRole__c[] newRoles = filterRolesByCategory(Records, 'Commercial');
        FinServ__FinancialAccountRole__c[] oldRoles = filterRolesByCategory(existingRecords.values(), 'Commercial');
        FinServ__FinancialAccountRole__c[] roles    = newRoles.clone();
        roles.addAll(oldRoles);
        accountsMap = this.getAccountsMap(roles);
        rollUp(newRoles, false);
        rollUp(oldRoles, true);
        update accountsMap.values();
        /////////////////////
    }
    public override void onAfterDelete()
    {
        // Custom 720 roll-up
        FinServ__FinancialAccountRole__c[] roles = filterRolesByCategory(Records, 'Commercial');
        accountsMap = this.getAccountsMap(roles);
        rollUp((FinServ__FinancialAccountRole__c[]) roles, true);
        update accountsMap.values();
        /////////////////////
    }

    private Map<Id, Account> getAccountsMap()
    {
        return this.getAccountsMap(null);
    }
    private Map<Id, Account> getAccountsMap(FinServ__FinancialAccountRole__c[] loopRecords)
    {
        Set<Id> accounts = new Set<Id>();
        for(FinServ__FinancialAccountRole__c fa: loopRecords) {
            accounts.add(fa.Finserv__RelatedAccount__c);
        }
        Map<Id, Account> accountsMap = new Map<Id, Account>(
            [SELECT CommercialBalance__c, CommercialLoan__c
                FROM Account
                WHERE Id IN: accounts FOR UPDATE] // FOR UPDATE!
        );
        return accountsMap;
    }

    /**
     * Calculates the 720 roll-up
     * @param      roles     FinancialAccountRole[]
     * @param      subtract  If true, the sum is subtracted to the roll-up
     */
    private void rollUp(FinServ__FinancialAccountRole__c[] roles, Boolean subtract) {
        for(FinServ__FinancialAccountRole__c far: roles) {
            Account accToUpdate = accountsMap.get(far.Finserv__RelatedAccount__c);
            if (String.isBlank(far.FinancialAccountCategory__c)) continue;
            String suffix = far.IsLoan__c ? 'Loan__c' : 'Balance__c';
            Decimal sum = (Decimal) accToUpdate.get(far.FinancialAccountCategory__c + suffix);
            if (sum == null) sum = 0;
            if (!subtract) sum += far.Balance__c != null ? far.Balance__c : 0.0;
            else           sum -= far.Balance__c != null ? far.Balance__c : 0.0;
            accToUpdate.put(far.FinancialAccountCategory__c + suffix, sum);
        }
    }

    /**
     * Helper method used to filter current context records (in triggers) for certain categories
     * @param      roles     The financialAccountRole[]
     * @param      category  The category
     */
    private FinServ__FinancialAccountRole__c[] filterRolesByCategory(FinServ__FinancialAccountRole__c[] roles, String category) {
        FinServ__FinancialAccountRole__c[] filteredRecords = new FinServ__FinancialAccountRole__c[]{};
        for(FinServ__FinancialAccountRole__c record : roles) {
            if (!record.IslinkingPrimaryOwner__c &&
                    record.FinancialAccountCategory__c == category &&
                    ROLL_UP_ROLES.contains(record.FinServ__Role__c)) {
                filteredRecords.add(record);
            }
        }
        return filteredRecords;
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