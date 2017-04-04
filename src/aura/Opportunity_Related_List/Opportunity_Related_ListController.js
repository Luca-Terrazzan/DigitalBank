({
    doInit : function(component, event, helper) {

        var faCategory = component.get("v.category");
        var action = component.get("{!c.getOpportunities}");
        action.setParams({
            accountId: component.get("v.recordId"),
            category: helper.validateCategory(faCategory)
        });
        //action.setParams({ accountId: "00146000002oWD8AAM"}); // temp hardocding

        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            console.log("APEX controller SOQL result: " , result);
            if( component.isValid() && state === "SUCCESS" ){
                component.set("v.opportunities", result);
            } else console.log("fail: " + state);
        });
        $A.enqueueAction(action);
        helper.getOpportunityDefaultRecordType(component);
    },

    createRecord : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        var rt = component.get("v.roleRecordType");
        createRecordEvent.setParams({
            "entityApiName": "Opportunity",
            "recordTypeId": rt
        });
        createRecordEvent.fire();
    }
})