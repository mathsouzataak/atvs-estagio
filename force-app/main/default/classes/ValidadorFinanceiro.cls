public with sharing class ValidadorFinanceiro {

    public static Boolean validarValor(Decimal valor) {
        if (valor > 0) {
            return true;
        } else {
            throw new IllegalArgumentException('O valor deve ser maior que zero');
        }
    }
}