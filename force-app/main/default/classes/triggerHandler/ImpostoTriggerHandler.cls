public with sharing class ImpostoTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }


        ImpostoHelper.impedirDuplicidade(Trigger.new);
    } 

}