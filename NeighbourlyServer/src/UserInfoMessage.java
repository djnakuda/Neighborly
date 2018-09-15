import java.util.ArrayList;

public class UserInfoMessage extends Message {
	int userID;
	String name;
	String email;
	String imageURL;
	ArrayList<Item> myItems;
	ArrayList<Item> borrowedItems;
	
	UserInfoMessage(int userID,String email, Database database )
	{
		super("valid");
		this.userID = userID;
		this.name=database.getNameFromID(userID);
		this.email = email;
		this.imageURL = database.getUserImageURLfromUserID(userID);
		this.myItems = database.getMyItems(userID);
		this.borrowedItems = database.getBorrowedItems(userID);
	}
	
	UserInfoMessage(int userID, Database database)
	{
		super("valid");
		this.userID = userID;
		this.name=database.getNameFromID(userID);
		this.myItems = database.getMyItems(userID);
		this.borrowedItems = database.getBorrowedItems(userID);
		this.imageURL = database.getUserImageURLfromUserID(userID);
	}

}
