
public class requestItemMessage extends Message {
	private int itemID;
	private int requestorID;
	
	public int getRequestorID() {
		return requestorID;
	}
	public void setRequestorID(int requestorID) {
		this.requestorID = requestorID;
	}
	public int getItemID() {
		return itemID;
	}
	public void setItemID(int itemID) {
		this.itemID = itemID;
	}
}
