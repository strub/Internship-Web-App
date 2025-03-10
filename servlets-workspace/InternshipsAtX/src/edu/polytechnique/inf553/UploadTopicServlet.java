package edu.polytechnique.inf553;

import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/*
 * Test out the hack! (only works if forgotten to put the '?' instead of the strings concatenation) Put this in passwords in SigninServlet : 
 * pppppppp'); drop table error; insert into person(name, email, creation_date, valid, password) values ('fds, aaaa', 'fds.aaaa@gmail.com', '2020-12-14', false, '12345678
 */

@MultipartConfig(maxFileSize = 16177215)    // upload file's size up to 16MB
public class UploadTopicServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	
	/**
	 * Constructor of UploadTopicServlet
	 * Query the programs and their categories
	 */
	public UploadTopicServlet() {
		super();
		try {
			Class.forName("org.postgresql.Driver");
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println(this.getClass().getName() + " doGet method called with path " + request.getRequestURI());

		List<Program> programs = loadData();
		request.setAttribute("programs", programs);
		request.getRequestDispatcher("upload_topic.jsp").include(request, response);
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("doPost called with parameter "+request.getQueryString());

		String firstName = request.getParameter("firstName");
		String lastName = request.getParameter("lastName");
		String email = request.getParameter("email").toLowerCase();
		String topicTitle = request.getParameter("topicTitle");
		String program_id_string = request.getParameter("programs");
		String category_id_string = request.getParameter("categories");
		String confidentiality = request.getParameter("confidentiality");
		Part uploadFile = request.getPart("uploadFile");
		
		String errorMessage = checkEntries(firstName, lastName, email, topicTitle, program_id_string, category_id_string, uploadFile);
		if(errorMessage.equals("None")) {
			
			//Conversion from String to Integer, exception impossible by construction of values in html files for each category and each program
			int program_id = Integer.parseInt(program_id_string);
			int category_id = Integer.parseInt(category_id_string);
			boolean confidentialSubject = Objects.equals(confidentiality, "on"); // the checkbox is checked
			try (Connection con = DbUtils.getConnection()) {
				int supervisor_id;
				
				if (con == null) {
					response.sendError(HttpServletResponse.SC_FORBIDDEN);
				}

				if(!checkEmail(email)) {
					String defaultPass = "password";
					String concatName = lastName+", "+firstName;
					String query1 = "insert into person(name, email, creation_date, valid, password)" + 
							" values (?, ?, ?, true, crypt(?, gen_salt('bf'))) ;";

					try (PreparedStatement ps1 = con.prepareStatement(query1)) {
            ps1.setString(1, concatName);
            ps1.setString(2, email);
            ps1.setDate(3, Date.valueOf(java.time.LocalDate.now()));
            ps1.setString(4, defaultPass);
            ps1.executeUpdate();
          }

					String query2 = "select id from person where email =? ;";
					try (PreparedStatement ps2 = con.prepareStatement(query2)) {
            ps2.setString(1, email);
            try (ResultSet rs2 = ps2.executeQuery()) {
              rs2.next();
              supervisor_id = rs2.getInt("id");
            }
          }
					
					String query3 = "insert into person_roles(role_id, person_id) values (4, ?);"; //'proponent' id=4
					try (PreparedStatement ps3 = con.prepareStatement(query3)) {
            ps3.setInt(1, supervisor_id);
            ps3.executeUpdate();
          }
				}
				
				String query4 = "select id from person where email =? ;";
				try (PreparedStatement ps4 =  con.prepareStatement(query4)) {
          ps4.setString(1, email);
          try (ResultSet rs4 = ps4.executeQuery()) {
            rs4.next();
            supervisor_id = rs4.getInt("id");
          }
        }
				
				String query5 = "insert into internship(title, creation_date, content, supervisor_id, scientific_validated, administr_validated, is_taken, program_id, is_confidential)" +
						" values (?, ?, ?, ?, false, false, false, ?, ?) ;";
				
				InputStream inputStream = uploadFile.getInputStream();

        if (inputStream != null) {
          try (PreparedStatement ps5 = con.prepareStatement(query5)) {
            ps5.setString(1, topicTitle);
            ps5.setDate(2, Date.valueOf(java.time.LocalDate.now()));
            ps5.setBinaryStream(3, inputStream);
            ps5.setInt(4, supervisor_id);
            ps5.setInt(5, program_id);
            ps5.setBoolean(6, confidentialSubject);
            int row = ps5.executeUpdate();
            if (row <= 0) {
              System.out.println("ERROR: File was not uploaded and saved into database");
            }
          }
					
					String query6 = "select id from internship where title =? ;";
					try (PreparedStatement ps6 = con.prepareStatement(query6)) {
            ps6.setString(1, topicTitle);
            try (ResultSet rs6 = ps6.executeQuery()) {
              rs6.next();
              int internship_id = rs6.getInt("id");

              String query7 = "insert into internship_category(internship_id, category_id)" + 
                " values (?, ?) ;";
              try (PreparedStatement ps7 = con.prepareStatement(query7)) {
                ps7.setInt(1, internship_id);
                ps7.setInt(2, category_id);
                ps7.executeUpdate();
              }
            }
          }
        }
			}
			catch(SQLException e) {
				e.printStackTrace();
			}
			request.setAttribute("topicTitle", topicTitle);
			request.getRequestDispatcher("upload_complete.jsp").forward(request, response);
		}
		else {
			request.setAttribute("firstName", firstName);
			request.setAttribute("lastName", lastName);
			request.setAttribute("email", email);
			request.setAttribute("topicTitle", topicTitle);
			request.setAttribute("err_message", errorMessage);
			List<Program> programs = loadData();
			request.setAttribute("programs", programs);
			request.getRequestDispatcher("upload_topic.jsp").forward(request, response);
		}
	}
	
	private List<Program> loadData() {
		List<Program> programs = new ArrayList<>();
		try (Connection con = DbUtils.getConnection()) {
			if (con == null) {
				return null;
			}
			
			String query1 = "SELECT DISTINCT id, name, year FROM program;";
			try (
           PreparedStatement ps1 = con.prepareStatement(query1);
           ResultSet rs1 = ps1.executeQuery();
      ) {
        while(rs1.next()) {
          Program p = new Program(rs1.getInt("id"), rs1.getString("name"), rs1.getString("year"));
          programs.add(p);
        }
      }

			for (Program program : programs) {
				String query = "SELECT DISTINCT c.description AS desc, c.id as id \n" +
						"FROM categories c\n" +
						"INNER JOIN program_category pc ON pc.cat_id = c.id\n" +
						"WHERE pc.program_id = ? ;";
				try (PreparedStatement stmt = con.prepareStatement(query)) {
          stmt.setInt(1, Integer.parseInt(program.getId()));
          try (ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
              Category c = new Category(rs.getString("desc"), rs.getInt("id"));
              program.addCategory(c);
            }
          }
        }
			}

		} catch(SQLException e) {
			e.printStackTrace();
		}
		return programs;
	}

	private String checkEntries(String firstName, String lastName, String email, String topicTitle, String program_id_string, String category_id_string, Part uploadFile) {
		if(firstName==null || firstName.equals("")) {
			return "Please enter a first name.";
		} else if(lastName==null || lastName.equals("")) {
			return "Please enter a last name.";
		} else if(email==null || email.equals("")) {
			return "Please enter an email.";
		} else if(topicTitle==null || topicTitle.equals("")) {
			return "Please choose a topic title.";
		} else if(checkTitle(topicTitle)) {
			return "The topic title is already taken.";
		} else if(program_id_string==null || program_id_string.equals("0")) {
			return "Please choose a program.";
		} else if(category_id_string==null || category_id_string.equals("0") || category_id_string.equals("-1")) {
			return "Please choose a category of your program.";
		} else {
			boolean emailIsValid = true;
			try {
				InternetAddress emailAddr = new InternetAddress(email);
				emailAddr.validate();
			} catch (AddressException e) {
				e.printStackTrace();
				emailIsValid = false;
			}
			if(emailIsValid) {
				if(uploadFile.getSize()==0) { // DOESN'T WORK
					return "Please submit your internship description as a PDF file. (16Mo max)";
				}
				return "None";
			} else { 
				return "Please enter a valid email.";
			}
		}  
	}
	
	private boolean checkEmail(String email) {
		boolean st = false;
		try (Connection con = DbUtils.getConnection()) {
			if (con == null) {
				return false;
			}

			String query = "select * from person where email=?;";

			try (PreparedStatement ps = con.prepareStatement(query)) {
        ps.setString(1, email);
        try (ResultSet rs = ps.executeQuery()) {
          st = rs.next();
        }
      }
		}
		catch(SQLException e) {
			e.printStackTrace();
		}
		return st;      
	}
	
	private boolean checkTitle(String topicTitle) {
		boolean st = false;
		try (Connection con = DbUtils.getConnection()) {
			if (con == null) {
				return false;
			}

			String query = "select * from internship where title=?;";

			try (PreparedStatement ps = con.prepareStatement(query)) {
        ps.setString(1, topicTitle);
        try (ResultSet rs = ps.executeQuery()) {
          st = rs.next();
        }
      }
          
		} catch(SQLException e) {
			e.printStackTrace();
		}
		return st;
	}
}
