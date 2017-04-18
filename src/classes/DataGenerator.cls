public with sharing class DataGenerator {
    private static DataGenerator instance = null;
    private static Integer randomizer = 0;

    private Account[] individuals;
    private Account[] households;

	private Opportunity[] opportunities;
    private PricebookEntry[] prices;
    private OpportunityLineItem[] olis;

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
        opportunities = new Opportunity[]{};
        salesAssociates = [SELECT Id FROM User WHERE UserRole.Name = 'Sales Associate'];
        prices = [SELECT Name, Pricebook2Id, UnitPrice, Product2.Name, Category__c FROM PricebookEntry WHERE IsActive = true];
        olis = new OpportunityLineItem[]{};

        individualRT = [SELECT Id FROM RecordType
            WHERE SObjectType = 'Account' AND DeveloperName = 'IndustriesIndividual'].Id;
	}
    public static DataGenerator getInstance() {
        if (instance == null) instance = new DataGenerator();
        return instance;
    }

    public DataGenerator commitWork() {
        insert this.individuals;
        insert this.finAccounts;
        insert this.opportunities;
        insert this.olis;
        return this;
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

    public DataGenerator createOpportunities(Integer opps) {
        Account[] individualsPool = individuals.isEmpty() ? [SELECT Id, Name
                FROM Account WHERE RecordType.DeveloperName = 'IndustriesIndividual' LIMIT : opps] : individuals;
        for(Integer i = opps; i > 0; i--) {
            Account rand = (Account)randomPickSObject(individualsPool);
            Opportunity opp = createOpportunity();
            opp.AccountId = rand.Id;
            opp.Name += ' ' + rand.Name + ' Opportunity';
            opportunities.add(opp);
        }
        System.debug(opportunities);
        return this;
    }
    public DataGenerator closeOpportunities(Decimal chance) {
        for(Opportunity opp: opportunities) {
            if (Math.random() <= chance) opp.StageName = 'Closed Won';
        }
        update opportunities;
        return this;
    }
    private Opportunity createOpportunity() {
        PricebookEntry randPrice = (PricebookEntry) randomPickSObject(prices);
        String randomId = randPrice.Id + String.valueOf(randomizer);
        randomizer++;
        OpportunityLineItem oli = new OpportunityLineItem(
            UnitPrice = randPrice.UnitPrice,
            Quantity = 1,

            PricebookEntryId = randPrice.Id
        );
        Opportunity opp = new Opportunity(
            Mock__c = true,
            Name = randPrice.Name,
            ExternalId__c = randomId,
            Branch__c = randomPick(CustomConstants.branches),
            Category__c = String.isEmpty(randPrice.Category__c) ? 'Retail' : randPrice.Category__c,
            StageName = randomPick(CustomConstants.opp_stages),
            CloseDate = System.today() + 15 + (Integer) Math.random() * 100,
            Pricebook2Id = randPrice.Pricebook2Id,
            Amount = Math.random()
        );
        oli.Opportunity = new Opportunity(ExternalId__c = randomId);
        olis.add(oli);
        return opp;
    }

    private String randomPick(String[] stringlist) {
        return stringlist[(Integer) Math.floor(Math.random()*stringlist.size())];
    }
    private SObject randomPickSObject(SObject[] stringlist) {
        if (stringlist == null || stringlist.isEmpty()) return null;
        return stringlist[(Integer) Math.floor(Math.random()*stringlist.size())];
    }
}