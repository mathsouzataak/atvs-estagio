public with sharing class ProductHelper {

    public static void putCustomCodeInProductCode(List<Product2> products) {
        for (Product2 product : products) {
            product.ProductCode = product.Codigo__c;
        }
    }

    public static void createStandardPriceBookEntry(List<Product2> products) {
        Pricebook2 pricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 product : products) {
            pricebookEntries.add(new PricebookEntry(Pricebook2Id = pricebook.Id, Product2Id = product.Id, UnitPrice = product.CustoProducao__c, IsActive = product.IsActive));
        }

        Database.insert(pricebookEntries, false);
    }

    public static List<Product2> queryProductsWithIds(Set<Id> ids) {
        return [SELECT Id, HierarquiaProduto__c, CustoProducao__c
                FROM Product2
                WHERE Id IN :ids];
    }

}