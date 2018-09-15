import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

public class Database {
	private Connection conn;
	private PreparedStatement ps;
	static String loginQuery = "SELECT * FROM Users WHERE email=? && password=?";
	static String ownedItemsQuery = "SELECT * FROM Items WHERE ownerID=?"; // need to install SQL may need to come back
																			// and change names later
	static String borrowerQuery = "SELECT * FROM Users WHERE name=?";
	static String singleItemQuery = "SELECT * FROM Items WHERE itemID=?";
	static String signUpInsert = "INSERT INTO Users (email, name, password, borrow)" + " VALUES(?, ?, ?, ?);";
	static String addItemInsert = "INSERT INTO Items(itemName, ownerID, imageURL, itemDescription, latitude, longitude, available, request, returnRequest)"
			+ " VALUES(? , ?, ?, ? , ?, ?, ?, ?, ?)";
	static String preppingforSearch = "ALTER TABLE Items" + " ADD FULLTEXT(itemName,itemDescription);";
	static String searchForItems = " SELECT * FROM Items "
			+ "WHERE MATCH(itemName,itemDescription) AGAINST (?)  AND NOT ownerID=? AND latitude BETWEEN ? AND ? AND longitude BETWEEN ? AND ?;";
	static String updateSQL = "UPDATE Users " + "SET image = ? " + "WHERE userID=?";
	static String updateItemSQL_Request = "UPDATE Items " + "SET available = ?, request = ?, requestorID = ? "
			+ "WHERE itemID=?";
	static String updateItemSQL_Accept = "UPDATE Items " + "SET available = ?, request = ?, borrowerID = ? "
			+ "WHERE itemID=?";
	static String updateItemSQL_Decline = "UPDATE Items "
			+ "SET available = ?, request = ?, borrowerID = ?, requestorID = ? " + "WHERE itemID=?";

	static String returnRequestSQL = "UPDATE Items " + "SET returnRequest = ? " + "WHERE itemID=?";

	static String returnAcceptSQL = "UPDATE Items " + "SET returnRequest = ?, borrowerID = ?, available = ? "
			+ "WHERE itemID=?";
	static String getNamefromIDSQL = "SELECT * FROM Users Where userID=?";
	static String getBorrowedItemsSQL = "SELECT * FROM Items Where borrowerID=?";
	static String getMyItemsSQL = "SELECT * FROM Items WHERE ownerID=?";
	static String lastAddedUser = "SELECT LAST_INSERT_ID()";

