public with sharing class ImpostoTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        ImpostoHelper.preventDuplicity(Trigger.new);
    } 

}