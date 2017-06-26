/**
 * Class for data generator.
 * TODO: refactoring using randomPicklistValue(); refactor using SOBject[]
 */
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

    private Transaction__c[] transactions;
    private FinServ__Revenue__c[] revenues;

    private User[] teamMembers;

    // TODO: replace single lists with general one to bulkify dml transactions
    private SObject[] items;

    /**
     * Singleton, avoids memory waste
     */
    private DataGenerator() {
        individuals = new Account[]{};
        households = new Account[]{};
        finAccounts = new FinServ__FinancialAccount__c[]{};
        contacts = new Contact[]{};
        opportunities = new Opportunity[]{};
        transactions = new Transaction__c[]{};
        revenues = new FinServ__Revenue__c[]{};
        salesAssociates = [SELECT Id FROM User WHERE UserRole.Name = 'Sales Associate'];
        prices = [SELECT Name, Pricebook2Id, UnitPrice, Product2.Name, Category__c FROM PricebookEntry WHERE IsActive = true AND UnitPrice > 0];
        olis = new OpportunityLineItem[]{};
        teamMembers = [SELECT Id FROM User WHERE IsActive = true AND UserRole.DeveloperName = 'Opportunity_mail_receiver'];

        individualRT = [SELECT Id FROM RecordType
            WHERE SObjectType = 'Account' AND DeveloperName = 'IndustriesIndividual'].Id;
	}
    public static DataGenerator getInstance() {
        if (instance == null) instance = new DataGenerator();
        return instance;
    }

    /**
     * Fill up DB with some test data, especially used in testSetup methods or when regenerating an org's db
     */
    public void createTestEnvironment() {
        DataGenerator dg = DataGenerator.getInstance();
        dg
            .createIndividuals(CustomConstants.DEFAULT_ACCOUNTS)
            .randomizeFinancialAccounts(CustomConstants.DEFAULT_RETAIL_ACCOUNTS,
                    CustomConstants.DEFAULT_WEALTH_ACCOUNTS,
                    CustomConstants.DEFAULT_COMMERCIAL_ACCOUNTS)
            .createOpportunities(CustomConstants.DEFAULT_OPPS)
            .closeOpportunities(CustomConstants.DEFAULT_OPPS_CLOSED, CustomConstants.DEFAULT_OPPS_WINCHANCE)
        .commitWork();
        //.createRevenues(CustomConstants.DEFAULT_REVENUES)
        //.createTransactions(CustomConstants.DEFAULT_TRANSACTIONS);
    }

    /**
     * Commit current work, similar to unit of work pattern
     * TODO: refactor in generic containers
     */
    public DataGenerator commitWork() {
        singleCommit(individuals);
        singleCommit(finAccounts);
        singleCommit(opportunities);
        singleCommit(olis);
        return this;
    }
    private void singleCommit(SObject[] sobjects) {
        if (!sobjects.isEmpty()) {
            insert sobjects;
            sobjects.clear();
        } else {
            System.debug(LoggingLevel.WARN, 'Trying to insert an empty list, skipping');
        }
    }

    /**
     * Creates n accounts with 'individual' record type
     * @param      n     the number of individuals
     */
    public DataGenerator createIndividuals(Integer n) {
        for(Integer i = 0; i < n; i++) {
            this.individuals.add(createIndividual());
        }
        return this;
    }
    /**
     * Private method for single individual set up
     */
    private Account createIndividual() {
        String firstname = randomPick(CustomConstants.names);
        String lastname = randomPick(CustomConstants.last_names);
        return new Account(
            OwnerId = randomPickSObject(teamMembers).Id,
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
            //Branch__c = randomPicklistValue(Account.Branch__c),
            Branch__c = randomPick(CustomConstants.branches),
            FinServ__InvestmentExperience__c = randomPick(CustomConstants.investment_experience),
            FinServ__ServiceModel__c = randomPick(CustomConstants.service_model),
            FinServ__TimeHorizon__c = randomPick(CustomConstants.time_horizon),
            Industry = randomPicklistValue(Account.Industry),
            Website = 'www.DigitalBank.com'
        );
    }

    /**
     * Create a random distribution of financial accounts between the current individuals population
     * @param      retails      Numbero of retail products
     * @param      wealths      Number of wealth products
     * @param      commercials  Number of commercial products
     */
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
            while (rand.Party_ID__c == comm_rand.Party_ID__c) {
                comm_rand = (Account)randomPickSObject(individuals);
            }
            finAccounts.add(createFinancialAccount('Commercial', rand.Party_ID__c, rand.Name, comm_rand.Party_ID__c, comm_rand.Name));
        }
        return this;
    }
    /**
     * Creates a financial account.
     *
     * @param      cat              The category
     * @param      ownerExtId       The owner external id
     * @param      ownerName        The owner name
     * @param      comm_ownerExtId  The commerical owner external id (optional)
     * @param      comm_ownerName   The commerical owner name (optional)
     */
    private FinServ__FinancialAccount__c createFinancialAccount(String cat, String ownerExtId, String ownerName, String comm_ownerExtId, String comm_ownerName) {
        Account owner = new Account(Party_Id__c = ownerExtId);
        Account comm_owner = String.isNotBlank(comm_ownerExtId) ? new Account(Party_Id__c = comm_ownerExtId) : null;
        String category = String.isBlank(cat) ? randomPick(CustomConstants.categories) : cat;
        String faType = category == 'Retail' ? randomPick(CustomConstants.retail_type) :
            category == 'Wealth' ? randomPick(CustomConstants.wealth_type) : randomPick(CustomConstants.commercial_type);
        return new FinServ__FinancialAccount__c(
            OwnerId = randomPickSObject(teamMembers).Id,
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

    /**
     * Creates opportunities between the current accounts populations
     * @param      opps  Number of opportunities to generate
     */
    public DataGenerator createOpportunities(Integer opps) {
        Account[] individualsPool = individuals.isEmpty() ? [SELECT Id, Name, FinServ__PrimaryContact__c
                FROM Account WHERE RecordType.DeveloperName = 'IndustriesIndividual' LIMIT : opps] : individuals;
        for(Integer i = opps; i > 0; i--) {
            Account rand = (Account)randomPickSObject(individualsPool);
            Opportunity opp = createOpportunity();
            if (opp != null) {
                opp.AccountId = rand.Id;
                opp.Referring_Customer__c = rand.FinServ__PrimaryContact__c;
                opp.Name += ' ' + rand.Name + ' Opportunity';
                opportunities.add(opp);
            } else {
                continue;
            }
        }
        return this;
    }
    /**
     * Closes opportunities. Uses loaded opportunities if called while creating some, otherwise selects up to
     * 10k mock opportunities at random from the db.
     * @param      chanceToBeClosed  The chance to be closed
     * @param      winChance         The chance to be closed as won
     * @return     reference to the current instance
     */
    public DataGenerator closeOpportunities(Decimal chanceToBeClosed, Decimal winChance) {
        if (opportunities.isEmpty()) {
            opportunities = [SELECT StageName FROM Opportunity
                WHERE Mock__c = true AND IsClosed = false
                LIMIT 10000 FOR UPDATE];
        }
        for(Opportunity opp: opportunities) {
            Decimal roll = Math.random();
            if (roll <= chanceToBeClosed) {
                opp.StageName = roll >= winChance ? 'Closed Won' : 'Closed Lost';
            }
        }
        update opportunities;
        return this;
    }
    /**
     * Creates an opportunity.
     */
    private Opportunity createOpportunity() {
        PricebookEntry randPrice = (PricebookEntry) randomPickSObject(prices);
        if (randPrice == null) {
            //System.debug(LoggingLevel.ERROR, 'Error while creating opportunity, no pricebook entries!');
            return null;
        }
        String randomId = randPrice.Id + String.valueOf(randomizer) + System.currentTimeMillis();
        randomizer++;
        OpportunityLineItem oli = new OpportunityLineItem(
            Mock__c = true,
            UnitPrice = randPrice.UnitPrice,
            Quantity = 1,
            PricebookEntryId = randPrice.Id
        );
        Opportunity opp = new Opportunity(
            OwnerId = randomPickSObject(teamMembers).Id,
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

    /**
     * Pick a random element in a string[]
     */
    public static String randomPick(String[] stringlist) {
        return stringlist[(Integer) Math.floor(Math.random()*stringlist.size())];
    }
    /**
     * Pick a random element in a SObject[]
     */
    public static SObject randomPickSObject(SObject[] stringlist) {
        if (stringlist == null || stringlist.isEmpty()) return null;
        return stringlist[(Integer) Math.floor(Math.random()*stringlist.size())];
    }
    /**
     * Pick a random element in a SObject picklist field
     */
    public static String randomPicklistValue(Schema.SObjectField field) {
        Schema.PicklistEntry[] ples = field.getDescribe().getPicklistValues();
        return ples[(Integer) Math.floor(Math.random()*ples.size())].getLabel();
    }
    /**
     * Picks a random account between the current population loaded in the class. If no accounts have been loaded,
     * picks from existing population instead.
     */
    public Account pickRandomAccount() {
        if (!individuals.isEmpty()) {
            return (Account) randomPickSObject(individuals);
        } else {
            individuals = [SELECT Id, Name FROM Account
                WHERE RecordType.DeveloperName = 'IndustriesIndividual' LIMIT : 10000];
            if (individuals.isEmpty()) {
                return null;
            }
            return (Account) randomPickSObject(individuals);
        }
    }
    /**
     * Picks a random financial account between the current population loaded in the class. If no financial accounts have been loaded,
     * picks from existing population instead.
     */
    public FinServ__FinancialAccount__c pickRandomFinAccount() {
        if (!finAccounts.isEmpty()) {
            return (FinServ__FinancialAccount__c) randomPickSObject(finAccounts);
        } else {
            finAccounts = [SELECT Name, Category__c, Branch__c, FinServ__Balance__c FROM FinServ__FinancialAccount__c
                WHERE Mock__c = true LIMIT : 10000];
            if (finAccounts.isEmpty()) {
                return null;
            }
            return (FinServ__FinancialAccount__c) randomPickSObject(finAccounts);
        }
    }
    /**
     * Randomizes owners for the current opportunity population
     * WARNING!!!!! MIGHT GENERATES EMAIL ALERTS!!!
     */
    public static void randomizeOpportunitiesOwnerships() {
        Opportunity[] opps = [SELECT Id FROM Opportunity WHERE Mock__c = true LIMIT 50000];
        User[] teamMembers = [SELECT Id FROM User WHERE IsActive = true AND UserRole.DeveloperName = 'Opportunity_mail_receiver'];
        for (Opportunity opp : opps) {
            opp.OwnerId = randomPickSObject(teamMembers).Id;
        }
        update opps;
    }

    /**
     * Creates transactions between the current financial accounts population
     * FIXME: check on process builders
     * @param      transactionsNumber  The number of transactions to create
     */
    /*public DataGenerator createTransactions(Integer transactionsNumber) {
        for(Integer i = 0; i < transactionsNumber; i++) {
            transactions.add(createTransaction());
        }
        insert transactions;
        transactions.clear();
        return this;
    }
    private Transaction__c createTransaction() {
        Boolean isDeposit = Math.random() >= 0.2 ? true : false;
        Boolean bigTransaction = Math.random() >= 0.9 ? true : false;
        Decimal amount = Math.random();
        amount = bigTransaction ? amount * 100000 + 25000 : amount * 1000 + 5;
        amount = isDeposit ? amount : -amount;
        FinServ__FinancialAccount__c finAccount = pickRandomFinAccount();
        Transaction__c newTransaction = new Transaction__c(
            Amount__c = amount,
            account_number__c = finAccount.Id,
            Mock__c = true,
            Channel__c = isDeposit ? randomPick(CustomConstants.depositChannels) : randomPick(CustomConstants.retrieveChannels),
            Status__c = true,
            transaction_date__c = System.today() - (Integer) (Math.random() * 180),
            transaction_id__c = String.valueOf(Math.random()) + String.valueOf(Math.random())
        );
        return newTransaction;
    }*/

    /**
     * Creates revenues between the current financial account population
     * FIXME: check on process builders
     * @param      revenuesNumber  The number of revenues to generate
     */
    /*public DataGenerator createRevenues(Integer revenuesNumber) {
        for(Integer i = 0; i < revenuesNumber; i++) {
            revenues.add(createRevenue());
        }
        insert revenues;
        revenues.clear();
        return this;
    }
    public FinServ__Revenue__c createRevenue() {
        FinServ__FinancialAccount__c randomFinAccount = pickRandomFinAccount();
        FinServ__Revenue__c revenue = new FinServ__Revenue__c(
            Mock__c = true,
            FinServ__Date__c = System.today() - (Integer) (Math.random() * 90),
            FinServ__Amount__c = randomFinAccount.FinServ__Balance__c,
            Branch__c = randomFinAccount.Branch__c
        );
        return revenue;
    }*/

    /**
     * Demo purposes only
     */
    public static void demoTransactions() {
        delete [SELECT Id FROM Transaction__c WHERE Transaction_Id__c IN ('103242323', '111042323')];
        Map<String, String> map1 = new Map<String, String>{
            'amount' => '-50000',
            'account_number' => 'rbmc_comm_1',
            'bank_reference_number' => 'BR0032223',
            'transaction_id' => '103242323',
            'transaction_type_desc' => 'Cheque from bank BK3232',
            'transaction_type_code' => 'CHQ',
            'transaction_date' => '04/20/2017',
            'Channel' => 'Withdrawal',
            'Status' => 'true'
        };
        Map<String, String> map2 = new Map<String, String>{
            'amount' => '50000',
            'account_number' => 'rbmc_1',
            'bank_reference_number' => 'BR0032223',
            'transaction_id' => '111042323',
            'transaction_type_desc' => 'Cheque from bank BK3232',
            'transaction_type_code' => 'CHQ',
            'transaction_date' => '04/20/2017',
            'Channel' => 'Deposit',
            'Status' => 'true'
        };
        TransactionRest.create(map1);
        TransactionRest.create(map2);
    }
}