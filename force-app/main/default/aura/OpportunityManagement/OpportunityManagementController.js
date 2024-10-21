({
    doInit: function (component, event, helper) {
        helper.fetchProducts(component);
    },

    saveOpportunity: function (component, event, helper) {
        helper.saveOpportunity(component);
    },

    addProduct: function (component, event, helper) {
        helper.addProduct(component);
    },

    deleteProduct: function (component, event, helper) {
        helper.deleteProduct(component, event);
    }
})
