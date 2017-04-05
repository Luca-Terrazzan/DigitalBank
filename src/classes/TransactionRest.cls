/**
 * Example call for transaction creation:
 * {
 *  "request": {
 *      "giving": "bca1",
 *      "receiving": "slda1",
 *      "amount": 12311.2
 *  }
 * }
 */
@RestResource(urlMapping='/transactionApi')
global with sharing class TransactionRest  {

    global class Response {
        global Boolean outcome;
        global String[] messages;
        global String[] errors;
        global Id itemId;
        global Response() {
            this.outcome = false;
            this.messages = new String[]{};
            this.errors = new String[]{};
        }
    }

    @HttpGet
    global static Transaction__c show() {
        Transaction__c obj;
        return obj;
    }

    @HttpPost
    global static Response create(Map<String, String> request) {
        FinServ__FinancialAccount__c receiver = new FinServ__FinancialAccount__c(
            FinServ__FinancialAccountNumber__c = request.get('account_number')
        );
        Transaction__c newTransaction = new Transaction__c(
            Amount__c = Decimal.valueOf(request.get('amount')),
            Account_number__r = receiver
        );
        request.remove('amount');
        request.remove('account_number');

        for (String key : request.keySet()) {
            newTransaction.put(key + '__c', request.get(key));
        }

        Response resp = new Response();
        try {
            insert newTransaction;
        } catch (DmlException dmle) {
            resp.outcome = false;
            resp.errors.add('Cannot create transaction.');
            resp.errors.add(dmle.getMessage());
            return resp;
        }
        resp.outcome = true;
        resp.itemId = newTransaction.Id;
        resp.messages.add('Operation successful');
        return resp;
    }

    @HttpPut
    global static Transaction__c updateObject() {
        Transaction__c obj;
        return obj;
    }

    @HttpDelete
    global static void remove() {}

}