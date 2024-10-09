@isTest
public class TestDataFactory {
    public static Opportunity createOpportunity() {
        Opportunity opp = new Opportunity(
            AccountName__c = 'Test Account',
            Name = 'Test Opportunity',
            CloseDate = Date.today().addDays(30),
            StageName = 'Qualification',
            ContactLastName__c = 'Test Contact'
        );
        
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

        return template;
    }
}