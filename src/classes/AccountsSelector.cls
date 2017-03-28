/**
 * Encapsulate Accounts query logic
 **/
public class AccountsSelector extends fflib_SObjectSelector
{
    public List<Schema.SObjectField> getSObjectFieldList()
    {
        return new List<Schema.SObjectField> {
                Account.Id
            };
    }

    public Schema.SObjectType getSObjectType()
    {
        return Account.sObjectType;
    }

    public List<Account> selectById(Set<ID> idSet)
    {
        return (List<Account>) selectSObjectsById(idSet);
    }

    public String getAccountFields(Id accountId, String fieldListString)
    {
        assertIsAccessible();
        String[] apiNames = fieldListString.split(',');
        String[] cleanApiNames = new String[]{};
        for(String fieldName: apiNames) {
            String cleanField = fieldName.toLowerCase();
            cleanField = cleanField.trim();
            cleanApiNames.add(cleanField);
        }
        System.debug(loggingLevel.Error, '*** apiNames: ' + cleanApiNames);
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();
        System.debug(loggingLevel.Error, '*** fieldMap: ' + fieldMap);
        Map<String, String> labelMap = new Map<String, String>();
        for(String field: cleanApiNames) {
            String label = fieldMap.get(field).getDescribe().getLabel();
            labelMap.put(field, label);
        }
        System.debug(loggingLevel.Error, '*** labelMap: ' + labelMap);
        Account result = (Account) Database.query(
            String.format(
                'select {0} ' +
                    'from {1} ' +
                    'where Id =: accountId ',
                new List<String> {
                    fieldListString,
                    getSObjectName()
                }
            )
        );
        System.debug(loggingLevel.Error, '*** result: ' + result);
        String jsonAccount = JSON.serialize(result).toLowerCase();
        System.debug(loggingLevel.Error, '*** jsonAccount: ' + jsonAccount);
        for(String field: cleanApiNames) {
            System.debug(loggingLevel.Error, '*** trying to replace: ' + field + ' with: ' + labelMap.get(field));
            jsonAccount = jsonAccount.replace(field, labelMap.get(field));
            System.debug(loggingLevel.Error, '*** jsonAccount: ' + jsonAccount);
        }
        return jsonAccount;
    }
}