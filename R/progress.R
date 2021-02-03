new_progress <- function() {
        n <- 0L
        chars <- c("|", "/", "-", "\\", "|", "/", "-", "\\")
        show <- function()
        {
                n <<- n + 1L
                cat("Processed ", format(n, width = 9), " batches", 
                    file = stderr())
                cat(" ", chars[n %% length(chars)], file = stderr())
                cat("\r", file = stderr())
                flush(stderr())
        }
        terminate <- function() 
        {
                cat("\n", file = stderr())
                flush(stderr())
        }
        list(show = show, terminate = terminate)
}