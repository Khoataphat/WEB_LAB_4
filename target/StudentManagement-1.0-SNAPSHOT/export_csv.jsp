<%-- 
    Document   : export_csv
    Created on : 8 thg 11, 2025, 15:31:44
    Author     : Admin
--%>

<%@ page language="java" contentType="text/csv; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
response.setHeader("Content-Disposition", "attachment; filename=\"students.csv\"");

out.println("ID,Student Code,Full Name,Email,Major");

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(
        "jdbc:mysql://localhost:3306/student_management", "root", "123456"
    );
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery("SELECT * FROM students");

    while (rs.next()) {
        out.println(
            rs.getInt("id") + "," +
            rs.getString("student_code") + "," +
            rs.getString("full_name") + "," +
            rs.getString("email") + "," +
            rs.getString("major")
        );
    }

    rs.close();
    stmt.close();
    conn.close();
} catch (Exception e) {
    e.printStackTrace();
}
%>

