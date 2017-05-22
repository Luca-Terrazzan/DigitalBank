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

    /**
     * Create shadows junction objects to couple with the standard object
     * DGTB_AccountContactReference__c keeps the fake lookup to the original one
     */
    public override void onAfterInsert()
    {
        AccountContactRelationship__c[] shadows = new AccountContactRelationship__c[]{};
        for(AccountContactRelation acr : (List<AccountContactRelation>) records)
        {
            shadows.add(copyJunction(acr));
        }
        insert shadows;
    }

    /**
     * Update shadows junction objects to couple with the standard object
     * DGTB_AccountContactReference__c keeps the fake lookup to the original one
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords)
    {
        AccountContactRelationship__c[] shadows = new AccountContactRelationship__c[]{};
        for(AccountContactRelation acr: (AccountContactRelation[]) existingRecords.values()) {
            shadows.add(copyJunction(acr));
        }
        //update shadows;
    }

    /**
     * TODO
     */
    public override void onAfterDelete()
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

    /**
     * Copy an AccountContactRelation record into a shadow object
     * @param      acr   The AccountContactRelation record
     * @return     AccountContactRelationship__c record
     */
    private AccountContactRelationship__c copyJunction(AccountContactRelation acr)
    {
        return new AccountContactRelationship__c(
            Account__c        = acr.AccountId,
            IsActive__c       = acr.IsActive,
            Contact__c        = acr.ContactId,
            IsDirect__c       = acr.IsDirect,
            EndDate__c        = acr.EndDate,
            Roles__c          = acr.Roles,
            IncludeInGroup__c = acr.FinServ__IncludeInGroup__c,
            PrimaryGroup__c   = acr.FinServ__PrimaryGroup__c,
            Primary__c        = acr.FinServ__Primary__c,
            Rollups__c        = acr.FinServ__Rollups__c,
            SourceSystemId__c = acr.FinServ__SourceSystemId__c,
            DGTB_AccountContactReference__c = acr.Id
        );
    }
}