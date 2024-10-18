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
            AccountId = accountId,
            ContactLastName__c = 'test contact',
            AccountName__c = 'test account'
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

    public static Quote createQuote(Id opportunityId, Id contactId) {
        Quote quote = new Quote(
            OpportunityId = opportunityId,
            Name = 'Test Quote',
            ContactId = contactId,
            Status = 'Draft'
        );
        insert quote;
        return quote;
    }

    public static QuotePDFController.EmailParams createEmailParams(Id quoteId) {
        QuotePDFController.EmailParams params = new QuotePDFController.EmailParams();
        params.toAddress = 'test@example.com';
        params.subject = 'Test Quote PDF';
        params.body = 'Please find the attached quote PDF.';
        params.attachmentName = 'TestQuote.pdf';
        params.recordId = quoteId;
        
        return params;
    }
}