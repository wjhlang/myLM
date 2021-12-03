#' myLM
#'
#' Fit a linear model'
#' @export
#' @importFrom stats model.frame model.matrix setNames terms

myLM <- function(formula, data, weights = NULL, subset = NULL, na.action,
                 method = "qr", model = TRUE, x = FALSE, y = FALSE,
                 qr = TRUE, singular.ok = TRUE, contrasts = NULL,
                 offset, ...){
  if (class(formula) != "formula"){
    stop('Invalid input, an object of class "formula" is expected.')
  }
  # Get and set na.action
  action = getOption("na.action")
  options(na.action=action)
  # If method = "model.frame" returns the model frame.
  if (method == "model.frame"){
    # Get all the covariates
    myx = model.matrix(formula, data = data, contrasts.arg = contrasts)
    myframe = model.frame(formula, data = data)
    dfx = as.data.frame(myx)
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
  # If subset is non-null, a string is expected
  if (!is.null(subset) && is.character(subset)){
    data = subset(data, eval(parse(text=subset)))
  } else if(!is.null(subset) && !is.character(subset)){
    stop('Invalid input, subset is expected to be a string.')
  }
  # The output list
  listname = c("coefficients", "residuals", "effect", "rank", "fitted.values", "assign", "qr", "df.residual", "call", "terms", "model", "x", "y")
  fit <- setNames(vector("list", length(listname)), listname)
  #fit = list()
  # Get all the covariates
  myx = model.matrix(formula, data = data, contrasts.arg = contrasts)
  myframe = model.frame(formula, data = data)
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
    beta = solve(tx%*%diag(weights)%*%myx) %*% tx%*%diag(weights)%*%myy
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
  # Add rank to the list
  fit[["rank"]] = myqr$rank
  # Add assign to the list
  myassign = attr(myx,"assign")
  fit[["assign"]] = myassign
  # Add df.residual to the list
  fit[["df.residual"]] = n - ncol(myx)
  # Add call to the list
  fit[["call"]] = match.call
  # Get the terms object used
  myterms = terms(formula)
  fit[["terms"]] = myterms

  # if requested (the default), get the model frame used
  if(model == TRUE){
    dfx = as.data.frame(myx)
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
  # Convert fit to class "lm" for summary and diagnostic plots
  class(fit) <- c("lm")
  fit
}
