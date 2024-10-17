@IsTest
public class TestDataFactory {

    public static Account createAccount() {
        Account account = new Account(
            Name = 'Test Account'
        );
        insert account;
        return account;
    }

    public static Contact createContact(Id accountId) {
        Contact contact = new Contact(
            LastName = 'Test Contact',
            AccountId = accountId
        );
        insert contact;
        return contact;
    }

    public static Opportunity createOpportunity(Id accountId) {
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            CloseDate = Date.today().addDays(30),
            StageName = 'Qualification',
            AccountId = accountId
        );
        insert opp;
        return opp;
    }

    public static EmailTemplate createEmailTemplate() {
        EmailTemplate template = new EmailTemplate(
            Name = 'OpportunityDeletion12',
            DeveloperName = 'OpportunityDeletion12',
            TemplateType = 'text',
            FolderId = UserInfo.getUserId(),
            Subject = 'Opportunity Deleted: {!Opportunity.Name}',
            Body = 'The opportunity {!Opportunity.Name} has been deleted.'
        );
        insert template;
        return template;
    }

    public static Quote createQuote(Id accountId, Id contactId) {
        Quote quote = new Quote(
            Name = 'Test Quote',
            ContactId = contactId,
            Status = 'Draft'
        );
        insert quote;

        return quote;
    }

    public static EmailService.EmailParams createEmailParams(Id quoteId) {
        EmailService.EmailParams params = new EmailService.EmailParams();
        params.toAddress = 'test@example.com';
        params.subject = 'Test Quote PDF';
        params.body = 'Please find the attached quote PDF.';
        params.attachmentName = 'TestQuote.pdf';
        params.recordId = quoteId;
        
        return params;
    }
}
