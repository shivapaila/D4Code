public class SwatchesWrapper implements Comparable{
    @AuraEnabled
    public string sku{get;set;}
    @AuraEnabled
    public string color{get;set;}
    @AuraEnabled
    public string swatchProductUrl{get;set;}
    @AuraEnabled
    public string imageSource{get;set;}
    @AuraEnabled
    public string guid{get;set;}
    
    // Compare SwatchesWrapper based on the sku.
    public Integer compareTo(Object compareTo) {
        // Cast argument to SwatchesWrapper
        SwatchesWrapper compareToSwatch = (SwatchesWrapper)compareTo;
        // The return value of 0 indicates that both elements are equal.
        Integer returnValue = 0;
        if (sku > compareToSwatch.sku) {
            // Set return value to a positive value.
            returnValue = 1;
        } else if (sku < compareToSwatch.sku) {
            // Set return value to a negative value.
            returnValue = -1;
        }
        return returnValue;
    }
}