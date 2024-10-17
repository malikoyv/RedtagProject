public class QuotePDFController {
    
    @InvocableMethod
    public static List<Boolean> sendEmailWithAttachment(List<EmailService.EmailParams> paramsList) {
        List<Boolean> result = EmailService.sendEmailWithPDF(paramsList);
        return result;
    }
}
