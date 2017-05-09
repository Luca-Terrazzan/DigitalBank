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
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Account.fields.getMap();
        Map<String, String> labelMap = new Map<String, String>();
        for(String field: cleanApiNames) {
            String label = fieldMap.get(field).getDescribe().getLabel();
            labelMap.put(field, label);
        }
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
        String jsonAccount = JSON.serialize(result).toLowerCase();
        for(String field: cleanApiNames) {
            jsonAccount = jsonAccount.replace(field, labelMap.get(field));
        }
        return jsonAccount;
    }
}