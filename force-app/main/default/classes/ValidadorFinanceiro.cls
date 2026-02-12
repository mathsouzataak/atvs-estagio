public with sharing class ValidadorFinanceiro {

    public static void validarValor(Decimal valor) {
        if (valor <= 0) {
            throw new IllegalArgumentException('O valor deve ser maior que zero');
        }
    }
}