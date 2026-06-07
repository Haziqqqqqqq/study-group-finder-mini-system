<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" language="java" %>
<%@ page import="java.io.PrintWriter, java.io.StringWriter" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>500 - Server Error</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light d-flex align-items-center justify-content-center" style="min-height: 100vh;">
    <div class="container py-5 text-center" style="max-width: 800px;">
        <h1 class="display-1 fw-bold text-danger">500</h1>
        <p class="fs-4 text-muted">Sorry, our server encountered an internal error.</p>
        <p class="text-muted small">${error}</p>
        
        <div class="text-start bg-dark text-light p-3 rounded overflow-auto mt-4" style="max-height: 400px; font-family: monospace; font-size: 0.85rem;">
<%
    Throwable t = exception;
    if (t == null) t = (Throwable) request.getAttribute("javax.servlet.error.exception");
    if (t != null) {
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        t.printStackTrace(pw);
        out.println(sw.toString().replace("<", "&lt;").replace(">", "&gt;").replace("\n", "<br/>"));
    } else {
        out.println("No exception object found in request.");
    }
%>
        </div>

        <a href="${pageContext.request.contextPath}/" class="btn btn-primary mt-4">Go to Homepage</a>
    </div>
</body>
</html>
