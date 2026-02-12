public abstract with sharing class Conta {

    public static Integer totalDeContas;

    public Integer numero;
    public String nome;
    public Decimal saldo;

    public Conta(Integer numero, String nome) {
        this.numero = numero;
        this.nome = nome;
        saldo = 0;

        totalDeContas++;
    }

    public void depositar(Decimal valor) {
        if (ValidadorFinanceiro.validarValor(valor)) {
            saldo += valor;
        }
    }

    public abstract Decimal calculartaxa();

    public static Decimal calcularTaxas(List<Conta> lista) {
        Decimal totalTaxas = 0;
        for (Conta conta : lista) {
            totalTaxas += conta.saldo * conta.calculartaxa();
        }

        return totalTaxas;
    }
}