	static String searchString = " SELECT * , 6371.04 * acos( cos( pi( ) /2 - radians( 90 - latitude) )"
			+ " * cos( pi( ) /2 - radians( 90 - ? ) ) * cos( radians("
			+ " longitude) - radians(?) ) + sin( pi( ) /2 - radians( 90"
			+ " - latitude) ) * sin( pi( ) /2 - radians( 90 - ?) ) ) AS" + " Distance" + " FROM Items"
			+ " WHERE ( 6371.04 * acos( cos( pi( ) /2 - radians( 90 - latitude) ) *"
			+ " cos( pi( ) /2 - radians( 90 - ? ) ) * cos( radians("
			+ " longitude) - radians(?) ) + sin( pi( ) /2 - radians( 90"
			+ " - latitude) ) * sin( pi( ) /2 - radians( 90 - ? ) ) ) <1 )"
			+ " AND MATCH(itemName,itemDescription) AGAINST (?)" + "GROUP BY itemID HAVING Distance < ?"
			+ "ORDER BY Distance";
	static String preppingForSearch2 = "ALTER TABLE Items ADD FULLTEXT(itemName,itemDescription);";
	static String returnAllItemsWithinArea = " SELECT * , 6371.04 * acos( cos( pi( ) /2 - radians( 90 - latitude) )"
			+ " * cos( pi( ) /2 - radians( 90 - ? ) ) * cos( radians("
			+ " longitude) - radians(?) ) + sin( pi( ) /2 - radians( 90"
			+ " - latitude) ) * sin( pi( ) /2 - radians( 90 - ?) ) ) AS" + " Distance" + " FROM Items"
			+ " WHERE ( 6371.04 * acos( cos( pi( ) /2 - radians( 90 - latitude) ) *"
			+ " cos( pi( ) /2 - radians( 90 - ? ) ) * cos( radians("
			+ " longitude) - radians(?) ) + sin( pi( ) /2 - radians( 90"
			+ " - latitude) ) * sin( pi( ) /2 - radians( 90 - ? ) ) ) <1 )" + "GROUP BY itemID HAVING Distance < ?"
			+ "ORDER BY Distance";
	static String searchString2 = "SELECT *," + 
			"3956 * 2 * ASIN(SQRT(POWER(SIN((?-ABS(latitude)) * PI()/180/2),2) + COS(? * PI()/180) * COS(ABS(latitude) * PI()/180) * POWER(SIN((?-longitude) * PI()/180/2),2))) AS distance" + 
			" FROM Items AS loc" + 
			" WHERE longitude BETWEEN (? - ? / ABS(COS(RADIANS(?))*69)) AND (?+? / ABS(COS(RADIANS(?)) * 69))" + 
			" AND latitude BETWEEN (?-(?/69)) AND (?+(?/69))" + 
			" AND MATCH(itemName,itemDescription) AGAINST (?)" +
			" HAVING distance < ?" + 
			" ORDER BY distance ASC";
	static String returnAllItemsWithinArea2 = "SELECT *," + 
			"3956 * 2 * ASIN(SQRT(POWER(SIN((?-ABS(latitude)) * PI()/180/2),2) + COS(? * PI()/180) * COS(ABS(latitude) * PI()/180) * POWER(SIN((?-longitude) * PI()/180/2),2))) AS distance" + 
			" FROM Items AS loc" + 
			" WHERE longitude BETWEEN (? - ? / ABS(COS(RADIANS(?))*69)) AND (?+? / ABS(COS(RADIANS(?)) * 69))" + 
			" AND latitude BETWEEN (?-(?/69)) AND (?+(?/69))" + 
			" HAVING distance < ?" + 
			" ORDER BY distance ASC";
	static String getOwnerIDbyItemID = "SELECT ownerID FROM Items WHERE itemID =?";
	static String updateUserImageURL = "UPDATE Users " + "SET imageURL = ? WHERE userID = ?;";
	static String getUserImageURL = "SELECT imageURL FROM Users Where userID=?";
	static String deleteItemSQL = "DELETE FROM Items WHERE itemID=?;";

	Database() {
		try {
			Class.forName("com.mysql.jdbc.Driver");
			conn = DriverManager
					.getConnection("jdbc:mysql://localhost/Neighborly?user=root&password=jBl45dolphin&useSSL=false");
			System.out.println("Database connected");

		} catch (ClassNotFoundException e) {
			System.out.println("Class not found exception in Database constructor");
		} catch (SQLException e) {
			System.out.println("SQL exception in Database Constructor");
		}

	}

	// performs login and if successful returns userID from the database
	// otherwise returns -1
	public int login(String email, String password) {
		ResultSet rs;
		try {
			ps = conn.prepareStatement(loginQuery);
			ps.setString(1, email);
			ps.setString(2, password);
			rs = ps.executeQuery();
			if (rs.next()) {
				return rs.getInt("userID");
			} else // validation was not successful
			{
				return -1;
			}
		} catch (SQLException e) {

			System.out.println("SQL exception in Database Login");
			System.out.println(e.getMessage());
			return -1;
		}
	}

