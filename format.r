library(dplyr)
library(readr)
library(R6)

Data <- R6::R6Class("Data",
                    public = list(
                      data = list(),
                      
                      initialize = function(data_dir = NULL, data_name = "default_data", data = NULL) {
                        if (!is.null(data_dir)) {
                          data <- self$data_loader(data_dir)
                        }
                        self$data[[data_name]] <- data
                      },
                      
                      check_data_name = function(data_name) {
                        if (!(data_name %in% names(self$data))) {
                          stop("Data name does not exist")
                        }
                      },
                      
                      data_loader = function(data_dir) {
                        if (file.exists(data_dir)) {
                          data <- read.csv(data_dir)
                          return(data)
                        } else {
                          stop("Directory does not exist")
                        }
                      },
                      
                      add_or_replace_data = function(data_or_data_dir, data_name) {
                        if (is.character(data_or_data_dir)) {
                          data <- self$data_loader(data_or_data_dir)
                        } else {
                          data <- data_or_data_dir
                        }
                        self$data[[data_name]] <- data
                      },
                      
                      data_copier_fetcher = function(data_or_data_name, deep_copy = FALSE) {
                        if (is.character(data_or_data_name)) {
                          if (!(data_or_data_name %in% names(self$data))) {
                            stop("Data name does not exist")
                          }
                          data <- self$data[[data_or_data_name]]
                        } else {
                          data <- data_or_data_name
                        }
                        
                        if (deep_copy) {
                          return(data.frame(data))
                        } else {
                          return(data)
                        }
                      },
                      
                      group = function(col_name, data_or_data_name = "default_data", store_into = NULL) {
                        data <- self$data_copier_fetcher(data_or_data_name, deep_copy = TRUE)
                        
                        if (is.character(col_name)) {
                          col_name <- list(col_name)
                        }
                        
                        for (col in col_name) {
                          if (!(col %in% colnames(data))) {
                            stop(paste("Column name:", col, "does not exist"))
                          }
                        }
                        
                        data_grouped <- data %>% group_by(across(all_of(col_name)))
                        
                        if (!is.null(store_into)) {
                          self$data[[store_into]] <- data_grouped
                        }
                        
                        return(data_grouped)
                      },
                      
                      append_items = function(data_name, data_to_append) {
                        self$check_data_name(data_name)
                        self$data[[data_name]] <- rbind(self$data[[data_name]], data_to_append)
                      },
                      
                      drop_items = function(data_name, items_to_drop) {
                        self$check_data_name(data_name)
                        
                        if (is.data.frame(items_to_drop)) {
                          drop_idx <- which(self$data[[data_name]] %in% items_to_drop)
                          self$data[[data_name]] <- self$data[[data_name]][-drop_idx, ]
                        } else if (is.list(items_to_drop) || is.vector(items_to_drop)) {
                          self$data[[data_name]] <- self$data[[data_name]][-items_to_drop, ]
                        } else {
                          stop("items_to_drop's type is not supported")
                        }
                      },
                      
                      replace_items = function(data_name, items_to_replace, items_to_replace_with) {
                        self$check_data_name(data_name)
                        
                        if (is.data.frame(items_to_replace)) {
                          replace_idx <- which(self$data[[data_name]] %in% items_to_replace)
                          self$data[[data_name]][replace_idx, ] <- items_to_replace_with
                        } else if (is.list(items_to_replace) || is.vector(items_to_replace)) {
                          self$data[[data_name]][items_to_replace, ] <- items_to_replace_with
                        } else {
                          stop("items_to_replace's type is not supported")
                        }
                      },
                      
                      filter = function(data_name, filter_func, ...) {
                        self$check_data_name(data_name)
                        filtered_data <- filter_func(self$data[[data_name]], ...)
                        return(filtered_data)
                      },
                      
                      cleaner = function(data_name = "default_data", merge_VT = TRUE, clean_NaN_in_Score = TRUE) {
                        # Placeholder function
                      },
                      
                      split_by_attribute = function(data_name, attribute) {
                        self$check_data_name(data_name)
                        
                        if (!(attribute %in% colnames(self$data[[data_name]]))) {
                          stop("Attribute does not exist")
                        }
                        
                        splitted_data <- self$data[[data_name]] %>% group_by(!!sym(attribute))
                        ls <- list()
                        for (key in unique(self$data[[data_name]][[attribute]])) {
                          ls[[key]] <- filter(splitted_data, !!sym(attribute) == key)
                        }
                        return(ls)
                      }
                    )
)

