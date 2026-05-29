public with sharing class DevUserHelper {
    
    public static List<DevUser__c> getDevUsersGithubData(List<DevUser__c> devUsers) {
        List<DevUser__c> devUsersWithData = new List<DevUser__c>();

        for (DevUser__c iDevUser : devUsers) {
            String responsePayload = getGithubUserData(iDevUser.Login__c);

            Map<String,Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responsePayload);

            iDevUser.ExternalId__c = (Integer) responseMap.get('id');
            iDevUser.Type__c = (String) responseMap.get('type');
            iDevUser.Bio__c = (String) responseMap.get('bio');

            devUsersWithData.add(iDevUser);
        }

        return devUsersWithData;
    }

    public static String getGithubUserData(String login) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.github.com/users/' + login);
        request.setMethod('GET');
        request.setHeader('Accept', 'application/vnd.github+json');

        HttpResponse response = http.send(request);

        System.debug('Callout response: ' + response);

        System.debug('Body: ' + response.getBody());

        return response.getBody();
    }

}