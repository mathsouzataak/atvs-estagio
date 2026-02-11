// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

String tempvar = 'Matheus';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

// Instantiate using the Conta class defined in force-app/main/default/classes/Conta.cls
Conta contazinha = new Conta(34, 'Pedro Paulo Pedroso');

// Access the public property 'nome'
System.debug('O nome da conta é ' + contazinha.nome);
