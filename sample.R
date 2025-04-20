# Step 1: Loading necessary libraries
library(arules)
library(dplyr)
library(ggplot2)
library(caTools)
library(cluster)
library(arulesViz) # For visualization of association rules
library(h2o)      # Provides functions for working with deep learning models

# Initializing the H2O machine learning platform, utilizing all available CPU threads
h2o.init(nthreads = -1)

# Step 2: Load the datasets
tryCatch({
  customer_data <- read.csv('customer_data.csv')
  purchase_history <- read.csv('customer_purchase_history_final.csv')
}, error = function(e) {
  stop("Error: Unable to load datasets. Please check file paths and ensure files exist.")
})

# Step 3: Data Exploration and Cleaning
explore_and_clean_data <- function(data) {
  # Basic exploration
  str(data)
  head(data)
  summary(data)
  
  # Check for missing values
  missing_values <- sum(is.na(data))
  if (missing_values > 0) {
    print(paste("Warning: There are", missing_values, "missing values in the dataset."))
    # Optionally handle missing values here
  }
  
  # Feature scaling
  numerical_indices <- sapply(data, is.numeric)  # Find all numeric columns
  numerical_indices["customer_id"] <- FALSE  # Exclude 'customer_id' from scaling
  data[, numerical_indices] <- scale(data[, numerical_indices])
  
  return(data)
}

combined_data <- merge(customer_data, purchase_history, by="row.names")
combined_data <- explore_and_clean_data(combined_data)

# Step 4: Data Preparation
prepare_data <- function(data) {
  data$loyalty_member <- as.factor(data$loyalty_member)
  data$gender <- as.factor(data$gender)
  data$state <- as.factor(data$state)
  
  # Convert the 'time_as_customer' to a numeric scale
  data$time_as_customer <- as.numeric(as.character(data$time_as_customer))
  
  return(data)
}

combined_data <- prepare_data(combined_data)

# Step 5: Data Modeling - Market Basket Analysis
apply_market_basket_analysis <- function(data) {
  # Convert the dataset to a transaction class for applying the Apriori algorithm
  trans_data <- as(data, "transactions")
  
  # Apply the Apriori algorithm for market basket analysis
  rules <- apriori(trans_data, parameter = list(support = 0.001, confidence = 0.2))
  
  # Order rules by lift to find the best association rules for product recommendation
  ordered_rules <- sort(rules, by = "lift")
  
  return(ordered_rules)
}

market_basket_rules <- apply_market_basket_analysis(combined_data)

# Step 6: Visualizing Market Basket Analysis Results
visualize_market_basket_analysis <- function(rules) {
  # Visualizing the rules
  plot(rules[1:10], method = "graph", control = list(type = "items"))
}

visualize_market_basket_analysis(market_basket_rules)

# Step 7: Insights and Recommendations - Market Basket Analysis
generate_market_basket_insights <- function(rules) {
  # Analyze the top rules to derive marketing insights
  top_rules <- rules[1:10]
  item_labels <- labels(lhs(top_rules)) # Left-hand side items of the rules
  
  # Understanding what items are most commonly bought together
  print("Top Product Combinations:")
  print(item_labels)
  
  # Visualize support and confidence of top rules
  plot(top_rules, measure=c("support", "confidence"), shading="confidence")
  
  # Derive actionable marketing strategies from the rules
  for (rule in 1:length(top_rules)) {
    lhs_items <- paste(labels(lhs(top_rules[rule])), collapse=", ")
    rhs_items <- paste(labels(rhs(top_rules[rule])), collapse=", ")
    message <- sprintf("Customers who bought %s also bought %s. Consider cross-selling these products in marketing campaigns.", lhs_items, rhs_items)
    print(message)
  }
}

generate_market_basket_insights(market_basket_rules)

# Step 8: Constructing the Product Recommendation Model
construct_recommendation_model <- function(data) {
  # Convert the data frame to a transactional format
  trans_data <- as(data[, -c(1:4)], "transactions")
  
  # Generate rules using the Apriori algorithm
  rules <- apriori(trans_data, parameter = list(support = 0.001, confidence = 0.2))
  
  # Sort the rules by lift and inspect the top 10 rules
  sorted_rules <- sort(rules, by = "lift")
  
  return(sorted_rules)
}

recommendation_rules <- construct_recommendation_model(combined_data)

# Step 9: Visualizing Recommendation Model
visualize_recommendation_model <- function(rules) {
  # Scatter Plot of Support vs. Confidence
  plot(rules, measure=c("support", "confidence"), shading="lift", main="Support vs Confidence", jitter = 0)
  
  # Graph Plot
  # Create a graph plot of the top rules
  subrules <- head(sort(rules, by="lift"), 10)
  plot(subrules, method="graph", control=list(type="items"))
  
  # Matrix Plot
  # Generate a matrix plot of the top rules
  plot(subrules, method="matrix", control=list(reorder="none"))
}

visualize_recommendation_model(recommendation_rules)
