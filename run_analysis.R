library(data.table)

path<-getwd()
path_dataset <- file.path(path, "UCI HAR Dataset")
if (!file.exists(path_dataset)){
    url <- "https://d396qusza40orc.cloudataframeront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    f <- 'ProjectData.zip'
    
    if (!file.exists(path)) {dir.create(path)}
    download.file(url, file.path(path, f))
    unzip("ProjectData.zip")
    
}

# 1 1.Merges the training and the test sets to create one data set

dataframe_train_set<-read.table(file.path(path_dataset,"train","X_train.txt"))
Data_train_set<-data.table(dataframe_train_set)

dataframe_test_set<-read.table(file.path(path_dataset,"test","X_test.txt"))
Data_test_set<-data.table(dataframe_test_set)

Data_set <- rbind(Data_train_set, Data_test_set)

dataframe_subject_train<-read.table(file.path(path_dataset,"train","subject_train.txt"))
Data_subject_train<-data.table(dataframe_subject_train)

dataframe_subject_test<-read.table(file.path(path_dataset,"test","subject_test.txt"))
Data_subject_test<-data.table(dataframe_subject_test)

Data_subject <- rbind(Data_subject_train, Data_subject_test)
setnames(Data_subject, names(Data_subject), c("subject_id"))

dataframe_label_train <-read.table(file.path(path_dataset,"train","y_train.txt"))
Data_label_train <-data.table(dataframe_label_train)

dataframe_label_test <-read.table(file.path(path_dataset,"test","y_test.txt"))
Data_label_test <-data.table(dataframe_label_test)

Data_label <- rbind(Data_label_train, Data_label_test)

setnames(Data_label, names(Data_label), c("activity_id"))

Data_set<-cbind(Data_set,Data_subject, Data_label)

# 2.Extracts only the measurements on the mean and standard deviation for each measurement

dataframe_features <- read.table(file.path(path_dataset,"features.txt"))
Data_features<-data.table(dataframe_features)

setnames(Data_features, names(Data_features), c("feature_id", "feature_name"))

my_logical_features <- grep ("mean\\(\\)|std\\(\\)", Data_features$feature_name)

Data_set_mean_std <- Data_set[,my_logical_features,with=FALSE]
Data_set_mean_std$subject_id <- Data_set$subject_id
Data_set_mean_std$activity_id <- Data_set$activity_id


# 3.Uses descriptive activity names to name the activities in the data set

dataframe_activity_labels <- read.table(file.path(path_dataset,"activity_labels.txt"))
Data_activity_labels <- data.table(dataframe_activity_labels)
setnames(Data_activity_labels, names(Data_activity_labels), c("activity_id", "activity_name"))
Data_set_mean_std <- merge(Data_set_mean_std, Data_activity_labels, by="activity_id", all.x=TRUE)

order_column<-names(Data_set_mean_std)[c(2:dim(Data_set_mean_std)[2],1)]
setcolorder(Data_set_mean_std, order_column)


# 4. Appropriately labels the data set with descriptive variable names. 
Data_features_logical <- Data_features[my_logical_features,]
setnames(Data_set_mean_std, names(Data_set_mean_std)[1:dim(Data_features_logical)[1]], as.character(Data_features_logical$feature_name))



# 5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
column_selected <- 1:((dim(Data_set_mean_std)[2])-3)
Data_tidy<-aggregate(Data_set_mean_std[,column_selected,with=FALSE],
                   (list(Data_set_mean_std$activity_name, Data_set_mean_std$subject_id)),mean)

setnames(Data_tidy, names(Data_tidy)[1:2], c("Activity_Name", "Subject_Id"))

f <- file.path(path, "tidy_data.txt")
write.table(Data_tidy, f, quote = FALSE, sep = "\t", row.names = FALSE)
