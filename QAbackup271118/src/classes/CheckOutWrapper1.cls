public class CheckOutWrapper1 {
    @AuraEnabled
    public String label { get;set; }
    @AuraEnabled
    public String value { get;set; }
    
    public CheckOutWrapper1(String label, String value) {
        this.label = label;
        this.value = value;
    }
}