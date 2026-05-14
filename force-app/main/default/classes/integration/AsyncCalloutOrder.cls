public with sharing class AsyncCalloutOrder implements Queueable, Database.AllowsCallouts {
    
    private List<String> orderIds;

    public AsyncCalloutOrder(List<String> orderIds) {
        this.orderIds = orderIds;
    }

    public void execute(QueueableContext context) {
		DataIntegrationFields.CalloutResponse response = CalloutOrder.executeCalloutOrder(orderIds);
		System.debug(response);
    }

}