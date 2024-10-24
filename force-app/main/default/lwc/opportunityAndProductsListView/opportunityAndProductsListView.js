import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getOpportunities from '@salesforce/apex/OpportunityAndProductListViewHelper.getOpportunities';
import searchOpportunity from '@salesforce/apex/OpportunityAndProductListViewHelper.searchOpportunity';
import deleteOpportunities from '@salesforce/apex/OpportunityAndProductListViewHelper.deleteOpportunities';
import getAllProducts from '@salesforce/apex/OpportunityManagementController.getAllProducts';
import { refreshApex } from '@salesforce/apex';

const ACTIONS = [{ label: 'Delete', name: 'delete' },
                { label: 'Open Products', name: 'products' }];

const PRODUCT_ACTIONS = [{ label: 'Delete', name: 'delete' }];

const COLS = [{ label: 'Name', fieldName: 'link', type: 'url', typeAttributes: { label: { fieldName: 'Name' } } },
            { label: 'Account', fieldName: 'accountLink', type: 'url', typeAttributes: { label: { fieldName: 'AccountName' } } },
            { label: 'Contact', fieldName: 'contactLink', type: 'url', typeAttributes: { label: { fieldName: 'ContactName' } } },
            { label: 'Stage', fieldName: 'StageName' },
            { label: 'Close Date', fieldName: 'CloseDate' },
            { fieldName: 'actions', type: 'action', typeAttributes: { rowActions: ACTIONS } }];

const PRODUCT_COLS = [{ label: 'Name', fieldName: 'link', type: 'url', typeAttributes: { label: { fieldName: 'Name' } } },
                    { label: 'Quantity', fieldName: 'quantity' },
                    { label: 'UnitPrice', fieldName: 'unitPrice', type: 'currency' },
                    { label: 'DiscountPrice', fieldName: 'discountPrice', type: 'currency' },
                    { fieldName: 'actions', type: 'action', typeAttributes: { rowActions: PRODUCT_ACTIONS } }];

export default class OpportunityAndProductsListView extends LightningElement {
    cols = COLS;
    product_cols = PRODUCT_COLS;
    opportunities;
    wiredOpportunities;
    selectedOpportunities;
    baseData;
    isDeleteModalOpen = false;
    isSingleDelete = false;
    selectedOpportunityId;

    wiredProducts;
    products;
    selectedProducts;

    get selectedOpportunitiesLen() {
        if (this.selectedOpportunities == undefined) return 0;
        return this.selectedOpportunities.length;
    }

    @wire(getOpportunities)
    opportunitiesWire(result) {
        this.wiredOpportunities = result;
        if (result.data) {
            this.opportunities = result.data.map((row) => this.mapOpportunities(row));
            this.baseData = this.opportunities;
        }
        if (result.error) {
            console.error(result.error);
        }
    }

    @wire(getAllProducts)
    productsWire(result) {
        this.wiredProducts = result;
        if (result.data) {
            this.products = result.data.map((row) => this.mapProducts(row));
            this.baseData += this.products;
        }
        if (result.error) {
            console.error(result.error);
        }
    }

    mapProducts(row) {
        return {
            ...row,
            Name: `${row.Name}`,
            link: `${row.Id}`,
            quantity: `${row.Quantity}`,
            unitPrice: `${row.Quantity}`,
            discountPrice: `${row.Discount_Price__c}`
        };
    }

    mapOpportunities(row) {
        return {
            ...row,
            Name: `${row.Name}`,
            link: `/${row.Id}`,
            AccountName: `${row.AccountName__c}`,
            accountLink: `/${row.AccountId}`,
            ContactName: `${row.ContactLastName__c}`,
            contactLink: `/${row.ContactId}`
        };
    }

    handleRowSelection(event) {
        this.selectedOpportunities = event.detail.selectedRows;
    }

    async handleSearch(event) {
        if (event.target.value == "") {
            this.opportunities = this.baseData;
        } else if (event.target.value.length > 1) {
            const searchOpportunities = await searchOpportunity({ input: event.target.value });
            this.opportunities = searchOpportunities.map(row => this.mapOpportunities(row));
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (actionName === 'delete') {
            this.selectedOpportunityId = row.Id;
            this.isSingleDelete = true;
            this.handleOpenDeleteModal();
        }
    }

    handleOpenDeleteModal() {
        this.isDeleteModalOpen = true;
    }

    handleCloseDeleteModal() {
        this.isDeleteModalOpen = false;
    }

    handleDelete() {
        if (this.isSingleDelete) {
            deleteOpportunities({ ids: [this.selectedOpportunityId] }).then(() => {
                this.showToast('Success', 'Opportunity deleted successfully', 'success');
                refreshApex(this.wiredOpportunities);
            }).catch(() => {
                this.showToast('Error', 'Failed to delete Opportunity', 'error');
            });
        } else {
            const idList = this.selectedOpportunities.map(row => row.Id);
            deleteOpportunities({ ids: idList }).then(() => {
                this.showToast('Success', 'Opportunities deleted successfully', 'success');
                refreshApex(this.wiredOpportunities);
            }).catch(() => {
                this.showToast('Error', 'Failed to delete Opportunities', 'error');
            });
        }

        this.handleCloseDeleteModal();
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}
