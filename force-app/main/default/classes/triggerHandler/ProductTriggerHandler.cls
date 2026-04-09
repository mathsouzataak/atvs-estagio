public with sharing class ProductTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }

        // Colocar código do campo Codigo__c no campo padrão ProductCode
        ProductHelper.putCustomCodeInProductCode(Trigger.new);
    }

    public override void afterInsert() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }

        // Criar entry no Pricebook padrão
        ProductHelper.createStandardPriceBookEntry(Trigger.new);

    }
}