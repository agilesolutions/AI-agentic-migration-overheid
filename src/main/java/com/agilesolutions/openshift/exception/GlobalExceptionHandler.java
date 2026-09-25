package com.agilesolutions.openshift.exception;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.ConstraintViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.net.URI;
import java.time.OffsetDateTime;
import java.util.stream.Collectors;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(NotebookNotFoundException.class)
    public ProblemDetail handleNotebookNotFound(
            NotebookNotFoundException exception,
            HttpServletRequest request) {

        ProblemDetail problem = ProblemDetail.forStatusAndDetail(
                HttpStatus.NOT_FOUND,
                exception.getMessage()
        );

        problem.setTitle("Notebook not found");
        problem.setType(URI.create(
                "https://api.example.com/problems/notebook-not-found"
        ));
        problem.setInstance(URI.create(request.getRequestURI()));

        addCommonProperties(problem);

        return problem;
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ProblemDetail handleValidation(
            MethodArgumentNotValidException exception,
            HttpServletRequest request) {

        String detail = exception.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(error -> error.getField() + ": " + error.getDefaultMessage())
                .collect(Collectors.joining(", "));

        ProblemDetail problem = ProblemDetail.forStatusAndDetail(
                HttpStatus.BAD_REQUEST,
                detail
        );

        problem.setTitle("Validation failed");
        problem.setType(URI.create(
                "https://api.example.com/problems/validation-error"
        ));
        problem.setInstance(URI.create(request.getRequestURI()));

        addCommonProperties(problem);

        return problem;
    }

    @ExceptionHandler(ConstraintViolationException.class)
    public ProblemDetail handleConstraintViolation(
            ConstraintViolationException exception,
            HttpServletRequest request) {

        ProblemDetail problem = ProblemDetail.forStatusAndDetail(
                HttpStatus.BAD_REQUEST,
                exception.getMessage()
        );

        problem.setTitle("Constraint violation");
        problem.setType(URI.create(
                "https://api.example.com/problems/constraint-violation"
        ));
        problem.setInstance(URI.create(request.getRequestURI()));

        addCommonProperties(problem);

        return problem;
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ProblemDetail handleIllegalArgument(
            IllegalArgumentException exception,
            HttpServletRequest request) {

        ProblemDetail problem = ProblemDetail.forStatusAndDetail(
                HttpStatus.BAD_REQUEST,
                exception.getMessage()
        );

        problem.setTitle("Invalid request");
        problem.setType(URI.create(
                "https://api.example.com/problems/invalid-request"
        ));
        problem.setInstance(URI.create(request.getRequestURI()));

        addCommonProperties(problem);

        return problem;
    }

    @ExceptionHandler(Exception.class)
    public ProblemDetail handleUnexpectedException(
            Exception exception,
            HttpServletRequest request) {

        ProblemDetail problem = ProblemDetail.forStatusAndDetail(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "An unexpected error occurred."
        );

        problem.setTitle("Internal server error");
        problem.setType(URI.create(
                "https://api.example.com/problems/internal-server-error"
        ));
        problem.setInstance(URI.create(request.getRequestURI()));

        addCommonProperties(problem);

        return problem;
    }

    private void addCommonProperties(ProblemDetail problem) {
        problem.setProperty("timestamp", OffsetDateTime.now());
    }
}