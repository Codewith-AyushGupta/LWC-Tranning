public class AccountFormController {
    @AuraEnabled
    public static List<AccountFields> getFieldsData(){
        List<AccountFields> fieldStructure = new  List<AccountFields>();
       fieldStructure.addAll(getSelectedObjectFieldsData('Account'));
        fieldStructure.addAll(getSelectedObjectFieldsData('Contact'));
        return fieldStructure;
    }
    @AuraEnabled
    public static List<AccountFields> getSelectedObjectFieldsData(String objectName){
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectName).getDescribe();
        List<AccountFields> fieldStructure = new List<AccountFields>();
        Map<String, Schema.SObjectField> fieldsMap = objectDescribe.fields.getMap();
        For(String FieldName : fieldsMap.keySet()){
            AccountFields fieldsref ;
            Schema.DescribeFieldResult fieldDescribe = fieldsMap.get(FieldName).getDescribe();
            
            system.debug('filed Name==>'+fieldDescribe.getName());
            system.debug('filed Type ==>'+fieldDescribe.getType());
            system.debug('fieldDescribe.isCreateable() ==>'+fieldDescribe.isCreateable());
            system.debug('fieldDescribe.isNillable() ==>'+fieldDescribe.isNillable());
            system.debug('fieldDescribe.isDefaultedOnCreate() ==>'+fieldDescribe.isDefaultedOnCreate());
            system.debug('fieldDescribe.isNameField() ==>'+fieldDescribe.isNameField());
            system.debug('fieldDescribe.isAutoNumber() ==>'+fieldDescribe.isAutoNumber());


            if((fieldDescribe.isCreateable() && !fieldDescribe.isNillable() && !fieldDescribe.isDefaultedOnCreate()) ||
               (fieldDescribe.isNameField() && !fieldDescribe.isAutoNumber())){
                String FieldType ='';
                if(fieldDescribe.getType().name() == 'Boolean'){
                    FieldType = 'checkbox';
                    fieldsref = new AccountFields(fieldDescribe.getLabel(),fieldDescribe.getName(),FieldType,objectName);
                }
                else if(fieldDescribe.getType().name() == 'referance'){
                    FieldType = 'lookup';
                    fieldsref = new AccountFields(fieldDescribe.getLabel(),fieldDescribe.getName(),FieldType,objectName);
                }
                else if(fieldDescribe.getType().name() == 'STRING'){
                    FieldType = 'text';
                    fieldsref = new AccountFields(fieldDescribe.getLabel(),fieldDescribe.getName(),FieldType,objectName);
                }
                else if(fieldDescribe.getType().name() == 'Email'){
                    FieldType = 'Email';
                    fieldsref = new AccountFields(fieldDescribe.getLabel(),fieldDescribe.getName(),FieldType,objectName);
                }
                else if(fieldDescribe.getType().name() == 'DATE'){
                    FieldType = 'date';
                    fieldsref = new AccountFields(fieldDescribe.getLabel(),fieldDescribe.getName(),FieldType,objectName);
                }
                else if(fieldDescribe.getType().name() == 'PICKLIST' && fieldDescribe.isAccessible() && fieldDescribe.isAccessible()){
                    List<Schema.PicklistEntry> picklistValues = null;
                    List<pickListEntry> pickListValuesByApi  = new List<pickListEntry>();
                    picklistValues = fieldDescribe.getPickListValues();
                    for(Schema.PicklistEntry entry : picklistValues){
                        string value = entry.getValue();
                        string label = entry.getLabel();
                        pickListEntry  pickData = new pickListEntry(label,value);
                        pickListValuesByApi.add(pickData);
                    }
                    fieldsref = new AccountFields(fieldDescribe.getLabel(),fieldDescribe.getName(),FieldType,pickListValuesByApi,objectName);
                }
                fieldStructure.add(fieldsref);
            }
        }
        if(fieldStructure.size()>0){
            System.debug('data==>'+json.serialize(fieldStructure));
            return  fieldStructure;
        }
        return null;
    }
    @AuraEnabled
    public static Boolean saveData(String accountData){
      List<AccountFields> accountFieldsData = (List<AccountFields>)JSON.deserialize(accountData, List<AccountFields>.class);        
        Account acc = new Account();
        Contact con = new Contact();
        for (AccountFields obj : accountFieldsData) {
            Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(obj.objectName).getDescribe();
            Map<String, Schema.SObjectField> fieldsMap = objectDescribe.fields.getMap();
            Schema.SObjectField fieldApi = fieldsMap.get(obj.FieldApiName);
            if (fieldApi != null && obj.objectName =='Account') {
                acc.put(fieldApi, obj.FieldData);
            }
            else if(fieldApi != null && obj.objectName =='Contact' && obj.FieldApiName !='Name'){
                con.put(fieldApi, obj.FieldData);
            }
        }

        try {
            insert acc;
            con.accountId = acc.Id;
            insert con;
            System.debug('Account Updated: ' + acc);
            return true;
        } catch (Exception e) {
            System.debug('Error updating account: ' + e.getMessage());
            return false;
        }
    
    }
    public class AccountFields{
        @AuraEnabled
        Public String FieldName{get;set;}
        @AuraEnabled
        Public String FieldApiName{get;set;}
        @AuraEnabled
        Public String FieldType{get;set;}
        @AuraEnabled
        Public String lookupObject{get;set;}
        @AuraEnabled
        Public List<pickListEntry> pickListData{get;set;}
        @AuraEnabled
        Public String fieldData{get;set;}
        @AuraEnabled
        Public String objectName{get;set;}


        public AccountFields(String FieldName , String FieldApiName , String FieldType , String objectName){
            this.FieldName = FieldName;
            this.FieldApiName = FieldApiName;
            this.FieldType = FieldType;
            this.fieldData = '';
            this.objectName = objectName;

        }
        public AccountFields(String FieldName , String FieldApiName , String FieldType , List<pickListEntry> pickListData , String objectName){
            this.FieldName = FieldName;
            this.FieldApiName = FieldApiName;
            this.FieldType = FieldType;
            this.pickListData = pickListData;
            this.fieldData = '';
            this.objectName = objectName;
        }
    }
    public  class pickListEntry{
        @AuraEnabled
        Public String label{get;set;}
        @AuraEnabled
        Public String value{get;set;}
        public pickListEntry(String label,String value){
            this.label = label;
            this.value = value;
        }
    }
}