# Equivalent R libraries for the Python imports
library(dplyr)       # Equivalent to pandas for data manipulation
library(tidyr)       # For reshaping data
library(data.table)  # Advanced data manipulation similar to pandas
library(stringdist)  # For string matching, equivalent to fuzzywuzzy
library(R.utils)     # For reading and writing binary files, a potential equivalent to pickle
library(fs)          # Filesystem operations, for some os functionalities
library(R6)

Data <- R6::R6Class("Data",
                    private = list(
                      .load_dir = NULL,
                      
                      .data_loader = function(data_dir) {
                        if (file.exists(data_dir)) {
                          data <- read.csv(data_dir)
                          return(data)
                        } else {
                          stop("Directory does not exist")
                        }
                      },
                      
                      .check_data_name = function(data_name) {
                        if (!(data_name %in% names(self$data))) {
                          stop("Data name does not exist")
                        }
                      }
                    ),
                    
                    public = list(
                      data = list(),
                      
                    initialize = function(data_dir = NULL, data_name = "default_data", data = NULL, load_dir = NULL) {
                        if (!is.null(load_dir)) {
                          self$load_all_data(load_dir)
                          return(invisible(NULL))
                        }
                        if (!is.null(data_dir)) {
                          data <- private$.data_loader(data_dir)
                        }
                        self$data[[data_name]] <- data
                      },
                      
                      set_load_dir = function(dir) {
                        private$.load_dir <- dir
                      },

                      load_all_data = function(data_dir) {
                        if (!dir.exists(data_dir)) {
                          stop("Directory does not exist")
                        }
                        files <- list.files(data_dir, full.names = TRUE, pattern = "\\.csv$")
                        for (file in files) {
                          data_name <- tools::file_path_sans_ext(basename(file))
                          private$.add_or_replace_data(file, data_name)
                        }
                      },
                      
                      get_load_dir = function() {
                        return(private$.load_dir)
                      },
                      
                      check_data_name = function(data_name) {
                        if (!(data_name %in% names(self$data))) {
                          stop("Data name does not exist")
                        }
                      },
                      
                      data_loader = function(data_dir = private$.load_dir) {
                        if (is.null(data_dir)) {
                          stop("Please set the load_dir first.")
                        }
                        return(private$.data_loader(data_dir))
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
                        data <- self$data[[data_name]]
                        
                        if (merge_VT && "Apparatus" %in% names(data)) {
                          data$Apparatus <- ifelse(data$Apparatus %in% c("VT1", "VT2"), "VT", data$Apparatus)
                        }
                        
                        if (clean_NaN_in_Score && "Score" %in% names(data)) {
                          data <- data[!is.na(data$Score),]
                        }
                        
                        self$data[[data_name]] <- data
                      },
                      
                      split_by_attribute = function(data_name, attribute) {
                        self$check_data_name(data_name)
                        
                        if (!(attribute %in% names(self$data[[data_name]]))) {
                          stop("Attribute does not exist")
                        }
                        
                        splitted_data <- split(self$data[[data_name]], self$data[[data_name]][[attribute]])
                        return(splitted_data)
                      }
                    )
)

Gymnastic_Data_Analyst <- R6Class("Gymnastic_Data_Analyst",
                                  inherit = Data,
                                  
                                  public = list(
                                    initialize = function(data_dir = NULL, data_name = "default_data", data = NULL, load_dir = NULL) {
                                      # 使用super$initialize()确保所有参数都被传递到父类的初始化方法中
                                      super$initialize(data_dir = data_dir, data_name = data_name, data = data, load_dir = load_dir)
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
                                        
                                        individual_summary_data$Total <- sum(as.numeric(individual_summary_data[apparatus_ls]), na.rm = TRUE)
                                        
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
  write.csv(summary_data, file = "summary_data_rsss.csv", row.names = FALSE)
  
  # 输出已写入文件的消息
  cat("Summary data has been written to summary_data.csv\n")
}
Gymnastic_Data_Analyst$new(load_dir = "data/formatted_data/")
main()
