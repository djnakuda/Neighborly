import java.io.IOException;
import java.util.ArrayList;
import java.util.Vector;
import javax.websocket.OnClose;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import com.google.gson.Gson;

@ServerEndpoint(value = "/ws")
public class ServerSocket {

	private static Vector<Session> sessionVector = new Vector<Session>();
	private static Database database = new Database();
	private static Gson gson = new Gson();

	@OnOpen
	public void open(Session session) {
		System.out.println("Client Connected!");
		sessionVector.add(session);
	}

	@OnMessage
	public void onMessage(String message, Session session) {
		System.out.println(message);
		Message m = null;
		m = gson.fromJson(message, Message.class);
		String messageID = m.getMessageID();
		System.out.println("messageID: " + messageID);

		if (messageID.trim().equals("signUp")) {
			m = gson.fromJson(message, SignUpMessage.class);
			String name = ((SignUpMessage) m).getName();
			String email = ((SignUpMessage) m).getEmail();
			String password = ((SignUpMessage) m).getPassword();
			String toWrite = "";

			int userID = database.signUp(email, name, password);

			if (userID != -1) {
				toWrite = gson.toJson(new UserInfoMessage(userID, email, database));
				session.getUserProperties().put("userID", userID);
			} else // sign up was unsuccessful
			{
				toWrite = gson.toJson(new Message("invalid"));
			}

			try {
				session.getBasicRemote().sendText(toWrite);
			} catch (IOException e) {
				System.out.println("IOException in signup");
			}
		}
		else if(messageID.trim().equals("login"))
		{
			System.out.println("daniyal is the man login!!!!!!");
			m = gson.fromJson(message,LoginMessage.class);
			String email = ((LoginMessage) m).getEmail();
			String password = ((LoginMessage) m).getPassword();
			String toWrite = "";

			int userID = database.login(email, password);
			if (userID == -1) // means login was unsuccessfull
			{
				toWrite = gson.toJson(new Message("invalid"));

			} else // means login was successful
			{
				toWrite = gson.toJson(new UserInfoMessage(userID, email, database));
				session.getUserProperties().put("userID", userID);
			}

			try {
				System.out.println(toWrite);
				session.getBasicRemote().sendText(toWrite);
			} catch (IOException e) {
				System.out.println("IOException in signup");
			}
		} else if (messageID.trim().equals("postItem")) {
			String toWrite = "";
			m = gson.fromJson(message, PostItemMessage.class);
			int ownerID = ((PostItemMessage) m).getOwnerID();
			String itemName = ((PostItemMessage) m).getItemName();
			String description = ((PostItemMessage) m).getItemDescription();
			double latitude = ((PostItemMessage) m).getLatitude();
			double longitude = ((PostItemMessage) m).getLongitude();
			String imageURL = ((PostItemMessage) m).getImageURL();

			int itemID = database.addItemToDatabase(ownerID, itemName, imageURL, description, latitude, longitude);
			ArrayList<Item> toReturn = new ArrayList<Item>();

			if (itemID == -1) {
				toWrite = gson.toJson(new replyToQueryMessage(toReturn, "invalid"));
			} else {

				Item item = database.getItembyID(itemID);
				toReturn.add(item);
				toWrite = gson.toJson(new replyToQueryMessage(toReturn, "valid"));
			}

			try {
				session.getBasicRemote().sendText(toWrite);
			} catch (IOException e) {
				System.out.println("IOException in signup");
			}

		} else if (messageID.trim().equals("searchItem")) {
			String toWrite = "";
			m = gson.fromJson(message, SearchQueryMessage.class);
			String searchTerm = ((SearchQueryMessage) m).getSearchTerm();
			double latitude = ((SearchQueryMessage) m).getLatitude();
			double longitude = ((SearchQueryMessage) m).getLongitude();
			int distance = ((SearchQueryMessage) m).getDistance();
			System.out.println("searchTerm: " + searchTerm);
			System.out.println("latitude: " + latitude);
			System.out.println("longitude: " + longitude);
			System.out.println("distance: " + distance);

			ArrayList<Item> toReturn;

			if (searchTerm.trim().equals("")) {
				toReturn = database.getAllItemsInDatabase(latitude, longitude, distance);
			} else {
				toReturn = database.searchItemsByDistance(searchTerm, latitude, longitude, distance);
			}
			toWrite = gson.toJson(new replyToQueryMessage(toReturn, "valid"));
			for (int i = 0; i < toReturn.size(); i++) {
				toReturn.get(i).printItem();
			}
			try {
				session.getBasicRemote().sendText(toWrite);
			} catch (IOException e) {
				System.out.println("IOException in searching items in server socket in java");
				toWrite = gson.toJson(new Message("invalid"));
			}
		} else if (messageID.trim().equals("accountInfo")) {
			String toWrite = "";
			m = gson.fromJson(message, requestUserInfobyIDMessage.class);
			int userID = ((requestUserInfobyIDMessage) m).getUserID();
			toWrite = gson.toJson(new UserInfoMessage(userID, database));
			System.out.println("sending: " + toWrite);
			try {
				session.getBasicRemote().sendText(toWrite);
			} catch (IOException e) {
				System.out.println("IOException in searching items in server socket in java");
				toWrite = gson.toJson(new Message("invalid"));
			}

		} else if (messageID.trim().equals("requestItem")) {
			System.out.println("In requestItem");
			String toWrite = "";
			m = gson.fromJson(message, requestItemMessage.class);
			int requestorID = ((requestItemMessage) m).getRequestorID();
			int itemID = ((requestItemMessage) m).getItemID();

			System.out.println("requestorID: " + requestorID);

			int ownerID = database.requestItem(itemID, requestorID);
			if (ownerID == -1) {
				toWrite = gson.toJson(new itemInfoMessage(-1, "invalid"));
			} else {
				toWrite = gson.toJson(new itemInfoMessage(itemID, "valid requestItem"));
			}
			try {
				session.getBasicRemote().sendText(toWrite);
			} catch (IOException e) {
				System.out.println("IOException in searching items in server socket in java");
				toWrite = gson.toJson(new Message("invalid"));
			}
			// function to send owner pop up notification
			/*
			 * for(Session s : sessionVector) { if(ownerID ==
			 * (int)session.getUserProperties().get("userID")) { try {
			 * s.getBasicRemote().sendText(message); } catch (IOException e) {
			 * e.printStackTrace(); } } }
			 */
		} else if (messageID.trim().equals("singleItemQuery")) {
			System.out.println("in single item query");
			String toWrite = "";
			m = gson.fromJson(message, singleItemQuery.class);
			int itemID = ((singleItemQuery) m).getItemID();

			Item item = database.getItembyID(itemID);
			ArrayList<Item> items = new ArrayList<Item>();
			if (item != null) {
				items.add(item);
				toWrite = gson.toJson(new replyToQueryMessage(items, "valid"));
			} else {
				toWrite = gson.toJson(new replyToQueryMessage(items, "invalid"));
			}
			try {
				session.getBasicRemote().sendText(toWrite);
			} catch (IOException e) {
				System.out.println("IOException in searching items in server socket in java");
				toWrite = gson.toJson(new Message("invalid"));
			}

		} else if (messageID.trim().equals("updateUserPhoto")) {
			System.out.println("In update user photo");
			String toWrite = "";
			m = gson.fromJson(message, UserUpdatePhotoMessage.class);
			int userID = ((UserUpdatePhotoMessage) m).getUserID();
			String imageURL = ((UserUpdatePhotoMessage) m).getImageURL();

			int x = database.updateUserPhoto(userID, imageURL);

			if (x == -1) {
				toWrite = gson.toJson(new Message("invalid"));
			} else {
				toWrite = gson.toJson(new UserInfoMessage(userID, database));
			}
			try {
				session.getBasicRemote().sendText(toWrite);
			} catch (IOException e) {
				System.out.println("IOException in searching items in server socket in java");
				toWrite = gson.toJson(new Message("invalid"));
			}
		} else if (messageID.trim().equals("acceptRequest")) {
			System.out.println("In acceptRequest");
			String toWrite = "";
			m = gson.fromJson(message, AcceptRequestMessage.class);
			int itemID = ((AcceptRequestMessage) m).getItemID();
			int borrowerID = ((AcceptRequestMessage) m).getBorrowerID();
			int x = database.acceptRequest(itemID, borrowerID);

			if (x == -1) {
				toWrite = gson.toJson(new itemInfoMessage(-1, "invalid"));
			} else {
				toWrite = gson.toJson(new itemInfoMessage(itemID, "valid acceptRequest"));
			}
			try {
				session.getBasicRemote().sendText(toWrite);
			} catch (IOException e) {
				System.out.println("IOException in searching items in server socket in java");
				toWrite = gson.toJson(new Message("invalid"));
			}
		} else if (messageID.trim().equals("declineRequest")) {
			System.out.println("in decline request");
			String toWrite = "";
			m = gson.fromJson(message, DeclineRequestMessage.class);
			int borrowerID = ((DeclineRequestMessage) m).getBorrowerID();
			int itemID = ((DeclineRequestMessage) m).getItemID();
			int x = database.declineRequest(itemID, borrowerID);

			if (x == -1) {
				toWrite = gson.toJson(new itemInfoMessage(-1, "invalid"));
			} else {
				toWrite = gson.toJson(new itemInfoMessage(itemID, "valid declineRequest"));
			}
			System.out.println(toWrite);
			try {
				session.getBasicRemote().sendText(toWrite);
			} catch (IOException e) {
				System.out.println("IOException in searching items in server socket in java");
				toWrite = gson.toJson(new Message("invalid"));
			}
		} else if (messageID.trim().equals("returnRequest")) {
			String toWrite = "";
			m = gson.fromJson(message, ReturnRequestMessage.class);
			int itemID = ((ReturnRequestMessage) m).getItemID();
			int x = database.returnRequest(itemID);

			if (x == -1) {
				toWrite = gson.toJson(new itemInfoMessage(-1, "invalid"));
			} else {
				toWrite = gson.toJson(new itemInfoMessage(itemID, "valid returnRequest"));
			}
			try {
				session.getBasicRemote().sendText(toWrite);
			} catch (IOException e) {
				System.out.println("IOException in searching items in server socket in java");
				toWrite = gson.toJson(new Message("invalid"));
			}
		} else if (messageID.trim().equals("returnRequestAccept")) {
			String toWrite = "";
			m = gson.fromJson(message, ReturnRequestAcceptMessage.class);
			int itemID = ((ReturnRequestAcceptMessage) m).getItemID();
			int x = database.returnRequestAccept(itemID);

			if (x == -1) {
				toWrite = gson.toJson(new itemInfoMessage(-1, "invalid"));
			} else {
				toWrite = gson.toJson(new itemInfoMessage(itemID, "valid returnRequestAccept"));
			}
			try {
				session.getBasicRemote().sendText(toWrite);
			} catch (IOException e) {
				System.out.println("IOException in searching items in server socket in java");
				toWrite = gson.toJson(new Message("invalid"));
			}
		} else if (messageID.trim().equals("returnRequestDecline")) {
			String toWrite = "";
			m = gson.fromJson(message, ReturnRequestDeclineMessage.class);
			int itemID = ((ReturnRequestDeclineMessage) m).getItemID();
			int x = database.returnRequestDecline(itemID);

			if (x == -1) {
				toWrite = gson.toJson(new itemInfoMessage(-1, "invalid"));
			} else {
				toWrite = gson.toJson(new itemInfoMessage(itemID, "valid returnRequestDecline"));
			}
			try {
				session.getBasicRemote().sendText(toWrite);
			} catch (IOException e) {
				System.out.println("IOException in searching items in server socket in java");
				toWrite = gson.toJson(new Message("invalid"));
			}
		} 
		else if(messageID.trim().equals("deleteItem"))
		{
			String toWrite = "";
			m = gson.fromJson(message, deleteItemMessage.class);
			int itemID = ((deleteItemMessage)m).getItemID();
			int x = database.deleteItem(itemID);
			if(x == -1)
			{
				toWrite = gson.toJson(new Message("invalid"));
			}
			else
			{
				toWrite = gson.toJson(new Message("valid"));
			}
			try {
				session.getBasicRemote().sendText(toWrite);
			} catch (IOException e) {
				System.out.println("IOException in deleting item in server socket in java");
				toWrite = gson.toJson(new Message("invalid"));
			}
		}
		else {
			System.out.println("wrong messageID");
		}
		
	}

	@OnClose
	public void close(Session session) {
		System.out.println("Client Disconnected");
		sessionVector.remove(session);
	}

}
