public with sharing class OrderItemTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        OrderItemHelper.searchAndAssignParameters(Trigger.new);
    }

}