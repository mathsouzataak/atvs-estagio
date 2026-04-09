public with sharing class MargemTriggerHandler extends TriggerHandler {
    
    public override void beforeInsert() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }

        MargemHelper.preventDuplicity(Trigger.new);
    }

}