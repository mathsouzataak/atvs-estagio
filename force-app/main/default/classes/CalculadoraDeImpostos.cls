public with sharing class CalculadoraDeImpostos {
    public CalculadoraDeImpostos() {
        
    }

    public Decimal calcularImpostos(List<Tributavel> tributaveis) {
        Decimal total = 0;
        for (Tributavel tributavel : tributaveis) {
            total += tributavel.calcularImposto();
        }
        return total;
    }
}