<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"
    import="edu.polytechnique.inf553.Person"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="en">
<head>
	<title>Login V8</title>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
<!--===============================================================================================-->	
	<link rel="icon" type="image/png" href="images/icons/favicon.ico"/>
<!--===============================================================================================-->
	<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.5.3/dist/css/bootstrap.min.css" integrity="sha384-TX8t27EcRE3e/ihU7zmQxVncDAy5uIKz4rEkgIXeMed4M0jlfIDPvg6uqKI2xXr2" crossorigin="anonymous">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="fonts/font-awesome-4.7.0/css/font-awesome.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="vendor/animate/animate.css">
<!--===============================================================================================-->	
	<link rel="stylesheet" type="text/css" href="vendor/css-hamburgers/hamburgers.min.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="vendor/animsition/css/animsition.min.css">
<!--===============================================================================================-->	
	<link rel="stylesheet" type="text/css" href="vendor/daterangepicker/daterangepicker.css">
<!--===============================================================================================-->
	<link rel="stylesheet" type="text/css" href="css/util.css">
	<link rel="stylesheet" type="text/css" href="css/main.css">
	<link rel="stylesheet" type="text/css" href="css/table.css">
<!--===============================================================================================-->
    <script src="https://code.jquery.com/jquery-3.5.1.min.js" integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0=" crossorigin="anonymous"></script>
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.0-beta1/dist/js/bootstrap.bundle.min.js" integrity="sha384-ygbV9kiqUc6oa4msXn9868pTtWMgiQaeYH7/t7LECLbyPA2x65Kgf80OJFdroafW" crossorigin="anonymous"></script>
	<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-beta.1/dist/css/select2.min.css" rel="stylesheet" />
	<script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-beta.1/dist/js/select2.min.js"></script>
<!--===============================================================================================-->

</head>
<style>
	.responsive-table li.table-row{
		margin-bottom:10px;
		padding: 10px 30px;
	}
