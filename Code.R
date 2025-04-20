# Step 1 Loading necessary libraries
  library(arules)
  library(dplyr)
  library(ggplot2)
  library(caTools)
  library(cluster)

# Step 2 Load the datasets
  customer_data <- read.csv('customer_data.csv')
  purchase_history <- read.csv('customer_purchase_history_final.csv')
  View(customer_data)
  View(purchase_history)
  
  #Check number of rows
  print(nrow(customer_data)) #Customer data has 50,000 rows
  print(nrow(purchase_history)) #Purchase history has 83,384
  
  combined_data <- merge(customer_data, purchase_history, by="row.names") #Combining two dataset into one
  print(nrow(combined_data))
  View(combined_data)

  # Check for duplicates entries per customer
  table(duplicated(combined_data)) # 0 duplicate entries found
  
# Step 3 Data Exploration
  str(combined_data)
  head(combined_data)
  summary(combined_data)
  
# Step 4 Data Cleaning
  missing_values <- sum(is.na(combined_data))
  missing_values # None (0)
  
  # Feature scaling
  numerical_indices <- sapply(combined_data, is.numeric)  # Find all numeric columns in the dataset
  numerical_indices["customer_id"] <- FALSE  # Excluding 'customer_id'
  
  # Scale the numeric columns
  combined_data[, numerical_indices] <- scale(combined_data[, numerical_indices])
  
  # Summary to see the result of scaling
  summary(combined_data[, numerical_indices])
  View(combined_data)

# Step 5 Data Preparation
  combined_data$loyalty_member <- as.factor(combined_data$loyalty_member)
  combined_data$gender <- as.factor(combined_data$gender)
  combined_data$state <- as.factor(combined_data$state)
  
  # Convert the 'time_as_customer' to a numeric scale
  combined_data$time_as_customer <- as.numeric(as.character(combined_data$time_as_customer))
  
  # Check if any NA
  if (anyNA(combined_data$time_as_customer)) {
    cat("NA values found in 'time_as_customer' after conversion.\n")
  }
  
  # Validating numeric conversion
  summary(combined_data$time_as_customer)
  
# Step 6 Data Model using Apriori algorithm
  
  library(arulesViz)
  
  # Convert the dataset to a transaction class
  trans_data <- as(combined_data, "transactions")
  
  # Apply the Apriori algorithm for market basket analysis
  rules <- apriori(trans_data, parameter = list(support = 0.001, confidence = 0.2))
  
  # order rules by lift to find the best association rules for product recommendations
  ordered_rules <- sort(rules, by = "lift")
  inspect(ordered_rules[1:10])
  
  # Visualizing the rules
  plot(ordered_rules[1:10], method = "graph", control = list(type = "items"))
  
# Step 7 Data Evaluation
  
  # Analyzing the top rules to derive marketing insights
  top_rules <- ordered_rules[1:10]
  item_labels <- labels(lhs(top_rules)) # Leftbhand side items of the rules
  
  # items commonly bought together
  print("Top Product Combinations:")
  print(item_labels)
  
  # Visualizing support and confidence of top rules
  plot(top_rules, measure=c("support", "confidence"), shading="confidence")
  
  # Deriving actionable marketing strategies
  for (rule in 1:length(top_rules)) {
    lhs_items <- paste(labels(lhs(top_rules[rule])), collapse=", ")
    rhs_items <- paste(labels(rhs(top_rules[rule])), collapse=", ")
    message <- sprintf("Customers who bought %s also bought %s. Consider cross-selling these products in marketing campaigns.", lhs_items, rhs_items)
    print(message)
  }
  
# Step 8 Constructing the Product Recommendation Model
  
  # Convert the data frame to a transaction format
  trans_data <- as(combined_data[, -c(1:4)], "transactions")
  
  # Applying the Apriori Algorithm
  rules <- apriori(trans_data, parameter = list(support = 0.001, confidence = 0.2))

  # Sorting the rules by lift and inspect the top 10 rules
  sorted_rules <- sort(rules, by = "lift")
  inspect(sorted_rules[1:10])
  
# Step 9 Visualizing the Rules
  # Scatter Plot of Support vs. Confidence
  plot(sorted_rules, measure=c("support", "confidence"), shading="lift", main="Support vs Confidence", jitter = 0)
  
  # Graph Plot of the top rules
  subrules <- head(sort(rules, by="lift"), 10)
  plot(subrules, method="graph", control=list(type="items"))
  
  # Matrix Plot of the top rules
  plot(subrules, method="matrix", control=list(reorder="none"))