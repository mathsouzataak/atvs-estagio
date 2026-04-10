@IsTest
private with sharing class ImpostoTest {


    @IsTest
    static void testBulkDuplicityOnInsert() {
        Imposto__c tax1 = TestDataFactory.createTax(false);
        Imposto__c tax2 = tax1.clone();
        List<Imposto__c> taxes = new List<Imposto__c>{tax1, tax2};
        TriggerHandler.clearBypass('ProductTriggerHandler');

        List<Database.SaveResult> results = Database.insert(taxes, false);

        Assert.isTrue(results[0].isSuccess());
        Assert.isFalse(results[1].isSuccess());
        Assert.isTrue(results[1].getErrors().size() > 0);
        Assert.areEqual('Este imposto é duplicata de outro nesta mesma inserção.', results[1].getErrors()[0].getMessage());
        
    }

    @IsTest 
    static void testOrgDuplicityOnInsert() {
        Imposto__c tax1 = TestDataFactory.createTax(false);
        Imposto__c tax2 = tax1.clone();
        TriggerHandler.clearBypass('ProductTriggerHandler');

        Database.insert(tax1);
        Database.SaveResult result = Database.insert(tax2, false);

        Assert.isFalse(result.isSuccess());
        Assert.isTrue(result.getErrors().size() > 0);
        Assert.areEqual('Já existe um imposto para esse produto nesse estado.', result.getErrors()[0].getMessage());
    }
    
}