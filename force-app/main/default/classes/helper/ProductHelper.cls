public with sharing class ProductHelper {

    public static void putCustomCodeInProductCode(List<Product2> products) {
        for (Product2 product : products) {
            product.ProductCode = product.Codigo__c;
        }
    }

    public static void createPriceBookEntryForNewProducts(List<Product2> products, Pricebook2 pricebook) {

        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Product2 product : products) {
            pricebookEntries.add(PricebookHelper.createPricebookEntryForInsertion(pricebook, product));
        }

        System.debug(products);
        System.debug(pricebookEntries);

        Database.insert(pricebookEntries, false);

        System.debug(pricebookEntries[0].getErrors());
    }

    public static List<Product2> queryProductsWithIds(Set<Id> ids) {
        return [SELECT Id, HierarquiaProduto__c, CustoProducao__c
                FROM Product2
                WHERE Id IN :ids];
    }

}