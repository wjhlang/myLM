# myLM
Implementing Linear Regression Model

<!-- Badges Start -->
[![R-CMD-check](https://github.com/wjhlang/myLM/workflows/R-CMD-check/badge.svg)](https://github.com/wjhlang/myLM/actions)
[![codecov](https://codecov.io/gh/wjhlang/myLM/branch/main/graph/badge.svg?token=VJPRJOQ2B3)](https://codecov.io/gh/wjhlang/myLM)
<!-- Badges End -->


## Overview
myLM is a package implementing the original lm function, generating the same output with some optimization. This package aims to output the exact same output as the original lm() function with minimal optimization.

## Installation
```
devtools::install_github("wjhlang/myLM")
library(myLM)
```
## Usage
```
library(myLM)
data("iris")
myLM(Petal.Length~Petal.Width*Sepal.Width,data = iris, model = T)


```
