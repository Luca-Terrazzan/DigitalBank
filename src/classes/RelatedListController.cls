public with sharing class RelatedListController {
	
	@AuraEnabled
	public static list<FinServ__FinancialAccount__c> getRetailFinancialAccount (){

		return [SELECT id, Name, FinServ__Balance__c FROM FinServ__FinancialAccount__c WHERE FinServ__FinancialAccount__c.IsCommercial__c = false];

	}

	@AuraEnabled
	public static list<FinServ__FinancialAccount__c> getCommercialFinancialAccount (){

		return [SELECT id, Name FROM FinServ__FinancialAccount__c WHERE FinServ__FinancialAccount__c.IsCommercial__c = true];

	}
}