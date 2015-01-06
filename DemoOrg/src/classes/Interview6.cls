public class Interview6
{
    public string Latitude { get; set; }
    public String Longitude { get; set; }
    public String City { get; set; }
    public String State { get; set; }
    public String HTTP_Response{ get; set; }
    public String Type{ get; set; }
    
    public pagereference Submit()
    {
        string  url;
        
        if('XML'.equals(Type))
        {
            url = 'https://maps.googleapis.com/maps/api/geocode/xml?address=' + City+'+'+State+'&key=AIzaSyBPCSYfdx9WwKwhfzDkhi_qa4xB5IT9h-k'; 
            httprequest(url);
        }
        else
        {
            url = 'https://maps.googleapis.com/maps/api/geocode/json?address=' + City+'+'+State+'&key=AIzaSyBPCSYfdx9WwKwhfzDkhi_qa4xB5IT9h-k'; 
            jsonrequest(url);
        }
        return null;
    }
    
   public void jsonrequest(String url)
   {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url); 
        req.setMethod('GET');
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        HTTP_Response = res.getBody();
        
        JSONParser parser = JSON.createParser(HTTP_Response);
        
       INTEGER I = 0;
       while(parser.nextToken() != NULL)
       {  
            If( parser.getCurrentName() == 'location')     
            {
                parser.nextToken();
                parser.nextToken();
                
              If( parser.getCurrentName() == 'lat')     
              {                  
                  parser.nextToken();
                  Latitude = parser.getText();
                  parser.getDoubleValue();
              }
              parser.nextToken();
              parser.nextToken();
                 
              If( parser.getCurrentName() == 'lng')     
              {                
                  Longitude = parser.getText(); 
              }
            }
        }   
   }
    
    public void httprequest(string url)
    {      
       // string url = 'https://maps.googleapis.com/maps/api/geocode/xml?address=ahmedabad+gujarat&key=AIzaSyBqm1Fg_MwsvidRjrQ85IMbxSAe1zdcZg4';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);       
        System.debug(url);
        
        req.setMethod('GET');
        System.debug(url+req);
          
         Http http = new Http();
         HTTPResponse res = http.send(req);
         HTTP_Response = res.getBody();
         dom.Document doc = res.getBodyDocument();        
         
        
        integer i = 0;
    /*    
        for(dom.XmlNode node : doc.getRootElement().getChildElements())
        {
            i++;
              System.debug(node.getName());
               System.debug(node.getNameSpace());                             
            
        }
     */
          dom.XmlNode node =  doc.getRootElement().getChildElement('result',NULL);      
          node =  node.getChildElement('geometry',NULL);
          node = node.getChildElement('location',NULL);
          System.debug(node.getName());
          Latitude = node.getChildElement('lat',NULL).getText();
          Longitude = node.getChildElement('lng',NULL).getText();        
    }
}