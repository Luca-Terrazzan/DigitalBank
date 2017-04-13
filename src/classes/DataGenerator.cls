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
        insert this.finAccounts;
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
            Party_ID__c = firstname + '-' + lastname + String.valueOf(Math.random()),
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
            Branch__c = randomPick(CustomConstants.branches),
            FinServ__InvestmentExperience__c = randomPick(CustomConstants.investment_experience),
            FinServ__ServiceModel__c = randomPick(CustomConstants.service_model),
            FinServ__TimeHorizon__c = randomPick(CustomConstants.time_horizon),
            Industry = randomPick(CustomConstants.industry),
            Website = 'www.DigitalBank.com'
        );
    }

    public DataGenerator randomizeFinancialAccounts(Integer retails, Integer wealths, Integer commercials) {
        for(Integer i = retails; i > 0; i--) {
            Account rand = (Account)randomPickSObject(individuals);
            finAccounts.add(createFinancialAccount('Retail', rand.Party_ID__c, rand.Name, null, null));
        }
        for(Integer i = wealths; i > 0; i--) {
            Account rand = (Account)randomPickSObject(individuals);
            finAccounts.add(createFinancialAccount('Wealth', rand.Party_ID__c, rand.Name, null, null));
        }
        for(Integer i = commercials; i > 0; i--) {
            Account rand = (Account)randomPickSObject(individuals);
            Account comm_rand = (Account)randomPickSObject(individuals);
            finAccounts.add(createFinancialAccount('Commercial', rand.Party_ID__c, rand.Name, comm_rand.Party_ID__c, comm_rand.Name));
        }
        return this;
    }

    private FinServ__FinancialAccount__c createFinancialAccount(String cat, String ownerExtId, String ownerName, String comm_ownerExtId, String comm_ownerName) {
        // only retail and wealth for now!
        Account owner = new Account(Party_Id__c = ownerExtId);
        Account comm_owner = String.isNotBlank(comm_ownerExtId) ? new Account(Party_Id__c = comm_ownerExtId) : null;
        String category = String.isBlank(cat) ? randomPick(CustomConstants.categories) : cat;
        String faType = category == 'Retail' ? randomPick(CustomConstants.retail_type) :
            category == 'Wealth' ? randomPick(CustomConstants.wealth_type) : randomPick(CustomConstants.commercial_type);
        return new FinServ__FinancialAccount__c(
            Name = ownerName + ' ' + faType,
            Mock__c = true,
            FinServ__PrimaryOwner__r =  owner,
            FinServ__JointOwner__r = comm_owner,
            Category__c = category,
            FinServ__FinancialAccountType__c = faType,
            FinServ__Status__c = randomPick(CustomConstants.fa_status),
            FinServ__Ownership__c = String.isBlank(comm_ownerExtId) ? 'Individual' : 'Joint',
            FinServ__FinancialAccountSource__c = randomPick(CustomConstants.fa_source),
            FinServ__Balance__c = category == 'Retail' ? Math.random() * 100000 : Math.random() * 1000000 + 100000,
            FinServ__OpenDate__c = System.today() - (Integer) (Math.random() * 500) - 20,
            FinServ__PaperlessDelivery__c = Math.random() >= 0.5 ? true : false,
            Branch__c = randomPick(CustomConstants.branches)
        );
    }

    private String randomPick(String[] stringlist) {
        return stringlist[(Integer) Math.floor(Math.random()*stringlist.size())];
    }
    private SObject randomPickSObject(SObject[] stringlist) {
        return stringlist[(Integer) Math.floor(Math.random()*stringlist.size())];
    }
}