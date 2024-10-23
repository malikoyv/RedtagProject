import { LightningElement , wire} from 'lwc';
import getOpportunities from '@salesforce/apex/OpportunityAndProductListViewHelper.getOpportunities';
import searchOpportunity from '@salesforce/apex/OpportunityAndProductListViewHelper.searchOpportunity';
import deleteOpportunities from '@salesforce/apex/OpportunityAndProductListViewHelper.deleteOpportunities';
import { refreshApex } from '@salesforce/apex';

const ACTIONS = [{label: 'Delete', name: 'delete'}];

const COLS = [{label: 'Name', fieldName: 'link', type: 'url', typeAttributes: {label: {fieldName: 'Name'}}},
            {label: 'Account', fieldName: 'accountLink', type: 'url', typeAttributes: {label: {fieldName: 'AccountName'}}},
            {label: 'Contact', fieldName: 'contactLink', type: 'url', typeAttributes: {label: {fieldName: 'ContactName'}}},
            {label: 'Stage', fieldName: 'StageName'},
            {label: 'Close Date', fieldName: 'CloseDate'},
            {fieldName: 'actions', type: 'action', typeAttributes: {rowActions: ACTIONS}}
];

export default class OpportunityAndProductsListView extends LightningElement {
    cols = COLS;
    opportunities;
    wiredOpportunities;
    selectedOpportunities;
    baseData;

    get selectedOpportunitiesLen(){
        if (this.selectedOpportunities == undefined) return 0;
        return this.selectedOpportunities.length;
    }

    @wire(getOpportunities)
    opportunitiesWire(result){
        this.wiredOpportunities = result;
        if (result.data) {
            this.opportunities = result.data.map((row) => {
                return this.mapOpportunities(row)
            })
            this.baseData = this.opportunities;
        }
        if (result.error){
            console.error(result.error);
        }
    }

    mapOpportunities(row){
        console.log(row);

        return {...row,
            Name: `${row.Name}`,
            link: `/${row.Id}`,
            AccountName: `${row.AccountName__c}`,
            accountLink: `/${row.AccountId}`,
            ContactName: `${row.ContactLastName__c}`,
            contactLink: `/${row.ContactId}`
        }
    }

    handleRowSelection(event){
        this.selectedOpportunities = event.detail.selectedRows;
    }

    async handleSearch(event) {
        if (event.target.value == ""){ // the base state of the table
            this.opportunities = this.baseData;
        } else if (event.target.value.length > 1){
            const searchOpportunities = await searchOpportunity({input: event.target.value});

            this.opportunities = searchOpportunities.map(row => {
                return this.mapOpportunities(row);
            })
        }
    }

    handleRowAction(event){
        deleteOpportunities({ids: [event.detail.row.Id]}).then(() => {
            refreshApex(this.wiredOpportunities);
        })
    }

    deleteSelectedOpportunities(){
        const idList = this.selectedOpportunities.map(row =>{
            return row.Id;
        })

        deleteOpportunities({ids: idList}).then(() => refreshApex(this.wiredOpportunities));
        this.template.querySelector('lightning-datatable').selectedRows = [];
        this.selectedOpportunities = undefined;
    }
}