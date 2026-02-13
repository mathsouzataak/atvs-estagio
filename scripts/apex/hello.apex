// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents


String tempvar = 'Matheus';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);


List<Conta> contas = new List<Conta>();
Set<Integer> numsContas = new Set<Integer>();
contas.add(new ContaCorrente(1, 'Carlos'));
contas.add(new ContaCorrente(2, 'João'));
contas.add(new ContaPoupanca(3, 'Luiz'));
numsContas.add(contas[0].numero);
numsContas.add(contas[1].numero);
numsContas.add(contas[2].numero);

Decimal totalTaxas = 0;

for (Conta conta : contas) {
    totalTaxas += conta.calculartaxa();
}

System.debug('Total de taxas: ' + totalTaxas);




Map<Integer, Conta> contasMap = new Map<Integer, Conta>();
for (Conta conta : contas) {
    contasMap.put(conta.numero, conta);
}

Conta conta = contasMap.get(2);

System.debug('Conta selecionada (2): ' + conta.nome);


contas[0].depositar(4500);
contas[1].depositar(100);
contas[2].depositar(3000);





