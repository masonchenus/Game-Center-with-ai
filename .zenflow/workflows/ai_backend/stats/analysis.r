# Game Center Statistical Analysis Scripts
# R language scripts for game analytics and player statistics
# Used by both game center and ai_backend for data analysis

# ============================================================================
# DATA LOADING AND PREPARATION
# ============================================================================

#' Load game scores from JSON file
#' @param file_path Path to the scores JSON file
#' @return Data frame of scores
load_scores <- function(file_path) {
  if (!file.exists(file_path)) {
    warning("File not found: ", file_path)
    return(data.frame())
  }
  
  json_data <- jsonlite::fromJSON(file_path)
  
  # Convert to data frame
  scores_df <- as.data.frame(json_data)
  
  # Convert date column
  if ("date" %in% colnames(scores_df)) {
    scores_df$date <- as.POSIXct(scores_df$date)
  }
  
  return(scores_df)
}

#' Clean and preprocess score data
#' @param scores_df Raw scores data frame
#' @return Cleaned data frame
clean_scores <- function(scores_df) {
  # Remove duplicates
  scores_df <- unique(scores_df)
  
  # Remove rows with missing scores
  scores_df <- scores_df[complete.cases(scores_df[, c("score", "playerName")]), ]
  
  # Remove invalid scores
  scores_df <- scores_df[scores_df$score >= 0, ]
  
  # Sort by date
  if ("date" %in% colnames(scores_df)) {
    scores_df <- scores_df[order(scores_df$date, decreasing = TRUE), ]
  }
  
  return(scores_df)
}

# ============================================================================
# DESCRIPTIVE STATISTICS
# ============================================================================

#' Calculate descriptive statistics for scores
#' @param scores Vector of scores
#' @return List of statistics
calculate_score_stats <- function(scores) {
  if (length(scores) == 0) {
    return(list(
      count = 0,
      mean = NA,
      median = NA,
      sd = NA,
      min = NA,
      max = NA,
      q1 = NA,
      q3 = NA,
      iqr = NA,
      skewness = NA,
      kurtosis = NA
    ))
  }
  
  stats <- list(
    count = length(scores),
    mean = mean(scores),
    median = median(scores),
    sd = sd(scores),
    min = min(scores),
    max = max(scores),
    q1 = quantile(scores, 0.25),
    q3 = quantile(scores, 0.75),
    iqr = IQR(scores)
  )
  
  # Calculate skewness and kurtosis
  if (length(scores) > 2) {
    stats$skewness <- sum(((scores - stats$mean) / stats$sd)^3) / length(scores)
    stats$kurtosis <- sum(((scores - stats$mean) / stats$sd)^4) / length(scores) - 3
  }
  
  return(stats)
}

#' Generate summary statistics by player
#' @param scores_df Scores data frame
#' @return Player statistics data frame
player_summary_stats <- function(scores_df) {
  if (!"playerName" %in% colnames(scores_df)) {
    stop("Data frame must contain 'playerName' column")
  }
  
  player_stats <- aggregate(score ~ playerName, data = scores_df, FUN = function(x) {
    list(
      count = length(x),
      mean = mean(x),
      total = sum(x),
      max = max(x),
      first_play = min(as.Date(date)),
      last_play = max(as.Date(date))
    )
  })
  
  # Flatten the list column
  player_stats$count <- sapply(player_stats$score, function(x) x$count)
  player_stats$mean_score <- sapply(player_stats$score, function(x) x$mean)
  player_stats$total_score <- sapply(player_stats$score, function(x) x$total)
  player_stats$max_score <- sapply(player_stats$score, function(x) x$max)
  player_stats$first_play <- sapply(player_stats$score, function(x) x$first_play)
  player_stats$last_play <- sapply(player_stats$score, function(x) x$last_play)
  
  player_stats$score <- NULL
  
  return(player_stats)
}

#' Generate summary statistics by game
#' @param scores_df Scores data frame
#' @return Game statistics data frame
game_summary_stats <- function(scores_df) {
  if (!"gameName" %in% colnames(scores_df)) {
    stop("Data frame must contain 'gameName' column")
  }
  
  game_stats <- aggregate(score ~ gameName, data = scores_df, FUN = function(x) {
    list(
      total_scores = length(x),
      unique_players = length(unique(scores_df$playerName[scores_df$gameName %in% current_game])),
      mean_score = mean(x),
      total_points = sum(x)
    )
  })
  
  return(game_stats)
}

# ============================================================================
# DISTRIBUTION ANALYSIS
# ============================================================================

#' Test normality of score distribution
#' @param scores Vector of scores
#' @return Shapiro-Wilk test result
test_normality <- function(scores) {
  if (length(scores) < 3 || length(scores) > 5000) {
    return(list(
      is_normal = NA,
      p_value = NA,
      message = "Sample size must be between 3 and 5000"
    ))
  }
  
  # Use Shapiro-Wilk test for normality
  if (length(scores) <= 5000) {
    test_result <- shapiro.test(sample(scores, min(length(scores), 5000)))
    return(list(
      is_normal = test_result$p.value > 0.05,
      p_value = test_result$p.value,
      statistic = test_result$statistic
    ))
  }
  
  return(list(is_normal = NA, p_value = NA))
}

