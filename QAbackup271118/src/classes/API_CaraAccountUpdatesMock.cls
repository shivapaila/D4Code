// mock class for API_CaraAccountUpdatesTest
@isTest
public class API_CaraAccountUpdatesMock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;

    public API_CaraAccountUpdatesMock(Integer code, String status, String body) {
        this.code = code;
        this.status = status;
        this.body = body;    
    }

    public HTTPResponse respond(HTTPRequest req) {

        HttpResponse res = new HttpResponse();
        res.setBody(this.body);
        res.setStatusCode(this.code);
        res.setStatus(this.status);
        return res;
    }

}