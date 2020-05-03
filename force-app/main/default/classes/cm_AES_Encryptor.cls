public class cm_AES_Encryptor {
    
    // 16 bytes of zeroes
    static Blob iv = EncodingUtil.base64Decode('AAAAAAAAAAAAAAAAAAAAAA==');
    static String base64Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    static Map<string, Integer> base64 = new map<string, Integer>{'A'=>0,'B'=>1,'C'=>2,'D'=>3,'E'=>4,'F'=>5,'G'=>6,'H'=>7,'I'=>8,'J'=>9,'K'=>10,'L'=>11,'M'=>12,'N'=>13,'O'=>14,'P'=>15,'Q'=>16,'R'=>17,'S'=>18,'T'=>19,'U'=>20,'V'=>21,'W'=>22,'X'=>23,'Y'=>24,'Z'=>25,'a'=>26,'b'=>27,'c'=>28,'d'=>29,'e'=>30,'f'=>31,'g'=>32,'h'=>33,'i'=>34,'j'=>35,'k'=>36,'l'=>37,'m'=>38,'n'=>39,'o'=>40,'p'=>41,'q'=>42,'r'=>43,'s'=>44,'t'=>45,'u'=>46,'v'=>47,'w'=>48,'x'=>49,'y'=>50,'z'=>51,'0'=>52,'1'=>53,'2'=>54,'3'=>55,'4'=>56,'5'=>57,'6'=>58,'7'=>59,'8'=>60,'9'=>61,'+'=>62,'/'=>63};

    public class CryptoException extends Exception {
    
    }

    public class BlobSplitter {
        String base64encoding;
        Integer bytes; // size of the base 64 encoding
        Integer ptr = 0; // offset into the base64 encoding
       Integer numBits = 0; // offset into first byte of next block

        public BlobSplitter(Blob b) {
        	system.debug('b is --> '+b);
            base64encoding = EncodingUtil.base64Encode(b);
        	system.debug('base64encoding is --> '+base64encoding);
            // Remove any padding
            if (base64encoding.endsWith('==')){
                base64encoding = base64encoding.substring(0, base64encoding.length() - 2);
            } 
            else if (base64encoding.endsWith('=')){
                base64encoding = base64encoding.substring(0, base64encoding.length() - 1);
            }
            bytes = base64encoding.length();
        	system.debug('base64encoding is --> '+base64encoding);
        	system.debug('bytes is --> '+bytes);
        }

        public Blob getBlock() {
           return EncodingUtil.base64Decode(base64encoding.substring(0, bytes));
        }
    }
@TestVisible
    private static Blob joinBlocks(List<Blob> blocks) {
        String base64encoded = '';
        Integer numBits = 0;
        Integer lastBits;
        for (Integer i = 0; i < blocks.size(); i++) {
            if (numBits == 0) {
                String encodedBlock = EncodingUtil.base64encode(blocks[i]);
                base64encoded += encodedBlock.substring(0,128);
                lastBits = base64.get(encodedBlock.substring(128,129)) & 48;
                numBits = 4;
            } 
            else if (numBits == 4) {
                String encodedBlock = EncodingUtil.base64encode(blocks[i]);
                for (Integer j = 0; j < 128; j++) {
                    String thisChar = encodedBlock.substring(j, j + 1);
                    Integer thisCharIndex = lastBits | ((base64.get(thisChar) & 60) >>> 2);
                    base64encoded += base64Chars.substring(thisCharIndex, thisCharIndex + 1);
                    lastBits = (base64.get(thisChar) & 3) << 4;
                }
                lastBits = lastBits | ((base64.get(encodedBlock.substring(128,129)) & 48) >>> 2);
                numBits = 2;                
            } 
          else if (numBits == 2) {
                String encodedBlock = EncodingUtil.base64encode(blocks[i]);
                for (Integer j = 0; j < 129; j++) {
                    String thisChar = encodedBlock.substring(j, j + 1);
                    Integer thisCharIndex = lastBits | ((base64.get(thisChar) & 48) >>> 4);
                    base64encoded += base64Chars.substring(thisCharIndex, thisCharIndex + 1);
                    lastBits = (base64.get(thisChar) & 127) << 2;
                }
                numBits = 0;                
            }
        }
        base64encoded += base64Chars.substring(lastBits, lastBits + 1);

        return EncodingUtil.base64decode(base64encoded);
    }

    public static Blob encrypt(String algorithmName, Blob privateKey, Blob plainText) {
        if (algorithmName != 'AES128') {
            throw new CryptoException('Algorithm '+algorithmName+' not supported');
        }

        BlobSplitter bs = new BlobSplitter(plainText);
        System.debug('bs>>>>>>>>>>>>>>>>>'+bs);
        blob block = bs.getBlock();
        System.debug('block after get block is >>>>>>>>>>>>>>>>>'+block.toString());
        System.debug('PT: '+EncodingUtil.convertToHex(block));
        blob cipherText = Crypto.encrypt('AES128', privateKey, iv, block);
        System.debug('privateKey: '+privateKey);
        //System.debug('iv: '+iv.toString());
        System.debug('block: '+block);
        System.debug('cipherText: '+EncodingUtil.base64Encode(cipherText));
        System.debug('cipherText: '+cipherText);
        System.debug('CT: '+EncodingUtil.convertToHex(cipherText).toUpperCase());
        string converted = EncodingUtil.convertToHex(cipherText).toUpperCase();

        return cipherText;
    }

}