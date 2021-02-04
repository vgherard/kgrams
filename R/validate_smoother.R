assert_exists_smoother <- function(smoother) {
        # Check that smoother is valid
        if (isFALSE(is.character(smoother) & smoother %in% smoothers()))
                rlang::abort(
                        class = c("smoother_error", "domain_error"),
                        message = c("Invalid smoother",
                                    i = "List of available smoothers:",
                                    paste(smoothers(), collapse = ", "))
                )
}

# check if k-gram probability smoother is correctly specified
validate_smoother <- function(smoother, ...) {
        assert_exists_smoother(smoother)
        args <- list(...)
        # Retrieve smoother parameters
        parameters <- list_parameters(smoother)
        
        # Check presence or validity of various arguments
        for (parameter in parameters) {
                name <- parameter$name
                default <- parameter$default
                expected <- parameter$expected
                is_valid <- parameter$validator
                if (is.null(args[[name]]))
                        smoother_domain_missing(smoother, name, default)
                else if (!is_valid(args[[name]]))
                        smoother_domain_error(smoother, name, expected)
        }
}

smoother_domain_missing <- function(sm, name, default) {
        rlang::warn(
                class = "smoother_domain_missing", 
                message = c(
                        paste0("Missing parameter for smoother '", sm, "'"),
                        x = name,
                        i = "Using the following default value:",
                        paste0(name, " = ", default)
                        ),
                .frequency = "once",
                .frequency_id = paste0(sm, "_", name) 
                )
}

smoother_domain_error <- function(sm, name, expected) {
        rlang::abort(
                class = c("smoother_error", "domain_error"),
                message = c(
                        paste0("Invalid parameter for smoother '", sm, "'"),
                        x = name,
                        i = "Expected type:",
                        paste0(name, ": ", expected)
                        )
                )
}

# list of parameters for the various smoothers
list_parameters <- function(smoother) {
        switch(smoother,
               sbo = list(
                       list(name = "lambda",
                            expected = "a number between zero and one",
                            default = 0.4,
                            validator = function(x)
                                    isTRUE(is.numeric(x) & 0 < x & x < 1)
                       )
               ),
               add_k = list(
                       list(name = "k",
                            expected = "a positive number",
                            default = 1.0,  
                            validator = function(x)
                                    isTRUE(is.numeric(x) & 0 < x)
                       )
               ),
               laplace = list(),
               ml = list(),
               kn = list(
                       list(name = "D",
                            expected = "a number between zero and one",
                            default = 0.75,
                            validator = function(x)
                                    isTRUE(is.numeric(x) & 0 < x & x < 1)
                       )
               ),
               mkn = list(
                       list(name = "D1",
                            expected = "a number between zero and one",
                            default = 0.75,
                            validator = function(x)
                                    isTRUE(is.numeric(x) & 0 < x & x < 1)
                       ),
                       list(name = "D2",
                            expected = "a number between zero and one",
                            default = 0.75,
                            validator = function(x)
                                    isTRUE(is.numeric(x) & 0 < x & x < 1)
                       ),
                       list(name = "D3",
                            expected = "a number between zero and one",
                            default = 0.75,
                            validator = function(x)
                                    isTRUE(is.numeric(x) & 0 < x & x < 1)
                       )
               ),
               abs = list(
                       list(name = "D",
                            expected = "a number between zero and one",
                            default = 0.75,
                            validator = function(x)
                                    isTRUE(is.numeric(x) & 0 < x & x < 1)
                       )
               ),
               wb = list()
        )
}