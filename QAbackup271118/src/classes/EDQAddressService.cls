public with sharing class EDQAddressService extends EDQBaseService {

    private ErrorLogController errorLogger = new ErrorLogController();

    @testVisible
    private final Map<Integer, String> fullAddressCodeMessageResponse = new Map<Integer, String>{
            400 => 'Request failed due to malformed syntax.',
            401 => 'Auth-Token provided is incorrect.',
            403 => 'Request is not authorized to use the service.',
            404 => 'The requested resource could not be found but may be available again in the future. Subsequent requests by the client are permissable.',
            500 => 'The server has encountered an error.',
            502 => 'Provider failure.',
            503 => 'The server is currently unavailable.'
    };

    public EDQAddressService(string token, string addressSearchEndpoint) {
        super(token, addressSearchEndpoint);
    }

    public String SearchAddress(string searchTerm, string country, Integer take) {
        String addressSearchUrl = Endpoint;
        addressSearchUrl += '?query=' + EncodingUtil.urlEncode(searchTerm, 'UTF-8');
        addressSearchUrl += '&country=' + country;
        addressSearchUrl += '&take=' + take;

        HttpResponse response = SendRequest(addressSearchUrl, '', true);
        Integer statusCode = response.getStatusCode();
        String resultJSON = response.getBody();

        if (200 != statusCode) {
            errorLogger.createLog(createAddressValidationLog(response, 'SearchAddress'));
            return '{"Message": "' + fullAddressCodeMessageResponse.get(statusCode) + '"}';
        }

        return resultJSON;
    }

    public String FormatAddress(string formatUrl) {
        HttpResponse response = SendRequest(formatUrl, '', true);
        Integer statusCode = response.getStatusCode();
        String resultJSON = response.getBody();

        if (200 != statusCode) {
            errorLogger.createLog(createAddressValidationLog(response, 'FormatAddress'));
            return '{"Message": "' + fullAddressCodeMessageResponse.get(statusCode) + '"}';
        }

        return resultJSON;
    }

    @TestVisible
    private ErrorLogController.Log createAddressValidationLog(HttpResponse response, String method) {
        Integer statusCode = response.getStatusCode();
        String errorClass = 'EDQAddressService';
        String errorMethod = method;
        String errorMessage = '';

        if (fullAddressCodeMessageResponse.containsKey(statusCode)) {
            errorMessage = 'Validation failed. Status code: ' + statusCode + '. Message: ' + fullAddressCodeMessageResponse.get(statusCode);
        } else {
            errorMessage = 'Validation failed. Status code: ' + statusCode + '. Body: ' + (response.getBody());
        }

        return new ErrorLogController.Log(errorClass, errorMethod, errorMessage);
    }
}