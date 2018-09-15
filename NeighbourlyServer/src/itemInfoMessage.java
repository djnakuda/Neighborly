
public class itemInfoMessage extends Message {
	
	int itemID;
	
	itemInfoMessage(int itemID, String message)
	{
		this.itemID = itemID;
		this.message = message;
	}

}
