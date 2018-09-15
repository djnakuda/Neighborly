import java.util.ArrayList;

public class User {

	private String name;
	private String email;
	private String imageURL;
	private ArrayList<Item> myItems;
	private boolean borrow;

	User(String name, String email, String imageURL, boolean borrow) {
		this.name = name;
		this.email = email;
		this.imageURL = imageURL;
		this.myItems = new ArrayList<Item>(); // add an empty class
		this.borrow = false;
	}

	void addItem(Item toAdd) {
		myItems.add(toAdd);
		// add this item to the items
	}

	public String getName() {
		return name;
	}

	public void setUsername(String username) {
		this.name = username;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getImageURL() {
		return imageURL;
	}

	public void setImageURL(String imageURL) {
		this.imageURL = imageURL;
	}

	public ArrayList<Item> getMyItems() {
		return myItems;
	}

	public void setMyItems(ArrayList<Item> myItems) {
		this.myItems = myItems;
	}

	public boolean isBorrow() {
		return borrow;
	}

	public void setBorrow(boolean borrow) {
		this.borrow = borrow;
	}

}
