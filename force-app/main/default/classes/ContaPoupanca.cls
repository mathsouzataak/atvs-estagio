public with sharing class ContaPoupanca extends Conta {
    public ContaPoupanca(Integer numero, String nome) {
        super(numero, nome);
    }
    
    public override Decimal calculartaxa() {
        return saldo * 0.005;
    }
}