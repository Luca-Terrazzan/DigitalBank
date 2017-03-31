({
    doInit : function(component, event, helper) {
        var faCategory = component.get("v.category");
        var action = component.get("{!c.getAccountFields}");
        action.setParams({
            accountId: component.get("v.recordId"),
            fieldList: component.get("v.fields")
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            console.log("APEX controller SOQL result: " , result);
            if( component.isValid() && state === "SUCCESS" ){
                component.set("v.fieldset", helper.fetchField(result));
            } else console.log("fail: " + state);
        });
        $A.enqueueAction(action);
    }
})