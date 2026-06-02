public with sharing class PokemonService {

    public static Map<String,Object> getPokemons(String endpoint) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Accept', 'application/json');

        Http http = new Http();
        HttpResponse response = http.send(request);

        return (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
    }
}