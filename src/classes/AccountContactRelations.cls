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

    /**
     * Create shadows junction objects to couple with the standard object
     * DGTB_AccountContactReference__c keeps the fake lookup to the original one
     */
    public override void onAfterInsert()
    {
        AccountContactRelationship__c[] shadows = new AccountContactRelationship__c[]{};
        for(AccountContactRelation record : (List<AccountContactRelation>) Records)
        {
            shadows.add(new AccountContactRelationship__c(
                Account__c        = record.AccountId,
                IsActive__c       = record.IsActive,
                Contact__c        = record.ContactId,
                IsDirect__c       = record.IsDirect,
                EndDate__c        = record.EndDate,
                Roles__c          = record.Roles,
                IncludeInGroup__c = record.FinServ__IncludeInGroup__c,
                PrimaryGroup__c   = record.FinServ__PrimaryGroup__c,
                Primary__c        = record.FinServ__Primary__c,
                Rollups__c        = record.FinServ__Rollups__c,
                SourceSystemId__c = record.FinServ__SourceSystemId__c,
                DGTB_AccountContactReference__c = record.Id
                )
            );
        }
        insert shadows;
    }

    /**
     * TODO: manage shadows updating (and deletion)
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords)
    {

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
