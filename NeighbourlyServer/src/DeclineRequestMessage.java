
public class DeclineRequestMessage extends Message {
	private int itemID;
	private int borrowerID;
	
	public int getItemID() {
		return itemID;
	}
	public void setItemID(int itemID) {
		this.itemID = itemID;
	}
	public int getBorrowerID() {
		return borrowerID;
	}
	public void setBorrowerID(int borrowerID) {
		this.borrowerID = borrowerID;
	}
}
