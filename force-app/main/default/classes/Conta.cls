public with sharing class Conta {

    public int numero;
    public String nome;
    public Decimal saldo;

    public Conta(int numero, String nome) {
        this.numero = numero;
        this.nome = nome;
        saldo = 0;
    }
}