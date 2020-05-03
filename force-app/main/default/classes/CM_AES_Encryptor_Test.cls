@isTest
public class CM_AES_Encryptor_Test {
    
    static testmethod void encryptor(){
        cm_AES_Encryptor encry = new cm_AES_Encryptor();
        Blob base=Blob.valueOf('Unit Test Attachment Body');
        cm_AES_Encryptor.BlobSplitter bcls = new cm_AES_Encryptor.BlobSplitter(base);  
        
        Blob b1=Blob.valueOf('0000000000000000');
        Blob b2=Blob.valueOf('0000000000000000');
        
        Blob b3=Blob.valueOf('0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000');
        Blob b4=Blob.valueOf('0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000');
        list<blob> blst = new list<blob>();
        blst.add(b3);
        blst.add(b4);
        
      cm_AES_Encryptor.encrypt('AES128',b1,b2);
      //cm_AES_Encryptor.joinBlocks(blst);
      
    }
    
    static testmethod void encryptorSecond(){
       
        cm_AES_Encryptor encry = new cm_AES_Encryptor();
        Blob base=Blob.valueOf('Unit Test Attachment Body=');
        cm_AES_Encryptor.BlobSplitter bcls = new cm_AES_Encryptor.BlobSplitter(base); 
       // bcls.numBits=2;
       String vals = '';
       for(Integer i=0;i<128;i++) {
           vals += i;
       }
       
        
        Blob b1=Blob.valueOf(' 00');
        Blob b2=Blob.valueOf('00');
        Blob b3=Blob.valueOf(vals);
       
        list<blob> blst = new list<blob>();
       list<blob> bls = new list<blob>(); 
        blst.add(b3);
        blst.add(b3);
        bls.add(b3);
       
       //cm_AES_Encryptor.encrypt('AES128',b1,b2);
       try{
       cm_AES_Encryptor.joinBlocks(blst);
       }catch(exception e){}
       //cm_AES_Encryptor.joinBlocks(bls); 
    }
}