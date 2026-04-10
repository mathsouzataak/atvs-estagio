public with sharing class MargemTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {
        MargemHelper.preventDuplicity(Trigger.new);
    }

}