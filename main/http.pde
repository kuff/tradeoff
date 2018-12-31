
/*
  SIMPLE HTTP CLIENT FOR INTERACTING WITH THE GAME API
*/

class Server {
  
  private HttpCookie sessionCookie; // where the session cookie retrieved from register() is stored
  private String APIEndpoint; // the API endpoint (url)
  int timeStamp; // read externally by MenuScene on refused connection on startup, also used internally to time requests
  private JSONArray savedScores; // the last successfully retrieved score data
  
  Server() {
    this.APIEndpoint = "http://papupa.com/tradeoff"; // if anybody abuses this I'm gonna be mad (and sad)
    this.savedScores = null; // no scores have been retrieved yet
    this.timeStamp = 0;
  }
  
  JSONObject register() {
    // registers the player with the server, retrieving the play alias and session cookie
    JSONObject response = this.get(this.APIEndpoint + "/register");
    // note if the request didn't go through and return the response
    SERVER_CONNECTION = response != null;
    return response;
  }
  
  JSONArray getScoreboard() {
    // fetches the highscores of all registered players
    int time = millis();
    if (this.timeStamp == 0 || time - this.timeStamp > 10000) {
      // if we have made no prior requests or it is more than ten seconds since the last one, perform a new request
      JSONObject result = this.get(this.APIEndpoint + "/scoreboard");
      SERVER_CONNECTION = result != null; // note if the request didn't go through
      this.timeStamp = time;
      // if the request did not succeed return the stored response (if there is any), otherwise save the response array
      if (result == null || !result.getBoolean("success")) return this.savedScores;
      this.savedScores = result.getJSONArray("data");
    }
    return this.savedScores; // return the instance variable, since it has been overwritten by new data by now if there is any
  }
  
  boolean postScore(int score) {
    // posts the given score to the server
    JSONObject reponse = this.get(this.APIEndpoint + "/postscore?s=" + score);
    // note if the request didn't go through and return the response
    SERVER_CONNECTION = reponse != null;
    return reponse != null;
  }
  
  private JSONObject get(String source) {
    
    try {
      // set up the request
      HttpURLConnection con = this.connect(source);
      if (con == null) return null;
      // make the request
      con.getResponseCode(); // this is only used to issue the request, meaning the actual value being retrieved is not read or used
      // read the response
      JSONObject result = this.parseResponse(con);
      if (result.getBoolean("success")) {
        // the request was successfully proccessed server-side, now save the retrieved session cookie and JSON response
        this.saveSessionCookie(con);
        con.disconnect();
        return result;
      }
      con.disconnect();
      // return null since the api request failed on the server side
      return null;
    }
    catch(Exception err) { // only requires IOException but other exception might get thrown
      println(err);
      return null;
    }
    
  }
  
  private HttpURLConnection connect(String source) {
    
    try {
      // attempt to estabslish a connection to the provided source url
      URL url = new URL(source);
      HttpURLConnection con = (HttpURLConnection) url.openConnection();
      // apply request parameters
      con.setRequestMethod("GET");
      con.setConnectTimeout(5000);
      con.setReadTimeout(5000);
      // if a session cookie exists, append it to the request
      if (this.sessionCookie != null) con.setRequestProperty("Cookie", this.sessionCookie.toString());
      // return the connection
      return con;
    }
    // handle exceptions by returning null
    catch(MalformedURLException err) {
      println(err);
      return null;
    }
    catch(IOException err) {
      println(err);
      return null;
    }
    
  }
  
  private JSONObject parseResponse(HttpURLConnection con) {
    
    try {
      // read the response and parse it as JSON
      BufferedReader in = new BufferedReader(new InputStreamReader(con.getInputStream()));
      String inputLine;
      StringBuffer content = new StringBuffer();
      while((inputLine = in.readLine()) != null) content.append(inputLine);
      in.close();
      return parseJSONObject(content.toString());
    }
    catch(Exception err) { // only requires IOException but other exception might get thrown
      println(err);
      return null;
    }
    
  }
  
  private void saveSessionCookie(HttpURLConnection con) {
    
    // save the provided session cookie
    String cookieHeader = con.getHeaderField("Set-Cookie");
    if (cookieHeader != null) {
      List<HttpCookie> cookies = HttpCookie.parse(cookieHeader);
      this.sessionCookie = cookies.get(0);
    }
    
  }
  
}
