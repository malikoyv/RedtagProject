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

    addProduct: function (component) {
        let selectedProduct = component.get("v.selectedProduct");
        let productOptions = component.get("v.productOptions");
        let opportunityProducts = component.get("v.opportunityProducts");

        let product = productOptions.find(p => p.value === selectedProduct);
        if (product) {
            opportunityProducts.push({
                Product2Id: product.value,
                Name: product.label,
                Quantity: 1,
                UnitPrice: 0
            });
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
