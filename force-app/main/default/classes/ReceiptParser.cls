public class ReceiptParser {

	public class RECEIPT_DETAIL_Z {
		public RECEIPT_DOC_DETAIL RECEIPT_DOC_DETAIL;
	}

	public class RECEIPT_DOC_DETAIL {
		public RECEIPT_DETAIL RECEIPT_DETAIL;
	}

	public String X_RETURN_STATUS;
	public X_ERROR_MESSAGE X_ERROR_MESSAGE;
	public RECEIPT_DETAIL_Z RECEIPT_DETAIL;

	public class X_ERROR_MESSAGE {
		public String Error;
	}

	public class RECEIPT_DETAIL {
		public String ACCOUNT_NAME;
		public String RECEIPT_NUMBER;
		public String AMOUNT;
		public String STATE_DSP;
		public String DOCUMENT_NUMBER;
		public String CREATION_DATE;
		public String COMMENTS;
		public String METHOD_NAME;
		public String RECEIPT_DATE;
		public String GL_DATE;
	}

	
	public static ReceiptParser parse(String json) {
		return (ReceiptParser) System.JSON.deserialize(json, ReceiptParser.class);
	}
}