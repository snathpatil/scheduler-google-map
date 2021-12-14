({
    keyPressController: function (component, event, helper) {

        var searchKey = component.get("v.searchKey");

        helper.openListbox(component, searchKey);
        helper.displayOptionsLocation(component, searchKey);
    },

    selectOption: function (component, event, helper) {
        var selectedItem = event.currentTarget.dataset.record;
        console.log(selectedItem);
        var selectedValue = event.currentTarget.dataset.value;

        component.set("v.selectedOption", selectedItem);
       
        var searchLookup = component.find("searchLookup");
        $A.util.removeClass(searchLookup, 'slds-is-open');
        component.set("v.searchKey", selectedItem);
        
        helper.getLatLangInfo(component, selectedValue);

    },

    clear: function (component, event, helper) {
        helper.clearComponentConfig(component);
    }

})