package models;

import miso.Model;
import net.java.ao.*;
import java.sql.*;
import java.util.*;
import com.mysql.jdbc.*;
import org.json.simple.*;

public class [[ModelNameCapitalized]]Model extends Model {

  // Find a single [[ModelNameLowercase]]
  public [[ModelNameCapitalized]] get(int id) {
    return db().get([[ModelNameCapitalized]].class, id);
  }

  // Create a [[ModelNameLowercase]] from a HashMap
  public [[ModelNameCapitalized]] create(HashMap params) {
    try {
      [[ModelNameCapitalized]] [[ModelNameLowercase]] = db().create([[ModelNameCapitalized]].class, params);
      return [[ModelNameLowercase]];
    } catch (SQLException ex) {
      return null;
    }
  }
  
  // Update a [[ModelNameLowercase]] from a HashMap
  public [[ModelNameCapitalized]] update(int id, HashMap params) {
    [[ModelNameCapitalized]] [[ModelNameLowercase]] = db().get([[ModelNameCapitalized]].class, id);
    [[SetterFromParamsImplementation]]
    [[ModelNameLowercase]].save();
    return [[ModelNameLowercase]];
  }
  
  // Return a list of all [[ModelNameLowercase]]s.
  public [[ModelNameCapitalized]][] list() {
    try {
      return db().find([[ModelNameCapitalized]].class);
    } catch (SQLException ex) {
      return null;
    }
  }

  // Find a single [[ModelNameLowercase]]
  public void destroy(int id) {
    try {
      [[ModelNameCapitalized]] p = db().get([[ModelNameCapitalized]].class, id);
      db().delete(p);
    } catch (SQLException ex) { }
  }

  public JSONArray listToJSON([[ModelNameCapitalized]][] [[ModelNameLowercase]]s) {
    JSONArray list = new JSONArray();
    for ([[ModelNameCapitalized]] [[ModelNameLowercase]] : [[ModelNameLowercase]]s) { list.add(toJSON([[ModelNameLowercase]])); }
    return list;
  }

  public JSONObject toJSON([[ModelNameCapitalized]] [[ModelNameLowercase]]) {
    JSONObject json = new JSONObject();
    [[JSONOutputForColumns]]
    return json;
  }

}