public class TwilioApiClient {
    private static final String ACCOUNT_SID = 'ACb6afdea2baeb7830ba9947b1ea578f1e';
    private static final String AUTH_TOKEN = 'd333d62f174251edbb648a694172c41f';
    private static final String FROM_NUMBER = '+18609680131';

    public static void sendSms(String toNumber, String body) {
        TwilioSF.TwilioApiClient api = new TwilioSF.TwilioApiClient();
        api.addUrlPart('Accounts');
        api.addUrlPart(ACCOUNT_SID);
        api.addUrlPart('Messages.json');

        api.addParam('To',toNumber);
        api.addParam('From',FROM_NUMBER);
        api.addParam('Body','Here is my message');
        TwilioSF.TwilioApiClientResponse response = api.doPost();

        //Example with key value pairs
        String sid = response.getTwilioJsonParser().get('sid').getString();
        Integer totalSegments = response.getTwilioJsonParser().get('num_segments').getInteger();

        //Example a key with object
        String media = response.getTwilioJsonParser().get('subresource_uris').get('media').getString();
    }
}
