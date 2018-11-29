//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
//

public class JSONPostcallForSR {

	public Integer RequestId;
	public String CreatedUserId;
	public String CustomerId;
	public String OpenDate;
	public String ReasonCodeText;
	public Integer ReasonCode;
	public Integer AssigneeCode;
	public String AssigneeName;
	public String ScheduledDate;
	public Integer RequestStatus;
	public String RequestStatusText;
	public String IsTechResource;
	public Integer RequestPriority;
	public String RequestPriorityText;
	public Object CommentText;
	public String ReopenDate;
	public String FollowUpDate;
	public Integer ProfitCenterCode;
	public Integer ServiceTechId;
	public String TechName;
	public String VendName;
	public String VpcName;
	public String VendId;
	public String PcKey;
	public Integer RequestSalesOrderNumber;
	public String Address1;
	public String Address2;
	public String CityName;
	public String StateCode;
	public String ZipCode;
	public String CustomerPhone1;
	public String CustomerPhone2;
	public String CustomerPhone3;
	public String CustomerEmail;
	public Integer EstimatedTimeForStop;

	
	public static JSONPostcallForSR parse(String json) {
		return (JSONPostcallForSR) System.JSON.deserialize(json, JSONPostcallForSR.class);
	}
}