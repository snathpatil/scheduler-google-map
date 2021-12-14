({
    doInit: function (component, event, helper) {
        /*var optsCountry = [
            { value: "", label: "--None--" },
            { value: "United States", label: "United States" }
        ];
        component.set("v.optionsCountry", optsCountry);
        
        var optsState = [
            { value: "", label: "--None--" },
            { value: "CA", label: "CA" },
            { value: "NY", label: "NY" }
        ];
        component.set("v.optionsState", optsState);
        
        var optsCity = [
            { value: "", label: "--None--" },
            { value: "San Francisco", label: "San Francisco" },
            { value: "New York", label: "New York" }
        ];
        component.set("v.optionsCity", optsCity);
       
        //If city, state and country is pre-populated, search the location                  
        if(component.get("v.city") && component.get("v.state") && component.get("v.country")){
            
            component.set("v.selectedValueCountry", component.get("v.country"));
            component.set("v.selectedValueState", component.get("v.state"));
            component.set("v.selectedValueCity", component.get("v.city"));
            
            helper.searchLocation(component, event, helper); 
        }*/
        
        //default to mobile styling
        var mobileAndDesktopStyling = {
			header: 'slds-text-heading_medium',
			serviceTerritoryTitle: 'slds-text-heading_small'
        };
        //480px used to define mobile width. Min 481 or more is for larger form factors
        if(window.matchMedia("(min-width: 481px)").matches) {
            mobileAndDesktopStyling = {
				header: 'slds-text-heading_large',
				serviceTerritoryTitle: 'slds-text-heading_medium'
            };
          
        }
        component.set("v.mobileAndDesktopStyling",mobileAndDesktopStyling);
    },
    
    searchLocation: function (component, event, helper) {
        
      	//helper.searchLocation(component, event, helper); 
        helper.searchLocationByLatLang(component, event);
    },
    
    onMarkerSelect: function (component, event, helper) {
        component.set("v.serviceTerritoryId", event.getParam("selectedMarkerValue"));
    }
})