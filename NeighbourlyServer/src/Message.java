
public class Message {
	protected String messageID;
	protected String message;
	
	Message()
	{
		
	}
	Message(String message)
	{
		this.message = message;
	}
	public String getMessageID() {
		return messageID;
	}
	public void setMessageID(String messageID) {
		this.messageID = messageID;
	}
	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
}