#' Fit distribution to scores
#' @param scores Vector of scores
#' @return Fitted distribution parameters
fit_distribution <- function(scores) {
  # Try normal distribution
  normal_fit <- fitdistrplus::fitdist(scores, "norm")
  
  # Try log-normal distribution
  tryCatch({
    lognormal_fit <- fitdistrplus::fitdist(scores[scores > 0], "lnorm")
    return(list(
      normal = normal_fit,
      lognormal = lognormal_fit
    ))
  }, error = function(e) {
    return(list(normal = normal_fit))
  })
}

#' Create score distribution histogram
#' @param scores Vector of scores
#' @param game_name Name of the game (for title)
#' @param save_path Path to save the plot
plot_score_distribution <- function(scores, game_name = "Game", save_path = NULL) {
  hist_plot <- ggplot2::ggplot(data.frame(score = scores), 
                               ggplot2::aes(x = score)) +
    ggplot2::geom_histogram(bins = 30, fill = "steelblue", color = "white", alpha = 0.7) +
    ggplot2::geom_vline(xintercept = mean(scores), color = "red", linetype = "dashed", 
                        linewidth = 1, label = "Mean") +
    ggplot2::geom_vline(xintercept = median(scores), color = "green", linetype = "dotted", 
                        linewidth = 1, label = "Median") +
    ggplot2::labs(
      title = paste("Score Distribution -", game_name),
      x = "Score",
      y = "Frequency"
    ) +
    ggplot2::theme_minimal()
  
  if (!is.null(save_path)) {
    ggplot2::ggsave(save_path, hist_plot, width = 10, height = 6)
  }
  
  return(hist_plot)
}

# ============================================================================
# TREND ANALYSIS
# ============================================================================

#' Analyze score trends over time
#' @param scores_df Scores data frame with date column
#' @param player_name Player to analyze (NULL for all)
#' @return Trend analysis results
analyze_score_trends <- function(scores_df, player_name = NULL) {
  if (!"date" %in% colnames(scores_df)) {
    stop("Data frame must contain 'date' column")
  }
  
  if (!is.null(player_name)) {
    scores_df <- scores_df[scores_df$playerName == player_name, ]
  }
  
  if (nrow(scores_df) == 0) {
    return(list(message = "No data found"))
  }
  
  # Aggregate by day
  scores_df$date_only <- as.Date(scores_df$date)
  daily_scores <- aggregate(score ~ date_only, data = scores_df, FUN = mean)
  
  # Fit linear regression for trend
  trend_model <- lm(score ~ as.numeric(date_only), data = daily_scores)
  trend_summary <- summary(trend_model)
  
  # Calculate moving average
  daily_scores$ma7 <- zoo::rollmean(daily_scores$score, k = 7, fill = NA)
  
  return(list(
    daily_scores = daily_scores,
    trend_model = trend_model,
    trend_pvalue = trend_summary$coefficients[2, 4],
    trend_direction = ifelse(trend_summary$coefficients[2, 1] > 0, "increasing", "decreasing"),
    r_squared = trend_summary$r.squared
  ))
}

#' Detect anomalies in scores
#' @param scores Vector of scores
#' @param threshold Z-score threshold for anomaly detection
#' @return List of anomalies
detect_score_anomalies <- function(scores, threshold = 3) {
  z_scores <- scale(scores)
  anomaly_indices <- which(abs(z_scores) > threshold)
  
  return(list(
    anomalies = data.frame(
      index = anomaly_indices,
      score = scores[anomaly_indices],
      z_score = as.vector(z_scores[anomaly_indices])
    ),
    total_anomalies = length(anomaly_indices),
    percentage_anomalies = length(anomaly_indices) / length(scores) * 100
  ))
}

# ============================================================================
# PLAYER SEGMENTATION
# ============================================================================

#' Segment players based on behavior
#' @param player_stats Player statistics data frame
#' @return Segmented players
segment_players <- function(player_stats) {
  # Normalize features for clustering
  features <- player_stats[, c("count", "mean_score", "max_score")]
  features_scaled <- scale(features)
  
  # Perform K-means clustering
  set.seed(42)
  kmeans_result <- kmeans(features_scaled, centers = 3)
  
  # Assign segment labels
  player_stats$segment <- kmeans_result$cluster
  
  # Name segments based on characteristics
  segment_means <- aggregate(. ~ segment, data = player_stats[, c("segment", "count", "mean_score")], 
                             FUN = mean)
  segment_means <- segment_means[order(-segment_means$mean_score), ]
  
  segment_names <- c("Champions", "Regular Players", "Casual Players")
  names(segment_names) <- segment_means$segment
  
  player_stats$segment_name <- segment_names[as.character(player_stats$segment)]
  
  return(player_stats)
}

