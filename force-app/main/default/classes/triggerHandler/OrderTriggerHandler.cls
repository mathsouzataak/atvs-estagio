public with sharing class OrderTriggerHandler extends TriggerHandler {

    public override void beforeUpdate() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }

    }
    
    public override void afterUpdate() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }
        
        Map<Id,Order> newEndereco = new Map<Id,Order>();
        for (Integer i = 0; i < Trigger.new.size(); i++) {
            if (((Order)(Trigger.new[i])).AccountAddress__c != ((Order)(Trigger.old[i])).AccountAddress__c) {
                Trigger.new[i].addError('Não é possível atualizar a conta do pedido');
            }
        }
    }
    
}