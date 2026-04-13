public with sharing class TemplateDefaultFields {
    public interface FieldDefaults {
        Map<String, Object> getFieldDefaults(Decimal countSObjectCreated);
    }

    // Minimal defaults for this repository demo tests.
    public class LeadDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'FirstName' => 'Intern',
                'LastName' => 'Demo ' + countSObjectCreated,
                'Company' => 'Taak Routter'
            };
        }
    }

    public class AccountDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Conta ' + countSObjectCreated,
                'CNPJ__c' => String.valueOf(countSObjectCreated).leftPad(14,'0')
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
                'Codigo__c' => String.valueOf(countSObjectCreated).leftPad(50,'X')
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
                'DataEntrega__c' => Date.today().addDays(countSObjectCreated),
                'TipoFrete__c' => 'CIF'
            };
        }
    }

}