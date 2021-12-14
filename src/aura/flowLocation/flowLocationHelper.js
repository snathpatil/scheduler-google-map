({
    searchLocation: function (component) {
        
        var action = component.get("c.searchLocationString");
        action.setParams({ country : component.get("v.selectedValueCountry"),
                          state : component.get("v.selectedValueState"),
                          city : component.get("v.selectedValueCity"),
                          workTypeGroupId : component.get("v.workTypeGroupId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.mapMarkersData", ""); 
            if (state === "SUCCESS") {
                if(response.getReturnValue().length > 0){
                    component.set("v.city", component.get("v.selectedValueCity"));
                    component.set("v.state", component.get("v.selectedValueState"));
                    component.set("v.country", component.get("v.selectedValueCountry"));
                    component.set("v.errorMessage", "");
                    component.set("v.isError", "false");
                    component.set("v.mapMarkersData", response.getReturnValue()); 
                    component.set("v.markersTitle", "Available locations.");
                }else{
                    component.set("v.errorMessage", "Sorry! We are not servicing at your location yet.");
                    component.set("v.isError", "true");
                }
            } else if (state === "INCOMPLETE") {
                component.set("v.errorMessage", "Unknown error");
                component.set("v.isError", "true");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.errorMessage", JSON.parse(errors[0].message)[0].message);
                        component.set("v.isError", "true");
                    }
                } else {
                    component.set("v.errorMessage", "Unknown error");
                    component.set("v.isError", "true");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    searchLocationByLatLang: function (component, event) {
        
        component.set("v.isLoading", true);
        
        var action = component.get("c.searchLocationLatLang");
        action.setParams({ lat : event.getParam("lat"),
                          lang : event.getParam("lng"),
                          radious : '50',
                          workTypeGroupId : component.get("v.workTypeGroupId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.mapMarkersData", ""); 
            component.set("v.isLoading", false);
            if (state === "SUCCESS") {
                if(response.getReturnValue().length > 0){
                    
                    component.set("v.errorMessage", "");
                    component.set("v.isError", "false");
                    component.set("v.mapMarkersData", response.getReturnValue()); 
                    component.set("v.markersTitle", "Available locations.");
                }else{
                    component.set("v.errorMessage", "Sorry! We are not servicing at your location yet.");
                    component.set("v.isError", "true");
                }
            } else if (state === "INCOMPLETE") {
                component.set("v.errorMessage", "Unknown error");
                component.set("v.isError", "true");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.errorMessage", JSON.parse(errors[0].message)[0].message);
                        component.set("v.isError", "true");
                    }
                } else {
                    component.set("v.errorMessage", "Unknown error");
                    component.set("v.isError", "true");
                }
            }
        });
        $A.enqueueAction(action);
    },
})