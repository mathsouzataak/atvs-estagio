// ======================================================
// PAÍSES
// ======================================================

List<Pais__c> paises = new List<Pais__c>();

paises.add(new Pais__c(Name = 'Brasil', Sigla__c = 'BR'));
paises.add(new Pais__c(Name = 'França', Sigla__c = 'FR'));
paises.add(new Pais__c(Name = 'Estados Unidos', Sigla__c = 'US'));

insert paises;

// ======================================================
// ESTADOS
// ======================================================

List<Estado__c> estados = new List<Estado__c> {
    new Estado__c(Name = 'Acre', Sigla__c = 'AC', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Alagoas', Sigla__c = 'AL', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Amapá', Sigla__c = 'AP', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Amazonas', Sigla__c = 'AM', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Bahia', Sigla__c = 'BA', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Ceará', Sigla__c = 'CE', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Distrito Federal', Sigla__c = 'DF', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Espírito Santo', Sigla__c = 'ES', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Goiás', Sigla__c = 'GO', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Maranhão', Sigla__c = 'MA', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Mato Grosso', Sigla__c = 'MT', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Mato Grosso do Sul', Sigla__c = 'MS', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Minas Gerais', Sigla__c = 'MG', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Pará', Sigla__c = 'PA', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Paraíba', Sigla__c = 'PB', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Paraná', Sigla__c = 'PR', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Pernambuco', Sigla__c = 'PE', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Piauí', Sigla__c = 'PI', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Rio de Janeiro', Sigla__c = 'RJ', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Rio Grande do Norte', Sigla__c = 'RN', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Rio Grande do Sul', Sigla__c = 'RS', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Rondônia', Sigla__c = 'RO', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Roraima', Sigla__c = 'RR', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Santa Catarina', Sigla__c = 'SC', Pais__c = paises[0].Id),
    new Estado__c(Name = 'São Paulo', Sigla__c = 'SP', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Sergipe', Sigla__c = 'SE', Pais__c = paises[0].Id),
    new Estado__c(Name = 'Tocantins', Sigla__c = 'TO', Pais__c = paises[0].Id)
};

insert estados;

// ======================================================
// CIDADES
// ======================================================

List<Cidade__c> cidades = new List<Cidade__c>{
    new Cidade__c(Name = 'Rio Branco', Codigo__c = '1200401', Estado__c = estados[0].Id), // Acre
    new Cidade__c(Name = 'Maceió', Codigo__c = '2704302', Estado__c = estados[1].Id), // Alagoas
    new Cidade__c(Name = 'Macapá', Codigo__c = '1600303', Estado__c = estados[2].Id), // Amapá
    new Cidade__c(Name = 'Manaus', Codigo__c = '1302603', Estado__c = estados[3].Id), // Amazonas
    new Cidade__c(Name = 'Salvador', Codigo__c = '2927408', Estado__c = estados[4].Id), // Bahia
    new Cidade__c(Name = 'Fortaleza', Codigo__c = '2304400', Estado__c = estados[5].Id), // Ceará
    new Cidade__c(Name = 'Brasília', Codigo__c = '5300108', Estado__c = estados[6].Id), // Distrito Federal
    new Cidade__c(Name = 'Vitória', Codigo__c = '3205309', Estado__c = estados[7].Id), // Espírito Santo
    new Cidade__c(Name = 'Goiânia', Codigo__c = '5208707', Estado__c = estados[8].Id), // Goiás
    new Cidade__c(Name = 'São Luís', Codigo__c = '2111300', Estado__c = estados[9].Id), // Maranhão
    new Cidade__c(Name = 'Cuiabá', Codigo__c = '5103403', Estado__c = estados[10].Id), // Mato Grosso
    new Cidade__c(Name = 'Campo Grande', Codigo__c = '5002704', Estado__c = estados[11].Id), // Mato Grosso do Sul
    new Cidade__c(Name = 'Belo Horizonte', Codigo__c = '3106200', Estado__c = estados[12].Id), // Minas Gerais
    new Cidade__c(Name = 'Belém', Codigo__c = '1501402', Estado__c = estados[13].Id), // Pará
    new Cidade__c(Name = 'João Pessoa', Codigo__c = '2507507', Estado__c = estados[14].Id), // Paraíba
    new Cidade__c(Name = 'Curitiba', Codigo__c = '4106902', Estado__c = estados[15].Id), // Paraná
    new Cidade__c(Name = 'Recife', Codigo__c = '2611606', Estado__c = estados[16].Id), // Pernambuco
    new Cidade__c(Name = 'Teresina', Codigo__c = '2211001', Estado__c = estados[17].Id), // Piauí
    new Cidade__c(Name = 'Rio de Janeiro', Codigo__c = '3304557', Estado__c = estados[18].Id), // Rio de Janeiro
    new Cidade__c(Name = 'Natal', Codigo__c = '2408102', Estado__c = estados[19].Id), // Rio Grande do Norte
    new Cidade__c(Name = 'Porto Alegre', Codigo__c = '4314902', Estado__c = estados[20].Id), // Rio Grande do Sul
    new Cidade__c(Name = 'Porto Velho', Codigo__c = '1100205', Estado__c = estados[21].Id), // Rondônia
    new Cidade__c(Name = 'Boa Vista', Codigo__c = '1400100', Estado__c = estados[22].Id), // Roraima
    new Cidade__c(Name = 'Florianópolis', Codigo__c = '4205407', Estado__c = estados[23].Id), // Santa Catarina
    new Cidade__c(Name = 'São Paulo', Codigo__c = '3550308', Estado__c = estados[24].Id), // São Paulo
    new Cidade__c(Name = 'Aracaju', Codigo__c = '2800308', Estado__c = estados[25].Id), // Sergipe
    new Cidade__c(Name = 'Palmas', Codigo__c = '1721000', Estado__c = estados[26].Id) // Tocantins
};

insert cidades;
