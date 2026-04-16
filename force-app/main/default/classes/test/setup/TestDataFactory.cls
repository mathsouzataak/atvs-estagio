@IsTest
public with sharing class TestDataFactory {


    // +++++++++++++++++++++++++++++++++
    // Create AccountGroup
    // +++++++++++++++++++++++++++++++++

    public static AccountGroup__c createAccountGroup(Boolean doInsert) {
        AccountGroup__c accountGroup = (AccountGroup__c)TestFactorySObject.getInstance().createSObject(new AccountGroup__c());
        if (doInsert) {
            Database.insert(accountGroup);
        }

        return accountGroup;
    }


    // +++++++++++++++++++++++++++++++++
    // Create Account
    // +++++++++++++++++++++++++++++++++

    public static Account createAccount(Id accountGroupId, Boolean doInsert) {
        Account account = (Account)TestFactorySObject.getInstance().createSObject(new Account(AccountGroup__c = accountGroupId));
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
        HierarquiaProduto__c productHierarchy = (HierarquiaProduto__c)TestFactorySObject.getInstance().createSObject(new HierarquiaProduto__c());
        if (doInsert) {
            Database.insert(productHierarchy);
        }
        
        return productHierarchy;
    }


    // +++++++++++++++++++++++++++++++++
    // Create Product
    // +++++++++++++++++++++++++++++++++

    public static Product2 createProduct(Id productHierarchyId, Boolean doInsert) {
        Product2 product = (Product2)TestFactorySObject.getInstance().createSObject(new Product2(HierarquiaProduto__c = productHierarchyId, CustoProducao__c = 5));
        if (doInsert) {
            Database.insert(product);
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
        Pais__c country = (Pais__c)TestFactorySObject.getInstance().createSObject(new Pais__c());
        if (doInsert) {
            Database.insert(country);
        }

        return country;
    }


    // +++++++++++++++++++++++++++++++++
    // Create Estado
    // +++++++++++++++++++++++++++++++++

    public static Estado__c createState(Id countryId, Boolean doInsert) {
        Estado__c state = (Estado__c)TestFactorySObject.getInstance().createSObject(new Estado__c(Pais__c = countryId));
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
        Cidade__c city = (Cidade__c)TestFactorySObject.getInstance().createSObject(new Cidade__c(Estado__c = stateId));
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
        DistributionCenter__c distCenter = (DistributionCenter__c)TestFactorySObject.getInstance().createSObject(new DistributionCenter__c());
        if (doInsert) {
            Database.insert(distCenter);
        }

        return distCenter;
    }


    // +++++++++++++++++++++++++++++++++
    // Create Imposto
    // +++++++++++++++++++++++++++++++++

    public static Imposto__c createTax(Id productId, Id stateId, Id distCenterId, Boolean doInsert) {
        Imposto__c tax = (Imposto__c)TestFactorySObject.getInstance().createSObject(new Imposto__c());
        tax.Product__c = productId;
        tax.Estado__c = stateId;
        tax.CentroDistribuicao__c = distCenterId;
        if (doInsert) {
            Database.insert(tax);
        }

        System.debug(tax);
        return tax;
    }

    public static Imposto__c createTax(Boolean doInsert) {
        return createTax(createProduct(true).Id, createState(true).Id, createDistCenter(true).Id, doInsert);
    }


    // +++++++++++++++++++++++++++++++++
    // Create Frete
    // +++++++++++++++++++++++++++++++++

    public static Frete__c createFreight(Id productId, Id locationId, Id distCenterId, Boolean doInsert) {
        Frete__c freight = (Frete__c)TestFactorySObject.getInstance().createSObject(new Frete__c());

        if (productId.getSObjectType() == Product2.sObjectType) {
            freight.Product__c = productId;
        } else {
            freight.HierarquiaProduto__c = productId;
        }

        if (locationId.getSObjectType() == Cidade__c.sObjectType) {
            freight.Cidade__c = locationId;
        } else if (locationId.getSObjectType() == Estado__c.sObjectType) {
            freight.Estado__c = locationId;
        } else {
            freight.Pais__c = locationId;
        }

        freight.CentroDistribuicao__c = distCenterId;

        if (doInsert) {
            Database.insert(freight);
        }

        System.debug(freight);

        return freight;
    }

    public static Frete__c createFreight(Boolean doInsert) {
        return createFreight(createProduct(true).Id, createCity(true).Id, createDistCenter(true).Id, doInsert);
    }


    // +++++++++++++++++++++++++++++++++
    // Create Margem
    // +++++++++++++++++++++++++++++++++

    public static Margem__c createMargin(Id productId, Id accountId, Id locationId, Id distCenterId, Boolean doInsert) {
        Margem__c margin = (Margem__c)TestFactorySObject.getInstance().createSObject(new Margem__c());

        if (productId.getSObjectType() == Product2.sObjectType) {
            margin.Product__c = productId;
        } else {
            margin.HierarquiaProduto__c = productId;
        }

        if (accountId.getSobjectType() == Account.sObjectType) {
            margin.Account__c = accountId;
        } else {
            margin.AccountGroup__c = accountId;
        }

        if (locationId.getSObjectType() == Cidade__c.sObjectType) {
            margin.Cidade__c = locationId;
        } else if (locationId.getSObjectType() == Estado__c.sObjectType) {
            margin.Estado__c = locationId;
        } else {
            margin.Pais__c = locationId;
        }

        margin.CentroDistribuicao__c = distCenterId;

        if (doInsert) {
            Database.insert(margin);
        }

        System.debug(margin);

        return margin;
    }

    public static Margem__c createMargin(Boolean doInsert) {
        return createMargin(createProduct(true).Id, createAccount(true).Id, createCity(true).Id, createDistCenter(true).Id, doInsert);
    }


    // +++++++++++++++++++++++++++++++++
    // Create AccountAddress
    // +++++++++++++++++++++++++++++++++

    public static AccountAddress__c createAddress(Id accountId, Id cidadeId, Boolean doInsert) {
        AccountAddress__c address = (AccountAddress__c)TestFactorySObject.getInstance().createSObject(new AccountAddress__c());
        address.Account__c = accountId;
        address.Cidade__c = cidadeId;

        if (doInsert) {
            Database.insert(address);
        }

        return address;
    }

    public static AccountAddress__c createAddress(Boolean doInsert) {
        return createAddress(createAccount(true).Id, createCity(true).Id, doInsert);
    }


    // +++++++++++++++++++++++++++++++++
    // Create CondicaoPagamento
    // +++++++++++++++++++++++++++++++++

    public static CondicaoPagamento__c createPaymentCondition(Boolean doInsert) {
        CondicaoPagamento__c condition = (CondicaoPagamento__c)TestFactorySObject.getInstance().createSObject(new CondicaoPagamento__c());

        if (doInsert) {
            Database.insert(condition);
        }

        return condition;
    }


    // +++++++++++++++++++++++++++++++++
    // Create Pricebook2
    // +++++++++++++++++++++++++++++++++

    public static Pricebook2 createPricebook(Boolean doInsert) {
        Pricebook2 pricebook = (Pricebook2)TestFactorySObject.getInstance().createSObject(new Pricebook2());
        if (doInsert) {
            Database.insert(pricebook);
        }

        return pricebook;
    }

    public static PricebookEntry createPricebookEntry(Pricebook2 pricebook, Product2 product, Boolean doInsert) {
        PricebookEntry pricebookEntry = PricebookHelper.createPricebookEntryForInsertion(pricebook, product);

        if (doInsert) {
            Database.insert(pricebookEntry);
        }

        return pricebookEntry;
    }    


    // +++++++++++++++++++++++++++++++++
    // Create Order
    // +++++++++++++++++++++++++++++++++

    public static Order createOrder(Id accountId, Id addressId, Id distCenterId, Id pricebookId, Id payConditionId, Boolean doInsert) {
        Order order = (Order)TestFactorySObject.getInstance().createSObject(new Order());
        order.AccountId = accountId;
        order.AccountAddress__c = addressId;
        order.CentroDistribuicao__c = distCenterId;
        order.Pricebook2Id = pricebookId;
        order.CondicaoPagamento__c = payConditionId;

        if (doInsert) {
            Database.insert(order);
        }

        return order;
    }

    public static Order createOrder(Boolean doInsert) {
        Account account = createAccount(true);
        return createOrder(account.Id, createAddress(account.Id, createCity(true).Id, true).Id, createDistCenter(true).Id, PricebookHelper.getStandardPricebook().Id, createPaymentCondition(true).Id, doInsert);
    }


    // +++++++++++++++++++++++++++++++++
    // Create OrderItem
    // +++++++++++++++++++++++++++++++++

    public static OrderItem createOrderItem(Id productId, Id orderId, PricebookEntry pricebookEntry, Boolean doInsert) {
        OrderItem orderItem = (OrderItem)TestFactorySObject.getInstance().createSObject(new OrderItem());
        orderItem.Product2Id = productId;
        orderItem.OrderId = orderId;
        orderItem.PricebookEntryId = priceBookEntry.Id;
        orderItem.ListPrice = pricebookEntry.UnitPrice;

        if(doInsert) {
            Database.insert(orderItem); 
        }

        return orderItem;
    }

    public static OrderItem createOrderItem(Boolean doInsert) {
        Account account = createAccount(true);
        Pricebook2 pricebook = PricebookHelper.getStandardPricebook();
        Order order = createOrder(account.Id, createAddress(account.Id, createCity(true).Id, true).Id, createDistCenter(true).Id, pricebook.Id, createPaymentCondition(true).Id, doInsert);
        TriggerHandler.bypass('ProductTriggerHandler');
        Product2 product = createProduct(true);
        TriggerHandler.bypass('ProductTriggerHandler');
        return createOrderItem(product.Id, createOrder(true).Id, createPricebookEntry(pricebook, product, true), doInsert);
    }
}