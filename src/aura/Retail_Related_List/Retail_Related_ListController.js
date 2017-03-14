({
	doInit : function(component) {
		var action = component.get("{!c.getRetailFinancialAccount}");
		action.setParams({ accountId: component.get("v.recordId") }); // to be enabled once the component is finished
		//action.setParams({ accountId: "00146000002oWD8AAM"}); // temp hardocding

		action.setCallback(this, function(response){
			var state = response.getState();
			var result = response.getReturnValue();
			console.log("APEX controller SOQL result: " , result);
			if( component.isValid() && state === "SUCCESS" ){
				component.set("v.financialAccounts", result);
			} else console.log("fail: " + state);
		});
		$A.enqueueAction(action);
	}
})