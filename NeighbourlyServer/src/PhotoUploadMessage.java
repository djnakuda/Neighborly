
public class PhotoUploadMessage extends Message {
	String imageAsString;
	int userID;

	public int getUserID() {
		return userID;
	}

	public void setUserID(int userID) {
		this.userID = userID;
	}

	public String getImageAsString() {
		return imageAsString;
	}

	public void setImageAsString(String imageAsString) {
		this.imageAsString = imageAsString;
	}
}
