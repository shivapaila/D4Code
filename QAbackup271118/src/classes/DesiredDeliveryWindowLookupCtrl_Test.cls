@isTest
public class DesiredDeliveryWindowLookupCtrl_Test {
	public static testMethod void testGetDesiredDeliveryCalendarDays() {
		Date currentDay = System.today();
		DeliveryWindowLookupController.DeliveryCalendarResponse response = DesiredDeliveryWindowLookupController.getDesiredDeliveryCalendarDays(currentDay.year()+'-'+(currentDay.month()+1)+'-'+currentDay.day());
		System.assert(response.isSuccess == true);
        System.assert(response.calendar.months[1].isCurrentSeletedDateMonth == true);
	}

}