public with sharing class Conta {

    public int numero;
    public String nome;
    public Decimal saldo;

    public Conta(int numero, String nome) {
        this.numero = numero;
        this.nome = nome;
        saldo = 0;
    }

    public void depositar(Decimal valor) {
        if (valor > 0) {
            saldo += valor;
        } else {
            throw new Exception('Não é possível depositar valores iguais ou menores que zero.');
        }
    }
}