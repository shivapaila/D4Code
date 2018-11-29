public with sharing abstract class EDQBaseService {
    protected EDQBaseService(string token, string endpoint) {
        this.token = token;
        this.Endpoint = endpoint;
        this.CalloutTimeoutInSeconds = 2;
    }
    public Integer CalloutTimeoutInSeconds { get; set; }
    public string Endpoint = '';
    private String token = '';

    protected HttpResponse SendRequest(String body, Boolean isGet) {
        return SendRequest(endpoint, body, isGet);
    }

    protected HttpResponse SendRequest(String endPoint, String body, Boolean isGet) {
        HttpRequest req = new HttpRequest();
        req.setTimeout(CalloutTimeoutInSeconds * 1000);
        req.setEndpoint(Endpoint);
        req.setHeader('Content-Type', 'application/json');

        if (!IsNullOrEmptyOrWhiteSpace(token))
            req.setHeader('Auth-Token', token);

        req.setMethod(isGet ? 'GET' : 'POST');

        if (!IsNullOrEmptyOrWhiteSpace(body))
            req.setBody(body);

        Http h = new Http();

        return h.send(req);
    }

    private static Boolean IsNullOrEmptyOrWhiteSpace(String value) {
        return value == null || value.trim().length() == 0;
    }
}