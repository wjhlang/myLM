#' myLM
#'
#' Implementing a Linear Regression Model.
#'
#' @param formula an object of class "formula": a symbolic description of the model to be fitted. A 1-D vector of response is expected.
#' @param data an optional data frame, list or environment containing the variables in the model. Default to NULL and then the variables are taken from formula.
#' @param subset an optional string specifying a subset of observations to be used in the fitting process, default to NULL.
#' @param weights	an optional vector of weights to be used in the fitting process, default to NULL. If non-NULL, weighted least squares is used with weights, otherwise ordinary least squares is used.
#' @param na.actions an user specified action when dealing with NA values, can be viewed by getOption("na.action").
#' @param method the method to be used when fitting the model, defaulted and currently only supported with "qr". method = "model.frame" returns the model frame without fitting the model.
#' @param model,x,y,qr logicals. Will return the corresponding components of the fit if TRUE.
#' @param contrasts an optional list, whose entries are values to be used as replacement values for the contrasts replacement function and whose names are the names of columns of data containing factors.
#'
#' @return lm returns an object of class "lm". If not assigned to anything, myLM will print the function and the coefficients of the model fitted.
#'
#' An object of class "lm" is a list containing at least the following components:
#'
#' \item{coefficients}{a named vector of coefficients.}
#' \item{residuals}{a named vector of residuals.}
#' \item{effect}{a named vector of effects that are the uncorrelated single-degree-of-freedom values obtained by projecting the data onto the successive orthogonal subspaces generated by the QR decomposition during the fitting process.}
#' \item{rank}{the numeric rank of the fitted linear model.}
#' \item{fitted.values}{the fitted mean values.}
#' \item{assign}{an integer vector with an entry for each column in the matrix giving the term in the formula which gave rise to the column.}
#' \item{qr}{if requested, the QR decomposition of the design matrix.}
#' \item{df.residual}{the residual degrees of freedom.}
#' \item{call}{the matched call.}
#' \item{terms}{the terms object for the formula.}
#' \item{contrasts}{(only where relevant) the contrasts used.}
#' \item{model}{if requested, the model frame used, including the intersections.}
#' \item{x}{if requested, the design matrix used.}
#' \item{y}{if requested, the response used.}
#' \item{na.action}{(only where relevant) if not default, the assigned na.action}
#' \item{F-statistics}{The F-statistics and associated p-value}
#'
#'
#' @examples
#' data("iris")
#' x = iris$Petal.Width
#' y = iris$Petal.Length
#' myLM(y~x)
#' # Equivalently
#' myLM(Petal.Length~Petal.Width, data = iris)
#'
#' @export
#' @importFrom stats model.frame model.matrix setNames terms

