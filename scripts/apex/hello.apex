// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents


String tempvar = 'Matheus';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

//Conta conta = new Conta(34, 'Pedro Paulo Pedroso');
//CadastroDeContas.adicionarConta(conta);



String lista = CadastroDeContas.listarContas();

System.debug(lista);
