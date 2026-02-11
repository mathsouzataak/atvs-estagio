public with sharing class ContaCorrente extends Conta{
    public ContaCorrente(Integer numero, String nome) {
        super(numero, nome);
    }

    public Decimal calculartaxa() {
        return saldo * 0.01;
    }
}