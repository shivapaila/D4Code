public class NoteWrapper {
    @AuraEnabled
    public String id{get;set;}
    @AuraEnabled
    public String title{get;set;}
    @AuraEnabled
    public String body{get;set;}
    
    public NoteWrapper(String i, String t, String b) {
        id = i;
        title = t;
        body = b;
    }
}