import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpportunitiesWithLineItems from '@salesforce/apex/OpportunityAndProductListViewHelper.getOpportunitiesWithLineItems';
import searchOpportunity from '@salesforce/apex/OpportunityAndProductListViewHelper.searchOpportunity';
import deleteOpportunities from '@salesforce/apex/OpportunityAndProductListViewHelper.deleteOpportunities';
import deleteProducts from '@salesforce/apex/OpportunityAndProductListViewHelper.deleteProducts';
import { refreshApex } from '@salesforce/apex';

const COLS = [
    { 
        label: 'Name', 
        fieldName: 'link', 
        type: 'url', 
        typeAttributes: { 
            label: { fieldName: 'Name' } 
        }
    },
    { 
        label: 'Account', 
        fieldName: 'accountLink', 
        type: 'url', 
        typeAttributes: { 
            label: { fieldName: 'AccountName' } 
        }
    },
    { 
        label: 'Contact', 
        fieldName: 'contactLink', 
        type: 'url', 
        typeAttributes: { 
            label: { fieldName: 'ContactName' } 
        }
    },
    { label: 'Stage', fieldName: 'StageName' },
    { label: 'Close Date', fieldName: 'CloseDate' },
    { 
        label: 'Quantity', 
        fieldName: 'Quantity',
        type: 'number',
        hideDefaultActions: true
    },
    { 
        label: 'Unit Price', 
        fieldName: 'UnitPrice',
        type: 'currency',
        hideDefaultActions: true
    },
    { 
        label: 'Discount Price', 
        fieldName: 'DiscountPrice',
        type: 'currency',
        hideDefaultActions: true
    },
    {
        type: 'action',
        typeAttributes: { 
            rowActions: { 
                fieldName: 'availableActions' 
            } 
        }
    }
];

export default class OpportunityAndProductsListView extends LightningElement {
    cols = COLS;
    opportunities;
    wiredOpportunities;
    selectedRows = [];
    isDeleteModalOpen = false;
    isSingleDelete = false;
    selectedOpportunityId;
    selectedOpportunities = [];
    gridExpandedRows = [];
    productId;
    baseData;
    error;

    get selectedOpportunitiesLen() {
        if (this.selectedOpportunities == undefined) return 0;
        return this.selectedOpportunities.length;
    }

    get showDeleteSelected() {
        return this.selectedOpportunitiesLen > 0;
    }

    @wire(getOpportunitiesWithLineItems)
    opportunitiesWire(result) {
        this.wiredOpportunities = result;
        if (result.data) {
            this.opportunities = this.transformData(result.data);
            this.baseData = this.opportunities;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.opportunities = [];
            this.baseData = [];
            this.showToast('Error', 'Error loading opportunities', 'error');
        }
    }

    transformData(data) {
        return data.map(opp => {
            const actions = [
                { label: 'Delete', name: 'delete' }
            ];

            const opportunity = {
                id: opp.Id,
                Name: opp.Name,
                link: `/${opp.Id}`,
                AccountName: opp.AccountName__c,
                accountLink: `/${opp.AccountId}`,
                ContactName: opp.ContactLastName__c,
                contactLink: `/${opp.ContactId}`,
                StageName: opp.StageName,
                CloseDate: opp.CloseDate,
                availableActions: actions,
                _children: []
            };

            if (opp.OpportunityLineItems) {
                opportunity._children = opp.OpportunityLineItems.map(product => ({
                    id: product.Id,
                    Name: product.Product2.Name,
                    link: `/${product.Id}`,
                    Quantity: product.Quantity,
                    UnitPrice: product.UnitPrice,
                    DiscountPrice: product.Discount_Price__c,
                    availableActions: [{ label: 'Delete', name: 'delete_product' }],
                    _children: []
                }));
            }

            return opportunity;
        });
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        switch (actionName) {
            case 'delete':
                this.selectedOpportunityId = row.id;
                this.isSingleDelete = true;
                this.handleOpenDeleteModal();
                break;
            case 'delete_product':
                this.productId = row.id;
                this.handleDeleteProduct();
                break;
            default:
                break;
        }
    }

    async handleSearch(event) {
        try {
            const searchTerm = event.target.value;
            if (!searchTerm) {
                this.opportunities = this.baseData;
                return;
            }
            
            if (searchTerm.length > 0) {
                const searchResults = await searchOpportunity({ input: searchTerm });
                this.opportunities = this.transformData(searchResults);
            }
        } catch (error) {
            this.showToast('Error', 'Error performing search', 'error');
        }
    }

    handleOpenDeleteModal() {
        if (!this.isSingleDelete && this.selectedOpportunitiesLen === 0) {
            this.showToast('Warning', 'Please select opportunities to delete', 'warning');
            return;
        }
        this.isDeleteModalOpen = true;
    }

    handleCloseDeleteModal() {
        this.isDeleteModalOpen = false;
        this.isSingleDelete = false;
        this.selectedOpportunityId = null;
    }

    async handleDeleteProduct() {
        try {
            const result = await deleteProducts({ ids: [this.productId] });
            if (result) {
                this.showToast('Success', 'Product deleted successfully', 'success');
                await refreshApex(this.wiredOpportunities);
            }
        } catch (error) {
            this.showToast('Error', 'Failed to delete Product', 'error');
        }
    }

    async handleDelete() {
        try {
            const idsToDelete = this.isSingleDelete ? 
                [this.selectedOpportunityId] : 
                this.selectedOpportunities.map(row => row.id);

            const result = await deleteOpportunities({ ids: idsToDelete });
            
            if (result) {
                this.showToast('Success', 
                    `${this.isSingleDelete ? 'Opportunity' : 'Opportunities'} deleted successfully`, 
                    'success'
                );
                this.selectedRows = [];
                this.selectedOpportunities = [];
                await refreshApex(this.wiredOpportunities);
            }
        } catch (error) {
            this.showToast('Error', 'Failed to delete Opportunities', 'error');
        } finally {
            this.handleCloseDeleteModal();
        }
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows.map(row => row.id);
        this.selectedOpportunities = event.detail.selectedRows;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant
        }));
    }
}   