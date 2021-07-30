test_that("smoothers() returns a character vector", {
        expect_vector(smoothers(), character())
})

test_that("info() is defined for all smoothers", {
        for (smoother in smoothers())
                capture_output( expect_error(info(smoother), NA) )
})

test_that("info() returns NULL, invisibly", {
        capture_output( expect_invisible(info("sbo")) )
        capture_output( expect_null(info("sbo")) )
})