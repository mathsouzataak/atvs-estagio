public with sharing class TemplateDefaultFields {
    public interface FieldDefaults {
        Map<String, Object> getFieldDefaults(Decimal countSObjectCreated);
    }

    public class AccountDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Conta ' + countSObjectCreated,
                'CNPJ__c' => String.valueOf(countSObjectCreated).leftPad(14,'0'),
                'ExternalId__c' => 'teste' + countSObjectCreated
            };
        }
    }

    public class AccountGroupDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Grupo de conta ' + countSObjectCreated,
                'Code__c' => 'test' + countSObjectCreated
            };
        }
    }
    
    public class Product2Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Produto ' + countSObjectCreated,
                'Codigo__c' => String.valueOf(countSObjectCreated).leftPad(50,'X'),
                'IsActive' => true,
                'ExternalId__c' => 'teste' + countSObjectCreated
            };
        }
    }

    public class HierarquiaProdutoDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Hierarquia de prod. ' + countSObjectCreated,
                'Codigo__c' => 'test' + countSObjectCreated
            };
        }
    }

    public class PaisDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'País ' + countSObjectCreated,
                'Sigla__c' => String.valueOf(countSObjectCreated).leftPad(5,'X')
            };
        }
    }

    public class EstadoDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Estado ' + countSObjectCreated,
                'Sigla__c' => String.valueOf(countSObjectCreated.hashCode()).right(2)
            };
        }
    }

    public class CidadeDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Estado ' + countSObjectCreated,
                'Codigo__c' => String.valueOf(countSObjectCreated).leftPad(7)
            };
        }
    }

    public class DistributionCenterDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'CD  ' + countSObjectCreated,
                'Code__c' => String.valueOf(countSObjectCreated).leftPad(30,'X')
            };
        }
    }

    public class ImpostoDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Status__c' => 'Aprovado',
                'ValorPercentual__c' => countSObjectCreated
            };
        }
    }

    public class FreteDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Status__c' => 'Aprovado',
                'Valor__c' => countSObjectCreated * 5
            };
        }
    }

    public class MargemDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Status__c' => 'Aprovado',
                'Valor__c' => countSObjectCreated * 10
            };
        }
    }

    public class OrderDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'EffectiveDate' => Date.today(),
                'DataEntrega__c' => Date.today().addDays(Integer.valueOf(countSObjectCreated)),
                'TipoFrete__c' => 'CIF',
                'Status' => 'New',
                'ExternalId__c' => 'teste' + countSObjectCreated
            };
        }
    }

    public class AccountAddressDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Code__c' => 'teste' + countSObjectCreated,
                'CEP__c' => '00000-111',
                'Logradouro__c' => 'Rua teste 67',
                'Bairro__c' => 'Bairro teste'
            };
        }
    }

    public class Pricebook2Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Test pricebook',
                'IsActive' => true,
                'ExternalId__c' => 'teste' + countSObjectCreated
            };
        }
    }


	public class PricebookEntryDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'UnitPrice' => 100,
				'ExternalId__c' => 'PricebookEntry' + countSObjectCreated
			};
		}
	}

    public class CondicaoPagamentoDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Test',
                'Codigo__c' => 'test' + countSObjectCreated
            };
        }
    }

    public class OrderItemDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'UnitPrice' => countSObjectCreated * 100,
                'Quantity' => Integer.valueOf(countSObjectCreated),
                'ExternalId__c' => 'teste' + countSObjectCreated
            };
        }
    }

    public class IntegrationSettingDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'IntegrationSettingName',
				'Method__c' => 'POST',
				'Endpoint__c' => 'Endpoint',
				'User__c' => UserInfo.getUserName(),
				'Password__c' => UserInfo.getUserName(),
				'Timeout__c' => 110000,
				'AccessToken__c' => 'AccessToken' + String.valueOf(Datetime.now()),
				'ClientId__c' => String.valueOf(Datetime.now()),
				'ClientSecret__c' => UserInfo.getUserName() + String.valueOf(Datetime.now()),
				'EndpointAccessToken__c' => 'EndpointAccessToken',
				'AccessTokenTime__c' => 360000,
				'LastAccessTokenTime__c' => Decimal.valueOf(Datetime.now().getTime())
			};
		}
	}

}