Gymnastic_Data_Analyst <- R6Class("Gymnastic_Data_Analyst",
                                  inherit = Data,
                                  
                                  public = list(
                                    initialize = function(data_dir = NULL, data_name = "default_data") {
                                      super$initialize(data_dir, data_name)
                                      private$cleaner(data_name)
                                    },
                                    
                                    summary_for_each_athlete = function(data_name = "default_data", store_into = NULL) {
                                      self$data[[data_name]]$FullName <- paste(self$data[[data_name]]$FirstName, self$data[[data_name]]$LastName, sep="_")
                                      grouped_data <- split(self$data[[data_name]], self$data[[data_name]]$FullName)
                                      apparatus_ls <- unique(self$data[[data_name]]$Apparatus)
                                      
                                      # 初始化summary_data为一个空的数据框
                                      summary_data <- data.frame(matrix(ncol = length(colnames(self$data[[data_name]])) + length(apparatus_ls) - 1))
                                      colnames(summary_data) <- c(colnames(self$data[[data_name]])[-which(colnames(self$data[[data_name]]) == "Apparatus")], apparatus_ls)
                                      
                                      # 使用一个列表来存储每个运动员的individual_summary_data
                                      summary_list <- list()
                                      
                                      for(name in names(grouped_data)) {
                                        group <- grouped_data[[name]]
                                        individual_grouped_data <- split(group, group$Apparatus)
                                        individual_summary_data <- group[1, ]
                                        individual_summary_data$Apparatus <- NULL
                                        for(apparatus in apparatus_ls) {
                                          individual_summary_data[[apparatus]] <- NA
                                        }
                  
                                        for(apparatus in names(individual_grouped_data)) {
                                          sub_group <- individual_grouped_data[[apparatus]]
                                          average_score <- mean(sub_group$Score, na.rm = TRUE)
                                          individual_summary_data[[apparatus]] <- average_score
                                        }
                                        
                                        # 将individual_summary_data添加到summary_list中
                                        summary_list[[name]] <- individual_summary_data
                                      }
                                      
                                      # 使用do.call(rbind, summary_list)来合并所有数据
                                      summary_data <- do.call(rbind, summary_list)
                                      
                                      if(!is.null(store_into)) {
                                        self$data[[store_into]] <- summary_data
                                      } else {
                                        return(summary_data)
                                      }
                                    }
                                  ),
                                  
                                  private = list(
                                    cleaner = function(data_name = "default_data", merge_VT = TRUE, clean_NaN_in_Score = TRUE) {
                                      super$cleaner(data_name, merge_VT, clean_NaN_in_Score)
                                      
                                      data <- self$data[[data_name]]
                                      
                                      if("Apparatus" %in% colnames(data)) {
                                        levels(data$Apparatus) <- c("VT1", "VT2", "HB", "VT_1", "VT_2")
                                        if(merge_VT) {
                                          data$Apparatus[data$Apparatus == "VT1" | data$Apparatus == "VT2"| data$Apparatus == "VT_2"| data$Apparatus == "VT_1"] <- "VT"
                                          data$Apparatus[data$Apparatus == "hb"] <- "HB"
                                        }
                                      }
                                      
                                      if(clean_NaN_in_Score && "Score" %in% colnames(data)) {
                                        data <- data[!is.na(data$Score), ]
                                      }
                                      
                                      self$data[[data_name]] <- data
                                    },
                                    
                                    group = function(col_name, data_or_data_name) {
                                      if(is.character(data_or_data_name)) {
                                        data <- self$data[[data_or_data_name]]
                                      } else {
                                        data <- data_or_data_name
                                      }
                                      
                                      grouped_data <- split(data, data[col_name])
                                      return(grouped_data)
                                    }
                                  )
)


main <- function() {
  data <- Gymnastic_Data_Analyst$new(data_dir = "data/data_2022_2023.csv", data_name = "gymnasts")
  data$cleaner(data_name = "gymnasts")
  print(names(data$data_copier_fetcher(data_or_data_name="gymnasts")$Apparatus))
  print("good")
  ls <- data$split_by_attribute(data_name = "gymnasts", attribute = "Country")
  for (i in 1:6) {
    cat(names(ls)[i], "\n")
    print(ls[[i]])
    cat("\n")
  }
  
  # 生成 summary_data
  data$summary_for_each_athlete(data_name="gymnasts", store_into="summary_data")
  
  # 将数据写入CSV文件
  summary_data <- data$data_copier_fetcher(data_or_data_name="summary_data")
  write.csv(summary_data, file = "summary_data_r.csv", row.names = FALSE)
  
  # 输出已写入文件的消息
  cat("Summary data has been written to summary_data.csv\n")
}

main()
