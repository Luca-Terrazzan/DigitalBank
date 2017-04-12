public with sharing class DataGenerator {
    private static DataGenerator instance = null;

    private Account[] individuals;
	private Account[] households;
    private FinServ__FinancialAccount__c[] finAccounts;
    private Contact[] contacts;
    private Id individualRT;
    private User[] salesAssociates;


    /**
     * Singleton
     */
    private DataGenerator() {
        individuals = new Account[]{};
        households = new Account[]{};
        finAccounts = new FinServ__FinancialAccount__c[]{};
        contacts = new Contact[]{};
        salesAssociates = [SELECT Id FROM User WHERE UserRole.Name = 'Sales Associate'];

        individualRT = [SELECT Id FROM RecordType
            WHERE SObjectType = 'Account' AND DeveloperName = 'IndustriesIndividual'].Id;
	}
    public static DataGenerator getInstance() {
        if (instance == null) instance = new DataGenerator();
        return instance;
    }

    public void commitWork() {
        insert this.individuals;
    }

    public DataGenerator createIndividuals(Integer n) {
        for(Integer i = 0; i < n; i++) {
            this.individuals.add(createIndividual());
        }
        return this;
    }
    private Account createIndividual() {
        String firstname = randomPick(CustomConstants.names);
        String lastname = randomPick(CustomConstants.last_names);
        return new Account(
            Mock__c = true,
            RecordTypeId = individualRT,
            Name = firstname + ' ' + lastname,
            Account_Owner_Retail__c = randomPickSObject(salesAssociates).Id,
            Account_Owner_Wealth__c = randomPickSObject(salesAssociates).Id,
            Account_Owner_Commercial__c = randomPickSObject(salesAssociates).Id,
            FinServ__PersonalInterests__c = randomPick(CustomConstants.interests),
            FinServ__FinancialInterests__c = randomPick(CustomConstants.financial_interests),
            Profitability__c = randomPick(CustomConstants.profitability),
            Customer_Tier__c = randomPick(CustomConstants.tier),
            Phone_Personal__c = randomPick(CustomConstants.phones),
            Phone = randomPick(CustomConstants.phones),
            Work_Phone__c = randomPick(CustomConstants.phones),
            Marketing_Segment_Retail__c = randomPick(CustomConstants.marketing_segment_retail),
            Marketing_Segment_wealth__c = randomPick(CustomConstants.marketing_segment_wealth),
            Marketing_Segment_commercial__c = randomPick(CustomConstants.marketing_segment_commercial),
            Email_Personal__c = firstname + '.' + lastname + '@digitalbank.com',
            Email_Work__c = firstname + '.' + lastname + '@company.com',
            Social_Media_Profile__c = 'facebook.com/' + lastname,
            Linkedin_Profile__c = 'linkedin.com/' + lastname,
            FinServ__InvestmentObjectives__c = randomPick(CustomConstants.investment_objectives),
            FinServ__RiskTolerance__c = randomPick(CustomConstants.risk_tolerance),
            Retail_Branch__c = randomPick(CustomConstants.branch_retail),
            Wealth_Branch__c = randomPick(CustomConstants.branch_Wealth),
            Commercial_Branch__c = randomPick(CustomConstants.branch_commercial),
            FinServ__InvestmentExperience__c = randomPick(CustomConstants.investment_experience),
            FinServ__ServiceModel__c = randomPick(CustomConstants.service_model),
            FinServ__TimeHorizon__c = randomPick(CustomConstants.time_horizon),
            Industry = randomPick(CustomConstants.industry),
            Website = 'www.DigitalBank.com'
        );
    }

    private String randomPick(String[] stringlist) {
        return stringlist[(Integer) Math.floor(Math.random()*stringlist.size())];
    }
    private SObject randomPickSObject(SObject[] stringlist) {
        return stringlist[(Integer) Math.floor(Math.random()*stringlist.size())];
    }
}