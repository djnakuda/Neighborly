import java.util.ArrayList;

public class Testing {
	public static void main(String[] args) {
		Database myDB = new Database();
		//myDB.addItemToDatabase(1,"camera", " ", "this is the camera", 34.023334,-118.2889454);
		//myDB.addItemToDatabase(1,"ladder", " ", "this is the ladder", 34.021605,-118.2928916);
		//myDB.addItemToDatabase(1,"home", " ", "this is the ladder", 34.021046, -118.276473);
		ArrayList<Item> myItems = myDB.searchItemsByDistance("cat",34.023334, -118.2889454 , 1);
		for(int i = 0; i < myItems.size();i++)
			{
				myItems.get(i).printItem();
			}
	}

}
