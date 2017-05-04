public with sharing class HWLaunchCoachController {
    public Id patientId{get;set;}
    String featuredrivervalue;
    
    public HWLaunchCoachController(){
        
        String recordId = ApexPages.currentPage().getParameters().get('recId');
        if(!Pattern.matches('003[0-9,a-z,A-Z]*', recordId)){

            if(HWUtil.canAccessHealthCloud()){
                
                Schema.SObjectType HCSettingMDT = Schema.getGlobalDescribe().get('HealthCloudGA__HealthCloudSetting__mdt');
                
                if(HCSettingMDT != null){
                    HCSettingMDT.newSObject();
                }
                List<sObject> featuredriverSetting; 
                
                featuredriverSetting = GenericDBService.fetchSObjects('select id,HealthCloudGA__Active__c,HealthCloudGA__SettingName__c,HealthCloudGA__SettingValue__c from HealthCloudGA__HealthCloudSetting__mdt where HealthCloudGA__SettingName__c = \'HcFeatureDriver\' LIMIT ' + Limits.getLimitDMLRows());
                
                if(featuredriverSetting != null && featuredriverSetting.size()>=1) {
                    sObject temp;
                    
                    for(sObject i : featuredriverSetting){
                        if((Boolean)i.get('HealthCloudGA__Active__c')){
                            temp = i;
                        }
                    }
                    
                    if(temp != null){
                        featuredrivervalue = (String)temp.get('HealthCloudGA__SettingValue__c');
                        
                        if(temp.get('HealthCloudGA__SettingValue__c') == 'Account'){
                            Schema.DescribeSObjectResult d = Schema.SObjectType.Contact;
                            Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
                            
                            if(!rtMapById.isEmpty()){                            
                            	try{
                                Contact pc = Database.query('select id from contact where accountId =: recordId and recordType.name = \'Individual\' limit 1');
                                if(pc != null)
                                    patientId = pc.id;
                            	}Catch(Exception e){
                            		
                            	} 
                            }
                        }else if(temp.get('HealthCloudGA__SettingValue__c') == 'Contact'){
                            patientId = recordId;
                        }
                    }
                    
                }
            }
        }else{
            patientId = recordId;
        }
    }
}