	// static String signUpInsert = "INSERT INTO Users (email, name, password,
	// borrow)" + " VALUES(? , ?, ?, ?);";
	public int signUp(String email, String name, String password) {
		try {
			ps = conn.prepareStatement(signUpInsert);
			ps.setString(1, email);
			ps.setString(2, name);
			ps.setString(3, password);
			ps.setBoolean(4, false);
			ps.executeUpdate();

			ps = conn.prepareStatement(lastAddedUser);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				return rs.getInt("LAST_INSERT_ID()");
			}

		} catch (SQLException e) {
			System.out.println("SQL exception in Database SignUp");
			System.out.println(e.getMessage());
		}
		return -1;
	}

	public ArrayList<Item> getUsersItems(int userID) {
		ResultSet rs;
		ArrayList<Item> toReturn = new ArrayList<Item>();
		try {
			ps = conn.prepareStatement(ownedItemsQuery);
			ps.setInt(1, userID);
			rs = ps.executeQuery();
			while (rs.next()) {
				int itemID = rs.getInt("itemID");
				toReturn.add(getItembyID(itemID));
			}
		} catch (SQLException e) {
			System.out.println("SQL exception in Database getUsersItems");
			System.out.println(e.getMessage());
		}

		return toReturn;
	}

	public int addItemToDatabase(int ownerID, String itemName, String imageURL, String description, double latitude,
			double longitude) {

		try {
			ps = conn.prepareStatement(addItemInsert);
			ps.setString(1, itemName);
			ps.setInt(2, ownerID);
			ps.setString(3, imageURL);
			ps.setString(4, description);
			ps.setDouble(5, latitude);
			ps.setDouble(6, longitude);
			ps.setInt(7, 1);
			ps.setInt(8, 0);
			ps.setInt(9, 0);
			ps.executeUpdate();
			ps = conn.prepareStatement(lastAddedUser);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				return rs.getInt("LAST_INSERT_ID()");
			}
		} catch (SQLException e) {
			System.out.println("SQL exception in Database addItem");
			System.out.println(e.getMessage());
		}

		return -1;
	}

	// returns id of the owner
	// updateItemSQL_Request = "UPDATE Items " + "SET available = ?, request = ?,
	// requestorID = ? "
	// + "WHERE itemID=?";
	public int requestItem(int itemID, int requestorID) {
		try {
			ps = conn.prepareStatement(updateItemSQL_Request);
			ps.setInt(1, 0); // available
			ps.setInt(2, 1); // request
			ps.setInt(3, requestorID);
			ps.setInt(4, itemID);
			System.out.println(ps.toString());
			ps.executeUpdate();
			return getOwnerIDfromItemID(itemID);

		} catch (SQLException e) {
			System.out.println("SQL exception in Database requestItem");
			System.out.println(e.getMessage());
		}

		return -1;
		// send a message to frontend for an in-app notification to send a request for
		// an item
	}

	// returns 1 if everything went fine, otherwise -1
	public int acceptRequest(int itemID, int borrowerID) {
		// ResultSet rs;
		try {

			ps = conn.prepareStatement(updateItemSQL_Accept);
			ps.setInt(1, 0);
			ps.setInt(2, 0);
			ps.setInt(3, borrowerID);
			ps.setInt(4, itemID);
			ps.executeUpdate();
			return 1;

		} catch (SQLException e) {
			System.out.println("SQL exception in Database acceptItem");
			System.out.println(e.getMessage());
		}

		// send a message to frontend for an in-app notification that requestor has
		// acccepted
		return -1;

	}

	public int declineRequest(int itemID, int borrowerID) {
		// ResultSet rs;
		try {

			ps = conn.prepareStatement(updateItemSQL_Decline);
			ps.setInt(1, 1);
			ps.setInt(2, 0);
			ps.setInt(3, -1); // borrowerID
			ps.setInt(4, -1); // requestorID
			ps.setInt(5, itemID);
			ps.executeUpdate();
			return 1;
		} catch (SQLException e) {
			System.out.println("SQL exception in Database declineItem");
			System.out.println(e.getMessage());
		}

		// send a message to frontend for an in-app notification that requestor has
		// declined
		return -1;
	}

	public int returnRequest(int itemID) {
		//int currentBorrowerID = getItembyID(itemID).getBorrowerID();
		//int ownerID = getItembyID(itemID).getOwnerID();

		try {

			ps = conn.prepareStatement(returnRequestSQL);
			ps.setInt(1, 1);
			ps.setInt(2, itemID);

			ps.executeUpdate();
			return 1;
		} catch (SQLException e) {
			System.out.println("SQL exception in Database acceptItem");
			System.out.println(e.getMessage());
		}

		return -1;
	}

	public int returnRequestAccept(int itemID) {

//		int currentBorrowerID = getItembyID(itemID).getBorrowerID();
//		int ownerID = getItembyID(itemID).getOwnerID();

		try {

			ps = conn.prepareStatement(returnAcceptSQL);
			ps.setInt(1, 0);
			ps.setInt(2, -1); // borrowerID
			ps.setInt(3, 1);
			ps.setInt(4, itemID);
			System.out.println(ps.toString());
			ps.executeUpdate();
			return 1;
		} catch (SQLException e) {
			System.out.println("SQL exception in Database return request accept Item");
			System.out.println(e.getMessage());
		}
		return -1;
		// send message to ownerID and borrowerID that item has been returned
	}

	public int returnRequestDecline(int itemID) {

		//int currentBorrowerID = getItembyID(itemID).getBorrowerID();

		try {

			ps = conn.prepareStatement(returnRequestSQL);
			ps.setInt(1, 0);
			ps.setInt(2, itemID);
			ps.executeUpdate();
			return 1;
		} catch (SQLException e) {
			System.out.println("SQL exception in Database acceptItem");
			System.out.println(e.getMessage());
		}
		return -1;
		// send message to borrowerID that your request to be returned has been denied
	}

	public Item getItembyID(int itemID) {
		ResultSet rs;
		try {
			ps = conn.prepareStatement(singleItemQuery);
			ps.setInt(1, itemID);
			rs = ps.executeQuery();
			rs.next();
			String itemName = rs.getString("itemName");
			String itemDescription = rs.getString("itemDescription");
			String imageURL = rs.getString("imageURL");
			int ownerID = rs.getInt("ownerID");
			int borrowerID = rs.getInt("borrowerID");
			double latitude = rs.getDouble("latitude");
			double longitude = rs.getDouble("longitude");
			int available = rs.getInt("available");
			int request = rs.getInt("request");
			int requestorID = rs.getInt("requestorID");
			int returnRequest = rs.getInt("returnRequest");
			return new Item(itemID, itemName, itemDescription, imageURL, ownerID, borrowerID, latitude, longitude,
					available, request, requestorID, returnRequest);
		} catch (SQLException e) {
			System.out.println("SQL exception in Database getItemsbyID");
			System.out.println(e.getMessage());
		}

		return null;
	}

	public ArrayList<Item> searchItems(int userID, String searchTerm, double minLatitude, double maxLatitude,
			double minLongitude, double maxLongitude) {
		ArrayList<Item> toReturn = new ArrayList<Item>();
		ResultSet rs;
		try {
			ps = conn.prepareStatement(preppingforSearch);
			ps.executeUpdate();
			ps = conn.prepareStatement(searchForItems);
			ps.setString(1, searchTerm);
			ps.setInt(2, userID);
			ps.setDouble(3, minLatitude);
			ps.setDouble(4, maxLatitude);
			ps.setDouble(5, minLongitude);
			ps.setDouble(6, maxLongitude);
			rs = ps.executeQuery();
			while (rs.next()) {
				int itemID = rs.getInt("itemID");
				toReturn.add(getItembyID(itemID));
			}
		} catch (SQLException e) {
			System.out.println("SQL exception in Database searchItems");
			System.out.println(e.getMessage());
		}

		return toReturn;
	}

	public ArrayList<Item> searchItemsByDistance(String searchTerm, double latitude, double longitude,
			int distanceInMiles) {

		ArrayList<Item> toReturn = new ArrayList<Item>();

		ResultSet rs;
		try {
			ps = conn.prepareStatement(preppingForSearch2);
			ps.executeUpdate();
			ps = conn.prepareStatement(searchString2);
			ps.setDouble(1, latitude);
			ps.setDouble(2, latitude);
			ps.setDouble(3, longitude);
			ps.setDouble(4, longitude);
			ps.setDouble(5, distanceInMiles);
			ps.setDouble(6, latitude);
			ps.setDouble(7, longitude);
			ps.setDouble(8, distanceInMiles);
			ps.setDouble(9, latitude);
			ps.setDouble(10, latitude);
			ps.setDouble(11, distanceInMiles);
			ps.setDouble(12, latitude);
			ps.setDouble(13, distanceInMiles);
			ps.setString(14, searchTerm);
			ps.setDouble(15, distanceInMiles);
			
			rs = ps.executeQuery();

			while (rs.next()) {
				int itemID = rs.getInt("itemID");
				System.out.println("itemID: " + itemID);
				toReturn.add(getItembyID(itemID));
			}
		} catch (SQLException e) {
			System.out.println("SQL exception in Database searchItems by distance");
			System.out.println(e.getMessage());
		}

		return toReturn;
	}

	public int getOwnerIDfromItemID(int itemID) {
		ResultSet rs;
		try {
			ps = conn.prepareStatement(getOwnerIDbyItemID);
			ps.setInt(1, itemID);
			rs = ps.executeQuery();
			while (rs.next()) {
				return rs.getInt("ownerID");
			}
		} catch (SQLException e) {
			System.out.println("SQL Exception in getOwnerIDfromItemID");
			System.out.println(e.getMessage());
		}

		return -1;
	}

	public ArrayList<Item> getMyItems(int userID) {
		ArrayList<Item> toReturn = new ArrayList<Item>();
		ResultSet rs;
		try {
			ps = conn.prepareStatement(getMyItemsSQL);
			ps.setInt(1, userID);
			rs = ps.executeQuery();
			while (rs.next()) {
				int itemID = rs.getInt("itemID");
				toReturn.add(getItembyID(itemID));
			}
		} catch (SQLException e) {
			System.out.println("SQL exception in Database getMyItems");
			System.out.println(e.getMessage());
		}

		return toReturn;
	}

	public ArrayList<Item> getBorrowedItems(int userID) {
		ArrayList<Item> toReturn = new ArrayList<Item>();
		ResultSet rs;
		try {
			ps = conn.prepareStatement(getBorrowedItemsSQL);
			ps.setInt(1, userID);
			rs = ps.executeQuery();
			while (rs.next()) {
				int itemID = rs.getInt("itemID");
				toReturn.add(getItembyID(itemID));
			}
		} catch (SQLException e) {
			System.out.println("SQL exception in Database getMyItems");
			System.out.println(e.getMessage());
		}

		return toReturn;
	}

	public String getNameFromID(int userID) {
		ResultSet rs;
		String toReturn = "";
		try {
			ps = conn.prepareStatement(getNamefromIDSQL);
			ps.setInt(1, userID);
			rs = ps.executeQuery();
			while (rs.next()) {
				toReturn = rs.getString("name");
			}
		} catch (SQLException e) {
			System.out.println("SQL exception in Database getMyItems");
			System.out.println(e.getMessage());
		}

		return toReturn;
	}

	public ArrayList<Item> getAllItemsInDatabase(double latitude, double longitude, int distanceInMiles) {
		ArrayList<Item> toReturn = new ArrayList<Item>();

		ResultSet rs;
		try {
			ps = conn.prepareStatement(returnAllItemsWithinArea2);
			ps.setDouble(1, latitude);
			ps.setDouble(2, latitude);
			ps.setDouble(3, longitude);
			ps.setDouble(4, longitude);
			ps.setDouble(5, distanceInMiles);
			ps.setDouble(6, latitude);
			ps.setDouble(7, longitude);
			ps.setDouble(8, distanceInMiles);
			ps.setDouble(9, latitude);
			ps.setDouble(10, latitude);
			ps.setDouble(11, distanceInMiles);
			ps.setDouble(12, latitude);
			ps.setDouble(13, distanceInMiles);
			ps.setDouble(14, distanceInMiles);
			System.out.println(ps.toString());
			rs = ps.executeQuery();
			
			while (rs.next()) {
				int itemID = rs.getInt("itemID");
				toReturn.add(getItembyID(itemID));
			}
		} catch (SQLException e) {
			System.out.println("SQL exception in Database searchItems by distance");
			System.out.println(e.getMessage());
		}

		return toReturn;
	}

	public int updateUserPhoto(int userID, String imageURL) {
		try {
			ps = conn.prepareStatement(updateUserImageURL);
			ps.setString(1, imageURL);
			ps.setInt(2, userID);
			ps.executeUpdate();
			return 1;
		} catch (SQLException e) {
			System.out.println("SQL exception in Database updateUserPhoto");
			System.out.println(e.getMessage());
		}

		return -1;
	}

	public String getUserImageURLfromUserID(int userID) {
		ResultSet rs;
		String toReturn = "";
		try {
			ps = conn.prepareStatement(getUserImageURL);
			ps.setInt(1, userID);
			rs = ps.executeQuery();
			while (rs.next()) {
				toReturn = rs.getString("imageURL");
			}
		} catch (SQLException e) {
			System.out.println("SQL exception in Database getUserImageURLfromUserID");
			System.out.println(e.getMessage());
		}

		return toReturn;
	}
	
	public int deleteItem(int itemID)
	{
		try {
			ps = conn.prepareStatement(deleteItemSQL);
			ps.setInt(1, itemID);
			ps.executeUpdate();
			return 1;
		} catch (SQLException e) {
			System.out.println("SQL exception in Database updateUserPhoto");
			System.out.println(e.getMessage());
		}

		return -1;
	}
}
