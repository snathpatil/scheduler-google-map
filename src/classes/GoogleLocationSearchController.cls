/**
 * @author shantinath.patil
 * @since 2021
 */
 
public class GoogleLocationSearchController{
    public static string getGoogleMapsAPIKey(){
        string strKey = ''; //YOUR MAPS API KEY HERE
        return strKey;
    }
    @AuraEnabled
    public static string getAddressAutoComplete(String input, String types) {
        String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input='
            + EncodingUtil.urlEncode(input, 'UTF-8')
            +'&libraries=places&callback=initAutocomplete'+
            + '&key=' + GoogleLocationSearchController.getGoogleMapsAPIKey();
        return GoogleLocationSearchController.getHttp(url);
    }
    
    public static string getHttp(string strURL){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setMethod('GET');
        req.setEndpoint(strURL);
        req.setTimeout(120000);
        res = h.send(req);
        String responseBody = res.getBody();
        return responseBody;
    }
    
    @AuraEnabled
    public static String getAddressDetailsByPlaceId(String placeId){
        String apiKey = GoogleLocationSearchController.getGoogleMapsAPIKey();
        String result = null;
        try{
            if(placeId != null){
                String apiUrl = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=' + placeId.replace(' ', '%20') + '&key=' + apiKey; 
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setEndpoint(apiUrl);
                Http http = new Http();
                HttpResponse res = http.send(req);
                Integer statusCode = res.getStatusCode();
                if(statusCode == 200){
                    result = res.getBody();
                    System.debug(result);
                }
            }
        } catch(exception e){
            System.debug(e.getMessage());
        }
        return result;
    }
}