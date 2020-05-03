/***********************************************************************************************
* Name              : xmlnsOracleComPcbpelAdapterDbDmlX_Test                                                 
* Description       : Test class for xmlnsOracleComPcbpelAdapterDbDmlX                                             
* Created Date      : 04/06/2018                                                    
* Created By        : Adeel Ahmad (adeel.ahmad@weare4c.com)    
* Jira/Req By       :                                                                                                                                         
* ----------------------------------------------------------------------------------------------
* VERSION   Developer   Date        Description     Ticket/Reference                                                                    
* 1.0       Adeel       04/06/2018  Created                              
************************************************************************************************/
@IsTest
public with sharing class xmlnsOracleComPcbpelAdapterDbDmlX_Test {
	private static testMethod void coverOutputs(){
        new xmlnsOracleComPcbpelAdapterDbDmlX.DML_XXEMR_DIS_STMT_DETAILS_VOutput();
    }
    
    private static testMethod void coverInputs(){
        new xmlnsOracleComPcbpelAdapterDbDmlX.DML_XXEMR_DIS_STMT_DETAILS_VInput();
    }
    
    private static testMethod void coverConnection(){
        new xmlnsOracleComPcbpelAdapterDbDmlX.DML_XXEMR_DIS_STMT_DETAILS_VOutputCollection();
    }
}