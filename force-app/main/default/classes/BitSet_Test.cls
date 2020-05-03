/***********************************************************************************************
* Name              : BitSet_Test                                                 
* Description       : Test class for BitSet                                             
* Created Date      : 30/05/2018                                                    
* Created By        : Divya Chary (divya.chary@were4c.com)    
* Jira/Req By       :                                                                                                                                         
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Divya       30/05/2018  Created                              
************************************************************************************************/
@isTest
private class BitSet_Test{  
    @isTest
    static void BitSet_Test(){    
      List < Integer > nList = new List < Integer >();
        nList.add(1);
       
        Test.startTest();
         BitSet bs = new BitSet();
         bs.testBits('pValidFor', nList);
 
         Test.stopTest();
    }  
    
    
     @isTest
    static void BitSet_Test2(){
        List < Integer > nList2 = new List < Integer >();  
         nList2.add(0);
         BitSet bs = new BitSet();
        bs.testBits('pValidFor', nList2);
    }
}