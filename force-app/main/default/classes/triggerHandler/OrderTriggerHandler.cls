public with sharing class OrderTriggerHandler extends TriggerHandler {
    
    public override void afterUpdate() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }
        
        // Map<Id,Order> newEndereco = new Map<Id,Order>();
        // for (Integer i = 0; i < Trigger.new.size(); i++) {
        //     if (((Order)(Trigger.new[i])).AccountAddress__c != ((Order)(Trigger.old[i])).AccountAddress__c) {
        //         newEndereco.put(Trigger.new[i].Id, (Order)Trigger.new[i]);
        //     }
        // }
        // OrderItemHelper.atribuirImposto(newEndereco);
    }
    
}