#' Calculate player retention
#' @param scores_df Scores data frame
#' @param periods Number of periods to analyze
#' @return Retention rates by period
calculate_retention <- function(scores_df, periods = 4) {
  # Weekly retention
  scores_df$week <- format(scores_df$date, "%Y-W%W")
  
  retention_data <- data.frame(
    period = character(),
    retained = numeric(),
    new = numeric(),
    retention_rate = numeric()
  )
  
  for (i in 1:periods) {
    current_week <- unique(scores_df$week)[i]
    previous_weeks <- unique(scores_df$week)[1:(i-1)]
    
    current_players <- unique(scores_df$playerName[scores_df$week == current_week])
    returning_players <- current_players[current_players %in% 
                                          unlist(lapply(previous_weeks, function(w) 
                                            unique(scores_df$playerName[scores_df$week == w])))]
    
    new_players <- setdiff(current_players, unlist(lapply(previous_weeks[previous_weeks != ""], function(w) 
      unique(scores_df$playerName[scores_df$week == w]))))
    
    retention_rate <- length(returning_players) / length(current_players) * 100
    
    retention_data <- rbind(retention_data, data.frame(
      period = current_week,
      retained = length(returning_players),
      new = length(new_players),
      retention_rate = retention_rate
    ))
  }
  
  return(retention_data)
}

# ============================================================================
# CORRELATION ANALYSIS
# ============================================================================

#' Analyze correlation between player metrics
#' @param player_stats Player statistics data frame
#' @return Correlation matrix
analyze_metric_correlations <- function(player_stats) {
  numeric_cols <- c("count", "mean_score", "max_score", "total_score")
  numeric_data <- player_stats[, numeric_cols, drop = FALSE]
  
  cor_matrix <- cor(numeric_data, use = "complete.obs")
  
  return(list(
    correlation_matrix = cor_matrix,
    significant_correlations = which(abs(cor_matrix) > 0.5 & cor_matrix != 1)
  ))
}

#' Compare game popularity
#' @param scores_df Scores data frame
#' @return Popularity comparison
compare_game_popularity <- function(scores_df) {
  if (!"gameName" %in% colnames(scores_df)) {
    stop("Data frame must contain 'gameName' column")
  }
  
  popularity <- data.frame(
    game = character(),
    total_scores = numeric(),
    unique_players = numeric(),
    avg_score = numeric(),
    engagement_score = numeric()
  )
  
  for (game in unique(scores_df$gameName)) {
    game_data <- scores_df[scores_df$gameName == game, ]
    
    engagement <- nrow(game_data) * mean(game_data$score)
    
    popularity <- rbind(popularity, data.frame(
      game = game,
      total_scores = nrow(game_data),
      unique_players = length(unique(game_data$playerName)),
      avg_score = mean(game_data$score),
      engagement_score = engagement
    ))
  }
  
  popularity <- popularity[order(-popularity$engagement_score), ]
  
  return(popularity)
}

# ============================================================================
# EXPORT FUNCTIONS
# ============================================================================

#' Export analysis results to JSON
#' @param results List of results to export
#' @param file_path Output file path
#' @return NULL
export_results_json <- function(results, file_path) {
  jsonlite::writeJSON(results, file_path, pretty = TRUE, auto_unbox = TRUE)
}

#' Generate comprehensive report
#' @param scores_df Scores data frame
#' @param output_dir Output directory for reports
#' @return Report summary
generate_report <- function(scores_df, output_dir = "reports") {
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  report <- list(
    generated_at = Sys.time(),
    total_records = nrow(scores_df),
    date_range = list(
      start = min(scores_df$date),
      end = max(scores_df$date)
    ),
    score_statistics = calculate_score_stats(scores_df$score),
    player_count = length(unique(scores_df$playerName)),
    game_count = length(unique(scores_df$gameName))
  )
  
  # Export report
  export_results_json(report, file.path(output_dir, "summary_report.json"))
  
  # Plot score distribution
  plot_score_distribution(scores_df$score, "All Games", 
                          file.path(output_dir, "score_distribution.png"))
  
  return(report)
}

# ============================================================================
# MAIN EXECUTION (when run as script)
# ============================================================================

if (!interactive() && !identical(Sys.getenv("R_SCRIPT"), "")) {
  # Get command line arguments
  args <- commandArgs(trailingOnly = TRUE)
  
  if (length(args) > 0) {
    scores_file <- args[1]
    
    if (file.exists(scores_file)) {
      scores <- load_scores(scores_file)
      scores <- clean_scores(scores)
      
      report <- generate_report(scores)
      cat("Report generated successfully!\n")
      cat("Total records:", report$total_records, "\n")
      cat("Players:", report$player_count, "\n")
      cat("Games:", report$game_count, "\n")
    } else {
      cat("Error: File not found:", scores_file, "\n")
    }
  } else {
    cat("Usage: Rscript analysis.r <scores_file.json>\n")
  }
}

