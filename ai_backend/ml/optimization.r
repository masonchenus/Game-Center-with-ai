# Machine Learning Optimization Scripts
# R language scripts for ML model optimization and tuning
# Used by both game center and ai_backend for AI model optimization

# ============================================================================
# DATA PREPARATION
# ============================================================================

#' Prepare features for ML training
#' @param data Raw data frame
#' @param target_col Name of target column
#' @param feature_cols Names of feature columns
#' @return List with features matrix and target vector
prepare_features <- function(data, target_col, feature_cols = NULL) {
  if (is.null(feature_cols)) {
    feature_cols <- setdiff(colnames(data), target_col)
  }
  
  # Handle missing values
  data_clean <- data[complete.cases(data[, c(target_col, feature_cols)]), ]
  
  # Create feature matrix
  X <- as.matrix(data_clean[, feature_cols, drop = FALSE])
  y <- data_clean[[target_col]]
  
  # Normalize features if needed
  X_scaled <- scale(X)
  
  return(list(
    X = X_scaled,
    y = y,
    feature_names = feature_cols,
    data = data_clean
  ))
}

#' Create time series features from score history
#' @param scores Vector of scores over time
#' @param lag_features Number of lag features to create
#' @return Data frame with features
create_time_features <- function(scores, lag_features = 5) {
  df <- data.frame(score = scores)
  
  # Lag features
  for (i in 1:lag_features) {
    df[[paste0("lag_", i)]] <- c(rep(NA, i), scores[1:(length(scores) - i)])
  }
  
  # Rolling statistics
  df$rolling_mean_3 <- zoo::rollmean(scores, k = 3, fill = NA)
  df$rolling_mean_5 <- zoo::rollmean(scores, k = 5, fill = NA)
  df$rolling_sd_3 <- zoo::rollapply(scores, width = 3, FUN = sd, fill = NA)
  df$rolling_sd_5 <- zoo::rollapply(scores, width = 5, FUN = sd, fill = NA)
  
  # Momentum features
  df$momentum_1 <- scores - lag(scores, 1)
  df$momentum_3 <- scores - lag(scores, 3)
  
  # Rate of change
  df$roc_1 <- (scores - lag(scores, 1)) / lag(scores, 1)
  df$roc_3 <- (scores - lag(scores, 3)) / lag(scores, 3)
  
  return(df)
}

# ============================================================================
# MODEL TRAINING
# ============================================================================

#' Train random forest model with cross-validation
#' @param X Feature matrix
#' @param y Target vector
#' @param n_trees Number of trees
#' @param cv_folds Number of cross-validation folds
#' @return Trained model with CV results
train_random_forest <- function(X, y, n_trees = 100, cv_folds = 5) {
  # Create data frame for training
  train_data <- as.data.frame(X)
  train_data$y <- y
  
  # Set up cross-validation
  cv_indices <- caret::createFolds(y, k = cv_folds, returnTrain = TRUE)
  
  cv_results <- list()
  
  for (fold in 1:cv_folds) {
    train_indices <- cv_indices[[fold]]
    val_indices <- setdiff(1:nrow(X), train_indices)
    
    train_fold <- train_data[train_indices, ]
    val_fold <- train_data[val_indices, ]
    
    # Train model
    model <- randomForest::randomForest(
      y ~ ., 
      data = train_fold, 
      ntree = n_trees,
      importance = TRUE
    )
    
    # Validate
    predictions <- predict(model, newdata = val_fold)
    rmse <- sqrt(mean((predictions - val_fold$y)^2))
    mae <- mean(abs(predictions - val_fold$y))
    
    cv_results[[fold]] <- list(
      model = model,
      rmse = rmse,
      mae = mae,
      r_squared = 1 - sum((predictions - val_fold$y)^2) / sum((val_fold$y - mean(val_fold$y))^2)
    )
  }
  
  # Train final model on all data
  final_model <- randomForest::randomForest(
    y ~ ., 
    data = train_data, 
    ntree = n_trees,
    importance = TRUE
  )
  
  # Calculate average CV performance
  avg_rmse <- mean(sapply(cv_results, function(x) x$rmse))
  avg_mae <- mean(sapply(cv_results, function(x) x$mae))
  avg_r2 <- mean(sapply(cv_results, function(x) x$r_squared))
  
  return(list(
    model = final_model,
    cv_results = cv_results,
    performance = list(
      cv_rmse = avg_rmse,
      cv_mae = avg_mae,
      cv_r2 = avg_r2
    ),
    feature_importance = randomForest::importance(final_model)
  ))
}

