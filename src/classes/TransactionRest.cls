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

    global class TransactionData {
        global String giving;
        global String receiving;
        global Decimal amount;
        global String status;
    }
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
    global static Response create(TransactionData request) {
        FinServ__FinancialAccount__c giver = new FinServ__FinancialAccount__c(
            FinServ__FinancialAccountNumber__c = request.giving
        );
        FinServ__FinancialAccount__c receiver = new FinServ__FinancialAccount__c(
            FinServ__FinancialAccountNumber__c = request.receiving
        );
        Transaction__c newTransaction = new Transaction__c(
            GivingFinancialAccount__r = giver,
            ReceivingFinancialAccount__r = receiver,
            MovedAmount__c = request.amount,
            Status__c = request.status
        );

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
    global static void remove() {

    }

}