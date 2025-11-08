<%-- 
    Document   : list_students
    Created on : 3 thg 11, 2025, 09:26:38
    Author     : Admin
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Student List</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                margin: 20px;
                background-color: #f5f5f5;
            }
            h1 {
                color: #333;
            }
            .message {
                padding: 10px;
                margin-bottom: 20px;
                border-radius: 5px;
            }
            .success {
                background-color: #d4edda;
                color: #155724;
                border: 1px solid #c3e6cb;
            }
            .error {
                background-color: #f8d7da;
                color: #721c24;
                border: 1px solid #f5c6cb;
            }
            .btn {
                display: inline-block;
                padding: 10px 20px;
                margin-bottom: 20px;
                background-color: #007bff;
                color: white;
                text-decoration: none;
                border-radius: 5px;
            }
            table {
                width: 100%;
                border-collapse: collapse;
                background-color: white;
            }
            th {
                background-color: #007bff;
                color: white;
                padding: 12px;
                text-align: left;
            }
            td {
                padding: 10px;
                border-bottom: 1px solid #ddd;
            }
            tr:hover {
                background-color: #f8f9fa;
            }
            .action-link {
                color: #007bff;
                text-decoration: none;
                margin-right: 10px;
            }
            .delete-link {
                color: #dc3545;
            }
            .pagination a, .pagination strong {
                margin: 0 5px;
                padding: 5px 10px;
                text-decoration: none;
            }
            .pagination strong {
                background: #007bff;
                color: white;
                border-radius: 4px;
            }
            .message {
                padding: 10px;
                margin-bottom: 20px;
                border-radius: 5px;
                font-weight: bold;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            .success {
                background-color: #d4edda;
                color: #155724;
                border: 1px solid #c3e6cb;
            }

            .error {
                background-color: #f8d7da;
                color: #721c24;
                border: 1px solid #f5c6cb;
            }
            .table-responsive {
                overflow-x: auto;
                max-width: 100%;
            }

            @media (max-width: 768px) {
                table {
                    font-size: 12px;
                }
                th, td {
                    padding: 5px;
                }
            }

        </style>
        <script>
            setTimeout(function () {
                var messages = document.querySelectorAll('.message');
                messages.forEach(function (msg) {
                    msg.style.display = 'none';
                });
            }, 3000);
        </script>

    </head>
    <body>
        <h1>📚 Student Management System</h1>

        <% if (request.getParameter("message") != null) {%>
        <div class="message success">
            <%= request.getParameter("message")%>
        </div>
        <% } %>

        <% if (request.getParameter("error") != null) {%>
        <div class="message error">
            <%= request.getParameter("error")%>
        </div>
        <% }%>

        <a href="add_student.jsp" class="btn">➕ Add New Student</a>
        <a href="export_csv.jsp" class="btn">⬇ Export CSV</a>


        <form action="list_students.jsp" method="GET">
            <input type="text" name="keyword" placeholder="Search by name or code...">
            <button type="submit">Search</button>
            <a href="list_students.jsp">Clear</a>
        </form>
        <br>
    <th><a class="btn" href="list_students.jsp?sort=full_name&order=<%=("asc".equals(request.getParameter("order")) ? "desc" : "asc")%>">Full Name</a></th>
    <th><a class="btn" href="list_students.jsp?sort=created_at&order=<%=("asc".equals(request.getParameter("order")) ? "desc" : "asc")%>">Created At</a></th>

    <br>
    <div class="table-responsive">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Student Code</th>
                    <th>Full Name</th>
                    <th>Email</th>
                    <th>Major</th>
                    <th>Created At</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                    Connection conn = null;
                    PreparedStatement stmt = null;
                    ResultSet rs = null;
                    int totalPages = 1;
                    int currentPage = 1;
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");

                        conn = DriverManager.getConnection(
                                "jdbc:mysql://localhost:3306/student_management",
                                "root",
                                "123456"
                        );
                        String keyword = request.getParameter("keyword");
                        if (keyword == null) {
                            keyword = "";
                        }

                        String sortBy = request.getParameter("sort");
                        String order = request.getParameter("order");

                        // Set default sorting if not present
                        if (sortBy == null || sortBy.isEmpty()) {
                            sortBy = "id";
                        }
                        if (order == null || order.isEmpty()) {
                            order = "desc";
                        }

                        String pageParam = request.getParameter("page");
                        currentPage = (pageParam != null) ? Integer.parseInt(pageParam) : 1;
                        int recordsPerPage = 10;
                        int offset = (currentPage - 1) * recordsPerPage;
                        String orderByClause = " ORDER BY " + sortBy + " " + order;
                        String sql;
                        if (keyword != null && !keyword.trim().isEmpty()) {
                            // Use parameterized query with LIKE for both full_name and student_code
                            sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ? OR major LIKE ? ORDER BY id DESC LIMIT ? OFFSET ?";
                            stmt = conn.prepareStatement(sql);
                            String param = "%" + keyword.trim() + "%";
                            stmt.setString(1, param);
                            stmt.setString(2, param);
                            stmt.setString(3, param);
                            stmt.setInt(4, recordsPerPage);
                            stmt.setInt(5, offset);

                        } else {
                            sql = "SELECT * FROM students" + orderByClause + " LIMIT ? OFFSET ?";
                            stmt = conn.prepareStatement(sql);
                            stmt.setInt(1, recordsPerPage);
                            stmt.setInt(2, offset);
                        }
                        rs = stmt.executeQuery();

                        while (rs.next()) {
                            int id = rs.getInt("id");
                            String studentCode = rs.getString("student_code");
                            String fullName = rs.getString("full_name");
                            String email = rs.getString("email");
                            String major = rs.getString("major");
                            Timestamp createdAt = rs.getTimestamp("created_at");

                            if (keyword != null && !keyword.isEmpty()) {
                                String lowerKeyword = keyword.toLowerCase();

                                if (fullName.toLowerCase().contains(lowerKeyword)) {
                                    fullName = fullName.replace(keyword, "<mark>" + keyword + "</mark>");
                                }

                                if (studentCode.toLowerCase().contains(lowerKeyword)) {
                                    studentCode = studentCode.replace(keyword, "<mark>" + keyword + "</mark>");
                                }
                                if (major.toLowerCase().contains(lowerKeyword)) {
                                    major = major.replace(keyword, "<mark>" + keyword + "</mark>");
                                }
                            }

                            int totalRecords = 0;
                            Statement countStmt = conn.createStatement();
                            ResultSet countRs = countStmt.executeQuery("SELECT COUNT(*) FROM students");
                            if (countRs.next()) {
                                totalRecords = countRs.getInt(1);
                            }
                            totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);
                            countRs.close();
                            countStmt.close();

                %>

                <tr>
                    <td><%= id%></td>
                    <td><%= studentCode%></td>
                    <td><%= fullName%></td>
                    <td><%= email != null ? email : "N/A"%></td>
                    <td><%= major != null ? major : "N/A"%></td>
                    <td><%= createdAt%></td>
                    <td>
                        <a href="edit_student.jsp?id=<%= id%>" class="action-link">✏️ Edit</a>
                        <a href="delete_student.jsp?id=<%= id%>" 
                           class="action-link delete-link"
                           onclick="return confirm('Are you sure?')">🗑️ Delete</a>
                    </td>
                </tr>
                <%
                        }
                    } catch (ClassNotFoundException e) {
                        out.println("<tr><td colspan='7'>Error: JDBC Driver not found!</td></tr>");
                        e.printStackTrace();
                    } catch (SQLException e) {
                        out.println("<tr><td colspan='7'>Database Error: " + e.getMessage() + "</td></tr>");
                        e.printStackTrace();
                    } finally {
                        try {
                            if (rs != null) {
                                rs.close();
                            }
                            if (stmt != null) {
                                stmt.close();
                            }
                            if (conn != null) {
                                conn.close();
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
                %>
            </tbody>
        </table>
    </div>      
    <hr><!-- comment -->
    <div class="pagination">
        <% if (currentPage > 1) {%>
        <a href="list_students.jsp?page=<%= currentPage - 1%>">Previous</a>
        <% } %>

        <% for (int i = 1; i <= totalPages; i++) { %>
        <% if (i == currentPage) {%>
        <strong><%= i%></strong>
        <% } else {%>
        <a href="list_students.jsp?page=<%= i%>"><%= i%></a>
        <% } %>
        <% } %>

        <% if (currentPage < totalPages) {%>
        <a href="list_students.jsp?page=<%= currentPage + 1%>">Next</a>
        <% }%>
    </div>

    <% if (request.getParameter("message") != null) {%>
    <div class="message success">✓ <%= request.getParameter("message")%></div>
    <% } %>

    <% if (request.getParameter("error") != null) {%>
    <div class="message error">✗ <%= request.getParameter("error")%></div>
    <% }%>

</body>
</html>
