public with sharing class KeyStringGenerator {
    // Criação de strings de Ids concateenados

    public static String createStringKeyFromIds(Id id1, Id id2, Id id3) {
        return id1 + ':' + id2 + ':' + id3;
    }

    public static String createStringKeyFromIds(Id id1, Id id2, Id id3, Id id4) {
        return id1 + ':' + id2 + ':' + id3 + ':' + id4;
    }
}