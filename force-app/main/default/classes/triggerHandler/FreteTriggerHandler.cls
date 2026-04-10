public with sharing class FreteTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        FreteHelper.preventDuplicity(Trigger.new);
    }

}