test_that("myLM works", {
  expect_equal(round(as.numeric(myLM(Petal.Length~Petal.Width, data = iris)$coefficients),6), c(1.083558,2.229940))
})