#' Train gradient boosting model
#' @param X Feature matrix
#' @param y Target vector
#' @param params Model parameters list
#' @param cv_folds Number of CV folds
#' @return Trained model with results
train_gradient_boosting <- function(X, y, params = list(
  nrounds = 100,
  max_depth = 6,
  eta = 0.1,
  gamma = 0,
  colsample_bytree = 1,
  min_child_weight = 1
), cv_folds = 5) {
  
  # Prepare data for xgboost
  dtrain <- xgboost::xgb.DMatrix(data = X, label = y)
  
  # Cross-validation
  cv_results <- xgboost::xgb.cv(
    params = params,
    data = dtrain,
    nrounds = params$nrounds,
    nfold = cv_folds,
    early_stopping_rounds = 10,
    metrics = "rmse",
    verbose = FALSE
  )
  
  # Train final model
  final_model <- xgboost::xgboost(
    params = params,
    data = dtrain,
    nrounds = nrow(cv_results$evaluation_log),
    verbose = FALSE
  )
  
  return(list(
    model = final_model,
    cv_results = cv_results,
    best_iteration = which.min(cv_results$evaluation_log$test_rmse_mean)
  ))
}

#' Train neural network model
#' @param X Feature matrix
#' @param y Target vector
#' @param hidden_layers Vector of hidden layer sizes
#' @param cv_folds Number of CV folds
#' @return Trained model with results
train_neural_network <- function(X, y, hidden_layers = c(64, 32), cv_folds = 5) {
  # Normalize data
  X_scaled <- scale(X)
  
  # Create formula
  p <- ncol(X)
  formula <- as.formula(paste("y ~", paste(rep(".", p), collapse = "+")))
  
  # Train/validation split
  train_indices <- createDataPartition(y, p = 0.8, list = FALSE)
  
  X_train <- X_scaled[train_indices, ]
  X_val <- X_scaled[-train_indices, ]
  y_train <- y[train_indices]
  y_val <- y[-train_indices]
  
  # Train neural network
  model <- neuralnet::neuralnet(
    formula,
    data = data.frame(X_train, y = y_train),
    hidden = hidden_layers,
    linear.output = TRUE,
    stepmax = 1e6
  )
  
  # Evaluate
  predictions <- neuralnet::compute(model, X_val)$net.result
  rmse <- sqrt(mean((predictions - y_val)^2))
  r2 <- 1 - sum((predictions - y_val)^2) / sum((y_val - mean(y_val))^2)
  
  return(list(
    model = model,
    performance = list(
      val_rmse = rmse,
      val_r2 = r2
    ),
    scaled_X = X_scaled
  ))
}

# ============================================================================
# HYPERPARAMETER TUNING
# ============================================================================

#' Grid search for hyperparameter optimization
#' @param X Feature matrix
#' @param y Target vector
#' @param param_grid Parameter grid list
#' @param model_type Type of model ("rf", "gbm", "nn")
#' @param cv_folds Number of CV folds
#' @return Best parameters and results
grid_search <- function(X, y, param_grid, model_type = "rf", cv_folds = 5) {
  # Generate parameter combinations
  param_combinations <- expand.grid(param_grid)
  
  results <- data.frame(
    params = I(list()),
    rmse = numeric(),
    r2 = numeric()
  )
  
  for (i in 1:nrow(param_combinations)) {
    params <- as.list(param_combinations[i, ])
    
    # Train model with current parameters
    if (model_type == "rf") {
      cv_indices <- createFolds(y, k = cv_folds, returnTrain = TRUE)
      cv_rmse <- numeric(cv_folds)
      cv_r2 <- numeric(cv_folds)
      
      for (fold in 1:cv_folds) {
        train_idx <- cv_indices[[fold]]
        val_idx <- setdiff(1:nrow(X), train_idx)
        
        model <- randomForest::randomForest(
          X[train_idx, ], y[train_idx],
          ntree = params$ntree,
          mtry = params$mtry
        )
        
        pred <- predict(model, X[val_idx, ])
        cv_rmse[fold] <- sqrt(mean((pred - y[val_idx])^2))
        cv_r2[fold] <- 1 - sum((pred - y[val_idx])^2) / sum((y[val_idx] - mean(y[val_idx]))^2)
      }
      
    } else if (model_type == "gbm") {
      model_result <- train_gradient_boosting(X, y, params, cv_folds)
      cv_rmse <- model_result$cv_results$evaluation_log$test_rmse_mean
      cv_r2 <- 1 - (cv_rmse^2) / var(y)
    }
    
    results <- rbind(results, data.frame(
      params = I(list(params)),
      rmse = mean(cv_rmse),
      r2 = mean(cv_r2)
    ))
    
    cat(sprintf("Params: ntree=%d, mtry=%d -> RMSE=%.2f, R2=%.3f\n",
                params$ntree, params$mtry, mean(cv_rmse), mean(cv_r2)))
  }
  
  # Find best parameters
  best_idx <- which.min(results$rmse)
  
  return(list(
    best_params = results$params[[best_idx]],
    best_rmse = results$rmse[best_idx],
    best_r2 = results$r2[best_idx],
    all_results = results
  ))
}

