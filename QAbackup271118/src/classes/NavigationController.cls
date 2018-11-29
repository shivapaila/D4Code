public class NavigationController {
   
    @AuraEnabled
    public Static String NavigateProduct(String PgReference)
    {
        system.debug('PgReference--------'+PgReference);
        string pgRef = PgReference;
        system.debug('PgReference--------'+pgRef);
        return pgRef;
    }
 
}