</style>
<body>

	<!-- navigation bar -->
	<nav class="navbar navbar-dark bg-dark">
	  <div class="container-fluid justify-content-start">
	    <a class="navbar-brand" href="/InternshipsAtX/dashboard">
	      <img src="images/logo.png" style="max-height: 35px;">
	      Internship Management
	    </a>
	    <div class="ml-auto d-flex">
	        <div class="nav-item dropdown">
	          <a class="text-white dropdown-toggle" href="#" id="navbarDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
	            ${user.role}: ${user.name}
	          </a>
	          <ul class="dropdown-menu" aria-labelledby="navbarDropdown" style="right:0;left:auto;">
	            ${ (user.role == "Admin") ? '<li><a class="dropdown-item" href="./user-management">User management</a></li>' : '' }
	            ${ (user.role == "Admin" || user.role == "Professor") ? '<li><a class="dropdown-item" href="./program-management">Program management</a></li>' : '' }
	            ${ (user.role == "Admin" || user.role == "Professor") ? '<li><a class="dropdown-item" href="./subject-management">Subject management</a></li>' : '' }
	            <li><hr class="dropdown-divider"></li>
	            <li><a class="dropdown-item" href="./LogoutServlet">Log out</a></li>
	          </ul>
	        </div>
	    </div>
	  </div>
	</nav>
	
	<!-- program management -->
	<div class="limiter">
		<div class="container-login100 background_style" style="min-height:30vh;">
			<div class="wrap-login100-V2">
				<div class="login100-form validate-form p-l-55 p-r-55 p-t-140 p-b-40">
					<span class="login100-form-title">
						<h1> Program Management </h1>
					</span>
					
					<!-- show all the programs -->
					<c:forEach items="${programs}" var="program">
						<div class="program-container mt-4">
						
							<!-- program title-->
							<div class="container-login100-form-btn-V2">
								<div class="program-title-container d-flex justify-content-between">
									<h2 class="login100-form-btn-V2 p-l-5 p-r-5 d-inline-flex ml-3" style="width:30%">
									${program.id}. ${program.name} - ${program.year} 
									</h2>
									<div class="program-actions">
										<button type="button" class="btn btn-secondary" data-bs-toggle="collapse" data-bs-target="#program-${program.id}" aria-expanded="false" aria-controls="#program-${program.id}">
										Show associated categories
										</button>
										<button type="button" class="btn btn-primary ml-3" onclick="deleteProgram(${program.id}, '${program.name}-${program.year}');">Delete Program</button>
									</div>
								</div>
							</div>

							<!-- categories associated with the program -->
							<div class="program-category text-center collapse mt-4" id="program-${program.id}">
								<ul class="responsive-table">
									<li class="table-header">
										<div class="col col-2"> Id </div>
										<div class="col col-7">Cetegory Description</div>
										<div class="col col-3">Action</div>
									</li>
									
									<!-- details of each category -->
									<c:forEach items="${program.categories}" var="category">
										<li class="table-row">
											<div class="col col-2" data-label="Id">${category.id}</div>
											<div class="col col-7" data-label="Cetegory Description">${category.name}</div>
											<div class="col col-3" data-label="Action">
												<button type="button" class="btn btn-secondary btn-sm" onclick="deleteCategoryFromProgram(this, ${category.id}, '${category.name}', ${program.id}, '${program.name}-${program.year}')">Remove</button>
											</div>
										</li>
									</c:forEach>

									<!-- form to associate a new category to the program -->
									<li class="table-row" style="background-color:lightblue;">
										<div class="col col-2" data-label="Id">NEW</div>
										<form class="col col-7 text-center">
										    <select  class="form-control w-75 d-inline" id="addCategory-${program.id}">
										    	<c:forEach items="${categories}" var="category">
										    		<!-- only show the categories not associated to the program -->
										    		<c:if test = "${!program.categories.contains(category)}">
										    			<option value="${category.id}">${category.name}</option>
										    		</c:if>
										    	</c:forEach>
										    </select>
										</form>
										<div class="col col-3" data-label="Id">
											<button type="submit" class="btn btn-secondary btn-sm" onclick="associateCategoryWithProgram(${program.id}, '${program.name}-${program.year}')">Add category</button>
										</div>
									</li>
								</ul>
							</div>					
						</div>
						<hr>
					</c:forEach>

					<!-- form to create new program -->
					<form class="create-program m-t-10 text-center" onsubmit="createProgram(event);">
						<div class="container-login100-form-btn-V2  p-t-25 p-b-25">
							<h2 class="login100-form-btn-V2 p-l-5 p-r-5 w-25 m-auto">
							New Program
							</h2>
						</div>
						<div class="form-group">
							<label for="programName" class="mr-3">Program name: </label>
						    <input type="text" placeholder="program name" class="form-control w-50 d-inline" id="programName">
						</div>
						<div class="form-group">
						  	<label for="programYear" class="mr-3">Program year: </label>
						    <input type="text" placeholder="program year" class="form-control w-50 d-inline" id="programYear">							
						</div>
					  <button class="btn btn-primary" type="submit">Create new program</button>
					</form>
					
				</div>
				
			</div>
		</div>
	</div>
	
	<!-- Category list -->
	<div class="limiter">
		<div class="container-login100 background_style" style="min-height:60vh;">
			<div class="wrap-login100-V2">
				<div class="login100-form validate-form p-l-55 p-r-55 p-t-178 p-b-40">
					<span class="login100-form-title">
						<h1> Category list </h1>
					</span>

					<!-- show all the categories -->
					<div class="text-center">
						<ul class="responsive-table">
							<li class="table-header">
								<div class="col col-2"> Id </div>
								<div class="col col-7">Cetegory Description</div>
								<div class="col col-3">Action</div>
							</li>
							
							<c:forEach items="${categories}" var="category">
								<li class="table-row">
									<div class="col col-2" data-label="Id">${category.id}</div>
									<div class="col col-7" data-label="Cetegory Description">${category.name}</div>
									<div class="col col-3" data-label="Action">
										<button type="button" class="btn btn-secondary btn-sm" onclick="deleteCategory(${category.id}, '${category.name}')">Delete</button>
									</div>
								</li>
							</c:forEach>
						</ul>
					</div>
					
					<!-- form to create new category -->
					<form class="create-category m-t-10 text-center" onsubmit = "createCategory(event);">
						<div class="container-login100-form-btn-V2  p-t-25 p-b-25">
							<h2 class="login100-form-btn-V2 p-l-5 p-r-5 w-25 m-auto">
							New Category
							</h2>
						</div>
						<div class="form-group">
							<label for="categoryName" class="mr-3">Category name: </label>
						    <input type="text" placeholder="category name" class="form-control w-50 d-inline" id="categoryName">
						</div>
					  <button class="btn btn-primary" type="submit">Create new category</button>
					</form>
					
				</div>
			</div>
		</div>
	</div>
	
