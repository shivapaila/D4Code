/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global interface MetadataProviderInterface {
    Boolean ContainsField(String param0);
    String CreateLongitudeFieldName(String param0);
    SObject CreateNewObject();
    String GetDefaultRecordTypeId();
    Schema.DescribeFieldResult GetFieldDescribeResult(String param0);
    String GetFieldLabelByFiledName(String param0);
    String GetFieldNameByFieldLabel(String param0);
    Schema.DisplayType GetFieldTypeByFiledName(String param0);
    String GetSObjectKeyPrefix();
    String GetSObjectLabel();
    String GetSObjectNameById(String param0);
    String GetSObjectPluralLabel();
    Boolean HasMiddleNameField();
    Boolean HasSuffixField();
    Boolean IsAutoNumberField(String param0);
    Boolean IsDateTimeField(String param0);
    Boolean IsLatitudeField(String param0);
    Boolean IsLongitudeField(String param0);
    Boolean IsPersonAccountsOn();
    Boolean IsPersonAccountsOnStatic();
    Boolean IsRecordTypesOn();
    Boolean IsReferenceField(String param0);
    Boolean IsStateAndCountryPicklistsOn();
}
