public with sharing class PokemonCallout implements Queueable, Database.AllowsCallouts{

    public String endpoint;

    public PokemonCallout() {
        this.endpoint = 'https://pokeapi.co/api/v2/pokemon';
    }

    private PokemonCallout(String endpoint) {
        this.endpoint = endpoint;
    }

    public void execute(QueueableContext context) {

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Accept', 'application/json');

        Http http = new Http();
        HttpResponse response = http.send(request);

        Map<String, Object> responseJsonBody = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
        String newEndpoint = (String) responseJsonBody.get('next');
        List<Object> pokemonList = (List<Object>) responseJsonBody.get('results');

        List<Pokemon__c> pokemonsForInsert = new List<Pokemon__c>();

        for (Object pokemonJson : (List<Object>) pokemonList) {
            Map<String,Object> pokemonMap = (Map<String,Object>) pokemonJson;
            pokemonsForInsert.add(new Pokemon__c(Name = (String) pokemonMap.get('name'), Url__c = (String) pokemonMap.get('url')));
        }

        Database.insert(pokemonsForInsert);

        if (!String.isBlank(newEndpoint)) {
            PokemonCallout nextCallout = new PokemonCallout(newEndpoint);
            System.enqueueJob(nextCallout);
        }
    }

}