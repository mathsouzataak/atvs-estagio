public with sharing class PokemonCallout implements Queueable, Database.AllowsCallouts{

    public String endpoint;

    public PokemonCallout() {
        this.endpoint = 'https://pokeapi.co/api/v2/pokemon';
    }

    private PokemonCallout(String endpoint) {
        this.endpoint = endpoint;
    }

    public void execute(QueueableContext context) {

        List<Pokemon__c> pokemonsForInsert = new List<Pokemon__c>();
        String newEndpoint = endpoint;

        for (Integer i = 0; i < 20; i++) {
            if (String.isBlank(newEndpoint)) {
                break;
            }

            Map<String, Object> responseJsonBody = PokemonService.getPokemons(newEndpoint);

            newEndpoint = (String) responseJsonBody.get('next');
            List<Object> pokemonList = (List<Object>) responseJsonBody.get('results');

            for (Object pokemonJson : (List<Object>) pokemonList) {
                Map<String,Object> pokemonMap = (Map<String,Object>) pokemonJson;
                pokemonsForInsert.add(new Pokemon__c(Name = (String) pokemonMap.get('name'), Url__c = (String) pokemonMap.get('url')));
            }
        }



        Database.insert(pokemonsForInsert, false);

        if (!String.isBlank(newEndpoint)) {
            PokemonCallout nextCallout = new PokemonCallout(newEndpoint);
            System.enqueueJob(nextCallout);
        }
    }

}