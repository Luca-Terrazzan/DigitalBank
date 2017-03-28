({
	fetchField : function(JSONAccount) {
        var account = JSON.parse(JSONAccount);
        delete account['id'];
        delete account['attributes'];
        var fieldSet = [];
        var labels = Object.keys(account);
        for (var i = 0; i < labels.length; i+=2) {
            var label = labels[i];
            var value = account[label];
            var row = {};
            row['label1'] = label;
            row['value1'] = value;
            label = labels[i+1];
            value = account[label];
            if (label) {
                row['label2'] = label;
                row['value2'] = value;
            }
            row != {} && fieldSet.push(row);
        }
        console.log('rows: ', fieldSet);
        return fieldSet;
    }
})