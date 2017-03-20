({
    doInit : function(component, event, helper) {
        var faCategory = component.get("v.category");
        var action = component.get("{!c.getFinancialAccount}");
        action.setParams({
            accountId: component.get("v.recordId"),
            category: helper.validateCategory(faCategory)
        });

        console.log("calling selector with data: " + helper.validateCategory(faCategory));

        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            console.log("APEX controller SOQL result: " , result);
            if( component.isValid() && state === "SUCCESS" ){
                component.set("v.financialAccounts", result);
            } else console.log("fail: " + state);
        });
        $A.enqueueAction(action);
    },

    showNewDialog : function(component, event, helper) {
        console.log('test new');
        var overlay = component.find('FAList');
        var box = component.find('ModalBox');
        $A.util.addClass(overlay, 'slds-backdrop--open');
        $A.util.addClass(box, 'slds-backdrop--open');
    }
})