# check if k-gram probability smoother is correctly specified
validate_smoother <- function(smoother, ...) {
        assert_smoother(smoother)
        args <- list(...)
        # Retrieve smoother parameters
        parameters <- list_parameters(smoother)
        
        # Check presence or validity of various arguments
        for (parameter in parameters) {
                name <- parameter$name
                default <- parameter$default
                if (is.null(args[[name]]))
                        smoother_par_missing(smoother, name, default)
                else if (!parameter$validator(args[[name]]))
                        smoother_par_error(smoother, name, parameter$expected)
        }
}

smoother_par_missing <- function(smoother, name, default) {
        rlang::warn(
                class = "kgrams_missing_par_warning", 
                message = c(
                        paste0("Missing parameter for smoother '", smoother, "'"
                               ),
                        x = name,
                        i = "Using the following default value:",
                        paste0(name, " = ", default)
                        ),
                .frequency = "once",
                .frequency_id = paste0(smoother, "_", name) 
                )
}

smoother_par_error <- function(smoother, name, expected) {
        rlang::abort(
                class = "kgrams_invalid_par_error",
                message = c(
                        paste0("Invalid parameter for smoother '", smoother, "'"
                               ),
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
                            expected = "a number in (0, 1)",
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
                            expected = "a number in (0, 1)",
                            default = 0.75,
                            validator = function(x)
                                    isTRUE(is.numeric(x) & 0 < x & x < 1)
                       )
               ),
               mkn = list(
                       list(name = "D1",
                            expected = "a number  in (0, 1)",
                            default = 0.75,
                            validator = function(x)
                                    isTRUE(is.numeric(x) & 0 < x & x < 1)
                       ),
                       list(name = "D2",
                            expected = "a number in (0, 1)",
                            default = 0.75,
                            validator = function(x)
                                    isTRUE(is.numeric(x) & 0 < x & x < 1)
                       ),
                       list(name = "D3",
                            expected = "a number in (0, 1)",
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
