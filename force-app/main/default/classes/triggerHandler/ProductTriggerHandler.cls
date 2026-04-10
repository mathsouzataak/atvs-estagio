public with sharing class ProductTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        // Colocar código do campo Codigo__c no campo padrão ProductCode
        ProductHelper.putCustomCodeInProductCode(Trigger.new);
    }

    public override void afterInsert() {
        // Criar entry no Pricebook padrão
        ProductHelper.createStandardPriceBookEntry(Trigger.new);

    }
}