public class TwilioApiClient {


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