#' Bayesian optimization for hyperparameters
#' @param X Feature matrix
#' @param y Target vector
#' @param param_space Parameter space definition
#' @param n_iter Number of iterations
#' @return Optimization results
bayesian_optimization <- function(X, y, param_space = list(
  ntree = c(50, 500),
  mtry = c(2, 10)
), n_iter = 20) {
  
  # Define objective function
  objective <- function(params) {
    cv_indices <- createFolds(y, k = 5, returnTrain = TRUE)
    cv_rmse <- numeric(5)
    
    for (fold in 1:5) {
      train_idx <- cv_indices[[fold]]
      val_idx <- setdiff(1:nrow(X), train_idx)
      
      model <- randomForest::randomForest(
        X[train_idx, ], y[train_idx],
        ntree = round(params$ntree),
        mtry = round(params$mtry)
      )
      
      pred <- predict(model, X[val_idx, ])
      cv_rmse[fold] <- sqrt(mean((pred - y[val_idx])^2))
    }
    
    return(mean(cv_rmse))
  }
  
  # Use rBayesianOptimization package if available
  if (require(rBayesianOptimization, quietly = TRUE)) {
    opt_result <- BayesianOptimization(
      FUN = objective,
      bounds = list(
        ntree = c(param_space$ntree[1], param_space$ntree[2]),
        mtry = c(param_space$mtry[1], param_space$mtry[2])
      ),
      init_points = 5,
      n_iter = n_iter,
      acq = "ei",
      verbose = TRUE
    )
    
    return(opt_result)
  } else {
    # Fallback to random search
    cat("rBayesianOptimization not available, using random search\n")
    results <- list()
    
    for (i in 1:n_iter) {
      params <- list(
        ntree = runif(1, param_space$ntree[1], param_space$ntree[2]),
        mtry = runif(1, param_space$mtry[1], param_space$mtry[2])
      )
      
      rmse <- objective(params)
      results[[i]] <- c(params, rmse = rmse)
    }
    
    best_result <- results[[which.min(sapply(results, function(x) x$rmse))]]
    
    return(list(
      best_params = best_result[1:2],
      best_rmse = best_result$rmse,
      all_results = results
    ))
  }
}

# ============================================================================
# MODEL EVALUATION
# ============================================================================

#' Evaluate model performance
#' @param model Trained model
#' @param X_test Test features
#' @param y_test Test targets
#' @return Evaluation metrics
evaluate_model <- function(model, X_test, y_test) {
  predictions <- predict(model, X_test)
  
  metrics <- list(
    rmse = sqrt(mean((predictions - y_test)^2)),
    mae = mean(abs(predictions - y_test)),
    r_squared = 1 - sum((predictions - y_test)^2) / sum((y_test - mean(y_test))^2),
    mape = mean(abs((y_test - predictions) / y_test)) * 100
  )
  
  # Calculate confidence intervals
  residuals <- y_test - predictions
  se <- sd(residuals) / sqrt(length(y_test))
  metrics$ci_95 <- c(metrics$rmse - 1.96 * se, metrics$rmse + 1.96 * se)
  
  return(metrics)
}

#' Generate prediction intervals
#' @param model Trained model
#' @param X_new New data for prediction
#' @param confidence Confidence level (0-1)
#' @return Predictions with intervals
prediction_intervals <- function(model, X_new, confidence = 0.95) {
  predictions <- predict(model, X_new)
  
  # Calculate residuals from training data
  if (inherits(model, "randomForest")) {
    # Get OOB predictions for residual calculation
    oob_preds <- model$predicted
    actual_y <- model$y
    
    residuals <- actual_y - oob_preds
    residual_se <- sd(residuals)
    
    # Calculate prediction intervals
    z <- qnorm((1 + confidence) / 2)
    
    lower <- predictions - z * residual_se
    upper <- predictions + z * residual_se
    
    return(list(
      predictions = predictions,
      lower = lower,
      upper = upper,
      se = residual_se
    ))
  }
  
  return(list(predictions = predictions))
}

#' Compare multiple models
#' @param models List of trained models
#' @param X_test Test features
#' @param y_test Test targets
#' @return Comparison table
compare_models <- function(models, X_test, y_test) {
  comparison <- data.frame(
    model = character(),
    rmse = numeric(),
    mae = numeric(),
    r_squared = numeric()
  )
  
  for (name in names(models)) {
    metrics <- evaluate_model(models[[name]], X_test, y_test)
    
    comparison <- rbind(comparison, data.frame(
      model = name,
      rmse = metrics$rmse,
      mae = metrics$mae,
      r_squared = metrics$r_squared
    ))
  }
  
  comparison <- comparison[order(-comparison$r_squared), ]
  
  return(comparison)
}

