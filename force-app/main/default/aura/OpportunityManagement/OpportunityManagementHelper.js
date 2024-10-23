({
    saveOpportunity: function (component) {
        let opportunity = component.get("v.opportunity");
        let account = component.get("v.account");
        let contact = component.get("v.contact");
        let products = component.get("v.opportunityProducts");

        let action = component.get("c.createOpportunityWithRelatedRecords");
        action.setParams({
            opp: opportunity,
            acc: account,
            con: contact,
            oppProducts: products
        });

        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Opportunity was created successfully.",
                    "type": "success"
                });
                toastEvent.fire();
                
                this.clearForm(component);
            } else {
                let errors = response.getError();
                let errorMessage = errors[0] && errors[0].message ? errors[0].message : "Unknown error";
                let toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": errorMessage,
                    "type": "error"
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
    },

    clearForm: function(component) {
        component.set("v.opportunity", {
            'sobjectType': 'Opportunity',
            'Name': '',
            'AccountName__c': '',
            'ContactLastName__c': ''
        });

        component.set("v.account", {
            'sobjectType': 'Account'
        });

        component.set("v.contact", {
            'sobjectType': 'Contact'
        });

        component.set("v.opportunityProducts", []);

        component.set("v.selectedProduct", '');

        let inputFields = component.find('opportunityName');
        if (Array.isArray(inputFields)) {
            inputFields.forEach(field => {
                field.setCustomValidity('');
                field.reportValidity();
            });
        } else if (inputFields) {
            inputFields.setCustomValidity('');
            inputFields.reportValidity();
        }
    },

    addProduct: function (component) {
        let selectedProduct = component.get("v.selectedProduct");
        let productOptions = component.get("v.productOptions");
        let opportunityProducts = component.get("v.opportunityProducts");

        let product = productOptions.find(p => p.value === selectedProduct);
        if (product) {
            let existingProduct = opportunityProducts.find(p => p.Product2Id === product.value);
            if (existingProduct) {
                existingProduct.Quantity++;
            } else {
                opportunityProducts.push({
                    Product2Id: product.value,
                    Name: product.label,
                    Quantity: 1,
                    UnitPrice: 0
                });
            }
            component.set("v.opportunityProducts", opportunityProducts);
        }
    },

    deleteProduct: function (component, event) {
        let index = event.getSource().get("v.value");
        let opportunityProducts = component.get("v.opportunityProducts");
        opportunityProducts.splice(index, 1);
        component.set("v.opportunityProducts", opportunityProducts);
    },

    fetchProducts: function (component) {
        var action = component.get("c.getAllProducts");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.productOptions", response.getReturnValue());
            } else {
                console.error("Failed to fetch products: " + response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})