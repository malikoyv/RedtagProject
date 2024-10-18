public class QuotePDFController {
    
    @InvocableMethod(label='Send Email with Quote PDF')
    public static List<Results> sendEmailWithAttachment(List<EmailParams> params) {
        List<Results> results = new List<Results>();
        List<Boolean> isSuccess = new List<Boolean>{false};
        String pageName = 'QuotePDF';
        
        for (EmailParams param : params) {
            List<Messaging.SendEmailResult> sendResult = EmailService.sendEmailWithPDF(
                param.recordId, 
                param.toAddress, 
                param.subject, 
                param.body, 
                param.attachmentName, 
                pageName
            );

            Results result = new Results();
            result.isSuccess = true;
            results.add(result);
        }

        return results;
    }

    public class EmailParams {
        @InvocableVariable(required=true)
        public String toAddress;
        
        @InvocableVariable(required=true)
        public String subject;
        
        @InvocableVariable(required=true)
        public String body;
        
        @InvocableVariable(required=true)
        public String attachmentName;
        
        @InvocableVariable(required=true)
        public Id recordId;
    }

    public class Results {
        @InvocableVariable(label='Email Sent Success' required=true)
        public Boolean isSuccess;
    }
}