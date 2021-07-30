test_that("minimal test to ensure correct definition", {
        # R < 4 misteoriously messes with tests involving this infix op.
        # TODO: investigate
        skip_if(R.version$major < 4,
                message = "Test not available for R < 4"
        )   
        expect_identical("a" %+% "b", "a b")
})
