import java.util.ArrayList;

public class replyToQueryMessage extends Message{
	private ArrayList<Item> itemList;
	
	public replyToQueryMessage(ArrayList<Item> itemList, String message) {
		this.itemList = itemList;
		this.message = message;
	}

	public ArrayList<Item> getItemList() {
		return itemList;
	}

	public void setItemList(ArrayList<Item> itemList) {
		this.itemList = itemList;
	}
	

}
