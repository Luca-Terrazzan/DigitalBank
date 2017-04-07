({
    /**
     * Checks if a category is valid
     * @param      {String}   category  The category
     * @return     {boolean}
     */
    validateCategory : function(category) {
        var okCategories = [
            "Retail",
            "Commercial",
            "Wealth"
        ];
        if (okCategories.indexOf(category) >= 0) return category;
        return '';
    },

    getOpportunityDefaultRecordType : function(component) {
        if (!component.get("v.roleRecordType")) {
            var action = component.get("{!c.getOppDefaultRecordType}");

            action.setCallback(this, function(response){
                var state = response.getState();
                var result = response.getReturnValue();
                console.log('Fetched default opportunity role record type: ', result);
                if( component.isValid() && state === "SUCCESS" ){
                    component.set("v.roleRecordType", result);
                } else console.log("fail: " + state);
            });
            $A.enqueueAction(action);
        }
    }
})