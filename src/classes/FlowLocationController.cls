/**
 * @author shantinath.patil
 * @since 2021
 */

public with sharing class FlowLocationController {
    public static final String NAMED_CRED = 'callout:salesforceAuth';
    public static final String TERRITORY_ENDPOINT_WTG = '/services/data/v48.0/connect/scheduling/service-territories?workTypeGroupId=';

    @AuraEnabled
    public static list<ServiceTerritoryWrapper> searchLocationString(String country, String state, String city, String workTypeGroupId){
        return getLocation(country, state, city, workTypeGroupId, null, null, null);
    }

    @AuraEnabled
    public static list<ServiceTerritoryWrapper> searchLocationLatLang(String lat, String lang, String radious, String workTypeGroupId){
        return getLocation(null, null, null, workTypeGroupId, lat, lang, radious);
    }
    
    private static list<ServiceTerritoryWrapper> getLocation(String country, String state, String city, String workTypeGroupId, String lat, String lang, String radious){
        
        //ServiceTerritoryResponse serviceTerrRes = getServiceTerritoryDetails(workTypeGroupId);
        ServiceTerritoryResponse serviceTerrRes = getServiceTerritoryDetailsLatLang(lat, lang, radious, workTypeGroupId);
        
        if(serviceTerrRes != NULL){
            Set<Id> serviceTerritoryIds = new Set<Id>();
            
            //Get all Service Territory Ids from API response
            for(ServiceTerritoryResponse.ServiceTerritories territory : serviceTerrRes.result.serviceTerritories){
                serviceTerritoryIds.add(territory.id);
            }
            
            //We need to do additional query to get custom fields data from Service Territory
            /*Map<Id, ServiceTerritory> serviceTerritoryMap = new Map<Id, ServiceTerritory>([SELECT Id, Name, Description, Country, City, TerritoryLogo__c, 
                                                                                                  PostalCode, Street, State, OperatingHoursId
                                                                                             FROM ServiceTerritory
                                                                                            WHERE Country =: country
                                                                                              AND State =: state
                                                                                              AND City =: city
                                                                                              AND Id IN: serviceTerritoryIds]);*/

            Map<Id, ServiceTerritory> serviceTerritoryMap = new Map<Id, ServiceTerritory>([SELECT Id, Name, Description, Country, City, TerritoryLogo__c, 
                                                                                                  PostalCode, Street, State, OperatingHoursId
                                                                                             FROM ServiceTerritory
                                                                                            WHERE Id IN: serviceTerritoryIds]);

            //Collect all Operating Hour Ids
            Set<Id> operatingHoursIds = new Set<Id>();
            for(ServiceTerritory serviceTerritory : serviceTerritoryMap.values()){
                operatingHoursIds.add(serviceTerritory.OperatingHoursId);
            }
            
            //Get all TimeSlot entries for Operating Hour
            Map<Id, Map<String, String>> operatingHoursMap = new Map<Id, Map<String, String>>(); 
            for(OperatingHours opHours: [SELECT Id, Name, 
                                                (SELECT Id, DayOfWeek, StartTime, EndTime 
                                                  FROM TimeSlots) 
                                           FROM OperatingHours 
                                          WHERE Id IN: operatingHoursIds]){
                operatingHoursMap.put(opHours.Id, getTimeSlots(opHours.TimeSlots));
            }
            
            //Create HTML tags for displaying Operating Hours
            Map<Id, String> operatingHoursDescMap = new Map<Id, String>(); 
            for(Id id : operatingHoursMap.keySet()){
                String hours = '<p>';
                for(String opHours : operatingHoursMap.get(id).keySet()){
                    hours+= '<strong>'+opHours+':</strong> '+operatingHoursMap.get(id).get(opHours)+'<br/>';
                }
                hours+='</p>';
                operatingHoursDescMap.put(id, hours);
            }
            
            //Fill the wrapper needed for Map component
            List<ServiceTerritoryWrapper> serviceTerritoryWrapper = new List<ServiceTerritoryWrapper>();
            for(ServiceTerritory serviceTerritory : serviceTerritoryMap.values()){
                // first create "AddressWrapper" instance and set appropriate values
                AddressWrapper addressWrap = new AddressWrapper();
                addressWrap.Street = serviceTerritory.Street;
                addressWrap.PostalCode = serviceTerritory.PostalCode;
                addressWrap.City = serviceTerritory.City;
                addressWrap.State = serviceTerritory.State;
                addressWrap.Country = serviceTerritory.Country;
                
                // create "ServiceTerritoryWrapper" instance, set values and add to final list. 
                ServiceTerritoryWrapper territoryWrapper = new ServiceTerritoryWrapper();
                territoryWrapper.icon = serviceTerritory.TerritoryLogo__c;
                territoryWrapper.title = serviceTerritory.Name;
                //Add description after operating hours
                String description = (serviceTerritory.Description != NULL)?''+serviceTerritory.Description:'';
                territoryWrapper.description = operatingHoursDescMap.get(serviceTerritory.OperatingHoursId)+description;
                territoryWrapper.location = addressWrap;
                territoryWrapper.value = serviceTerritory.Id;
                serviceTerritoryWrapper.add(territoryWrapper);
            }
            
            return serviceTerritoryWrapper;            
        }
        
        return null;
        
    }
    
    private static ServiceTerritoryResponse getServiceTerritoryDetails(String workTypeGroupId){
        
        String restAPIURL  = NAMED_CRED+TERRITORY_ENDPOINT_WTG+workTypeGroupId;
        
        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('GET');   
        httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());  
        httpRequest.setHeader('Content-Type','application/json');
        httpRequest.setHeader('Accept','application/json');
        httpRequest.setEndpoint(restAPIURL);
        
        Http http = new Http();    
        HttpResponse httpResponse = http.send(httpRequest);   
        if (httpResponse.getStatusCode() == 200 ) { 
            return ServiceTerritoryResponse.parse(httpResponse.getBody());
        } else {   
            throw new CalloutException( httpResponse.getBody() );  
        }  
    }

    private static ServiceTerritoryResponse getServiceTerritoryDetailsLatLang(String lat, String lang, String radious, String workTypeGroupId){
        
        //connect/scheduling/service-territories?workTypeGroupId=0VSRM000000009Z4AQ&latitude=37.79332&longitude=-122.392761&radius=50&radiusUnit=km&sortBy=Distance&sortOrder=asc

        String restAPIURL  = NAMED_CRED+TERRITORY_ENDPOINT_WTG+workTypeGroupId;
        restAPIURL+= '&latitude='+lat;
        restAPIURL+= '&longitude='+lang;
        restAPIURL+= '&radius='+50;
        restAPIURL+= '&radiusUnit=km&sortBy=Distance&sortOrder=asc';

        HttpRequest httpRequest = new HttpRequest();  
        httpRequest.setMethod('GET');   
        httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());  
        httpRequest.setHeader('Content-Type','application/json');
        httpRequest.setHeader('Accept','application/json');
        httpRequest.setEndpoint(restAPIURL);
        
        Http http = new Http();    
        HttpResponse httpResponse = http.send(httpRequest);   
        if (httpResponse.getStatusCode() == 200 ) { 
            return ServiceTerritoryResponse.parse(httpResponse.getBody());
        } else {   
            throw new CalloutException( httpResponse.getBody() );  
        }  
    }
    
    private static Map<String, String> getTimeSlots(List<TimeSlot> timeSlots){
        Map<String, String> mapDayToTime = new Map<String, String>();
        
        //Init map with all available values in DayOfWeek picklist to maintain order of days
        for(String dayOfWeek : getPickListValuesIntoList()){
            mapDayToTime.put(dayOfWeek, NULL);
        }
        
        Date tempDate = System.now().date();
        for(TimeSlot slot: timeSlots){
            DateTime startSlot = DateTime.newInstance(tempDate,  slot.StartTime);
            DateTime endSlot = DateTime.newInstance(tempDate,  slot.EndTime);
            mapDayToTime.put(slot.DayOfWeek, startSlot.format().replace(startSlot.date().format(), '').trim().replace(',','')+
                             ' - '+endSlot.format().replace(endSlot.date().format(), '').trim().replace(',',''));
        }
        
        //Cleanup map
        for(String item: mapDayToTime.keySet()){
            if(mapDayToTime.get(item) == null){
                mapDayToTime.remove(item);
            }
        }
        return mapDayToTime;
    }
    
    private static List<String> getPickListValuesIntoList(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = TimeSlot.DayOfWeek.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    public class ServiceTerritoryWrapper{
        @AuraEnabled 
        public string icon{get;set;} 
        @AuraEnabled 
        public string title{get;set;} 
        @AuraEnabled 
        public string description{get;set;} 
        @AuraEnabled 
        public string value{get;set;} 
        //We can use below parameters to further customize map markers
        /*@AuraEnabled 
        public string type {get;set;} 
        @AuraEnabled 
        public string radius {get;set;} 
        @AuraEnabled 
        public string strokeColor {get;set;} 
        @AuraEnabled 
        public string strokeOpacity {get;set;} 
        @AuraEnabled 
        public string strokeWeight {get;set;} 
        @AuraEnabled 
        public string fillColor {get;set;} 
        @AuraEnabled 
        public string fillOpacity {get;set;} */
        @AuraEnabled 
        public AddressWrapper location{get;set;} 
    }
    
    /* sub wrapper class to store location details for "ServiceTerritoryWrapper" location property.*/ 
    public class AddressWrapper{
        @AuraEnabled 
        public string Street{get;set;}
        @AuraEnabled 
        public string PostalCode{get;set;}
        @AuraEnabled 
        public string City{get;set;}
        @AuraEnabled 
        public string State{get;set;}
        @AuraEnabled 
        public string Country{get;set;}
    }
}