# ============================================================================
# MODEL INTERPRETABILITY
# ============================================================================

#' Generate partial dependence plots
#' @param model Trained random forest model
#' @param X Training data
#' @param feature_name Feature to analyze
#' @param save_path Path to save plot
#' @return Partial dependence data
partial_dependence <- function(model, X, feature_name, save_path = NULL) {
  feature_idx <- which(colnames(X) == feature_name)
  
  # Get unique values of the feature
  feature_values <- sort(unique(X[, feature_idx]))
  
  pdp <- numeric(length(feature_values))
  
  # Calculate average prediction at each feature value
  for (i in seq_along(feature_values)) {
    X_temp <- X
    X_temp[, feature_idx] <- feature_values[i]
    pdp[i] <- mean(predict(model, X_temp))
  }
  
  # Create plot
  pdp_df <- data.frame(
    feature = feature_values,
    prediction = pdp
  )
  
  plot <- ggplot2::ggplot(pdp_df, ggplot2::aes(x = feature, y = prediction)) +
    ggplot2::geom_line(color = "steelblue", linewidth = 1) +
    ggplot2::geom_point(color = "steelblue") +
    ggplot2::labs(
      x = feature_name,
      y = "Average Prediction",
      title = paste("Partial Dependence Plot -", feature_name)
    ) +
    ggplot2::theme_minimal()
  
  if (!is.null(save_path)) {
    ggplot2::ggsave(save_path, plot, width = 8, height = 6)
  }
  
  return(list(
    feature_values = feature_values,
    pdp_values = pdp,
    plot = plot
  ))
}

#' Generate SHAP values (approximation for tree models)
#' @param model Trained model
#' @param X Feature matrix
#' @param sample_size Number of samples to use
#' @return SHAP values matrix
calculate_shap_values <- function(model, X, sample_size = 100) {
  if (!require(shapviz, quietly = TRUE)) {
    cat("shapviz package not available, using permutation importance\n")
    return(NULL)
  }
  
  # Sample data
  if (nrow(X) > sample_size) {
    sample_idx <- sample(1:nrow(X), sample_size)
    X_sample <- X[sample_idx, ]
  } else {
    X_sample <- X
  }
  
  # Calculate SHAP values
  shap_values <- shapviz::shapviz(model, X_sample)
  
  return(shap_values)
}

# ============================================================================
# MODEL EXPORT
# ============================================================================

#' Export model to file
#' @param model Trained model
#' @param file_path Path to save model
#' @param type Model type ("rds", "onnx", "pmml")
#' @return NULL
export_model <- function(model, file_path, type = "rds") {
  if (type == "rds") {
    saveRDS(model, file_path)
  } else if (type == "onnx") {
    if (require(onnx, quietly = TRUE)) {
      onnx::write_onnx_model(model, file_path)
    } else {
      warning("ONNX export not available")
    }
  } else if (type == "pmml") {
    if (require(pmml, quietly = TRUE)) {
      pmml::pmml(model, file_path)
    } else {
      warning("PMML export not available")
    }
  }
}

#' Import model from file
#' @param file_path Path to model file
#' @return Loaded model
import_model <- function(file_path) {
  if (!file.exists(file_path)) {
    stop("Model file not found: ", file_path)
  }
  
  if (grepl("\\.rds$", file_path)) {
    return(readRDS(file_path))
  } else if (grepl("\\.onnx$", file_path)) {
    if (require(onnx, quietly = TRUE)) {
      return(onnx::read_onnx_model(file_path))
    } else {
      stop("ONNX package not available")
    }
  }
  
  stop("Unsupported model format")
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

if (!interactive() && !identical(Sys.getenv("R_SCRIPT"), "")) {
  args <- commandArgs(trailingOnly = TRUE)
  
  if (length(args) >= 2) {
    data_file <- args[1]
    output_file <- args[2]
    
    if (file.exists(data_file)) {
      data <- readRDS(data_file)
      
      # Prepare features
      prepared <- prepare_features(data, target_col = "target")
      
      # Train model
      rf_result <- train_random_forest(prepared$X, prepared$y, n_trees = 100)
      
      # Export results
      saveRDS(rf_result, output_file)
      
      cat("Model trained and saved!\n")
      cat("CV RMSE:", rf_result$performance$cv_rmse, "\n")
      cat("CV R2:", rf_result$performance$cv_r2, "\n")
    }
  } else {
    cat("Usage: Rscript optimization.r <data.rds> <output.rds>\n")
  }
}

