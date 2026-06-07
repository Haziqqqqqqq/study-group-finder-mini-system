package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConnection Utility
 * Provides JDBC connections for XAMPP MySQL.
 * Update DB_URL, DB_USER, DB_PASS to match your environment.
 */
public class DBConnection {

    private static final String DB_URL    = "jdbc:mysql://localhost:3306/studygroup_db";
    private static final String DB_USER   = "root";
    private static final String DB_PASS   = ""; 
    private static final String DB_DRIVER = "com.mysql.cj.jdbc.Driver";

    static {
        try {
            Class.forName(DB_DRIVER);
        } catch (ClassNotFoundException e) {
            throw new ExceptionInInitializerError("MySQL JDBC Driver not found: " + e.getMessage());
        }
    }

    /**
     * Returns a new JDBC connection.
     * Always use try-with-resources to close it automatically.
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
    }
}
