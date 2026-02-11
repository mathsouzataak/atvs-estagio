public abstract with sharing class Conta {

    public Integer numero;
    public String nome;
    public Decimal saldo;

    public Conta(Integer numero, String nome) {
        this.numero = numero;
        this.nome = nome;
        saldo = 0;
    }

    public void depositar(Decimal valor) {
        if (valor > 0) {
            saldo += valor;
        } else {
            throw new IllegalArgumentException('Não é possível depositar valores iguais ou menores que zero.');
        }
    }

    public abstract Decimal calculartaxa(){
        
    }
}