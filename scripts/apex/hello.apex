// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents


String tempvar = 'Matheus';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);


ContaCorrente conta = new ContaCorrente(25, 'Beltrano');
conta.depositar(4000);
conta.sacarTryCatch(50000);
System.debug(conta.saldo);

// SeguroDeVida seguro = new SeguroDeVida();
// System.debug(seguro.calcularImposto());