<script>

function deleteProgram(id, name){
	var r = confirm("Are you sure you want to delete the program " + name + " ?");
	if (r == true) {
	    $.ajax({
	        type : "GET",
	        url : "DeleteProgramServlet",
	        data : "id=" + id ,
	        success : function(data) {
	        	console.log("delete program " + name);
	        	location.reload();
	        },
	        error: function(res){
	        	alert("Failed to delete the program" + name);
	        }
	    });
	}
}

function createProgram(e){
	// prevent refreshing page by default
	e.preventDefault();
	var pName = document.getElementById("programName").value;
	var pYear = document.getElementById("programYear").value;
	if(pName.trim() == ''){
		alert('Please enter a program name');
	}else if(pYear.trim() == ''){
		alert('Please enter a program year');
	}else if(!/\d{4}/.test(pYear)){
		alert('Year malformatted');
	}else{
	    $.ajax({
	        type : "GET",
	        url : "CreateProgramServlet",
	        data : "name=" + pName + "&year=" + pYear,
	        success : function(data) {
	        	console.log("create new program " + pName + " - " + pYear);
	        	// reload the new data
	        	location.reload();
	        },
	        error: function(res){
	        	alert("Failed to create new program");
	        }
	    });
	}
}

function deleteCategory(id, name){
	var r = confirm("Are you sure you want to delete the category " + name + " ?");
	if (r == true) {
	    $.ajax({
	        type : "GET",
	        url : "DeleteCategoryServlet",
	        data : "id=" + id ,
	        success : function(data) {
	        	console.log("delete category " + name);
	        	location.reload();
	        },
	        error: function(res){
	        	alert("Failed to delete the category " + name);
	        }
	    });
	}
}

function createCategory(e){
	var cName = document.getElementById("categoryName").value;
	// prevent refreshing page by default
	e.preventDefault();
	if(cName.trim() == ''){
		alert('Please enter a category name');
	}else{
	    $.ajax({
	        type : "GET",
	        url : "CreateCategoryServlet",
	        data : "name=" + cName,
	        success : function(data) {
	        	console.log("create new category " + cName);
	        	// reload the new data
	        	location.reload();
	        },
	        error: function(res){
	        	alert("Failed to create new category");
	        }
	    });
	}
}

function deleteCategoryFromProgram(ele, cid, cname, pid, pname){
 	var r = confirm("Are you sure you want to remove the category " + cname + " from the program " + pname + "?");
	if (r == true) {
	    $.ajax({
	        type : "GET",
	        url : "UpdateProgramCategoryServlet",
	        data : "type=delete&pid=" + pid + "&cid=" + cid,
	        success : function(data) {
	        	console.log("remove the category " + cname + " from the program " + pname);
	        	// delete the element in the page
	        	$(ele).parentsUntil("ul").remove();
	        },
	        error: function(res){
	        	alert("Failed to remove the category " + cname + " from the program " + pname);
	        }
	    });
	}
}

function associateCategoryWithProgram(pid, pname){
	var option =$("#addCategory-" + pid);
	var cid = option.val();
	var cname = $("#addCategory-" + pid).find("option:selected").text();
	var li = option.parent().parent();
    $.ajax({
        type : "GET",
        url : "UpdateProgramCategoryServlet",
        data : "type=add&pid=" + pid + "&cid=" + cid,
        success : function(data) {
        	console.log("associate the category " + cid + " with the program " + pid);
        	// add the category under the category list of program
        	li.before("<li class='table-row'>" +
    				"<div class='col col-2' data-label='Id'>" + cid + "</div>" +
    				"<div class='col col-7' data-label='Cetegory Description'>" + cname + "</div>" +
    				"<div class='col col-3' data-label='Action'>" +
    					"<button type='button' class='btn btn-secondary btn-sm' onclick='deleteCategoryFromProgram(this, " +cid+ ", " + cname + ", " +pid+ ", " +pname+ ")'>Remove</button>" +
    				"</div>" +
    			  "</li>")
    		// delete the category option in the selection box
    		$("#addCategory-" + pid).find("option:selected").remove();
        },
        error: function(res){
        	alert("Failed to associate the category " + cid + " with the program " + pid);
        }
    }); 
}

</script>

</body>
</html>