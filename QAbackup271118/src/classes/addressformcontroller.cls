public class addressformcontroller {
 // EDQ added
    @AuraEnabled
    public static String SearchAddress(string searchTerm, string country, Integer take) {
        return EDQService.SearchAddress(searchTerm, country, take);
    }
    
    // EDQ added
    @AuraEnabled
    public static String FormatAddress(string formatUrl) {
        return EDQService.FormatAddress(formatUrl);
    }
}