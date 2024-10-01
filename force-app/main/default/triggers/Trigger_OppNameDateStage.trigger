trigger Trigger_OppNameDateStage on Opportunity (before insert) {

    for (Opportunity opp : Trigger.new) {
        if (opp.AccountName__c != null) {
            opp.Name = opp.AccountName__c + ' ' + String.valueOf(Date.today().month()) + '/' + 
                       String.valueOf(Date.today().day()) + '/' + 
                       String.valueOf(Date.today().year());
        } else {
            opp.Name = 'No Account ' + String.valueOf(Date.today().month()) + '/' + 
                       String.valueOf(Date.today().day()) + '/' + 
                       String.valueOf(Date.today().year());
        }
        
        opp.StageName = 'Prospecting';
        
        opp.CloseDate = Date.today().addDays(90);
    }
}
