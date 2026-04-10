@IsTest
public with sharing class TestDataFactory {

    private static TestFactorySObject testFactorySObject;
    private static TestFactorySObject getFactory() {
        if (testFactorySObject == null) {
            testFactorySObject = new TestFactorySObject();
        }
        return testFactorySObject;
    }
    
    // +++++++++++++++++++++++++++++++++
    // Create AccountGroup
    // +++++++++++++++++++++++++++++++++

    public static AccountGroup__c createAccountGroup(Boolean doInsert) {
        AccountGroup__c accountGroup = (AccountGroup__c)getFactory().createSObject(new AccountGroup__c());
        if (doInsert) {
            Database.insert(accountGroup);
        }

        return accountGroup;
    }


    // +++++++++++++++++++++++++++++++++
    // Create Account
    // +++++++++++++++++++++++++++++++++

    public static Account createAccount(Id accountGroupId, Boolean doInsert) {
        Account account = (Account)getFactory().createSObject(new Account(AccountGroup__c = accountGroupId));
        if (doInsert) {
            Database.insert(account);
        }

        return account;
    }

    public static Account createAccount(Boolean doInsert) {
        return createAccount(createAccountGroup(true).Id, doInsert);
    }


    // +++++++++++++++++++++++++++++++++
    // Create HierarquiaProduto
    // +++++++++++++++++++++++++++++++++

    public static HierarquiaProduto__c createProductHierarchy(Boolean doInsert) {
        HierarquiaProduto__c productHierarchy = (HierarquiaProduto__c)getFactory().createSObject(new HierarquiaProduto__c());
        if (doInsert) {
            Database.insert(productHierarchy);
        }
        
        return productHierarchy;
    }


    // +++++++++++++++++++++++++++++++++
    // Create Product
    // +++++++++++++++++++++++++++++++++

    public static Product2 createProduct(Id productHierarchyId, Boolean doInsert) {
        Product2 product = (Product2)getFactory().createSObject(new Product2(HierarquiaProduto__c = productHierarchyId, CustoProducao__c = 5));
        if (doInsert) {
            TriggerHandler.bypass('ProductTriggerHandler');
            Database.insert(product);
            TriggerHandler.clearBypass('ProductTriggerHandler');
        }

        return product;
    }

    public static Product2 createProduct(Boolean doInsert) {
        return createProduct(createProductHierarchy(true).Id, doInsert);
    }


    // +++++++++++++++++++++++++++++++++
    // Create Pais
    // +++++++++++++++++++++++++++++++++

    public static Pais__c createCountry(Boolean doInsert) {
        Pais__c country = (Pais__c)getFactory().createSObject(new Pais__c());
        if (doInsert) {
            Database.insert(country);
        }

        return country;
    }


    // +++++++++++++++++++++++++++++++++
    // Create Estado
    // +++++++++++++++++++++++++++++++++

    public static Estado__c createState(Id countryId, Boolean doInsert) {
        Estado__c state = (Estado__c)getFactory().createSObject(new Estado__c(Pais__c = countryId));
        if (doInsert) {
            Database.insert(state);
        }

        return state;
    }

    public static Estado__c createState(Boolean doInsert) {
        return createState(createCountry(true).Id, doInsert);
    }


    // +++++++++++++++++++++++++++++++++
    // Create Cidade
    // +++++++++++++++++++++++++++++++++

    public static Cidade__c createCity(Id stateId, Boolean doInsert) {
        Cidade__c city = (Cidade__c)getFactory().createSObject(new Cidade__c(Estado__c = stateId));
        if (doInsert) {
            Database.insert(city);
        }

        return city;
    }

    public static Cidade__c createCity(Boolean doInsert) {
        return createCity(createState(true).Id, doInsert);
    }


    // +++++++++++++++++++++++++++++++++
    // Create DistributionCenter
    // +++++++++++++++++++++++++++++++++

    public static DistributionCenter__c createDistCenter(Boolean doInsert) {
        DistributionCenter__c distCenter = (DistributionCenter__c)getFactory().createSObject(new DistributionCenter__c());
        if (doInsert) {
            Database.insert(distCenter);
        }

        return distCenter;
    }


    // +++++++++++++++++++++++++++++++++
    // Create Imposto
    // +++++++++++++++++++++++++++++++++

    public static Imposto__c createTax(Id productId, Id stateId, Id distCenterId, Boolean doInsert) {
        Imposto__c tax = new Imposto__c(Product__c = productId, Estado__c = stateId, CentroDistribuicao__c = distCenterId, ValorPercentual__c = 3, Status__c = 'Aprovado');
        if (doInsert) {
            Database.insert(tax);
        }

        return tax;
    }

    public static Imposto__c createTax(Boolean doInsert) {
        return createTax(createProduct(true).Id, createState(true).Id, createDistCenter(true).Id, doInsert);
    }


    // +++++++++++++++++++++++++++++++++
    // Create Frete
    // +++++++++++++++++++++++++++++++++

    public static Frete__c createFreight(Id productId, Id locationId, Id distCenterId, Boolean doInsert) {
        Frete__c freight = new Frete__c(Valor__c = 40, Status__c = 'Aprovado');
        if (productId.getSObjectType() == Frete__c.Product__c.getDescribe().getSObjectType()) {
            freight.Product__c = productId;
        } else {
            freight.HierarquiaProduto__c = productId;
        }


        return freight;
    }
}