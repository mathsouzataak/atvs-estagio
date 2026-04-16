public with sharing class PricebookHelper {
    
    private static Pricebook2 testPricebook;

    public static Pricebook2 getStandardPricebook() {
        return Test.isRunningTest() ? new Pricebook2(Id = Test.getStandardPricebookId()) : [SELECT Id, IsActive FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
    }

    public static Pricebook2 getTestPricebook() {
        if (testPricebook == null) {
            testPricebook = TestDataFactory.createPricebook(true); 
        }

        System.debug(testPricebook);
        return testPricebook; 
    }

    public static PricebookEntry createPricebookEntryForInsertion(Pricebook2 pricebook, Product2 product) {
        return new PricebookEntry(Pricebook2Id = pricebook.Id, Product2Id = product.Id, UnitPrice = product.CustoProducao__c, IsActive = product.IsActive);
    }

}