public class PairObj {
    @AuraEnabled
    public String value{get;set;}
    @AuraEnabled
    public String label{get;set;}
    
    public PairObj(String key, String name){
        this.value=key;
        this.label=name;
    }
}