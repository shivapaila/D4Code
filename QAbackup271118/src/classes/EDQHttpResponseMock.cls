@isTest
public class EDQHttpResponseMock implements HttpCalloutMock {
	private Integer statusCode;
	public EDQHttpResponseMock(Integer statusCode) {
		this.statusCode = statusCode;
	}
	public HTTPResponse respond(HTTPRequest request) {
		String responseBody = '';
		if(request.getEndpoint().startsWith(AddressSearchEndpoint)) {
			responseBody = '{"count":7,"results":[{"suggestion":"PO Box 10099, Akron OH 44310","matched":[[7,12],[0,6]],"format":"https://api.edq.com/capture/address/v2/format?country=USA&id=95889123-1cea-48cf-8633-da5f46b74a58ql12"},{"suggestion":"PO Box 10099, Albany NY 12201","matched":[[7,12],[0,6]],"format":"https://api.edq.com/capture/address/v2/format?country=USA&id=fdfa85d0-e324-4dad-a001-a02eafde0219ql12"},{"suggestion":"PO Box 10099, Albuquerque NM 87184","matched":[[7,12],[0,6]],"format":"https://api.edq.com/capture/address/v2/format?country=USA&id=e2d741c8-db56-438d-987e-7385f34b842eql12"},{"suggestion":"PO Box 10099, Alexandria VA 22310","matched":[[7,12],[0,6]],"format":"https://api.edq.com/capture/address/v2/format?country=USA&id=17285670-e81a-4062-b130-919de99338acql12"},{"suggestion":"PO Box 10099, Amarillo TX 79116","matched":[[7,12],[0,6]],"format":"https://api.edq.com/capture/address/v2/format?country=USA&id=3e7b0be2-0c9c-45fa-b7ba-4188f58e4087ql12"},{"suggestion":"PO Box 10099, American Canyon CA 94503","matched":[[7,12],[0,6]],"format":"https://api.edq.com/capture/address/v2/format?country=USA&id=cffcdb43-dc15-4ab4-8b1d-ac7be13dbfb1ql12"},{"suggestion":"PO Box 10099, Anaheim CA 92812","matched":[[7,12],[0,6]],"format":"https://api.edq.com/capture/address/v2/format?country=USA&id=08fea279-976c-43ac-8dbf-d7f7f25eb159ql12"}]}';
		} else if(request.getEndpoint().startsWith(AddressFormatEndpoint)) {
			responseBody = '{"address":[{"addressLine1":"38 Lane Cove Rd"},{"addressLine2":"38 Lane Cove Road"},{"addressLine3":""},{"locality":"RYDE"},{"province":"NSW"},{"postalCode":"2112"},{"country":"AUSTRALIA"}],"components":[{"deliveryPointId1":"76077169"},{"streetNumber1":"38"},{"street1":"Lane Cove Rd"},{"locality1":"RYDE"},{"province1":"New South Wales"},{"provinceCode1":"NSW"},{"postalCode1":"2112"},{"country1":"AUSTRALIA"},{"countryISO1":"AUS"}],"metadata":{}}';
		}

		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		response.setBody(responseBody);
		response.setStatusCode(statusCode);

		return response;
	}

	public static string AddressSearchEndpoint = 'https://api.edq.com/capture/address/v2/search';
	public static string AddressFormatEndpoint = 'https://api.edq.com/capture/address/v2/format';
}