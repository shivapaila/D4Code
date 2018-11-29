public with sharing class EDQService {

    private static String validationToken = null;
    private static final String addressSearchEndpoint = 'https://api.edq.com/capture/address/v2/search';
    private static Integer serviceTimeoutInSeconds = 4;
    private static Map<String, String> aliases;
    @TestVisible
    private static List<StaticResource> staticResourcesResult = new List<StaticResource>();

    /**
     * Do a request for address lookup and return result
     *
     * @param searchTerm
     * @param country
     * @param take
     *
     * @return
     */
    @AuraEnabled
    public static String SearchAddress(string searchTerm, string country, Integer take) {
        country = transformToISO3(country);
        EDQAddressService addressService = new EDQAddressService(GetValidationToken(), addressSearchEndpoint);
        addressService.CalloutTimeoutInSeconds = serviceTimeoutInSeconds;

        return addressService.SearchAddress(searchTerm, country, take);
    }

    /**
     * Do request for address detailed information and return result
     *
     * @param formatUrl
     *
     * @return
     */
    @AuraEnabled
    public static String FormatAddress(string formatUrl) {
        EDQAddressService addressService = new EDQAddressService(GetValidationToken(), addressSearchEndpoint);
        addressService.CalloutTimeoutInSeconds = serviceTimeoutInSeconds;

        return addressService.FormatAddress(formatUrl);
    }

    /**
     * Try to transform the country to ISO3 format using the country aliases from EDQ Settings
     *
     * @param country
     *
     * @return String
     */
    @TestVisible
    private static String transformToISO3(String country) {
        if (3 == country.length()) {
            return country;
        }

        String iso3 = getCountryAliases().get(country.toUpperCase());
        if (null == iso3) {
            return country;
        }

        return iso3;
    }

    /**
     * Get country aliases from EDQ Settings
     *
     * @return
     */
    @TestVisible
    private static Map<String, String> getCountryAliases() {
        try {
            if (null == aliases) {
                Map<String, String> parsedAliasMap = new Map<String, String>();
                String configurationsJson = GetJSONFromStaticResource('EDQGlobalSettings');
                if (null != configurationsJson) {
                    Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(configurationsJson);
                    if (result.containsKey('AddressSettings')) {
                        Map<String, Object> notParsedAddressSettings = (Map<String, Object>) result.get('AddressSettings');
                        if (notParsedAddressSettings.containsKey('DataSetAliases')) {
                            Map<String, Object> notParsedAliasMap = (Map<String, Object>) notParsedAddressSettings.get('DataSetAliases');
                            for (String key : notParsedAliasMap.keySet()) {
                                parsedAliasMap.put(key, String.valueOf(notParsedAliasMap.get(key)));
                            }
                        }
                    }
                }
                aliases = parsedAliasMap;
            }
        } catch (Exception e) {
            aliases = new Map<String, String>();
        }

        return aliases;
    }

    /**
     * Get validation token from EDQ Settings
     *
     * @return
     */
    @TestVisible
    private static String GetValidationToken() {
        if (validationToken == null) {
            String configurationsJson = GetJSONFromStaticResource('EDQSessionToken');

            if (String.isBlank(configurationsJson)) {
                return '';
            }

            JSONParser parser = JSON.createParser(configurationsJson);
            Map<String, String> edqSessionToken = (Map<String, String>) parser.readValueAs(Map<String, String>.class);

            validationToken = edqSessionToken.get('AV2Token');
        }
        return validationToken;
    }

    /**
     * Get static resource
     *
     * @param staticResourceName
     *
     * @return
     */
    @TestVisible
    private static String GetJSONFromStaticResource(String staticResourceName) {
        List<StaticResource> resource = getStaticResources(staticResourceName);
        if (resource == null || resource.size() == 0) {
            return null;
        }

        String str = resource[0].Body.toString();
        Integer i = str.indexOf('=');

        return i > 0 ? str.substring(i + 1) : str;
    }

    /**
     * Returns list of static resources based on Name.
     * Note that this method was necessary in order to test the class
     *
     * @param staticResourceName
     *
     * @return
     */
    private static List<StaticResource> getStaticResources(String staticResourceName){
        if(null == staticResourcesResult || 0 == staticResourcesResult.size()){
            return [Select Body from StaticResource where Name = :staticResourceName];
        }
        return staticResourcesResult;
    }

}