public with sharing class ProductHelper {

    public static void putCodigoInProductCode(List<Product2> produtos) {
        for (Product2 produto : produtos) {
            produto.ProductCode = produto.Codigo__c;
        }
    }

    public static void createStandardPriceBookEntry(List<Product2> produtos) {
        Pricebook2 catalogo = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];

        List<PricebookEntry> itensCatalogo = new List<PricebookEntry>();
        for (Product2 produto : produtos) {
            itensCatalogo.add(new PricebookEntry(Pricebook2Id = catalogo.Id, Product2Id = produto.Id, UnitPrice = produto.CustoProducao__c));
        }

        Database.insert(itensCatalogo, false);
    }

    public static List<Product2> queryProdutoComIds(Set<Id> ids) {
        return [SELECT Id, HierarquiaProduto__c, CustoProducao__c
                FROM Product2
                WHERE Id IN :ids];
    }

}