global class Egy_NumberHelper {
    
    private static final String[] numNames = new String[]{
                    '',
                        ' one',
                        ' two',
                        ' three',
                        ' four',
                        ' five',
                        ' six',
                        ' seven',
                        ' eight',
                        ' nine',
                        ' ten',
                        ' eleven',
                        ' twelve',
                        ' thirteen',
                        ' fourteen',
                        ' fifteen',
                        ' sixteen',
                        ' seventeen',
                        ' eighteen',
                        ' nineteen'
};
    private static final String[] tensNames = new String[]{
        '',
            ' ten',
            ' twenty',
            ' thirty',
            ' forty',
            ' fifty',
            ' sixty',
            ' seventy',
            ' eighty',
            ' ninety'
};
      
    private static final String[] numNamesarabicLang = new String[]{
            '',
            'واحد ',
            'أثنان ',
            'ثلاثة ',
            'أربعة ',
            'خمسة ',
            'ستة ',
            'سبعة ',
            'ثمانية ',
            'تسعة ',
            'عشرة ',
            'أحد عشر ',
            'أثنا عشر ',
            'ثلاثة عشر ',
            'أربعة عشر ',
            'خمسة عشر ',
            'ستة عشر ',
            'سبعة عشر ',
            'ثمانية عشر ',
            'تسعة عشر '
    };
    private static final String[] tensNamesarabicLang = new String[]{
                '',
                '',
                'عشرون ',
                'ثلاثون ',
                'أربعون ',
                'خمسون ',
                'ستون ',
                'سبعون ',
                'ثمانون ',
                'تسعون '
        };
    private static final String[] hundredNamesarabicLang = new String[]{
                '',
                'مائة ',
                'مائتان ',
                'ثلاثمائة ',
                'أربعمائة ',
                'خمسمائة ',
                'ستمائة ',
                'سبعمائة ',
                'ثمانمائة ',
                'تسعمائة '
        };
                            
    private static String convertLessThanOneThousand(Integer num) {
                                String soFar = '';
                                
                                if (Math.mod(num, 100) < 20){
                                    soFar = numNames[Math.mod(num, 100)];
                                    num /= 100;
                                }
                                else {
                                    soFar = numNames[Math.mod(num, 10)];
                                    num /= 10;
                                    
                                    soFar = tensNames[Math.mod(num, 10)] + soFar;
                                    num /= 10;
                                }
                                if (num == 0) 
                                    return soFar;
                                return numNames[num] + ' hundred' + soFar;
                            }
    private static String convertLessThanOneThousandarabicLang(Integer num) {
                                String soFar = '';
                                if (Math.mod(num, 100) < 20){
                                    soFar = numNamesarabicLang[Math.mod(num, 100)];
                                    num /= 100;
                                }
                                else {
                                    soFar = numNamesarabicLang[Math.mod(num, 10)];
                                    soFar += ((soFar.length() > 0)? ' و ' : '');
                                    num /= 10;
                                    
                                    soFar = soFar + tensNamesarabicLang[Math.mod(num, 10)];
                                    num /= 10;
                                }
                                if (num == 0) 
                                    return soFar;
                                return hundredNamesarabicLang[num] + ((soFar.length() > 0)? ' و ' : '') + soFar;
                            }
    
    global static String convert(decimal num, boolean arabicLang) {
        try{
        if (num == 0) { return ((arabicLang)? 'صفر':'zero'); }
        system.debug('MOST1: '+num);
        num = num.setScale(2);
        String numString = String.valueOf(num);
        String numWhole = numString.substringBefore('.');
        String numDecimals = numString.substringAfter('.');
        numDecimals = numDecimals.rightPad(2, '0');
        String snumber = numWhole.leftPad(12, '0');
        system.debug('MOST2: '+snumber);
        system.debug('MOST3: '+numDecimals);
        // XXXnnnnnnnnn
        Integer billions = Integer.valueOf(snumber.substring(0,3));
        // nnnXXXnnnnnn
        Integer millions  = Integer.valueOf(snumber.substring(3,6));
        // nnnnnnXXXnnn
        Integer hundredThousands = Integer.valueOf(snumber.substring(6,9));
        // nnnnnnnnnXXX
        Integer thousands = Integer.valueOf(snumber.substring(9,12));
        String tradBillions;
        switch on billions {
            when 0{
                tradBillions = '';
            }
            when 1{
                tradBillions = ((arabicLang)? ' مليار ' : ' one billion ');
            }
            when 2{
                tradBillions = ((arabicLang)? ' ملياران ' : ' two billions ');
            }
            when else{
                tradBillions = ((arabicLang)?convertLessThanOneThousandarabicLang(billions): convertLessThanOneThousand(billions));   
                if(arabicLang){
                    if(billions <= 10)
                    	tradBillions = tradBillions + 'مليارات ';
                    else
                    	tradBillions = tradBillions + 'مليار ';
                }else{
                    tradBillions = tradBillions + ' billions ';
                }
            }
        }
        String result =  tradBillions;
        system.debug('MOST4: '+result);
        if(result.length() > 0 && !result.endsWith('and ') && !result.endsWith('و ')){
            result += (arabicLang)? 'و ' : 'and ';
        }           
        
        String tradMillions;
        switch on millions {
            when 0{
                tradMillions = '';
            }
            when 1{
                tradMillions = ((arabicLang)? 'مليون ' : 'one million ');
            }
            when 2{
                tradMillions = ((arabicLang)? 'مليونان ' : 'two millions ');                
            }
            when else{
                tradMillions = ((arabicLang)?convertLessThanOneThousandarabicLang(millions): convertLessThanOneThousand(millions));
                if(arabicLang){
                    if(millions <= 10)
                    	tradMillions = tradMillions + 'ملايين ';
                    else
                    	tradMillions = tradMillions + 'مليون ';
                }else{
                    tradMillions = tradMillions + ' millions ';
                }
            }
        }
        result =  result + tradMillions;
        system.debug('MOST5: '+result);
        if(result.length() > 0 && !result.endsWith('and ') && !result.endsWith('و ')){
            result += (arabicLang)? 'و ' : 'and ';
        }            
        
        String tradHundredThousands;
        switch on hundredThousands {
            when 0{
                tradHundredThousands = '';            
            }
            when 1{
                tradHundredThousands = ((arabicLang)? 'ألف ' : 'one thousands ');
            }
            when 2{
                tradHundredThousands = ((arabicLang)? 'ألفان ' : 'two thousands ');
            }
            when else{
                tradHundredThousands = ((arabicLang)?convertLessThanOneThousandarabicLang(hundredThousands): convertLessThanOneThousand(hundredThousands));
                if(arabicLang){
                    if(hundredThousands <= 10)
                    	tradHundredThousands = tradHundredThousands + 'آلاف ';
                    else
                    	tradHundredThousands = tradHundredThousands + 'ألف ';
                }else{
                    tradHundredThousands = tradHundredThousands + ' thousands ';
                }
            }
        }
        result =  result + tradHundredThousands;
        system.debug('MOST6: '+result);
        if(result.length() > 0 && !result.endsWith('and ') && !result.endsWith('و ')){
            result += (arabicLang)? 'و ' : 'and ';
        }                    
        String tradThousand;
        tradThousand = ((arabicLang)?convertLessThanOneThousandarabicLang(thousands) : convertLessThanOneThousand(thousands));
        result =  result + tradThousand + ((arabicLang)? ' جنيه مصري ' : ' Egyptian Pound ');
        
        if(result.length() > 0 && !result.endsWith('and ') && !result.endsWith('و ')){
            result += (arabicLang)? ' و ' : ' and ';
        } 
        String piasters = '';
        Integer numDecimalValue = Integer.valueOf(numDecimals);
        switch on numDecimalValue {
            when 0{
                piasters = '';
            }
            when 1{
                piasters = ((arabicLang)? ' قرشا ' : ' one piaster ');
            }
            when 2{
                piasters = ((arabicLang)? ' قرشان ' : ' two piasters ');
            }
            when else{
                piasters = ((arabicLang)?convertLessThanOneThousandarabicLang(numDecimalValue): convertLessThanOneThousand(numDecimalValue));   
                if(arabicLang){
                    if(numDecimalValue <= 10)
                    	piasters = piasters + 'قروش ';
                    else
                    	piasters = piasters + 'قرشا ';
                }else{
                    piasters += ' piasters ';
                }
            }
        }
        result +=  piasters;
        system.debug('MOST7: '+result);
        result = result.endsWith('and ') ? result.removeEnd('and ') : result;
        result = result.endsWith('و ') ? result.removeEnd('و ') : result;
        return result.replaceAll('^\\s+', '').replaceAll('\\b\\s{2,}\\b', ' ');
        }catch(Exception e){system.debug('MOST ERR: '+e.getLineNumber()+' '+e.getMessage());}
        return '';
    }
}