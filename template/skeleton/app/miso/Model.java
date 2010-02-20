package miso;

import net.java.ao.*;
import java.sql.*;
import com.mysql.jdbc.*;
import models.*;
import java.util.logging.*;

public class Model {
  
  static String url = "jdbc:mysql://localhost/miso";
  public EntityManager em = new EntityManager(url, "root", "");
  
  public EntityManager db() {
    // Place EntityManager configuraton here (e.g., setPolymorphicTypeMapper, etc)
    return em;
  }
  
}