myLM <- function(formula, data = NULL, weights = NULL, subset = NULL, na.actions = NULL,
                 method = "qr", model = TRUE, x = FALSE, y = FALSE,
                 qr = TRUE, contrasts = NULL){
  if (class(formula) != "formula"){
    stop('Invalid input, an object of class "formula" is expected.')
  }
  # The output list
  listname = c("coefficients", "residuals", "effect", "rank", "fitted.values", "assign", "qr", "df.residual", "call", "terms", "contrasts", "model", "x", "y", "na.action", "F-statistics")
  fit <- setNames(vector("list", length(listname)), listname)
  # Get and set na.action
  if(is.null(na.actions)){
    action = getOption("na.action")
    options(na.action=action)
  } else{
    options(na.action=na.actions)
  }
  fit[["na.action"]] = na.actions

  # If method = "model.frame" returns the model frame.
  if (method == "model.frame"){
    # Get all the covariates
    if (!is.null(data)){
      myx = model.matrix(formula, data = data, contrasts.arg = contrasts)
      myframe = model.frame(formula, data = data)
    } else {
      myx = model.matrix(formula, contrasts.arg = contrasts)
      myframe = model.frame(formula)
    }
    dfx = as.data.frame(myx)
    # In case of matrix of x
    myframe = as.matrix(myframe)
    myframe = as.data.frame(myframe)
    # Change myframe colnames as model.frame and model.matrix generate different names
    colnames(myframe) = gsub("\\.(?=[0-9])", "", colnames(myframe), perl=TRUE)
    # Get common columns
    common = intersect(colnames(myframe),  colnames(dfx))
    # Get the different columns (interactions) and keep the column name
    noncommon = dfx[,!names(dfx) %in% c("(Intercept)", common), drop = FALSE]
    # Generate a model with the response and all covariates
    mymodel = cbind(myframe, noncommon)
    return(mymodel)
  } else if(method != "qr"){
    warning(paste0("method = '",method,"' is not supported. Using 'qr'"))
  }
  # Get all the covariates
  if (!is.null(data)){
    if (is.data.frame(data) | is.list(data)){
      myx = model.matrix(formula, data = data, contrasts.arg = contrasts)
      myframe = model.frame(formula, data = data)
    } else {
      stop("Invalid input, 'data' must be a data.frame or list, not a matrix or an array.")
    }
  } else {
    myx = model.matrix(formula, contrasts.arg = contrasts)
    myframe = model.frame(formula)
  }
  # Add assign to the list
  myassign = attr(myx,"assign")
  fit[["assign"]] = myassign

  # If subset is non-null, a string is expected
  if (!is.null(subset) && is.character(subset) && length(subset) == 1){
    myx = subset(as.data.frame(myx), eval(parse(text=subset)))
    myx = as.matrix(myx)
    myframe = subset(myframe, eval(parse(text=subset)))
  } else if(!is.null(subset) && (!is.character(subset) || length(subset) != 1)){
    stop('Invalid input, subset is expected to be a string.')
  }
  # Transpose x
  tx = t(myx)
  # Get the number of observations
  myy = myframe[,1]
  n = length(myy)

  # Compute the coefficients
  if (is.null(weights)){
    # Ordinary least squared
    beta = solve(tx%*%myx) %*% tx%*%myy
  } else if(length(weights) != n){
    stop("variable lengths differ (found for '(weights)').")
  } else {
    # Use weighted least squared if weights is non-null
    diagw = diag(weights)
    beta = solve(tx%*%diagw%*%myx) %*% tx%*%diagw%*%myy
  }
  # Convert beta to a named vector
  mybeta = setNames(beta[,1], rownames(beta))
  fit[["coefficients"]] = mybeta
  # Compute the fitted values
  ypred = myx%*%beta
  myfitted = setNames(ypred[,1], rownames(ypred))
  fit[["fitted.values"]] = myfitted
  # Compute the residuals
  res = myy - ypred
  myres = setNames(res[,1], rownames(res))
  fit[["residuals"]] = myres

  # Get the QR decomposition
  myqr = qr(myx)
  # if requested (the default), add qr to the list
  if (qr == TRUE){
    fit[["qr"]] = myqr
  } else if(qr == FALSE){
    fit[["qr"]] = NULL
  } else {
    stop("Invalid input, qr is expected to be logical.")
  }

  # Get the effect
  myeffect = qr.qty(myqr, myy)
  fit[["effect"]] = myeffect
  fit[["rank"]] = myqr$rank
  fit[["df.residual"]] = n - ncol(myx)
  fit[["call"]] = match.call()

  # Get the terms object used
  myterms = terms(formula)
  fit[["terms"]] = myterms
  fit[["contrasts"]] = contrasts
  # if requested (the default), get the model frame used
  if(model == TRUE){
    dfx = as.data.frame(myx)
    # In case of matrix of x
    myframe = as.matrix(myframe)
    myframe = as.data.frame(myframe)
    # Change myframe colnames as model.frame and model.matrix generate different names
    colnames(myframe) = gsub("\\.(?=[0-9])", "", colnames(myframe), perl=TRUE)
    # Get common columns
    common = intersect(colnames(myframe),  colnames(dfx))
    # Get the different columns (interactions) and keep the column name
    noncommon = dfx[,!names(dfx) %in% c("(Intercept)", common), drop = FALSE]
    # Generate a model with the response and all covariates
    mymodel = cbind(myframe, noncommon)
    fit[["model"]] = mymodel
  } else if(model == FALSE){
    fit[["model"]] = NULL
  } else {
    stop("Invalid input, model is expected to be logical.")
  }

  if (x == TRUE){
    fit[["x"]] = myx
  } else if(x == FALSE){
    fit[["x"]] = NULL
  } else {
    stop("Invalid input, x is expected to be logical.")
  }

  # If y true, convert to named vector and add to list
  myy = setNames(myy, 1:n)
  if (y == TRUE){
    fit[["y"]] = myy
  } else if(y == FALSE){
    fit[["y"]] = NULL
  } else {
    stop("Invalid input, y is expected to be logical.")
  }

  # Calculate F-statistics
  SSE = sum(myres^2)
  SSR = sum((myfitted - mean(myy))^2)
  df1 = length(beta)- 1
  df2 = n-length(beta)
  Fstat = (SSR/df1)/(SSE/df2)
  pval = pf(Fstat, df1, df2, lower.tail = FALSE)
  fit[["F-statistics"]] = paste0("F-statistic: ", Fstat, " on ", df1, " and ", df2, " DF, p-value: ", pval)

  # Convert fit to class "lm" for summary and diagnostic plots
  class(fit) <- c("lm")
  fit
}
