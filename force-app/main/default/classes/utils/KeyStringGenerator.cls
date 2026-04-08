public with sharing class KeyStringGenerator {
    // Criação de strings de Ids concateenados

    public static String createStringKeyFromIds(Id key1, Id key2) {
        return key1 + ':' + key2;
    }

    public static String createStringKeyFromIds(Id key1, Id key2, Id key3) {
        return key1 + ':' + key2 + ':' + key3;
    }

    public static String createStringKeyFromIds(Id key1, Id key2, Id key3, Id key4) {
        return key1 + ':' + key2 + ':' + key3 + ':' + key4;
    }
}