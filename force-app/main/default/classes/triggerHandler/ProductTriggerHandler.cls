public with sharing class ProductTriggerHandler extends TriggerHandler {
    public override void beforeInsert() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }

        ProductHelper.putCodigoInProductCode(Trigger.new);
    }

    public override void afterInsert() {
        if (Trigger.new == null || Trigger.new.isEmpty()) {
            return;
        }

        ProductHelper.createStandardPriceBookEntry(Trigger.new);

    }
}