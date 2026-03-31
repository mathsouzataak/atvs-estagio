public with sharing class KeyStringGenerator {
    public static String createStringKeyFromIds(String key1, String key2) {
        return key1 + ':' + key2;
    }

    public static String createStringKeyFromIds(String key1, String key2, String key3) {
        return key1 + ':' + key2 + ':' + key3;
    }
}