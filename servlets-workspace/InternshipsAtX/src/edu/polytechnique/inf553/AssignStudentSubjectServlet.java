package edu.polytechnique.inf553;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * Servlet implementation class AssignStudentSubjectServlet
 */
@WebServlet("/AssignStudentSubjectServlet")
public class AssignStudentSubjectServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public AssignStudentSubjectServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println(this.getClass().getName() + " doGet method called with path " + request.getRequestURI() + " and parameters " + request.getQueryString());
		// session management
		HttpSession session = request.getSession(false);
		if(session!=null && session.getAttribute("user")!= null) {
			Person user = (Person)session.getAttribute("user");
			String role = user.getRole();
			if (role.equals("Admin") || role.equals("Professor") || role.equals("Assistant")) {
				int studentId = Integer.parseInt(request.getParameter("studentId"));
				int subjectId = Integer.parseInt(request.getParameter("subjectId"));
				
				try (Connection con = DbUtils.getConnection()) {
					if (con == null) {
						response.sendError(HttpServletResponse.SC_FORBIDDEN);
					}
										
					// update user valid, set isolation level SERIALIZABLE
					String query = "INSERT INTO person_internship (internship_id, person_id) values (?, ?)";
					try (PreparedStatement preparedStatement = con.prepareStatement(query)) {
            preparedStatement.setInt(1, subjectId);
            preparedStatement.setInt(2, studentId);
            preparedStatement.executeUpdate();
          }
					
					query = "UPDATE internship SET is_taken = TRUE WHERE id=?";
					try (PreparedStatement preparedStatement = con.prepareStatement(query)) {
            preparedStatement.setInt(1, subjectId);
            preparedStatement.executeUpdate();
          }
				} catch(SQLException e) {
					e.printStackTrace();
        }
				
				response.setStatus( 200 );
			}else {
				// the user is not admin, redirect to the error page
				response.sendError(HttpServletResponse.SC_FORBIDDEN);
			}
		}else {
			// the user is not logged in, redirect to the error page
			response.setStatus( HttpServletResponse.SC_FORBIDDEN );
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		doGet(request, response);
	}

}
