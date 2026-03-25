public with sharing class FreteTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }

        FreteHelper.impedirDuplicidade(Trigger.new);
    }

}