public with sharing class OrderItemHelper {
    
    public static void atribuirParametros(List<OrderItem> itens) {
        atribuirImposto(itens);
        atribuirFrete(itens);
    }    

    public static void atribuirImposto(List<OrderItem> itens) {
        
        // Sets com ids para query dos produtos e pedidos associados aos novos itens
        Set<Id> idsProdutos = new Set<Id>();
        Set<Id> idsPedidos = new Set<Id>();
        for (OrderItem item : itens) {
            idsProdutos.add(item.Product2Id);
            idsPedidos.add(item.OrderId);
        }
        
        // Map relacionando id dos pedidos com o id do estado do endereço de sua conta
        Map<Id,Id> mapPedidoEstado = new Map<Id,Id>();
        for (Order pedido : [SELECT Id, AccountAddress__c FROM Order WHERE Id IN :idsPedidos]) {
            mapPedidoEstado.put(pedido.Id, pedido.AccountAddress__r.Cidade__r.Estado__c);
        }
        
        // Listagem de impostos para os produtos e estados dos itens
        List<Imposto__c> impostos = [SELECT Id, Estado__c, Product__c, ValorPercentual__c 
                                        FROM Imposto__c 
                                        WHERE (Status__c = 'Aprovado' AND Estado__c IN :mapPedidoEstado.values() AND Product__c IN :idsProdutos)];
        
        for (OrderItem item : itens) {
            Imposto__c impostoAplicado;
            // Busca por impostos que correspondam ao estado e produto do item
            for (Imposto__c imposto : impostos) {
                if (imposto.Product__c == item.Product2Id && imposto.Estado__c == mapPedidoEstado.get(item.OrderId)) {
                    impostoAplicado = imposto;
                    break;
                }
            }
            
            if (impostoAplicado != null) {
                item.ImpostoPercent__c = impostoAplicado.ValorPercentual__c;
            } else { // Não foi encontrado imposto correspondente 
                item.addError('O produto não possui imposto aplicável no estado do pedido.');
            }
        }
    }

    public static void atribuirFrete(List<OrderItem> itens) {
        // Sets com ids para query dos produtos e pedidos associados aos novos itens
        Set<Id> idsProdutos = new Set<Id>();
        Set<Id> idsPedidos = new Set<Id>();
        for (OrderItem item : itens) {
            idsProdutos.add(item.Product2Id);
            idsPedidos.add(item.OrderId);
        }
        
        // Map relacionando id dos pedidos com a cidade do endereço de sua conta
        Map<Id,Cidade__c> mapPedidoCidade = new Map<Id,Cidade__c>();
        Set<Id> idsCidade = new Set<Id>();
        Set<Id> idsEstado = new Set<Id>();
        Set<Id> idsPais = new Set<Id>();
        for (Order pedido : [SELECT Id, AccountAddress__c FROM Order WHERE Id IN :idsPedidos]) {
            mapPedidoCidade.put(pedido.Id, pedido.AccountAddress__r.Cidade__r);
            idsCidade.add(pedido.AccountAddress__r.Cidade__c);
            idsEstado.add(pedido.AccountAddress__r.Cidade__r.Estado__c);
            idsPais.add(pedido.AccountAddress__r.Cidade__r.Estado__r.Pais__c);
        }

        // Mapa de produtos relacionados aos itens
        Map<Id,Product2> mapProduto = new Map<Id,Product2>();
        Set<Id> idsHierarquias = new Set<Id>();
        for (Product2 produto : [SELECT Id, HierarquiaProduto__c
                                    FROM Product2
                                    WHERE Id IN :idsProdutos]) {
            mapProduto.put(produto.Id, produto);
            idsHierarquias.add(produto.HierarquiaProduto__c);
        }
        
        // Listagem de fretes correspondentes aosnparâmetros dos itens
        List<Frete__c> fretes = [SELECT Id, Cidade__c, Estado__c, Pais__c, Product__c, HierarquiaProduto__c, Valor__c, CreatedDate 
                                        FROM Frete__c 
                                        WHERE (Status__c = 'Aprovado' AND 
                                            (Cidade__c IN :idsCidade OR Estado__c IN :idsEstado OR Pais__c IN :idsPais) AND 
                                            (Product__c IN :idsProdutos OR HierarquiaProduto__c IN :idsHierarquias))];
        
        for (OrderItem item : itens) {
            Frete__c freteAplicado;
            // Busca por impostos que melhor correspondam ao produto e localidade do item
            for (Frete__c frete : fretes) {
                if (frete.Product__c == item.Product2Id) {
                    if (frete.Cidade__c == mapPedidoCidade.get(item.OrderId).Id) {
                        if (String.isBlank(freteAplicado?.Cidade__c) || frete.CreatedDate > freteAplicado.CreatedDate) {
                            freteAplicado = frete;
                        }
                    } else if (frete.Estado__c == mapPedidoCidade.get(item.OrderId).Estado__c) {
                        if (String.isBlank(freteAplicado?.Cidade__c) && String.isBlank(freteAplicado?.Estado__c)
                            || frete.CreatedDate > freteAplicado.CreatedDate) {
                            freteAplicado = frete;
                        }
                    } else if (frete.Pais__c == mapPedidoCidade.get(item.OrderId).Estado__r.Pais__c) {
                        if (frete.CreatedDate > freteAplicado.CreatedDate) {
                            freteAplicado = frete;
                        }
                    }
                } else if (frete.HierarquiaProduto__c == mapProduto.get(item.Product2Id).HierarquiaProduto__c) {
                    if (String.isNotBlank(freteAplicado?.Product__c)) {
                        continue;
                    }

                    if (frete.Cidade__c == mapPedidoCidade.get(item.OrderId).Id) {
                        if (String.isBlank(freteAplicado?.Cidade__c) || frete.CreatedDate > freteAplicado.CreatedDate) {
                            freteAplicado = frete;
                        }
                    } else if (frete.Estado__c == mapPedidoCidade.get(item.OrderId).Estado__c) {
                        if (String.isBlank(freteAplicado?.Cidade__c) && String.isBlank(freteAplicado?.Estado__c)
                            || frete.CreatedDate > freteAplicado.CreatedDate) {
                            freteAplicado = frete;
                        }
                    } else if (frete.Pais__c == mapPedidoCidade.get(item.OrderId).Estado__r.Pais__c) {
                        if (frete.CreatedDate > freteAplicado.CreatedDate) {
                            freteAplicado = frete;
                        }
                    }
                }
            }
            
            if (freteAplicado != null) {
                item.ValorFrete__c = freteAplicado.Valor__c;
            } else {
                item.addError('O produto não possui frete aplicável para a localidade do pedido.');
            }
        }
    }
    
}