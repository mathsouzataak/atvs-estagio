public with sharing class ContaCorrente extends Conta implements Tributavel{
    
    public ContaCorrente(Integer numero, String nome) {
        super(numero, nome);
    }

    public override Decimal calculartaxa() {
        return saldo * 0.01;
    }

    public Decimal calcularImposto() {
        return saldo * 0.02;
    }

}