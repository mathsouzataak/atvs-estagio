public with sharing class CadastroDeContas {

    private static final List<Conta> contas = new List<Conta>();

    public static void adicionarConta(Conta conta) {
        contas.add(conta);
    }

    public static String listarContas() {
        String lista;
        for (Conta conta : contas) {
            lista += '[' + conta.numero + ']\t' + conta.nome + '\tSaldo: ' + conta.saldo.toString() + '\n'; 
        }

        return lista;
    }
}